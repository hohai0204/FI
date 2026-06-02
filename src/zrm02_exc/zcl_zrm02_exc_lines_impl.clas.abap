CLASS zcl_zrm02_exc_lines_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.
    TYPES: tt_data_output TYPE STANDARD TABLE OF zfa_i_zrm02_exc_lines.
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS get_data
      IMPORTING io_request TYPE REF TO if_rap_query_request
      EXPORTING et_table   TYPE tt_data_output
      .
ENDCLASS.



CLASS ZCL_ZRM02_EXC_LINES_IMPL IMPLEMENTATION.


  METHOD get_data.
    DATA lt_data_output TYPE tt_data_output.
    TYPES: BEGIN OF lty_header_exc ,
             compname           TYPE string,
             compadd            TYPE string,
             compmst            TYPE string,

             titleheader        TYPE string,
             glacccount         TYPE string,
             postingdate_fromto TYPE string,

             currentdate        TYPE string,
             nguoilap           TYPE string,
             ketoan             TYPE string,
             giamdoc            TYPE string,
           END OF lty_header_exc.

    DATA: lt_header TYPE TABLE OF lty_header_exc,
          ls_header TYPE lty_header_exc.
    " Sort
    DATA(lt_sort) = io_request->get_sort_elements( ).
    DATA lv_orderby TYPE string VALUE `COMPANYCODE`.
    IF lt_sort IS NOT INITIAL.
      " lv_orderby = |GLACCOUNT|.
      lv_orderby = REDUCE #( INIT s TYPE string
                             FOR ls_sort IN lt_sort
                             NEXT s &&= |{ ls_sort-element_name } { COND #( WHEN ls_sort-descending = abap_true
                                                                            THEN 'DESCENDING' ) }, | ).
      REPLACE ALL OCCURRENCES OF PCRE `\s*,\s*$` IN lv_orderby WITH space.
    ENDIF.
    " Filter bar
    DATA(ro_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = ro_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range ##NO_HANDLER.
    ENDTRY.

    DATA lr_customer_range TYPE RANGE OF kunnr.
    IF lt_range IS NOT INITIAL.
      LOOP AT lt_range INTO DATA(ls_range).
        CASE ls_range-name.
          WHEN 'COMPANYCODE'.
            DATA(lr_compcode_range) = ls_range-range.
          WHEN 'CUSTOMERACCOUNTGROUP'.
            DATA(lr_custaccgrp_range) = ls_range-range.
          WHEN 'CUSTOMERCODE'.
            LOOP AT ls_range-range ASSIGNING FIELD-SYMBOL(<ls_any_range>).
              APPEND VALUE #( sign = <ls_any_range>-sign
                              option = <ls_any_range>-option
                              low = |{ <ls_any_range>-low ALPHA = IN }|
                              high = |{ <ls_any_range>-high ALPHA = IN }| ) TO lr_customer_range.
            ENDLOOP.
          WHEN 'GLACCOUNT'.
            DATA(lr_glaccount_range) = ls_range-range.
          WHEN 'BALANCETRANSACTIONCURRENCY'.
            DATA(lr_cuki_range) = ls_range-range.
          WHEN 'POSTINGDATE'.
            DATA(lr_postingdate_range) = ls_range-range.
          WHEN 'FISCALYEAR'.
            DATA(lr_fiscalyear_range) = ls_range-range.
          WHEN 'NGUOILAP'.
            DATA(lr_nguoilap) = ls_range-range.
          WHEN 'KETOAN'.
            DATA(lr_ketoan) = ls_range-range.
          WHEN 'GIAMDOC'.
            DATA(lr_giamdoc) = ls_range-range.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    "-- Ngày in hiện tại.
    DATA(lv_currdate) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_current_date) = |Ngày { lv_currdate+6(2) } Tháng { lv_currdate+4(2) } Năm { lv_currdate+0(4) }|.

    "-- Ngày Posting date from-to
    DATA: lv_postingdate_from_fm TYPE string,
          lv_postingdate_to_fm   TYPE string,
          lv_date_from_fm        TYPE string,
          lv_date_to_fm          TYPE string.
    READ TABLE lr_postingdate_range INTO DATA(ls_date) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_prev_postingdate) =  ls_date-low. "|{ ls_date-low+0(4) }-{ ls_date-low+4(2) }-{ ls_date-low+6(2) }|.
      DATA(lv_next_postingdate) =  ls_date-high. "|{ ls_date-high+0(4) }-{ ls_date-high+4(2) }-{ ls_date-high+6(2) }|.
    ENDIF.
    IF lv_prev_postingdate IS NOT INITIAL.
      lv_postingdate_from_fm = |{ lv_prev_postingdate+6(2) }-{ lv_prev_postingdate+4(2) }-{ lv_prev_postingdate+0(4) }|.
      lv_date_from_fm        = |{ lv_prev_postingdate+6(2) }/{ lv_prev_postingdate+4(2) }/{ lv_prev_postingdate+0(4) }|.
    ELSE.
    ENDIF.

    IF lv_next_postingdate IS NOT INITIAL.
      lv_postingdate_to_fm = |{ lv_next_postingdate+6(2) }-{ lv_next_postingdate+4(2) }-{ lv_next_postingdate+0(4) }|.
      lv_date_to_fm        = |{ lv_next_postingdate+6(2) }/{ lv_next_postingdate+4(2) }/{ lv_next_postingdate+0(4) }|.
    ELSE.
    ENDIF.
    "-- Format data input CUKI
    LOOP AT lr_cuki_range ASSIGNING FIELD-SYMBOL(<lfs_cuki_r>).
      TRANSLATE <lfs_cuki_r>-low TO UPPER CASE.
      TRANSLATE <lfs_cuki_r>-high TO UPPER CASE.
    ENDLOOP.

    "---------- Select from Master data ----------"
    "-- Tài khoản
    SELECT view_entity~companycode,
      view_entity~compname,
      view_entity~compadd,
      view_entity~compmst,
      view_entity~ledger,

      view_entity~customeraccountgroup,
      view_entity~fiscalyear,
      view_entity~customer,
      view_entity~customername,
      view_entity~ismarkedforarchiving,

      view_entity~glaccount,
      view_entity~glaccountlongname
    FROM zfa_i_zrm02_view AS view_entity
    INNER JOIN i_journalentryitem AS journalentryitem ON view_entity~companycode = journalentryitem~companycode
                                                     AND view_entity~fiscalyear = journalentryitem~fiscalyear
                                                     AND view_entity~glaccount = journalentryitem~glaccount
                                                     AND journalentryitem~ledger =  view_entity~ledger
                                                     AND journalentryitem~customer =  view_entity~customer
    WHERE journalentryitem~balancetransactioncurrency IN @lr_cuki_range
      AND journalentryitem~postingdate IN @lr_postingdate_range
      AND view_entity~companycode IN @lr_compcode_range
      AND view_entity~fiscalyear IN @lr_fiscalyear_range
      AND view_entity~customeraccountgroup IN @lr_custaccgrp_range
      AND view_entity~glaccount IN @lr_glaccount_range
      AND view_entity~customer IN @lr_customer_range
      AND view_entity~ismarkedforarchiving IS INITIAL
    GROUP BY view_entity~companycode,view_entity~fiscalyear,
             view_entity~compname,
             view_entity~compadd,
             view_entity~compmst,
             view_entity~ledger,
             view_entity~customer,
             view_entity~customeraccountgroup,
             view_entity~customername,
             view_entity~ismarkedforarchiving,
             view_entity~glaccount,
             view_entity~glaccountlongname
    INTO TABLE @DATA(lt_about_glaccount).

    SELECT view_entity~companycode,
      view_entity~compname,
      view_entity~compadd,
      view_entity~compmst,
      view_entity~ledger,

      view_entity~customeraccountgroup,
      view_entity~fiscalyear,
      view_entity~customer,
      view_entity~customername,
      view_entity~ismarkedforarchiving,

      view_entity~glaccount,
      view_entity~glaccountlongname
    FROM zfa_i_zrm02_view AS view_entity
    INNER JOIN i_journalentryitem AS journalentryitem ON view_entity~companycode = journalentryitem~companycode
                                                     AND view_entity~fiscalyear = journalentryitem~fiscalyear
                                                     AND view_entity~glaccount = journalentryitem~glaccount
                                                     AND journalentryitem~ledger =  view_entity~ledger
                                                     AND journalentryitem~customer =  view_entity~customer
    WHERE journalentryitem~balancetransactioncurrency IN @lr_cuki_range
      AND journalentryitem~postingdate < @lv_prev_postingdate
      AND view_entity~companycode IN @lr_compcode_range
*      AND view_entity~fiscalyear IN @lr_fiscalyear_range
      AND view_entity~customeraccountgroup IN @lr_custaccgrp_range
      AND view_entity~glaccount IN @lr_glaccount_range
      AND view_entity~customer IN @lr_customer_range
      AND view_entity~ismarkedforarchiving IS INITIAL
    GROUP BY view_entity~companycode,view_entity~fiscalyear,
             view_entity~compname,
             view_entity~compadd,
             view_entity~compmst,
             view_entity~ledger,
             view_entity~customer,
             view_entity~customeraccountgroup,
             view_entity~customername,
             view_entity~ismarkedforarchiving,
             view_entity~glaccount,
             view_entity~glaccountlongname
    APPENDING TABLE @lt_about_glaccount.

    IF lt_about_glaccount IS INITIAL.
      EXIT.
    ENDIF.

    "-- GLACCOUNT 1 LINE
    SORT lt_about_glaccount BY companycode customeraccountgroup customer glaccount.
    DELETE ADJACENT DUPLICATES FROM lt_about_glaccount COMPARING companycode customeraccountgroup customer glaccount.

    DATA lv_glacc_grp TYPE string.

    IF    lr_glaccount_range IS INITIAL.
      lv_glacc_grp = |Tài khoản: All|.
    ELSE.
*      SELECT gl~glaccount, gl~glaccountlongname
*      FROM @lt_about_glaccount AS gl
*      GROUP BY gl~glaccount, gl~glaccountlongname
*      ORDER BY gl~glaccount
*      INTO TABLE @DATA(lt_1line_gl).

      SELECT gl~glaccount, gl~glaccountlongname
    FROM i_glaccounttext AS gl
                WHERE  'YCOA'   = gl~chartofaccounts
                     AND  gl~glaccount IN @lr_glaccount_range
    GROUP BY gl~glaccount, gl~glaccountlongname
    ORDER BY gl~glaccount
    INTO TABLE @DATA(lt_1line_gl)."ViHT9/14.01.2026/ update ZPM02_EXC ver 2.3.3

      LOOP AT lt_1line_gl INTO DATA(ls_grp_glacc).
        DATA(glaccountname) = |{ ls_grp_glacc-glaccount }-{ ls_grp_glacc-glaccountlongname }|.
        lv_glacc_grp = |{ lv_glacc_grp }; { glaccountname }|.
        CLEAR: ls_grp_glacc.
      ENDLOOP.

      SHIFT lv_glacc_grp LEFT BY 2 PLACES.
      lv_glacc_grp = |Tài khoản: { lv_glacc_grp }|.
    ENDIF.
    "-----------------------------------------------"
    TYPES: BEGIN OF ty_sodu,
             customeraccountgroup       TYPE ktokd,
             customer                   TYPE kunnr,
             glaccount                  TYPE string,
             customername               TYPE string,
             balance                    TYPE p LENGTH 13 DECIMALS 2,
             balancetransactioncurrency TYPE waers,
             amountcompcode             TYPE p LENGTH 13 DECIMALS 2,
             companycodecurrency        TYPE waers,
             typesodu                   TYPE string,
           END OF ty_sodu.
    DATA lt_sodu TYPE TABLE OF ty_sodu.

    "-- Đầu kì
**    "------------------------ NaVTT/ 03.04.2026/ Đầu kì check reversed -----------------------"
**    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~customername, gl_account~glaccount,
**           SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
**           journalentryitem~balancetransactioncurrency,
**           "-- quy đổi
**           SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency ,
**           journalentryitem~companycodecurrency,
**           'DK' AS typesodu,
**
**           journalentryitem~accountingdocument,
**           journalentryitem~reversalreferencedocument,
**           journalentryitem~fiscalperiod
**
**     FROM @lt_about_glaccount AS gl_account
**      INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
**                                                      AND gl_account~ledger            = journalentryitem~ledger
**                                                      AND gl_account~glaccount         = journalentryitem~glaccount
**                                                      AND gl_account~customer          =  journalentryitem~customer
**      INNER JOIN i_journalentry AS journalentry  ON journalentryitem~companycode        = journalentry~companycode
**                                                AND journalentryitem~accountingdocument = journalentry~accountingdocument
**       WHERE journalentryitem~postingdate < @lv_prev_postingdate
**         AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
**         AND journalentryitem~isreversal IS NOT INITIAL
**      GROUP BY gl_account~customeraccountgroup, gl_account~customer, gl_account~customername, gl_account~glaccount,
**        journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency,
**        journalentryitem~accountingdocument,
**        journalentryitem~reversalreferencedocument,
**        journalentryitem~fiscalperiod
**      ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount
**      INTO TABLE @DATA(lt_dk_isreversal).
**
**
**    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~customername, gl_account~glaccount,
**           SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
**           journalentryitem~balancetransactioncurrency,
**           "-- quy đổi
**           SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency ,
**           journalentryitem~companycodecurrency,
**           'DK' AS typesodu,
**
**           journalentryitem~accountingdocument,
**           journalentryitem~reversalreferencedocument,
**           journalentryitem~fiscalperiod
**
**     FROM @lt_about_glaccount AS gl_account
**      INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
**                                                      AND gl_account~ledger            = journalentryitem~ledger
**                                                      AND gl_account~glaccount         = journalentryitem~glaccount
**                                                      AND gl_account~customer               =  journalentryitem~customer
**      INNER JOIN i_journalentry AS journalentry  ON journalentryitem~companycode        = journalentry~companycode
**                                                AND journalentryitem~accountingdocument = journalentry~accountingdocument
**       WHERE journalentryitem~postingdate < @lv_prev_postingdate
**         AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
**         AND journalentryitem~isreversed IS NOT INITIAL
**      GROUP BY gl_account~customeraccountgroup, gl_account~customer, gl_account~customername, gl_account~glaccount,
**        journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency,
**        journalentryitem~accountingdocument,
**        journalentryitem~reversalreferencedocument,
**        journalentryitem~fiscalperiod
**      ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount
**      INTO TABLE @DATA(lt_dk_isreversed).
**
**
**    DATA: lv_count_reversed TYPE i,
**          lv_count_reversal TYPE i.
**
**    LOOP AT lt_dk_isreversal INTO DATA(ls_dk_isreversal).
**      lv_count_reversal = sy-tabix.
**      READ TABLE lt_dk_isreversed INTO DATA(ls_dk_isreversed) WITH KEY customer = ls_dk_isreversal-customer
**                                                                       glaccount = ls_dk_isreversal-glaccount
**                                                                       balancetransactioncurrency = ls_dk_isreversal-balancetransactioncurrency
**                                                                       reversalreferencedocument = ls_dk_isreversal-accountingdocument BINARY SEARCH.
**      IF sy-subrc = 0.
**        lv_count_reversed = sy-tabix.
**        IF ls_dk_isreversal-fiscalperiod = ls_dk_isreversed-fiscalperiod.
**          DELETE lt_dk_isreversal INDEX lv_count_reversal.
**          DELETE lt_dk_isreversed INDEX lv_count_reversed.
**          CLEAR: lv_count_reversal, lv_count_reversed.
**        ENDIF.
**      ENDIF.
**    ENDLOOP.
**
**    "------------------------ NaVTT/ 03.04.2026/ Đầu kì check reversed -----------------------"
    "-- Đầu kì
    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, gl_account~customername,
    SUM( journalentryitem~amountinbalancetransaccrcy ) AS balance,
    journalentryitem~balancetransactioncurrency,
    "-- quy đổi
    SUM( journalentryitem~amountincompanycodecurrency ) AS amountcompcode ,
    journalentryitem~companycodecurrency,
    'DK' AS typesodu
    FROM @lt_about_glaccount AS gl_account
    INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                     AND gl_account~ledger            = journalentryitem~ledger
                                                     AND gl_account~glaccount         = journalentryitem~glaccount
                                                     AND gl_account~customer         = journalentryitem~customer
    INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                     AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                     AND journalentryitem~accountingdocument = journalentry~accountingdocument
    WHERE journalentryitem~postingdate < @lv_prev_postingdate
*      AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
      AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
***-- Begin: NaVTT/03.04.2026/
*          AND journalentryitem~isreversed IS INITIAL
*          AND journalentryitem~isreversal IS INITIAL
***-- End: NaVTT/03.04.2026/
    GROUP BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, gl_account~customername,
    journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency
    ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount
      INTO TABLE @DATA(lt_dk).
*      INTO TABLE @lt_sodu.

**    "- Đầu kì (reversed check) NaVTT/update 03.04.2025
**    SELECT a~customeraccountgroup, a~customer, a~glaccount, a~customername,
**     SUM( a~amountinbalancetransaccrcy ) AS balance ,
**     a~balancetransactioncurrency,
**      "-- quy đổi
**      SUM( a~amountincompanycodecurrency ) AS amountcompcode ,
**      a~companycodecurrency,
**      a~typesodu
**      FROM @lt_dk_isreversal AS a
**      GROUP BY a~customeraccountgroup, a~customer, a~glaccount, a~customername,
**      a~balancetransactioncurrency, a~companycodecurrency, a~typesodu
**      ORDER BY a~customeraccountgroup, a~customer, a~glaccount, a~balancetransactioncurrency
**      APPENDING TABLE @lt_dk.

    "- Sum Đầu kì
    SELECT a~customeraccountgroup, a~customer, a~glaccount, a~customername,
      SUM( a~balance ) AS balance,
      a~balancetransactioncurrency,
      "-- quy đổi
      SUM( a~amountcompcode ) AS amountcompcode ,
      a~companycodecurrency,
      a~typesodu
    FROM @lt_dk AS a
    GROUP BY a~customeraccountgroup, a~customer, a~glaccount, a~customername,a~balancetransactioncurrency,a~companycodecurrency,a~typesodu
    ORDER BY a~customeraccountgroup, a~customer, a~glaccount
    INTO CORRESPONDING FIELDS OF TABLE @lt_sodu.

    "-----------------------------------------------"
    "-- Phát sinh từ [App] Manage Customer Line Items

    "- Phát sinh
    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, gl_account~customername, journalentryitem~postingdate,
        journalentryitem~amountinbalancetransaccrcy,
        journalentryitem~balancetransactioncurrency,
        "-- quy đổi
        journalentryitem~amountincompanycodecurrency,
        journalentryitem~companycodecurrency,
*          'PS_NO' AS typesodu,
        journalentryitem~debitcreditcode,
        CASE  WHEN ( journalentryitem~amountinbalancetransaccrcy  > 0 )
                 AND journalentryitem~debitcreditcode = 'H' THEN CAST( 'X' AS CHAR( 1 ) )
              WHEN ( journalentryitem~amountintransactioncurrency  < 0 )
                 AND journalentryitem~debitcreditcode = 'S' THEN CAST( 'X' AS CHAR( 1 ) )
              ELSE CAST( ' ' AS CHAR( 1 )  ) END AS isnegativeposting,

" NaVTT test reversed 07.04
             journalentryitem~accountingdocument,
             journalentry~reversalreferencedocument,
             journalentryitem~fiscalperiod,
             journalentryitem~isreversed,
             journalentryitem~isreversal
" NaVTT test reversed 07.04

   FROM @lt_about_glaccount AS gl_account
   INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                    AND gl_account~ledger            = journalentryitem~ledger
                                                    AND gl_account~glaccount         = journalentryitem~glaccount
                                                    AND gl_account~customer          = journalentryitem~customer
    INNER JOIN i_journalentry AS journalentry  ON journalentryitem~companycode        = journalentry~companycode
                                              AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                              AND journalentryitem~accountingdocument = journalentry~accountingdocument
      WHERE journalentryitem~postingdate IN @lr_postingdate_range
      AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
      AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
      AND journalentryitem~ledger = '0L'
*      AND journalentryitem~financialaccounttype = 'D'
      AND ( journalentryitem~financialaccounttype = 'D' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~customer IS NOT INITIAL ) )
      AND journalentryitem~isreversed IS INITIAL
      AND journalentryitem~isreversal IS INITIAL
    ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, journalentryitem~balancetransactioncurrency
    INTO TABLE @DATA(lt_phatsinh).
    " Phát sinh Reversed
    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, gl_account~customername, journalentryitem~postingdate,
        journalentryitem~amountinbalancetransaccrcy  ,
        journalentryitem~balancetransactioncurrency,
        "-- quy đổi
        journalentryitem~amountincompanycodecurrency,
        journalentryitem~companycodecurrency,
*          'PS_NO' AS typesodu,
        journalentryitem~debitcreditcode,
        CASE  WHEN ( journalentryitem~amountinbalancetransaccrcy  > 0 )
                 AND journalentryitem~debitcreditcode = 'H' THEN CAST( 'X' AS CHAR( 1 ) )
              WHEN ( journalentryitem~amountintransactioncurrency  < 0 )
                 AND journalentryitem~debitcreditcode = 'S' THEN CAST( 'X' AS CHAR( 1 ) )
              ELSE CAST( ' ' AS CHAR( 1 )  ) END AS isnegativeposting,

" NaVTT test reversed 07.04
           journalentryitem~accountingdocument,
           journalentry~reversalreferencedocument,
           journalentryitem~fiscalperiod,
           journalentryitem~isreversed,
           journalentryitem~isreversal
" NaVTT test reversed 07.04

   FROM @lt_about_glaccount AS gl_account
   INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                    AND gl_account~ledger            = journalentryitem~ledger
                                                    AND gl_account~glaccount         = journalentryitem~glaccount
                                                    AND gl_account~customer          = journalentryitem~customer
    INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                     AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                     AND journalentryitem~accountingdocument = journalentry~accountingdocument
    WHERE journalentryitem~postingdate IN @lr_postingdate_range
      AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
      AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
      AND journalentryitem~ledger = '0L'
*        AND journalentryitem~financialaccounttype = 'D'
      AND ( journalentryitem~financialaccounttype = 'D' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~customer IS NOT INITIAL ) )
      AND journalentryitem~isreversed IS NOT INITIAL
    ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, journalentryitem~balancetransactioncurrency
    INTO TABLE @DATA(lt_phatsinh_isreversed).

    " Phát sinh Reversal
    SELECT gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, gl_account~customername, journalentryitem~postingdate,
        journalentryitem~amountinbalancetransaccrcy  ,
        journalentryitem~balancetransactioncurrency,
        "-- quy đổi
        journalentryitem~amountincompanycodecurrency,
        journalentryitem~companycodecurrency,
*          'PS_NO' AS typesodu,
        journalentryitem~debitcreditcode,
        CASE  WHEN ( journalentryitem~amountinbalancetransaccrcy  > 0 )
                 AND journalentryitem~debitcreditcode = 'H' THEN CAST( 'X' AS CHAR( 1 ) )
              WHEN ( journalentryitem~amountintransactioncurrency  < 0 )
                 AND journalentryitem~debitcreditcode = 'S' THEN CAST( 'X' AS CHAR( 1 ) )
              ELSE CAST( ' ' AS CHAR( 1 )  ) END AS isnegativeposting,

" NaVTT test reversed 07.04
           journalentryitem~accountingdocument,
           journalentry~reversalreferencedocument,
           journalentryitem~fiscalperiod,
           journalentryitem~isreversed,
           journalentryitem~isreversal
" NaVTT test reversed 07.04

   FROM @lt_about_glaccount AS gl_account
   INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                    AND gl_account~ledger            = journalentryitem~ledger
                                                    AND gl_account~glaccount         = journalentryitem~glaccount
                                                    AND gl_account~customer          = journalentryitem~customer
    INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                     AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                     AND journalentryitem~accountingdocument = journalentry~accountingdocument
    WHERE journalentryitem~postingdate IN @lr_postingdate_range
      AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
      AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
      AND journalentryitem~ledger = '0L'
*        AND journalentryitem~financialaccounttype = 'D'
      AND ( journalentryitem~financialaccounttype = 'D' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~customer IS NOT INITIAL ) )
      AND journalentryitem~isreversal IS NOT INITIAL
    ORDER BY gl_account~customeraccountgroup, gl_account~customer, gl_account~glaccount, journalentryitem~balancetransactioncurrency
    INTO TABLE @DATA(lt_phatsinh_isreversal).

    DATA: lv_count_reversed TYPE i,
          lv_count_reversal TYPE i.

    LOOP AT lt_phatsinh_isreversal INTO DATA(ls_rv_ps_isreversal).
      lv_count_reversal = sy-tabix.
      READ TABLE lt_phatsinh_isreversed INTO DATA(ls_rv_ps_isreversed) WITH KEY customer = ls_rv_ps_isreversal-customer
                                                                           glaccount = ls_rv_ps_isreversal-glaccount
                                                                           balancetransactioncurrency = ls_rv_ps_isreversal-balancetransactioncurrency
                                                                           reversalreferencedocument = ls_rv_ps_isreversal-accountingdocument BINARY SEARCH.
      IF sy-subrc = 0.
        lv_count_reversed = sy-tabix.
        IF ls_rv_ps_isreversal-fiscalperiod = ls_rv_ps_isreversed-fiscalperiod.
          DELETE lt_phatsinh_isreversal INDEX lv_count_reversal.
          DELETE lt_phatsinh_isreversed INDEX lv_count_reversed.
          CLEAR: lv_count_reversal, lv_count_reversed.
        ENDIF.
      ENDIF.
    ENDLOOP.

    APPEND LINES OF lt_phatsinh_isreversed TO lt_phatsinh_isreversal.
    DELETE lt_phatsinh_isreversal WHERE postingdate NOT IN lr_postingdate_range.

    APPEND LINES OF lt_phatsinh_isreversal TO lt_phatsinh.

    "------------------"

    "- Phát sinh NỢ
    SELECT customeraccountgroup, customer, glaccount, customername,
          SUM( amountinbalancetransaccrcy ) AS balance ,
          balancetransactioncurrency,
          "-- quy đổi
          SUM( amountincompanycodecurrency ) AS amountcompcode ,
          companycodecurrency,
          'PS_NO' AS typesodu
      FROM @lt_phatsinh AS ps
**-- Begin: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> NỢ = S
*        WHERE ( debitcreditcode = 'S' AND isnegativeposting IS INITIAL )
*           OR ( debitcreditcode = 'H' AND isnegativeposting = 'X' )
        WHERE  debitcreditcode = 'S'
**-- End: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> NỢ = S
        GROUP BY customeraccountgroup, customer, glaccount, customername, balancetransactioncurrency,companycodecurrency
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_sodu.

    "- Phát sinh CÓ
    SELECT customeraccountgroup, customer, glaccount, customername,
          SUM( amountinbalancetransaccrcy ) AS balance ,
          balancetransactioncurrency,
          "-- quy đổi
          SUM( amountincompanycodecurrency ) AS amountcompcode ,
          companycodecurrency,
          'PS_CO' AS typesodu
      FROM @lt_phatsinh AS ps
**-- Begin: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> CÓ = H
*        WHERE ( debitcreditcode = 'H' AND isnegativeposting IS INITIAL )
*           OR ( debitcreditcode = 'S' AND isnegativeposting = 'X' )
        WHERE  debitcreditcode = 'H'
**-- End: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> CÓ = H
        GROUP BY customeraccountgroup, customer, glaccount, customername, balancetransactioncurrency,companycodecurrency
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_sodu.
    "-----------------------------------------------"


    DATA: lt_sodu_vn TYPE TABLE OF ty_sodu,
          lt_sodu_nt TYPE TABLE OF ty_sodu,
          ls_sodu    TYPE ty_sodu.

    LOOP AT lt_sodu INTO ls_sodu.
      CASE ls_sodu-balancetransactioncurrency.
        WHEN 'VND'.
          APPEND ls_sodu TO lt_sodu_vn.
        WHEN OTHERS.
          APPEND ls_sodu TO lt_sodu_nt.
      ENDCASE.
    ENDLOOP.

    SORT lt_sodu_vn BY customeraccountgroup customer glaccount typesodu.
    SORT lt_sodu_nt BY customeraccountgroup customer glaccount typesodu.
    "-----------------------------------------------"
    "-- Cuối kì -> Ending Balance = Starting Balance + Total Debit – Total Credit
    "-----------------------------------------------"
    DATA: lt_lines TYPE TABLE OF zfa_i_zrm02_exc_lines,
          ls_lines TYPE zfa_i_zrm02_exc_lines.
    DATA: tt_exc TYPE zfa_i_zrm02_exc_lines.

    DATA: lv_dauki_no_nt    TYPE p LENGTH 13 DECIMALS 2,
          lv_dauki_no_vn    TYPE p LENGTH 13 DECIMALS 2,
          lv_dauki_co_nt    TYPE p LENGTH 13 DECIMALS 2,
          lv_dauki_co_vn    TYPE p LENGTH 13 DECIMALS 2,

          lv_phatsinh_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_phatsinh_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_phatsinh_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_phatsinh_co_vn TYPE p LENGTH 13 DECIMALS 2,


          lv_cuoiki_vn      TYPE p LENGTH 13 DECIMALS 2,
          lv_cuoiki_nt      TYPE p LENGTH 13 DECIMALS 2,
          lv_cuoiki_no_nt   TYPE p LENGTH 13 DECIMALS 2,
          lv_cuoiki_no_vn   TYPE p LENGTH 13 DECIMALS 2,
          lv_cuoiki_co_nt   TYPE p LENGTH 13 DECIMALS 2,
          lv_cuoiki_co_vn   TYPE p LENGTH 13 DECIMALS 2.

    DATA: lv_total_dk_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_dk_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_total_dk_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_dk_co_vn TYPE p LENGTH 13 DECIMALS 2,

          lv_total_ps_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ps_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ps_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ps_co_vn TYPE p LENGTH 13 DECIMALS 2,

          lv_total_ck_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ck_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ck_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_total_ck_co_vn TYPE p LENGTH 13 DECIMALS 2.

    DATA: lv_subtotal_dk_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_dk_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_dk_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_dk_co_vn TYPE p LENGTH 13 DECIMALS 2,

          lv_subtotal_ps_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ps_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ps_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ps_co_vn TYPE p LENGTH 13 DECIMALS 2,

          lv_subtotal_ck_no_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ck_no_vn TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ck_co_nt TYPE p LENGTH 13 DECIMALS 2,
          lv_subtotal_ck_co_vn TYPE p LENGTH 13 DECIMALS 2.



    " Begin: processing data ZRM02
    LOOP AT lt_about_glaccount ASSIGNING FIELD-SYMBOL(<lfs_glaccount>).
*      AT NEW companycode.
*        CLEAR: ls_lines.
*        ls_lines-title_type = 1.
*        ls_lines-title = <lfs_glaccount>-compname.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*        ls_lines-title_type = 2.
*        ls_lines-title = <lfs_glaccount>-compadd.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*        ls_lines-title_type = 3.
*        ls_lines-title = |Mã số thuế: { <lfs_glaccount>-compmst }|.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*        ls_lines-title_type = 4.
*        ls_lines-title = 'SỔ TỔNG HỢP CÔNG NỢ PHẢI THU KHÁCH HÀNG'.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*        ls_lines-title_type = 5.
*        ls_lines-title = lv_glacc_grp.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*
*        ls_lines-title_type = 6.
*        IF lv_postingdate_from_fm IS NOT INITIAL AND lv_postingdate_to_fm IS NOT INITIAL.
*          IF lv_postingdate_from_fm <> lv_postingdate_to_fm.
*            ls_lines-title = |Từ ngày: { lv_postingdate_from_fm } đến ngày: { lv_postingdate_to_fm }|.
*          ELSE.
*            ls_lines-title = |Ngày: { lv_postingdate_from_fm }|.
*          ENDIF.
*        ELSEIF lv_postingdate_from_fm IS NOT INITIAL AND lv_postingdate_to_fm IS INITIAL.
*          ls_lines-title = |Ngày: { lv_postingdate_from_fm }|.
*        ENDIF.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*      ENDAT.


      READ TABLE lt_sodu_vn TRANSPORTING NO FIELDS WITH KEY customeraccountgroup = <lfs_glaccount>-customeraccountgroup customer = <lfs_glaccount>-customer glaccount = <lfs_glaccount>-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_sodu_vn INTO DATA(ls_sd_vn) FROM sy-tabix.
          IF ls_sd_vn-customeraccountgroup = <lfs_glaccount>-customeraccountgroup AND ls_sd_vn-customer = <lfs_glaccount>-customer AND ls_sd_vn-glaccount = <lfs_glaccount>-glaccount.

            ls_lines-balancetransactioncurrency = 'VND'.
            ls_lines-companycodecurrency = 'VND'.
*            ls_lines-balancetransactioncurrency = ls_sd_vn-balancetransactioncurrency.
*            ls_lines-companycodecurrency = ls_sd_vn-companycodecurrency.
            IF ls_sd_vn-typesodu = 'DK'.

              IF ls_sd_vn-amountcompcode >= 0.
                lv_dauki_no_vn = abs( ls_sd_vn-amountcompcode ).
              ELSE.
                lv_dauki_co_vn = abs( ls_sd_vn-amountcompcode ).
              ENDIF.

            ELSEIF ls_sd_vn-typesodu = 'PS_CO'.

              IF ls_sd_vn-amountcompcode > 0.
                lv_phatsinh_co_vn = ls_sd_vn-amountcompcode * -1.
              ELSE.
                lv_phatsinh_co_vn = abs( ls_sd_vn-amountcompcode ).
              ENDIF.
            ELSEIF ls_sd_vn-typesodu = 'PS_NO'.

              lv_phatsinh_no_vn = ls_sd_vn-amountcompcode.

            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.

        MOVE-CORRESPONDING <lfs_glaccount> TO ls_lines.
        ls_lines-customercode = |{ ls_lines-customer ALPHA = OUT }|.
        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
        IF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS NOT INITIAL.
          IF lv_date_from_fm <> lv_date_to_fm.
            ls_lines-postingdate_fromto  = |{ lv_date_from_fm } - { lv_date_to_fm }|.
          ELSE.
            ls_lines-postingdate_fromto  = |{ lv_date_from_fm }|.
          ENDIF.
        ELSEIF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS INITIAL.
          ls_lines-postingdate_fromto  = |{ lv_date_from_fm }|.
        ENDIF.

        "-- cuoi ki
        lv_cuoiki_vn = lv_dauki_no_vn - lv_dauki_co_vn + lv_phatsinh_no_vn - lv_phatsinh_co_vn.
        IF lv_cuoiki_vn >= 0.
          lv_cuoiki_no_vn = lv_cuoiki_vn.
        ELSE.
          lv_cuoiki_co_vn = lv_cuoiki_vn.
        ENDIF.

        "-- currency excel
        ls_lines-dauki_co_nt    = lv_dauki_co_nt .
        ls_lines-dauki_no_nt    = lv_dauki_no_nt .
        ls_lines-phatsinh_co_nt = lv_phatsinh_co_nt.
        ls_lines-phatsinh_no_nt = lv_phatsinh_no_nt.
        ls_lines-cuoiki_co_nt   = lv_cuoiki_co_nt .
        ls_lines-cuoiki_no_nt   = lv_cuoiki_no_nt .
        ls_lines-dauki_co_vn    = lv_dauki_co_vn .
        ls_lines-dauki_no_vn    = lv_dauki_no_vn .
        ls_lines-phatsinh_co_vn = lv_phatsinh_co_vn.
        ls_lines-phatsinh_no_vn = lv_phatsinh_no_vn.
        ls_lines-cuoiki_co_vn   = abs( lv_cuoiki_co_vn ).
        ls_lines-cuoiki_no_vn   = lv_cuoiki_no_vn.

        "-- line total
        lv_total_dk_no_vn = lv_total_dk_no_vn + lv_dauki_no_vn.
        lv_total_dk_co_vn = lv_total_dk_co_vn + lv_dauki_co_vn.
        lv_total_ps_no_vn = lv_total_ps_no_vn +  lv_phatsinh_no_vn.
        lv_total_ps_co_vn = lv_total_ps_co_vn +  lv_phatsinh_co_vn.
        lv_total_ck_no_vn = lv_total_ck_no_vn + lv_cuoiki_no_vn.
        lv_total_ck_co_vn = lv_total_ck_co_vn + lv_cuoiki_co_vn.

        "-- line subtotal key customer quy đổi usd - vnd
        lv_subtotal_dk_no_vn = lv_subtotal_dk_no_vn + lv_dauki_no_vn.
        lv_subtotal_dk_co_vn = lv_subtotal_dk_co_vn + lv_dauki_co_vn.
        lv_subtotal_ps_no_vn = lv_subtotal_ps_no_vn +  lv_phatsinh_no_vn.
        lv_subtotal_ps_co_vn = lv_subtotal_ps_co_vn +  lv_phatsinh_co_vn.
        lv_subtotal_ck_no_vn = lv_subtotal_ck_no_vn + lv_cuoiki_no_vn.
        lv_subtotal_ck_co_vn = lv_subtotal_ck_co_vn + lv_cuoiki_co_vn.


*        ls_lines-title_type = 7.
        APPEND ls_lines TO lt_lines.
        CLEAR: ls_lines, lv_cuoiki_vn,
        lv_dauki_no_vn, lv_dauki_co_vn, lv_phatsinh_no_vn, lv_phatsinh_co_vn, lv_cuoiki_no_vn, lv_cuoiki_co_vn,
        lv_dauki_no_nt, lv_dauki_co_nt, lv_phatsinh_no_nt, lv_phatsinh_co_nt, lv_cuoiki_no_nt, lv_cuoiki_co_nt .
      ENDIF.

      READ TABLE lt_sodu_nt TRANSPORTING NO FIELDS WITH KEY customeraccountgroup = <lfs_glaccount>-customeraccountgroup customer = <lfs_glaccount>-customer glaccount = <lfs_glaccount>-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_sodu_nt INTO DATA(ls_sd_nt) FROM sy-tabix.
          IF ls_sd_nt-customeraccountgroup = <lfs_glaccount>-customeraccountgroup AND ls_sd_nt-customer = <lfs_glaccount>-customer AND ls_sd_nt-glaccount = <lfs_glaccount>-glaccount.

            ls_lines-balancetransactioncurrency = 'USD'.
            ls_lines-companycodecurrency = 'VND'.
*            ls_lines-balancetransactioncurrency = ls_sd_nt-balancetransactioncurrency.
*            ls_lines-companycodecurrency = ls_sd_nt-companycodecurrency.
            IF ls_sd_nt-typesodu = 'DK'.

              IF ls_sd_nt-balance >= 0.
                lv_dauki_no_nt = abs( ls_sd_nt-balance ).
                lv_dauki_no_vn = abs( ls_sd_nt-amountcompcode ). " quy đổi usd - vnd
              ELSE.
                lv_dauki_co_nt = abs( ls_sd_nt-balance ).
                lv_dauki_co_vn = abs( ls_sd_nt-amountcompcode ). " quy đổi usd - vnd
              ENDIF.

            ELSEIF ls_sd_nt-typesodu = 'PS_CO'.

              IF ls_sd_nt-balance > 0.
                lv_phatsinh_co_nt = ls_sd_nt-balance * -1.
              ELSE.
                lv_phatsinh_co_nt = abs( ls_sd_nt-balance ) .
              ENDIF.
              IF ls_sd_nt-amountcompcode > 0.
                lv_phatsinh_co_vn =  ls_sd_nt-amountcompcode * -1." quy đổi usd - vnd
              ELSE.
                lv_phatsinh_co_vn =  abs( ls_sd_nt-amountcompcode )." quy đổi usd - vnd
              ENDIF.

            ELSEIF ls_sd_nt-typesodu = 'PS_NO'.


              lv_phatsinh_no_nt = ls_sd_nt-balance.
              lv_phatsinh_no_vn = ls_sd_nt-amountcompcode." quy đổi usd - vnd

            ENDIF.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.

        MOVE-CORRESPONDING <lfs_glaccount> TO ls_lines.
        ls_lines-customercode = |{ ls_lines-customer ALPHA = OUT }|.
        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
        IF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS NOT INITIAL.
          IF lv_date_from_fm <> lv_date_to_fm.
            ls_lines-postingdate_fromto  = |{ lv_date_from_fm } - { lv_date_to_fm }|.
          ELSE.
            ls_lines-postingdate_fromto  = |{ lv_date_from_fm }|.
          ENDIF.
        ELSEIF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS INITIAL.
          ls_lines-postingdate_fromto  = |{ lv_date_from_fm }|.
        ENDIF.

        "-- cuoi ki
        lv_cuoiki_nt = lv_dauki_no_nt - lv_dauki_co_nt + lv_phatsinh_no_nt - lv_phatsinh_co_nt.
        IF lv_cuoiki_nt >= 0.
          lv_cuoiki_no_nt = lv_cuoiki_nt.
        ELSE.
          lv_cuoiki_co_nt = lv_cuoiki_nt.
        ENDIF.
        "-- quy đổi cuối kì usd - vnd
        lv_cuoiki_vn = lv_dauki_no_vn - lv_dauki_co_vn + lv_phatsinh_no_vn - lv_phatsinh_co_vn.
        IF lv_cuoiki_vn >= 0.
          lv_cuoiki_no_vn = lv_cuoiki_vn.
        ELSE.
          lv_cuoiki_co_vn = lv_cuoiki_vn.
        ENDIF.

        "-- currency excel
        ls_lines-dauki_co_nt    = lv_dauki_co_nt .
        ls_lines-dauki_no_nt    = lv_dauki_no_nt .
        ls_lines-phatsinh_co_nt = lv_phatsinh_co_nt.
        ls_lines-phatsinh_no_nt = lv_phatsinh_no_nt.
        ls_lines-cuoiki_co_nt   = abs( lv_cuoiki_co_nt ).
        ls_lines-cuoiki_no_nt   = lv_cuoiki_no_nt.
        ls_lines-dauki_co_vn    = lv_dauki_co_vn .
        ls_lines-dauki_no_vn    = lv_dauki_no_vn .
        ls_lines-phatsinh_co_vn = lv_phatsinh_co_vn.
        ls_lines-phatsinh_no_vn = lv_phatsinh_no_vn.
        ls_lines-cuoiki_co_vn   = abs( lv_cuoiki_co_vn ).
        ls_lines-cuoiki_no_vn   = lv_cuoiki_no_vn.

        "-- line total
        lv_total_dk_no_nt = lv_total_dk_no_nt + lv_dauki_no_nt.
        lv_total_dk_co_nt = lv_total_dk_co_nt + lv_dauki_co_nt.
        lv_total_ps_no_nt = lv_total_ps_no_nt +  lv_phatsinh_no_nt.
        lv_total_ps_co_nt = lv_total_ps_co_nt +  lv_phatsinh_co_nt.
        lv_total_ck_no_nt = lv_total_ck_no_nt + lv_cuoiki_no_nt.
        lv_total_ck_co_nt = lv_total_ck_co_nt + lv_cuoiki_co_nt.

        "-- line total quy đổi usd - vnd
        lv_total_dk_no_vn = lv_total_dk_no_vn + lv_dauki_no_vn.
        lv_total_dk_co_vn = lv_total_dk_co_vn + lv_dauki_co_vn.
        lv_total_ps_no_vn = lv_total_ps_no_vn +  lv_phatsinh_no_vn.
        lv_total_ps_co_vn = lv_total_ps_co_vn +  lv_phatsinh_co_vn.
        lv_total_ck_no_vn = lv_total_ck_no_vn + lv_cuoiki_no_vn.
        lv_total_ck_co_vn = lv_total_ck_co_vn + lv_cuoiki_co_vn.

        "-- line subtotal key customer
        lv_subtotal_dk_no_nt = lv_subtotal_dk_no_nt + lv_dauki_no_nt.
        lv_subtotal_dk_co_nt = lv_subtotal_dk_co_nt + lv_dauki_co_nt.
        lv_subtotal_ps_no_nt = lv_subtotal_ps_no_nt +  lv_phatsinh_no_nt.
        lv_subtotal_ps_co_nt = lv_subtotal_ps_co_nt +  lv_phatsinh_co_nt.
        lv_subtotal_ck_no_nt = lv_subtotal_ck_no_nt + lv_cuoiki_no_nt.
        lv_subtotal_ck_co_nt = lv_subtotal_ck_co_nt + lv_cuoiki_co_nt.

        "-- line subtotal key customer quy đổi usd - vnd
        lv_subtotal_dk_no_vn = lv_subtotal_dk_no_vn + lv_dauki_no_vn.
        lv_subtotal_dk_co_vn = lv_subtotal_dk_co_vn + lv_dauki_co_vn.
        lv_subtotal_ps_no_vn = lv_subtotal_ps_no_vn +  lv_phatsinh_no_vn.
        lv_subtotal_ps_co_vn = lv_subtotal_ps_co_vn +  lv_phatsinh_co_vn.
        lv_subtotal_ck_no_vn = lv_subtotal_ck_no_vn + lv_cuoiki_no_vn.
        lv_subtotal_ck_co_vn = lv_subtotal_ck_co_vn + lv_cuoiki_co_vn.

*        ls_lines-title_type = 8.
        APPEND ls_lines TO lt_lines.
        CLEAR: ls_lines, lv_cuoiki_vn, lv_cuoiki_nt,
        lv_dauki_no_vn, lv_dauki_co_vn, lv_phatsinh_no_vn, lv_phatsinh_co_vn, lv_cuoiki_no_vn, lv_cuoiki_co_vn,
        lv_dauki_no_nt, lv_dauki_co_nt, lv_phatsinh_no_nt, lv_phatsinh_co_nt, lv_cuoiki_no_nt, lv_cuoiki_co_nt .
      ENDIF.

      AT END OF customeraccountgroup.
        CLEAR: ls_lines.
        "-- begin: total line
*        ls_lines-title_type = 9.
        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
        IF <lfs_glaccount>-customeraccountgroup = 'Z10'.
          ls_lines-title = |Tổng nhóm trong nước|.
        ELSEIF <lfs_glaccount>-customeraccountgroup = 'Z20'.
          ls_lines-title = |Tổng nhóm nước ngoài|.
        ELSEIF <lfs_glaccount>-customeraccountgroup = 'Z30'.
          ls_lines-title = |Tổng nhóm NH, HQ, CQNN|.
        ELSEIF <lfs_glaccount>-customeraccountgroup = 'Z40'.
          ls_lines-title = |Tổng nhóm nội bộ|.
        ELSEIF <lfs_glaccount>-customeraccountgroup = 'Z50'.
          ls_lines-title = |Tổng nhóm nhân viên|.
        ELSE.
          ls_lines-title = |Tổng|.
        ENDIF.
        ls_lines-balancetransactioncurrency = 'USD'.
        ls_lines-companycodecurrency = 'VND'.
        ls_lines-dauki_co_nt    = lv_subtotal_dk_co_nt .
        ls_lines-dauki_no_nt    = lv_subtotal_dk_no_nt .

        ls_lines-phatsinh_co_nt = lv_subtotal_ps_co_nt.
        ls_lines-phatsinh_no_nt = lv_subtotal_ps_no_nt.

        IF ( lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt ) < 0.
          ls_lines-cuoiki_co_nt   = abs( lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt ).
        ELSE.
          ls_lines-cuoiki_no_nt   = lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt .
        ENDIF.

        ls_lines-dauki_co_vn    = lv_subtotal_dk_co_vn.
        ls_lines-dauki_no_vn    = lv_subtotal_dk_no_vn.

        ls_lines-phatsinh_co_vn = lv_subtotal_ps_co_vn.
        ls_lines-phatsinh_no_vn = lv_subtotal_ps_no_vn.

        IF ( lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn ) < 0.
          ls_lines-cuoiki_co_vn   = abs( lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn ).
        ELSE.
          ls_lines-cuoiki_no_vn   = ( lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn ).
        ENDIF.
        APPEND ls_lines TO lt_lines.
        CLEAR: ls_lines, lv_subtotal_dk_co_nt, lv_subtotal_dk_no_nt, lv_subtotal_ps_co_nt, lv_subtotal_ps_no_nt, lv_subtotal_ck_co_nt, lv_subtotal_ck_no_nt,
               lv_subtotal_dk_co_vn, lv_subtotal_dk_no_vn, lv_subtotal_ps_co_vn, lv_subtotal_ps_no_vn, lv_subtotal_ck_co_vn, lv_subtotal_ck_no_vn.
        "-- end: total line
      ENDAT.

      AT LAST.
        CLEAR: ls_lines.
        "-- begin: total line
*        ls_lines-title_type = 10.
        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
        ls_lines-title = |Tổng cộng|.
        ls_lines-balancetransactioncurrency = 'USD'.
        ls_lines-companycodecurrency = 'VND'.
        ls_lines-dauki_co_nt    = lv_total_dk_co_nt .
        ls_lines-dauki_no_nt    = lv_total_dk_no_nt .

        ls_lines-phatsinh_co_nt = lv_total_ps_co_nt.
        ls_lines-phatsinh_no_nt = lv_total_ps_no_nt.

        ls_lines-cuoiki_co_nt   = abs( lv_total_ck_co_nt ) .
        ls_lines-cuoiki_no_nt   = abs( lv_total_ck_no_nt ) .


        ls_lines-dauki_co_vn    = lv_total_dk_co_vn .
        ls_lines-dauki_no_vn    = lv_total_dk_no_vn.

        ls_lines-phatsinh_co_vn = lv_total_ps_co_vn.
        ls_lines-phatsinh_no_vn = lv_total_ps_no_vn.


        ls_lines-cuoiki_co_vn   = abs( lv_total_ck_co_vn ).

        ls_lines-cuoiki_no_vn   = abs( lv_total_ck_no_vn ).
        APPEND ls_lines TO lt_lines.
        CLEAR: ls_lines.
        "-- end: total line


*        ls_lines-title_type = 10.
*        ls_lines-title = lv_current_date.
*        ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*        APPEND ls_lines TO lt_lines.
*        CLEAR: ls_lines.
*
*        IF lr_nguoilap IS INITIAL.
*          ls_lines-title_type = 11.
*          ls_lines-title = |Người Lập: |.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ELSE.
*          ls_lines-title_type = 11.
*          READ TABLE lr_nguoilap INTO DATA(ls_nl) INDEX 1.
*          IF sy-subrc = 0. ls_lines-title = |Người Lập: { ls_nl-low }|. ENDIF.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ENDIF.
*
*        IF lr_ketoan IS INITIAL.
*          ls_lines-title_type = 12.
*          ls_lines-title = |Kế Toán Trưởng: |.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ELSE.
*          ls_lines-title_type = 12.
*          READ TABLE lr_ketoan   INTO DATA(ls_kt) INDEX 1.
*          IF sy-subrc = 0. ls_lines-title = |Kế Toán Trưởng: { ls_kt-low }|. ENDIF.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ENDIF.
*
*        IF lr_giamdoc IS INITIAL.
*          ls_lines-title_type = 13.
*          ls_lines-title = |Giám Đốc: |.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ELSE.
*          ls_lines-title_type = 13.
*          READ TABLE lr_giamdoc  INTO DATA(ls_gd) INDEX 1.
*          IF sy-subrc = 0. ls_lines-title = |Giám Đốc: { ls_gd-low }|. ENDIF.
*          ls_lines-postingdate = lv_prev_postingdate. "--> Note: fill data temp tránh lỗi hệ thống sai data type DATS null
*          APPEND ls_lines TO lt_lines.
*          CLEAR: ls_lines.
*        ENDIF.
      ENDAT.
    ENDLOOP.

    DATA: lv_count TYPE int4.
    "-- Begin: Add title in LT_LINES
    LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<lfs_count_h>).
      lv_count += 1.
      <lfs_count_h>-title_type = lv_count.
    ENDLOOP.
    "-- End: Add title in LT_LINES
*    SORT lt_lines BY title_type.
    lt_data_output = CORRESPONDING #( lt_lines ).
    et_table = lt_data_output.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lt_data_output TYPE tt_data_output.
    DATA: lt_linestop TYPE tt_data_output.

    CHECK io_request->is_data_requested( ).
    DATA(rt_requested_elements) = io_request->get_requested_elements( ).
    DATA(ro_aggregation) = io_request->get_aggregation( ).
    DATA(ro_filter) = io_request->get_filter(  ).

    DATA(rt_aggregated_elements) = ro_aggregation->get_aggregated_elements( ).
    DATA(rt_grouped_elements) = ro_aggregation->get_grouped_elements( ).

    " Top
    DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    " Skip
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).

    me->get_data(
      EXPORTING
        io_request = io_request
      IMPORTING
        et_table   = lt_data_output
    ).

    IF lines( lt_data_output ) > 0.
      LOOP AT lt_data_output INTO DATA(ls_row) FROM lv_skip + 1 TO lv_skip + lv_top.
        APPEND ls_row TO lt_linestop.
      ENDLOOP.
    ENDIF.

    io_response->set_data( lt_linestop ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data_output ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
