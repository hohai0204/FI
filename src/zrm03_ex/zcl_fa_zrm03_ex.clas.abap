CLASS zcl_fa_zrm03_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    INTERFACES if_rap_query_request.
    TYPES: ty_curr TYPE zde_amount23.

    CLASS-METHODS format_amount
      IMPORTING
        i_amount        TYPE ty_curr
        i_currency      TYPE waers
      RETURNING
        VALUE(r_amount) TYPE string.

    TYPES: tt_item  TYPE STANDARD TABLE OF zfa_i_rzrm03_ex  WITH EMPTY KEY.
    TYPES: BEGIN OF ty_data_exc,
             report_name  TYPE string,
             bieumau      TYPE string,
             kythue       TYPE string,
             nguoint      TYPE string,
             mst_nguoint  TYPE string,
             address_nnt  TYPE string,
             dvttien      TYPE string,
             tt_stt       TYPE string,
             tt_hdb       TYPE string,
             tt_mauhd     TYPE string,
             tt_kyhieuhd  TYPE string,
             tt_sohd      TYPE string,
             tt_datehd    TYPE string,
             tt_tennm     TYPE string,
             tt_mstnm     TYPE string,
             tt_mathang   TYPE string,
             tt_doanhso   TYPE string,
             tt_tax       TYPE string,
             tt_note      TYPE string,
             tt_sochungtu TYPE string,
             items        TYPE  tt_item,
             sumdoanhthu  TYPE string,
             sumtax       TYPE string,
             datefoot     TYPE string,
             tt1foot      TYPE string,
             tt2foot      TYPE string,
             tt3foot      TYPE string,

           END OF ty_data_exc.

    TYPES: tt_data_output TYPE STANDARD TABLE OF ty_data_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ZRM03_EX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.



    "khai báo ===========================================================
    DATA: lt_results_head TYPE STANDARD TABLE OF  zfa_i_rzrm03_ex,
          lt_results      TYPE STANDARD TABLE OF  zfa_i_rzrm03_ex,
          lt_result_page  TYPE STANDARD TABLE OF zfa_i_rzrm03_ex.
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
          lr_reves       TYPE if_rap_query_filter=>tt_range_option.


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
          WHEN 'OBJECT_ID'.
            DATA(lr_object_id) = lw_range-range.
          WHEN OTHERS.
            " Do nothing for other fields
        ENDCASE.
      ENDLOOP.
    ENDIF.

    "-- Check pdf ? --"
    IF lr_object_id IS NOT INITIAL.
      SELECT
        *
        FROM ztb_fifa_excel
        WHERE object_id IN @lr_object_id
        AND report_id = 'ZRM03'
        ORDER BY object_id
        INTO TABLE @DATA(lt_excel_file).
    ENDIF.
    DATA lv_uuid_fi          TYPE uuid.
    TRY.
        lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
      CATCH cx_uuid_error INTO DATA(lx_err).
        DATA(lv_error3) = lx_err->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.
    IF lt_excel_file IS INITIAL.
      "get data===============================================
      SELECT DISTINCT
      concat( tax_type, tax_group ) AS object,
*    @lv_uuid_fi as object_id,
        tax_group ,
        taxgroup_desc                                                     AS dgdv,
      'A' AS zsort,
      '3' AS row_type
      FROM ztb_fi_ztax WHERE tax_type = 'B' INTO CORRESPONDING FIELDS OF TABLE @lt_results_head .


      SELECT  zc_fa_zrm03_01~*, 'B' AS zsort FROM zc_fa_zrm03_01
      WHERE    companycode IN @lr_compcode
              AND postingdate IN  @lr_postingdate
              AND assignmentreference IN  @lr_asment
              AND documentdate IN  @lr_docdate
              AND accountingdocument IN  @lr_fidoc
              AND isreversed IN  @lr_reves

       INTO CORRESPONDING FIELDS OF TABLE @lt_results.

      SORT lt_results BY  tax_group documentdate accountingdocument taxcode.

      DATA: ls_group  TYPE  zfa_i_rzrm03_ex,
            ls_result TYPE  zfa_i_rzrm03_ex,
            ls_last   TYPE  zfa_i_rzrm03_ex,
            lt_group  TYPE STANDARD TABLE OF  zfa_i_rzrm03_ex.

      DATA: lt_excel    TYPE tt_data_output,
            ls_data_exc TYPE ty_data_exc.
      DATA: lv_stt TYPE int4.
*loop at lt_results ASSIGNING FIELD-SYMBOL(<lfs_line>).
*
*<lfs_line>-Totalline = <lfs_line>-Taxamount + <lfs_line>-amount.
*lv_stt += 1.
*<lfs_line>-stt = lv_stt.
*ls_group-amount += <lfs_line>-amount.
*ls_group-Taxamount += <lfs_line>-Taxamount.
*ls_group-tax_group = <lfs_line>-tax_group.
*ls_group-Object = |{ ls_group-tax_group  }TOTAL|.
*ls_last-amount += <lfs_line>-amount.
*ls_last-Taxamount += <lfs_line>-Taxamount.
*
*AT END OF tax_group.
*ls_group-dgdv = 'Tổng'.
*ls_group-Totalline = ls_group-amount + ls_group-Taxamount.
*ls_group-Zsort = 'C'.
*append ls_group to lt_group.
*CLear: lv_stt, ls_group.
*ENDAT.
*
*
*at LAST.
*ls_last-dgdv = 'Tổng'.
*ls_last-Totalline = ls_last-amount + ls_last-Taxamount.
*endat.
*ENDLOOP.

      WITH
      +item_min AS (
      SELECT  item_yy~accountingdocument ,MIN( item_yy~accountingdocumentitem )  AS accountingdocumentitem
      FROM i_journalentryitem AS item_yy
      GROUP BY item_yy~accountingdocument
      )
      SELECT min~accountingdocument, item_yy~yy1_gchd_jei
      FROM @lt_results AS fidoc
      INNER JOIN +item_min AS min ON min~accountingdocument = fidoc~accountingdocument
      INNER JOIN i_journalentryitem AS item_yy ON  min~accountingdocument = item_yy~accountingdocument
      AND min~accountingdocumentitem = item_yy~accountingdocumentitem
      ORDER BY min~accountingdocument
      INTO TABLE @DATA(lt_itemmin).
      SELECT DISTINCT fidoc~customer,
      CASE WHEN fidoc~accountingdocumenttype = 'RV' THEN
      CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
               ota_cus~name
                 ELSE customer_fi~name  END
                 ELSE
                 CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
                concat_with_space( ota_cusfi~businesspartnername1,
                concat_with_space( ota_cusfi~businesspartnername2,
                concat_with_space( ota_cusfi~businesspartnername3, ota_cusfi~businesspartnername4, 1 ), 1 ) ,1 )

                 ELSE customer_fi~name  END
                  END                                                                                                 AS customername,

            CASE WHEN fidoc~accountingdocumenttype = 'RV' THEN
            CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
            concat( concat(  concat(
                  concat_with_space( ota_cus~street1, ota_cus~street2, 1 ),  ota_cus~street3 ),ota_cus~street4 ), ota_cus~street5 )

            ELSE customer_fi~address  END
            ELSE
            CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
            concat_with_space( ota_cusfi~streetaddressname, ota_cusfi~cityname, 1 )
            ELSE
            customer_fi~address      END
            END                                                                                                       AS customeradress,

            customer_fi~mst                                                                                              AS mst_customer

      FROM @lt_results AS fidoc
          LEFT OUTER JOIN zcds_bp_profile  AS customer_fi   ON fidoc~customer = customer_fi~businesspartner
          LEFT OUTER JOIN zcds_bp_ota                   AS ota_cus         ON  fidoc~customer          = ota_cus~customer
                                                                           AND fidoc~originalreferencedocument = ota_cus~billingdocument
          LEFT OUTER JOIN i_onetimeaccountsupplier      AS ota_cusfi       ON  ota_cusfi~accountingdocument     = fidoc~accountingdocument
                                                                           AND ota_cusfi~companycode            = fidoc~companycode
                                                                           AND fidoc~customer          = ota_cusfi~supplier
      ORDER BY fidoc~customer
      INTO TABLE @DATA(lt_customer).
      DATA: lo_api       TYPE REF TO zcl_get_long_text.

      lo_api = NEW #( ).

      DATA: lo_fotamt TYPE REF TO zcl_format_amount.
      lo_fotamt = NEW #(  ).
      DATA: lt_longtext TYPE zcl_get_long_text=>tt_longtext_res.
      DATA: lt_longtext_out TYPE zcl_get_long_text=>tt_longtext_res.
      DATA: lv_billing TYPE i_billingdocument-billingdocument.
      LOOP AT lt_results INTO ls_result
           GROUP BY ( tax_group = ls_result-tax_group ) INTO DATA(group_key).

        LOOP AT GROUP group_key ASSIGNING FIELD-SYMBOL(<lfs_line>).
          <lfs_line>-totalline = <lfs_line>-taxamount + <lfs_line>-amount.
          lv_stt += 1.
          <lfs_line>-stt = lv_stt.
*        <lfs_line>-object_id = lv_uuid_fi.
          READ TABLE lt_itemmin INTO DATA(ls_intemmin) WITH KEY accountingdocument = <lfs_line>-accountingdocument BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_line>-yy1_gchd_jei = ls_intemmin-yy1_gchd_jei.
          ENDIF.

          lv_billing = <lfs_line>-originalreferencedocument.
          lv_billing = |{ lv_billing  ALPHA = IN }|.
          lo_api->get_longtext_billing_header( EXPORTING billingdocument = lv_billing
                                     IMPORTING result           = lt_longtext ).
          READ TABLE lt_longtext INTO DATA(ls_longtext) WITH KEY tdid = 'TX06' BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_line>-custom_name = ls_longtext-longtext.
          ELSE.
            READ TABLE lt_customer INTO DATA(ls_cus) WITH KEY customer = <lfs_line>-customer BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_line>-custom_name = ls_cus-customername.
            ENDIF.
          ENDIF.
          READ TABLE lt_longtext INTO ls_longtext WITH KEY tdid = 'TX15' BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_line>-custom_mst = ls_longtext-longtext.
          ELSE.
            <lfs_line>-custom_mst = ls_cus-mst_customer.
          ENDIF.
          CLEAR lt_longtext.
          IF <lfs_line>-custom_name IS INITIAL.
            <lfs_line>-custom_name = <lfs_line>-customername.
          ENDIF.
          IF <lfs_line>-custom_mst IS INITIAL.
            <lfs_line>-custom_mst = <lfs_line>-mst_customer.
          ENDIF.
          <lfs_line>-amount_text = |{ lo_fotamt->format_amount( i_amount = <lfs_line>-amount  i_currency = <lfs_line>-companycodecurrency ) }|.
          <lfs_line>-taxamount_text = |{ lo_fotamt->format_amount( i_amount = <lfs_line>-taxamount  i_currency = <lfs_line>-companycodecurrency ) }|.
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
        ls_group-dgdv_exc = |Tổng:|.
        ls_group-totalline = ls_group-amount + ls_group-taxamount.
        ls_group-amount_nt = ls_group-taxbaseamountintranscrcy + ls_group-taxamounttrans.
        ls_group-zsort = 'C'.
        ls_group-row_type = '2'.
*      ls_group-object_id = lv_uuid_fi.

        ls_group-amount_text = |{ lo_fotamt->format_amount( i_amount = ls_group-amount  i_currency = ls_group-companycodecurrency ) }|.
        ls_group-taxamount_text = |{ lo_fotamt->format_amount( i_amount =  ls_group-taxamount  i_currency = ls_group-companycodecurrency ) }|.
        APPEND ls_group TO lt_group.
        CLEAR: lv_stt, ls_group.

      ENDLOOP.
      ls_last-object = 'DSUMTOTAL'.
*    ls_last-object_id = lv_uuid_fi.
      ls_last-zsort = 'D'.
      ls_last-dgdv = 'Tổng'.
      ls_last-row_type = '1'.
      ls_last-totalline = ls_last-amount + ls_last-taxamount.
      ls_last-amount_nt = ls_last-taxbaseamountintranscrcy + ls_last-taxamounttrans.
      ls_last-amount_text = |{ lo_fotamt->format_amount( i_amount =  ls_last-amount i_currency = ls_last-companycodecurrency ) }|.
      ls_last-taxamount_text = |{ lo_fotamt->format_amount( i_amount =  ls_last-taxamount  i_currency = ls_last-companycodecurrency ) }|.

      " excel ================================

      READ TABLE lt_results INTO DATA(ls_head) INDEX 1.
      IF sy-subrc = 0.
        ls_data_exc-report_name = 'BẢNG KÊ HOÁ ĐƠN, CHỨNG TỪ HÀNG HOÁ, DỊCH VỤ BÁN RA'.
        ls_data_exc-bieumau = '(Kèm theo tờ khai thuế GTGT mẫu số 01/GTGT)'.
        ls_data_exc-dvttien      = 'Đơn vị tiền : đồng Việt Nam'.

        " --- Các nhãn tiêu đề cho phần Header (Nếu cần in nhãn) ---
        ls_data_exc-kythue       = |Kỳ tính thuế: Tháng { ls_head-period(2) } năm { ls_head-documentdate(4) }|.
        ls_data_exc-nguoint      = |Người nộp thuế: { ls_head-tencty_vn }|.
        ls_data_exc-mst_nguoint  = |Mã số thuế: { ls_head-mst_company }|.
        ls_data_exc-address_nnt  = |Địa chỉ: { ls_head-diachi_vn }|.

        " --- Mapping tiêu đề cột cho bảng (Items) ---
        ls_data_exc-tt_hdb      = 'Hóa đơn chứng từ bán'.
        ls_data_exc-tt_stt      = 'STT'.
        ls_data_exc-tt_mauhd    = 'Ký hiệu mẫu hóa đơn'.
        ls_data_exc-tt_kyhieuhd = 'Ký hiệu hóa đơn'.
        ls_data_exc-tt_sohd     = 'Số hóa đơn'.
        ls_data_exc-tt_datehd   = 'Ngày, tháng, năm phát hành'.
        ls_data_exc-tt_tennm    = 'Tên người mua'.
        ls_data_exc-tt_mstnm    = 'Mã số thuế người mua'.
        ls_data_exc-tt_mathang  = 'Mặt hàng'.
        ls_data_exc-tt_doanhso  = 'Doanh số bán chưa có thuế'.
        ls_data_exc-tt_tax      = 'Thuế GTGT'.
        ls_data_exc-tt_note     = 'Ghi chú'.
        ls_data_exc-tt_tax      = 'Thuế GTGT'.
        ls_data_exc-tt_sochungtu = 'Số chứng từ'.
        ls_data_exc-sumdoanhthu     = |Tổng doanh thu hàng hóa, dịch vụ bán ra chịu thuế GTGT (*): { ls_last-amount_text }|.
        ls_data_exc-sumtax     = |Tổng số thuế GTGT của hàng hóa, dịch vụ bán ra (**): { ls_last-taxamount_text }|.
        " --- Footer Information (Chức danh) ---
        ls_data_exc-datefoot     = |............,ngày { sy-datum+6(2) } tháng { sy-datum+4(2) } năm { sy-datum(4) }|.
        ls_data_exc-tt1foot     = 'NGƯỜI NỘP THUẾ hoặc'.
        ls_data_exc-tt2foot     = 'ĐẠI DIỆN HỢP PHÁP CỦA NGƯỜI NỘP THUẾ'.
        ls_data_exc-tt3foot     = 'Ký tên, đóng dấu (Ghi rõ họ tên và chức vụ)'.
      ENDIF.

      APPEND LINES OF lt_results_head TO lt_results.
      APPEND LINES OF lt_group TO lt_results.
      SORT lt_results BY tax_group zsort documentdate accountingdocument taxcode.

      ls_data_exc-items = CORRESPONDING #( lt_results ) .

*ls_data_exc-items = CORRESPONDING #( lt_results_head ).
      APPEND ls_last TO lt_results.
      CLEAR: lt_group, ls_last.

      "export Excel attachment
      APPEND ls_data_exc TO lt_excel.

      DATA: lv_attacment_exc TYPE zde_attachment,
            lv_report        TYPE char72 VALUE 'ZRM03',
            lv_template      TYPE char72 VALUE 'ZRM03_EXC'.

      DATA: lo_excel       TYPE REF TO zcl_export_excel_xlsx.
      lo_excel = NEW #( ).
      lo_excel->export_excel( EXPORTING
                              iv_template = lv_template
                              iv_report = lv_report
                              it_data = lt_excel
                              iv_generate = abap_false
                              IMPORTING lv_context = lv_attacment_exc ).



      GET TIME STAMP FIELD DATA(lv_timestamp).
      READ TABLE lt_results ASSIGNING FIELD-SYMBOL(<lfs_data>) INDEX 1.
      IF sy-subrc = 0.
        "excel attachment
        <lfs_data>-object_id = lv_uuid_fi.
        <lfs_data>-attachment_exc = lv_attacment_exc.
        <lfs_data>-mimetype_exc = 'application/vnd.ms-excel'.
        <lfs_data>-filename_exc = |{ lv_timestamp }.xlsx|.

      ENDIF.
      DATA(lo_saveexc) = NEW zcl_update_fifaexcel( ) .
      DATA: lv_date_after TYPE datum.
      lv_date_after = syst-datum - 1.
*    DELETE FROM ztb_fifa_excel WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).
      lo_saveexc->delete_fifaexcel( EXPORTING lv_date = lv_date_after iv_report_id = 'ZRM03' ).
      DATA(ls_data) = VALUE ztb_fifa_excel(
            object_id = lv_uuid_fi
            report_id = 'ZRM03'
            filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.xlsx|
            mimetype =  'application/vnd.ms-excel'
            attachment = lv_attacment_exc

             " Metadata fields
      create_time            = syst-uzeit
      create_date            = syst-datum

          ).

      IF ls_data IS NOT INITIAL.
        lo_saveexc->update_fifaexcel( EXPORTING ls_update_fifaexcel = ls_data  ).
      ENDIF.
*    INSERT ztb_fifa_excel FROM @ls_data.
*    IF sy-subrc <> 0.
*      " Có thể update nếu đã tồn tại
*      UPDATE ztb_fifa_excel FROM @ls_data.
*    ENDIF.
*
*
    ELSE.

      "-- Current date print
      DATA: ls_file TYPE zfa_i_rzrm03_ex.
      READ TABLE lt_excel_file ASSIGNING FIELD-SYMBOL(<lfs_excel>) INDEX 1.
      IF sy-subrc = 0.

        "excel attachment
        ls_file-object_id = lr_object_id[ 1 ]-low.
        ls_file-attachment_exc = <lfs_excel>-attachment.
        ls_file-mimetype_exc =  <lfs_excel>-mimetype.
        ls_file-filename_exc =  <lfs_excel>-filename.
        APPEND ls_file TO lt_results.
      ENDIF.
    ENDIF.
    " excel ================================





    " Request Sorting
    DATA: lv_sort_string TYPE string.
    DATA(sort_elements) = io_request->get_sort_elements( ).
    IF sort_elements IS NOT INITIAL.
      DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                 ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                                                        THEN ' descending'
                                                                                        ELSE ' ascending' ) ) ).

      IF lt_sort_criteria IS INITIAL.
        lv_sort_string = 'primary key'.
      ELSE.
        lv_sort_string = concat_lines_of( table = lt_sort_criteria sep = `, ` ).
      ENDIF.

    ENDIF.
*      IF lv_sort_string IS NOT INITIAL.
*        sort lt_results  BY (lv_sort_string) .
*      ELSE.
*
*      ENDIF.

    "export data entity======================================================
    IF lt_results IS NOT INITIAL.
      IF top < 0.
        top = 1.
      ENDIF.

      IF lines( lt_results ) > 1.
        LOOP AT lt_results INTO DATA(ls_row) FROM skip + 1 TO skip + top.
          APPEND ls_row TO lt_result_page.
        ENDLOOP.
      ELSE.
        lt_result_page = lt_results.
      ENDIF.

      io_response->set_data( lt_result_page ).
    ENDIF.


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


  METHOD format_amount.


    DATA: lv_str      TYPE string,
          lv_dec      TYPE string,
          lv_amount   TYPE zde_amount23,
          lv_sign     TYPE abap_boolean,
          lv_decimals TYPE i.
    IF i_amount >= 0.
      lv_amount = abs( i_amount ).
    ELSE.
      lv_sign = abap_true.
      lv_amount = abs( i_amount ).
    ENDIF.
    " --- Nhân theo loại tiền ---
    CASE i_currency.
      WHEN 'VND'.
        lv_amount   = lv_amount * 100.
        lv_decimals = 0.
      WHEN 'USD'.
        lv_amount   = lv_amount.
        lv_decimals = 2.
      WHEN OTHERS.
        lv_amount   = lv_amount * 100.
        lv_decimals = 0.
    ENDCASE.

    " --- Convert sang string theo số decimal ---
    lv_str = |{ lv_amount DECIMALS = lv_decimals }|.

    " --- Split integer + decimal ---
    DATA(lv_int) = lv_str.
    CLEAR lv_dec.

    IF lv_decimals > 0.
      SPLIT lv_str AT '.' INTO lv_int lv_dec.

      " đảm bảo đủ số decimal
      WHILE strlen( lv_dec ) < lv_decimals.
        lv_dec = lv_dec && '0'.
      ENDWHILE.

    ELSE.
      lv_int = lv_str.
    ENDIF.

    " --- Insert thousand separator (.) ---
    DATA lv_formatted_int TYPE string.
    DATA(l_length) = strlen( lv_int ).
    DATA lv_len TYPE i.
    lv_len = l_length.

    DATA lv_pos TYPE i.
    lv_pos = lv_len.

    WHILE lv_pos > 3.
      lv_pos = lv_pos - 3.
      lv_formatted_int = substring( val = lv_int off = lv_pos len = 3 ) && lv_formatted_int.
      lv_formatted_int = '.' && lv_formatted_int.
      lv_int = substring( val = lv_int off = 0 len = lv_pos ).
    ENDWHILE.

    lv_formatted_int = lv_int && lv_formatted_int.

    " --- Combine ---
    IF lv_decimals > 0.
      r_amount = lv_formatted_int && ',' && lv_dec.
    ELSEIF lv_decimals = 0.
      r_amount = ''.
    ELSE.
      r_amount = lv_formatted_int.
    ENDIF.
    IF lv_sign IS NOT INITIAL.
      r_amount = |({ r_amount })|.
    ELSE.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
