CLASS zcl_fa_zpm03_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    INTERFACES if_rap_query_request.
    TYPES: BEGIN OF gty_item,
             object              TYPE string,
             stt                 TYPE string,
             dgdv                TYPE string,
             assignmentreference TYPE string,
             pattern             TYPE string,
             invoice_num         TYPE string,
             documentdate        TYPE string,
             suppliername        TYPE string,
             mst_supplier        TYPE string,
             itemtext            TYPE string,
             baseunit            TYPE string,
             quantity            TYPE menge_d,
             price               TYPE zde_amount23,
             amount              TYPE zde_amount23,
             taxrate             TYPE menge_d,
             taxamount           TYPE zde_amount23,
             total_sumline       TYPE zde_amount23,
             yy1_gchd_jei        TYPE string,
             t_amount            TYPE string,
             t_taxamount         TYPE string,
             t_total_sumline     TYPE string,
             t_price             TYPE string,
             t_quantity          TYPE string,
             t_taxrate_text      TYPE string,
             t_date              TYPE string,
             accountingdocument  TYPE string,
             zlevel              TYPE string,

           END OF gty_item,
           tt_item TYPE STANDARD TABLE OF gty_item WITH EMPTY KEY.
*    TYPES : BEGIN OF gty_item,
*              i_tite    TYPE string,
*              i_subitem TYPE tt_sub_item,
*              zlevel     TYPE string,
*            END OF gty_item,
*            tt_item TYPE STANDARD TABLE OF gty_item WITH EMPTY KEY.
    TYPES: BEGIN OF gty_excel,
             h_title_report            TYPE string,
             h_note                    TYPE string,
             h_title_sub               TYPE string,
             h_nguoinopthue            TYPE string,
             h_masothue                TYPE string,
             h_donvitien               TYPE string,
             "item_title
             i_title_stt               TYPE string,
             i_title_haodonchungtu     TYPE string,
             i_title_kyhieumauso       TYPE string,
             i_title_kyhieuhoadon      TYPE string,
             i_title_sohoadonw         TYPE string,
             i_title_ngaythangphathanh TYPE string,
             i_title_tennguoiban       TYPE string,
             i_title_mstnguoiban       TYPE string,
             i_title_mathang           TYPE string,
             i_title_donvitinh         TYPE string,
             i_title_soluong           TYPE string,
             i_title_dongia            TYPE string,
             i_title_doanhthuchuathue  TYPE string,
             i_title_thuesuat          TYPE string,
             i_title_thuesuatgtgt      TYPE string,
             i_title_tongtien          TYPE string,
             i_title_ghichu            TYPE string,
             i_title_sochungtu         TYPE string,
             "item
             item                      TYPE tt_item,
             "footer
             f_note_1                  TYPE string,
             f_note_2                  TYPE string,
             f_title_ngaythangnam      TYPE string,
             f_note3                   TYPE string,
             f_note4                   TYPE string,
             f_note_5                  TYPE string,
           END OF gty_excel,
           tt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.

    METHODS create_excel
      IMPORTING i_data     TYPE tt_excel
      EXPORTING e_excel    TYPE zde_attachment_tmpl
                e_filename TYPE string
                e_mimetype TYPE string
      .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ZPM03_EX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    "khai báo ===========================================================
    DATA: lt_results_head TYPE STANDARD TABLE OF  zfa_i_zpm03_ex,
          lt_results      TYPE STANDARD TABLE OF  zfa_i_zpm03_ex,
          lt_result_page  TYPE STANDARD TABLE OF zfa_i_zpm03_ex.
    TRY.
        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
        " Filter
        DATA(ro_filter) = io_request->get_filter( ).
        " Conditions
        DATA(lv_conditions) = io_request->get_filter( )->get_as_sql_string( ).

        TRY.
            DATA(rt_ranges) = ro_filter->get_as_ranges( iv_drop_null_comparisons = abap_true ).
          CATCH cx_rap_query_filter_no_range.
            RETURN.
        ENDTRY.
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).


    DATA: lr_compcode    TYPE if_rap_query_filter=>tt_range_option,
          lr_postingdate TYPE if_rap_query_filter=>tt_range_option,
          lr_asment      TYPE if_rap_query_filter=>tt_range_option,
          lr_docdate     TYPE if_rap_query_filter=>tt_range_option,
          lr_fidoc       TYPE if_rap_query_filter=>tt_range_option,
          lr_reves       TYPE if_rap_query_filter=>tt_range_option,
          lr_uuid        TYPE if_rap_query_filter=>tt_range_option.



    IF rt_ranges IS NOT INITIAL.
      LOOP AT rt_ranges INTO DATA(lw_range).
        CASE lw_range-name.
          WHEN 'COMPANYCODE'.
            lr_compcode = lw_range-range.
          WHEN 'POSTINGDATE'.
            lr_postingdate = lw_range-range.
          WHEN 'ASSIGNMENTREFERENCE'.
            lr_asment = lw_range-range.
          WHEN 'DOCUMENTDATE'.
            lr_docdate  = lw_range-range.
          WHEN 'ACCOUNTINGDOCUMENT'.
            lr_fidoc  = lw_range-range.
          WHEN 'ISREVERSED'.
            lr_reves = lw_range-range.
          WHEN 'UUID'.
            lr_uuid = lw_range-range.
          WHEN OTHERS.
            " Do nothing for other fields
        ENDCASE.
      ENDLOOP.
    ENDIF.
    IF lr_uuid IS NOT INITIAL.
      SELECT
    attachment AS attachment_exc,
    mimetype AS mimetype_exc,
    filename AS filename_exc
   FROM zr_tbfile_export
   WHERE reportid = 'ZPM03_EXC'
   INTO CORRESPONDING FIELDS OF  TABLE @lt_results.
    ENDIF.
    IF lt_results IS INITIAL.
      DATA: lv_uuid_fi TYPE uuid.
      TRY.
          lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
        CATCH cx_uuid_error INTO DATA(lw_error).
          DATA(lv_err_txt) = lw_error->get_text( ).  " Hoặc ghi log, v.v.

      ENDTRY.
      "get data===============================================
      SELECT DISTINCT
      concat( tax_type, tax_group ) AS object,
        tax_group ,
        taxgroup_desc                                                     AS dgdv,
      'A' AS zsort,
      '3' AS row_type
      FROM ztb_fi_ztax WHERE tax_type = 'A' INTO CORRESPONDING FIELDS OF TABLE @lt_results_head .


      SELECT  zc_fa_zpm03_nw~*, 'B' AS zsort FROM zc_fa_zpm03_nw


      WHERE    companycode IN @lr_compcode
              AND postingdate IN  @lr_postingdate
              AND assignmentreference IN  @lr_asment
              AND documentdate IN  @lr_docdate
              AND accountingdocument IN  @lr_fidoc
              AND isreversed IN  @lr_reves

      INTO CORRESPONDING FIELDS OF TABLE @lt_results.

      SORT lt_results BY  tax_group postingdate accountingdocument taxcode.
      DATA: ls_group  TYPE  zfa_i_zpm03_ex,
            ls_result TYPE  zfa_i_zpm03_ex,
            ls_last   TYPE  zfa_i_zpm03_ex,
            lt_group  TYPE STANDARD TABLE OF  zfa_i_zpm03_ex.
      DATA: lv_stt TYPE i.

      LOOP AT lt_results INTO ls_result
           GROUP BY ( tax_group = ls_result-tax_group ) INTO DATA(group_key).
        LOOP AT GROUP group_key ASSIGNING FIELD-SYMBOL(<lfs_line>).
          <lfs_line>-totalline = <lfs_line>-taxamount + <lfs_line>-amount.
          lv_stt += 1.
          <lfs_line>-stt = lv_stt.

          ls_group-amount += <lfs_line>-amount.
          ls_group-taxamount += <lfs_line>-taxamount.
          ls_group-taxbaseamountintranscrcy += <lfs_line>-taxbaseamountintranscrcy.
          ls_group-taxamounttrans += <lfs_line>-taxamounttrans.
          ls_group-tax_group = <lfs_line>-tax_group.
          ls_group-object = |{ ls_group-tax_group  }TOTAL|.
          ls_group-companycodecurrency = <lfs_line>-companycodecurrency.
          ls_group-dgdv = <lfs_line>-dgdv.
          ls_last-amount += <lfs_line>-amount.
          ls_last-taxamount += <lfs_line>-taxamount.
          ls_last-taxbaseamountintranscrcy += <lfs_line>-taxbaseamountintranscrcy.
          ls_last-taxamounttrans += <lfs_line>-taxamounttrans.
          ls_last-companycodecurrency = <lfs_line>-companycodecurrency.
          IF <lfs_line>-transactioncurrency  <> 'VND'.
            ls_group-transactioncurrency = <lfs_line>-transactioncurrency.
            ls_last-transactioncurrency = <lfs_line>-transactioncurrency.
          ENDIF.
        ENDLOOP.
        ls_group-dgdv = |Tổng: { ls_group-dgdv }|.
        ls_group-totalline = ls_group-amount + ls_group-taxamount.
        ls_group-amount_nt = ls_group-taxbaseamountintranscrcy + ls_group-taxamounttrans.
        ls_group-zsort = 'C'.
        ls_group-row_type = '2'.
        APPEND ls_group TO lt_group.
        CLEAR: lv_stt, ls_group.

      ENDLOOP.
      ls_last-object = 'DSUMTOTAL'.
      ls_last-zsort = 'D'.
      ls_last-dgdv = 'Tổng cộng:'.
      ls_last-row_type = '1'.
      ls_last-totalline = ls_last-amount + ls_last-taxamount.
      ls_last-amount_nt = ls_last-taxbaseamountintranscrcy + ls_last-taxamounttrans.
      APPEND LINES OF lt_results_head TO lt_results.
      APPEND LINES OF lt_group TO lt_results.
      SORT lt_results BY tax_group zsort postingdate accountingdocument taxcode.
      APPEND ls_last TO lt_results.
      CLEAR: lt_group, ls_last.
      "export excel============================================================
      DATA: lt_item TYPE tt_item.
      DATA: lt_excel TYPE tt_excel.
      DATA: lv_excel    TYPE zde_attachment_tmpl,
            lv_filename TYPE string,
            lv_mimetype TYPE string.
      LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<lfs_result>).
        IF <lfs_result>-suppliername IS INITIAL AND <lfs_result>-mst_supplier IS NOT INITIAL.
          SELECT SINGLE
          CASE WHEN name234 IS NOT INITIAL THEN name234 ELSE name1 END AS name
          FROM zcds_bp
          WHERE mst = @<lfs_result>-mst_supplier
          INTO @<lfs_result>-suppliername.
        ENDIF.
      ENDLOOP.


      DATA(lt_temp) = lt_results.
      DATA : lv_total_doanhthuchuathue TYPE zcl_format_amount=>ty_curr.
      DATA : lv_total_thuegtgt TYPE zcl_format_amount=>ty_curr.
      DATA : lv_total_doanhthuchuathue_t TYPE string.
      DATA : lv_total_thuegtgt_t TYPE string.
      MOVE-CORRESPONDING lt_results TO lt_item.
      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).
*        <lfs_item>-amount = <lfs_item>-amount * 100.
*        <lfs_item>-taxamount =  <lfs_item>-taxamount * 100.
        IF <lfs_item>-object CP 'A*'.
          <lfs_item>-zlevel = 'A'.
        ELSEIF <lfs_item>-object CP '*TOTAL'.
          <lfs_item>-zlevel = 'C'.
        ELSE.
          <lfs_item>-zlevel = 'B'.
          lv_total_doanhthuchuathue += <lfs_item>-amount .
          lv_total_thuegtgt += <lfs_item>-taxamount .
        ENDIF.
        <lfs_item>-total_sumline = <lfs_item>-amount + <lfs_item>-taxamount.
        zcl_format_amount=>format_amount(
          EXPORTING
            i_amount   = <lfs_item>-amount
            i_currency = 'VND'
          RECEIVING
            r_amount   = <lfs_item>-t_amount
        ).

        zcl_format_amount=>format_amount(
  EXPORTING
    i_amount   = <lfs_item>-taxamount
    i_currency = 'VND'
  RECEIVING
    r_amount   = <lfs_item>-t_taxamount
).

        zcl_format_amount=>format_amount(
  EXPORTING
    i_amount   = <lfs_item>-total_sumline
    i_currency = 'VND'
  RECEIVING
    r_amount   = <lfs_item>-t_total_sumline
).

        zcl_format_amount=>format_amount(
  EXPORTING
    i_amount   = <lfs_item>-price
    i_currency = 'VND'
  RECEIVING
    r_amount   = <lfs_item>-t_price
).
        DATA: lo_format_quan TYPE REF TO zcl_format_quan.
        lo_format_quan = NEW zcl_format_quan( ).
        lo_format_quan->format_quantity(
          EXPORTING
            iv_quantity            = <lfs_item>-quantity
            iv_unit                = ''
            iv_is_negative_bracket = ''
          RECEIVING
            rv_formatted           = <lfs_item>-t_quantity
        ).
        lo_format_quan->format_quantity(
          EXPORTING
            iv_quantity            = <lfs_item>-taxrate
            iv_unit                = ''
            iv_is_negative_bracket = ''
          RECEIVING
            rv_formatted           = <lfs_item>-t_taxrate_text
        ).
        <lfs_item>-t_date = |{ <lfs_item>-documentdate+6(2) }/{ <lfs_item>-documentdate+4(2) }/{ <lfs_item>-documentdate+0(4) }|.

      ENDLOOP.
      DATA lv_title_sub TYPE string.
      IF lr_postingdate IS NOT INITIAL.
        DATA(lv_postingdate) = lr_postingdate[ 1 ]-low.
        lv_title_sub = |Kỳ tính thuế: tháng { lv_postingdate+4(2) } năm { lv_postingdate+0(4) }|.
      ELSE.
        lv_title_sub = |Kỳ tính thuế: tháng..... năm .... |.
      ENDIF.
      IF lr_compcode IS NOT INITIAL.
        SELECT SINGLE
           tencty_vn,
           diachi_vn23 AS diachi_vn,
           concat_with_space( 'Mã số thuế:' , mst , 1 ) AS mst
           FROM zcds_company
           WHERE companycode IN @lr_compcode
           INTO @DATA(ls_company).
      ENDIF.
      zcl_format_amount=>format_amount(
         EXPORTING
           i_amount   = lv_total_doanhthuchuathue
           i_currency = 'VND'
         RECEIVING
           r_amount   = lv_total_doanhthuchuathue_t
       ).

      zcl_format_amount=>format_amount(
         EXPORTING
           i_amount   = lv_total_thuegtgt
           i_currency = 'VND'
         RECEIVING
           r_amount   = lv_total_thuegtgt_t
       ).
      APPEND VALUE #(
          h_title_report  = 'BẢNG KÊ HÓA ĐƠN, CHỨNG TỪ HÀNG HOÁ, DỊCH VỤ MUA VÀO'
          h_note          = '(Kèm theo tờ khai thuế GTGT mẫu số 01/GTGT)'
          h_title_sub     = lv_title_sub
          h_nguoinopthue  = | Người nộp thuế: { ls_company-tencty_vn }|
          h_masothue      = ls_company-mst
          h_donvitien = 'Đơn vị tiền: VND'
          i_title_stt     = 'STT'
          i_title_haodonchungtu  = 'Hóa đơn, chứng từ, biên lai nộp thuế'
          i_title_kyhieumauso    = 'Ký hiệu mẫu hóa đơn'
          i_title_kyhieuhoadon   = 'Ký hiệu hóa đơn'
          i_title_sohoadonw      = 'Số hóa đơn'
          i_title_ngaythangphathanh = 'Ngày, tháng, năm phát hành'
          i_title_tennguoiban       = 'Tên người bán'
          i_title_mstnguoiban       = 'MST người bán'
          i_title_mathang           = 'Mặt Hàng'
          i_title_donvitinh         = 'Đơn vị tính'
          i_title_soluong           = 'Số lượng'
          i_title_dongia            = 'Đơn giá'
          i_title_doanhthuchuathue  = 'Doanh số mua chưa có thuế'
          i_title_thuesuat          = 'Thuế suất'
          i_title_thuesuatgtgt          = 'Thuế GTGT'
          i_title_tongtien          = 'Tổng tiền'
          i_title_ghichu            = 'Ghi chú '
          i_title_sochungtu         = 'Số chứng từ'
          item = lt_item
          f_note_1            = |Tổng giá trị HHDV mua vào phục vụ SXKD được khấu trừ thuế GTGT (**): { lv_total_doanhthuchuathue_t }|
          f_note_2            = |Tổng số thuế GTGT của HHDV mua vào đủ điều kiện được khấu trừ thuế  (***): { lv_total_thuegtgt_t }|
          f_title_ngaythangnam = '..............., ngày......... tháng........... năm..........'
          f_note3              = 'NGƯỜI NỘP THUẾ hoặc'
          f_note4              = 'ĐẠI DIỆN HỢP PHÁP CỦA NGƯỜI NỘP THUẾ'
          f_note_5             = ' Ký tên, đóng dấu (ghi rõ họ tên và chức vụ)'
       ) TO lt_excel.
      me->create_excel(
        EXPORTING
          i_data     = lt_excel
        IMPORTING
          e_excel    = lv_excel
          e_filename = lv_filename
          e_mimetype = lv_mimetype
      ).
    ENDIF.
    "export data entity======================================================
    IF lt_results IS NOT INITIAL.
      IF top < 0.
        top = 1.
      ENDIF.

      IF lines( lt_results ) > 1.
        LOOP AT lt_results INTO DATA(ls_row) FROM skip + 1 TO skip + top. "#EC CI_NOORDER
          ls_row-uuid = lv_uuid_fi.
          ls_row-attachment_exc = lv_excel.
          ls_row-filename_exc = lv_filename.
          ls_row-mimetype_exc = lv_mimetype.
          APPEND ls_row TO lt_result_page.
        ENDLOOP.
      ELSE.
        lt_result_page = lt_results.
      ENDIF.


    ENDIF.

    io_response->set_data( lt_result_page ).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_results ) ).
    ENDIF.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_aggregation.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_entity_id.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_filter.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_paging.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_parameters.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_requested_elements.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_search_expression.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_sort_elements.
  ENDMETHOD.


  METHOD   if_rap_query_request~is_data_requested.
  ENDMETHOD.


  METHOD   if_rap_query_request~is_total_numb_of_rec_requested.
  ENDMETHOD.


  METHOD create_excel.
    DATA: lo_excel    TYPE REF TO zcl_export_excel_xlsx,
          lv_report   TYPE char72 VALUE 'ZPM03',
          lv_template TYPE char72 VALUE 'ZPM03_EXC',
          lv_filename TYPE string VALUE 'ZPM03.xlsx',
          lv_mimetype TYPE string VALUE 'application/vnd.ms-excel'.

    DATA: lv_excel TYPE zde_attachment_tmpl.

    lo_excel = NEW #( ).
    lo_excel->export_excel(
      EXPORTING
        iv_template = lv_template
        iv_report   = lv_report
        it_data     = i_data
        iv_generate = ''
      IMPORTING
        lv_context  = lv_excel
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
            filename   = lv_filename
            mimetype   = lv_mimetype
            attachment = lv_excel
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
        filename   = lv_filename
        mimetype   = lv_mimetype
        attachment = lv_excel
        ) )
     MAPPED DATA(ls_mapped_update)
     REPORTED DATA(ls_reported_update)
     FAILED DATA(ls_failed_update).
    ENDIF.
    COMMIT ENTITIES.
    e_excel = lv_excel.
    e_filename = lv_filename.
    e_mimetype = lv_mimetype.
  ENDMETHOD.
ENDCLASS.
