CLASS zcl_fa_zgl05_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    INTERFACES if_rap_query_provider .

    TYPES: BEGIN OF ty_data_output.
    TYPES: dutrongkyvnd   TYPE p LENGTH 16 DECIMALS 2,
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
           END OF ty_data_output.

    TYPES: tt_data_output TYPE STANDARD TABLE OF zi_fa_zgl05_ex.


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
             END OF header,
           END OF ty_header_v1.

    TYPES: BEGIN OF ty_form_v1,
             BEGIN OF form,
               title           TYPE string,
               date_from_to    TYPE string,
               from            TYPE string,
               to              TYPE string,
               title_glaccount TYPE string,
               glaccounts      TYPE STANDARD TABLE OF ty_header_v1 WITH EMPTY KEY,
             END OF form,
           END OF ty_form_v1.

* ------------------------------------------------------------------------
    TYPES: BEGIN OF ty_large_object,
             attachment TYPE xstring,
             mimetype   TYPE string,
             filename   TYPE string,
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
    DATA: ls_data_form_v1 TYPE ty_form_v1.
    DATA: is_large_object TYPE abap_boolean VALUE abap_false.

    METHODS get_data
      IMPORTING io_request TYPE REF TO if_rap_query_request
      EXPORTING et_table   TYPE tt_data_output
      .

    METHODS dynamic_data
      IMPORTING i_data         TYPE any
                i_name_mapping TYPE /ui2/cl_json=>name_mappings OPTIONAL
                i_kind_type    TYPE c DEFAULT cl_abap_typedescr=>typekind_struct2
      CHANGING  co_writer      TYPE REF TO if_sxml_writer OPTIONAL.


    METHODS format_negative_number
      IMPORTING iv_value        TYPE ty_dec_2
                i_negative      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_value) TYPE string.
    METHODS format_negative_number_output
      IMPORTING iv_value        TYPE ty_dec_2
                i_negative      TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_value) TYPE string.
ENDCLASS.



CLASS ZCL_FA_ZGL05_EX IMPLEMENTATION.


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
    DATA lt_data_ex                 TYPE tt_data_output.
    DATA ls_data_ex  TYPE  zi_fa_zgl05_ex.

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

    DATA lv_orderby TYPE string VALUE `COMPANYCODE`.
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
        WHEN 'PDFID'.
          CHECK ls_range-range IS NOT INITIAL.
          ls_session_pdf-old_id = ls_range-range[ 1 ]-low.
          DATA(origin_condition_pdf) = |PDFID = '{ ls_session_pdf-old_id }'|.
          REPLACE ALL OCCURRENCES OF origin_condition_pdf IN lv_conditions WITH '1 = 1'.
  WHEN 'GLACCOUNT'.
          range_glaccount = ls_range-range.
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

select
CompanyCode
from I_CompanyCode
where CompanyCode is not INITIAL
into table @data(lt_companys).

LOOP AT lt_companys INTO DATA(ls_comp).
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD ls_comp-CompanyCode
    ID 'ACTVT' FIELD '03'.
  IF sy-subrc = 0.
APPEND VALUE #( sign   = 'I'
                    option = 'EQ'
                    low    = ls_comp-CompanyCode ) TO lr_bukrs.
  ENDIF.
ENDLOOP.

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

             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS beginningbalance,
             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS currentbalance,
             ( amountintransactioncurrency - amountintransactioncurrency )                                                AS endingbalance,
             @sy-datum(4)                                                                                                 AS currentyear
      WHERE (lv_conditions)

      ORDER BY (lv_orderby) " glaccount ASCENDING, thungoaite, thuvnd DESCENDING "(lv_orderby)
      INTO TABLE @DATA(lt_data_glacc)
      UP TO @lv_top ROWS
      OFFSET @lv_skip.

    delETE lt_data_glacc where companycode not in lr_bukrs.
    IF lt_data_glacc IS INITIAL.
      RETURN.
    ENDIF.
    lt_data = CORRESPONDING #( lt_data_glacc ).

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
*        AND fiscalyear  IN @range_year                      "= '2025'
*        and GLAccount in @range_glaccount
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

    " ----------------------------------------------
    " Binding dữ liệu vào form
    " ----------------------------------------------
    SELECT FROM zfa_i_zgl05_h                          "#EC CI_NOWHERE.
      FIELDS glaccount, glaccounttext, glaccountlongname
              WHERE companycode IN @range_company
        AND glaccount IN @range_glaccount
      ORDER BY glaccount
      INTO TABLE @DATA(lt_glaccount).

    " binding data to form.
    DATA lt_glaccount_form              LIKE ls_data_form_v1-form-glaccounts.
    DATA ls_glaccount_form              LIKE LINE OF lt_glaccount_form.
    DATA lt_glacc_documents             LIKE ls_glaccount_form-header-documents.

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

    SORT lt_data_glacc BY glaccount.
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
      READ TABLE lt_amount_beginning WITH KEY glaccount           = ls_glacc-glaccount INTO DATA(ls_amount_beginning) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_tondauky_vnd_theo_glaccount = ls_amount_beginning-amountvnd.
        lv_tondauky_usd_theo_glaccount = ls_amount_beginning-amountnt.
      ENDIF.

*      " Tồn USD đầu kì kỳ
*      READ TABLE lt_amount_beginning WITH KEY glaccount           = ls_glacc-glaccount
*                                              transactioncurrency = 'USD' INTO DATA(ls_amount_beginning_usd) BINARY SEARCH.
*      IF sy-subrc = 0.
*        lv_tondauky_usd_theo_glaccount = ls_amount_beginning_usd-amount.
*      ENDIF.

      " Tổng thu, chi VND trong kỳ
      READ TABLE lt_amount_current WITH KEY glaccount           = ls_glacc-glaccount
                                            transactioncurrency = 'VND' INTO DATA(ls_amount_current_vnd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_chi_vnd = abs( ls_amount_current_vnd-chivnd ).
        lv_amount_thu_vnd = ls_amount_current_vnd-thuvnd.
      ENDIF.

      " Tổng thu, chi USD trong kỳ
      READ TABLE lt_amount_current WITH KEY glaccount           = ls_glacc-glaccount
                                            transactioncurrency = 'USD' INTO DATA(ls_amount_current_usd) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_chi_ngoaite = abs( ls_amount_current_usd-chingoaite ).
        lv_amount_thu_ngoaite = ls_amount_current_usd-thungoaite.
      ENDIF.

      " Tồn VND cuối kỳ
      READ TABLE lt_amount_ending WITH KEY glaccount           = ls_glacc-glaccount INTO DATA(ls_amount_ending) BINARY SEARCH.
      IF sy-subrc = 0.
        lv_amount_ton_vnd = ls_amount_ending-tonvnd.
        lv_amount_ton_ngoaite = ls_amount_ending-tonngoaite.
      ENDIF.


*      " Tồn USD cuối kỳ
*      READ TABLE lt_amount_ending WITH KEY glaccount           = ls_glacc-glaccount
*                                           transactioncurrency = 'USD' INTO DATA(ls_amount_ending_usd) BINARY SEARCH.
*      IF sy-subrc = 0.
*        lv_amount_ton_ngoaite = ls_amount_ending_usd-tonngoaite.
*      ENDIF.


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
                                                      iv_is_negative_bracket = abap_true ) ) )

               TO lt_glacc_documents.

        " Update lt_data
      ENDLOOP.

      IF lt_glacc_documents IS NOT INITIAL.
lv_amount_ton_vnd = lv_amount_ton_vnd + lv_tondauky_vnd_theo_glaccount.
lv_amount_ton_ngoaite += lv_tondauky_usd_theo_glaccount.
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
                              documents         = lt_glacc_documents ) )
               TO lt_glaccount_form.

        CLEAR lt_glacc_documents.
      ENDIF.

    ENDLOOP.
DATA lv_stt TYPE i.

LOOP AT lt_glaccount_form ASSIGNING FIELD-SYMBOL(<lfs_glaccount_form>).

  "-----------------------------------------
  " Tiêu đề tài khoản
  "-----------------------------------------
  lv_stt += 1.
  ls_data_ex-stt = lv_stt.
  ls_data_ex-Des = <lfs_glaccount_form>-header-glaccounttext.
  APPEND ls_data_ex TO lt_data_ex.
  CLEAR ls_data_ex.

  "-----------------------------------------
  " Số dư đầu kỳ
  "-----------------------------------------
  lv_stt += 1.
  ls_data_ex-stt = lv_stt.
  ls_data_ex-Des = 'Số dư đầu kỳ'.

  ls_data_ex-TonVND_char     = <lfs_glaccount_form>-header-begin_amount_vnd.
  ls_data_ex-TonNgoaiTe_char = <lfs_glaccount_form>-header-begin_amount.
  APPEND ls_data_ex TO lt_data_ex.
  CLEAR ls_data_ex.

  "-----------------------------------------
  " Chi tiết chứng từ
  "-----------------------------------------
  LOOP AT <lfs_glaccount_form>-header-documents ASSIGNING FIELD-SYMBOL(<lfs_document>).
    lv_stt += 1.
    ls_data_ex-stt = lv_stt.
    ls_data_ex-PostingDate           = <lfs_document>-item-posting_date.
    ls_data_ex-DocumentDate          = <lfs_document>-item-document_date.
    ls_data_ex-AccountingDocument    = <lfs_document>-item-document.
    ls_data_ex-DocumentItemText      = <lfs_document>-item-document_item_text.
    ls_data_ex-OffsettingAccount     = <lfs_document>-item-offsetting_account.
    ls_data_ex-OffsettingAccountName = <lfs_document>-item-offsetting_account_name.
    ls_data_ex-ReconciliationAccount = <lfs_document>-item-reconciliation_account.
    ls_data_ex-TransactionCurrency   = <lfs_document>-item-currency.
    ls_data_ex-AbsoluteExchangeRate  = <lfs_document>-item-absolute_exchange_rate.

    ls_data_ex-ThuVND_char        = <lfs_document>-item-debit_amount_vnd.
    ls_data_ex-ThuNgoaiTe_char    = <lfs_document>-item-debit_amount.
    ls_data_ex-ChiVND_char        = <lfs_document>-item-credit_amount_vnd.
    ls_data_ex-ChiNgoaiTe_char    = <lfs_document>-item-credit_amount.
    ls_data_ex-TonVND_char        = <lfs_document>-item-end_amount_vnd.
    ls_data_ex-TonNgoaiTe_char    = <lfs_document>-item-end_amount.

    APPEND ls_data_ex TO lt_data_ex.
    CLEAR ls_data_ex.
  ENDLOOP.

  "-----------------------------------------
  " Phát sinh trung kỳ
  "-----------------------------------------
  lv_stt += 1.
  ls_data_ex-stt = lv_stt.
  ls_data_ex-Des = 'Phát sinh trong kỳ'.
  ls_data_ex-ThuVND_char     = <lfs_glaccount_form>-header-debit_amount_vnd.
  ls_data_ex-ThuNgoaiTe_char = <lfs_glaccount_form>-header-debit_amount.
  ls_data_ex-ChiVND_char     = <lfs_glaccount_form>-header-credit_amount_vnd.
  ls_data_ex-ChiNgoaiTe_char = <lfs_glaccount_form>-header-credit_amount.
  APPEND ls_data_ex TO lt_data_ex.
  CLEAR ls_data_ex.

  "-----------------------------------------
  " Số dư cuối kỳ
  "-----------------------------------------
  lv_stt += 1.
  ls_data_ex-stt = lv_stt.
  ls_data_ex-Des = 'Số dư cuối kỳ'.
  ls_data_ex-TonVND_char     = <lfs_glaccount_form>-header-end_amount_vnd.
  ls_data_ex-TonNgoaiTe_char = <lfs_glaccount_form>-header-end_amount.
  APPEND ls_data_ex TO lt_data_ex.
  CLEAR ls_data_ex.

ENDLOOP.





    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).
      CASE <lfs_data>-transactioncurrency.

        WHEN 'VND'.
          <lfs_data>-dudaukyvnd = lv_tondauky_vnd_theo_glaccount.
          <lfs_data>-tonvnd     = lv_amount_ton_vnd.
        WHEN OTHERS.
          <lfs_data>-dudaukyngoaite = lv_tondauky_usd_theo_glaccount.
          <lfs_data>-tonngoaite     = lv_amount_ton_ngoaite.
      ENDCASE.

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

    et_table = lt_data_ex.

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
ENDCLASS.
