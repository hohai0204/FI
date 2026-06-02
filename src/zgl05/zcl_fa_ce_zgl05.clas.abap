CLASS zcl_fa_ce_zgl05 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_rap_query_provider .

    TYPES: BEGIN OF ty_data_output.
             INCLUDE TYPE zfa_i_zgl05.
    TYPES:   dutrongkyvnd   TYPE p LENGTH 16  DECIMALS 2,
             dutrongkyusd   TYPE p LENGTH 16  DECIMALS 2,
             tonvnd         TYPE p LENGTH 16  DECIMALS 2,
             tonngoaite     TYPE p LENGTH 16  DECIMALS 2,
             dudaukyvnd     TYPE p LENGTH 16  DECIMALS 2,
             dudaukyngoaite TYPE p LENGTH 16  DECIMALS 2,
             attachment     TYPE zattachment,
             filename       TYPE c LENGTH 128,
             mimetype       TYPE c LENGTH 128,
             attachment_xml TYPE zattachment,
             filename_xml   TYPE c LENGTH 128,
             mimetype_xml   TYPE c LENGTH 128,
             pdfid          TYPE c LENGTH 100,

             attachment_exc TYPE zattachment,
             mimetype_exc   TYPE c LENGTH 128,
             filename_exc   TYPE c LENGTH 128,

           END OF ty_data_output.

    TYPES: tt_data_output TYPE STANDARD TABLE OF ty_data_output.

    TYPES: BEGIN OF ty_item,
             BEGIN OF item,
               accounting_document  TYPE string,
               assignment_reference TYPE string,
             END OF item,
           END OF ty_item.

    TYPES: BEGIN OF ty_header,
             BEGIN OF header,
               from_to_posting_date TYPE string,
               from_to_glaccount    TYPE string,
               glaccount            TYPE string,
               glaccounttext        TYPE string,
               items                TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,
             END OF header,
           END OF ty_header.
    TYPES: BEGIN OF ty_form,
             BEGIN OF form,
               headers TYPE STANDARD TABLE OF ty_header WITH EMPTY KEY,
             END OF form,
           END OF ty_form.

* ------------------------------------------------------------------------

    TYPES: BEGIN OF ty_item_v1,
             BEGIN OF item,
               posting_date            TYPE string,
               document                TYPE string,
               document_date           TYPE string,
               document_item_text      TYPE string,
               offsetting_account      TYPE string,
               offsetting_account_name TYPE string,
               reconciliation_account  TYPE string,
               currency                TYPE string,
               absolute_exchange_rate  TYPE string,
               debit_amount            TYPE string,
               debit_amount_vnd        TYPE string,
               credit_amount           TYPE string,
               credit_amount_vnd       TYPE string,
               end_amount              TYPE string,
               end_amount_vnd          TYPE string,

               posting_date_doc            TYPE string,
               document_date_doc           TYPE string,

               zlevel                  TYPE char03,
             END OF item,
           END OF ty_item_v1.
    TYPES: BEGIN OF ty_header_v1,
             BEGIN OF header,
               glaccount         TYPE string,
               glaccounttext     TYPE string,
               glaccountlongname TYPE string,
               begin_amount      TYPE string,
               begin_amount_vnd  TYPE string,
               debit_amount      TYPE string,
               debit_amount_vnd  TYPE string,
               credit_amount     TYPE string,
               credit_amount_vnd TYPE string,
               end_amount        TYPE string,
               end_amount_vnd    TYPE string,
               documents         TYPE  STANDARD TABLE OF ty_item_v1 WITH EMPTY KEY,

               zlevel            TYPE char03,
             END OF header,
           END OF ty_header_v1.

*ViHT9/20.04.2026/Update ZGL05 excel
    TYPES: BEGIN OF ty_header_v1_ex,

               glaccount               TYPE string,
               glaccounttext           TYPE string,
               glaccountlongname       TYPE string,
               begin_amount            TYPE string,
               begin_amount_vnd        TYPE string,
               debit_amount            TYPE string,
               debit_amount_vnd        TYPE string,
               credit_amount           TYPE string,
               credit_amount_vnd       TYPE string,
               end_amount              TYPE string,
               end_amount_vnd          TYPE string,

               posting_date_doc            TYPE string,
               document_date_doc           TYPE string,
               document                TYPE string,
               document_item_text      TYPE string,
               offsetting_account      TYPE string,
               offsetting_account_name TYPE string,
               reconciliation_account  TYPE string,
               currency                TYPE string,
               absolute_exchange_rate  TYPE string,


               sddktext          TYPE string,
               pstktext          TYPE string,
               sdcktext          TYPE string,

               zlevel                  TYPE char03,
               border                  TYPE char03,

           END OF ty_header_v1_ex.

TYPES:  ty_glaccountsexc TYPE STANDARD TABLE OF ty_header_v1_ex WITH EMPTY KEY.
*ViHT9/20.04.2026/Update ZGL05 excel

    TYPES: BEGIN OF ty_form_v1,
             BEGIN OF form,
               title             TYPE string,
               date_from_to      TYPE string,
               from              TYPE string,
               to                TYPE string,
               title_glaccount   TYPE string,
*ViHT9/24.10.2025/Update ZGL05 PHUTAI_SAP_2025_BH-130
               zlogo                TYPE string,

               debit_amount      TYPE string,
               debit_amount_vnd  TYPE string,
               credit_amount     TYPE string,
               credit_amount_vnd TYPE string,
               ton_amount        TYPE string,
               ton_amount_vnd    TYPE string,

               tencty_vn         TYPE string,
               diachi_vn         TYPE string,
               mst               TYPE string,

               ngs_h             TYPE string,

               ct_h              TYPE string,
               nct_h             TYPE string,
               sct_h             TYPE string,

               dg_h              TYPE string,
               st_h              TYPE string,
               thu_h             TYPE string,
               chi_h             TYPE string,
               ton_h             TYPE string,

               tcktext           TYPE string,

               nl_h              TYPE string,
               ktt_h             TYPE string,
               gd_h              TYPE string,

               nlky_h            TYPE string,
               kttky_h           TYPE string,
               gdky_h            TYPE string,

               glaccountsexc     TYPE STANDARD TABLE OF ty_header_v1_ex WITH EMPTY KEY,
*ViHT9/24.10.2025/Update ZGL05 PHUTAI_SAP_2025_BH-130
               glaccounts        TYPE STANDARD TABLE OF ty_header_v1 WITH EMPTY KEY,
             END OF form,
           END OF ty_form_v1.

* ------------------------------------------------------------------------
    TYPES: BEGIN OF ty_large_object,
             attachment     TYPE xstring,
             mimetype       TYPE string,
             filename       TYPE string,

             attachment_exc TYPE xstring,
           END OF ty_large_object.
    TYPES: BEGIN OF ty_session,
             old_id TYPE string,
             new_id TYPE string,
           END OF ty_session.


  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_dec_2    TYPE p DECIMALS 2 LENGTH 16,
      ty_curr_vnd TYPE p DECIMALS 0 LENGTH 16.

    DATA: gt_data_output TYPE tt_data_output.
    DATA: ls_data_form TYPE ty_form.
    DATA: ls_data_form_v1 TYPE ty_form_v1,
          lt_data_form_v1 TYPE STANDARD TABLE OF  ty_form_v1-form.
    DATA: is_large_object TYPE abap_boolean VALUE abap_false.

    METHODS get_data
      IMPORTING io_request TYPE REF TO if_rap_query_request
      EXPORTING et_table   TYPE tt_data_output
      .

    METHODS render_form
      IMPORTING ia_abap TYPE any
      EXPORTING ev_pdf  TYPE xstring
                ev_xml  TYPE xstring
*      RETURNING VALUE(rv_pdf) TYPE xstring.
      .

    METHODS abap2xml
      IMPORTING ia_abap            TYPE any
      EXPORTING ev_xml_string      TYPE string
                ev_xml_xstring     TYPE xstring
      RETURNING VALUE(rv_xml_data) TYPE string.

    METHODS dynamic_data
      IMPORTING i_data         TYPE any
                i_name_mapping TYPE /ui2/cl_json=>name_mappings OPTIONAL
                i_kind_type    TYPE c DEFAULT cl_abap_typedescr=>typekind_struct2
      CHANGING  co_writer      TYPE REF TO if_sxml_writer OPTIONAL.

    METHODS upsert_attachment
      IMPORTING is_large_object TYPE ty_large_object
                is_session      TYPE ty_session OPTIONAL
      .

    METHODS upsert_attachment_xml
      IMPORTING is_large_object TYPE ty_large_object
                is_session      TYPE ty_session OPTIONAL.

    METHODS format_negative_number
      IMPORTING iv_value        TYPE ty_dec_2
                i_negative      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_value) TYPE string.
    METHODS format_negative_number_output
      IMPORTING iv_value        TYPE ty_dec_2
                i_negative      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_value) TYPE string.
ENDCLASS.



CLASS ZCL_FA_CE_ZGL05 IMPLEMENTATION.


  METHOD abap2xml.

    DATA(writer) = CAST if_sxml_writer( cl_sxml_string_writer=>create( type     = if_sxml=>co_xt_xml10
                                                                               encoding = 'UTF-8' ) ).

    dynamic_data( EXPORTING i_data         = ia_abap
                            i_kind_type    = cl_abap_typedescr=>typekind_struct2
                            i_name_mapping = zcl_einvoice=>name_mappings_request-preview_invoice
                  CHANGING  co_writer      = writer ).

    DATA(xml) = CAST cl_sxml_string_writer( writer )->get_output(  ).
    DATA(lv_xml) = xco_cp=>xstring( xml )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    REPLACE '<?xml version="1.0" encoding="utf-8"?>' IN lv_xml WITH ''.

    ev_xml_string = lv_xml.
    ev_xml_xstring = xml.

    RETURN lv_xml.
  ENDMETHOD.


  METHOD dynamic_data.

    DATA: lo_table_descr      TYPE REF TO cl_abap_tabledescr,
          lo_struct_descr     TYPE REF TO cl_abap_structdescr,
          lo_struct_descr1    TYPE REF TO cl_abap_structdescr,
          lo_line_type        TYPE REF TO cl_abap_typedescr,
          lt_components       TYPE cl_abap_structdescr=>component_table,
          lt_components_child TYPE cl_abap_structdescr=>component_table,
          ls_component        TYPE cl_abap_structdescr=>component,
          lo_data_descr       TYPE REF TO cl_abap_datadescr,
          lv_abap_type_kind   TYPE abap_typekind.

    DATA: lv_field_name_mapping TYPE string,
          lv_row_index          TYPE i.
    FIELD-SYMBOLS: <lv_field> TYPE any.

    TRY.

        IF i_kind_type = cl_abap_typedescr=>typekind_table OR i_kind_type = cl_abap_typedescr=>kind_table.
          lo_table_descr ?= cl_abap_typedescr=>describe_by_data( i_data ).
          lo_line_type = lo_table_descr->get_table_line_type( ).
          lo_struct_descr ?= lo_line_type.
        ELSE.

          lo_struct_descr ?= cl_abap_typedescr=>describe_by_data( i_data ).
        ENDIF.


        lt_components = lo_struct_descr->get_components( ).
        LOOP AT lt_components INTO ls_component.
          lv_row_index = sy-tabix.

          CASE i_kind_type.
            WHEN cl_abap_typedescr=>typekind_table OR cl_abap_typedescr=>kind_table.
              LOOP AT i_data ASSIGNING FIELD-SYMBOL(<lfs_struct>).
                dynamic_data(
                  EXPORTING
                    i_data       = <lfs_struct>
                  i_name_mapping = i_name_mapping
                    i_kind_type  = cl_abap_typedescr=>typekind_struct2
                    CHANGING co_writer = co_writer
                ).
              ENDLOOP.

          ENDCASE.

          CHECK i_kind_type <> cl_abap_typedescr=>typekind_table AND
                i_kind_type <> cl_abap_typedescr=>kind_table.


          IF ls_component-as_include = abap_true.
            lo_struct_descr1 ?= ls_component-type.
*            APPEND LINES OF lo_struct_descr1->get_components( ) TO lt_components.
            lv_row_index += 1.
            INSERT LINES OF  lo_struct_descr1->get_components( ) INTO lt_components INDEX lv_row_index.
            CONTINUE.
          ENDIF.

          CHECK ls_component-name IS NOT INITIAL.
          "lv_field_name_mapping = i_name_mapping[ abap = to_lower( ls_component-name ) ]-json.
          lv_field_name_mapping = ls_component-name.
          co_writer->open_element( name = lv_field_name_mapping ).

          ASSIGN COMPONENT ls_component-name OF STRUCTURE i_data TO <lv_field>.
          CHECK <lv_field> IS ASSIGNED.

          CASE ls_component-type->type_kind.

            WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2 OR
            cl_abap_typedescr=>typekind_table OR cl_abap_typedescr=>kind_table.

              dynamic_data( EXPORTING i_data         = <lv_field>
                                      i_name_mapping = i_name_mapping
                                      i_kind_type    = ls_component-type->type_kind
                            CHANGING  co_writer      = co_writer ).

            WHEN cl_abap_typedescr=>typekind_string
                OR cl_abap_typedescr=>typekind_char
                OR cl_abap_typedescr=>typekind_num
                OR cl_abap_typedescr=>typekind_int
                OR cl_abap_typedescr=>typekind_int1
                OR cl_abap_typedescr=>typekind_int2
                OR cl_abap_typedescr=>typekind_int8.
              co_writer->write_value( condense( <lv_field> ) ).

          ENDCASE.


          co_writer->close_element( ).
          "ls_component-name
          "<lv_field>
          "ls_component-type->type_kind
        ENDLOOP.


      CATCH cx_sxml_state_error INTO DATA(lx_sxml_error).
        DATA(lv_error_message) = lx_sxml_error->get_text( ).

      CATCH cx_sxml_name_error INTO DATA(lx_sxml_name_error).
        DATA(lv_error_message_1) = lx_sxml_name_error->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD format_negative_number.
*    DATA: lv_value TYPE ty_dec_2.
*    lv_value = iv_value.
    RETURN COND #( WHEN iv_value < 0 THEN |-{ iv_value * -1 }| ELSE |{ iv_value }| ).
  ENDMETHOD.


  METHOD format_negative_number_output.
*    DATA: lv_value TYPE ty_dec_2.
*    lv_value = iv_value.
    RETURN COND #( WHEN iv_value < 0 THEN |({ iv_value * -1 })| ELSE |{ iv_value }| ).
  ENDMETHOD.


  METHOD get_data.
    DATA ls_session_pdf TYPE ty_session.
    DATA lt_data                 TYPE tt_data_output.
    DATA field_isincludereversal TYPE string VALUE 'IsIncludeReversal'.

    field_isincludereversal = to_upper( field_isincludereversal ).

    " Filter
    DATA(ro_filter) = io_request->get_filter( ).
    " Conditions
    DATA(lv_conditions) = io_request->get_filter( )->get_as_sql_string( ).

    TRY.
        DATA(rt_ranges) = ro_filter->get_as_ranges( iv_drop_null_comparisons = abap_true ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    " Top
    DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    " Skip
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).
*    lv_conditions &&= | AND GLACCOUNT = '1111010001'|.

    DATA(lt_sort) = io_request->get_sort_elements( ).
    " SORTING
*    DATA(sort_order) = VALUE abap_sortorder_tab(
*                                 FOR sort_element IN io_request->get_sort_elements( )
*                                 ( name = sort_element-element_name descending = sort_element-descending ) ).
*    sort lt_data by (sort_order).

    DATA lv_orderby TYPE string VALUE `COMPANYCODE` .
    IF lt_sort IS NOT INITIAL.
      " lv_orderby = |GLACCOUNT|.
      lv_orderby = REDUCE #( INIT s TYPE string
                             FOR ls_sort IN lt_sort
                             NEXT s &&= |{ ls_sort-element_name } { COND #( WHEN ls_sort-descending = abap_true
                                                                            THEN 'DESCENDING' ) }, | ).

      REPLACE ALL OCCURRENCES OF PCRE `\s*,\s*$` IN lv_orderby WITH space.
    ENDIF.


    " ------------------------------------------------------------------------
    " Get filter sử dụng cho các select khác: Tính đầu kì
    " ------------------------------------------------------------------------
    DATA range_company        TYPE if_rap_query_filter=>tt_range_option.
    DATA range_year           TYPE if_rap_query_filter=>tt_range_option.
    DATA range_postingdate    TYPE if_rap_query_filter=>tt_range_option.
    DATA range_glaccount    TYPE if_rap_query_filter=>tt_range_option.
    DATA lv_posting_date_from TYPE d.
    DATA lv_posting_date_to   TYPE d.

    DATA: lv_logo TYPE string.
    DATA: lo_logo       TYPE REF TO zcl_get_logo_company.

    LOOP AT rt_ranges INTO DATA(ls_range).
      CASE ls_range-name.
        WHEN 'COMPANYCODE'.
          range_company = ls_range-range.
        WHEN 'FISCALYEAR'.
          range_year = ls_range-range.
        WHEN 'POSTINGDATE'.
          range_postingdate = ls_range-range.
          IF range_postingdate IS NOT INITIAL.
            lv_posting_date_from = range_postingdate[ 1 ]-low.
            lv_posting_date_to = range_postingdate[ 1 ]-high.
          ENDIF.
        WHEN 'GLACCOUNT'.
          range_glaccount = ls_range-range.
        WHEN 'PDFID'.
          CHECK ls_range-range IS NOT INITIAL.
          ls_session_pdf-old_id = ls_range-range[ 1 ]-low.
          DATA(origin_condition_pdf) = |PDFID = '{ ls_session_pdf-old_id }'|.
          REPLACE ALL OCCURRENCES OF origin_condition_pdf IN lv_conditions WITH '1 = 1'.

        WHEN field_isincludereversal.
          CHECK ls_range-range IS NOT INITIAL.
          DATA(filter_includereversal) = ls_range-range[ 1 ].
          IF filter_includereversal-low = abap_false.
            DATA(replace_condition) = |IsNotReversal = 'X'|.
            replace_condition = to_upper( replace_condition ).
            DATA(origin_condition) = |{ field_isincludereversal } = ' '|.
            REPLACE ALL OCCURRENCES OF origin_condition IN lv_conditions WITH replace_condition.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    DATA: lr_bukrs TYPE RANGE OF bukrs.

    SELECT
    companycode
    FROM i_companycode
    where CompanyCode is not INITIAL
    INTO TABLE @DATA(lt_companys).

    LOOP AT lt_companys INTO DATA(ls_comp).
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD ls_comp-companycode
        ID 'ACTVT' FIELD '03'.
      IF sy-subrc = 0.
        APPEND VALUE #( sign   = 'I'
                            option = 'EQ'
                            low    = ls_comp-companycode ) TO lr_bukrs.
      ENDIF.
    ENDLOOP.

          lo_logo = NEW #( ).

    SELECT FROM zfa_i_zgl05
      FIELDS sourceledger,
             companycode,
             fiscalyear,
             ledger,
             accountingdocument,
             ledgergllineitem,
             postingdate,
             documentdate,
             documentitemtext,
             offsettingaccounttype,
             CASE WHEN offsettingaccounttype = 'D' OR offsettingaccounttype = 'K' THEN offsettingaccount ELSE ' ' END     AS offsettingaccount,
             CASE WHEN offsettingaccounttype = 'D' OR offsettingaccounttype = 'K' THEN offsettingaccountname ELSE ' ' END AS offsettingaccountname,
             CASE WHEN offsettingaccounttype = 'S' THEN offsettingaccount
                  WHEN offsettingaccounttype = 'D' OR offsettingaccounttype = 'K' THEN reconciliationaccount ELSE ' ' END     AS reconciliationaccount,
             glaccount,
             glaccounttype,
             glaccountlongname,
             debitcreditcode,
             transactioncurrency,
             absoluteexchangerate,
             debitamountintranscrcy,
             creditamountintranscrcy,

             postingkey,
             fiscalperiod,
             fiscalyearperiod,
             fiscalyearvariant,
             profitcenter,
             segment,
             balancetransactioncurrency,
             amountintransactioncurrency,
             assignmentreference,
             accountingdocumenttype,
             accountingdocumentitem,
             glaccounttext,
             accdoctypetext,
             isnotreversal,
             isincludereversal,
             thuvnd,
             chivnd,
             thungoaite,
             chingoaite,
             'VND' AS cukyVND,
             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS beginningbalance,
             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS currentbalance,
             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS endingbalance,
             @sy-datum(4)                                                                                                 AS currentyear
      WHERE (lv_conditions)

      ORDER BY (lv_orderby) " glaccount ASCENDING, thungoaite, thuvnd DESCENDING "(lv_orderby)
      INTO TABLE @DATA(lt_data_glacc)
      UP TO @lv_top ROWS
      OFFSET @lv_skip.

    DELETE lt_data_glacc WHERE companycode NOT IN lr_bukrs.

    IF lt_data_glacc IS INITIAL.
      RETURN.
    ENDIF.
    lt_data = CORRESPONDING #( lt_data_glacc ).

    " ------------------------------------------------------------------------
    " Xử lý khi người dùng bấm vào Attachment
    " Kiểm tra table lưu attachment, lấy ra attachment sau cùng
    " ------------------------------------------------------------------------
    IF is_large_object = abap_true.
      DATA lv_report_id TYPE string VALUE 'ZFA_ZGL05'.
      DATA lv_object_id TYPE string.
      lv_object_id = |PDF_{ ls_session_pdf-old_id }|.

      " Get attachment lastest by Tcode + User
      SELECT report_id, object_id, attachment, mimetype, filename, last_changed_by, last_changed_at
        FROM ztb_fi_pdf_draf
        WHERE 1               = 1
          AND report_id       = @lv_report_id
          AND object_id       = @lv_object_id
          AND last_changed_by = @sy-uname
        ORDER BY last_changed_at DESCENDING
        INTO TABLE @DATA(lt_pdf_lastest)
        UP TO 1 ROWS.


      IF lt_pdf_lastest IS NOT INITIAL.
        ASSIGN lt_pdf_lastest[ 1 ] TO FIELD-SYMBOL(<ls_pdf_lastest>).
        IF <ls_pdf_lastest>-attachment IS NOT INITIAL.

          MODIFY lt_data FROM VALUE #( BASE CORRESPONDING #( lt_data[ 1 ] )
                                       attachment = <ls_pdf_lastest>-attachment
                                       mimetype   = <ls_pdf_lastest>-mimetype
                                       filename   = <ls_pdf_lastest>-filename )
                 INDEX 1 TRANSPORTING attachment mimetype filename.
          IF sy-subrc <> 0.
          ENDIF.
        ENDIF.
      ENDIF.


    SELECT report_id, object_id, attachment, mimetype, filename, last_changed_by, last_changed_at
      FROM ztb_fifa_excel
      WHERE 1               = 1
        AND report_id       = @lv_report_id
        AND object_id       = @lv_object_id
        AND last_changed_by = @sy-uname
      ORDER BY last_changed_at DESCENDING
      INTO TABLE @DATA(lt_excel_lastest)
      UP TO 1 ROWS.

    IF lt_excel_lastest IS NOT INITIAL.
      ASSIGN lt_excel_lastest[ 1 ] TO FIELD-SYMBOL(<ls_excel_lastest>).
      IF <ls_excel_lastest>-attachment IS NOT INITIAL.

        MODIFY lt_data FROM VALUE #( BASE CORRESPONDING #( lt_data[ 1 ] )
                                     attachment_exc = <ls_excel_lastest>-attachment
                                     mimetype_exc   = <ls_excel_lastest>-mimetype
                                     filename_exc   = <ls_excel_lastest>-filename )
               INDEX 1 TRANSPORTING attachment_exc mimetype_exc filename_exc.
        IF sy-subrc <> 0.
        ENDIF.
      ENDIF.
    ENDIF.

      lv_object_id = |XML_{ ls_session_pdf-old_id }|.
      " Get attachment lastest by Tcode + User
      SELECT report_id, object_id, attachment, mimetype, filename, last_changed_by, last_changed_at
        FROM ztb_fi_pdf_draf
        WHERE 1               = 1
          AND report_id       = @lv_report_id
          AND object_id       = @lv_object_id
          AND last_changed_by = @sy-uname
        ORDER BY last_changed_at DESCENDING
        INTO TABLE @DATA(lt_xml_lastest)
        UP TO 1 ROWS.

      IF lt_xml_lastest IS NOT INITIAL.
        ASSIGN lt_xml_lastest[ 1 ] TO FIELD-SYMBOL(<ls_xml_lastest>).
        IF <ls_xml_lastest>-attachment IS NOT INITIAL.

          MODIFY lt_data FROM VALUE #( BASE CORRESPONDING #( lt_data[ 1 ] )
                                       attachment_xml = <ls_xml_lastest>-attachment
                                       mimetype_xml   = <ls_xml_lastest>-mimetype
                                       filename_xml   = <ls_xml_lastest>-filename )
                 INDEX 1 TRANSPORTING attachment_xml mimetype_xml filename_xml.
          IF sy-subrc <> 0.
          ENDIF.
        ENDIF.
      ENDIF.



      et_table = lt_data.
      RETURN.
    ENDIF.


    " ----------------------------------------------
    " Tính toán dữ liệu đầu kì, trong kì, cuối kì của tài khoản
    " ----------------------------------------------

    " Đầu kì của tài khoản
*    SELECT FROM zfa_i_zgl05
*      FIELDS glaccount,
*             transactioncurrency,
*             glaccounttext,
*             SUM( amountintransactioncurrency ) AS amount
*      WHERE companycode IN @range_company "=    '1100'
*      and glaccount in @range_glaccount
**   AND fiscalyear  IN @range_year                      "= '2025'
*        AND postingdate  < @lv_posting_date_from
*      GROUP BY glaccount, transactioncurrency, glaccounttext
*      ORDER BY glaccount, transactioncurrency
*      INTO TABLE @DATA(lt_amount_beginning).

    SELECT FROM zfa_i_zgl05
      FIELDS glaccount,
             transactioncurrency,
             glaccounttext,
             SUM( thuvnd ) - SUM( chivnd ) AS amountvnd,
              SUM( thungoaite ) - SUM( chingoaite ) AS amountnt
      WHERE companycode IN @range_company "=    '1100'
      AND glaccount IN @range_glaccount
*   AND fiscalyear  IN @range_year                      "= '2025'
        AND postingdate  < @lv_posting_date_from
      GROUP BY glaccount, transactioncurrency, glaccounttext
      ORDER BY glaccount, transactioncurrency
      INTO TABLE @DATA(lt_amount_beginning).


    " Trong kì của tài khoản
    SELECT FROM @lt_data_glacc AS tb
      FIELDS glaccount,
             transactioncurrency,
             glaccounttext,
             SUM( thuvnd )       AS thuvnd,
             SUM( thungoaite )   AS thungoaite,
             SUM( chivnd )       AS chivnd,
             SUM( chingoaite )   AS chingoaite
      GROUP BY glaccount, transactioncurrency, glaccounttext
      ORDER BY glaccount, transactioncurrency
      INTO TABLE @DATA(lt_amount_current).

    " Cuối kì của tài khoản
    SELECT FROM @lt_data_glacc AS tb
      FIELDS glaccount,
             transactioncurrency,
             glaccounttext,
             SUM( thuvnd - chivnd )         AS tonvnd,
             SUM( thungoaite - chingoaite ) AS tonngoaite
      GROUP BY glaccount, transactioncurrency, glaccounttext
      ORDER BY glaccount, transactioncurrency
      INTO TABLE @DATA(lt_amount_ending).

*    FIELD-SYMBOLS <lfs_amount_beginning> LIKE LINE OF lt_amount_beginning.
*    FIELD-SYMBOLS <lfs_amount_ending> LIKE LINE OF lt_amount_ending.
*    DATA lv_dudaukyvnd     LIKE <lfs_amount_beginning>-amount.
*    DATA lv_dudaukyngoaite LIKE <lfs_amount_beginning>-amount.
*    DATA lv_ducuoikyvnd     LIKE <lfs_amount_ending>-tonvnd.
*    DATA lv_ducuoikyngoaite LIKE <lfs_amount_ending>-tonngoaite.
*
*    IF lt_amount_beginning IS NOT INITIAL.
*      ASSIGN lt_amount_beginning[ transactioncurrency = 'VND' ] TO <lfs_amount_beginning>.
*      IF <lfs_amount_beginning> IS ASSIGNED.
*        lv_dudaukyvnd = <lfs_amount_beginning>-amount.
*        UNASSIGN <lfs_amount_beginning>.
*      ENDIF.
*
*      ASSIGN lt_amount_beginning[ transactioncurrency = 'USD' ] TO <lfs_amount_beginning>.
*      IF <lfs_amount_beginning> IS ASSIGNED.
*        lv_dudaukyngoaite = <lfs_amount_beginning>-amount.
*        UNASSIGN <lfs_amount_beginning>.
*      ENDIF.
*
*    ENDIF.
*
*    IF lt_amount_ending IS NOT INITIAL.
*      ASSIGN lt_amount_ending[ transactioncurrency = 'VND' ] TO <lfs_amount_ending>.
*      IF <lfs_amount_ending> IS ASSIGNED.
*        lv_ducuoikyvnd = <lfs_amount_ending>-tonvnd.
*        UNASSIGN <lfs_amount_ending>.
*      ENDIF.
*
*      ASSIGN lt_amount_ending[ transactioncurrency = 'USD' ] TO <lfs_amount_ending>.
*      IF <lfs_amount_ending> IS ASSIGNED.
*        lv_ducuoikyngoaite = <lfs_amount_ending>-tonngoaite.
*        UNASSIGN <lfs_amount_ending>.
*      ENDIF.
*
*    ENDIF.

    " ----------------------------------------------
    " Binding dữ liệu vào form
    " ----------------------------------------------
    SELECT FROM zfa_i_zgl05_h                          "#EC CI_NOWHERE.
      FIELDS companycode,glaccount, glaccounttext, glaccountlongname
        WHERE companycode IN @range_company
        AND glaccount IN @range_glaccount
      ORDER BY glaccount
      INTO TABLE @DATA(lt_glaccount).

    " binding data to form.

    DATA lt_glaccount_form              LIKE ls_data_form_v1-form-glaccounts.
    DATA ls_glaccount_form              LIKE LINE OF lt_glaccount_form.
    DATA lt_glacc_documents             LIKE ls_glaccount_form-header-documents.
    DATA lt_glaccount_form_ex            LIKE ls_data_form_v1-form-glaccountsexc.
    DATA lS_glaccount_form_ex            TYPE ty_header_v1_ex.

    DATA lv_amount_chi_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_amount_chi_vnd              TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_amount_thu_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_amount_thu_vnd              TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_amount_ton_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_amount_ton_vnd              TYPE p LENGTH 16                        DECIMALS 2.

    DATA lv_ton_vnd_theo_line           TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_ton_usd_theo_line           TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_tondauky_vnd_theo_glaccount TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_tondauky_usd_theo_glaccount TYPE p LENGTH 16                        DECIMALS 2.

    DATA lv_total_amount_chi_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_total_amount_chi_vnd              TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_total_amount_thu_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_total_amount_thu_vnd              TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_total_amount_ton_ngoaite          TYPE p LENGTH 16                        DECIMALS 2.
    DATA lv_total_amount_ton_vnd              TYPE p LENGTH 16                        DECIMALS 2.

    SORT lt_data_glacc BY glaccount postingdate documentdate accountingdocument.
    LOOP AT lt_glaccount INTO DATA(ls_glacc).
      lv_amount_ton_vnd = 0.
      lv_amount_ton_ngoaite = lv_amount_ton_vnd.
      lv_amount_thu_vnd = lv_amount_ton_ngoaite.
      lv_amount_thu_ngoaite = lv_amount_thu_vnd.
      lv_amount_chi_vnd = lv_amount_thu_ngoaite.
      lv_amount_chi_ngoaite = lv_amount_chi_vnd
    .

      lv_tondauky_vnd_theo_glaccount = 0.
      lv_tondauky_usd_theo_glaccount = 0.

      " Tồn VND đầu kì kỳ
      READ TABLE lt_amount_beginning WITH KEY glaccount           = ls_glacc-glaccount
                                              transactioncurrency = 'VND' INTO DATA(ls_amount_beginning_vnd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tondauky_vnd_theo_glaccount = ls_amount_beginning_vnd-amountvnd.
      ENDIF.

      " Tồn USD đầu kì kỳ
      READ TABLE lt_amount_beginning WITH KEY glaccount           = ls_glacc-glaccount
                                              transactioncurrency = 'USD' INTO DATA(ls_amount_beginning_usd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tondauky_usd_theo_glaccount = ls_amount_beginning_usd-amountnt.
        lv_tondauky_vnd_theo_glaccount = ls_amount_beginning_usd-amountvnd.
      ENDIF.

      lv_amount_ton_vnd += lv_tondauky_vnd_theo_glaccount.

      " Tổng thu, chi VND trong kỳ
      READ TABLE lt_amount_current WITH KEY glaccount           = ls_glacc-glaccount
                                            transactioncurrency = 'VND' INTO DATA(ls_amount_current_vnd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_chi_vnd = abs( ls_amount_current_vnd-chivnd ).
        lv_amount_thu_vnd = ls_amount_current_vnd-thuvnd.

        lv_total_amount_chi_vnd += abs( ls_amount_current_vnd-chivnd ).
        lv_total_amount_thu_vnd  += ls_amount_current_vnd-thuvnd.
      ENDIF.

      " Tổng thu, chi USD trong kỳ
      READ TABLE lt_amount_current WITH KEY glaccount           = ls_glacc-glaccount
                                            transactioncurrency = 'USD' INTO DATA(ls_amount_current_usd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_chi_ngoaite = abs( ls_amount_current_usd-chingoaite ).
        lv_amount_thu_ngoaite = ls_amount_current_usd-chingoaite.


        lv_amount_chi_vnd = abs( ls_amount_current_usd-chivnd ).
        lv_amount_thu_vnd = ls_amount_current_usd-thuvnd.
        lv_total_amount_chi_ngoaite += abs( ls_amount_current_usd-chingoaite ).
        lv_total_amount_thu_ngoaite  += ls_amount_current_usd-chingoaite.
      ENDIF.

      " Tồn VND cuối kỳ
      READ TABLE lt_amount_ending WITH KEY glaccount           = ls_glacc-glaccount
                                           transactioncurrency = 'VND' INTO DATA(ls_amount_ending_vnd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_ton_vnd = ls_amount_ending_vnd-tonvnd.
        lv_total_amount_ton_vnd  += lv_amount_ton_vnd.
      ENDIF.


      " Tồn USD cuối kỳ
      READ TABLE lt_amount_ending WITH KEY glaccount           = ls_glacc-glaccount
                                           transactioncurrency = 'USD' INTO DATA(ls_amount_ending_usd) BINARY SEARCH.
      IF sy-subrc = 0.

        lv_amount_ton_ngoaite = ls_amount_ending_usd-tonngoaite.
        lv_amount_ton_vnd = ls_amount_ending_usd-tonvnd.
        lv_total_amount_ton_vnd  += lv_amount_ton_vnd.
      ENDIF.
      lv_amount_ton_ngoaite += lv_tondauky_usd_theo_glaccount.
      lv_total_amount_ton_ngoaite  += lv_amount_ton_ngoaite.

      lv_ton_vnd_theo_line = lv_tondauky_vnd_theo_glaccount * 100.
      lv_ton_usd_theo_line = lv_tondauky_usd_theo_glaccount.


      LOOP AT lt_data_glacc INTO DATA(ls_data_glacc) WHERE glaccount = ls_glacc-glaccount.
        " Tồn của mỗi line tính như sau
        " Tồn của line trước  + thu (line hiện tại) - chi (line hiện tại)
        ls_data_glacc-thuvnd *= 100.
        ls_data_glacc-chivnd *= 100.

        lv_ton_vnd_theo_line += ls_data_glacc-thuvnd - ls_data_glacc-chivnd.
        lv_ton_usd_theo_line += ls_data_glacc-thungoaite - ls_data_glacc-chingoaite.
        APPEND VALUE #( item = VALUE #( posting_date            = ls_data_glacc-postingdate
                                        document                = ls_data_glacc-accountingdocument
                                        document_date           = ls_data_glacc-documentdate
                                        document_item_text      = ls_data_glacc-documentitemtext
                                        offsetting_account      = |{ ls_data_glacc-offsettingaccount ALPHA = OUT }|
                                        offsetting_account_name = ls_data_glacc-offsettingaccountname
                                        reconciliation_account  = ls_data_glacc-reconciliationaccount
                                        currency                = ls_data_glacc-transactioncurrency
                                        absolute_exchange_rate  = ls_data_glacc-absoluteexchangerate

                                        debit_amount            = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( ls_data_glacc-thungoaite )
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                                        credit_amount           = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( ls_data_glacc-chingoaite )
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                                        end_amount              = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = lv_ton_usd_theo_line
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )

                                        debit_amount_vnd        = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( ls_data_glacc-thuvnd )
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                                        credit_amount_vnd       = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( ls_data_glacc-chivnd )
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                                        end_amount_vnd          = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = lv_ton_vnd_theo_line
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )

                                         document_date_doc           = |{ lv_posting_date_from DATE = USER }|
                                         posting_date_doc            = |{ ls_data_glacc-postingdate DATE = USER }|


                                      zlevel = 'B'  ) )

               TO lt_glacc_documents.

        " Update lt_data
      ENDLOOP.

      IF lt_glacc_documents IS NOT INITIAL.
        lv_amount_ton_vnd  = lv_total_amount_ton_vnd + lv_tondauky_vnd_theo_glaccount.
        APPEND VALUE #(
            header = VALUE #( glaccount         = ls_glacc-glaccount
                              glaccounttext     = |{ ls_glacc-glaccount } - { ls_glacc-glaccountlongname }|
                              glaccountlongname = ls_glacc-glaccountlongname
                              begin_amount      = zcl_currency_formatter=>format_currency(
                                                      iv_amount              = lv_tondauky_usd_theo_glaccount
                                                      iv_currency            = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              begin_amount_vnd  = zcl_currency_formatter=>format_currency(
                                                      iv_amount              = lv_tondauky_vnd_theo_glaccount * 100
                                                      iv_currency            = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              debit_amount      = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_thu_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              debit_amount_vnd  = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_thu_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              credit_amount     = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_chi_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              credit_amount_vnd = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_chi_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              end_amount        = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_ton_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              end_amount_vnd    = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_ton_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              documents         = lt_glacc_documents

                              zlevel            = 'A'
                              ) )
               TO lt_glaccount_form.

*ViHT9/20.04.2026/Update ZGL05 excel
 lS_glaccount_form_ex = VALUE #( glaccount         = ls_glacc-glaccount
                              glaccounttext     = |{ ls_glacc-glaccount } - { ls_glacc-glaccountlongname }|
                              glaccountlongname = ls_glacc-glaccountlongname
                              begin_amount      = zcl_currency_formatter=>format_currency(
                                                      iv_amount              = lv_tondauky_usd_theo_glaccount
                                                      iv_currency            = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              begin_amount_vnd  = zcl_currency_formatter=>format_currency(
                                                      iv_amount              = lv_tondauky_vnd_theo_glaccount * 100
                                                      iv_currency            = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              debit_amount      = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_thu_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              debit_amount_vnd  = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_thu_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              credit_amount     = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_chi_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              credit_amount_vnd = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_chi_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                              end_amount        = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_ton_ngoaite
                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                              end_amount_vnd    = zcl_currency_formatter=>format_currency(
                                                      iv_amount   = lv_amount_ton_vnd * 100
                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )


                              ).
     lS_glaccount_form_ex-zlevel            = 'A'.
APPEND lS_glaccount_form_ex TO lt_glaccount_form_ex.
    lS_glaccount_form_ex-sddktext = 'Số dư đầu kỳ'.
     lS_glaccount_form_ex-zlevel            = 'C'.
    APPEND lS_glaccount_form_ex TO lt_glaccount_form_ex.
    lS_glaccount_form_ex-pstktext = 'Phát sinh trong kỳ'.
     lS_glaccount_form_ex-zlevel            = 'D'.
    APPEND lS_glaccount_form_ex TO lt_glaccount_form_ex.
    lS_glaccount_form_ex-sdcktext = 'Số dư cuối kỳ'.
     lS_glaccount_form_ex-zlevel            = 'E'.
    APPEND lS_glaccount_form_ex TO lt_glaccount_form_ex.

        lt_glaccount_form_ex = VALUE ty_glaccountsexc(
  BASE lt_glaccount_form_ex
*    ( LINES OF VALUE ty_glaccountsexc(
*      FOR ls_gl IN lt_glaccount_form
*      ( CORRESPONDING #( ls_gl-header ) )
*    ) )
  ( LINES OF VALUE ty_glaccountsexc(
      FOR wa IN lt_glacc_documents
      (
        CORRESPONDING #( wa-item )

      )
    ) )
).

*ViHT9/20.04.2026/Update ZGL05 excel
        CLEAR lt_glacc_documents.
      ENDIF.

    ENDLOOP.

    DATA(lt_string_glaccount) = VALUE string_table( FOR ls_gl IN lt_glaccount_form
                                                    ( ls_gl-header-glaccount ) ).
    DATA(glaccount_list) = xco_cp=>strings( lt_string_glaccount )->join( |, | )->value.
*    REPLACE ALL OCCURRENCES OF ',' IN glaccount_list WITH ', '.

    IF lines( lt_glaccount_form ) = 1.
      glaccount_list = |{ lt_glaccount_form[ 1 ]-header-glaccount } - { lt_glaccount_form[ 1 ]-header-glaccountlongname }|.
    ENDIF.
    lv_total_amount_ton_vnd = lv_total_amount_ton_vnd + lv_tondauky_vnd_theo_glaccount.
*ViHT9/28.04.2026/ Update ZGL05 PTB_SAP_2025_TH_DA-409

          lo_logo->get_logo( EXPORTING iv_company = CONV bukrs( range_company[ 1 ]-low ) IMPORTING lv_logo = lv_logo ).
          IF lv_logo IS INITIAL.
            lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
          ENDIF.


      SELECT
                _company~tencty_vn,
          _company~diachi_vn23 as diachi_vn,
          _company~mst
        FROM ZCDS_COMPANY as _company
        WHERE CompanyCode       IN @range_company
        INTO TABLE @DATA(lt_COMPANY)
        UP TO 1 ROWS.
   ASSIGN lt_COMPANY[ 1 ] TO FIELD-SYMBOL(<lfs_COMPANY>).
*ViHT9/28.04.2026/ Update ZGL05 PTB_SAP_2025_TH_DA-409

    "------ new form
    ls_data_form_v1-form = VALUE #(
        title           = 'SỔ QUỸ TIỀN MẶT'
        date_from_to    = |Từ ngày { lv_posting_date_from DATE = USER } đến { COND string(
    WHEN lv_posting_date_to IS INITIAL
    THEN |{ lv_posting_date_from DATE = USER }|
    ELSE |{ lv_posting_date_to DATE = USER }|
  ) }|
        title_glaccount = |Tài khoản: { glaccount_list }|
        from            = lv_posting_date_from
        to              = COND d( WHEN lv_posting_date_to IS INITIAL THEN lv_posting_date_from ELSE lv_posting_date_to )
        glaccounts      = lt_glaccount_form
        glaccountsexc      = lt_glaccount_form_ex
        zlogo              = lv_logo
        tencty_vn          = <lfs_COMPANY>-tencty_vn
        diachi_vn          = <lfs_COMPANY>-diachi_vn
        mst                = <lfs_COMPANY>-mst
                                    credit_amount            = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( lv_total_amount_chi_ngoaite )
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                                        debit_amount           = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( lv_total_amount_thu_ngoaite )
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )
                                        ton_amount              = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = lv_total_amount_ton_ngoaite
                                                                      iv_currency = 'USD'
                                                      iv_is_negative_bracket = abap_true )

                                        credit_amount_vnd        = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( lv_total_amount_chi_vnd * 100 )
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                                        debit_amount_vnd       = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = CONV #( lv_total_amount_thu_vnd * 100 )
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true )
                                        ton_amount_vnd         = zcl_currency_formatter=>format_currency(
                                                                      iv_amount   = lv_total_amount_ton_vnd * 100
                                                                      iv_currency = 'VND'
                                                      iv_is_negative_bracket = abap_true ) ).

    DATA lv_timestamp    TYPE timestamp.
    DATA lv_filename_xml TYPE string.
    DATA lv_filename_pdf TYPE string.
    DATA lv_pdf_xstring  TYPE xstring.
    DATA lv_xml_xstring  TYPE xstring.

    render_form( EXPORTING ia_abap = ls_data_form_v1
                 IMPORTING ev_pdf  = lv_pdf_xstring
                           ev_xml  = lv_xml_xstring ).

    GET TIME STAMP FIELD lv_timestamp.
    lv_filename_pdf = |{ lv_timestamp }.pdf|.
    lv_filename_xml = |{ lv_timestamp }.xml|.
*    TRY.
*        " TODO: variable is assigned but never used (ABAP cleaner)
*        DATA(lv_uuid_c32) = cl_system_uuid=>create_uuid_c32_static( ).
*        ls_session_pdf-new_id = CONV string( lv_uuid_c32 ).
*      CATCH cx_uuid_error.
*        RETURN.
*    ENDTRY.

    ls_session_pdf-old_id = sy-uname.
    ls_session_pdf-new_id = sy-uname.
    "export Excel attachment
    DATA: lv_attacment_exc TYPE zde_attachment,
          lv_report        TYPE char72 VALUE 'ZGL05',
          lv_template      TYPE char72 VALUE 'ZGL05_EXC'.


    ls_data_form_v1-form-title = 'SỔ QUỸ TIỀN MẶT'.
    ls_data_form_v1-form-ngs_h   = 'Ngày ghi sổ'.
    ls_data_form_v1-form-NCT_H  = 'Ngày chứng từ'.
    ls_data_form_v1-form-SCT_H    = 'Số chứng từ'.
    ls_data_form_v1-form-dg_h     = 'Diễn giải'.

    ls_data_form_v1-form-st_h    = 'Số tiền'.
    ls_data_form_v1-form-thu_h    = 'Thu'.
    ls_data_form_v1-form-chi_h    = 'Chi'.
    ls_data_form_v1-form-ton_h    = 'Tồn'.

    ls_data_form_v1-form-tcktext  = 'Tổng cuối kỳ'.

    ls_data_form_v1-form-nl_h    = 'Người lập'.
    ls_data_form_v1-form-ktt_h   = 'Kế toán trưởng'.
    ls_data_form_v1-form-gd_h    = 'Giám đốc'.

    ls_data_form_v1-form-nlky_h  = '(Ký, họ tên)'.
    ls_data_form_v1-form-kttky_h = '(Ký, họ tên)'.
    ls_data_form_v1-form-gdky_h  = '(Ký, họ tên, đóng dấu)'.

   ls_data_form_v1-form-diachi_vn = <lfs_COMPANY>-diachi_vn.
   ls_data_form_v1-form-tencty_vn = <lfs_COMPANY>-tencty_vn.
   ls_data_form_v1-form-mst = <lfs_COMPANY>-mst.

    APPEND ls_data_form_v1-form TO lt_data_form_v1 .
    DATA: lo_excel       TYPE REF TO zcl_export_excel_xlsx.

    lo_excel = NEW #( ).
    lo_excel->export_excel( EXPORTING
                            iv_template = lv_template
                            iv_report = lv_report
                            it_data = lt_data_form_v1
                            iv_generate = abap_false
                            IMPORTING lv_context = lv_attacment_exc ).

    GET TIME STAMP FIELD DATA(lv_timestamp_ex).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CASE <lfs_data>-transactioncurrency.

        WHEN 'VND'.
          <lfs_data>-dudaukyvnd = lv_tondauky_vnd_theo_glaccount.
          <lfs_data>-tonvnd     = lv_amount_ton_vnd.
        WHEN OTHERS.
          <lfs_data>-dudaukyngoaite = lv_tondauky_usd_theo_glaccount.
          <lfs_data>-tonngoaite     = lv_amount_ton_ngoaite.
      ENDCASE.

      <lfs_data>-attachment     = lv_pdf_xstring.
      <lfs_data>-mimetype       = 'application/pdf'.
      <lfs_data>-filename       = lv_filename_pdf.

      <lfs_data>-attachment_xml = lv_xml_xstring.
      <lfs_data>-mimetype_xml   = 'application/xml'.
      <lfs_data>-filename_xml   = lv_filename_xml.
      <lfs_data>-pdfid          = ls_session_pdf-new_id.

      <lfs_data>-attachment_exc = lv_attacment_exc.
      <lfs_data>-mimetype_exc = 'application/vnd.ms-excel'.
      <lfs_data>-filename_exc = |{ lv_timestamp_ex }.xlsx|.

    ENDLOOP.

    SORT lt_data BY sourceledger
                    companycode
                    fiscalyear
                    ledger
                    accountingdocument.
    DELETE ADJACENT DUPLICATES FROM lt_data COMPARING sourceledger
    companycode
    fiscalyear
    ledger
    accountingdocument.

    et_table = lt_data.

    " Upsert attachment
    IF lv_pdf_xstring IS NOT INITIAL.
      upsert_attachment( is_large_object = VALUE #( attachment = lv_pdf_xstring
                                                    mimetype   = 'application/pdf'
                                                    filename   = lv_filename_pdf
                                                    attachment_exc = lv_attacment_exc )
                         is_session      = ls_session_pdf ).
    ENDIF.
    IF lv_xml_xstring IS NOT INITIAL.
      upsert_attachment_xml( is_large_object = VALUE #( attachment = lv_xml_xstring
                                                        mimetype   = 'application/xml'
                                                        filename   = lv_filename_xml )
                             is_session      = ls_session_pdf  ).
    ENDIF.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    DATA: lt_data_output TYPE tt_data_output.
    DATA: range_large_object TYPE RANGE OF string.
    range_large_object = VALUE #( sign = 'I' option = 'EQ'
        ( low = 'ATTACHMENT' )
        ( low = 'FILENAME' )
        ( low = 'MIMETYPE' )
        ( low = 'ATTACHMENT_XML' )
        ( low = 'FILENAME_XML' )
        ( low = 'MIMETYPE_XML' )
        ( low = 'ATTACHMENT_EXC' )
        ( low = 'FILENAME_EXC' )
        ( low = 'MIMETYPE_EXC' )
    ).

    CHECK io_request->is_data_requested( ).
    DATA(rt_requested_elements) = io_request->get_requested_elements( ).
    DATA(rt_element_copy) =  rt_requested_elements .
    DATA(ro_aggregation) = io_request->get_aggregation( ).

    DATA(rt_aggregated_elements) = ro_aggregation->get_aggregated_elements( ).
    DATA(rt_grouped_elements) = ro_aggregation->get_grouped_elements( ).

    IF lines( rt_element_copy ) = 3.
      LOOP AT rt_element_copy INTO DATA(field_name).
        IF field_name IN range_large_object.
          is_large_object = abap_true.
        ELSE.
          is_large_object = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    me->get_data(
      EXPORTING
        io_request = io_request
      IMPORTING
        et_table   = lt_data_output
    ).
*    check lines( rt_element_copy ) = 3.

    io_response->set_data( lt_data_output ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data_output ) ).
    ENDIF.


  ENDMETHOD.


  METHOD render_form.
    TRY.
        "Render Form

        "------- OLD -----
*        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
*              iv_use_destination_service = abap_false
*              iv_service_instance_name   = 'ZADSTEMPLSTORE'
*            ).
*        DATA(ls_template) = lo_store->get_template_by_name(
*        iv_get_binary     = abap_true
*        iv_form_name      = 'ZFA_ZGL05' "<= form object in template store
*        iv_template_name  = 'ZFA_ZGL05_TML_DEV' "<= template (in form object) that should be used
*      ).

        "------- NEW -----
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client( ).

        DATA(ls_template_new) = lo_store->get_template_by_tcode(
          iv_tcode = 'ZGL05'
        ).


        DATA: lv_xml_xstring TYPE xstring,
              lv_xml         TYPE string,
              lv_xml_string  TYPE string.

        abap2xml(
          EXPORTING
            ia_abap        = ia_abap
          IMPORTING
            ev_xml_string  = lv_xml_string
            ev_xml_xstring = lv_xml_xstring
        ).

        cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xml_xstring
                                              iv_xdp_layout   = ls_template_new-xdp_template
                                              iv_locale       = 'en_US'
                                              is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                    IMPORTING
                                    " TODO: variable is assigned but never used (ABAP cleaner)
                                              ev_trace_string = DATA(lv_trace)
                                    " TODO: variable is assigned but never used (ABAP cleaner)
                                              ev_pdf          = DATA(lv_pdf) ).
        ev_pdf = lv_pdf.

      CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util INTO DATA(exc).
        "Exception occurred whiling render_form
        DATA(lv_error_message) = exc->get_text( ).
    ENDTRY.

    ev_xml = lv_xml_xstring.
  ENDMETHOD.


  METHOD upsert_attachment.
    DATA: lv_timestampl    TYPE timestampl,
          lv_error_message TYPE string,
          lv_object_id     TYPE string,
          lv_report_id     TYPE string.

    DATA:
      ls_pdf_draft TYPE ztb_fi_pdf_draf,
      lt_pdf_draft TYPE TABLE OF ztb_fi_pdf_draf.

    lv_report_id = |ZFA_ZGL05|.
*    lv_object_id = |ZGL05_{ sy-uname }|.

    GET TIME STAMP FIELD lv_timestampl.

    IF is_session-old_id IS NOT INITIAL.

      lv_object_id = |PDF_{ is_session-old_id }|.
      " Update or create Attachment
      SELECT report_id, object_id, attachment, mimetype, filename, last_changed_by, last_changed_at
        FROM ztb_fi_pdf_draf
        WHERE 1               = 1
          AND report_id       = @lv_report_id
          AND object_id       = @lv_object_id
          AND last_changed_by = @sy-uname
        ORDER BY last_changed_at DESCENDING
        INTO CORRESPONDING FIELDS OF TABLE @lt_pdf_draft
        UP TO 1 ROWS.

      IF lt_pdf_draft IS NOT INITIAL.
        ASSIGN lt_pdf_draft[ 1 ] TO FIELD-SYMBOL(<lfs_pdf_draft>).
        UPDATE ztb_fi_pdf_draf
        SET attachment = @is_large_object-attachment,
            filename = @is_large_object-filename,
            mimetype = @is_large_object-mimetype,
            last_changed_at = @lv_timestampl,
            last_changed_by = @sy-uname,
            local_last_changed_at = @lv_timestampl
        WHERE report_id       = @<lfs_pdf_draft>-report_id
          AND object_id       = @<lfs_pdf_draft>-object_id
          AND last_changed_by = @<lfs_pdf_draft>-last_changed_by.
        IF sy-subrc <> 0.
          " Error updating ztb_fi_pdf_draf
          lv_error_message = 'Error updating ztb_fi_pdf_draf'.
        ENDIF.
      ENDIF.

    ENDIF.

    IF is_session-old_id IS INITIAL OR lt_pdf_draft IS INITIAL.
      lv_object_id = |PDF_{ is_session-new_id }|.
      ls_pdf_draft = VALUE #( report_id             = lv_report_id
                              object_id             = lv_object_id
                              attachment            = is_large_object-attachment
                              filename              = is_large_object-filename
                              mimetype              = is_large_object-mimetype
                              created_by            = sy-uname
                              created_at            = lv_timestampl
                              last_changed_by       = sy-uname
                              last_changed_at       = lv_timestampl
                              local_last_changed_at = lv_timestampl ).
      INSERT INTO ztb_fi_pdf_draf VALUES @ls_pdf_draft.
      IF sy-subrc <> 0.
        " Error inserting into ztb_fi_pdf_draf
        lv_error_message = 'Error inserting into ztb_fi_pdf_draf'.
      ENDIF.
    ENDIF.

*ViHT9/20.04.2026/Update ZGL05 excel
    DATA: lv_date_after TYPE datum.
    lv_date_after = syst-datum - 1.
    DELETE FROM ztb_fifa_excel WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).

    DATA(ls_data) = VALUE ztb_fifa_excel(
          object_id = lv_object_id
          report_id = lv_report_id
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.xlsx|
          mimetype =  'application/vnd.ms-excel'
          attachment = is_large_object-attachment_exc

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum
last_changed_by       = sy-uname
        ).
    INSERT ztb_fifa_excel FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_fifa_excel FROM @ls_data.
    ENDIF.
*ViHT9/20.04.2026/Update ZGL05 excel
*    IF lt_pdf_draft IS NOT INITIAL.
*      GET TIME STAMP FIELD lv_timestampl.
*      READ TABLE lt_pdf_draft ASSIGNING FIELD-SYMBOL(<lfs_pdf_draft>) INDEX 1.
*      UPDATE ztb_fi_pdf_draf
*      SET attachment = @is_large_object-attachment,
*          filename = @is_large_object-filename,
*          mimetype = @is_large_object-mimetype,
*          last_changed_at = @lv_timestampl,
*          last_changed_by = @sy-uname,
*          local_last_changed_at = @lv_timestampl
*      WHERE report_id       = @<lfs_pdf_draft>-report_id
*        AND object_id = @<lfs_pdf_draft>-object_id
*        AND last_changed_by = @<lfs_pdf_draft>-last_changed_by.
*      IF sy-subrc <> 0.
*        "Error updating ztb_fi_pdf_draf
*        lv_error_message = 'Error updating ztb_fi_pdf_draf'.
*      ENDIF.
*    ELSE.
*
*      ls_pdf_draft = VALUE #( report_id             = lv_report_id
*                              object_id             = lv_object_id
*                              attachment            = is_large_object-attachment
*                              filename              = is_large_object-filename
*                              mimetype              = is_large_object-mimetype
*                              created_by       = sy-uname
*                              created_at      = lv_timestampl
*                              last_changed_by       = sy-uname
*                              last_changed_at       = lv_timestampl
*                              local_last_changed_at = lv_timestampl ).
*      INSERT INTO ztb_fi_pdf_draf VALUES @ls_pdf_draft.
*      IF sy-subrc <> 0.
*        "Error inserting into ztb_fi_pdf_draf
*        lv_error_message = 'Error inserting into ztb_fi_pdf_draf'.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.


  METHOD upsert_attachment_xml.
    DATA: lv_timestampl    TYPE timestampl,
          lv_error_message TYPE string,
          lv_object_id     TYPE string,
          lv_report_id     TYPE string.


    DATA:
      ls_pdf_draft TYPE ztb_fi_pdf_draf,
      lt_pdf_draft TYPE TABLE OF ztb_fi_pdf_draf.

    lv_report_id = |ZFA_ZGL05|.
*    lv_object_id = |ZGL05_XML_{ sy-uname }|.
*    ----------------------------------

    GET TIME STAMP FIELD lv_timestampl.

    IF is_session-old_id IS NOT INITIAL.

      lv_object_id = |XML_{ is_session-old_id }|.
      " Update or create Attachment
      SELECT report_id, object_id, attachment, mimetype, filename, last_changed_by, last_changed_at
        FROM ztb_fi_pdf_draf
        WHERE 1               = 1
          AND report_id       = @lv_report_id
          AND object_id       = @lv_object_id
          AND last_changed_by = @sy-uname
        ORDER BY last_changed_at DESCENDING
        INTO CORRESPONDING FIELDS OF TABLE @lt_pdf_draft
        UP TO 1 ROWS.

      IF lt_pdf_draft IS NOT INITIAL.
        ASSIGN lt_pdf_draft[ 1 ] TO FIELD-SYMBOL(<lfs_pdf_draft>).
        UPDATE ztb_fi_pdf_draf
        SET attachment = @is_large_object-attachment,
            filename = @is_large_object-filename,
            mimetype = @is_large_object-mimetype,
            last_changed_at = @lv_timestampl,
            last_changed_by = @sy-uname,
            local_last_changed_at = @lv_timestampl
        WHERE report_id       = @<lfs_pdf_draft>-report_id
          AND object_id       = @<lfs_pdf_draft>-object_id
          AND last_changed_by = @<lfs_pdf_draft>-last_changed_by.
        IF sy-subrc <> 0.
          " Error updating ztb_fi_pdf_draf
          lv_error_message = 'Error updating ztb_fi_pdf_draf'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF is_session-old_id IS INITIAL OR lt_pdf_draft IS INITIAL.
      lv_object_id = |XML_{ is_session-new_id }|.
      ls_pdf_draft = VALUE #( report_id             = lv_report_id
                              object_id             = lv_object_id
                              attachment            = is_large_object-attachment
                              filename              = is_large_object-filename
                              mimetype              = is_large_object-mimetype
                              created_by            = sy-uname
                              created_at            = lv_timestampl
                              last_changed_by       = sy-uname
                              last_changed_at       = lv_timestampl
                              local_last_changed_at = lv_timestampl ).
      INSERT INTO ztb_fi_pdf_draf VALUES @ls_pdf_draft.
      IF sy-subrc <> 0.
        " Error inserting into ztb_fi_pdf_draf
        lv_error_message = 'Error inserting into ztb_fi_pdf_draf'.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
