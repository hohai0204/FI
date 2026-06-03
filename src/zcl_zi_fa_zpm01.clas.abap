CLASS zcl_zi_fa_zpm01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    INTERFACES if_rap_query_request.
    CLASS-METHODS format_amount_string
      IMPORTING
        i_input         TYPE string
        i_currency      TYPE string
      RETURNING
        VALUE(r_output) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_formatted_date
      IMPORTING
        iv_date        TYPE d  " YYYYMMDD
      RETURNING
        VALUE(rv_text) TYPE string. " DD-MM-YYYY

ENDCLASS.



CLASS ZCL_ZI_FA_ZPM01 IMPLEMENTATION.


  METHOD format_amount_string.

    DATA: lv_clean      TYPE string,
          lv_number     TYPE p LENGTH 16 DECIMALS 2,
          lv_scaled     TYPE p LENGTH 16 DECIMALS 2,
          lv_negative   TYPE abap_bool VALUE abap_false,
          lv_use_paren  TYPE abap_bool VALUE abap_false,
          lv_show_minus TYPE abap_bool VALUE abap_false,
          lv_formatted  TYPE string,
          lv_decimals   TYPE i.

    lv_clean = i_input.
    CONDENSE lv_clean NO-GAPS.

    " --- Xử lý dấu âm và dấu ngoặc giống JS ---
    IF lv_clean CP '*(*)-*'. " ví dụ: (500000-)
      lv_negative   = abap_true.
      lv_use_paren  = abap_true.
      lv_show_minus = abap_true.
      REPLACE ALL OCCURRENCES OF '(' IN lv_clean WITH ''.
      REPLACE ALL OCCURRENCES OF ')' IN lv_clean WITH ''.
      REPLACE ALL OCCURRENCES OF '-' IN lv_clean WITH ''.

    ELSEIF lv_clean CP '*(*)*'.
      lv_negative   = abap_true.
      lv_use_paren  = abap_true.
      REPLACE ALL OCCURRENCES OF '(' IN lv_clean WITH ''.
      REPLACE ALL OCCURRENCES OF ')' IN lv_clean WITH ''.

    ELSEIF lv_clean CP '*-*'.
      lv_negative = abap_true.
      REPLACE ALL OCCURRENCES OF '-' IN lv_clean WITH ''.
    ENDIF.

    " --- Ép kiểu sang số ---
    TRY.
        lv_number = lv_clean.
      CATCH cx_sy_conversion_no_number.
        r_output = i_input.
        RETURN.
    ENDTRY.

    " --- Nhân theo loại tiền ---
    CASE i_currency.
      WHEN 'VND'.
        lv_scaled   = lv_number * 100.
        lv_decimals = 0.
      WHEN 'USD'.
        lv_scaled   = lv_number.
        lv_decimals = 2.
      WHEN OTHERS.
        lv_scaled   = lv_number * 100.
        lv_decimals = 0.
    ENDCASE.

    IF lv_negative = abap_true AND lv_scaled > 0.
      lv_scaled = - lv_scaled.
    ENDIF.

    " --- Format số có dấu phẩy phân tách ---
    lv_formatted = |{ abs( lv_scaled ) CURRENCY = i_currency NUMBER = USER }|.

    " --- Chuyển , thành . nếu cần (tuỳ locale bạn có thể giữ nguyên) ---
*  REPLACE ALL OCCURRENCES OF ',' IN lv_formatted WITH '.'.

    " --- Gắn dấu lại theo logic JS ---
    IF lv_negative = abap_true.
      IF lv_use_paren = abap_true AND lv_show_minus = abap_true.
        r_output = |(-{ lv_formatted })|.        " (123.000-)
      ELSEIF lv_use_paren = abap_true.
        r_output = |({ lv_formatted })|.         " (123.000)
      ELSE.
        r_output = |-{ lv_formatted }|.          " 123.000-
      ENDIF.
    ELSE.
      r_output = lv_formatted.
    ENDIF.

  ENDMETHOD.


  METHOD get_formatted_date.

    IF iv_date IS INITIAL.
      rv_text = ''.
      RETURN.
    ENDIF.

    rv_text = |{ iv_date+6(2) }-{ iv_date+4(2) }-{ iv_date(4) }|.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    "Start Khai báo
    TYPES: BEGIN OF lty_journal_entry,
             accountingdocument             TYPE string,
             journalentrylastchangedatetime TYPE string,
             postingdate                    TYPE string,
             documentreferenceid            TYPE string,
             accountingdocumentheadertext   TYPE string,
             glaccount_26                   TYPE string,
             glaccount_27                   TYPE string,
             transactioncurrency            TYPE string,
             taxexchangerate                TYPE string,
             amountinbalancetransaccrcy_30  TYPE string,
             amountinbalancetransaccrcy_31  TYPE string,
             amountinbalancetransaccrcy_32  TYPE string,
             amountinbalancetransaccrcy_33  TYPE string,
             amountinbalancetransaccrcy_46  TYPE string,
             amountinbalancetransaccrcy_47  TYPE string,
           END OF lty_journal_entry.

    TYPES tt_journal_entrys TYPE STANDARD TABLE OF lty_journal_entry WITH EMPTY KEY.

    TYPES: BEGIN OF lty_supplier,
             supplieraccountgroup TYPE string,
             ncc                  TYPE string,
             ct9_nodk_vnd         TYPE string,
             ct10_codk_vnd        TYPE string,
             ct11_nodk            TYPE string,
             ct12_codk            TYPE string,
             ct13_cpsn_vnd        TYPE string,
             ct14_cpsc_vnd        TYPE string,
             ct15_cpsn            TYPE string,
             ct16_cpsc            TYPE string,
             ct17_sdnck_vnd       TYPE string,
             ct18_sdcck_vnd       TYPE string,
             ct19_sdnck           TYPE string,
             ct20_sdcck           TYPE string,

             ct44_nodk            TYPE string,
             ct45_codk            TYPE string,
             ct44_cpsn            TYPE string,
             ct45_cpsc            TYPE string,
             ct45_sdnck           TYPE string,
             ct45_sdcck           TYPE string,
             journal_entrys       TYPE tt_journal_entrys,


           END OF lty_supplier.
    TYPES tt_suppliers TYPE STANDARD TABLE OF lty_supplier WITH EMPTY KEY.
    TYPES: BEGIN OF lty_header,
             tencty_vn     TYPE string,
             diachi_vn     TYPE string,
             mst           TYPE string,

             tk            TYPE string,
             day           TYPE string,
             suppliers     TYPE tt_suppliers,
             nguoilap      TYPE string,

             sum_ct9       TYPE string,
             sum_ct10      TYPE string,
             sum_ct11      TYPE string,
             sum_ct12      TYPE string,

             sum_cpsn_vnd  TYPE string,
             sum_cpsc_vnd  TYPE string,
             sum_cpsn      TYPE string,
             sum_cpsc      TYPE string,
             sum_sdnck_vnd TYPE string,
             sum_sdcck_vnd TYPE string,
             sum_sdnck     TYPE string,
             sum_sdcck     TYPE string,

             sum_nosddk    TYPE string,
             sum_cosddk    TYPE string,
             sum_cpsn_lk   TYPE string,
             sum_cpsc_lk   TYPE string,
             sum_sdnck_lk  TYPE string,
             sum_sdcck_lk  TYPE string,

             ketoantruong  TYPE string,
             giamdoc       TYPE string,
             day_print     TYPE string,

           END OF lty_header.

    DATA: lt_zpm01 TYPE STANDARD TABLE OF zi_fa_zpm01.

    DATA: lt_post            TYPE TABLE OF lty_header,
           ls_post            TYPE lty_header,
          ls_supplier        TYPE lty_supplier,
          ls_supplier_header TYPE lty_supplier,
          lt_suppliers       TYPE TABLE OF lty_supplier,
          ls_journal_entry   TYPE lty_journal_entry,
          lt_journal_entrys  TYPE TABLE OF lty_journal_entry.
    DATA:
      lt_result TYPE STANDARD TABLE OF zi_fa_zpm01,
      ls_result TYPE zi_fa_zpm01.
    DATA:
      lt_result_page TYPE STANDARD TABLE OF zi_fa_zpm01,
      lv_offset      TYPE i,
      lv_page_size   TYPE i,
      lv_count       TYPE i VALUE 0.

    DATA: lv_amount30 TYPE p DECIMALS 2,
          lv_amount31 TYPE p DECIMALS 2,
          lv_amount32 TYPE p DECIMALS 2,
          lv_amount33 TYPE p DECIMALS 2.

    DATA:
lv_stt     TYPE i.
    DATA lv_uuid_fi          TYPE uuid.
    DATA lv_isreversal          TYPE co_stflg.


TYPES: BEGIN OF ty_group_sophatsinh,
         supplier TYPE i_supplier-supplier,
         companycode TYPE i_journalentryitem-companycode,
         accountingdocument TYPE i_journalentryitem-accountingdocument,
         glaccount_k TYPE i_journalentryitem-glaccount,
         glaccount TYPE i_journalentryitem-glaccount,
         financialaccounttype TYPE i_journalentryitem-financialaccounttype,
         amountinbalancetransaccrcy_30 TYPE i_journalentryitem-amountincompanycodecurrency,
         amountinbalancetransaccrcy_31 TYPE i_journalentryitem-amountincompanycodecurrency,
         amountinbalancetransaccrcy_32 TYPE i_journalentryitem-amountintransactioncurrency,
         amountinbalancetransaccrcy_33 TYPE i_journalentryitem-amountintransactioncurrency,
       END OF ty_group_sophatsinh.

DATA: lt_group_not_k TYPE TABLE OF ty_group_sophatsinh,
      lt_group_k     TYPE TABLE OF ty_group_sophatsinh,
      lt_group_sophatsinh TYPE TABLE OF ty_group_sophatsinh.

    "End Khai báo
    TRY.
        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.



    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).



    IF lo_filter IS NOT INITIAL.

      LOOP AT lo_filter INTO DATA(ls_filter).
        CASE ls_filter-name.
          WHEN 'SUPPLIER'.
            DATA(lt_supplier_range) = ls_filter-range.
          WHEN 'COMPANYCODE'.
            DATA(lt_companycode_range) = ls_filter-range.
          WHEN 'FISCALYEAR'.
            DATA(lt_fiscalyear_range) = ls_filter-range.
          WHEN 'POSTINGDATE'.
            DATA(lt_postingdate_range) = ls_filter-range.
          WHEN 'GLACCOUNT_26'.
            DATA(lt_glaccount_range) = ls_filter-range.
          WHEN 'SUPPLIERACCOUNTGROUP'.
            DATA(lt_supplieraccountgroup_range) = ls_filter-range.
          WHEN 'ISREVERSAL'.
            DATA(lt_isreversal_range) = ls_filter-range.

          WHEN 'NGUOILAP'.
            DATA(lt_nguoilap_range) = ls_filter-range.
          WHEN 'KETOANTRUONG'.
            DATA(lt_ketoantruong_range) = ls_filter-range.
          WHEN 'GIAMDOC'.
            DATA(lt_giamdoc_range) = ls_filter-range.
          WHEN 'ACCOUNTINGDOCUMENT'.
            DATA(lt_accountingdocument_range) = ls_filter-range.
          WHEN 'OBJECT_ID'.
            DATA(lt_objectid_range) = ls_filter-range.
          WHEN 'GLACCOUNT'.
            DATA(lt_tkdu_range) = ls_filter-range.
        ENDCASE.
      ENDLOOP.
    ENDIF.


*check lt_isreversal_range is not initial.
    IF io_request->is_data_requested( ).


      DATA: lv_min_date             TYPE d,
            lv_prev_month_first_day TYPE d.
      LOOP AT lt_postingdate_range INTO DATA(ls_range).
        IF lv_min_date IS INITIAL OR ls_range-low < lv_min_date.
          lv_min_date = ls_range-low.
        ENDIF.
      ENDLOOP.



      IF lv_min_date+4(2) = '01'.
        lv_prev_month_first_day  = |{ lv_min_date+0(4) - 1 }1201|.
      ELSE.
        IF lv_min_date+4(2) - 1  > 9.
          lv_prev_month_first_day  = |{ lv_min_date+0(4) }{ lv_min_date+4(2) - 1 }01|.
        ELSE.
          lv_prev_month_first_day  = |{ lv_min_date+0(4) }0{ lv_min_date+4(2) - 1 }01|.
        ENDIF.

      ENDIF.
IF lt_isreversal_range IS NOT INITIAL.
             READ TABLE lt_isreversal_range ASSIGNING FIELD-SYMBOL(<lfs_isreversal>) INDEX 1.
        IF sy-subrc = 0.
        IF <lfs_isreversal>-low = 'X'.
        lv_isreversal = '1'.
        ELSE.
        lv_isreversal = '0'.
        ENDIF.
        ENDIF.
  ENDIF.
      SELECT
       supplier~supplier,
        item_journalentry~companycode,
*  Item_JournalEntry~BalanceTransactionCurrency,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~debitAmountInCoCodeCrcy
*            ELSE 0
*          END
*        ) AS ct9_dauky_vnd,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~CREDITAMOUNTINCOCODECRCY
*            ELSE 0
*          END
*        ) AS ct10_dauky_vnd,
        SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_vnd,
*       SUM(
*
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~debitamountincocodecrcy
*             ELSE 0
*          END
*        ) AS dauky_no,
*               SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~creditamountincocodecrcy
*                       ELSE 0
*          END
*        ) AS dauky_co,
        SUM(
       item_journalentry~AmountInCompanyCodeCurrency

        ) AS dauky,
      SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountinbalancetransaccrcy
            ELSE 0
          END
        ) AS dauky_nt,
         SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_nt_vnd

*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~debitamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct11_dauky,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~creditamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS


      FROM i_supplier AS supplier
        INNER JOIN i_journalentryitem AS item_journalentry ON supplier~supplier = item_journalentry~supplier AND item_journalentry~ledger = '0L'
        LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
      WHERE
            supplier~supplier IN @lt_supplier_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~glaccount IN @lt_glaccount_range
        AND journalentry~postingdate < @lv_min_date"journalentry~postingdate < @lv_prev_month_first_day" AND journalentry~postingdate < @lv_min_date
        AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
            AND item_journalentry~financialaccounttype = 'K'
      GROUP BY  supplier~supplier,
                item_journalentry~companycode
       ORDER BY supplier~supplier,
                item_journalentry~companycode
      INTO TABLE @DATA(lt_group_dauky).

      SELECT
        supplier~supplieraccountgroup && ' - ' && grouptext~accountgroupname AS supplieraccountgroup,
       supplier~supplier,
               concat(
          concat(
            ltrim( supplier~supplier, '0' ),
            '-'
          ),
          bp~name
        ) AS ncc,
*               SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~debitamountincocodecrcy
**            CAST( item_journalentry~debitamountinbalancetranscrcy
**         * journalentry~absoluteexchangerate
**         * 10 AS DEC( 31,2 ) )
*            ELSE 0
*          END
*        ) AS dauky_no,
*               SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~creditamountincocodecrcy
**            CAST( item_journalentry~creditamountinbalancetranscrcy
**         * journalentry~absoluteexchangerate
**         * 10 AS DEC( 31,2 ) )
*            ELSE 0
*          END
*        ) AS dauky_co,
    SUM(
       item_journalentry~AmountInCompanyCodeCurrency

        ) AS dauky,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~debitAmountInCoCodeCrcy
*            ELSE 0
*          END
*        ) AS ct9_dauky_vnd,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~CREDITAMOUNTINCOCODECRCY
*            ELSE 0
*          END
*        ) AS ct10_dauky_vnd,
        SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_vnd,
         SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~AmountInBalanceTransacCrcy
            ELSE 0
          END
        ) AS dauky_nt,
                 SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_nt_vnd
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~debitamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct11_dauky,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~creditamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct12_dauky
      FROM i_supplier AS supplier
        INNER JOIN i_journalentryitem AS item_journalentry ON supplier~supplier = item_journalentry~supplier AND item_journalentry~ledger = '0L'
        LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
          LEFT JOIN zcds_bp AS bp ON supplier~supplier = bp~businesspartner
                     LEFT JOIN i_supplieraccountgrouptext AS grouptext ON grouptext~supplieraccountgroup = supplier~supplieraccountgroup AND grouptext~language = 'E'

      WHERE
            supplier~supplier IN @lt_supplier_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~glaccount IN @lt_glaccount_range
        AND journalentry~postingdate < @lv_min_date
                AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
            AND item_journalentry~financialaccounttype = 'K'
      GROUP BY  supplier~supplier,bp~name, supplier~supplieraccountgroup,grouptext~accountgroupname
       ORDER BY supplier~supplier
      INTO TABLE @DATA(lt_supplier_dauky).

      SELECT
         SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_vnd,
        SUM(
       item_journalentry~AmountInCompanyCodeCurrency

        ) AS dauky,
      SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountinbalancetransaccrcy
            ELSE 0
          END
        ) AS dauky_nt,
         SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~AmountInCompanyCodeCurrency
            ELSE 0
          END
        ) AS dauky_nt_vnd
      FROM i_supplier AS supplier
        INNER JOIN i_journalentryitem AS item_journalentry ON supplier~supplier = item_journalentry~supplier AND item_journalentry~ledger = '0L'
        LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
          LEFT JOIN zcds_bp AS bp ON supplier~supplier = bp~businesspartner
                     LEFT JOIN i_supplieraccountgrouptext AS grouptext ON grouptext~supplieraccountgroup = supplier~supplieraccountgroup AND grouptext~language = 'E'

      WHERE
            supplier~supplier IN @lt_supplier_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~glaccount IN @lt_glaccount_range
        AND journalentry~postingdate < @lv_min_date
                AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
        AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
       AND item_journalentry~financialaccounttype = 'K'
      INTO TABLE @DATA(lt_dauky).

      "--- Lấy danh sách dòng K (Supplier Line)
      SELECT
          supplier~supplier,
          item_k~companycode,
          item_k~fiscalyear,
          item_k~accountingdocument,
          item_k~glaccount
      FROM i_supplier AS supplier
      INNER JOIN i_journalentryitem AS item_k
          ON supplier~supplier = item_k~supplier
         AND item_k~financialaccounttype = 'K'
         AND item_k~ledger = '0L'
      WHERE
          supplier~supplier IN @lt_supplier_range
      AND item_k~companycode IN @lt_companycode_range
      AND item_k~fiscalyear IN @lt_fiscalyear_range
      AND item_k~glaccount IN @lt_glaccount_range

      GROUP BY     supplier~supplier,
          item_k~companycode,
          item_k~fiscalyear,
          item_k~accountingdocument,
          item_k~glaccount
      INTO TABLE @DATA(lt_k_items).

*      SELECT
*        supplier~supplier,
*        item_journalentry~companycode,
*        item_journalentry~accountingdocument,
*        item_journalentry_k~glaccount AS glaccount_k,
*        item_journalentry~glaccount,
*        item_journalentry~financialaccounttype,
**        item_journalentry~balancetransactioncurrency,
**        journalentry~isreversal,
*                SUM(
*          CASE
*             WHEN item_journalentry~debitcreditcode = 'S' AND item_journalentry~transactioncurrency = 'VND' AND item_journalentry~amountintransactioncurrency  > 0 THEN  item_journalentry~amountincompanycodecurrency
**            WHEN item_journalentry~debitcreditcode = 'H' AND item_journalentry~transactioncurrency = 'VND' AND item_journalentry~amountintransactioncurrency  > 0 THEN item_journalentry~amountincompanycodecurrency
*
*            ELSE 0
*          END
*        ) AS amountinbalancetransaccrcy_30,
*        SUM(
*          CASE
*                      WHEN item_journalentry~debitcreditcode = 'H' AND item_journalentry~transactioncurrency = 'VND' AND item_journalentry~amountintransactioncurrency  < 0 THEN abs( item_journalentry~amountincompanycodecurrency )
**            WHEN item_journalentry~debitcreditcode = 'S' AND item_journalentry~transactioncurrency = 'VND'  AND item_journalentry~amountintransactioncurrency  < 0 THEN abs( item_journalentry~amountincompanycodecurrency )
*
*            ELSE 0
*          END
*        ) AS amountinbalancetransaccrcy_31,
*     SUM(
*          CASE
*            WHEN item_journalentry~debitcreditcode = 'S' AND item_journalentry~transactioncurrency <> 'VND'   THEN item_journalentry~amountintransactioncurrency
**            WHEN item_journalentry~debitcreditcode = 'H' AND item_journalentry~transactioncurrency <> 'VND' AND item_journalentry~amountintransactioncurrency  > 0  THEN item_journalentry~amountintransactioncurrency
*            ELSE 0
*          END
*        ) AS amountinbalancetransaccrcy_32,
*        SUM(
*          CASE
*            WHEN item_journalentry~debitcreditcode = 'H' AND item_journalentry~transactioncurrency <> 'VND'   THEN abs( item_journalentry~amountintransactioncurrency )
**            WHEN item_journalentry~debitcreditcode = 'S' AND item_journalentry~transactioncurrency <> 'VND' AND item_journalentry~amountintransactioncurrency  < 0  THEN abs( item_journalentry~amountintransactioncurrency )
*            ELSE 0
*          END
*        ) AS amountinbalancetransaccrcy_33
*
*      FROM i_supplier AS supplier
*                LEFT JOIN @lt_k_items AS item_journalentry_k
*            ON supplier~supplier = item_journalentry_k~supplier
**           AND item_journalentry_k~financialaccounttype = 'K'
**           AND item_journalentry_k~ledger = '0L'
*        LEFT JOIN i_journalentryitem AS item_journalentry
*          ON    "AND item_journalentry~glaccount NOT LIKE '133%'
*        item_journalentry~ledger = '0L'
*        AND item_journalentry~companycode =  item_journalentry_k~companycode
*           AND item_journalentry~fiscalyear =  item_journalentry_k~fiscalyear
*           AND item_journalentry~accountingdocument =  item_journalentry_k~accountingdocument
*
*      LEFT JOIN i_journalentry AS journalentry
*          ON journalentry~accountingdocument = item_journalentry~accountingdocument
*
*  LEFT JOIN ZI_COUNT_glaccount AS k_count
*    ON k_count~accountingdocument = journalentry~accountingdocument
*      WHERE
*            supplier~supplier IN @lt_supplier_range
*        AND item_journalentry~companycode IN @lt_companycode_range
*        AND journalentry~fiscalyear IN @lt_fiscalyear_range
*        AND item_journalentry~accountingdocument IN @lt_accountingdocument_range
*        AND item_journalentry_k~glaccount      IN @lt_glaccount_range
*        AND journalentry~postingdate         IN @lt_postingdate_range
*        AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
*       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
*       OR ( ( journalentry~isreversal IN @lt_isreversal_range
*       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
*         AND ( item_journalentry~financialaccounttype <> 'K'
*         or ( k_count~Clearing = 1 AND k_count~c > 1 AND item_journalentry~ClearingJournalEntry is NOT null AND item_journalentry~financialaccounttype = 'K' )
*          or (  k_count~Clearing = 0 AND k_count~c > 1 AND item_journalentry~postingkey = '38' AND item_journalentry~financialaccounttype = 'K' ) )
*      GROUP BY
*        supplier~supplier,
*        item_journalentry~companycode,
*        item_journalentry~accountingdocument,
*        item_journalentry_k~glaccount,
*        item_journalentry~glaccount,
*        item_journalentry~financialaccounttype
**        item_journalentry~balancetransactioncurrency
**        journalentry~isreversal
*      INTO TABLE @DATA(lt_group_sophatsinh).


"--- 1. SELECT nhóm (không phải loại K)
SELECT
    supplier~supplier,
    item_journalentry~companycode,
    item_journalentry~accountingdocument,
    item_journalentry_k~glaccount AS glaccount_k,
    item_journalentry~glaccount,
    item_journalentry~financialaccounttype,
    SUM(
      CASE
        WHEN item_journalentry~debitcreditcode = 'S'
         AND item_journalentry~transactioncurrency = 'VND'
         AND item_journalentry~amountintransactioncurrency > 0
        THEN item_journalentry~amountincompanycodecurrency
        ELSE 0
      END
    ) AS amountinbalancetransaccrcy_30,
    SUM(
      CASE
        WHEN item_journalentry~debitcreditcode = 'H'
         AND item_journalentry~transactioncurrency = 'VND'
         AND item_journalentry~amountintransactioncurrency < 0
        THEN abs( item_journalentry~amountincompanycodecurrency )
        ELSE 0
      END
    ) AS amountinbalancetransaccrcy_31,
    SUM(
      CASE
        WHEN item_journalentry~debitcreditcode = 'S'
         AND item_journalentry~transactioncurrency <> 'VND'
        THEN item_journalentry~amountintransactioncurrency
        ELSE 0
      END
    ) AS amountinbalancetransaccrcy_32,
    SUM(
      CASE
        WHEN item_journalentry~debitcreditcode = 'H'
         AND item_journalentry~transactioncurrency <> 'VND'
        THEN abs( item_journalentry~amountintransactioncurrency )
        ELSE 0
      END
    ) AS amountinbalancetransaccrcy_33
  FROM i_supplier AS supplier
  LEFT JOIN @lt_k_items AS item_journalentry_k
    ON supplier~supplier = item_journalentry_k~supplier
  LEFT JOIN i_journalentryitem AS item_journalentry
    ON item_journalentry~ledger = '0L'
   AND item_journalentry~companycode = item_journalentry_k~companycode
   AND item_journalentry~fiscalyear  = item_journalentry_k~fiscalyear
   AND item_journalentry~accountingdocument = item_journalentry_k~accountingdocument
  LEFT JOIN i_journalentry AS journalentry
    ON journalentry~accountingdocument = item_journalentry~accountingdocument
  LEFT JOIN ZI_COUNT_glaccount AS k_count
    ON k_count~accountingdocument = journalentry~accountingdocument
  WHERE
        item_journalentry~financialaccounttype <> 'K'
        AND supplier~supplier IN @lt_supplier_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~accountingdocument IN @lt_accountingdocument_range

        AND item_journalentry_k~glaccount      IN @lt_glaccount_range
        AND journalentry~postingdate         IN @lt_postingdate_range
        AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )

  GROUP BY
    supplier~supplier,
    item_journalentry~companycode,
    item_journalentry~accountingdocument,
    item_journalentry_k~glaccount,
    item_journalentry~glaccount,
    item_journalentry~financialaccounttype
     INTO CORRESPONDING FIELDS OF TABLE @lt_group_not_k.


"--- 2. SELECT không nhóm (loại K giữ nguyên)
SELECT
    supplier~supplier,
    item_journalentry~companycode,
    item_journalentry~accountingdocument,
    item_journalentry_k~glaccount AS glaccount_k,
    item_journalentry~glaccount,
    item_journalentry~financialaccounttype,
      CASE
        WHEN item_journalentry~debitcreditcode = 'S'
         AND item_journalentry~transactioncurrency = 'VND'
         AND item_journalentry~amountintransactioncurrency > 0
        THEN item_journalentry~amountincompanycodecurrency
        ELSE 0
      END
 AS amountinbalancetransaccrcy_30,
      CASE
        WHEN item_journalentry~debitcreditcode = 'H'
         AND item_journalentry~transactioncurrency = 'VND'
         AND item_journalentry~amountintransactioncurrency < 0
        THEN abs( item_journalentry~amountincompanycodecurrency )
        ELSE 0
      END AS amountinbalancetransaccrcy_31,
      CASE
        WHEN item_journalentry~debitcreditcode = 'S'
         AND item_journalentry~transactioncurrency <> 'VND'
        THEN item_journalentry~amountintransactioncurrency
        ELSE 0
      END AS amountinbalancetransaccrcy_32,
      CASE
        WHEN item_journalentry~debitcreditcode = 'H'
         AND item_journalentry~transactioncurrency <> 'VND'
        THEN abs( item_journalentry~amountintransactioncurrency )
        ELSE 0
      END AS amountinbalancetransaccrcy_33
  FROM i_supplier AS supplier
  LEFT JOIN @lt_k_items AS item_journalentry_k
    ON supplier~supplier = item_journalentry_k~supplier
  LEFT JOIN i_journalentryitem AS item_journalentry
    ON item_journalentry~ledger = '0L'
   AND item_journalentry~companycode = item_journalentry_k~companycode
   AND item_journalentry~fiscalyear  = item_journalentry_k~fiscalyear
   AND item_journalentry~accountingdocument = item_journalentry_k~accountingdocument
  LEFT JOIN i_journalentry AS journalentry
    ON journalentry~accountingdocument = item_journalentry~accountingdocument
  LEFT JOIN ZI_COUNT_glaccount AS k_count
    ON k_count~accountingdocument = journalentry~accountingdocument
  WHERE
        item_journalentry~financialaccounttype = 'K'
        AND supplier~supplier IN @lt_supplier_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~accountingdocument IN @lt_accountingdocument_range
                AND item_journalentry_k~glaccount      IN @lt_glaccount_range
        AND journalentry~postingdate         IN @lt_postingdate_range
        AND supplier~supplieraccountgroup IN @lt_supplieraccountgroup_range
       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
       AND ( ( k_count~Clearing = 1 AND k_count~c > 1 AND item_journalentry~ClearingJournalEntry is NOT null AND item_journalentry~financialaccounttype = 'K' )
          or (  k_count~Clearing = 0 AND k_count~c > 1 AND item_journalentry~postingkey = '38' AND item_journalentry~financialaccounttype = 'K' ) )
   INTO CORRESPONDING FIELDS OF TABLE @lt_group_k.


"--- 3. Gộp lại
APPEND LINES OF lt_group_k TO lt_group_not_k.
lt_group_sophatsinh = lt_group_not_k.


*      LOOP AT lt_group_sophatsinh ASSIGNING FIELD-SYMBOL(<fs_row>).
*        lv_amount30 = <fs_row>-amountinbalancetransaccrcy_30.
*        lv_amount31 = <fs_row>-amountinbalancetransaccrcy_31.
*        lv_amount32 = <fs_row>-amountinbalancetransaccrcy_32.
*        lv_amount33 = <fs_row>-amountinbalancetransaccrcy_33.
*
*        IF ( lv_amount30 - lv_amount31 = 0 ) AND
*           ( lv_amount32 - lv_amount33 = 0 ).
*          DELETE lt_group_sophatsinh INDEX sy-tabix.
*        ENDIF.
*      ENDLOOP.

      SELECT
         supplier~supplier,
          journalentry~companycode,
          journalentry~fiscalyear,
          journalentry~accountingdocument,
          journalentry~postingdate,
          journalentry~journalentrylastchangedatetime,
        concat(
          concat(
            ltrim( supplier~supplier, '0' ),
            '-'
          ),
          bp~name
        ) AS ncc,
      substring(
        journalentry~documentreferenceid,
        instr( journalentry~documentreferenceid, '.' ) + 1,
        length( journalentry~documentreferenceid ) - instr( journalentry~documentreferenceid, '.' )
      ) AS documentreferenceid,
*          journalentry~accountingdocumentheadertext,
          CASE
            WHEN journalentry~accountingdocumentheadertext IS NOT INITIAL
            THEN journalentry~accountingdocumentheadertext
            WHEN item_journalentry~documentitemtext IS NOT INITIAL
            THEN item_journalentry~documentitemtext
          END AS accountingdocumentheadertext,
         item_journalentry~glaccount AS glaccount_26,
        sophatsinh~glaccount,
          journalentry~transactioncurrency,
          CASE
            WHEN journalentry~transactioncurrency <> 'VND'
            THEN  journalentry~absoluteexchangerate"journalentry~taxabsoluteexchangerate
          END AS taxexchangerate,
*          CASE
*             WHEN  sophatsinh~financialaccounttype <> 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_31
*            WHEN  sophatsinh~financialaccounttype = 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_30
*            ELSE 0
*          END AS ct30_curr,
sophatsinh~amountinbalancetransaccrcy_31 AS ct30_curr,
*          CASE
*             WHEN  sophatsinh~financialaccounttype <> 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_30
*            WHEN  sophatsinh~financialaccounttype = 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_31
*           ELSE 0
*         END AS ct31_curr,
sophatsinh~amountinbalancetransaccrcy_30 AS ct31_curr,
*          CASE
*             WHEN  sophatsinh~financialaccounttype <> 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_33
*            WHEN  sophatsinh~financialaccounttype = 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_32
**            WHEN  sophatsinh~glaccount IS NULL AND item_journalentry~debitcreditcode = 'S' AND item_journalentry~transactioncurrency <> 'VND' AND item_journalentry~amountintransactioncurrency  > 0  THEN item_journalentry~amountintransactioncurrency
**            WHEN  sophatsinh~glaccount IS NULL AND  item_journalentry~debitcreditcode = 'H' AND item_journalentry~transactioncurrency <> 'VND' AND item_journalentry~amountintransactioncurrency  > 0  THEN item_journalentry~amountintransactioncurrency
*            ELSE 0
*          END AS ct32_curr,
 sophatsinh~amountinbalancetransaccrcy_33 AS ct32_curr,
*          CASE
*             WHEN  sophatsinh~financialaccounttype <> 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_32
*            WHEN  sophatsinh~financialaccounttype = 'K'
*            THEN  sophatsinh~amountinbalancetransaccrcy_33
**            WHEN  sophatsinh~glaccount IS NULL AND item_journalentry~debitcreditcode = 'H'
**            AND item_journalentry~transactioncurrency <> 'VND'   THEN abs( item_journalentry~amountintransactioncurrency )
**            WHEN  sophatsinh~glaccount IS NULL AND item_journalentry~debitcreditcode = 'S'
**            AND item_journalentry~transactioncurrency <> 'VND' AND item_journalentry~amountintransactioncurrency  < 0 THEN abs( item_journalentry~amountintransactioncurrency )
*            ELSE 0
*          END AS ct33_curr,
          sophatsinh~amountinbalancetransaccrcy_32 AS ct33_curr,
          _company~tencty_vn,
          _company~diachi_vn,
          _company~mst,
          supplier~supplieraccountgroup && ' - ' && grouptext~accountgroupname AS supplieraccountgroup,

          item_journalentry~balancetransactioncurrency,


        CASE
            WHEN journalentry~isreversal = 'X'
            THEN journalentry~isreversal
            WHEN journalentry~IsReversed = 'X'
            THEN journalentry~IsReversed
          END AS isreversal,
*          journalentry~isreversal,
          CASE  WHEN ( item_journalentry~amountintransactioncurrency  > 0 )
              AND item_journalentry~debitcreditcode = 'H' THEN 'X'
            WHEN ( item_journalentry~amountintransactioncurrency  < 0 )
              AND item_journalentry~debitcreditcode = 'S' THEN  'X'
            ELSE ' '  END AS isnegativeposting

          FROM i_supplier AS supplier
          INNER JOIN I_JournalEntryItem AS item_journalentry
            ON supplier~supplier = item_journalentry~supplier
           AND item_journalentry~financialaccounttype = 'K'
           AND item_journalentry~ledger = '0L'

          INNER JOIN i_journalentry AS journalentry
            ON journalentry~accountingdocument = item_journalentry~accountingdocument


           LEFT JOIN @lt_group_sophatsinh AS sophatsinh
            ON sophatsinh~companycode = journalentry~companycode
           AND journalentry~accountingdocument = sophatsinh~accountingdocument
           AND supplier~supplier = sophatsinh~supplier AND item_journalentry~glaccount = sophatsinh~glaccount_k
  LEFT JOIN ZI_COUNT_glaccount AS k_count
    ON k_count~accountingdocument = journalentry~accountingdocument
          LEFT JOIN zcds_bp AS bp
            ON supplier~supplier = bp~businesspartner

           LEFT JOIN i_supplieraccountgrouptext AS grouptext ON grouptext~supplieraccountgroup = supplier~supplieraccountgroup AND grouptext~language = 'E'

          LEFT JOIN zcds_company AS _company
            ON journalentry~companycode = _company~companycode

          WHERE supplier~supplier                IN @lt_supplier_range
            AND journalentry~companycode         IN @lt_companycode_range
            AND journalentry~fiscalyear          IN @lt_fiscalyear_range
            AND journalentry~accountingdocument  IN @lt_accountingdocument_range
            AND journalentry~postingdate         IN @lt_postingdate_range
            AND item_journalentry~glaccount      IN @lt_glaccount_range
            AND supplier~supplieraccountgroup    IN @lt_supplieraccountgroup_range
            AND sophatsinh~glaccount          IN @lt_tkdu_range
       AND ( (  journalentry~IsReversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal IS INITIAL )   )
       OR ( ( journalentry~isreversal IN @lt_isreversal_range
       OR  journalentry~IsReversed IN @lt_isreversal_range ) AND @lv_isreversal = '1' ) )
       AND ( ( k_count~Clearing = 1 AND k_count~c > 1 AND item_journalentry~ClearingJournalEntry is INITIAL )
        OR k_count~c <= 1 or
       (  k_count~Clearing = 0 AND k_count~c > 1 AND item_journalentry~postingkey <> '38' ) )
            ORDER BY supplier~supplier,journalentry~postingdate ,journalentry~accountingdocument
      INTO CORRESPONDING FIELDS OF TABLE @lt_result.

*      SORT lt_result. " Sắp xếp để các dòng trùng đứng gần nhau
*      DELETE ADJACENT DUPLICATES FROM lt_result.


      IF lt_objectid_range IS NOT INITIAL.
        SELECT
        *
        FROM ztb_zpm01_pdfn
        WHERE object_id IN @lt_objectid_range
        INTO TABLE @DATA(lt_pdf).
      ENDIF.

*      READ TABLE lt_flag_range ASSIGNING FIELD-SYMBOL(<lfs_flag>) INDEX 1.
*      IF sy-subrc = 0.
*        IF <lfs_flag>-low = 'X' AND lt_result IS INITIAL.
*          APPEND ls_result TO lt_result.
*        ENDIF.
*      ENDIF.
      IF lt_pdf IS INITIAL.

            TRY.
          lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
        CATCH cx_uuid_error INTO DATA(lx_err).
          DATA(lv_error3) = lx_err->get_text( ).  " Hoặc ghi log, v.v.
      ENDTRY.

        LOOP AT lt_supplier_dauky ASSIGNING FIELD-SYMBOL(<fs_dauky>).



          READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_res>)
               WITH KEY supplier = <fs_dauky>-supplier.
          IF sy-subrc <> 0.
            lv_stt = lv_stt + 1.
            ls_result-stt = lv_stt.
            ls_result-object_id = lv_uuid_fi.
            ls_result-supplier = <fs_dauky>-supplier.
            ls_result-ncc = <fs_dauky>-ncc.
            ls_result-supplieraccountgroup = <fs_dauky>-supplieraccountgroup.

*            ls_result-ct9_nodk_vnd = abs( <fs_dauky>-ct9_dauky_vnd ).
*            ls_result-ct10_codk_vnd = abs( <fs_dauky>-ct10_dauky_vnd ).
*            ls_result-ct11_nodk = abs( <fs_dauky>-ct11_dauky ).
*            ls_result-ct12_codk = abs( <fs_dauky>-ct12_dauky ).
            if <fs_dauky>-dauky_vnd >= 0.
                ls_result-ct9_nodk_vnd = <fs_dauky>-dauky_vnd .
              endif.
              if <fs_dauky>-dauky_vnd < 0.

              ls_result-ct10_codk_vnd =  ABS( <fs_dauky>-dauky_vnd ).
              endif.
               if <fs_dauky>-dauky_nt_vnd >= 0.

               ls_result-ct11_nodk = <fs_dauky>-dauky_nt.
              endif.
               if <fs_dauky>-dauky_nt_vnd < 0.

            ls_result-ct12_codk = ABS( <fs_dauky>-dauky_nt ).
              endif.
                        IF <fs_dauky>-dauky >= 0.
             ls_result-ct44_nodk =  <fs_dauky>-dauky.
          ELSE.
              ls_result-ct45_codk = abs( <fs_dauky>-dauky ).
              ENDIF.
*                        ls_result-ct44_nodk = abs( ls_result-ct9_nodk_vnd + <fs_dauky>-dauky_no ).
*            ls_result-ct45_codk = abs( ls_result-ct10_codk_vnd + <fs_dauky>-dauky_co ).
            ls_result-flag = 'X'.
            APPEND ls_result TO lt_result.
            CLEAR ls_result.
          ENDIF.
        ENDLOOP.

        SORT lt_result BY supplieraccountgroup supplier postingdate accountingdocument.

*      ENDIF.
        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_zpm01>) ."INTO DATA(ls_zsd07).
          lv_stt = lv_stt + 1.
          <lfs_zpm01>-stt = lv_stt.
          <lfs_zpm01>-object_id = lv_uuid_fi.
          AT FIRST.
            MOVE-CORRESPONDING <lfs_zpm01> TO ls_post.
          ENDAT.
*          IF <lfs_zpm01>-isnegativeposting IS NOT INITIAL.
*            <lfs_zpm01>-amountinbalancetransaccrcy_30 = |({ <lfs_zpm01>-ct30_curr })|.
*            <lfs_zpm01>-amountinbalancetransaccrcy_31 = |({ <lfs_zpm01>-ct31_curr })|.
*            IF <lfs_zpm01>-transactioncurrency <> 'VND'.
*              <lfs_zpm01>-amountinbalancetransaccrcy_32 = |({ <lfs_zpm01>-ct32_curr })|.
*              <lfs_zpm01>-amountinbalancetransaccrcy_33 = |({ <lfs_zpm01>-ct33_curr })|.
*            ENDIF.
*          ELSE.
            <lfs_zpm01>-amountinbalancetransaccrcy_30 = <lfs_zpm01>-ct30_curr.
            <lfs_zpm01>-amountinbalancetransaccrcy_31 = <lfs_zpm01>-ct31_curr.
            IF <lfs_zpm01>-transactioncurrency <> 'VND'.
              <lfs_zpm01>-amountinbalancetransaccrcy_32 = <lfs_zpm01>-ct32_curr.
              <lfs_zpm01>-amountinbalancetransaccrcy_33 = <lfs_zpm01>-ct33_curr.
            ENDIF.
*          ENDIF.

          <lfs_zpm01>-amountinbalancetransaccrcy_46  = <lfs_zpm01>-ct30_curr + <lfs_zpm01>-ct32_curr * (  <lfs_zpm01>-taxexchangerate * 10 ) .
          <lfs_zpm01>-amountinbalancetransaccrcy_47  = <lfs_zpm01>-ct31_curr + <lfs_zpm01>-ct33_curr * (  <lfs_zpm01>-taxexchangerate * 10 ) .


          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_30 NO-GAPS.
          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_31 NO-GAPS.
          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_32 NO-GAPS.
          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_33 NO-GAPS.
          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_46 NO-GAPS.
          CONDENSE <lfs_zpm01>-amountinbalancetransaccrcy_47 NO-GAPS.

          <lfs_zpm01>-amountinbalancetransaccrcy_30 = format_amount_string( i_currency =  'VND' i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_30 ) ).
          <lfs_zpm01>-amountinbalancetransaccrcy_31 = format_amount_string( i_currency =  'VND'  i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_31 ) ).

            <lfs_zpm01>-amountinbalancetransaccrcy_32 = format_amount_string( i_currency = 'USD'  i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_32 ) ).
            <lfs_zpm01>-amountinbalancetransaccrcy_33 = format_amount_string( i_currency = 'USD'  i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_33 ) ).

          <lfs_zpm01>-amountinbalancetransaccrcy_46 = format_amount_string( i_currency = 'VND' i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_46 ) ).
          <lfs_zpm01>-amountinbalancetransaccrcy_47 = format_amount_string( i_currency = 'VND' i_input = CONV string( <lfs_zpm01>-amountinbalancetransaccrcy_47 ) ).


* Start - Get data lt_journal_entrys
          MOVE-CORRESPONDING <lfs_zpm01> TO ls_journal_entry.

*          ls_journal_entry-journalentrylastchangedatetime = ls_journal_entry-journalentrylastchangedatetime+0(8).
          ls_journal_entry-journalentrylastchangedatetime = ls_journal_entry-postingdate.
          ls_journal_entry-glaccount_27 = <lfs_zpm01>-glaccount.

*           if ls_journal_entry-postingdate is not INITIAL.
*              ls_journal_entry-postingdate = get_formatted_date( CONV d( ls_journal_entry-postingdate ) ).
*           endif.
*           if ls_journal_entry-journalentrylastchangedatetime is not INITIAL.
*              ls_journal_entry-journalentrylastchangedatetime = get_formatted_date( CONV d( ls_journal_entry-journalentrylastchangedatetime ) ).
*           endif.

          ls_supplier-ct13_cpsn_vnd   = ls_supplier-ct13_cpsn_vnd + <lfs_zpm01>-ct30_curr.
          ls_supplier-ct14_cpsc_vnd   = ls_supplier-ct14_cpsc_vnd + <lfs_zpm01>-ct31_curr.
          ls_supplier-ct15_cpsn       = ls_supplier-ct15_cpsn + <lfs_zpm01>-ct32_curr.
          ls_supplier-ct16_cpsc       = ls_supplier-ct16_cpsc + <lfs_zpm01>-ct33_curr.
          ls_supplier-ct44_cpsn       = ls_supplier-ct44_cpsn +  ( <lfs_zpm01>-ct30_curr + <lfs_zpm01>-ct32_curr * (  <lfs_zpm01>-taxexchangerate * 10 ) ).
          ls_supplier-ct45_cpsc       = ls_supplier-ct45_cpsc +  ( <lfs_zpm01>-ct31_curr + <lfs_zpm01>-ct33_curr * (  <lfs_zpm01>-taxexchangerate * 10 ) ).
          IF <lfs_zpm01>-accountingdocument IS NOT INITIAL.
            APPEND ls_journal_entry TO lt_journal_entrys.

          ENDIF.
          CLEAR: ls_journal_entry.

* End - Get data lt_journal_entrys

* Start - Get data lt_suppliers


          AT END OF supplier.
            MOVE-CORRESPONDING <lfs_zpm01> TO ls_supplier_header.
 IF <lfs_zpm01>-accountingdocument IS not INITIAL.
            READ TABLE lt_group_dauky ASSIGNING FIELD-SYMBOL(<lfs_dauky>) WITH KEY  companycode = <lfs_zpm01>-companycode
                                                                                         supplier = <lfs_zpm01>-supplier BINARY SEARCH.
            IF sy-subrc = 0.

              if <lfs_dauky>-dauky_vnd >= 0.
                ls_supplier_header-ct9_nodk_vnd = <lfs_dauky>-dauky_vnd .
              endif.
              if <lfs_dauky>-dauky_vnd < 0.

              ls_supplier_header-ct10_codk_vnd =  ABS( <lfs_dauky>-dauky_vnd ).
              endif.
               if <lfs_dauky>-dauky_nt_vnd >= 0.

               ls_supplier_header-ct11_nodk = <lfs_dauky>-dauky_nt.
              endif.
               if <lfs_dauky>-dauky_nt_vnd < 0.

             ls_supplier_header-ct12_codk = ABS( <lfs_dauky>-dauky_nt ).
              endif.
*              ls_supplier_header-ct9_nodk_vnd = abs( <lfs_dauky>-ct9_dauky_vnd ).
*              ls_supplier_header-ct10_codk_vnd = abs( <lfs_dauky>-ct10_dauky_vnd ).
*              ls_supplier_header-ct11_nodk = abs( <lfs_dauky>-ct11_dauky ).
*              ls_supplier_header-ct12_codk = abs( <lfs_dauky>-ct12_dauky ).

              IF <lfs_dauky>-dauky >= 0.
              ls_supplier_header-ct44_nodk =  <lfs_dauky>-dauky.
          ELSE.
              ls_supplier_header-ct45_codk = abs( <lfs_dauky>-dauky ).
              ENDIF.

*              ls_supplier_header-ct44_nodk = ls_supplier_header-ct44_nodk + ( ls_supplier_header-ct9_nodk_vnd + <lfs_dauky>-dauky_no ).
*              ls_supplier_header-ct45_codk = ls_supplier_header-ct45_codk + ( ls_supplier_header-ct10_codk_vnd + abs( <lfs_dauky>-dauky_co ) ).

              ls_post-sum_ct9   = ls_post-sum_ct9 + ls_supplier_header-ct9_nodk_vnd.
              ls_post-sum_ct10  = ls_post-sum_ct10 + ls_supplier_header-ct10_codk_vnd.

              ls_post-sum_ct11  = ls_post-sum_ct11 + ls_supplier_header-ct11_nodk.
              ls_post-sum_ct12  = ls_post-sum_ct12 + ls_supplier_header-ct12_codk.


              ls_post-sum_nosddk  = ls_post-sum_nosddk + ls_supplier_header-ct44_nodk.
              ls_post-sum_cosddk  = ls_post-sum_cosddk + ls_supplier_header-ct45_codk.

            ENDIF.

           ELSE.
              ls_supplier_header-ct9_nodk_vnd = abs( <lfs_zpm01>-ct9_nodk_vnd ).
              ls_supplier_header-ct10_codk_vnd = abs( <lfs_zpm01>-ct10_codk_vnd ).
              ls_supplier_header-ct11_nodk = abs( <lfs_zpm01>-ct11_nodk ).
              ls_supplier_header-ct12_codk = abs( <lfs_zpm01>-ct12_codk ).

              ls_supplier_header-ct44_nodk = <lfs_zpm01>-ct44_nodk .
              ls_supplier_header-ct45_codk =  abs( <lfs_zpm01>-ct45_codk ) .

              ls_post-sum_ct9   = ls_post-sum_ct9 + ls_supplier_header-ct9_nodk_vnd .
              ls_post-sum_ct10  = ls_post-sum_ct10 + ls_supplier_header-ct10_codk_vnd.
              ls_post-sum_ct11  = ls_post-sum_ct11 + ls_supplier_header-ct11_nodk.
              ls_post-sum_ct12  = ls_post-sum_ct12 + ls_supplier_header-ct12_codk.
              ls_post-sum_nosddk  = ls_post-sum_nosddk + ls_supplier_header-ct44_nodk.
              ls_post-sum_cosddk  = ls_post-sum_cosddk + ls_supplier_header-ct45_codk.
            ENDIF.


            ls_supplier_header-ct13_cpsn_vnd = ls_supplier-ct13_cpsn_vnd.
            ls_supplier_header-ct14_cpsc_vnd = ls_supplier-ct14_cpsc_vnd.
            ls_supplier_header-ct15_cpsn = ls_supplier-ct15_cpsn.
            ls_supplier_header-ct16_cpsc = ls_supplier-ct16_cpsc.

            ls_supplier_header-ct44_cpsn = ls_supplier-ct44_cpsn.
            ls_supplier_header-ct45_cpsc = ls_supplier-ct45_cpsc.

            IF ( ls_supplier_header-ct44_nodk - ls_supplier_header-ct45_codk + ls_supplier-ct44_cpsn - ls_supplier-ct45_cpsc ) > 0.
              ls_supplier_header-ct45_sdnck =  ls_supplier_header-ct44_nodk - ls_supplier_header-ct45_codk + ls_supplier-ct44_cpsn - ls_supplier-ct45_cpsc.
            ELSE.
              ls_supplier_header-ct45_sdcck = abs( ls_supplier_header-ct44_nodk - ls_supplier_header-ct45_codk + ls_supplier-ct44_cpsn - ls_supplier-ct45_cpsc ).
            ENDIF.


            IF ( ls_supplier_header-ct9_nodk_vnd - ls_supplier_header-ct10_codk_vnd + ls_supplier-ct13_cpsn_vnd - ls_supplier-ct14_cpsc_vnd ) > 0.
              ls_supplier_header-ct17_sdnck_vnd =  ls_supplier_header-ct9_nodk_vnd - ls_supplier_header-ct10_codk_vnd + ls_supplier-ct13_cpsn_vnd - ls_supplier-ct14_cpsc_vnd.
            ELSE.
              ls_supplier_header-ct18_sdcck_vnd = abs( ls_supplier_header-ct9_nodk_vnd - ls_supplier_header-ct10_codk_vnd + ls_supplier-ct13_cpsn_vnd - ls_supplier-ct14_cpsc_vnd ).
            ENDIF.
            IF ( ls_supplier_header-ct11_nodk - ls_supplier_header-ct12_codk + ls_supplier-ct15_cpsn - ls_supplier-ct16_cpsc ) > 0.
              ls_supplier_header-ct19_sdnck =  ls_supplier_header-ct11_nodk - ls_supplier_header-ct12_codk + ls_supplier-ct15_cpsn - ls_supplier-ct16_cpsc.
            ELSE.
              ls_supplier_header-ct20_sdcck = abs( ls_supplier_header-ct11_nodk - ls_supplier_header-ct12_codk + ls_supplier-ct15_cpsn - ls_supplier-ct16_cpsc ).
            ENDIF.

            ls_post-sum_cpsn_vnd = ls_post-sum_cpsn_vnd + ls_supplier_header-ct13_cpsn_vnd.
            ls_post-sum_cpsc_vnd = ls_post-sum_cpsc_vnd + ls_supplier_header-ct14_cpsc_vnd.
            ls_post-sum_cpsn = ls_post-sum_cpsn + ls_supplier_header-ct15_cpsn.
            ls_post-sum_cpsc = ls_post-sum_cpsc + ls_supplier_header-ct16_cpsc.

*            ls_post-sum_sdnck_vnd = ls_post-sum_sdnck_vnd + ls_supplier_header-ct17_sdnck_vnd.
*            ls_post-sum_sdcck_vnd = ls_post-sum_sdcck_vnd + ls_supplier_header-ct18_sdcck_vnd.
ls_post-sum_sdnck_vnd = ls_post-sum_sdnck_vnd + ( ls_supplier_header-ct9_nodk_vnd - ls_supplier_header-ct10_codk_vnd + ls_supplier-ct13_cpsn_vnd - ls_supplier-ct14_cpsc_vnd ).
*            ls_post-sum_sdnck = ls_post-sum_sdnck + ls_supplier_header-ct19_sdnck.
*            ls_post-sum_sdcck = ls_post-sum_sdcck + ls_supplier_header-ct20_sdcck.
 ls_post-sum_sdnck = ls_post-sum_sdnck + ( ls_supplier_header-ct11_nodk - ls_supplier_header-ct12_codk + ls_supplier-ct15_cpsn - ls_supplier-ct16_cpsc ).

            ls_post-sum_cpsn_lk = ls_post-sum_cpsn_lk + ls_supplier_header-ct44_cpsn.
            ls_post-sum_cpsc_lk  = ls_post-sum_cpsc_lk + ls_supplier_header-ct45_cpsc.
*            ls_post-sum_sdnck_lk = ls_post-sum_sdnck_lk + ls_supplier_header-ct45_sdnck.
*            ls_post-sum_sdcck_lk  = ls_post-sum_sdcck_lk + ls_supplier_header-ct45_sdcck.
ls_post-sum_sdnck_lk = ls_post-sum_sdnck_lk + ( ls_supplier_header-ct44_nodk - ls_supplier_header-ct45_codk + ls_supplier-ct44_cpsn - ls_supplier-ct45_cpsc ).

            ls_supplier-ct13_cpsn_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier-ct13_cpsn_vnd ) ).
            ls_supplier-ct14_cpsc_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier-ct14_cpsc_vnd ) ).
            ls_supplier-ct15_cpsn     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier-ct15_cpsn ) ).
            ls_supplier-ct16_cpsc     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier-ct16_cpsc ) ).

            ls_supplier_header-ct9_nodk_vnd  = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct9_nodk_vnd ) ).
            ls_supplier_header-ct10_codk_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct10_codk_vnd ) ).
            ls_supplier_header-ct11_nodk     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct11_nodk ) ).
            ls_supplier_header-ct12_codk     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct12_codk ) ).

            ls_supplier_header-ct13_cpsn_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct13_cpsn_vnd ) ).
            ls_supplier_header-ct14_cpsc_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct14_cpsc_vnd ) ).
            ls_supplier_header-ct15_cpsn     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct15_cpsn ) ).
            ls_supplier_header-ct16_cpsc     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct16_cpsc ) ).
            ls_supplier_header-ct17_sdnck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct17_sdnck_vnd ) ).
            ls_supplier_header-ct18_sdcck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct18_sdcck_vnd ) ).
            ls_supplier_header-ct19_sdnck     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct19_sdnck ) ).
            ls_supplier_header-ct20_sdcck     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_supplier_header-ct20_sdcck ) ).

            ls_supplier_header-ct44_nodk = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct44_nodk ) ).
            ls_supplier_header-ct45_codk = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct45_codk ) ).

            ls_supplier_header-ct44_cpsn = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct44_cpsn ) ).
            ls_supplier_header-ct45_cpsc = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct45_cpsc ) ).

            ls_supplier_header-ct45_sdnck = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct45_sdnck ) ).
            ls_supplier_header-ct45_sdcck = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_supplier_header-ct45_sdcck ) ).


            ls_supplier_header-journal_entrys = lt_journal_entrys.
            APPEND ls_supplier_header TO lt_suppliers.
            CLEAR: ls_supplier,ls_supplier_header,lt_journal_entrys.
          ENDAT.


        ENDLOOP.

ls_post-sum_ct9      = 0.
ls_post-sum_ct10     = 0.
ls_post-sum_ct11     = 0.
ls_post-sum_ct12     = 0.
ls_post-sum_nosddk   = 0.
ls_post-sum_cosddk   = 0.
 READ TABLE lt_dauky ASSIGNING FIELD-SYMBOL(<lfs_dauky_tong>) INDEX 1.
            IF sy-subrc = 0.

              if <lfs_dauky_tong>-dauky_vnd >= 0.
                ls_post-sum_ct9 = <lfs_dauky_tong>-dauky_vnd .
              endif.
              if <lfs_dauky_tong>-dauky_vnd < 0.

               ls_post-sum_ct10 =  ABS( <lfs_dauky_tong>-dauky_vnd ).
              endif.
               if <lfs_dauky_tong>-dauky_nt_vnd >= 0.

               ls_post-sum_ct11 = <lfs_dauky_tong>-dauky_nt.
              endif.
               if <lfs_dauky_tong>-dauky_nt_vnd < 0.

             ls_post-sum_ct12 = ABS( <lfs_dauky_tong>-dauky_nt ).
              endif.
              IF <lfs_dauky_tong>-dauky >= 0.
              ls_post-sum_nosddk =  <lfs_dauky_tong>-dauky.
            ELSE.
              ls_post-sum_cosddk = abs( <lfs_dauky_tong>-dauky ).
              ENDIF.
         ENDIF.

        ls_post-sum_ct9                  = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_ct9 ) ).
        ls_post-sum_ct10                 = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_ct10 ) ).
        ls_post-sum_ct11                 = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_ct11 ) ).
        ls_post-sum_ct12                 = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_ct12 ) ).

        ls_post-sum_cpsn_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_cpsn_vnd ) ).
        ls_post-sum_cpsc_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_cpsc_vnd ) ).
        ls_post-sum_cpsn     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_cpsn ) ).
        ls_post-sum_cpsc     = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_cpsc ) ).

if ls_post-sum_sdnck_vnd >= 0.
  ls_post-sum_sdnck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_sdnck_vnd ) ).
  ELSE.
 ls_post-sum_sdnck_vnd = abs( ls_post-sum_sdnck_vnd ).
  ls_post-sum_sdcck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_sdnck_vnd ) ).
ls_post-sum_sdnck_vnd = 0.
endif.
*        ls_post-sum_sdnck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_sdnck_vnd ) ).
*        ls_post-sum_sdcck_vnd = format_amount_string( i_currency = 'VND' i_input = CONV string( ls_post-sum_sdcck_vnd ) ).
if ls_post-sum_sdnck >= 0.
ls_post-sum_sdnck    = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_sdnck ) ).
  ELSE.
     ls_post-sum_sdnck = abs( ls_post-sum_sdnck ).
ls_post-sum_sdcck   = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_sdnck ) ).
ls_post-sum_sdnck  = 0.
endif.
*        ls_post-sum_sdnck    = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_sdnck ) ).
*        ls_post-sum_sdcck    = format_amount_string( i_currency = 'USD' i_input = CONV string( ls_post-sum_sdcck ) ).


        ls_post-sum_nosddk    = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_nosddk ).
        ls_post-sum_cosddk    = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_cosddk ).
        ls_post-sum_cpsn_lk   = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_cpsn_lk ).
        ls_post-sum_cpsc_lk   = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_cpsc_lk ).
if ls_post-sum_sdnck_lk >= 0 .
        ls_post-sum_sdnck_lk  = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_sdnck_lk ).
else.
   ls_post-sum_sdnck_lk = abs(  ls_post-sum_sdnck_lk ).
   ls_post-sum_sdcck_lk  = format_amount_string( i_currency = 'VND'
                                                      i_input    = ls_post-sum_sdnck_lk ).
    ls_post-sum_sdnck_lk  = 0 .
endif.
*        ls_post-sum_sdnck_lk  = format_amount_string( i_currency = 'VND'
*                                                      i_input    = ls_post-sum_sdnck_lk ).
*        ls_post-sum_sdcck_lk  = format_amount_string( i_currency = 'VND'
*                                                      i_input    = ls_post-sum_sdcck_lk ).

        READ TABLE lt_nguoilap_range ASSIGNING FIELD-SYMBOL(<lfs_nguoilap>) INDEX 1.
        IF sy-subrc = 0.
          ls_post-nguoilap = <lfs_nguoilap>-low.
        ENDIF.
        READ TABLE lt_ketoantruong_range ASSIGNING FIELD-SYMBOL(<lfs_ketoantruong>) INDEX 1.
        IF sy-subrc = 0.
          ls_post-ketoantruong = <lfs_ketoantruong>-low.
        ENDIF.
        READ TABLE lt_giamdoc_range ASSIGNING FIELD-SYMBOL(<lfs_giamdoc>) INDEX 1.
        IF sy-subrc = 0.
          ls_post-giamdoc = <lfs_giamdoc>-low.
        ENDIF.

        READ TABLE lt_postingdate_range ASSIGNING FIELD-SYMBOL(<lfs_postingdate>) INDEX 1.
        IF sy-subrc = 0.
          IF <lfs_postingdate>-high IS NOT INITIAL.
            ls_post-day = |Từ ngày: { get_formatted_date( CONV d( <lfs_postingdate>-low ) ) } - Đến ngày: { get_formatted_date( CONV d( <lfs_postingdate>-high ) )  } | .
          ELSE.
            ls_post-day = |Từ ngày: { get_formatted_date( CONV d( <lfs_postingdate>-low ) ) } - Đến ngày: { get_formatted_date( CONV d( <lfs_postingdate>-low ) ) } | .
          ENDIF.
        ELSE.
*        ls_post-day = <lfs_postingdate>-low.
        ENDIF.
        SORT lt_glaccount_range BY low high.
        IF lt_glaccount_range IS INITIAL.
          ls_post-tk = 'All'.
        ELSE.
          IF lines( lt_glaccount_range ) = 1
   AND lt_glaccount_range[ 1 ]-sign = 'I'
     AND lt_glaccount_range[ 1 ]-option = 'EQ' .

            DATA(lv_glaccount) = lt_glaccount_range[ 1 ]-low.
            SELECT SINGLE glaccountlongname
         FROM i_glaccounttext
         WHERE language = @sy-langu
           AND chartofaccounts = 'YCOA'
           AND glaccount = @lv_glaccount
           INTO @DATA(lv_glaccounttext).

            ls_post-tk = lv_glaccount && ' - ' && lv_glaccounttext.
          ELSEIF  lines( lt_glaccount_range ) = 1
       AND lt_glaccount_range[ 1 ]-sign = 'I'
         AND lt_glaccount_range[ 1 ]-option = 'BT' .
            ls_post-tk = 'Từ: ' && lt_glaccount_range[ 1 ]-low && ' Đến: ' && lt_glaccount_range[ 1 ]-high.
          ELSE.

            LOOP AT lt_glaccount_range ASSIGNING FIELD-SYMBOL(<lfs_glaccount>).
              IF ls_post-tk IS INITIAL.
                ls_post-tk = <lfs_glaccount>-low.
              ELSE.
                ls_post-tk = ls_post-tk && ',' && <lfs_glaccount>-low.
              ENDIF.


            ENDLOOP.
          ENDIF.
        ENDIF.

        TRY.
            DATA(lv_time) = cl_abap_context_info=>get_system_time( ).

            DATA(lv_formatted_time) = |{ lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }|.
            ls_post-day_print = |{  get_formatted_date( cl_abap_context_info=>get_system_date( ) ) },{ lv_formatted_time },{ cl_abap_context_info=>get_user_formatted_name( ) } |.
          CATCH cx_abap_context_info_error INTO DATA(lx_ctx).
            DATA(lv_error) = lx_ctx->get_text( ).  " Hoặc ghi log, v.v.
        ENDTRY.
        ls_post-suppliers = lt_suppliers.


        TRY.
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
                 iv_service_instance_name   = 'ZADSTEMPLSTORE'
                 iv_use_destination_service = abap_false
               ).

*            DATA(ls_template) = lo_store->get_template_by_name(
*              iv_get_binary    = abap_true
*              iv_form_name     = 'ZFA_F_ZPM01'
*              iv_template_name = 'ZFA_F_ZPM01'
*            ).
            DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZPM01' ).
          CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error1).
            DATA(lv_err1) = lx_error1->get_text( ).  " Hoặc ghi log, v.v.
        ENDTRY.

        DATA: lv_xml TYPE string.

        lv_xml = '<Header>'.

        lv_xml = |{ lv_xml }<tencty_en>{ ls_post-tencty_vn }</tencty_en>|.
        lv_xml = |{ lv_xml }<diachi_en>{ ls_post-diachi_vn }</diachi_en>|.
        lv_xml = |{ lv_xml }<mst>Mã số thuế: { ls_post-mst }</mst>|.
        lv_xml = |{ lv_xml }<tk>{ ls_post-tk }</tk>|.
        lv_xml = |{ lv_xml }<day>{ ls_post-day }</day>|.
        lv_xml = |{ lv_xml }<nguoilap>{ ls_post-nguoilap }</nguoilap>|.

        " --- Tổng đầu kỳ ---
        lv_xml = |{ lv_xml }<sum_nosddk>{ ls_post-sum_nosddk }</sum_nosddk>|. " mới thêm
        lv_xml = |{ lv_xml }<sum_cosddk>{ ls_post-sum_cosddk }</sum_cosddk>|. " mới thêm

        lv_xml = |{ lv_xml }<sum_cpsn_vnd>{ ls_post-sum_cpsn_vnd }</sum_cpsn_vnd>|.
        lv_xml = |{ lv_xml }<sum_cpsc_vnd>{ ls_post-sum_cpsc_vnd }</sum_cpsc_vnd>|.
        lv_xml = |{ lv_xml }<sum_cpsn>{ ls_post-sum_cpsn }</sum_cpsn>|.
        lv_xml = |{ lv_xml }<sum_cpsc>{ ls_post-sum_cpsc }</sum_cpsc>|.

        lv_xml = |{ lv_xml }<sum_sdnck_vnd>{ ls_post-sum_sdnck_vnd }</sum_sdnck_vnd>|.
        lv_xml = |{ lv_xml }<sum_sdcck_vnd>{ ls_post-sum_sdcck_vnd }</sum_sdcck_vnd>|.
        lv_xml = |{ lv_xml }<sum_sdnck>{ ls_post-sum_sdnck }</sum_sdnck>|.
        lv_xml = |{ lv_xml }<sum_sdcck>{ ls_post-sum_sdcck }</sum_sdcck>|.

        lv_xml = |{ lv_xml }<ketoantruong>{ ls_post-ketoantruong }</ketoantruong>|.
        lv_xml = |{ lv_xml }<giamdoc>{ ls_post-giamdoc }</giamdoc>|.
        lv_xml = |{ lv_xml }<day_print>{ ls_post-day_print }</day_print>|.

        lv_xml = |{ lv_xml }<sum_ct9>{ ls_post-sum_ct9 }</sum_ct9>|.
        lv_xml = |{ lv_xml }<sum_ct10>{ ls_post-sum_ct10 }</sum_ct10>|.
        lv_xml = |{ lv_xml }<sum_ct11>{ ls_post-sum_ct11 }</sum_ct11>|.
        lv_xml = |{ lv_xml }<sum_ct12>{ ls_post-sum_ct12 }</sum_ct12>|.

        lv_xml = |{ lv_xml }<sum_cpsn_LK>{ ls_post-sum_cpsn_lk }</sum_cpsn_LK>|.
        lv_xml = |{ lv_xml }<sum_cpsc_LK>{ ls_post-sum_cpsc_lk }</sum_cpsc_LK>|.
        lv_xml = |{ lv_xml }<sum_sdnck_LK>{ ls_post-sum_sdnck_lk }</sum_sdnck_LK>|.
        lv_xml = |{ lv_xml }<sum_sdcck_LK>{ ls_post-sum_sdcck_lk }</sum_sdcck_LK>|.


        lv_xml = |{ lv_xml }<Suppliers>|.

        LOOP AT ls_post-suppliers INTO DATA(ls_supplierxml).
          lv_xml = |{ lv_xml }<Supplier>|.

          lv_xml = |{ lv_xml }<supplieraccountgroup>{ ls_supplierxml-supplieraccountgroup }</supplieraccountgroup>|.
          lv_xml = |{ lv_xml }<ncc>{ escape( val = ls_supplierxml-ncc format = cl_abap_format=>e_xml_text ) }</ncc>|.

          " --- Đầu kỳ ---
          lv_xml = |{ lv_xml }<ct9_nodk_vnd>{ ls_supplierxml-ct9_nodk_vnd }</ct9_nodk_vnd>|.
          lv_xml = |{ lv_xml }<ct10_codk_vnd>{ ls_supplierxml-ct10_codk_vnd }</ct10_codk_vnd>|.
          lv_xml = |{ lv_xml }<ct11_nodk>{ ls_supplierxml-ct11_nodk }</ct11_nodk>|.
          lv_xml = |{ lv_xml }<ct12_codk>{ ls_supplierxml-ct12_codk }</ct12_codk>|.
          lv_xml = |{ lv_xml }<ct44_nodk>{ ls_supplierxml-ct44_nodk }</ct44_nodk>|. " mới thêm
          lv_xml = |{ lv_xml }<ct45_codk>{ ls_supplierxml-ct45_codk }</ct45_codk>|. " mới thêm

          " --- PS ---
          lv_xml = |{ lv_xml }<ct13_cpsn_vnd>{ ls_supplierxml-ct13_cpsn_vnd }</ct13_cpsn_vnd>|.
          lv_xml = |{ lv_xml }<ct14_cpsc_vnd>{ ls_supplierxml-ct14_cpsc_vnd }</ct14_cpsc_vnd>|.
          lv_xml = |{ lv_xml }<ct15_cpsn>{ ls_supplierxml-ct15_cpsn }</ct15_cpsn>|.
          lv_xml = |{ lv_xml }<ct16_cpsc>{ ls_supplierxml-ct16_cpsc }</ct16_cpsc>|.

          lv_xml = |{ lv_xml }<ct44_cpsn>{ ls_supplierxml-ct44_cpsn }</ct44_cpsn>|. " mới thêm
          lv_xml = |{ lv_xml }<ct45_cpsc>{ ls_supplierxml-ct45_cpsc }</ct45_cpsc>|. " mới thêm

          " --- CK ---
          lv_xml = |{ lv_xml }<ct17_sdnck_vnd>{ ls_supplierxml-ct17_sdnck_vnd }</ct17_sdnck_vnd>|.
          lv_xml = |{ lv_xml }<ct18_sdcck_vnd>{ ls_supplierxml-ct18_sdcck_vnd }</ct18_sdcck_vnd>|.
          lv_xml = |{ lv_xml }<ct19_sdnck>{ ls_supplierxml-ct19_sdnck }</ct19_sdnck>|.
          lv_xml = |{ lv_xml }<ct20_sdcck>{ ls_supplierxml-ct20_sdcck }</ct20_sdcck>|.

          lv_xml = |{ lv_xml }<ct45_sdnck>{ ls_supplierxml-ct45_sdnck }</ct45_sdnck>|. " mới thêm
          lv_xml = |{ lv_xml }<ct45_sdcck>{ ls_supplierxml-ct45_sdcck }</ct45_sdcck>|. " mới thêm

          " --- JournalEntries ---
          lv_xml = |{ lv_xml }<JournalEntrys>|.
          LOOP AT ls_supplierxml-journal_entrys INTO DATA(ls_entry).

            lv_xml = |{ lv_xml }<JournalEntry>|.

            lv_xml = |{ lv_xml }<accountingdocument>{ ls_entry-accountingdocument }</accountingdocument>|.
            lv_xml = |{ lv_xml }<journalentrylastchangedatetime>{ ls_entry-journalentrylastchangedatetime }</journalentrylastchangedatetime>|.
            lv_xml = |{ lv_xml }<postingdate>{ ls_entry-postingdate }</postingdate>|.
            lv_xml = |{ lv_xml }<documentreferenceid>{ ls_entry-documentreferenceid }</documentreferenceid>|.
            lv_xml = |{ lv_xml }<accountingdocumentheadertext>{ ls_entry-accountingdocumentheadertext }</accountingdocumentheadertext>|.
            lv_xml = |{ lv_xml }<glaccount_26>{ ls_entry-glaccount_26 }</glaccount_26>|.
            lv_xml = |{ lv_xml }<glaccount_27>{ ls_entry-glaccount_27 }</glaccount_27>|.
            lv_xml = |{ lv_xml }<transactioncurrency>{ ls_entry-transactioncurrency }</transactioncurrency>|.
            IF ls_entry-transactioncurrency = 'VND'.
              lv_xml = |{ lv_xml }<taxexchangerate></taxexchangerate>|.
            ELSE.
              lv_xml = |{ lv_xml }<taxexchangerate>{ ls_entry-taxexchangerate }</taxexchangerate>|.
            ENDIF.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_30>{ ls_entry-amountinbalancetransaccrcy_30 }</amountinbalancetransaccrcy_30>|.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_31>{ ls_entry-amountinbalancetransaccrcy_31 }</amountinbalancetransaccrcy_31>|.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_32>{ ls_entry-amountinbalancetransaccrcy_32 }</amountinbalancetransaccrcy_32>|.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_33>{ ls_entry-amountinbalancetransaccrcy_33 }</amountinbalancetransaccrcy_33>|.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_46>{ ls_entry-amountinbalancetransaccrcy_46 }</amountinbalancetransaccrcy_46>|.
            lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_47>{ ls_entry-amountinbalancetransaccrcy_47 }</amountinbalancetransaccrcy_47>|.
            lv_xml = |{ lv_xml }</JournalEntry>|.

          ENDLOOP.
          lv_xml = |{ lv_xml }</JournalEntrys>|.

          lv_xml = |{ lv_xml }</Supplier>|.
        ENDLOOP.

        lv_xml = |{ lv_xml }</Suppliers>|.

        lv_xml = |{ lv_xml }</Header>|.



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

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_print>) .

*        IF <lfs_print>-attachment IS INITIAL.
          <lfs_print>-attachment = lv_pdf.
          <lfs_print>-mimetype = 'application/pdf'.
          <lfs_print>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.

*        ENDIF.
        ENDLOOP.

        DATA(lo_saver) = NEW zcl_save_pdf( ).

*        lo_saver->save_pdf(
*          iv_reportid = 'ZFA_ZPM01'
*          iv_objectid      = lv_uuid_fi
*          iv_pdf      = lv_pdf
*        ).
        DELETE lt_result WHERE flag = 'X'.
      ELSE.
if lt_result is INITIAL.
  APPEND ls_result to lt_result.
endif.
        READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>) INDEX 1.
        IF sy-subrc = 0.
          READ TABLE lt_pdf ASSIGNING FIELD-SYMBOL(<lfs_pdf>) INDEX 1.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING <lfs_pdf> TO <lfs_result>.
          ENDIF.
        ENDIF.

      ENDIF.




 " Request Sorting
      DATA: lv_sort_string TYPE string.
      DATA(sort_elements) = io_request->get_sort_elements( ).
      IF sort_elements IS NOT INITIAL.

  DATA(lt_sort_criteria) = VALUE string_table(
     FOR sort_element IN sort_elements
     ( sort_element-element_name )
*      &&
*       COND #( WHEN sort_element-descending = abap_true
*               THEN ' DESCENDING'
*               ELSE ' ASCENDING' ) )
  ).

  IF lt_sort_criteria IS NOT INITIAL.
    lv_sort_string = concat_lines_of( table = lt_sort_criteria sep = ` ` ).
  ENDIF.

  TRY.
      SORT lt_result BY (lv_sort_string).

    CATCH cx_sy_dynamic_osql_error INTO DATA(lx_sort).
SORT lt_result BY supplieraccountgroup postingdate journalentrylastchangedatetime accountingdocument.
  ENDTRY.
      ELSE.
      SORT lt_result BY supplieraccountgroup postingdate journalentrylastchangedatetime accountingdocument.
      ENDIF.


      IF top < 0.
        top = 1.
      ENDIF.

      IF lines( lt_result ) > 1.
        LOOP AT lt_result INTO DATA(ls_row) FROM skip + 1 TO skip + top.
          APPEND ls_row TO lt_result_page.
        ENDLOOP.
      ELSE.
        lt_result_page = lt_result.
      ENDIF.

      io_response->set_data( lt_result_page ).
    ENDIF.

*
*  " Lấy thông tin phân trang từ request
*  lv_offset    = io_request->get_paging( )->get_offset( ).
*  lv_page_size = io_request->get_paging( )->get_page_size( ).
*
*  " Trả dữ liệu theo phân trang
*  LOOP AT lt_result INTO DATA(ls_line) FROM lv_offset + 1.
*    INSERT ls_line INTO TABLE lt_result_page.
*    ADD 1 TO lv_count.
*    IF lv_count >= lv_page_size.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*
*
*  " Trả về dữ liệu phân trang và tổng số bản ghi
*  io_response->set_data( lt_result_page ).


    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.
  ENDMETHOD.


  METHOD if_rap_query_request~get_aggregation.

  ENDMETHOD.


  METHOD if_rap_query_request~get_entity_id.

  ENDMETHOD.


  METHOD if_rap_query_request~get_filter.

  ENDMETHOD.


  METHOD if_rap_query_request~get_paging.

  ENDMETHOD.


  METHOD if_rap_query_request~get_parameters.

  ENDMETHOD.


  METHOD if_rap_query_request~get_requested_elements.

  ENDMETHOD.


  METHOD if_rap_query_request~get_search_expression.

  ENDMETHOD.


  METHOD if_rap_query_request~get_sort_elements.

  ENDMETHOD.


  METHOD if_rap_query_request~is_data_requested.

  ENDMETHOD.


  METHOD if_rap_query_request~is_total_numb_of_rec_requested.

  ENDMETHOD.
ENDCLASS.
