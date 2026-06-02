CLASS zcl_fa_enity_zgl02_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
    INTERFACES if_rap_query_request .
    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ENITY_ZGL02_EX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_data TYPE TABLE OF zfa_r_zgl02_ex,
          ls_data TYPE zfa_r_zgl02_ex.
    DATA: lt_header TYPE TABLE OF zfa_r_zgl02,
          ls_header TYPE zfa_r_zgl02.
    DATA lr_compnaycode    TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_glaccount     TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_report_year    TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_report_period  TYPE if_rap_query_filter=>tt_range_option.
    DATA: lr_display_subtotal TYPE if_rap_query_filter=>tt_range_option.
*    DATA lr_uuid TYPE if_rap_query_filter=>tt_range_option.
*    DATA lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
*    DATA lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
*    DATA lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
    DATA: lv_year_period TYPE string.
    DATA: lv_period TYPE c LENGTH 3.
    DATA: lv_dauky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_dauky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_trongky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_trongky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_cuoiky     TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_dauky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_dauky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_trongky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_trongky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_cuoiky_co     TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_cuoiky_no     TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_dauky TYPE p LENGTH 13 DECIMALS 2.
*    DATA: lv_xml TYPE string.
*    DATA: lv_uuid_fi TYPE uuid.
    TRY.
        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).

    IF lo_filter IS NOT INITIAL.
      LOOP AT lo_filter INTO DATA(lw_filter).
        CASE lw_filter-name.
          WHEN 'COMPANYCODE'.
            lr_compnaycode = lw_filter-range.
            DATA(lw_companycode) = lr_compnaycode[ 1 ].
          WHEN 'GLACCOUNT'.
            lr_glaccount = lw_filter-range.
            DATA(lw_glaccount) = lr_glaccount[ 1 ].
          WHEN 'FISCALPERIOD'.
            lr_report_period = lw_filter-range.
            DATA(lw_report_period) = lr_report_period[ 1 ].
          WHEN 'FISCALYEAR'.
            lr_report_year = lw_filter-range.
            DATA(lw_report_year) = lr_report_year[ 1 ].
          WHEN 'DISPLAY_SUBTOTAL'.
            lr_display_subtotal = lw_filter-range.
*          WHEN 'UUID'.
*            lr_uuid = lw_filter-range.
*            DATA(lw_uuid) = lr_uuid[ 1 ].
*          WHEN 'NGUOI_LAP'.
*            lr_nguoi_lap = lw_filter-range.
*            IF lw_filter-range IS NOT INITIAL.
*              DATA(lw_nguoi_lap) = lr_nguoi_lap[ 1 ].
*            ENDIF.
*          WHEN 'KE_TOAN'.
*            lr_ke_toan = lw_filter-range.
*            IF lw_filter-range IS NOT INITIAL.
*              DATA(lw_ke_toan) = lr_ke_toan[ 1 ].
*            ENDIF.
*          WHEN 'GIAM_DOC'.
*            lr_giam_doc = lw_filter-range.
*            IF lw_filter-range IS NOT INITIAL.
*              DATA(lw_giam_doc) = lr_giam_doc[ 1 ].
*            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    DATA: lv_allow TYPE abap_boolean.
    DATA: lv_company TYPE c LENGTH 4.
    lv_company = lw_companycode-low .
    me->authorization(
      EXPORTING
        i_company = lv_company
      IMPORTING
        e_allow   = lv_allow
    ).

    IF lv_allow IS NOT INITIAL.
      "Company Info
      SELECT SINGLE
      tencty_vn,
      diachi_vn,
      concat_with_space( 'Mã số thuế:', concat_with_space( ' ', mst , 1 ) , 1 ) AS mst
      FROM zcds_company AS compnay
      WHERE companycode IN @lr_compnaycode
      INTO @DATA(ls_compnay).

      lv_period = |{ lw_report_period-low ALPHA = IN }|.
      lv_year_period = |{ lw_report_year-low }{ lv_period }|.

      DATA(lv_display_subtotal) = lr_display_subtotal[ 1 ]-low.
      TYPES : BEGIN OF lt_gl_data_type,
                keysubtotal  TYPE string,
                glaccount    TYPE zfa_r_zgl02-glaccount,
                account_text TYPE string,
                group_lv_1   TYPE string,
                group_lv_2   TYPE string,
                zlevel       TYPE string,
              END OF lt_gl_data_type.
      DATA lt_glaccount TYPE TABLE OF lt_gl_data_type WITH EMPTY KEY.
      DATA: lt_glaccount_level1 TYPE TABLE OF lt_gl_data_type WITH EMPTY KEY.
      DATA: lt_glaccount_level2 TYPE TABLE OF lt_gl_data_type WITH EMPTY KEY.
      CASE lv_display_subtotal.
        WHEN 'LEVEL1'.
          "select
          SELECT
              left( gl_acc~glaccount , 3 ) AS keysubtotal,
              gl_acc~glaccount,
              text_key~hierarchynodetext AS account_text
              FROM i_glaccount AS gl_acc
*              LEFT JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_acc~glaccount , 3 )
              INNER JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_acc~glaccount , 3 )
              AND text_key~language = 'E'
              AND text_key~hierarchytype = 'GL05'
              WHERE  gl_acc~chartofaccounts = 'YCOA'

              AND gl_acc~companycode IN @lr_compnaycode
              AND gl_acc~glaccount IN @lr_glaccount
              AND gl_acc~glaccount NOT LIKE '00%'
              ORDER BY keysubtotal, glaccount
              INTO TABLE @lt_glaccount
*                    UP TO @top ROWS
*      OFFSET @skip
      .


        WHEN 'LEVEL2'.
          SELECT
              left( gl_data~glaccount , 4 ) AS keysubtotal,
              gl_data~glaccount,
              text_key~hierarchynodetext AS account_text
              FROM i_glaccount AS gl_data
*              LEFT JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_data~glaccount , 4 )
              INNER JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_data~glaccount , 4 )
              AND text_key~language = 'E'
              AND text_key~hierarchytype = 'GL05'
              WHERE  gl_data~chartofaccounts = 'YCOA'

              AND gl_data~companycode IN @lr_compnaycode
              AND gl_data~glaccount IN @lr_glaccount
              AND gl_data~glaccount NOT LIKE '00%'
              ORDER BY keysubtotal, glaccount
              INTO TABLE @lt_glaccount
*                    UP TO @top ROWS
*      OFFSET @skip
      .
        WHEN 'DETAIL'.
          SELECT
            gl_data~glaccount AS keysubtotal,
            gl_data~glaccount,
            gl_text~glaccountname AS account_text,
            left( gl_data~glaccount , 3 ) AS group_lv_1,
            left( gl_data~glaccount , 4 ) AS group_lv_2,
            '2' AS zlevel
            FROM i_glaccount AS gl_data
            LEFT OUTER JOIN i_glaccounttext AS gl_text ON gl_text~glaccount = gl_data~glaccount
*            inner JOIN i_glaccounttext AS gl_text ON gl_text~glaccount = gl_data~glaccount
            AND gl_text~language = 'E'
            AND gl_text~chartofaccounts = gl_data~chartofaccounts
            WHERE  gl_data~chartofaccounts = 'YCOA'
            AND gl_data~companycode IN @lr_compnaycode
            AND gl_data~glaccount IN @lr_glaccount
            AND gl_data~glaccount NOT LIKE '00%'
              ORDER BY keysubtotal, gl_data~glaccount
              INTO TABLE @lt_glaccount
*                    UP TO @top ROWS
*      OFFSET @skip
      .
          SELECT
                             left( gl_acc~glaccount , 3 ) AS keysubtotal,
                             gl_acc~glaccount,
                             text_key~hierarchynodetext AS account_text,
                             left( gl_acc~glaccount , 3 ) AS group_lv_1,
                             '1' AS zlevel
                             FROM i_glaccount AS gl_acc
*                LEFT JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_acc~glaccount , 3 )
                             INNER JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_acc~glaccount , 3 )
                             AND text_key~language = 'E'
                             AND text_key~hierarchytype = 'GL05'
                             WHERE  gl_acc~chartofaccounts = 'YCOA'

                             AND gl_acc~companycode IN @lr_compnaycode
                             AND gl_acc~glaccount IN @lr_glaccount
                             AND gl_acc~glaccount NOT LIKE '00%'
                             ORDER BY keysubtotal, glaccount
                             INTO TABLE @lt_glaccount_level1
*                    UP TO @top ROWS
*      OFFSET @skip
                     .
          SELECT
              left( gl_data~glaccount , 4 ) AS keysubtotal,
              gl_data~glaccount,
              text_key~hierarchynodetext AS account_text,
              left( gl_data~glaccount , 3 ) AS group_lv_1,
              left( gl_data~glaccount , 4 ) AS group_lv_2,
              '2' AS zlevel
              FROM i_glaccount AS gl_data
*
              INNER JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_data~glaccount , 4 )
              AND text_key~language = 'E'
              AND text_key~hierarchytype = 'GL05'
              WHERE  gl_data~chartofaccounts = 'YCOA'

              AND gl_data~companycode IN @lr_compnaycode
              AND gl_data~glaccount IN @lr_glaccount
              AND gl_data~glaccount NOT LIKE '00%'
              ORDER BY keysubtotal, glaccount
              INTO TABLE @lt_glaccount_level2.
      ENDCASE.

      SELECT
       SUM( amountincompanycodecurrency ) AS amountincompanycode,
       glaccount
       FROM i_glaccountlineitemrawdata AS gl_data
       WHERE gl_data~companycode IN @lr_compnaycode
       AND gl_data~glaccount IN @lr_glaccount
       AND gl_data~fiscalyearperiod = @lv_year_period
       AND gl_data~debitcreditcode = 'S'
       AND gl_data~sourceledger = '0L'
       GROUP BY glaccount
       ORDER BY glaccount
       INTO TABLE @DATA(lt_gl_debit_trongky).

      SELECT
          SUM( amountincompanycodecurrency ) AS amountincompanycode,
          glaccount
          FROM i_glaccountlineitemrawdata AS gl_data
          WHERE gl_data~companycode IN @lr_compnaycode
          AND gl_data~glaccount IN @lr_glaccount
          AND gl_data~fiscalyearperiod = @lv_year_period
          AND gl_data~debitcreditcode = 'H'
          AND gl_data~sourceledger = '0L'
          GROUP BY glaccount
          ORDER BY glaccount
          INTO TABLE @DATA(lt_gl_credit_trongky).


      SELECT
       SUM( amountincompanycodecurrency ) AS amountincompanycode,
       glaccount
       FROM i_glaccountlineitemrawdata AS gl_data
       WHERE gl_data~companycode IN @lr_compnaycode
       AND gl_data~glaccount IN @lr_glaccount
       AND gl_data~fiscalyearperiod < @lv_year_period
       AND gl_data~fiscalyear = @lw_report_year-low
       AND gl_data~debitcreditcode = 'S'
       AND gl_data~sourceledger = '0L'
       GROUP BY glaccount
       ORDER BY glaccount
       INTO TABLE @DATA(lt_gl_debit_before).

      SELECT
       SUM( amountincompanycodecurrency ) AS amountincompanycode,
       glaccount
       FROM i_glaccountlineitemrawdata AS gl_data
       WHERE gl_data~companycode IN @lr_compnaycode
       AND gl_data~glaccount IN @lr_glaccount
       AND gl_data~fiscalyear = @lw_report_year-low
       AND gl_data~fiscalyearperiod < @lv_year_period
       AND gl_data~debitcreditcode = 'H'
       AND gl_data~sourceledger = '0L'
       GROUP BY glaccount
       ORDER BY glaccount
       INTO TABLE @DATA(lt_gl_credit_before).



      LOOP AT lt_glaccount INTO DATA(lw_glacc).
        DATA(lw_acc_1) = lw_glacc.
        "so du dau ky - no
        READ TABLE lt_gl_debit_before INTO DATA(lw_debit_before) WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_no += lw_debit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_before INTO DATA(lw_credit_before) WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_co += lw_credit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_debit_trongky INTO DATA(lw_debit_trongky) WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_no += lw_debit_trongky-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_trongky INTO DATA(lw_credit_trongky) WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_co += lw_credit_trongky-amountincompanycode.
        ENDIF.
        AT END OF   keysubtotal.
*          ls_data-uuid = lv_uuid_fi.
          ls_data-currency = 'VND'.
          ls_data-keysubtotal = lw_acc_1-keysubtotal.
          ls_data-glaccount = lw_acc_1-glaccount.
          ls_data-account_text = lw_acc_1-account_text.
          lv_dauky = lv_dauky_no + lv_dauky_co.
          IF lv_dauky > 0.
            ls_data-dauky_no = abs( lv_dauky ).
            ls_data-dauky_co = 0.
          ELSE.
            ls_data-dauky_no = 0 .
            ls_data-dauky_co = abs( lv_dauky ).
          ENDIF.
          ls_data-phatsinh_no = lv_trongky_no.
          ls_data-phatsinh_co = lv_trongky_co * -1.
          lv_cuoiky = lv_dauky_no + lv_trongky_no - ( ( lv_dauky_co * -1 ) + ( lv_trongky_co * -1 ) ).
          IF lv_cuoiky > 0.
            ls_data-cuoiky_no = lv_cuoiky.
            ls_data-cuoiky_co = 0.
          ELSE.
            ls_data-cuoiky_no = 0.
            ls_data-cuoiky_co = lv_cuoiky * -1.
          ENDIF.
          lv_total_dauky_co += ls_data-dauky_co.
          lv_total_dauky_no += ls_data-dauky_no.
          lv_total_trongky_no += ls_data-phatsinh_no.
          lv_total_trongky_co += ls_data-phatsinh_co.
          lv_total_cuoiky_no += ls_data-cuoiky_no.
          lv_total_cuoiky_co += ls_data-cuoiky_co.
          ls_data-group_lv_1 = lw_acc_1-group_lv_1.
          ls_data-group_lv_2 = lw_acc_1-group_lv_2.
          ls_data-zlevel = 'C'.
          APPEND ls_data TO lt_data.
          CLEAR: lv_dauky_no, lv_dauky_co, lv_trongky_no, lv_trongky_co, lv_cuoiky, ls_data.
        ENDAT.
      ENDLOOP.
      CLEAR: lw_glacc , lw_acc_1.
      LOOP AT lt_glaccount_level2 INTO lw_glacc.
        lw_acc_1 = lw_glacc.
        "so du dau ky - no
        READ TABLE lt_gl_debit_before INTO lw_debit_before WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_no += lw_debit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_before INTO lw_credit_before WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_co += lw_credit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_debit_trongky INTO lw_debit_trongky WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_no += lw_debit_trongky-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_trongky INTO lw_credit_trongky WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_co += lw_credit_trongky-amountincompanycode.
        ENDIF.
        AT END OF   keysubtotal.
*          ls_data-uuid = lv_uuid_fi.
          ls_data-currency = 'VND'.
          ls_data-keysubtotal = lw_acc_1-keysubtotal.
          ls_data-glaccount = lw_acc_1-glaccount.
          ls_data-account_text = lw_acc_1-account_text.
          lv_dauky = lv_dauky_no + lv_dauky_co.
          IF lv_dauky > 0.
            ls_data-dauky_no = abs( lv_dauky ).
            ls_data-dauky_co = 0.
          ELSE.
            ls_data-dauky_no = 0 .
            ls_data-dauky_co = abs( lv_dauky ).
          ENDIF.
          ls_data-phatsinh_no = lv_trongky_no.
          ls_data-phatsinh_co = lv_trongky_co * -1.
          lv_cuoiky = lv_dauky_no + lv_trongky_no - ( ( lv_dauky_co * -1 ) + ( lv_trongky_co * -1 ) ).
          IF lv_cuoiky > 0.
            ls_data-cuoiky_no = lv_cuoiky.
            ls_data-cuoiky_co = 0.
          ELSE.
            ls_data-cuoiky_no = 0.
            ls_data-cuoiky_co = lv_cuoiky * -1.
          ENDIF.
          lv_total_dauky_co += ls_data-dauky_co.
          lv_total_dauky_no += ls_data-dauky_no.
          lv_total_trongky_no += ls_data-phatsinh_no.
          lv_total_trongky_co += ls_data-phatsinh_co.
          lv_total_cuoiky_no += ls_data-cuoiky_no.
          lv_total_cuoiky_co += ls_data-cuoiky_co.
          ls_data-group_lv_1 = lw_acc_1-group_lv_1.
          ls_data-group_lv_2 = lw_acc_1-group_lv_2.
          ls_data-zlevel = 'B'.
          APPEND ls_data TO lt_data.
          CLEAR: lv_dauky_no, lv_dauky_co, lv_trongky_no, lv_trongky_co, lv_cuoiky, ls_data.
        ENDAT.
      ENDLOOP.

      LOOP AT lt_glaccount_level1 INTO lw_glacc.
        lw_acc_1 = lw_glacc.
        "so du dau ky - no
        READ TABLE lt_gl_debit_before INTO lw_debit_before WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_no += lw_debit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_before INTO lw_credit_before WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_dauky_co += lw_credit_before-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_debit_trongky INTO lw_debit_trongky WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_no += lw_debit_trongky-amountincompanycode.
        ENDIF.

        READ TABLE lt_gl_credit_trongky INTO lw_credit_trongky WITH KEY glaccount = lw_acc_1-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          lv_trongky_co += lw_credit_trongky-amountincompanycode.
        ENDIF.
        AT END OF   keysubtotal.
*          ls_data-uuid = lv_uuid_fi.
          ls_data-currency = 'VND'.
          ls_data-keysubtotal = lw_acc_1-keysubtotal.
          ls_data-glaccount = lw_acc_1-glaccount.
          ls_data-account_text = lw_acc_1-account_text.
          lv_dauky = lv_dauky_no + lv_dauky_co.
          IF lv_dauky > 0.
            ls_data-dauky_no = abs( lv_dauky ).
            ls_data-dauky_co = 0.
          ELSE.
            ls_data-dauky_no = 0 .
            ls_data-dauky_co = abs( lv_dauky ).
          ENDIF.
          ls_data-phatsinh_no = lv_trongky_no.
          ls_data-phatsinh_co = lv_trongky_co * -1.
          lv_cuoiky = lv_dauky_no + lv_trongky_no - ( ( lv_dauky_co * -1 ) + ( lv_trongky_co * -1 ) ).
          IF lv_cuoiky > 0.
            ls_data-cuoiky_no = lv_cuoiky.
            ls_data-cuoiky_co = 0.
          ELSE.
            ls_data-cuoiky_no = 0.
            ls_data-cuoiky_co = lv_cuoiky * -1.
          ENDIF.
          lv_total_dauky_co += ls_data-dauky_co.
          lv_total_dauky_no += ls_data-dauky_no.
          lv_total_trongky_no += ls_data-phatsinh_no.
          lv_total_trongky_co += ls_data-phatsinh_co.
          lv_total_cuoiky_no += ls_data-cuoiky_no.
          lv_total_cuoiky_co += ls_data-cuoiky_co.
          ls_data-group_lv_1 = lw_acc_1-group_lv_1.
          ls_data-zlevel = 'A'.
          APPEND ls_data TO lt_data.
          CLEAR: lv_dauky_no, lv_dauky_co, lv_trongky_no, lv_trongky_co, lv_cuoiky, ls_data.
        ENDAT.
      ENDLOOP.
*      SORT lt_data BY group_lv_1 group_lv_2 zlevel keysubtotal glaccount.
      DATA(lw_total) = VALUE zfa_r_zgl02_ex(
*      keysubtotal = 'TOTAL'
        account_text = 'Tổng cộng'
        dauky_no = lv_total_dauky_no
        dauky_co = lv_total_dauky_co
        phatsinh_no = lv_total_trongky_no
        phatsinh_co = lv_total_trongky_co
        cuoiky_no = lv_total_cuoiky_no
        cuoiky_co = lv_total_cuoiky_co
      ).
      APPEND lw_total TO lt_data.
      CLEAR lw_total.
      SORT lt_data BY group_lv_1 group_lv_2 zlevel ASCENDING.
      DATA lv_lines TYPE int8.
      IF lines( lt_data ) > 0.
        DATA(lt_data_tmp) = lt_data.
        lv_lines = lines( lt_data ).
        FREE lt_data.
        LOOP AT lt_data_tmp INTO DATA(ls_row) FROM skip + 1 TO skip + top  . "#EC CI_NOORDER
          ls_row-cuoiky_co =  ls_row-cuoiky_co * 100.
          ls_row-cuoiky_no =  ls_row-cuoiky_no * 100.
          ls_row-dauky_co =  ls_row-dauky_co * 100.
          ls_row-dauky_no =  ls_row-dauky_no * 100.
          ls_row-phatsinh_co =  ls_row-phatsinh_co * 100.
          ls_row-phatsinh_no =  ls_row-phatsinh_no * 100.
          APPEND ls_row TO lt_data.
        ENDLOOP.
      ENDIF.
    ENDIF.

    io_response->set_data( lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lv_lines ).
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


  METHOD authorization.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK' ##AUTH_FLD_MISSING
        ID 'BUKRS' FIELD i_company.
    IF sy-subrc = 0.
      e_allow = 'X'.
    ELSE.
      e_allow = ''.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
