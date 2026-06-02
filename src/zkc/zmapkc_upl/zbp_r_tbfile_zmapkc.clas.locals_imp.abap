CLASS lhc__file DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_status,
        success   TYPE c VALUE 'S',
        error     TYPE c VALUE 'E',
        warning   TYPE c VALUE 'W',
        inprocess TYPE c VALUE 'I',
      END OF c_status.

    TYPES: BEGIN OF gty_excel,
             sacct   TYPE string,
             bukrs   TYPE string,
             rulty   TYPE string,
             dacct   TYPE string,
             dacct2  TYPE string,
             account TYPE string,
             dcost   TYPE string,
             dprctr  TYPE string,
             oacct   TYPE string,
             ocost   TYPE string,
             oprctr  TYPE string,
             lineid type int4,
           END OF gty_excel,
           tt_row TYPE STANDARD TABLE OF gty_excel.
" 1. Định nghĩa kiểu dữ liệu cấu trúc (Structure Type)
TYPES: BEGIN OF ty_s_mapkc_with_id.
         INCLUDE TYPE ztb_zmapkc. " Lấy toàn bộ các trường của bảng gốc ztb_zmapkc
TYPES:   lineid TYPE sy-tabix.    " Thêm trường lineid (kiểu số nguyên chỉ mục hệ thống)
TYPES: END OF ty_s_mapkc_with_id.


    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zrtbfilezmapkc RESULT result.

    METHODS getdatafile FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zrtbfilezmapkc~getdatafile.

    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zrtbfilezmapkc~setinitialstatus.

    METHODS setdata FOR DETERMINE ON SAVE
      IMPORTING keys FOR zrtbfilezmapkc~setdata.

    DATA lt_insert TYPE TABLE FOR CREATE zr_tbzmapkc000\\zrtbzmapkc000.
    DATA lt_update TYPE TABLE FOR UPDATE zr_tbzmapkc000\\zrtbzmapkc000.
    DATA lt_create_preview TYPE TABLE FOR CREATE zr_tbzmapkc000\\zrtbzmapkc000.

ENDCLASS.

CLASS lhc__file IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD getdatafile.
    DATA:
          lv_sub_crate       TYPE posnr_vl.

    READ ENTITIES OF zr_tbfile_zmapkc IN LOCAL MODE
    ENTITY zrtbfilezmapkc
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    CLEAR: lt_insert, lt_update.

    " Get attachment value from the instance
    IF lt_header IS INITIAL.
      RETURN.
    ELSE.
      FINAL(lv_attachment) = lt_header[ 1 ]-attachment.
    ENDIF.

    IF lv_attachment IS INITIAL.

    ENDIF.

  ENDMETHOD.

  METHOD setinitialstatus.
    READ ENTITIES OF zr_tbfile_zmapkc IN LOCAL MODE
    ENTITY zrtbfilezmapkc
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    MODIFY ENTITIES OF zr_tbfile_zmapkc IN LOCAL MODE
    ENTITY zrtbfilezmapkc
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR ls_header IN lt_header (
                    %tky = ls_header-%tky
                    status = c_status-inprocess
                    ) )
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD setdata.
    DATA: lv_error TYPE zde_char1.
    DATA: lt_rows    TYPE tt_row.

    READ ENTITIES OF zr_tbfile_zmapkc IN LOCAL MODE
       ENTITY zrtbfilezmapkc
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_header).

    CLEAR: lt_insert, lt_update, lt_create_preview.

    " Get attachment value from the instance
    IF lt_header IS INITIAL.
      RETURN.
    ELSE.
      FINAL(lv_attachment) = lt_header[ 1 ]-attachment.
    ENDIF.

    IF lv_attachment IS INITIAL.

    ENDIF.

    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ). "First worksheet

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    DATA:lv_lineid type int4,
         lv_lifnr type lifnr.
    DATA:lv_amountvnd TYPE zde_amount23.
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<f_file>).

      FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_to( REF #( lt_rows ) )->if_xco_xlsx_ra_operation~execute( ).

      DELETE lt_rows INDEX 1.
      DELETE ADJACENT DUPLICATES FROM lt_rows COMPARING ALL FIELDS.
      IF lt_rows IS INITIAL.
        RETURN.
      ENDIF.


      DATA:lt_checkdata TYPE TABLE OF ty_s_mapkc_with_id.
      lt_checkdata = CORRESPONDING #( lt_rows ).
      LOOP AT lt_checkdata ASSIGNING FIELD-SYMBOL(<LFS_check>).
      lv_lineid += 1.
      <LFS_check>-lineid = lv_lineid.
      ENDLOOP.
      SORT lt_checkdata BY bukrs sacct.

      SELECT bukrs, sacct
      FROM ztb_zmapkc
      where bukrs in ( select bukrs from @lt_checkdata as data )
      ORDER BY  bukrs, sacct
      INTO TABLE @DATA(lt_zmapkc).

       SELECT FROM @lt_checkdata AS data
      innER join I_GLAccount WITH PRIVILEGED ACCESS AS  GL on GL~GLAccount = data~sacct
     FIELDS  DISTINCT GL~GLAccount
     ORDER BY GL~GLAccount
      into table @data(lt_glaccountlist).

       SELECT FROM @lt_checkdata AS data
      innER join I_GLAccountInCompanyCode WITH PRIVILEGED ACCESS AS  GL_COMP on GL_COMP~GLAccount = data~sacct and gl_comp~CompanyCode = data~bukrs
     FIELDS  DISTINCT gl_comp~CompanyCode, GL_COMP~GLAccount
     ORDER BY gl_comp~CompanyCode, GL_COMP~GLAccount
      into table @data(lt_glaccount).

       SELECT  FROM @lt_checkdata AS data
      innER join I_CompanyCode WITH PRIVILEGED ACCESS AS  COmpany on company~CompanyCode = data~bukrs
  FIELDS DISTINCT company~COmpanycode
  ORDER BY  company~COmpanycode
      into table @data(lt_company).

      data: lv_index type int4.
      LOOP AT lt_rows INTO DATA(ls_row).
      lv_index += 1.
lv_lifnr = ls_row-account.
lv_lifnr = |{ lv_lifnr ALPHA = IN }|.
      READ TABLE lt_company INTO DATA(LS_company) WITH KEY CompanyCode = ls_row-bukrs BINARY SEARCH.
      if SY-SUBRC = 0 AND LS_company-CompanyCode = ls_row-bukrs.
      ELSE.
       lv_error  = abap_true.
         APPEND VALUE #( %tky = <f_file>-%tky
                          %msg = new_message( id = 'ZMC_FI'
                                             number = '010'
                                             v1 = ls_row-bukrs
                                             v2 = lv_index
                                             severity = if_abap_behv_message=>severity-error ) ) TO reported-zrtbfilezmapkc.

      ENDIF.

 READ TABLE lt_glaccountlist TRANSPORTING NO FIELDS WITH KEY GLAccount = ls_row-sacct BINARY SEARCH.
      if SY-SUBRC = 0.
      ELSE.
       lv_error  = abap_true.
          APPEND VALUE #( %tky = <f_file>-%tky
                          %msg = new_message( id = 'ZMC_FI'
                                             number = '009'
                                             v1 = ls_row-sacct
                                             v2 = lv_index
                                             severity = if_abap_behv_message=>severity-error ) ) TO reported-zrtbfilezmapkc.

      ENDIF.

        READ TABLE lt_zmapkc TRANSPORTING NO FIELDS WITH KEY bukrs = ls_row-bukrs sacct = ls_row-sacct BINARY SEARCH.
        IF sy-subrc = 0.
          lv_error  = abap_true.
          APPEND VALUE #( %tky = <f_file>-%tky
                          %msg = new_message( id = 'ZMC_FI'
                                             number = '001'
                                             v2 = ls_row-bukrs
                                             v1 = ls_row-sacct
                                             severity = if_abap_behv_message=>severity-error ) ) TO reported-zrtbfilezmapkc.


        ENDIF.
" Tìm chính xác Index của dòng ĐẦU TIÊN trong nhóm trùng bukrs và sacct
DATA(lv_start_index) = line_index( lt_checkdata[ bukrs = ls_row-bukrs
                                                 sacct = ls_row-sacct ] ).

IF lv_start_index > 0. " Nếu tìm thấy ít nhất 1 dòng trùng

  " Vòng lặp chắc chắn sẽ quét từ dòng đầu tiên của nhóm cho đến hết nhóm
  LOOP AT lt_checkdata TRANSPORTING NO FIELDS
                       FROM lv_start_index
                       WHERE bukrs  = ls_row-bukrs
                         AND sacct  = ls_row-sacct.

    " Check xem có dòng nào có lineid khác với dòng hiện tại (lv_index) không
    IF lt_checkdata[ sy-tabix ]-lineid <> lv_index.
      lv_error = abap_true.
       lv_error = abap_true.
          APPEND VALUE #(
            %tky = <f_file>-%tky
            %msg = new_message(
                     id       = 'ZMC_FI'
                     number   = '002'
                     v1       = ls_row-sacct " Giữ nguyên v1, v2 như code mẫu của bạn
                     v2       = ls_row-bukrs
                     severity = if_abap_behv_message=>severity-error
                   )
          ) TO reported-zrtbfilezmapkc. " Bạn nhớ check lại xem có cần đổi tên bảng reported này không nhé

      EXIT. " Tìm thấy lỗi là thoát luôn
    ENDIF.

  ENDLOOP.
ENDIF.


        if ls_row-rulty = '3A' and ls_row-account is inITIAL.
        lv_error = abap_true.
           APPEND VALUE #(
            %tky = <f_file>-%tky
            %msg = new_message(
                     id       = 'ZMC_FI'
                     number   = '007'
                     v1 = lv_index
                     severity = if_abap_behv_message=>severity-error
                   )
          ) TO reported-zrtbfilezmapkc.
        ENDIF.
        if ls_row-account is not inITIAL and ls_row-dacct is not inITIAL.
         lv_error = abap_true.
           APPEND VALUE #(
            %tky = <f_file>-%tky
            %msg = new_message(
                     id       = 'ZMC_FI'
                     number   = '008'
                     severity = if_abap_behv_message=>severity-error
                   )
          ) TO reported-zrtbfilezmapkc.
        ENDIF.

        " Kiểm tra các trường chung bắt buộc trước, sau đó check 1 trong 4 điều kiện riêng đi kèm
IF ls_row-sacct IS INITIAL OR ls_row-bukrs IS INITIAL OR ls_row-rulty IS INITIAL OR ls_row-oacct IS INITIAL
   OR NOT (
     ( ls_row-dacct   IS NOT INITIAL AND ls_row-dcost  IS NOT INITIAL AND ls_row-ocost  IS NOT INITIAL ) OR " TH1
     ( ls_row-dacct   IS NOT INITIAL AND ls_row-dprctr IS NOT INITIAL AND ls_row-oprctr IS NOT INITIAL ) OR " TH2
     ( ls_row-account IS NOT INITIAL AND ls_row-oprctr IS NOT INITIAL )                                  OR " TH3
     ( ls_row-account IS NOT INITIAL AND ls_row-ocost  IS NOT INITIAL )                                     " TH4
   ).

  " --- THỰC HIỆN BÁO LỖI ---
  lv_error = abap_true.

  APPEND VALUE #(
    %tky = <f_file>-%tky
    %msg = new_message(
             id       = 'ZMC_FI'
             number   = '006'
             v1 = lv_index
             severity = if_abap_behv_message=>severity-error
           )
  ) TO reported-zrtbfilezmapkc.

ENDIF.
if lv_error is inITIAL.
READ TABLE lt_glaccount TRANSPORTING NO FIELDS WITH KEY CompanyCode = ls_row-bukrs GLAccount = ls_row-sacct BINARY SEARCH.
if SY-SUBRC = 0.

ELSE.
    lv_error = abap_true.
           APPEND VALUE #(
            %tky = <f_file>-%tky
            %msg = new_message(
                     id       = 'ZMC_FI'
                     v1 = ls_row-sacct
                     v2 = ls_row-bukrs
                     number   = '005'
                     severity = if_abap_behv_message=>severity-error
                   )
          ) TO reported-zrtbfilezmapkc.
ENDIF.
ENDIF.
        IF lv_error IS INITIAL.
          FINAL(lv_tabix) = sy-tabix.
          APPEND VALUE #( %is_draft = <f_file>-%is_draft
                            sacct = ls_row-sacct
                            bukrs  = ls_row-bukrs
                            rulty = ls_row-rulty
                            dacct = ls_row-dacct
                            dcost = ls_row-dcost
                            dacct2 = ls_row-dacct2
                            account = lv_lifnr
                            dprctr = ls_row-dprctr
                            oacct = ls_row-oacct
                            ocost = ls_row-ocost
                            oprctr = ls_row-oprctr
                                              createdby              = <f_file>-createdby
                                                 createdat              = <f_file>-createdat
                                                 lastchangedby    = <f_file>-locallastchangedby
                                                 locallastchangedat     = <f_file>-locallastchangedat
                                                 lastchangedat          = <f_file>-lastchangedat )
                 TO lt_create_preview.
        ENDIF.
      ENDLOOP.
      IF  lv_error  <> abap_true.
        IF lt_create_preview IS NOT INITIAL.
          " Step 3: Update new data
          MODIFY ENTITIES OF zr_tbzmapkc000
                 ENTITY zrtbzmapkc000
                        CREATE FIELDS ( sacct bukrs dacct dcost dprctr oacct ocost oprctr rultname rulty  account  )
                AUTO FILL CID WITH
                 lt_create_preview
                 FAILED DATA(lt_preview_fail)
                 REPORTED DATA(lt_preview_reported).
        ENDIF.

      ENDIF.
      CLEAR: lt_create_preview, lv_error.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_tbfile_zmapkc DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.



    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_tbfile_zmapkc IMPLEMENTATION.



  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
