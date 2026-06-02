CLASS zcl_zi_fa_zaa01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES tt_data TYPE STANDARD TABLE OF zfa_r_zaa01_n WITH EMPTY KEY.
    TYPES: BEGIN OF gty_excel,
             "Header
             h_company_name        TYPE string,
             h_company_add         TYPE string,
             h_company_mst         TYPE string,
             h_title_report        TYPE string,
             h_title_subtitle      TYPE string,
             "item title
             i_title_stt           TYPE string,
             i_title_nhomtaisan    TYPE string,
             i_title_mataisan      TYPE string,
             i_title_tentaisan     TYPE string,
             i_title_plant         TYPE string,
             i_title_profitcenter  TYPE string,
             i_title_vitri         TYPE string,
             i_title_ngayphatsinh  TYPE string,
             i_title_ngayketthuc   TYPE string,
             i_title_trangthai     TYPE string,
             i_title_tknguyengia   TYPE string,
             i_title_tkkhauhao     TYPE string,
             i_title_tkchiphi      TYPE string,
             i_title_costcenter    TYPE string,
             i_title_macu          TYPE string,
             i_title_ngaybatdau    TYPE string,
             i_title_soluong       TYPE string,
             i_title_donvitinh     TYPE string,
             i_title_sokykhauhao   TYPE string,
             i_title_sokydakhauhao TYPE string,
             i_title_sokyconlai    TYPE string,
             i_title_dk_nguyengia  TYPE string,
             i_title_dk_khauhao    TYPE string,
             i_title_dk_conlai     TYPE string,
             i_title_pst_nguyengia TYPE string,
             i_title_pst_khauhao   TYPE string,
             i_title_psg_nguyengia TYPE string,
             i_title_psg_khauhao   TYPE string,
             i_title_ck_nguyengia  TYPE string,
             i_title_ck_khauhao    TYPE string,
             i_title_ck_conlai     TYPE string,
             i_title_dk            TYPE string,
             i_title_pst           TYPE string,
             i_title_psg           TYPE string,
             i_title_ck            TYPE string,
             item                  TYPE tt_data,
             "footer
             f_title_total         TYPE string,
             f_sokykhauhao         TYPE string,
             f_sokydakhauhao       TYPE string,
             f_dk_nguyengia        TYPE string,
             f_dk_khauhao          TYPE string,
             f_dk_conlai           TYPE string,
             f_pst_nguyengia       TYPE string,
             f_pst_khauhao         TYPE string,
             f_psg_nguyengia       TYPE string,
             f_psg_khauhao         TYPE string,
             f_ck_nguyengia        TYPE string,
             f_ck_khauhao          TYPE string,
             f_ck_conlai           TYPE string,
             f_title_nguoilap      TYPE string,
             f_title_ketoantruong  TYPE string,
             f_title_giamdoc       TYPE string,
             f_subtitle            TYPE string,
             f_nguoilap            TYPE string,
             f_ketoantruong        TYPE string,
             f_giamdoc             TYPE string,
           END OF gty_excel,
           tt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.
    INTERFACES if_rap_query_provider .
*    INTERFACES if_rap_query_request .
    METHODS convert_date IMPORTING i_date      TYPE d
                         EXPORTING e_text_date TYPE string.

    METHODS get_data IMPORTING it_filter      TYPE  if_rap_query_filter=>tt_name_range_pairs
                     EXPORTING
                               e_tu_ky_den_ky TYPE string
                               et_data        TYPE tt_data
                               e_uuid         TYPE uuid
                               e_nguoilap     TYPE string
                               e_giamdoc      TYPE string
                               e_ketoan       TYPE string
                               e_companycode  TYPE string
                               e_tu_ky        TYPE string
                               e_den_ky       TYPE string
                               e_nam_bao_cao  TYPE string


                     .
    METHODS create_pdf IMPORTING it_data        TYPE tt_data
                                 i_tu_ky_den_ky TYPE string
                                 i_nguoilap     TYPE string
                                 i_giamdoc      TYPE string
                                 i_ketoan       TYPE string
                       EXPORTING
                                 e_pdf          TYPE xstring

                       .

    METHODS create_excel IMPORTING it_data        TYPE tt_data
                                   i_tu_ky_den_ky TYPE string
                                   i_nguoilap     TYPE string
                                   i_giamdoc      TYPE string
                                   i_ketoan       TYPE string
                         EXPORTING e_attachment   TYPE zde_attachment_tmpl
                         .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZI_FA_ZAA01 IMPLEMENTATION.


  METHOD convert_date.
    e_text_date = |{ i_date+6(2) }.{ i_date+4(2) }.{ i_date+0(4) }|.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA lt_data TYPE STANDARD TABLE OF zfa_r_zaa01_n WITH EMPTY KEY.
    DATA lt_data_page TYPE STANDARD TABLE OF zfa_r_zaa01_n.
    DATA: lv_uuid_fi          TYPE uuid.
    DATA : lv_ke_toan   TYPE string,
           lv_nguoi_lap TYPE string,
           lv_giam_doc  TYPE string.



    DATA: lv_tu_ky       TYPE string,
          lv_den_ky      TYPE string,
          lv_nam_bao_cao TYPE string,
          lv_date_tu_ky  TYPE d, " lấy ngày bắt đầu kì báo cáo theo tham số
          lv_date_den_ky TYPE d. " lấy ngày kết thúc kì báo cao theo tham số
    DATA lr_tu_ky TYPE if_rap_query_filter=>tt_range_option.
    DATA: lr_den_ky      TYPE if_rap_query_filter=>tt_range_option,
          lr_nam_bao_cao TYPE if_rap_query_filter=>tt_range_option,
          lr_companycode TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_masterfixedasset TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_fixedasset TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_assetclass TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_costcenter TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_ky_bao_cao TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_uuid TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
    DATA: lv_total_so_ky_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
    DATA: lv_total_so_ky_da_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
    DATA: lv_total_so_ky_con_lai TYPE zfa_r_zaa01_n-so_ky_khao_hao_con_lai.
    DATA: lv_total_nguyen_gia_dau_ky TYPE zfa_r_zaa01_n-nguyen_gia_dau_ky.
    DATA: lv_total_khauhao_luyke_dky TYPE zfa_r_zaa01_n-khau_hao_luy_ke_dau_ky.
    DATA: lv_total_giatri_conlai_dky TYPE zfa_r_zaa01_n-gia_tri_con_lai_dau_ky.
    DATA: lv_total_tangnguyengia_tk TYPE zfa_r_zaa01_n-tang_nguyen_gia_trong_ki.
    DATA: lv_total_tangkhauhao_tk TYPE zfa_r_zaa01_n-tang_khau_hao_trong_ki.
    DATA: lv_total_giamnguyengia_tk TYPE zfa_r_zaa01_n-giam_nguyen_gia_trong_ky.
    DATA: lv_total_giamkhauhao_tk TYPE zfa_r_zaa01_n-giam_khau_hao_trong_ky.
    DATA: lv_total_nguyengia_ck TYPE zfa_r_zaa01_n-nguyen_gia_cuoi_ky.
    DATA: lv_total_khau_hao_luy_ke_ck TYPE zfa_r_zaa01_n-khau_hao_luy_ke_cuoi_ky.
    DATA: lv_total_gia_tri_con_lai_ck TYPE zfa_r_zaa01_n-gia_tri_con_lai_cuoi_ky.
*    data: go_db_access TYPE REF TO lif_faa_md_cds_exit_db_access .
    DATA next_ky TYPE c LENGTH 2.
    DATA: lv_pdf TYPE xstring.
    DATA: lv_tabix TYPE i.
    DATA: lv_tu_ky_den_ky TYPE string.
    DATA: lv_companycode TYPE string.
*    DATA: lv_tu_ky       TYPE string.
*    DATA: lv_den_ky      TYPE string.
*    DATA: lv_nam_bao_cao TYPE string.
    " Filter
    DATA(ro_filter) = io_request->get_filter( ).
    " Conditions
    DATA(lv_conditions) = io_request->get_filter( )->get_as_sql_string( ).

    TRY.
        DATA(rt_ranges) = ro_filter->get_as_ranges( iv_drop_null_comparisons = abap_true ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    me->get_data(
      EXPORTING
        it_filter      = rt_ranges
      IMPORTING
        e_tu_ky_den_ky = lv_tu_ky_den_ky
        et_data        = lt_data
        e_uuid         = lv_uuid_fi
        e_giamdoc      = lv_giam_doc
        e_ketoan       = lv_ke_toan
        e_nguoilap     = lv_nguoi_lap
        e_companycode = lv_companycode
        e_tu_ky = lv_tu_ky
        e_den_ky = lv_den_ky
        e_nam_bao_cao = lv_nam_bao_cao

    ).
    IF lv_uuid_fi IS NOT INITIAL.

      me->create_pdf(
        EXPORTING
          it_data        = lt_data
          i_tu_ky_den_ky = lv_tu_ky_den_ky
           i_giamdoc     = lv_giam_doc
          i_ketoan       = lv_ke_toan
          i_nguoilap     = lv_nguoi_lap

        IMPORTING
          e_pdf   = lv_pdf

      ).
      SELECT SINGLE
            *
        FROM zr_tbfile_export
        WHERE reportid = 'ZAA01_EXC'
        INTO @DATA(ls_excel).
*      IF ls_excel IS INITIAL.
      DATA: lv_excel TYPE zde_attachment_tmpl.
      me->create_excel(
        EXPORTING
          it_data        = lt_data
          i_tu_ky_den_ky = lv_tu_ky_den_ky
          i_nguoilap     = lv_giam_doc
          i_giamdoc      = lv_ke_toan
          i_ketoan       = lv_nguoi_lap
        IMPORTING
          e_attachment   = lv_excel
      ).
*      else.
*        lv_excel = ls_excel-Attachment.
*      ENDIF.
**      TRY.
**          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
**               iv_service_instance_name   = 'ZADSTEMPLSTORE'
**               iv_use_destination_service = abap_false
**             ).
**
**          DATA(ls_template) = lo_store->get_template_by_name(
**            iv_get_binary    = abap_true
**            iv_form_name     = 'ZFA_F_ZAA01'
**            iv_template_name = 'ZFA_F_ZAA01'
**          ).
**        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error).
**          DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
**      ENDTRY.

      DATA: lv_stt TYPE string VALUE '1'.
      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_print>).
        <lfs_print>-stt = lv_stt.
*        IF <lfs_print>-attachment IS INITIAL.
        <lfs_print>-attachment = lv_pdf.
        <lfs_print>-mimetype = 'application/pdf'.
        <lfs_print>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
        <lfs_print>-attachment_exc = lv_excel.
        <lfs_print>-mimetype_exc = 'application/vnd.ms-excel'.
        <lfs_print>-filename_exc = 'ZAA01.xlsx'.
*        lv_stt += 1.
        <lfs_print>-companycode = lv_companycode.
        <lfs_print>-tu_ky = lv_tu_ky.
        IF lv_den_ky IS NOT INITIAL.
          <lfs_print>-den_ky = lv_den_ky.
        ELSE.
          <lfs_print>-den_ky = lv_tu_ky.
        ENDIF.
        <lfs_print>-nam_bao_cao = lv_nam_bao_cao.
      ENDLOOP.

      DATA(lo_saver) = NEW zcl_save_pdf_zaa01( ).
      lo_saver->save_pdf(
            iv_reportid = 'ZFA_ZGAA1'
            iv_objectid      = lv_uuid_fi
            iv_pdf      = lv_pdf
          ).
    ENDIF.
*  ELSE.
*    MOVE-CORRESPONDING lt_pdf TO lt_data.
*  ENDIF.
    " Top
    DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    " Skip
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).
    IF lv_top < 1.
      lv_top = 1.
    ENDIF.
    IF lines( lt_data ) > 0.
      LOOP AT lt_data INTO DATA(ls_row) TO 1 .          "#EC CI_NOORDER
        APPEND ls_row TO lt_data_page.
      ENDLOOP.
    ELSE.
      lt_data_page = lt_data.
    ENDIF.
    io_response->set_data( lt_data_page ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data_page ) ).
    ENDIF.
  ENDMETHOD.


  METHOD get_data.

    DATA: lv_tu_ky       TYPE string,
          lv_den_ky      TYPE string,
          lv_nam_bao_cao TYPE string,
          lv_date_tu_ky  TYPE d, " lấy ngày bắt đầu kì báo cáo theo tham số
          lv_date_den_ky TYPE d. " lấy ngày kết thúc kì báo cao theo tham số
    DATA lr_tu_ky TYPE if_rap_query_filter=>tt_range_option.
    DATA: lr_den_ky      TYPE if_rap_query_filter=>tt_range_option,
          lr_nam_bao_cao TYPE if_rap_query_filter=>tt_range_option,
          lr_companycode TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_masterfixedasset TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_fixedasset TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_assetclass TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_costcenter TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_ky_bao_cao TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_uuid TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
    DATA:     lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
*    DATA: lv_total_so_ky_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
*    DATA: lv_total_so_ky_da_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
*    DATA: lv_total_so_ky_con_lai TYPE zfa_r_zaa01_n-so_ky_khao_hao_con_lai.
*    DATA: lv_total_nguyen_gia_dau_ky TYPE zfa_r_zaa01_n-nguyen_gia_dau_ky.
*    DATA: lv_total_khauhao_luyke_dky TYPE zfa_r_zaa01_n-khau_hao_luy_ke_dau_ky.
*    DATA: lv_total_giatri_conlai_dky TYPE zfa_r_zaa01_n-gia_tri_con_lai_dau_ky.
*    DATA: lv_total_tangnguyengia_tk TYPE zfa_r_zaa01_n-tang_nguyen_gia_trong_ki.
*    DATA: lv_total_tangkhauhao_tk TYPE zfa_r_zaa01_n-tang_khau_hao_trong_ki.
*    DATA: lv_total_giamnguyengia_tk TYPE zfa_r_zaa01_n-giam_nguyen_gia_trong_ky.
*    DATA: lv_total_giamkhauhao_tk TYPE zfa_r_zaa01_n-giam_khau_hao_trong_ky.
*    DATA: lv_total_nguyengia_ck TYPE zfa_r_zaa01_n-nguyen_gia_cuoi_ky.
*    DATA: lv_total_khau_hao_luy_ke_ck TYPE zfa_r_zaa01_n-khau_hao_luy_ke_cuoi_ky.
*    DATA: lv_total_gia_tri_con_lai_ck TYPE zfa_r_zaa01_n-gia_tri_con_lai_cuoi_ky.
*    data: go_db_access TYPE REF TO lif_faa_md_cds_exit_db_access .
    DATA next_ky TYPE c LENGTH 2.
    DATA: lv_tabix TYPE i.
    DATA: lv_uuid_fi TYPE uuid.

    IF it_filter IS NOT INITIAL.
      LOOP AT it_filter INTO DATA(lw_range).
        CASE lw_range-name.
          WHEN 'MASTERFIXEDASSET'.
            lr_masterfixedasset = lw_range-range.
          WHEN 'FIXEDASSET'.
            lr_fixedasset = lw_range-range.
          WHEN 'ASSETCLASS'.
            lr_assetclass = lw_range-range.
          WHEN 'COSTCENTER'.
            lr_costcenter = lw_range-range.
          WHEN 'TU_KY'.
            lr_tu_ky = lw_range-range.
            e_tu_ky = lr_tu_ky[ 1 ]-low.
          WHEN 'DEN_KY'.
            lr_den_ky = lw_range-range.
            e_den_ky = lr_den_ky[ 1 ]-low.
          WHEN 'NAM_BAO_CAO'.
            lr_nam_bao_cao = lw_range-range.
            e_nam_bao_cao = lr_nam_bao_cao[ 1 ]-low.
          WHEN 'COMPANYCODE'.
            lr_companycode = lw_range-range.
            e_companycode = lr_companycode[ 1 ]-low.
          WHEN 'UUID'.
            lr_uuid = lw_range-range.
          WHEN 'KE_TOAN'.
            lr_ke_toan = lw_range-range.
          WHEN 'NGUOI_LAP'.
            lr_nguoi_lap = lw_range-range.
          WHEN 'GIAM_DOC'.
            lr_giam_doc = lw_range-range.
          WHEN OTHERS.
            " Do nothing for other fields
        ENDCASE.
      ENDLOOP.
    ENDIF.
*
*
*
*

    IF lr_uuid IS NOT INITIAL.
      SELECT *
      FROM ztb_zaa01_pdf
      WHERE object_id IN @lr_uuid
*  INTO TABLE @DATA(lt_pdf).
        INTO CORRESPONDING FIELDS OF TABLE @et_data.

      SELECT SINGLE
      *
      FROM zr_tbfile_export
      WHERE reportid = 'ZAA01_EXC'
      INTO @DATA(ls_excel).

      LOOP AT et_data ASSIGNING FIELD-SYMBOL(<lfs_e_data>).
        <lfs_e_data>-attachment_exc = ls_excel-attachment.
        <lfs_e_data>-mimetype_exc = ls_excel-mimetype.
        <lfs_e_data>-filename_exc = ls_excel-filename.
      ENDLOOP.
    ENDIF.

    IF lr_masterfixedasset IS NOT INITIAL.
      LOOP AT lr_masterfixedasset ASSIGNING FIELD-SYMBOL(<lfs_masterfixedasset>).
        <lfs_masterfixedasset>-low = |0000{ <lfs_masterfixedasset>-low }|.
        IF <lfs_masterfixedasset>-high IS NOT INITIAL.
          <lfs_masterfixedasset>-high = |0000{ <lfs_masterfixedasset>-high }|.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF et_data IS INITIAL.
      TRY.
          lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
        CATCH cx_uuid_error INTO DATA(lw_er).
          DATA(lv_text_er) = lw_er->get_text( ).
      ENDTRY.
      DATA : lv_ke_toan   TYPE string,
             lv_nguoi_lap TYPE string,
             lv_giam_doc  TYPE string.

      IF lr_ke_toan IS NOT INITIAL.
        lv_ke_toan = lr_ke_toan[ 1 ]-low.
      ENDIF .
      IF lr_nguoi_lap IS NOT INITIAL.
        lv_nguoi_lap = lr_nguoi_lap[ 1 ]-low.
      ENDIF.
      IF lr_giam_doc IS NOT INITIAL.
        lv_giam_doc = lr_giam_doc[ 1 ]-low.
      ENDIF.
      lv_tu_ky = lr_tu_ky[ 1 ]-low.
      lv_nam_bao_cao = lr_nam_bao_cao[ 1 ]-low.
      SHIFT lv_tu_ky LEFT DELETING LEADING '0'.
      IF lv_tu_ky < 10.
        lv_tu_ky = |0{ lv_tu_ky }|.
      ENDIF.
      lv_date_tu_ky = lv_nam_bao_cao && lv_tu_ky && '01'.

      IF lr_den_ky IS NOT INITIAL.
        lv_den_ky = lr_den_ky[ 1 ]-low.
        next_ky = lv_den_ky + 1.
        IF next_ky < 10.
          next_ky = |0{ next_ky }|.
        ENDIF.
        lv_date_den_ky = |{ lv_nam_bao_cao }{ next_ky }01|.
        lv_date_den_ky = CONV d( lv_date_den_ky - 1  ) .
        e_tu_ky_den_ky = |Từ kỳ { lv_tu_ky } đến kỳ { lv_den_ky } năm { lv_nam_bao_cao }|.
      ELSE.
        lv_den_ky = lr_tu_ky[ 1 ]-low.
        next_ky = lv_den_ky + 1.
        IF next_ky < 10.
          next_ky = |0{ next_ky }|.
        ENDIF.
        lv_date_den_ky = |{ lv_nam_bao_cao }{ next_ky }01|.
        lv_date_den_ky = CONV d( lv_date_den_ky - 1  ) .
        e_tu_ky_den_ky = |Từ kỳ { lv_tu_ky } năm { lv_nam_bao_cao }|.
      ENDIF.
      APPEND VALUE #( low = | 0{ lv_tu_ky }|
                      high = |0{ lv_den_ky }|
                      option = 'BT'
                      sign = 'I' ) TO lr_ky_bao_cao.

      DATA(lv_check_date) = |{ lv_nam_bao_cao }{ lv_tu_ky }|.
      "Select data
      SELECT
      masterfixedasset,
      masterfixedassetdescription,
      companycode,
      fixedasset,
      assetnumber,
      assetclass,
      assetclass_desc,
      tencongty,
      diachicongty,
      mstcongty,
      plant,
      profitcenter,
      assetlocation,
      assetlocation_desc,
      assetcapitalizationdate,
      assetdeactivationdate,
      costcenter,
      costcenter_desc,
      quantity,
      baseunit,
      depreciationstartdate,
      inventory,
      ul_periods AS plannedusefullifeinperiods,
      ul_years AS plannedusefullifeinyears,
      reportid,
      objectid,
      attachment,
      mimetype,
      filename
       FROM zfa_v_zaa01( p_tu_ki = @lv_date_tu_ky, p_den_ki = @lv_date_den_ky ) AS data
      WHERE data~companycode IN @lr_companycode
      AND data~masterfixedasset IN @lr_masterfixedasset
      AND data~fixedasset IN @lr_fixedasset
      AND data~assetclass IN @lr_assetclass
      AND data~costcenter IN @lr_costcenter
      AND data~period_year <= @lv_check_date
       ORDER BY companycode, masterfixedasset, fixedasset , assetclass
      INTO CORRESPONDING FIELDS OF TABLE @et_data
*        UP TO @lv_top ROWS
*         OFFSET @lv_skip
      .

      SELECT
      masterfixedasset,
      companycode,
    fixedasset,
    plant~plant,
    plant~plantname
    FROM i_fixedassetassgmt AS assgmt
    INNER JOIN i_plant  AS plant ON plant~plant = assgmt~plant
*     AND plant~language = 'E'
         WHERE assgmt~companycode IN @lr_companycode
    AND assgmt~masterfixedasset IN @lr_masterfixedasset
    AND assgmt~fixedasset IN @lr_fixedasset
    ORDER BY companycode, masterfixedasset,fixedasset
    INTO TABLE @DATA(lt_assgmt).

      SELECT
       *
      FROM zfa_i_zaa01_sum_asset AS sum_asset

      WHERE sum_asset~companycode IN @lr_companycode
      AND sum_asset~masterfixedasset IN @lr_masterfixedasset
      AND sum_asset~fixedasset IN @lr_fixedasset
      AND sum_asset~report_period IN @lr_ky_bao_cao
      AND sum_asset~report_year IN @lr_nam_bao_cao
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_tang_nguyen_gia_trong_ki).

      SELECT
      *
      FROM zfa_i_zaa01_tkhtk AS tkhtk
      WHERE tkhtk~companycode IN @lr_companycode
      AND tkhtk~masterfixedasset IN @lr_masterfixedasset
      AND tkhtk~fixedasset IN @lr_fixedasset
      AND tkhtk~report_period IN @lr_ky_bao_cao
      AND tkhtk~report_year IN @lr_nam_bao_cao
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_tang_khau_hao_trong_ki).

      SELECT *
  FROM zfa_i_zaa01_gngtk AS gngtk
  WHERE gngtk~companycode IN @lr_companycode
  AND gngtk~masterfixedasset IN @lr_masterfixedasset
  AND gngtk~fixedasset IN @lr_fixedasset
  AND gngtk~report_period IN @lr_ky_bao_cao
  AND gngtk~report_year IN @lr_nam_bao_cao
  ORDER BY companycode, masterfixedasset, fixedasset
  INTO TABLE @DATA(lt_giam_nguyen_gia_trong_ki).

      DATA lv_period_1 TYPE string.
      lv_period_1 = lv_tu_ky.
      SHIFT lv_period_1 LEFT DELETING LEADING '0'.
      IF lv_period_1 < 10.
        lv_period_1 = |00{ lv_period_1 }|.
      ELSE.
        lv_period_1 = |0{ lv_period_1 }|.
      ENDIF.
      DATA(lv_fiscalyearperiod) = |{ lr_nam_bao_cao[ 1 ]-low }{ lv_period_1 }|.

      SELECT
      SUM( amountintransactioncurrency ) AS amountintransactioncurrency,
      masterfixedasset,
      fixedasset
      FROM i_glaccountlineitemrawdata AS gl_data
      WHERE gl_data~sourceledger = '0L'
      AND (  gl_data~assettransactiontype = '105' )
      AND gl_data~assetdepreciationarea = '01'
      AND gl_data~fiscalyearperiod < @lv_fiscalyearperiod
      AND gl_data~masterfixedasset IN @lr_masterfixedasset
      AND gl_data~fixedasset IN @lr_fixedasset
      GROUP BY masterfixedasset, fixedasset
      ORDER BY masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_nguyen_gia_dau_ki_1).



      SELECT
            gl_data~sourceledger,
            gl_data~companycode,
            gl_data~fiscalyear,
            gl_data~masterfixedasset,
            gl_data~fixedasset,
            gl_data~fiscalperiod                       AS report_period,
            gl_data~fiscalyear                         AS report_year,
            gl_data~ledgerfiscalyear,
            gl_data~fiscalyearperiod,
            gl_data~transactioncurrency,
            CAST( concat( gl_data~fiscalyear, concat( right( gl_data~fiscalperiod , 2 ) , '01' ) ) AS DATS ) AS report_year_period,
            SUM( amountintransactioncurrency ) AS amount_in_transaction_currency
         FROM i_glaccountlineitemrawdata AS gl_data
         INNER JOIN @et_data AS zc_data ON gl_data~fixedasset = zc_data~fixedasset
                                       AND gl_data~masterfixedasset = zc_data~masterfixedasset
         WHERE gl_data~sourceledger = '0L'
         AND gl_data~assetdepreciationarea = '01'
         AND ( gl_data~assettransactiontype = '100' OR gl_data~assettransactiontype = '970' )
*       AND gl_data~fiscalyearperiod IN @lr_ky_bao_cao
*       AND gl_data~fiscalyear IN @lr_nam_bao_cao

         GROUP BY
            gl_data~sourceledger,
            gl_data~companycode,
            gl_data~fiscalyear,
            gl_data~masterfixedasset,
            gl_data~fixedasset,
            gl_data~fiscalperiod,
            gl_data~fiscalyear,
            gl_data~ledgerfiscalyear,
            gl_data~fiscalyearperiod,
            gl_data~transactioncurrency
         INTO TABLE @DATA(lt_ngdk).
      SORT lt_ngdk BY masterfixedasset fixedasset.

      SELECT
     gl_data~sourceledger,
     gl_data~companycode,
     gl_data~fiscalyear,
     gl_data~masterfixedasset,
     gl_data~fixedasset,
     gl_data~fiscalperiod                       AS report_period,
     gl_data~fiscalyear                         AS report_year,
     gl_data~ledgerfiscalyear,
     gl_data~fiscalyearperiod,
     gl_data~transactioncurrency,
     CAST( concat( gl_data~fiscalyear, concat( right( gl_data~fiscalperiod , 2 ) , '01' ) ) AS DATS ) AS report_year_period,
     SUM( amountintransactioncurrency ) AS amount_in_transaction_currency
  FROM i_glaccountlineitemrawdata AS gl_data
  INNER JOIN @et_data AS zc_data ON gl_data~fixedasset = zc_data~fixedasset
                                AND gl_data~masterfixedasset = zc_data~masterfixedasset
  WHERE gl_data~sourceledger = '0L'
  AND gl_data~assetdepreciationarea = '01'
  AND  gl_data~assettransactiontype = '500'
*AND gl_data~fiscalyearperiod IN @lr_ky_bao_cao
*    AND gl_data~fiscalyear IN @lr_nam_bao_cao
  GROUP BY
     gl_data~sourceledger,
     gl_data~companycode,
     gl_data~fiscalyear,
     gl_data~masterfixedasset,
     gl_data~fixedasset,
     gl_data~fiscalperiod,
     gl_data~fiscalyear,
     gl_data~ledgerfiscalyear,
     gl_data~fiscalyearperiod,
     gl_data~transactioncurrency
  INTO TABLE @DATA(lt_khlkdk).
      SORT lt_khlkdk BY masterfixedasset fixedasset.
      "tai khoan nguyen gia - asset transaction type 100
      "case này xảy ra khi dep start date thuộc năm hiện tại
      SELECT *
      FROM zfa_i_zaa01_glacc( p_asset_trans_type = '100' )
      WHERE right( glaccount, 4 ) NOT LIKE '99%'
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_glacc_100).
      "tai khoan nguyen gia - asset transaction type 970
      "case này xảy ra khi dep start date khác năm hiện tại
      SELECT *
      FROM zfa_i_zaa01_glacc( p_asset_trans_type = '970' )
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_glacc_970).
      "    "tai khoan khấu hao - asset transaction type 500
      " glaccount 6*
*      SELECT *
*      FROM zfa_i_zaa01_glacc( p_asset_trans_type = '500' )
*      WHERE glaccount LIKE '6%'
*      INTO TABLE @DATA(lt_glacc_500_6).

      SELECT
      accountingdocument
      FROM i_journalentryitem AS journalitem
      WHERE masterfixedasset IN @lr_masterfixedasset
      AND assettransactiontype = '500'
      AND ledger = '0L'
      AND accountingdocument IS NOT INITIAL
      INTO TABLE @DATA(lt_accounting_document).

      SELECT
      masterfixedasset,
      fixedasset,
      glaccount
      FROM i_journalentryitem AS journalitem
      INNER JOIN @lt_accounting_document AS acc_doc ON journalitem~accountingdocument = acc_doc~accountingdocument
      AND glaccount LIKE '6%'
      WHERE masterfixedasset IN @lr_masterfixedasset
      ORDER BY masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_glacc_500_6).
      "tai khoan chi phi khau hao - asset transaction type 500
      " glaccount 214*
      SELECT *
      FROM zfa_i_zaa01_glacc( p_asset_trans_type = '500' )
      WHERE glaccount LIKE '214%'
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_glacc_500_214).

      SELECT
      glaccount,
      masterfixedasset,
      fixedasset
      FROM i_journalentryitem AS journalitem
      WHERE masterfixedasset IN @lr_masterfixedasset
      AND fixedasset IN @lr_fixedasset
      AND assettransactiontype = '500'
      AND ledger = '0L'
*      and FinancialAccountType = 'A'
      AND glaccount LIKE '6%'
      ORDER BY masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_journal).

      SELECT *
      FROM zfa_i_zaa01_650
      WHERE companycode IN @lr_companycode
      AND masterfixedasset IN @lr_masterfixedasset
      AND fixedasset IN @lr_fixedasset
      AND fiscalperiod IN @lr_ky_bao_cao
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_gia_tri_bat_thuong).

      SELECT
      companycode,
      masterfixedasset,
      fixedasset,
      baseunit,
      SUM( quantity ) AS quantity
      FROM i_glaccountlineitemrawdata
      WHERE companycode IN @lr_companycode
      AND masterfixedasset IN @lr_masterfixedasset
      AND fixedasset IN @lr_fixedasset
      AND sourceledger = '0L'
      AND baseunit IS NOT INITIAL
      GROUP BY
      companycode,
      masterfixedasset,
      fixedasset,
      baseunit
      ORDER BY companycode, masterfixedasset, fixedasset
      INTO TABLE @DATA(lt_quantity).


      DATA: lv_count TYPE int4 VALUE '1'.
      LOOP AT et_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
*        lv_xml = lv_xml && |<Data>|.

        <lfs_data>-uuid = lv_uuid_fi.
        <lfs_data>-so_ky_khau_hao = <lfs_data>-plannedusefullifeinperiods + <lfs_data>-plannedusefullifeinyears * 12.

        IF <lfs_data>-assetcapitalizationdate IS NOT INITIAL.
          DATA(lv_start_year) = CONV string( <lfs_data>-assetcapitalizationdate+0(4) ).
          DATA(lv_start_month) = <lfs_data>-assetcapitalizationdate+4(2).
          DATA(lv_distance_year) = lv_nam_bao_cao - lv_start_year.
          IF lv_distance_year = 0.
            <lfs_data>-so_ky_da_khua_hao = abs( lv_tu_ky - lv_start_month ).
          ELSE.
            <lfs_data>-so_ky_da_khua_hao = abs( ( lv_tu_ky + ( lv_distance_year * 12 ) )  - lv_start_month ) .
          ENDIF.
          IF <lfs_data>-assetdeactivationdate IS INITIAL.
            DATA(lv_old_period) = <lfs_data>-assetcapitalizationdate+4(2).
            DATA(lv_old_year) = <lfs_data>-assetcapitalizationdate+0(4).
            DATA(lv_old_date) = <lfs_data>-assetcapitalizationdate+6(2).
            DATA(lv_new_month) = lv_old_period + <lfs_data>-plannedusefullifeinperiods.
            IF lv_new_month > 12.
              lv_new_month = lv_new_month - 12.
              lv_old_year += 1.

            ENDIF.
            IF lv_new_month < 10.
              DATA(lv_new_month_char) = |0{ lv_new_month }|.
            ENDIF.
            DATA(lv_new_year) = lv_old_year + <lfs_data>-plannedusefullifeinyears.
            <lfs_data>-assetdeactivationdate = |{ lv_new_year }{ lv_new_month_char }{ lv_old_date }|.
          ENDIF.
        ENDIF.
        IF <lfs_data>-so_ky_da_khua_hao IS NOT INITIAL.
          <lfs_data>-so_ky_khao_hao_con_lai = <lfs_data>-so_ky_khau_hao - <lfs_data>-so_ky_da_khua_hao.
        ENDIF.


        "quantity
        IF <lfs_data>-quantity IS INITIAL.
          READ TABLE lt_quantity INTO DATA(lw_quantity) WITH KEY companycode = <lfs_data>-companycode
                                                                                   masterfixedasset = <lfs_data>-masterfixedasset
                                                                                   fixedasset = <lfs_data>-fixedasset BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-quantity = lw_quantity-quantity.
            <lfs_data>-baseunit = lw_quantity-baseunit.
          ENDIF.
        ENDIF.

        "Nguyên giá đầu kỳ
        READ TABLE lt_ngdk INTO DATA(ls_ngdk) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                 fixedasset = <lfs_data>-fixedasset BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_ngdk INTO ls_ngdk FROM lv_tabix WHERE report_year_period < lv_date_tu_ky.
            "qua mã khác thi cook luôn
            IF ls_ngdk-masterfixedasset <> <lfs_data>-masterfixedasset OR
            ls_ngdk-fixedasset <> <lfs_data>-fixedasset.
*            CONTINUE.
              EXIT.
            ELSE.
              <lfs_data>-nguyen_gia_dau_ky += ls_ngdk-amount_in_transaction_currency.
            ENDIF.
          ENDLOOP.
        ENDIF.

        READ TABLE lt_nguyen_gia_dau_ki_1 INTO DATA(lw_nguyengia_dk) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                 fixedasset = <lfs_data>-fixedasset BINARY SEARCH.
        IF sy-subrc = 0.
          <lfs_data>-nguyen_gia_dau_ky += lw_nguyengia_dk-amountintransactioncurrency.
        ENDIF.
        "Khấu hao lũy kế đầu kỳ
        READ TABLE lt_khlkdk INTO DATA(ls_khlkdk) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                  fixedasset = <lfs_data>-fixedasset BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_khlkdk INTO ls_khlkdk FROM lv_tabix WHERE report_year_period < lv_date_tu_ky.
            "qua mã khác thi cook luôn
            IF ls_khlkdk-masterfixedasset <> <lfs_data>-masterfixedasset OR
            ls_khlkdk-fixedasset <> <lfs_data>-fixedasset.
*            CONTINUE.
              EXIT.
            ELSE.
              <lfs_data>-khau_hao_luy_ke_dau_ky += ls_khlkdk-amount_in_transaction_currency.
            ENDIF.
          ENDLOOP.
        ENDIF.
        "Giá trị còn lại đầu kỳ
        <lfs_data>-khau_hao_luy_ke_dau_ky = abs( <lfs_data>-khau_hao_luy_ke_dau_ky ).
        <lfs_data>-gia_tri_con_lai_dau_ky = <lfs_data>-nguyen_gia_dau_ky - abs( <lfs_data>-khau_hao_luy_ke_dau_ky ).

        "Tang nguyên giá trong kì
        READ TABLE lt_tang_nguyen_gia_trong_ki INTO DATA(lw_tang_nguyen_gia_trong_ki) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                                            fixedasset = <lfs_data>-fixedasset
                                                                                            companycode = <lfs_data>-companycode
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_tang_nguyen_gia_trong_ki INTO lw_tang_nguyen_gia_trong_ki FROM lv_tabix.
            IF lw_tang_nguyen_gia_trong_ki-masterfixedasset <> <lfs_data>-masterfixedasset.
              EXIT.
            ELSE.
              <lfs_data>-tang_nguyen_gia_trong_ki += lw_tang_nguyen_gia_trong_ki-amount_in_transaction_currency.
            ENDIF.
          ENDLOOP.
        ENDIF.

        "tang khấu hao trong kì
        READ TABLE lt_tang_khau_hao_trong_ki INTO DATA(lw_tang_khau_hao_trong_ki) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                                            fixedasset = <lfs_data>-fixedasset
                                                                                            companycode = <lfs_data>-companycode
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_tang_khau_hao_trong_ki INTO lw_tang_khau_hao_trong_ki FROM lv_tabix  WHERE tang_khau_hao_trong_ki < 0.
            IF lw_tang_khau_hao_trong_ki-masterfixedasset <> <lfs_data>-masterfixedasset.
              EXIT.
            ELSE.
              <lfs_data>-tang_khau_hao_trong_ki += abs( lw_tang_khau_hao_trong_ki-tang_khau_hao_trong_ki ).
            ENDIF.
          ENDLOOP.
        ENDIF.

        "Giảm nguyên giá trong kì
        READ TABLE lt_giam_nguyen_gia_trong_ki INTO DATA(lw_giam_nguyen_gia_trong_ki) WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                                            fixedasset = <lfs_data>-fixedasset
                                                                                            companycode = <lfs_data>-companycode
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_giam_nguyen_gia_trong_ki INTO lw_giam_nguyen_gia_trong_ki FROM lv_tabix.
            IF lw_giam_nguyen_gia_trong_ki-masterfixedasset <> <lfs_data>-masterfixedasset.
              EXIT.
            ELSE.
              <lfs_data>-giam_nguyen_gia_trong_ky += lw_giam_nguyen_gia_trong_ki-amount_in_transaction_currency.
            ENDIF.
          ENDLOOP.
        ENDIF.

        "giam khau hao trong kì
        READ TABLE lt_tang_khau_hao_trong_ki INTO lw_tang_khau_hao_trong_ki WITH KEY masterfixedasset = <lfs_data>-masterfixedasset
                                                                                            fixedasset = <lfs_data>-fixedasset
                                                                                            companycode = <lfs_data>-companycode
                                                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_tang_khau_hao_trong_ki INTO lw_tang_khau_hao_trong_ki FROM lv_tabix WHERE tang_khau_hao_trong_ki > 0 .
            IF lw_tang_khau_hao_trong_ki-masterfixedasset <> <lfs_data>-masterfixedasset.
              EXIT.
            ELSE.
              <lfs_data>-giam_khau_hao_trong_ky += lw_tang_khau_hao_trong_ki-tang_khau_hao_trong_ki.
            ENDIF.
          ENDLOOP.
        ENDIF.

        READ TABLE lt_gia_tri_bat_thuong INTO DATA(ls_gia_tri_bat_thuong) WITH KEY companycode = <lfs_data>-companycode
                                                                   masterfixedasset = <lfs_data>-masterfixedasset
                                                                   fixedasset = <lfs_data>-fixedasset
                                                                   BINARY SEARCH.
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          LOOP AT lt_gia_tri_bat_thuong INTO ls_gia_tri_bat_thuong FROM lv_tabix.
            IF ls_gia_tri_bat_thuong-masterfixedasset <> <lfs_data>-masterfixedasset OR
               ls_gia_tri_bat_thuong-fixedasset <> <lfs_data>-fixedasset.
              EXIT.
            ELSE.
              IF ls_gia_tri_bat_thuong-amountinbalancetransaccrcy > 0.
                <lfs_data>-giam_khau_hao_trong_ky += ls_gia_tri_bat_thuong-amountinbalancetransaccrcy.
              ELSE.
                <lfs_data>-tang_khau_hao_trong_ki += ls_gia_tri_bat_thuong-amountinbalancetransaccrcy.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.

        DATA(lv_curr_date) = cl_abap_context_info=>get_system_date( ).
        IF <lfs_data>-depreciationstartdate+0(4) = lv_curr_date+0(4) .
          READ TABLE lt_glacc_100 INTO DATA(ls_glacc_100) WITH KEY companycode = <lfs_data>-companycode
                                                                       masterfixedasset = <lfs_data>-masterfixedasset
                                                                       fixedasset = <lfs_data>-fixedasset
                                                                       BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-tk_nguyen_gia = ls_glacc_100-glaccount.
          ENDIF.
        ELSE.
          READ TABLE lt_glacc_970 INTO DATA(ls_glacc_970) WITH KEY companycode = <lfs_data>-companycode
                                                                         masterfixedasset = <lfs_data>-masterfixedasset
                                                                         fixedasset = <lfs_data>-fixedasset
                                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-tk_nguyen_gia = ls_glacc_970-glaccount.
          ENDIF.
        ENDIF.

        READ TABLE lt_glacc_500_214 INTO DATA(ls_glacc_500_214) WITH KEY companycode = <lfs_data>-companycode
                                                                   masterfixedasset = <lfs_data>-masterfixedasset
                                                                   fixedasset = <lfs_data>-fixedasset
                                                                   BINARY SEARCH.
        IF sy-subrc = 0.
*            <lfs_data>-tk_chi_phi = ls_glacc_500_214-glaccount.
          <lfs_data>-tk_khau_hao = ls_glacc_500_214-glaccount.
        ENDIF.

        READ TABLE lt_glacc_500_6 INTO DATA(ls_journal) WITH KEY
                                                                   masterfixedasset = <lfs_data>-masterfixedasset
                                                                   fixedasset = <lfs_data>-fixedasset
                                                                   BINARY SEARCH.
        IF sy-subrc = 0.
*            <lfs_data>-tk_khau_hao = ls_journal-glaccount.
          <lfs_data>-tk_chi_phi = ls_journal-glaccount.
        ENDIF.
        " So Cuối Kỳ
        <lfs_data>-nguyen_gia_cuoi_ky = <lfs_data>-nguyen_gia_dau_ky + <lfs_data>-tang_nguyen_gia_trong_ki - <lfs_data>-giam_nguyen_gia_trong_ky.
        <lfs_data>-khau_hao_luy_ke_cuoi_ky = <lfs_data>-khau_hao_luy_ke_dau_ky + <lfs_data>-tang_khau_hao_trong_ki - <lfs_data>-giam_khau_hao_trong_ky.
        <lfs_data>-gia_tri_con_lai_cuoi_ky = <lfs_data>-nguyen_gia_cuoi_ky - <lfs_data>-khau_hao_luy_ke_cuoi_ky.
        IF <lfs_data>-nguyen_gia_cuoi_ky <= 0.
          <lfs_data>-trang_thai = 'Ngừng KH'.
        ELSEIF <lfs_data>-nguyen_gia_cuoi_ky > 0 AND <lfs_data>-gia_tri_con_lai_cuoi_ky <= 0.
          <lfs_data>-trang_thai = 'Hoàn thành KH'.
        ELSE.
          <lfs_data>-trang_thai = 'Đang KH'.
        ENDIF.


        IF <lfs_data>-plant IS INITIAL.
          READ TABLE lt_assgmt INTO DATA(lw_assgmt) WITH KEY companycode = <lfs_data>-companycode
                                                             masterfixedasset = <lfs_data>-masterfixedasset
                                                             fixedasset = <lfs_data>-fixedasset BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_data>-plant = |{ lw_assgmt-plant }-{ lw_assgmt-plantname }|.
          ENDIF.
        ENDIF.

*        "tạo xml
*        lv_xml = lv_xml && |<STT>{ lv_count }</STT>|.
*        lv_xml = lv_xml && |<AssetClass>{ <lfs_data>-assetclass_desc }</AssetClass>|.
*        DATA(lv_fixedasset) = <lfs_data>-fixedasset.
*        SHIFT lv_fixedasset LEFT DELETING LEADING '0'.
*        IF lv_fixedasset IS INITIAL.
*          lv_fixedasset = '0'.
*        ENDIF.
*        DATA(lv_asset) = |{ <lfs_data>-masterfixedasset }-{ lv_fixedasset }|.
*        SHIFT lv_asset LEFT DELETING LEADING '0'.
*        lv_xml = lv_xml && |<MasterFixedAsset>{ lv_asset }</MasterFixedAsset>|.
*        DATA(lv_masterfixedassetdescription) = <lfs_data>-masterfixedassetdescription.
*        REPLACE ALL OCCURRENCES OF '&' IN lv_masterfixedassetdescription WITH '&amp;'.
*        REPLACE ALL OCCURRENCES OF '<' IN lv_masterfixedassetdescription WITH '&lt;'.
*        REPLACE ALL OCCURRENCES OF '>' IN lv_masterfixedassetdescription WITH '&gt;'.
*        lv_xml = lv_xml && |<MasterFixedAssetDescription>{ lv_masterfixedassetdescription }</MasterFixedAssetDescription>|.
*        lv_xml = lv_xml && |<Plant>{ <lfs_data>-plant }</Plant>|.
*        lv_xml = lv_xml && |<ProfitCenter>{ <lfs_data>-profitcenter }</ProfitCenter>|.
*        lv_xml = lv_xml && |<AssetLocation>{ <lfs_data>-assetlocation_desc }</AssetLocation>|.
*        me->convert_date(
*  EXPORTING
*    i_date      = <lfs_data>-assetcapitalizationdate
*  IMPORTING
*    e_text_date = DATA(lv_assetcapitalizationdate)
*).
*        lv_xml = lv_xml && |<AssetCapitalizationDate>{ lv_assetcapitalizationdate }</AssetCapitalizationDate>|.
*
*        me->convert_date(
*  EXPORTING
*    i_date      = <lfs_data>-assetdeactivationdate
*  IMPORTING
*    e_text_date = DATA(lv_assetdeactivationdate)
*).
*        lv_xml = lv_xml && |<AssetDeactivationDate>{ lv_assetdeactivationdate }</AssetDeactivationDate>|.
*
*        lv_xml = lv_xml && |<TrangThai>{ <lfs_data>-trang_thai }</TrangThai>|.
*        lv_xml = lv_xml && |<TkNguyenGia>{ <lfs_data>-tk_nguyen_gia }</TkNguyenGia>|.
*        lv_xml = lv_xml && |<TkKhauHao>{ <lfs_data>-tk_khau_hao }</TkKhauHao>|.
*        lv_xml = lv_xml && |<TkChiPhi>{ <lfs_data>-tk_chi_phi }</TkChiPhi>|.
*        lv_xml = lv_xml && |<CostCenter>{ <lfs_data>-costcenter_desc }</CostCenter>|.
*        lv_xml = lv_xml && |<MaCu>{ <lfs_data>-inventory }</MaCu>|.
*        me->convert_date(
*          EXPORTING
*            i_date      = <lfs_data>-depreciationstartdate
*          IMPORTING
*            e_text_date = DATA(lv_depreciationstartdate)
*        ).
*        lv_xml = lv_xml && |<NgaybatDauKhauHao>{ lv_depreciationstartdate }</NgaybatDauKhauHao>|.
*        lv_xml = lv_xml && |<SoLuong>{ <lfs_data>-quantity }</SoLuong>|.
*        lv_xml = lv_xml && |<DonViTinh>{ <lfs_data>-baseunit }</DonViTinh>|.
*        lv_xml = lv_xml && |<SoKyKhaoHao>{ <lfs_data>-so_ky_khau_hao }</SoKyKhaoHao>|.
*        lv_xml = lv_xml && |<SoKyDaKhaoHao>{ <lfs_data>-so_ky_da_khua_hao }</SoKyDaKhaoHao>|.
*        lv_xml = lv_xml && |<SoKyKhaoHaoConLai>{ <lfs_data>-so_ky_khao_hao_con_lai }</SoKyKhaoHaoConLai>|.
*        lv_xml = lv_xml && |<NguyenGiaDauKy>{ <lfs_data>-nguyen_gia_dau_ky }</NguyenGiaDauKy>|.
*        lv_xml = lv_xml && |<KhauHaoLuyKeDauKy>{ <lfs_data>-khau_hao_luy_ke_dau_ky }</KhauHaoLuyKeDauKy>|.
*        lv_xml = lv_xml && |<GiaTriConLaiDauKy>{ <lfs_data>-gia_tri_con_lai_dau_ky }</GiaTriConLaiDauKy>|.
*        lv_xml = lv_xml && |<TangNguyenGiaTrongKy>{ <lfs_data>-tang_nguyen_gia_trong_ki }</TangNguyenGiaTrongKy>|.
*        lv_xml = lv_xml && |<TangKhauHaoTrongKy>{ <lfs_data>-tang_khau_hao_trong_ki }</TangKhauHaoTrongKy>|.
*        lv_xml = lv_xml && |<GiamNguyenGiaTrongKy>{ <lfs_data>-giam_nguyen_gia_trong_ky }</GiamNguyenGiaTrongKy>|.
*        lv_xml = lv_xml && |<GiamKhauHaoTrongKy>{ <lfs_data>-giam_khau_hao_trong_ky }</GiamKhauHaoTrongKy>|.
*        lv_xml = lv_xml && |<NguyenGiaCuoiKy>{ <lfs_data>-nguyen_gia_cuoi_ky }</NguyenGiaCuoiKy>|.
*        lv_xml = lv_xml && |<KhauHaoLuyKeCuoiKy>{ <lfs_data>-khau_hao_luy_ke_cuoi_ky }</KhauHaoLuyKeCuoiKy>|.
*        lv_xml = lv_xml && |<GiaTriConLaiCuoiKy>{ <lfs_data>-gia_tri_con_lai_cuoi_ky }</GiaTriConLaiCuoiKy>|.
*        lv_xml = lv_xml && |</Data>|.
        lv_count += 1 .
      ENDLOOP.
*      lv_xml = lv_xml && |</Datas>|.
*      lv_xml = lv_xml && |<total_so_ky_khau_hao>{ lv_total_so_ky_khau_hao }</total_so_ky_khau_hao>|.
*      lv_xml = lv_xml && |<total_so_ky_da_khau_hao>{ lv_total_so_ky_da_khau_hao }</total_so_ky_da_khau_hao>|.
*      lv_xml = lv_xml && |<total_so_ky_con_lai>{ lv_total_so_ky_con_lai }</total_so_ky_con_lai>|.
*      lv_xml = lv_xml && |<total_nguyen_gia_dau_ky>{ lv_total_nguyen_gia_dau_ky }</total_nguyen_gia_dau_ky>|.
*      lv_xml = lv_xml && |<total_khauhao_luyke_dky>{ lv_total_khauhao_luyke_dky }</total_khauhao_luyke_dky>|.
*      lv_xml = lv_xml && |<total_giatri_conlai_dky>{ lv_total_giatri_conlai_dky }</total_giatri_conlai_dky>|.
*      lv_xml = lv_xml && |<total_tangnguyengia_tk>{ lv_total_tangnguyengia_tk }</total_tangnguyengia_tk>|.
*      lv_xml = lv_xml && |<total_tangkhauhao_tk>{ lv_total_tangkhauhao_tk }</total_tangkhauhao_tk>|.
*      lv_xml = lv_xml && |<total_giamnguyengia_tk>{ lv_total_giamnguyengia_tk }</total_giamnguyengia_tk>|.
*      lv_xml = lv_xml && |<total_giamkhauhao_tk>{ lv_total_giamkhauhao_tk }</total_giamkhauhao_tk>|.
*      lv_xml = lv_xml && |<total_nguyengia_ck>{ lv_total_nguyengia_ck }</total_nguyengia_ck>|.
*      lv_xml = lv_xml && |<total_khau_hao_luy_ke_ck>{ lv_total_khau_hao_luy_ke_ck }</total_khau_hao_luy_ke_ck>|.
*      lv_xml = lv_xml && |<total_gia_tri_con_lai_ck>{ lv_total_gia_tri_con_lai_ck }</total_gia_tri_con_lai_ck>|.
*      lv_xml = lv_xml && |<NguoiLap>{ lv_nguoi_lap }</NguoiLap>|.
*      lv_xml = lv_xml && |<KeToan>{ lv_ke_toan }</KeToan>|.
*      lv_xml = lv_xml && |<GiamDoc>{ lv_giam_doc }</GiamDoc>|.
*      lv_xml = lv_xml && |</Header>|.
    ENDIF.
    e_uuid = lv_uuid_fi.
    e_nguoilap = lv_nguoi_lap.
    e_giamdoc = lv_giam_doc.
    e_ketoan = lv_ke_toan.
  ENDMETHOD.


  METHOD create_excel.
    DATA: lt_excel    TYPE tt_excel,
          lv_report   TYPE char72 VALUE 'ZAA01',
          lv_template TYPE char72 VALUE 'ZAA01_EXC'.

    CHECK it_data IS NOT INITIAL.

    DATA(lw_data) = it_data[ 1 ].
    APPEND VALUE #(
                     h_company_name      = lw_data-tencongty
                     h_company_add       = lw_data-diachicongty
                     h_company_mst       = lw_data-mstcongty
                     h_title_report      = 'BÁO CÁO TÌNH HÌNH TĂNG GIẢM TÀI SẢN'
                     h_title_subtitle    = i_tu_ky_den_ky
                     "item title
                     i_title_stt         = 'STT'
                     i_title_nhomtaisan  = 'Nhóm tài sản'
                     i_title_mataisan     = 'Mã tài sản'
                     i_title_tentaisan    = 'Tên tài sản'
                     i_title_plant        = 'Plant'
                     i_title_profitcenter = 'Profit center'
                     i_title_vitri        = 'Vị trí'
                     i_title_ngayphatsinh = 'Ngày phát sinh'
                     i_title_ngayketthuc  = 'Ngày kết thúc'
                     i_title_trangthai    = 'Trạng thái'
                     i_title_tknguyengia  = 'TK nguyên giá'
                     i_title_tkkhauhao    = 'TK khấu hao'
                     i_title_tkchiphi     = 'TK chi phí'
                     i_title_costcenter   = 'Cost center'
                     i_title_macu         = 'Mã cũ'
                     i_title_ngaybatdau   = 'Ngày bắt đầu'
                     i_title_soluong      = 'Số lượng'
                     i_title_donvitinh    = 'Đơn vị tính'
                     i_title_sokykhauhao  = 'Số kỳ khấu hao'
                     i_title_sokydakhauhao = 'Số kỳ đã khấu hao'
                     i_title_sokyconlai   = 'Số kỳ còn lại'
                     i_title_dk_nguyengia = 'Nguyên giá'
                     i_title_dk_khauhao   = 'Lũy kế khấu hao'
                     i_title_dk_conlai    = 'Còn lại'
                     i_title_pst_nguyengia = 'Nguyên giá'
                     i_title_pst_khauhao   = 'Khấu hao'
                     i_title_psg_nguyengia = 'Nguyên giá'
                     i_title_psg_khauhao  = 'Khấu hao'
                     i_title_ck_nguyengia = 'Nguyên giá'
                     i_title_ck_khauhao   = 'Lũy kế khấu hao'
                     i_title_ck_conlai    = 'Còn lại'
                     i_title_dk           = 'Đầu kỳ'
                     i_title_pst          = 'Phát sinh tăng'
                     i_title_psg          = 'Phát sinh giảm'
                     i_title_ck           = 'Cuối ký'
                     item                 = it_data
                     "footer              =
*                        f_title_total        =
*                        f_sokykhauhao        =
*                        f_sokydakhauhao      =
*                        f_dk_nguyengia       =
*                        f_dk_khauhao         =
*                        f_dk_conlai          =
*                        f_pst_nguyengia      =
*                        f_pst_khauhao        =
*                        f_psg_nguyengia      =
*                        f_psg_khauhao        =
*                        f_ck_nguyengia       =
*                        f_ck_khauhao         =
*                        f_ck_conlai          =
*                        f_title_nguoilap     =
*                        f_title_ketoantruong =
*                        f_title_giamdoc      =
*                        f_subtitle           =
*                        f_nguoilap           =
*                        f_ketoantruong       =
*                        f_giamdoc            =
 ) TO lt_excel.




    DATA: lo_excel       TYPE REF TO zcl_export_excel_xlsx.
    lo_excel = NEW #( ).
    lo_excel->export_excel(
      EXPORTING
        iv_template = lv_template
        iv_report   = lv_report
        it_data     = lt_excel
        iv_generate = ''
      IMPORTING
        lv_context  = e_attachment
    ).

    SELECT SINGLE
    report_id
    FROM ztb_file_export WHERE report_id = @lv_template
    INTO @DATA(lv_exist).
    " Return file content

    IF lv_exist IS INITIAL.
      MODIFY ENTITIES OF zr_tbfile_export
         ENTITY zrtbfileexport
        CREATE AUTO FILL CID FIELDS ( reportid template  attachment filename mimetype ) WITH VALUE #(
            (
           reportid      = lv_template
           template = lv_template
            filename   = 'ZAA01.xlsx'
            mimetype   = 'application/vnd.ms-excel'
            attachment = e_attachment
            ) )
         MAPPED DATA(ls_mapped_cr)
         REPORTED DATA(ls_reported_cr)
         FAILED DATA(ls_failed_cr).
    ELSE.
      MODIFY ENTITIES OF zr_tbfile_export
     ENTITY zrtbfileexport
    UPDATE  FIELDS (    attachment filename mimetype ) WITH VALUE #(
        (
       reportid      = lv_template
       template = lv_template
        filename   = 'ZAA01.xlsx'
        mimetype   = 'application/vnd.ms-excel'
        attachment = e_attachment
        ) )
     MAPPED DATA(ls_mapped_update)
     REPORTED DATA(ls_reported_update)
     FAILED DATA(ls_failed_update).
    ENDIF.
    COMMIT ENTITIES.
  ENDMETHOD.


  METHOD create_pdf.
    DATA: lv_total_so_ky_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
    DATA: lv_total_so_ky_da_khau_hao TYPE zfa_r_zaa01_n-so_ky_da_khua_hao.
    DATA: lv_total_so_ky_con_lai TYPE zfa_r_zaa01_n-so_ky_khao_hao_con_lai.
    DATA: lv_total_nguyen_gia_dau_ky TYPE zfa_r_zaa01_n-nguyen_gia_dau_ky.
    DATA: lv_total_khauhao_luyke_dky TYPE zfa_r_zaa01_n-khau_hao_luy_ke_dau_ky.
    DATA: lv_total_giatri_conlai_dky TYPE zfa_r_zaa01_n-gia_tri_con_lai_dau_ky.
    DATA: lv_total_tangnguyengia_tk TYPE zfa_r_zaa01_n-tang_nguyen_gia_trong_ki.
    DATA: lv_total_tangkhauhao_tk TYPE zfa_r_zaa01_n-tang_khau_hao_trong_ki.
    DATA: lv_total_giamnguyengia_tk TYPE zfa_r_zaa01_n-giam_nguyen_gia_trong_ky.
    DATA: lv_total_giamkhauhao_tk TYPE zfa_r_zaa01_n-giam_khau_hao_trong_ky.
    DATA: lv_total_nguyengia_ck TYPE zfa_r_zaa01_n-nguyen_gia_cuoi_ky.
    DATA: lv_total_khau_hao_luy_ke_ck TYPE zfa_r_zaa01_n-khau_hao_luy_ke_cuoi_ky.
    DATA: lv_total_gia_tri_con_lai_ck TYPE zfa_r_zaa01_n-gia_tri_con_lai_cuoi_ky.
    DATA: lv_xml TYPE string.
    DATA: lv_count TYPE int4 VALUE '1'.
    lv_xml = |<Header>|.
    lv_xml = lv_xml && |<TuKyDenKy>{ i_tu_ky_den_ky }</TuKyDenKy>|.
    lv_xml = lv_xml && |<TenCongTy>{ it_data[ 1 ]-tencongty }</TenCongTy>|.
    lv_xml = lv_xml && |<DiaChi>{ it_data[ 1 ]-diachicongty }</DiaChi>|.
    lv_xml = lv_xml && |<MaSoThue>{ it_data[ 1 ]-mstcongty }</MaSoThue>|.
    lv_xml = lv_xml && |<Datas>|.
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

*        "total
      lv_total_so_ky_khau_hao += <lfs_data>-so_ky_khau_hao.
      lv_total_so_ky_da_khau_hao += <lfs_data>-so_ky_da_khua_hao.
      lv_total_so_ky_con_lai += <lfs_data>-so_ky_khao_hao_con_lai.
      lv_total_nguyen_gia_dau_ky += <lfs_data>-nguyen_gia_dau_ky.
      lv_total_khauhao_luyke_dky += <lfs_data>-khau_hao_luy_ke_dau_ky.
      lv_total_giatri_conlai_dky += <lfs_data>-gia_tri_con_lai_dau_ky.
      lv_total_tangnguyengia_tk += <lfs_data>-tang_nguyen_gia_trong_ki.
      lv_total_tangkhauhao_tk += <lfs_data>-tang_khau_hao_trong_ki.
      lv_total_giamnguyengia_tk += <lfs_data>-giam_nguyen_gia_trong_ky.
      lv_total_giamkhauhao_tk += <lfs_data>-giam_khau_hao_trong_ky.
      lv_total_nguyengia_ck += <lfs_data>-nguyen_gia_cuoi_ky.
      lv_total_khau_hao_luy_ke_ck += <lfs_data>-khau_hao_luy_ke_cuoi_ky.
      lv_total_gia_tri_con_lai_ck += <lfs_data>-gia_tri_con_lai_cuoi_ky.

      "tạo xml
      lv_xml = lv_xml && |<STT>{ lv_count }</STT>|.
      lv_xml = lv_xml && |<AssetClass>{ <lfs_data>-assetclass_desc }</AssetClass>|.
      DATA(lv_fixedasset) = <lfs_data>-fixedasset.
      SHIFT lv_fixedasset LEFT DELETING LEADING '0'.
      IF lv_fixedasset IS INITIAL.
        lv_fixedasset = '0'.
      ENDIF.
      DATA(lv_asset) = |{ <lfs_data>-masterfixedasset }-{ lv_fixedasset }|.
      SHIFT lv_asset LEFT DELETING LEADING '0'.
      lv_xml = lv_xml && |<MasterFixedAsset>{ lv_asset }</MasterFixedAsset>|.
      DATA(lv_masterfixedassetdescription) = <lfs_data>-masterfixedassetdescription.
      REPLACE ALL OCCURRENCES OF '&' IN lv_masterfixedassetdescription WITH '&amp;'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_masterfixedassetdescription WITH '&lt;'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_masterfixedassetdescription WITH '&gt;'.
      lv_xml = lv_xml && |<MasterFixedAssetDescription>{ lv_masterfixedassetdescription }</MasterFixedAssetDescription>|.
      lv_xml = lv_xml && |<Plant>{ <lfs_data>-plant }</Plant>|.
      lv_xml = lv_xml && |<ProfitCenter>{ <lfs_data>-profitcenter }</ProfitCenter>|.
      lv_xml = lv_xml && |<AssetLocation>{ <lfs_data>-assetlocation_desc }</AssetLocation>|.
      me->convert_date(
                EXPORTING
                  i_date      = <lfs_data>-assetcapitalizationdate
                IMPORTING
                  e_text_date = DATA(lv_assetcapitalizationdate)
              ).
      lv_xml = lv_xml && |<AssetCapitalizationDate>{ lv_assetcapitalizationdate }</AssetCapitalizationDate>|.

      me->convert_date(
EXPORTING
  i_date      = <lfs_data>-assetdeactivationdate
IMPORTING
  e_text_date = DATA(lv_assetdeactivationdate)
).
      lv_xml = lv_xml && |<AssetDeactivationDate>{ lv_assetdeactivationdate }</AssetDeactivationDate>|.

      lv_xml = lv_xml && |<TrangThai>{ <lfs_data>-trang_thai }</TrangThai>|.
      lv_xml = lv_xml && |<TkNguyenGia>{ <lfs_data>-tk_nguyen_gia }</TkNguyenGia>|.
      lv_xml = lv_xml && |<TkKhauHao>{ <lfs_data>-tk_khau_hao }</TkKhauHao>|.
      lv_xml = lv_xml && |<TkChiPhi>{ <lfs_data>-tk_chi_phi }</TkChiPhi>|.
      lv_xml = lv_xml && |<CostCenter>{ <lfs_data>-costcenter_desc }</CostCenter>|.
      lv_xml = lv_xml && |<MaCu>{ <lfs_data>-inventory }</MaCu>|.
      me->convert_date(
        EXPORTING
          i_date      = <lfs_data>-depreciationstartdate
        IMPORTING
          e_text_date = DATA(lv_depreciationstartdate)
      ).
      lv_xml = lv_xml && |<NgaybatDauKhauHao>{ lv_depreciationstartdate }</NgaybatDauKhauHao>|.
      lv_xml = lv_xml && |<SoLuong>{ <lfs_data>-quantity }</SoLuong>|.
      lv_xml = lv_xml && |<DonViTinh>{ <lfs_data>-baseunit }</DonViTinh>|.
      lv_xml = lv_xml && |<SoKyKhaoHao>{ <lfs_data>-so_ky_khau_hao }</SoKyKhaoHao>|.
      lv_xml = lv_xml && |<SoKyDaKhaoHao>{ <lfs_data>-so_ky_da_khua_hao }</SoKyDaKhaoHao>|.
      lv_xml = lv_xml && |<SoKyKhaoHaoConLai>{ <lfs_data>-so_ky_khao_hao_con_lai }</SoKyKhaoHaoConLai>|.
      lv_xml = lv_xml && |<NguyenGiaDauKy>{ <lfs_data>-nguyen_gia_dau_ky }</NguyenGiaDauKy>|.
      lv_xml = lv_xml && |<KhauHaoLuyKeDauKy>{ <lfs_data>-khau_hao_luy_ke_dau_ky }</KhauHaoLuyKeDauKy>|.
      lv_xml = lv_xml && |<GiaTriConLaiDauKy>{ <lfs_data>-gia_tri_con_lai_dau_ky }</GiaTriConLaiDauKy>|.
      lv_xml = lv_xml && |<TangNguyenGiaTrongKy>{ <lfs_data>-tang_nguyen_gia_trong_ki }</TangNguyenGiaTrongKy>|.
      lv_xml = lv_xml && |<TangKhauHaoTrongKy>{ <lfs_data>-tang_khau_hao_trong_ki }</TangKhauHaoTrongKy>|.
      lv_xml = lv_xml && |<GiamNguyenGiaTrongKy>{ <lfs_data>-giam_nguyen_gia_trong_ky }</GiamNguyenGiaTrongKy>|.
      lv_xml = lv_xml && |<GiamKhauHaoTrongKy>{ <lfs_data>-giam_khau_hao_trong_ky }</GiamKhauHaoTrongKy>|.
      lv_xml = lv_xml && |<NguyenGiaCuoiKy>{ <lfs_data>-nguyen_gia_cuoi_ky }</NguyenGiaCuoiKy>|.
      lv_xml = lv_xml && |<KhauHaoLuyKeCuoiKy>{ <lfs_data>-khau_hao_luy_ke_cuoi_ky }</KhauHaoLuyKeCuoiKy>|.
      lv_xml = lv_xml && |<GiaTriConLaiCuoiKy>{ <lfs_data>-gia_tri_con_lai_cuoi_ky }</GiaTriConLaiCuoiKy>|.
      lv_xml = lv_xml && |</Data>|.


    ENDLOOP.
    lv_xml = lv_xml && |</Datas>|.
    lv_xml = lv_xml && |<total_so_ky_khau_hao>{ lv_total_so_ky_khau_hao }</total_so_ky_khau_hao>|.
    lv_xml = lv_xml && |<total_so_ky_da_khau_hao>{ lv_total_so_ky_da_khau_hao }</total_so_ky_da_khau_hao>|.
    lv_xml = lv_xml && |<total_so_ky_con_lai>{ lv_total_so_ky_con_lai }</total_so_ky_con_lai>|.
    lv_xml = lv_xml && |<total_nguyen_gia_dau_ky>{ lv_total_nguyen_gia_dau_ky }</total_nguyen_gia_dau_ky>|.
    lv_xml = lv_xml && |<total_khauhao_luyke_dky>{ lv_total_khauhao_luyke_dky }</total_khauhao_luyke_dky>|.
    lv_xml = lv_xml && |<total_giatri_conlai_dky>{ lv_total_giatri_conlai_dky }</total_giatri_conlai_dky>|.
    lv_xml = lv_xml && |<total_tangnguyengia_tk>{ lv_total_tangnguyengia_tk }</total_tangnguyengia_tk>|.
    lv_xml = lv_xml && |<total_tangkhauhao_tk>{ lv_total_tangkhauhao_tk }</total_tangkhauhao_tk>|.
    lv_xml = lv_xml && |<total_giamnguyengia_tk>{ lv_total_giamnguyengia_tk }</total_giamnguyengia_tk>|.
    lv_xml = lv_xml && |<total_giamkhauhao_tk>{ lv_total_giamkhauhao_tk }</total_giamkhauhao_tk>|.
    lv_xml = lv_xml && |<total_nguyengia_ck>{ lv_total_nguyengia_ck }</total_nguyengia_ck>|.
    lv_xml = lv_xml && |<total_khau_hao_luy_ke_ck>{ lv_total_khau_hao_luy_ke_ck }</total_khau_hao_luy_ke_ck>|.
    lv_xml = lv_xml && |<total_gia_tri_con_lai_ck>{ lv_total_gia_tri_con_lai_ck }</total_gia_tri_con_lai_ck>|.
    lv_xml = lv_xml && |<NguoiLap>{ i_nguoilap }</NguoiLap>|.
    lv_xml = lv_xml && |<KeToan>{ i_ketoan }</KeToan>|.
    lv_xml = lv_xml && |<GiamDoc>{ i_giamdoc }</GiamDoc>|.
    lv_xml = lv_xml && |</Header>|.
    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
  iv_service_instance_name   = 'ZADSTEMPLSTORE'
  iv_use_destination_service = abap_false
  ).

        DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZAA01' ).
        ##no_handler
      CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error_1).
        DATA(lv_err_1) = lx_error_1->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.

    TRY.
        cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xstring "lv_xml
                                              iv_xdp_layout   = ls_template-xdp_template
                                              iv_locale       = 'de_DE'
                                              is_options      = VALUE #(
                                             trace_level = 4 "Use 0 in production environment
        )
                                    IMPORTING ev_pdf          = DATA(lv_pdf)
                                              ev_pages        = DATA(ev_pages)
                                              ev_trace_string = DATA(ev_trace_string)
                                             ).
      CATCH cx_fp_ads_util INTO DATA(lx_error2).
        DATA(lv_err2) = lx_error2->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
