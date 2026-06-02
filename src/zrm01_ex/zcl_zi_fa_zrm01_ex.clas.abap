CLASS zcl_zi_fa_zrm01_ex DEFINITION
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



CLASS ZCL_ZI_FA_ZRM01_EX IMPLEMENTATION.


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
      lv_use_paren  = abap_true.
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

    IF lv_scaled = 0.
      r_output = ''.
      RETURN.
    ENDIF.
    " --- Format số có dấu phẩy phân tách ---
    lv_formatted = |{ abs( lv_scaled ) CURRENCY = i_currency NUMBER = USER }|.

    " --- Chuyển , thành . nếu cần (tuỳ locale bạn có thể giữ nguyên) ---
*  REPLACE ALL OCCURRENCES OF ',' IN lv_formatted WITH '.'.

    " --- Gắn dấu lại theo logic JS ---
    IF lv_negative = abap_true.
      IF lv_use_paren = abap_true AND lv_show_minus = abap_true.
        r_output = |({ lv_formatted }-)|.        " (123.000-)
      ELSEIF lv_use_paren = abap_true.
        r_output = |({ lv_formatted })|.         " (123.000)
      ELSE.
        r_output = |{ lv_formatted }-|.          " 123.000-
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
             z_invoiceno                    TYPE string,
             z_tokhai                       TYPE string,
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

    DATA: lt_post            TYPE TABLE OF lty_header,
          ls_post            TYPE lty_header,
          ls_supplier        TYPE lty_supplier,
          ls_supplier_header TYPE lty_supplier,
          lt_suppliers       TYPE TABLE OF lty_supplier,
          ls_suppliergroup   TYPE lty_header,
          lt_suppliersgroup  TYPE TABLE OF lty_header,
          ls_journal_entry   TYPE lty_journal_entry,
          lt_journal_entrys  TYPE TABLE OF lty_journal_entry.
    DATA:
      lt_result TYPE STANDARD TABLE OF zi_fa_zrm01_ex,
      ls_result TYPE zi_fa_zrm01_ex.

    DATA:
      lt_result_ex TYPE STANDARD TABLE OF zi_fa_zrm01_ex,
      ls_result_ex TYPE zi_fa_zrm01_ex.

    DATA:
      lt_result_dk TYPE STANDARD TABLE OF zi_fa_zrm01_ex,
      ls_result_dk TYPE zi_fa_zrm01_ex.

    DATA:
      lt_result_page TYPE STANDARD TABLE OF zi_fa_zrm01_ex,
      lv_offset      TYPE i,
      lv_page_size   TYPE i,
      lv_count       TYPE i VALUE 0.

    DATA: lv_amount30 TYPE p DECIMALS 2,
          lv_amount31 TYPE p DECIMALS 2,
          lv_amount32 TYPE p DECIMALS 2,
          lv_amount33 TYPE p DECIMALS 2.

    DATA:
      lv_stt     TYPE i,
      lv_stt_cps TYPE i.

    DATA: lv_layout TYPE string.

    DATA lv_uuid_fi          TYPE uuid.
    DATA lv_isreversal          TYPE co_stflg.
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
            DATA(lt_customer_range) = ls_filter-range.
          WHEN 'COMPANYCODE'.
            DATA(lt_companycode_range) = ls_filter-range.
          WHEN 'FISCALYEAR'.
            DATA(lt_fiscalyear_range) = ls_filter-range.
          WHEN 'POSTINGDATE'.
            DATA(lt_postingdate_range) = ls_filter-range.
          WHEN 'GLACCOUNT_26'.
            DATA(lt_glaccount_range) = ls_filter-range.
          WHEN 'SUPPLIERACCOUNTGROUP'.
            DATA(lt_customeraccountgroup_range) = ls_filter-range.
          WHEN 'ISREVERSAL'.
            DATA(lt_isreversal_range) = ls_filter-range.
*          WHEN 'ZLAYOUT'.
*            DATA(lt_layout_range) = ls_filter-range.
        ENDCASE.
      ENDLOOP.

    ENDIF.

DATA: lr_bukrs TYPE RANGE OF bukrs.

select
CompanyCode
from I_CompanyCode
wHERE CompanyCode is noT inITIAL
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
      ELSE.
        lv_isreversal = '3'.
      ENDIF.


*      READ TABLE lt_layout_range INTO DATA(ls_layout) INDEX 1.
*      IF sy-subrc = 0.
*        lv_layout = ls_layout-low.
*      ELSE.
      lv_layout = '01'.
*      ENDIF.

      SELECT
       customer~customer,
        item_journalentry~companycode,
                SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~amountincompanycodecurrency
            ELSE 0
          END
        ) AS dauky_vnd,
               SUM(
       item_journalentry~amountincompanycodecurrency

        ) AS dauky,
      SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountinbalancetransaccrcy
            ELSE 0
          END
        ) AS dauky_nt,
         SUM(
          CASE
            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountincompanycodecurrency
            ELSE 0
          END
        ) AS dauky_nt_vnd
*         SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~debitamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct9_dauky_vnd,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~creditamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct10_dauky_vnd,
*       SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN  item_journalentry~debitAmountInCoCodeCrcy
*            ELSE 0
*          END
*        ) AS dauky_no,
*               SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~creditAmountInCoCodeCrcy
*            ELSE 0
*          END
*        ) AS dauky_co,
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
      FROM i_customer AS customer
        INNER JOIN i_journalentryitem AS item_journalentry ON customer~customer = item_journalentry~customer AND item_journalentry~ledger = '0L'   AND item_journalentry~financialaccounttype = 'D'
        LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
            LEFT JOIN i_businesspartner ON i_businesspartner~businesspartner =  customer~customer
     WHERE
            customer~customer IN @lt_customer_range
        AND item_journalentry~companycode IN @lt_companycode_range
        AND journalentry~fiscalyear IN @lt_fiscalyear_range
        AND item_journalentry~glaccount IN @lt_glaccount_range
        AND journalentry~postingdate < @lv_min_date
         AND customer~customeraccountgroup IN @lt_customeraccountgroup_range
            AND i_businesspartner~ismarkedforarchiving IS INITIAL
           AND (
       (  journalentry~isreversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal = '3' )   )
       OR ( ( journalentry~isreversal = 'X' OR  journalentry~isreversed = 'X' ) AND @lv_isreversal = '1' ) )
      GROUP BY  customer~customer,
                item_journalentry~companycode
      INTO TABLE @DATA(lt_group_dauky).

      SELECT
customer~customeraccountgroup,
* SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~debitamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct9_dauky_vnd,
*        SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~creditamountinbalancetranscrcy
*            ELSE 0
*          END
*        ) AS ct10_dauky_vnd,
*       SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN  item_journalentry~debitAmountInCoCodeCrcy
**         * journalentry~absoluteexchangerate
**         * 10 AS DEC( 31,2 ) )
*            ELSE 0
*          END
*        ) AS dauky_no,
*       SUM(
*          CASE
*            WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN  item_journalentry~creditAmountInCoCodeCrcy
**         * journalentry~absoluteexchangerate
**         * 10 AS DEC( 31,2 ) )
*            ELSE 0
*          END
*        ) AS dauky_co,
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
SUM(
 item_journalentry~amountincompanycodecurrency

  ) AS dauky,
          SUM(
    CASE
      WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~amountincompanycodecurrency
      ELSE 0
    END
  ) AS dauky_vnd,
   SUM(
    CASE
      WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountinbalancetransaccrcy
      ELSE 0
    END
  ) AS dauky_nt,
           SUM(
    CASE
      WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountincompanycodecurrency
      ELSE 0
    END
  ) AS dauky_nt_vnd
FROM i_customer AS customer
  INNER JOIN i_journalentryitem AS item_journalentry ON customer~customer = item_journalentry~customer AND item_journalentry~ledger = '0L'   AND item_journalentry~financialaccounttype = 'D'
  LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
LEFT JOIN i_businesspartner ON i_businesspartner~businesspartner =  customer~customer
WHERE
customer~customer IN @lt_customer_range
AND item_journalentry~companycode IN @lt_companycode_range
AND journalentry~fiscalyear IN @lt_fiscalyear_range
AND item_journalentry~glaccount IN @lt_glaccount_range
AND journalentry~postingdate < @lv_min_date
AND customer~customeraccountgroup IN @lt_customeraccountgroup_range
AND i_businesspartner~ismarkedforarchiving IS INITIAL
AND (
 (  journalentry~isreversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal = '3' )   )
 OR ( ( journalentry~isreversal = 'X' OR  journalentry~isreversed = 'X' ) AND @lv_isreversal = '1' ) )
GROUP BY  customer~customeraccountgroup
ORDER BY customer~customeraccountgroup
INTO TABLE @DATA(lt_customergroup_dauky).


      SELECT
             customer~customeraccountgroup AS supplier_account_group,
             customer~customeraccountgroup && ' - ' && grouptext~accountgroupname AS supplieraccountgroup,
            customer~customer,
                    concat(
               concat(
                 ltrim( customer~customer, '0' ),
                 '-'
               ),
               bp~name
             ) AS ncc,
                     SUM(
            item_journalentry~amountincompanycodecurrency

             ) AS dauky,
                     SUM(
               CASE
                 WHEN item_journalentry~balancetransactioncurrency = 'VND'  THEN item_journalentry~amountincompanycodecurrency
                 ELSE 0
               END
             ) AS dauky_vnd,
              SUM(
               CASE
                 WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountinbalancetransaccrcy
                 ELSE 0
               END
             ) AS dauky_nt,
                      SUM(
               CASE
                 WHEN item_journalentry~balancetransactioncurrency <> 'VND'  THEN item_journalentry~amountincompanycodecurrency
                 ELSE 0
               END
             ) AS dauky_nt_vnd
           FROM i_customer AS customer
             INNER JOIN i_journalentryitem AS item_journalentry ON customer~customer = item_journalentry~customer AND item_journalentry~ledger = '0L'   AND item_journalentry~financialaccounttype = 'D'
             LEFT OUTER JOIN i_journalentry AS journalentry ON journalentry~accountingdocument = item_journalentry~accountingdocument
                LEFT JOIN zcds_bp AS bp
                 ON customer~customer = bp~businesspartner
      LEFT JOIN i_customeraccountgrouptext AS grouptext ON grouptext~customeraccountgroup = customer~customeraccountgroup AND grouptext~language = 'E'
         LEFT JOIN i_businesspartner ON i_businesspartner~businesspartner =  customer~customer
               WHERE customer~customer                IN @lt_customer_range
                 AND journalentry~companycode         IN @lt_companycode_range
                 AND journalentry~fiscalyear          IN @lt_fiscalyear_range
                  AND journalentry~postingdate < @lv_min_date
                 AND item_journalentry~glaccount      IN @lt_glaccount_range
                 AND customer~customeraccountgroup    IN @lt_customeraccountgroup_range
                    AND i_businesspartner~ismarkedforarchiving IS INITIAL
        AND (
            (  journalentry~isreversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal = '3' )   )
            OR ( ( journalentry~isreversal = 'X' OR  journalentry~isreversed = 'X' ) AND @lv_isreversal = '1' ) )
           GROUP BY  customer~customer,bp~name, customer~customeraccountgroup,grouptext~accountgroupname
            ORDER BY customer~customer
           INTO TABLE @DATA(lt_customer_dauky).


      SELECT
      customer~customeraccountgroup,
         customer~customer AS supplier,
          journalentry~companycode,
          journalentry~fiscalyear,
          journalentry~accountingdocument,
          journalentry~postingdate,
          journalentry~documentdate ,

        concat(
          concat(
            ltrim( customer~customer, '0' ),
            '-'
          ),
          bp~name
        ) AS ncc,
      substring(
        journalentry~documentreferenceid,
        instr( journalentry~documentreferenceid, '.' ) + 1,
        length( journalentry~documentreferenceid ) - instr( journalentry~documentreferenceid, '.' )
      ) AS documentreferenceid,
      journalentry~accountingdocumenttype,
                 journalentry~originalreferencedocument,
              bd~yy1_customdecleration_bdh AS z_tokhai,
         bd~yy1_invoiceno_bdh AS z_invoiceno,
          CASE
            WHEN journalentry~accountingdocumentheadertext IS NOT INITIAL
            THEN journalentry~accountingdocumentheadertext
            WHEN item_journalentry~documentitemtext IS NOT INITIAL
            THEN item_journalentry~documentitemtext
          END AS accountingdocumentheadertext,
      bd~billingdocument AS billingdoc,

item_journalentry~glaccount AS glaccount_26,
          CASE
            WHEN _customercompany~reconciliationaccount  IS NOT INITIAL
            THEN  _customercompany~reconciliationaccount
            ELSE item_journalentry~offsettingaccount
          END AS glaccount,
          journalentry~transactioncurrency,
          CASE
            WHEN journalentry~transactioncurrency <> 'VND'
            THEN  journalentry~absoluteexchangerate
          END AS taxexchangerate,
          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'S'
               AND item_journalentry~transactioncurrency = 'VND'
              THEN item_journalentry~amountincompanycodecurrency
              ELSE 0
            END
          AS DEC( 31,2 ) )  AS ct30_curr,

          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'H'
               AND item_journalentry~transactioncurrency = 'VND'
              THEN item_journalentry~amountincompanycodecurrency
              ELSE 0
            END
          AS DEC( 31,2 ) )  AS ct31_curr,

          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'S'
               AND item_journalentry~transactioncurrency <> 'VND'
              THEN item_journalentry~amountintransactioncurrency
              ELSE 0
            END
           AS DEC( 31,2 ) )  AS ct32_curr,

          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'H'
               AND item_journalentry~transactioncurrency <> 'VND'
              THEN item_journalentry~amountintransactioncurrency
              ELSE 0
            END
          AS DEC( 31,2 ) ) AS ct33_curr,

          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'S'
              THEN item_journalentry~amountincompanycodecurrency
              ELSE 0
            END
          AS DEC( 31,2 ) )  AS ct46_curr,

          CAST(
            CASE
              WHEN item_journalentry~debitcreditcode = 'H'
              THEN item_journalentry~amountincompanycodecurrency
              ELSE 0
            END
          AS DEC( 31,2 ) )  AS ct47_curr,

          customer~customeraccountgroup && ' - ' && grouptext~accountgroupname AS supplieraccountgroup,

          item_journalentry~balancetransactioncurrency,
          journalentry~isreversal

          FROM i_customer AS customer

          INNER JOIN i_journalentryitem AS item_journalentry
            ON customer~customer = item_journalentry~customer
           AND item_journalentry~financialaccounttype = 'D'
           AND item_journalentry~ledger = '0L'
LEFT JOIN i_customercompany  AS _customercompany              ON  item_journalentry~offsettingaccount = _customercompany~customer
          INNER JOIN i_journalentry AS journalentry
            ON journalentry~accountingdocument = item_journalentry~accountingdocument

          LEFT JOIN zcds_bp AS bp
            ON customer~customer = bp~businesspartner
 LEFT JOIN i_customeraccountgrouptext AS grouptext ON grouptext~customeraccountgroup = customer~customeraccountgroup AND grouptext~language = 'E'
          LEFT JOIN zcds_company AS _company
            ON journalentry~companycode = _company~companycode
LEFT OUTER JOIN i_billingdocument AS bd ON bd~billingdocument = journalentry~originalreferencedocument
              LEFT JOIN i_businesspartner ON i_businesspartner~businesspartner =  customer~customer
          WHERE customer~customer                IN @lt_customer_range
            AND journalentry~companycode         IN @lt_companycode_range
            AND journalentry~fiscalyear          IN @lt_fiscalyear_range
            AND journalentry~postingdate         IN @lt_postingdate_range
            AND item_journalentry~glaccount      IN @lt_glaccount_range
            AND customer~customeraccountgroup    IN @lt_customeraccountgroup_range
               AND i_businesspartner~ismarkedforarchiving IS INITIAL
     AND (
       (  journalentry~isreversed IN @lt_isreversal_range AND journalentry~isreversal IN @lt_isreversal_range AND ( @lv_isreversal = '0' OR @lv_isreversal = '3' )   )
       OR ( ( journalentry~isreversal = 'X' OR  journalentry~isreversed = 'X' ) AND @lv_isreversal = '1' ) )
        AND journalentry~companycode         IN @lr_bukrs
            ORDER BY customer~customeraccountgroup,customer~customer,journalentry~postingdate ,journalentry~accountingdocument
      INTO CORRESPONDING FIELDS OF TABLE @lt_result.

      SORT lt_result BY supplier postingdate accountingdocument.



      SELECT
        billingitem~billingdocument,
         tp~yy1_invoiceno_dlh
      FROM @lt_result AS data
      INNER JOIN i_billingdocumentitem AS billingitem
        ON billingitem~billingdocument = data~billingdoc
         LEFT OUTER JOIN i_deliverydocument AS tp   ON tp~deliverydocument = billingitem~referencesddocument
         GROUP BY billingdocument,tp~yy1_invoiceno_dlh
         ORDER BY billingdocument
      INTO TABLE @DATA(lt_outbound).

      SELECT
        billingitem~billingdocument,
         billingitem~billingdocumentitemtext
      FROM @lt_result AS data
      INNER JOIN i_billingdocumentitem AS billingitem
        ON billingitem~billingdocument = data~billingdoc
         ORDER BY billingdocument
      INTO TABLE @DATA(lt_itemtext).
 DELETE lt_customer_dauky WHERE dauky_vnd = 0 AND dauky_nt_vnd = 0 AND dauky = 0.
*Get data customr đầu kỳ không phát sinh giao dịch
      LOOP AT lt_customer_dauky ASSIGNING FIELD-SYMBOL(<fs_dauky>).

        READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_res>)
             WITH KEY supplier = <fs_dauky>-customer.
        IF sy-subrc <> 0.

          lv_stt = lv_stt + 1.
          ls_result-stt = lv_stt.
          ls_result-supplier = <fs_dauky>-customer.
          ls_result-ncc = <fs_dauky>-ncc.

          ls_result-supplieraccountgroup = <fs_dauky>-supplieraccountgroup.
          IF <fs_dauky>-dauky_vnd >= 0.
            ls_result-zno_vnd = <fs_dauky>-dauky_vnd.
          ELSE.
            ls_result-zco_vnd = abs( <fs_dauky>-dauky_vnd ).
          ENDIF.
          IF <fs_dauky>-dauky_nt_vnd >= 0.
            ls_result-zno_nt = <fs_dauky>-dauky_nt.
          ELSE.
            ls_result-zco_nt = abs( <fs_dauky>-dauky_nt ).
          ENDIF.

          IF <fs_dauky>-dauky >= 0.
            ls_result-zno = abs( <fs_dauky>-dauky ).
          ELSE.
            ls_result-zco = abs( <fs_dauky>-dauky ).
          ENDIF.



          APPEND ls_result TO lt_result.
          CLEAR ls_result.
        ENDIF.
      ENDLOOP.

      SORT lt_result BY customeraccountgroup supplier postingdate accountingdocument.
      lv_stt = lv_stt + 1.


      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_zrm01>) .

        IF lv_layout = '01'.
          AT NEW customeraccountgroup.

            lv_stt = lv_stt + 1.
            ls_result_ex-stt = lv_stt.
            ls_result_ex-supplier = <lfs_zrm01>-supplier.
            ls_result_ex-des = <lfs_zrm01>-supplieraccountgroup.
            ls_result_ex-stt = lv_stt.
            APPEND ls_result_ex TO lt_result_ex.
            CLEAR ls_result_ex.

            lv_stt = lv_stt + 1.
            ls_result_ex-stt = lv_stt.
            ls_result_ex-supplier = <lfs_zrm01>-supplier.
            ls_result_ex-des = 'Số dư đầu kỳ' && ' ' && <lfs_zrm01>-supplieraccountgroup.
            READ TABLE lt_customergroup_dauky ASSIGNING FIELD-SYMBOL(<lfs_cag_dauky>) WITH KEY  customeraccountgroup = <lfs_zrm01>-customeraccountgroup BINARY SEARCH.
            IF sy-subrc = 0.

              IF <lfs_cag_dauky>-dauky_vnd >= 0.
                ls_result_ex-zno_vnd =  <lfs_cag_dauky>-dauky_vnd.
              ELSE.
                ls_result_ex-zco_vnd = abs( <lfs_cag_dauky>-dauky_vnd ).
              ENDIF.

              IF <lfs_cag_dauky>-dauky_nt_vnd >= 0.
                ls_result_ex-zno_nt = <lfs_cag_dauky>-dauky_nt.
              ELSE.
                ls_result_ex-zco_nt = abs( <lfs_cag_dauky>-dauky_nt ).
              ENDIF.

              IF <lfs_cag_dauky>-dauky >= 0.
                ls_result_ex-zno = <lfs_cag_dauky>-dauky.
              ELSE.
                ls_result_ex-zco =  abs( <lfs_cag_dauky>-dauky ).
              ENDIF.


              ls_post-sum_ct9   = ls_post-sum_ct9 + <lfs_cag_dauky>-dauky_vnd.
              ls_post-sum_ct11  = ls_post-sum_ct11 + <lfs_cag_dauky>-dauky_nt.
              ls_post-sum_nosddk  = ls_post-sum_nosddk + <lfs_cag_dauky>-dauky.
            ENDIF.

            ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
            ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
            ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
            ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
            ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
            ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).

            APPEND ls_result_ex TO lt_result_ex.
            CLEAR ls_result_ex.

          ENDAT.
        ENDIF.

        AT NEW supplier.


          lv_stt = lv_stt + 1.
          ls_result_ex-stt = lv_stt.
          ls_result_ex-supplier = <lfs_zrm01>-supplier.
          ls_result_ex-des = <lfs_zrm01>-ncc.
          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.


          lv_stt = lv_stt + 1.
          ls_result_ex-stt = lv_stt.
          ls_result_ex-supplier = <lfs_zrm01>-supplier.
          ls_result_ex-des = 'Số dư đầu kỳ'.

          READ TABLE lt_group_dauky ASSIGNING FIELD-SYMBOL(<lfs_dauky>) WITH KEY  companycode = <lfs_zrm01>-companycode customer = <lfs_zrm01>-supplier.
          IF sy-subrc = 0.
            IF <lfs_dauky>-dauky_vnd >= 0.
              ls_result_ex-zno_vnd = <lfs_dauky>-dauky_vnd.
            ELSE.
              ls_result_ex-zco_vnd = abs( <lfs_dauky>-dauky_vnd ).
            ENDIF.

            IF <lfs_dauky>-dauky_nt_vnd >= 0.
              ls_result_ex-zno_nt = <lfs_dauky>-dauky_nt.
            ELSE.
              ls_result_ex-zco_nt = abs( <lfs_dauky>-dauky_nt  ).
            ENDIF.

            IF <lfs_dauky>-dauky >= 0.
              ls_result_ex-zno =  <lfs_dauky>-dauky.
            ELSE.
              ls_result_ex-zco = abs( <lfs_dauky>-dauky  ).
            ENDIF.

            ls_supplier_header-ct9_nodk_vnd = ls_result_ex-zno_vnd.
            ls_supplier_header-ct10_codk_vnd = ls_result_ex-zco_vnd.
            ls_supplier_header-ct11_nodk = ls_result_ex-zno_nt.
            ls_supplier_header-ct12_codk = ls_result_ex-zco_nt.
            ls_supplier_header-ct44_nodk = ls_result_ex-zno.
            ls_supplier_header-ct45_codk =  ls_result_ex-zco.

          ENDIF.


          IF <lfs_zrm01>-accountingdocument IS INITIAL.

            ls_result_ex-zno_vnd =  abs( <lfs_zrm01>-zno_vnd ).
            ls_result_ex-zco_vnd = abs( <lfs_zrm01>-zco_vnd ).
            ls_result_ex-zno_nt = abs( <lfs_zrm01>-zno_nt ).
            ls_result_ex-zco_nt = abs( <lfs_zrm01>-zco_nt ).
            ls_result_ex-zno = abs( <lfs_zrm01>-zno ).
            ls_result_ex-zco = abs( <lfs_zrm01>-zco ).

            ls_supplier_header-ct9_nodk_vnd = abs( <lfs_zrm01>-zno_vnd ).
            ls_supplier_header-ct10_codk_vnd = abs( <lfs_zrm01>-zco_vnd ).
            ls_supplier_header-ct11_nodk = abs( <lfs_zrm01>-zno_nt ).
            ls_supplier_header-ct12_codk = abs( <lfs_zrm01>-zco_nt ).

            ls_supplier_header-ct44_nodk = <lfs_zrm01>-zno .
            ls_supplier_header-ct45_codk =  abs( <lfs_zrm01>-zco ) .


          ENDIF.

          ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
          ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
          ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
          ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
          ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
          ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.

          lv_stt = lv_stt + 2.

          lv_stt_cps = lv_stt.



        ENDAT.

        lv_stt = lv_stt + 1.

        <lfs_zrm01>-zno_vnd = <lfs_zrm01>-ct30_curr.
        <lfs_zrm01>-zco_vnd =  <lfs_zrm01>-ct31_curr * -1.
        <lfs_zrm01>-zno_nt = <lfs_zrm01>-ct32_curr.
        <lfs_zrm01>-zco_nt = <lfs_zrm01>-ct33_curr * -1.
        <lfs_zrm01>-zno = <lfs_zrm01>-ct46_curr.
        <lfs_zrm01>-zco = <lfs_zrm01>-ct47_curr * -1.

        CONDENSE <lfs_zrm01>-zco_vnd NO-GAPS.
        CONDENSE <lfs_zrm01>-zno_vnd NO-GAPS.
        CONDENSE <lfs_zrm01>-zco_nt NO-GAPS.
        CONDENSE <lfs_zrm01>-zno_nt NO-GAPS.
        CONDENSE <lfs_zrm01>-zco NO-GAPS.
        CONDENSE <lfs_zrm01>-zno NO-GAPS.

        <lfs_zrm01>-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( <lfs_zrm01>-zco_vnd ) ).
        <lfs_zrm01>-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( <lfs_zrm01>-zno_vnd ) ).
        <lfs_zrm01>-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( <lfs_zrm01>-zco_nt ) ).
        <lfs_zrm01>-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( <lfs_zrm01>-zno_nt ) ).
        <lfs_zrm01>-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( <lfs_zrm01>-zco ) ).
        <lfs_zrm01>-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( <lfs_zrm01>-zno ) ).

        IF <lfs_zrm01>-accountingdocumenttype =  'RV'.
          READ TABLE lt_itemtext ASSIGNING FIELD-SYMBOL(<lfs_text>) WITH KEY  billingdocument = <lfs_zrm01>-billingdoc BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_zrm01>-accountingdocumentheadertext = <lfs_text>-billingdocumentitemtext.
          ENDIF.
        ENDIF.
* Start - Get data lt_journal_entrys
        MOVE-CORRESPONDING <lfs_zrm01> TO ls_result_ex.

        ls_supplier-ct13_cpsn_vnd   = ls_supplier-ct13_cpsn_vnd + <lfs_zrm01>-ct30_curr.
        ls_supplier-ct14_cpsc_vnd   = ls_supplier-ct14_cpsc_vnd + <lfs_zrm01>-ct31_curr.
        ls_supplier-ct15_cpsn       = ls_supplier-ct15_cpsn + <lfs_zrm01>-ct32_curr.
        ls_supplier-ct16_cpsc       = ls_supplier-ct16_cpsc + <lfs_zrm01>-ct33_curr.
        ls_supplier-ct44_cpsn       = ls_supplier-ct44_cpsn + <lfs_zrm01>-ct46_curr.
        ls_supplier-ct45_cpsc       = ls_supplier-ct45_cpsc +  <lfs_zrm01>-ct47_curr.

        ls_result_ex-stt = lv_stt.

        APPEND ls_result_ex TO lt_result_ex.
        CLEAR ls_result_ex.

* End - Get data lt_journal_entrys

* Start - Get data lt_suppliers

        AT END OF supplier.

          ls_result_ex-stt = lv_stt_cps - 1.
          ls_result_ex-zno_vnd = ls_supplier-ct13_cpsn_vnd.
          ls_result_ex-zco_vnd = ls_supplier-ct14_cpsc_vnd * -1.
          ls_result_ex-zno_nt = ls_supplier-ct15_cpsn.
          ls_result_ex-zco_nt = ls_supplier-ct16_cpsc * -1.
          ls_result_ex-zno = ls_supplier-ct44_cpsn.
          ls_result_ex-zco = ls_supplier-ct45_cpsc * -1.

          ls_suppliergroup-sum_cpsn_vnd = ls_suppliergroup-sum_cpsn_vnd + ls_supplier-ct13_cpsn_vnd.
          ls_suppliergroup-sum_cpsc_vnd = ls_suppliergroup-sum_cpsc_vnd + ls_supplier-ct14_cpsc_vnd * -1.
          ls_suppliergroup-sum_cpsn = ls_suppliergroup-sum_cpsn + ls_supplier-ct15_cpsn.
          ls_suppliergroup-sum_cpsc = ls_suppliergroup-sum_cpsc + ls_supplier-ct16_cpsc * -1.
          ls_suppliergroup-sum_cpsn_lk = ls_suppliergroup-sum_cpsn_lk + ls_supplier-ct44_cpsn.
          ls_suppliergroup-sum_cpsc_lk = ls_suppliergroup-sum_cpsc_lk + ls_supplier-ct45_cpsc * -1.
          ls_result_ex-des = 'Cộng phát sinh'.

          ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
          ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
          ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
          ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
          ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
          ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).

          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.
          lv_stt = lv_stt + 1.
          ls_result_ex-stt = lv_stt."lv_stt_cps.
          IF ( abs( ls_supplier_header-ct9_nodk_vnd )
               - abs( ls_supplier_header-ct10_codk_vnd )
               + abs( ls_supplier-ct13_cpsn_vnd )
               - abs( ls_supplier-ct14_cpsc_vnd ) ) > 0.
            ls_result_ex-zno_vnd = abs( ls_supplier_header-ct9_nodk_vnd )
                                   - abs( ls_supplier_header-ct10_codk_vnd )
                                   + abs( ls_supplier-ct13_cpsn_vnd )
                                   - abs( ls_supplier-ct14_cpsc_vnd ).
          ELSE.
            ls_result_ex-zco_vnd = abs( abs( ls_supplier_header-ct9_nodk_vnd )
                                        - abs( ls_supplier_header-ct10_codk_vnd )
                                        + abs( ls_supplier-ct13_cpsn_vnd )
                                        - abs( ls_supplier-ct14_cpsc_vnd ) ).
          ENDIF.

          IF ( abs( ls_supplier_header-ct11_nodk )
               - abs( ls_supplier_header-ct12_codk )
               + abs( ls_supplier-ct15_cpsn )
               - abs( ls_supplier-ct16_cpsc ) ) > 0.
            ls_result_ex-zno_nt = abs( ls_supplier_header-ct11_nodk )
                                  - abs( ls_supplier_header-ct12_codk )
                                  + abs( ls_supplier-ct15_cpsn )
                                  - abs( ls_supplier-ct16_cpsc ).
          ELSE.
            ls_result_ex-zco_nt = abs( abs( ls_supplier_header-ct11_nodk )
                                       - abs( ls_supplier_header-ct12_codk )
                                       + abs( ls_supplier-ct15_cpsn )
                                       - abs( ls_supplier-ct16_cpsc ) ).
          ENDIF.

          IF ( abs( ls_supplier_header-ct44_nodk )
               - abs( ls_supplier_header-ct45_codk )
               + abs( ls_supplier-ct44_cpsn )
               - abs( ls_supplier-ct45_cpsc ) ) > 0.
            ls_result_ex-zno = abs( ls_supplier_header-ct44_nodk )
                               - abs( ls_supplier_header-ct45_codk )
                               + abs( ls_supplier-ct44_cpsn )
                               - abs( ls_supplier-ct45_cpsc ).
          ELSE.
            ls_result_ex-zco = abs( abs( ls_supplier_header-ct44_nodk )
                                    - abs( ls_supplier_header-ct45_codk )
                                    + abs( ls_supplier-ct44_cpsn )
                                    - abs( ls_supplier-ct45_cpsc ) ).
          ENDIF.

*          ls_suppliergroup-sum_cpsn_vnd = ls_suppliergroup-sum_cpsn_vnd + ls_supplier_header-ct13_cpsn_vnd.
*          ls_suppliergroup-sum_cpsc_vnd = ls_suppliergroup-sum_cpsc_vnd + ls_supplier_header-ct14_cpsc_vnd.
*          ls_suppliergroup-sum_cpsn = ls_suppliergroup-sum_cpsn + ls_supplier_header-ct15_cpsn.
*          ls_suppliergroup-sum_cpsc = ls_suppliergroup-sum_cpsc + ls_supplier_header-ct16_cpsc.
*          ls_suppliergroup-sum_nosddk = ls_post-sum_nosddk + ls_result_ex-zno.
*          ls_suppliergroup-sum_Cosddk = ls_post-sum_Cosddk + ls_result_ex-zco.

          ls_suppliergroup-sum_sdnck_vnd = ls_suppliergroup-sum_sdnck_vnd + abs( ls_supplier_header-ct9_nodk_vnd )
                         - abs( ls_supplier_header-ct10_codk_vnd )
                         + abs( ls_supplier-ct13_cpsn_vnd )
                         - abs( ls_supplier-ct14_cpsc_vnd ).

          ls_suppliergroup-sum_sdnck = ls_suppliergroup-sum_sdnck + abs( ls_supplier_header-ct11_nodk )
                        - abs( ls_supplier_header-ct12_codk )
                        + abs( ls_supplier-ct15_cpsn )
                        - abs( ls_supplier-ct16_cpsc ).

          ls_suppliergroup-sum_sdnck_lk = ls_suppliergroup-sum_sdnck_lk + abs( ls_supplier_header-ct44_nodk )
                     - abs( ls_supplier_header-ct45_codk )
                     + abs( ls_supplier-ct44_cpsn )
                     - abs( ls_supplier-ct45_cpsc ).


          ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
          ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
          ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
          ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
          ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
          ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


          ls_result_ex-des = 'Số dư cuối kỳ'.
          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.

          CLEAR: ls_supplier,ls_supplier_header,lt_journal_entrys.


        ENDAT.

        AT END OF customeraccountgroup.
          lv_stt = lv_stt + 1.
          ls_result_ex-stt = lv_stt.
          ls_result_ex-zno_vnd = ls_suppliergroup-sum_cpsn_vnd.
          ls_result_ex-zco_vnd = ls_suppliergroup-sum_cpsc_vnd.
          ls_result_ex-zno_nt = ls_suppliergroup-sum_cpsn.
          ls_result_ex-zco_nt = ls_suppliergroup-sum_cpsc.
          ls_result_ex-zno = ls_suppliergroup-sum_cpsn_lk.
          ls_result_ex-zco = ls_suppliergroup-sum_cpsc_lk.

          ls_post-sum_cpsn_vnd = ls_post-sum_cpsn_vnd + ls_result_ex-zno_vnd.
          ls_post-sum_cpsc_vnd = ls_post-sum_cpsc_vnd + ls_result_ex-zco_vnd.
          ls_post-sum_cpsn = ls_post-sum_cpsn + ls_result_ex-zno_nt.
          ls_post-sum_cpsc = ls_post-sum_cpsc + ls_result_ex-zco_nt.
          ls_post-sum_cpsn_lk = ls_post-sum_cpsn_lk + ls_result_ex-zno.
          ls_post-sum_cpsc_lk = ls_post-sum_cpsc_lk + ls_result_ex-zco.
          ls_result_ex-des = 'Cộng phát sinh' && ' ' && <lfs_zrm01>-supplieraccountgroup.

          ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
          ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
          ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
          ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
          ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
          ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.
          lv_stt = lv_stt + 1.
          ls_result_ex-stt = lv_stt.
          IF ls_suppliergroup-sum_sdnck_vnd >= 0.
            ls_result_ex-zno_vnd = ls_suppliergroup-sum_sdnck_vnd.
          ELSE.
            ls_result_ex-zco_vnd = ls_suppliergroup-sum_sdnck_vnd.
          ENDIF.
          IF ls_suppliergroup-sum_sdnck >= 0.
            ls_result_ex-zno_nt = ls_suppliergroup-sum_sdnck.
          ELSE.
            ls_result_ex-zco_nt = ls_suppliergroup-sum_sdnck.
          ENDIF.


          IF ls_suppliergroup-sum_sdnck_lk >= 0.
            ls_result_ex-zno = ls_suppliergroup-sum_sdnck_lk.
          ELSE.
            ls_result_ex-zco = ls_suppliergroup-sum_sdnck_lk.
          ENDIF.


          ls_post-sum_sdnck_vnd = ls_post-sum_sdnck_vnd + ls_suppliergroup-sum_sdnck_vnd.
          ls_post-sum_sdnck = ls_post-sum_sdnck + ls_suppliergroup-sum_sdnck.
          ls_post-sum_sdnck_lk = ls_post-sum_sdnck_lk + ls_suppliergroup-sum_sdnck_lk.

          ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
          ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
          ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
          ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
          ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
          ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


          ls_result_ex-des = 'Số dư cuối kỳ' && ' ' &&  <lfs_zrm01>-supplieraccountgroup.
          APPEND ls_result_ex TO lt_result_ex.
          CLEAR ls_result_ex.

          CLEAR: ls_supplier,ls_supplier_header,lt_journal_entrys,ls_suppliergroup.


        ENDAT.
      ENDLOOP.

      ls_result_ex-stt = 1.
      ls_result_ex-des = 'Tổng số dư đầu kỳ'.
      IF ls_post-sum_ct9 >= 0.
        ls_result_ex-zno_vnd =  ls_post-sum_ct9.
      ELSE.
        ls_result_ex-zco_vnd = abs( ls_post-sum_ct9 ).
      ENDIF.
      IF ls_post-sum_ct11 >= 0.
        ls_result_ex-zno_nt = ls_post-sum_ct11.
      ELSE.
        ls_result_ex-zco_nt = abs( ls_post-sum_ct11 ).
      ENDIF.

      IF ls_post-sum_nosddk >= 0.
        ls_result_ex-zno = ls_post-sum_nosddk.
      ELSE.
        ls_result_ex-zco = abs( ls_post-sum_cosddk ).
      ENDIF.




      ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
      ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
      ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
      ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
      ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
      ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


      APPEND ls_result_ex TO lt_result_ex.
      CLEAR ls_result_ex.


      lv_stt = lv_stt + 1.
      ls_result_ex-stt = lv_stt.
      ls_result_ex-des = 'Tổng cộng'.
      APPEND ls_result_ex TO lt_result_ex.
      CLEAR ls_result_ex.

      lv_stt = lv_stt + 1.
      ls_result_ex-stt = lv_stt.
      ls_result_ex-zno_vnd = ls_post-sum_cpsn_vnd.
      ls_result_ex-zco_vnd = ls_post-sum_cpsc_vnd.
      ls_result_ex-zno_nt  = ls_post-sum_cpsn.
      ls_result_ex-zco_nt  = ls_post-sum_cpsc.
      ls_result_ex-zno  = ls_post-sum_cpsn_lk.
      ls_result_ex-zco  = ls_post-sum_cpsc_lk.

      ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
      ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
      ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
      ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
      ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
      ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


      ls_result_ex-des = 'Tổng cộng phát sinh'.
      APPEND ls_result_ex TO lt_result_ex.
      CLEAR ls_result_ex.

      lv_stt = lv_stt + 1.
      ls_result_ex-stt = lv_stt.
      IF ls_post-sum_sdnck_vnd >= 0.
        ls_result_ex-zno_vnd = ls_post-sum_sdnck_vnd.
      ELSE.
        ls_result_ex-zco_vnd = ls_post-sum_sdnck_vnd.
      ENDIF.

      IF ls_post-sum_sdnck >= 0.
        ls_result_ex-zno_nt  = ls_post-sum_sdnck.
      ELSE.
        ls_result_ex-zco_nt  = ls_post-sum_sdnck.
      ENDIF.
      IF ls_post-sum_sdnck_lk >= 0.
        ls_result_ex-zno  = ls_post-sum_sdnck_lk.
      ELSE.
        ls_result_ex-zco  = ls_post-sum_sdnck_lk.
      ENDIF.


      ls_result_ex-des = 'Tổng số dư cuối kỳ'.

      ls_result_ex-zco_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco_vnd ) ).
      ls_result_ex-zno_vnd = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno_vnd ) ).
      ls_result_ex-zco_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zco_nt ) ).
      ls_result_ex-zno_nt = format_amount_string( i_currency = CONV string( 'USD' ) i_input = CONV string( ls_result_ex-zno_nt ) ).
      ls_result_ex-zco = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zco ) ).
      ls_result_ex-zno = format_amount_string( i_currency = CONV string( 'VND' ) i_input = CONV string( ls_result_ex-zno ) ).


      APPEND ls_result_ex TO lt_result_ex.
      CLEAR ls_result_ex.
      SORT lt_result_ex BY stt postingdate documentdate accountingdocument.
      IF top < 0.
        top = 1.
      ENDIF.

      IF lines( lt_result ) > 1.
        LOOP AT lt_result_ex INTO DATA(ls_row) FROM skip + 1 TO skip + top.
          APPEND ls_row TO lt_result_page.
        ENDLOOP.
      ELSE.
        lt_result_page = lt_result_ex.
      ENDIF.

      io_response->set_data( lt_result_page ).
    ENDIF.


    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result_ex ) ).
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
