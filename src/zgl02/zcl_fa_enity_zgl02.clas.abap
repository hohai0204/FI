CLASS zcl_fa_enity_zgl02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: gtt_item TYPE STANDARD TABLE OF zfa_r_zgl02 WITH EMPTY KEY.
    TYPES: BEGIN OF gty_excel,
             h_company_name       TYPE string,
             h_company_add        TYPE string,
             h_company_mst        TYPE string,
             h_title_vn           TYPE string,
             h_title_subtitle     TYPE string,
             h_donvitinh          TYPE string,
             i_title_taikhoan     TYPE string,
             i_title_tentaikhoan  TYPE string,
             i_title_dk_no        TYPE string,
             i_title_dk_co        TYPE string,
             i_title_ps_no        TYPE string,
             i_title_ps_co        TYPE string,
             i_title_ck_no        TYPE string,
             i_title_ck_co        TYPE string,
             i_title_dk           TYPE string,
             i_title_ps           TYPE string,
             i_title_ck           TYPE string,
             item                 TYPE gtt_item,
             f_title_total        TYPE string,
             f_total_dk_no        TYPE p LENGTH 16 DECIMALS 2,
             f_total_dk_co        TYPE p LENGTH 16 DECIMALS 2,
             f_total_ps_no        TYPE p LENGTH 16 DECIMALS 2,
             f_total_ps_co        TYPE p LENGTH 16 DECIMALS 2,
             f_total_ck_no        TYPE p LENGTH 16 DECIMALS 2,
             f_total_ck_co        TYPE p LENGTH 16 DECIMALS 2,
             f_ngaythangnam       TYPE string,
             f_title_nguoilap     TYPE string,
             f_title_ketoantruong TYPE string,
             f_title_tonggiamdoc  TYPE string,
             f_nguoilap           TYPE string,
             f_ketoantruong       TYPE string,
             f_tonggiamdoc        TYPE string,
           END OF gty_excel,
           gtt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.

    INTERFACES if_rap_query_provider .
    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.

    METHODS create_excel
      IMPORTING i_data     TYPE gtt_excel
      EXPORTING e_excel    TYPE zde_attachment_tmpl
                e_filename TYPE string
                e_mimetype TYPE string
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ENITY_ZGL02 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_data TYPE TABLE OF zfa_r_zgl02,
          ls_data TYPE zfa_r_zgl02.
    DATA: lt_header TYPE TABLE OF zfa_r_zgl02,
          ls_header TYPE zfa_r_zgl02.
    DATA lr_compnaycode    TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_glaccount     TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_report_year    TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_report_period  TYPE if_rap_query_filter=>tt_range_option.
    DATA: lr_display_subtotal TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_uuid TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
    DATA: lr_incl_reserve TYPE if_rap_query_filter=>tt_range_option.
    DATA: lv_year_period TYPE string.
    DATA: lv_period TYPE c LENGTH 3.
    DATA: lv_dauky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_dauky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_trongky_no TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_trongky_co TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_cuoiky     TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_total_dauky_no TYPE zde_amount23.
    DATA: lv_total_dauky_co TYPE zde_amount23.
    DATA: lv_total_trongky_no TYPE zde_amount23.
    DATA: lv_total_trongky_co TYPE zde_amount23.
    DATA: lv_total_cuoiky_co     TYPE zde_amount23.
    DATA: lv_total_cuoiky_no     TYPE zde_amount23.
    DATA: lv_dauky TYPE p LENGTH 13 DECIMALS 2.
    DATA: lv_xml TYPE string.
    DATA: lv_uuid_fi TYPE uuid.
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
          WHEN 'UUID'.
            lr_uuid = lw_filter-range.
            DATA(lw_uuid) = lr_uuid[ 1 ].
          WHEN 'NGUOI_LAP'.
            lr_nguoi_lap = lw_filter-range.
            IF lw_filter-range IS NOT INITIAL.
              DATA(lw_nguoi_lap) = lr_nguoi_lap[ 1 ].
            ENDIF.
          WHEN 'KE_TOAN'.
            lr_ke_toan = lw_filter-range.
            IF lw_filter-range IS NOT INITIAL.
              DATA(lw_ke_toan) = lr_ke_toan[ 1 ].
            ENDIF.
          WHEN 'GIAM_DOC'.
            lr_giam_doc = lw_filter-range.
            IF lw_filter-range IS NOT INITIAL.
              DATA(lw_giam_doc) = lr_giam_doc[ 1 ].
            ENDIF.
          WHEN 'INCL_RESERVE'.
            lr_incl_reserve = lw_filter-range.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    DATA: lv_allow TYPE abap_boolean.
    DATA: lv_company TYPE c LENGTH 4.
    lv_company = lw_companycode-low.
    me->authorization(
      EXPORTING
        i_company = lv_company
      IMPORTING
        e_allow   = lv_allow
    ).
    IF lv_allow IS NOT INITIAL.
      IF lr_uuid IS NOT INITIAL.

        SELECT SINGLE *
        FROM ztb_zgl02_pdf AS pdf
        WHERE pdf~object_id = @lw_uuid-low
        INTO @DATA(lw_pdf).
      ENDIF.
      IF lw_pdf IS INITIAL.

        TRY.
            lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
          CATCH cx_uuid_error INTO DATA(lw_err).
            DATA(lv_err_text) = lw_err->get_text( ).  " Hoặc ghi log, v.v.)
        ENDTRY.

        "Company Info
        SELECT SINGLE
        tencty_vn,
        diachi_vn23 AS diachi_vn,
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
*                LEFT JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_acc~glaccount , 3 )
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
*        select

        .


          WHEN 'LEVEL2'.
            SELECT
                left( gl_data~glaccount , 4 ) AS keysubtotal,
                gl_data~glaccount,
                text_key~hierarchynodetext AS account_text
                FROM i_glaccount AS gl_data
*                LEFT JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_data~glaccount , 4 )
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
          WHEN 'DETAIL'. " lấy thêm thông tin của level 1 de hiển thị
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
              INNER JOIN i_hierruntimerprstnnodetext AS text_key ON ltrim( text_key~hierarchynode , '0' ) = left( gl_data~glaccount , 3 )
               AND text_key~language = 'E'
                   AND text_key~hierarchytype = 'GL05'
              WHERE  gl_data~chartofaccounts = 'YCOA'
              AND gl_data~companycode IN @lr_compnaycode
              AND gl_data~glaccount IN @lr_glaccount
              AND gl_data~glaccount NOT LIKE '00%'
                ORDER BY keysubtotal, gl_data~glaccount
                INTO TABLE @lt_glaccount
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
        "check companycode có được khai báo trong variant không
*        SELECT SINGLE 1
*        FROM zc_einv_var_i
*        WHERE zlow = @lw_companycode-low
*        AND variantname = 'BCDSPS_CO'
*        INTO @DATA(lv_check_co).
*
*        SELECT SINGLE 1
*        FROM zc_einv_var_i
*        WHERE zlow = @lw_companycode-low
*        AND variantname = 'BCDSPS_PB'
*        INTO @DATA(lv_check_pb).

*        DATA: lr_ne_journal_type TYPE if_rap_query_filter=>tt_range_option.
*        IF lv_check_co IS NOT INITIAL.
*          APPEND VALUE #( sign = 'I' option = 'EQ' low = 'CO' high = '' ) TO lr_ne_journal_type.
*        ENDIF.
*        IF lv_check_pb IS NOT INITIAL.
*          APPEND VALUE #( sign = 'I' option = 'EQ' low = 'PB' high = '' ) TO lr_ne_journal_type.
*        ENDIF.

        SELECT
         SUM( amountincompanycodecurrency ) AS amountincompanycode,
        gl_data~glaccount
         FROM i_glaccountlineitemrawdata AS gl_data
         INNER JOIN @lt_glaccount AS lt_data ON lt_data~glaccount = gl_data~glaccount
         LEFT JOIN i_journalentry AS bkpf ON bkpf~companycode = gl_data~companycode
         AND bkpf~fiscalyear = gl_data~fiscalyear
         AND bkpf~accountingdocument = gl_data~accountingdocument
         WHERE gl_data~companycode IN @lr_compnaycode
         AND gl_data~glaccount IN @lr_glaccount
         AND gl_data~fiscalyearperiod = @lv_year_period
         AND gl_data~debitcreditcode = 'S'
         AND gl_data~sourceledger = '0L'
*         AND bkpf~accountingdocumenttype NOT IN @lr_ne_journal_type
          AND GL_DATA~IsReversed IN @lr_incl_reserve
         GROUP BY gl_data~glaccount
         ORDER BY gl_data~glaccount
         INTO TABLE @DATA(lt_gl_debit_trongky).

        SELECT
            SUM( amountincompanycodecurrency ) AS amountincompanycode,
            glaccount
            FROM i_glaccountlineitemrawdata AS gl_data
            LEFT JOIN i_journalentry AS bkpf ON bkpf~companycode = gl_data~companycode
         AND bkpf~fiscalyear = gl_data~fiscalyear
         AND bkpf~accountingdocument = gl_data~accountingdocument
            WHERE gl_data~companycode IN @lr_compnaycode
            AND gl_data~glaccount IN @lr_glaccount
            AND gl_data~fiscalyearperiod = @lv_year_period
            AND gl_data~debitcreditcode = 'H'
            AND gl_data~sourceledger = '0L'
*            AND bkpf~accountingdocumenttype NOT IN @lr_ne_journal_type
            AND GL_DATA~IsReversed IN @lr_incl_reserve
            GROUP BY glaccount
            ORDER BY glaccount
            INTO TABLE @DATA(lt_gl_credit_trongky).


        SELECT
         SUM( amountincompanycodecurrency ) AS amountincompanycode,
         glaccount
         FROM i_glaccountlineitemrawdata AS gl_data
         LEFT JOIN i_journalentry AS bkpf ON bkpf~companycode = gl_data~companycode
         AND bkpf~fiscalyear = gl_data~fiscalyear
         AND bkpf~accountingdocument = gl_data~accountingdocument
         WHERE gl_data~companycode IN @lr_compnaycode
         AND gl_data~glaccount IN @lr_glaccount
         AND gl_data~fiscalyearperiod < @lv_year_period
         AND gl_data~fiscalyear = @lw_report_year-low
         AND gl_data~debitcreditcode = 'S'
         AND gl_data~sourceledger = '0L'
*         AND bkpf~accountingdocumenttype NOT IN @lr_ne_journal_type
          AND GL_DATA~IsReversed IN @lr_incl_reserve
         GROUP BY glaccount
         ORDER BY glaccount
         INTO TABLE @DATA(lt_gl_debit_before).

        SELECT
         SUM( amountincompanycodecurrency ) AS amountincompanycode,
         glaccount
         FROM i_glaccountlineitemrawdata AS gl_data
         LEFT JOIN i_journalentry AS bkpf ON bkpf~companycode = gl_data~companycode
         AND bkpf~fiscalyear = gl_data~fiscalyear
         AND bkpf~accountingdocument = gl_data~accountingdocument
         WHERE gl_data~companycode IN @lr_compnaycode
         AND gl_data~glaccount IN @lr_glaccount
         AND gl_data~fiscalyearperiod < @lv_year_period
         AND gl_data~fiscalyear = @lw_report_year-low
         AND gl_data~debitcreditcode = 'H'
         AND gl_data~sourceledger = '0L'
*         AND bkpf~accountingdocumenttype NOT IN @lr_ne_journal_type
          AND GL_DATA~IsReversed IN @lr_incl_reserve
         GROUP BY glaccount
         ORDER BY glaccount
         INTO TABLE @DATA(lt_gl_credit_before).


        DATA: lv_dauky_co_n TYPE zde_amount23.
        DATA: lv_dauky_no_n TYPE zde_amount23.
        DATA: lv_trongky_no_n TYPE zde_amount23.
        DATA: lv_trongky_co_n TYPE zde_amount23.
        DATA: lv_cuoiky_no_n TYPE zde_amount23.
        DATA: lv_cuoiky_co_n TYPE zde_amount23.

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

            ls_data-uuid = lv_uuid_fi.
            ls_data-keysubtotal = lw_acc_1-keysubtotal.
            ls_data-glaccount = lw_acc_1-glaccount.
            ls_data-account_text = lw_acc_1-account_text.
*          ls_data-dauky_no = lv_dauky_no.
*          ls_data-dauky_co = lv_dauky_co * -1.
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

            lv_dauky_co_n = ls_data-dauky_co.
            lv_dauky_no_n = ls_data-dauky_no.
            lv_trongky_no_n = ls_data-phatsinh_no.
            lv_trongky_co_n = ls_data-phatsinh_co.
            lv_cuoiky_no_n = ls_data-cuoiky_no.
            lv_cuoiky_co_n = ls_data-cuoiky_co.

            zcl_format_amount=>format_amount(
                EXPORTING
                  i_amount   = lv_dauky_co_n
                  i_currency = 'VND'
                RECEIVING
                  r_amount   = ls_data-t_dauky_co
              ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_dauky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_dauky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_co
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_co
                ).
            lv_total_dauky_co   += ls_data-dauky_co.
            lv_total_dauky_no   += ls_data-dauky_no.
            lv_total_trongky_no += ls_data-phatsinh_no.
            lv_total_trongky_co += ls_data-phatsinh_co.
            lv_total_cuoiky_no  += ls_data-cuoiky_no.
            lv_total_cuoiky_co  += ls_data-cuoiky_co.
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

            ls_data-uuid = lv_uuid_fi.
            ls_data-keysubtotal = lw_acc_1-keysubtotal.
            ls_data-glaccount = lw_acc_1-glaccount.
            ls_data-account_text = lw_acc_1-account_text.
*          ls_data-dauky_no = lv_dauky_no.
*          ls_data-dauky_co = lv_dauky_co * -1.
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

            lv_dauky_co_n = ls_data-dauky_co.
            lv_dauky_no_n = ls_data-dauky_no.
            lv_trongky_no_n = ls_data-phatsinh_no.
            lv_trongky_co_n = ls_data-phatsinh_co.
            lv_cuoiky_no_n = ls_data-cuoiky_no.
            lv_cuoiky_co_n = ls_data-cuoiky_co.

            zcl_format_amount=>format_amount(
                EXPORTING
                  i_amount   = lv_dauky_co_n
                  i_currency = 'VND'
                RECEIVING
                  r_amount   = ls_data-t_dauky_co
              ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_dauky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_dauky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_co
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_co
                ).
*            lv_total_dauky_co   += ls_data-dauky_co.
*            lv_total_dauky_no   += ls_data-dauky_no.
*            lv_total_trongky_no += ls_data-phatsinh_no.
*            lv_total_trongky_co += ls_data-phatsinh_co.
*            lv_total_cuoiky_no  += ls_data-cuoiky_no.
*            lv_total_cuoiky_co  += ls_data-cuoiky_co.
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

            ls_data-uuid = lv_uuid_fi.
            ls_data-keysubtotal = lw_acc_1-keysubtotal.
            ls_data-glaccount = lw_acc_1-glaccount.
            ls_data-account_text = lw_acc_1-account_text.
*          ls_data-dauky_no = lv_dauky_no.
*          ls_data-dauky_co = lv_dauky_co * -1.
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

            lv_dauky_co_n = ls_data-dauky_co.
            lv_dauky_no_n = ls_data-dauky_no.
            lv_trongky_no_n = ls_data-phatsinh_no.
            lv_trongky_co_n = ls_data-phatsinh_co.
            lv_cuoiky_no_n = ls_data-cuoiky_no.
            lv_cuoiky_co_n = ls_data-cuoiky_co.

            zcl_format_amount=>format_amount(
                EXPORTING
                  i_amount   = lv_dauky_co_n
                  i_currency = 'VND'
                RECEIVING
                  r_amount   = ls_data-t_dauky_co
              ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_dauky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_dauky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_trongky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_phatsinh_co
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_no_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_no
                ).

            zcl_format_amount=>format_amount(
                EXPORTING
                    i_amount   = lv_cuoiky_co_n
                    i_currency = 'VND'
                RECEIVING
                    r_amount   = ls_data-t_cuoiky_co
                ).
            ls_data-group_lv_1 = lw_acc_1-group_lv_1.
            ls_data-zlevel = 'A'.
            APPEND ls_data TO lt_data.
            CLEAR: lv_dauky_no, lv_dauky_co, lv_trongky_no, lv_trongky_co, lv_cuoiky, ls_data.
          ENDAT.
        ENDLOOP.

        SORT lt_data BY group_lv_1 group_lv_2 zlevel keysubtotal glaccount.
        "get logo
        DATA: lo_logo       TYPE REF TO zcl_get_logo_company.
        DATA: lv_logo TYPE string.
*        DATA: lv_company TYPE c LENGTH 4.
        lv_company = lw_companycode-low.
        lo_logo = NEW #( ).
        lo_logo->get_logo( EXPORTING iv_company = lv_company IMPORTING lv_logo = lv_logo ).
        IF lv_logo IS INITIAL.
          lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
        ENDIF.
        lv_xml = |<Header>|.
        lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
        lv_xml = lv_xml && |<CompanyName>{ escape( val = ls_compnay-tencty_vn format = cl_abap_format=>e_xml_text ) }</CompanyName>|.
        lv_xml = lv_xml && |<CompanyAddress>{ escape( val = ls_compnay-diachi_vn format = cl_abap_format=>e_xml_text ) }</CompanyAddress>|.
        lv_xml = lv_xml && |<CompanyTaxNumber>{ ls_compnay-mst }</CompanyTaxNumber>|.
        DATA(lv_tu_ky) = |Từ kỳ :{ lw_report_period-low }|.
        lv_xml = lv_xml && |<FromPeriod>{ lv_tu_ky }</FromPeriod>|.
        lv_xml = lv_xml && |<Data>|.
        LOOP AT lt_data INTO ls_data  .
*      READ TABLE  lt_data INTO ls_data  INDEX 1.
          lv_xml = lv_xml && |<Item>|.
          lv_xml = lv_xml && |<KeySubtotal>{ ls_data-keysubtotal }</KeySubtotal>|.
          lv_xml = lv_xml && |<GlAccount>{ ls_data-glaccount }</GlAccount>|.
          lv_xml = lv_xml && |<GlAccountName>{ escape( val = ls_data-account_text format = cl_abap_format=>e_xml_text ) }</GlAccountName>|.
          lv_xml = lv_xml && |<DauKyNo>{ ls_data-t_dauky_no }</DauKyNo>|.
          lv_xml = lv_xml && |<DauKyCo>{ ls_data-t_dauky_co }</DauKyCo>|.
          lv_xml = lv_xml && |<PhatSinhNo>{ ls_data-t_phatsinh_no }</PhatSinhNo>|.
          lv_xml = lv_xml && |<PhatSinhCo>{ ls_data-t_phatsinh_co }</PhatSinhCo>|.
          lv_xml = lv_xml && |<CuoikyNo>{ ls_data-t_cuoiky_no }</CuoikyNo>|.
          lv_xml = lv_xml && |<CuoikyCo>{ ls_data-t_cuoiky_co }</CuoikyCo>|.
          lv_xml = lv_xml && |<Zlevel>{ ls_data-zlevel }</Zlevel>|.
          lv_xml = lv_xml && |</Item>|.
        ENDLOOP.
        lv_xml = lv_xml && |</Data>|.
        lv_xml = lv_xml && |<TotalDaukyCo>{ lv_total_dauky_co }</TotalDaukyCo>|.
        lv_xml = lv_xml && |<TotalDaukyNo>{ lv_total_dauky_no }</TotalDaukyNo>|.
        lv_xml = lv_xml && |<TotalTrongkyCo>{ lv_total_trongky_co }</TotalTrongkyCo>|.
        lv_xml = lv_xml && |<TotalTrongkyNo>{ lv_total_trongky_no }</TotalTrongkyNo>|.
        lv_xml = lv_xml && |<TotalCuoikyCo>{ lv_total_cuoiky_co }</TotalCuoikyCo>|.
        lv_xml = lv_xml && |<TotalCuoikyNo>{ lv_total_cuoiky_no }</TotalCuoikyNo>|.
        lv_xml = lv_xml && |<NguoiLap>{ lw_nguoi_lap-low }</NguoiLap>|.
        lv_xml = lv_xml && |<KeToan>{ lw_ke_toan-low }</KeToan>|.
        lv_xml = lv_xml && |<GiamDoc>{ lw_giam_doc-low }</GiamDoc>|.
        lv_xml = lv_xml && |</Header>|.


        DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
        TRY.
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
      iv_service_instance_name   = 'ZADSTEMPLSTORE'
      iv_use_destination_service = abap_false
      ).

            DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZGL02' ).
            ##no_handler
          CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error_1).
            DATA(lv_err_1) = lx_error_1->get_text( ).  " Hoặc ghi log, v.v.
        ENDTRY.

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

*        ls_header-companycode = lw_companycode-low.
        ls_header-uuid = lv_uuid_fi.
*        ls_header-fiscalperiod = lw_report_period-low.
*        ls_header-fiscalyear = lw_report_year-low.
*        ls_header-attachment = lv_pdf.
*        ls_header-mimetype = 'application/pdf'.
*        ls_header-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
*        APPEND ls_header TO lt_header.
        CLEAR ls_data.

*        sort lt_data by
        zcl_format_amount=>format_amount(
            EXPORTING
              i_amount   = lv_total_dauky_co
              i_currency = 'VND'
            RECEIVING
              r_amount   = ls_data-t_dauky_co
          ).

        zcl_format_amount=>format_amount(
            EXPORTING
                i_amount   = lv_total_dauky_no
                i_currency = 'VND'
            RECEIVING
                r_amount   = ls_data-t_dauky_no
            ).

        zcl_format_amount=>format_amount(
            EXPORTING
                i_amount   = lv_total_trongky_no
                i_currency = 'VND'
            RECEIVING
                r_amount   = ls_data-t_phatsinh_no
            ).

        zcl_format_amount=>format_amount(
            EXPORTING
                i_amount   = lv_total_trongky_co
                i_currency = 'VND'
            RECEIVING
                r_amount   = ls_data-t_phatsinh_co
            ).

        zcl_format_amount=>format_amount(
            EXPORTING
                i_amount   = lv_total_cuoiky_no
                i_currency = 'VND'
            RECEIVING
                r_amount   = ls_data-t_cuoiky_no
            ).

        zcl_format_amount=>format_amount(
            EXPORTING
                i_amount   = lv_total_cuoiky_co
                i_currency = 'VND'
            RECEIVING
                r_amount   = ls_data-t_cuoiky_co
            ).
        ls_data-account_text = 'Tổng cộng'.
        ls_data-zlevel = 'D'.
        APPEND ls_data TO lt_data.
        CLEAR: ls_data.
        DATA: lt_excel TYPE gtt_excel.
        APPEND VALUE #(
        h_company_name       =   ls_compnay-tencty_vn
        h_company_add        = ls_compnay-diachi_vn
        h_company_mst        = ls_compnay-mst
        h_title_vn           = 'BẢNG CÂN ĐỐI SỐ PHÁT SINH TÀI KHOẢN'
        h_title_subtitle     = lv_tu_ky
        h_donvitinh          = 'Đơn vị tính: VND'
        i_title_taikhoan     = 'Tài khoản'
        i_title_tentaikhoan  = 'Tên tài khoản'
        i_title_dk_no        = 'Nợ'
        i_title_dk_co        = 'Có'
        i_title_ps_no      = 'Nợ'
        i_title_ps_co      = 'Có'
        i_title_ck_no      = 'Nợ'
        i_title_ck_co      = 'Có'
        i_title_dk         = 'Số dư đầu kỳ (VNĐ)'
        i_title_ps         = 'Phát sinh trong kỳ (VNĐ)'
        i_title_ck         = 'Số dư cuối kỳ (VNĐ)'
        item                 = lt_data
        f_ngaythangnam       = 'Ngày ... Tháng ... Năm ...'
        f_title_nguoilap     = 'Người lập'
        f_title_ketoantruong = 'Kế toán trưởng'
        f_title_tonggiamdoc  = 'Tổng giám đốc'
        f_nguoilap           = lw_nguoi_lap-low
        f_ketoantruong       = lw_ke_toan-low
        f_tonggiamdoc        = lw_giam_doc-low

 ) TO lt_excel.

        DATA : lv_excel    TYPE zde_attachment_tmpl,
               lv_filename TYPE string,
               lv_mimetype TYPE string.
        me->create_excel(
          EXPORTING
            i_data     =  lt_excel
          IMPORTING
            e_excel    = lv_excel
            e_filename = lv_filename
            e_mimetype = lv_mimetype
        ).


        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_print>) TO 1.
          ls_header-companycode = lv_company.
          ls_header-fiscalperiod = lr_report_period[ 1 ]-low.
          ls_header-fiscalyear = lr_report_year[ 1 ]-low.
*        IF <lfs_print>-attachment IS INITIAL.
          ls_header-attachment = lv_pdf.
          ls_header-mimetype = 'application/pdf'.
          ls_header-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
          ls_header-attachment_exc = lv_excel.
          ls_header-mimetype_exc = lv_mimetype.
          ls_header-filename_exc = lv_filename .

*        ENDIF.
        ENDLOOP.
        APPEND ls_header TO lt_header.
        DATA(lo_saver) = NEW zcl_save_pdf_zgl02( ).
        lo_saver->save_pdf(
              iv_reportid = 'ZFA_ZAA02'
              iv_objectid      = lv_uuid_fi
              iv_pdf      = lv_pdf
            ).
      ELSE.
        MOVE-CORRESPONDING lw_pdf TO ls_header.
        SELECT SINGLE
          *
          FROM zr_tbfile_export
          WHERE reportid = 'ZGL02_EXC'
          INTO @DATA(ls_excel).
        ls_header-attachment_exc = ls_excel-attachment.
        ls_header-mimetype_exc = ls_excel-mimetype.
        ls_header-filename_exc = ls_excel-filename.
        APPEND ls_header TO lt_header.
        CLEAR ls_header.
      ENDIF.
    ENDIF.
    SORT lt_data BY keysubtotal glaccount.
    io_response->set_data( lt_header ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_header ) ).
    ENDIF.
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


  METHOD create_excel.
    DATA: lo_excel    TYPE REF TO zcl_export_excel_xlsx,
          lv_report   TYPE char72 VALUE 'ZGL02',
          lv_template TYPE char72 VALUE 'ZGL02_EXC',
          lv_filename TYPE string VALUE 'ZGL02.xlsx',
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
