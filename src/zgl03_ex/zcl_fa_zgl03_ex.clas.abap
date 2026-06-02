CLASS zcl_fa_zgl03_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
*    INTERFACES if_rap_query_request .
    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ZGL03_EX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TYPES: BEGIN OF lty_data,
             chi_tieu       TYPE string,
             ma_so          TYPE string,
             thuyet_minh    TYPE string,
             ky_bao_cao     TYPE p LENGTH 15 DECIMALS 2,
             ky_so_sanh     TYPE p LENGTH 15 DECIMALS 2,
             luy_ke_so_sanh TYPE p LENGTH 15 DECIMALS 2,
             luy_ke_bao_cao TYPE p LENGTH 15 DECIMALS 2,
             style          TYPE string,
             level_node     TYPE string,
             parent_node    TYPE string,
             currency       TYPE zfa_r_zgl03_ex-currency,
           END OF lty_data.


    DATA : lt_header TYPE TABLE OF zfa_r_zgl03.
    DATA : lw_header TYPE zfa_r_zgl03.
    DATA: lt_data TYPE TABLE OF lty_data.
    DATA : lw_data TYPE lty_data.
    DATA lr_compnaycode    TYPE if_rap_query_filter=>tt_range_option.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_report_year    TYPE if_rap_query_filter=>tt_range_option.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_report_period  TYPE if_rap_query_filter=>tt_range_option.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_compare_year   TYPE if_rap_query_filter=>tt_range_option.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lr_compare_period TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_uuid TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
    DATA lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
    DATA: lv_xml TYPE string.
    DATA: lv_uuid_fi TYPE uuid.

    DATA : lv_report_total TYPE p DECIMALS 2 LENGTH 15.
    DATA : lv_compare_total TYPE p DECIMALS 2 LENGTH 15.
    DATA : lv_report_total_luy_ke TYPE p DECIMALS 2 LENGTH 15.
    DATA : lv_compare_total_luy_ke TYPE p DECIMALS 2 LENGTH 15.
    DATA: lv_bao_cao_031 TYPE p DECIMALS 2 LENGTH 15.
    DATA: lv_so_sanh_031 TYPE p DECIMALS 2 LENGTH 15.
    DATA: lv_bao_cao_031_luyke TYPE p DECIMALS 2 LENGTH 15.
    DATA: lv_so_sanh_031_luyke TYPE p DECIMALS 2 LENGTH 15.
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
            IF lr_compnaycode IS NOT INITIAL.
              DATA(lw_companycode) = lr_compnaycode[ 1 ].
              lw_header-companycode = lw_companycode-low.
            ENDIF.
          WHEN 'KY_BAO_CAO_T'.
            lr_report_period = lw_filter-range.
            DATA(lw_report_period) = lr_report_period[ 1 ].
            lw_header-ky_bao_cao = lw_report_period-low.
          WHEN 'NAM_BAO_CAO'.
            lr_report_year = lw_filter-range.
            DATA(lw_report_year) = lr_report_year[ 1 ].
            lw_header-nam_bao_cao = lw_report_year-low.
          WHEN 'KY_SO_SANH_T'.
            lr_compare_period = lw_filter-range.
            DATA(lw_compare_period) = lr_compare_period[ 1 ].
            lw_header-ky_so_sanh = lw_compare_period-low.
          WHEN 'NAM_SO_SANH'.
            lr_compare_year = lw_filter-range.
            DATA(lw_compare_year) = lr_compare_year[ 1 ].
            lw_header-nam_so_sanh = lw_compare_year-low.
          WHEN 'UUID'.
            lr_uuid = lw_filter-range.
            DATA(lw_uuid) = lr_uuid[ 1 ].
          WHEN 'NGUOI_LAP'.
            lr_nguoi_lap = lw_filter-range.
            IF lr_nguoi_lap IS NOT INITIAL.
              DATA(lw_nguoi_lap) = lr_nguoi_lap[ 1 ].
            ENDIF.
          WHEN 'KE_TOAN'.
            lr_ke_toan = lw_filter-range.
            IF lr_ke_toan IS NOT INITIAL.
              DATA(lw_ke_toan) = lr_ke_toan[ 1 ].
            ENDIF.
          WHEN 'GIAM_DOC'.
            lr_giam_doc = lw_filter-range.
            IF lr_giam_doc IS NOT INITIAL.
              DATA(lw_giam_doc) = lr_giam_doc[ 1 ].
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    DATA: lv_allow TYPE abap_boolean.
    me->authorization(
      EXPORTING
        i_company = lw_header-companycode
      IMPORTING
        e_allow   = lv_allow
    ).
    IF lv_allow IS NOT INITIAL.
      DATA(lv_period_report) = lw_report_period-low.
      SHIFT lv_period_report LEFT DELETING LEADING '0'.
      IF lv_period_report < 10.
        DATA(lv_fiscal_report) = |{ lw_report_year-low }00{ lv_period_report }|.
      ELSE.
        lv_fiscal_report = |{ lw_report_year-low }0{ lv_period_report }|.
      ENDIF.

      DATA(lv_period_compare) = lw_compare_period-low.
      SHIFT lv_period_compare LEFT DELETING LEADING '0'.
      IF lv_period_compare < 10.
        DATA(lv_fiscal_compare) = |{ lw_compare_year-low }00{ lv_period_compare }|.
      ELSE.
        lv_fiscal_compare = |{ lw_compare_year-low }0{ lv_period_compare }|.
      ENDIF.
      IF lr_uuid IS NOT INITIAL.

        SELECT
        *
        FROM ztb_zgl03_pdf
        WHERE object_id = @lw_uuid-low
        INTO TABLE @DATA(lt_pdf).
      ENDIF.

      IF lt_pdf IS INITIAL.
        TRY.
            lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
          CATCH cx_uuid_error INTO DATA(lw_error).
            DATA(lv_err_text) = lw_error->get_text( ).  " Hoặc ghi log, v.v.
        ENDTRY.
        lw_header-companycode = lw_companycode-low.
*        IF lw_header-companycode IS INITIAL.
*          lw_header-companycode = '1100'.
*        ENDIF.
        lw_header-ky_bao_cao = lw_report_period-low.
        lw_header-nam_bao_cao = lw_report_year-low.
        lw_header-ky_so_sanh = lw_compare_period-low.
        lw_header-nam_so_sanh = lw_compare_year-low.
        lw_header-uuid = lv_uuid_fi.
        APPEND lw_header TO lt_header.
        SELECT
          text~financialstatementhierarchy,
          text~hierarchynode,
          text~hierarchynodetext,
          head~hierarchynodelevel,
          head~parentnode
*        zfes2~thuyet_minh,
*        CASE WHEN zfes2~bold = 'X' AND zfes2~italic IS INITIAL THEN 'B'
*            WHEN zfes2~bold IS INITIAL AND zfes2~italic = 'X' THEN 'I'
*            WHEN zfes2~bold = 'X' AND zfes2~italic = 'X' THEN 'X'
*            ELSE ' ' END AS style
          FROM i_financialstatementhiernodet AS  text
          INNER JOIN i_glaccounthierarchynode AS head ON head~glaccounthierarchy = text~financialstatementhierarchy
*        LEFT JOIN ztb_zfes2 AS zfes2 ON head~glaccounthierarchy = zfes2~fs_version
*                                    AND head~hierarchynode = zfes2~financial_statement
          AND head~hierarchynode = text~hierarchynode
          WHERE head~glaccounthierarchy = 'ZIS1'
         AND length( text~hierarchynode ) < 6
          AND text~hierarchynode <> '0ZIS1'
          ORDER BY head~hierarchynode , head~hierarchynodelevel
          INTO TABLE @DATA(lt_zfes2)
       .

        SELECT
        SUM( amountincompanycodecurrency ) AS amount,
        gl_data~glaccount,
        zsfe2~parentnode,
         companycodecurrency AS balancetransactioncurrency
          FROM i_glaccountlineitemrawdata AS gl_data
          LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
          WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
          fiscalyearperiod = @lv_fiscal_report
          AND sourceledger = '0L'
          AND zsfe2~glaccounthierarchy = 'ZIS1'
          AND length( zsfe2~parentnode ) < 6
          AND zsfe2~parentnode <> '0ZIS1'
          AND gl_data~companycode = @lw_header-companycode

*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
          GROUP BY zsfe2~parentnode,
          gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
          companycodecurrency
          ORDER BY zsfe2~parentnode
          INTO TABLE @DATA(lt_gl_ky_report).

*        SELECT
*    amountincompanycodecurrency ,
*    gl_data~glaccount,
*    zsfe2~parentnode,
*     companycodecurrency AS balancetransactioncurrency
*      FROM i_glaccountlineitemrawdata AS gl_data
*      LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
*      WHERE
**          fiscalperiod IN @lr_report_period
**          AND fiscalyear IN @lr_report_year
*      fiscalyearperiod = @lv_fiscal_report
*      AND sourceledger = '0L'
*      AND zsfe2~glaccounthierarchy = 'ZIS1'
*      AND length( zsfe2~parentnode ) = 3
*      AND zsfe2~parentnode = '001'
**          and gl_data~FinancialAccountType = 'K'
**          AND gl_data~glaccount NOT LIKE '3%1'
**        GROUP BY zsfe2~parentnode,
**        gl_data~glaccount,
***          fiscalperiod,
***          fiscalyear,
**        companycodecurrency
*      ORDER BY zsfe2~parentnode
*      INTO TABLE @DATA(lt_check).

        SELECT
    SUM( amountincompanycodecurrency ) AS amount,
    gl_data~glaccount,
    zsfe2~parentnode,
     companycodecurrency AS balancetransactioncurrency
      FROM i_glaccountlineitemrawdata AS gl_data
      LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
      WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
      fiscalyearperiod <= @lv_fiscal_report
      AND sourceledger = '0L'
      AND zsfe2~glaccounthierarchy = 'ZIS1'
*      AND length( zsfe2~parentnode ) = 3
          AND length( zsfe2~parentnode ) < 6
          AND zsfe2~parentnode <> '0ZIS1'
      AND gl_data~companycode = @lw_header-companycode
      AND gl_data~fiscalyear = @lw_header-nam_bao_cao
*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
      GROUP BY zsfe2~parentnode,
      gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
      companycodecurrency
      ORDER BY zsfe2~parentnode
      INTO TABLE @DATA(lt_gl_luyke_report).


        SELECT
    SUM( amountincompanycodecurrency ) AS amount,
    gl_data~glaccount,
    zsfe2~parentnode,
     companycodecurrency AS balancetransactioncurrency
      FROM i_glaccountlineitemrawdata AS gl_data
      LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
      WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
      fiscalyearperiod = @lv_fiscal_compare
      AND sourceledger = '0L'
      AND zsfe2~glaccounthierarchy = 'ZIS1'
*      AND length( zsfe2~parentnode ) = 3
          AND length( zsfe2~parentnode ) < 6
          AND zsfe2~parentnode <> '0ZIS1'
            AND gl_data~companycode = @lw_header-companycode
*      and gl_data~FiscalYear = @lw_header-nam_bao_cao
*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
      GROUP BY zsfe2~parentnode,
      gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
      companycodecurrency
      ORDER BY zsfe2~parentnode
      INTO TABLE @DATA(lt_gl_ky_compare).

        SELECT
    SUM( amountincompanycodecurrency ) AS amount,
    gl_data~glaccount,
    zsfe2~parentnode,
     companycodecurrency AS balancetransactioncurrency
      FROM i_glaccountlineitemrawdata AS gl_data
      LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
      WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
      fiscalyearperiod <= @lv_fiscal_compare
      AND sourceledger = '0L'
      AND zsfe2~glaccounthierarchy = 'ZIS1'
*      AND length( zsfe2~parentnode ) = 3
          AND length( zsfe2~parentnode ) < 6
          AND zsfe2~parentnode <> '0ZIS1'
            AND gl_data~companycode = @lw_header-companycode
      AND gl_data~fiscalyear = @lw_header-nam_so_sanh
*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
      GROUP BY zsfe2~parentnode,
      gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
      companycodecurrency
      ORDER BY zsfe2~parentnode
      INTO TABLE @DATA(lt_gl_luyke_compare).

        SELECT
            fs_version,
            financial_statement,
          CASE WHEN zfes2~bold = 'X' AND zfes2~italic IS INITIAL THEN 'B'
              WHEN zfes2~bold IS INITIAL AND zfes2~italic = 'X' THEN 'I'
              WHEN zfes2~bold = 'X' AND zfes2~italic = 'X' THEN 'X'
              ELSE ' ' END AS style,
        thuyet_minh,
        node_text
               FROM ztb_zfes2 AS zfes2
               WHERE fs_version = 'ZIS1'
               ORDER BY  fs_version,
            financial_statement
               INTO TABLE @DATA(lt_thuyetminh).

        LOOP AT lt_zfes2 INTO DATA(lw_zfes2).
          lw_data-chi_tieu = lw_zfes2-hierarchynodetext.
          lw_data-ma_so = lw_zfes2-hierarchynode.
          lw_data-currency = 'VND'.
*          CASE lw_data-ma_so.
*            WHEN '010'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 10 = 01 - 02 )'.
*
*            WHEN '020'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 20 = 10 - 11 )'.
*
*            WHEN '030'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' { 30 = 20 + ( 21 - 22 ) - ( 23 + 25 + 26 ) }'.
*
*            WHEN '040'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 40 = 31 + 32 )'.
*            WHEN '050'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 50 = 30 + 40 )'.
*            WHEN '060'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 60 = 50 - 51 - 52 )'.
*          ENDCASE.
          lw_data-level_node = lw_zfes2-hierarchynodelevel.
          lw_data-parent_node = lw_zfes2-parentnode.
          SHIFT lw_data-level_node LEFT DELETING LEADING '0'.
          READ TABLE lt_thuyetminh INTO DATA(lw_thuyeminh) WITH KEY fs_version = lw_zfes2-financialstatementhierarchy
                                                                    financial_statement = lw_zfes2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0 .
            lw_data-thuyet_minh = lw_thuyeminh-thuyet_minh.
            lw_data-style = lw_thuyeminh-style.
            IF lw_thuyeminh-node_text IS NOT INITIAL.
              lw_data-chi_tieu = lw_thuyeminh-node_text.
            ENDIF.
          ENDIF.
          "giá trị ky bao cao
          READ TABLE lt_gl_ky_report INTO DATA(ls_gl_ky_report) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix_1) = sy-tabix.
            LOOP AT lt_gl_ky_report INTO ls_gl_ky_report FROM lv_tabix_1.
              IF ls_gl_ky_report-parentnode <> lw_zfes2-hierarchynode.
                EXIT.
              ELSE.
                lw_data-ky_bao_cao += ls_gl_ky_report-amount.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "giá trị luy ke ky bao cao
          READ TABLE lt_gl_luyke_report INTO DATA(ls_gl_luyke_report) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix_2) = sy-tabix.
            LOOP AT lt_gl_luyke_report INTO ls_gl_luyke_report FROM lv_tabix_2.
              IF ls_gl_luyke_report-parentnode <> lw_zfes2-hierarchynode.
                EXIT.
              ELSE.

                lw_data-luy_ke_bao_cao += ls_gl_luyke_report-amount.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "giá trị ky so sanh
          READ TABLE lt_gl_ky_compare INTO DATA(ls_gl_ky_compare) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix_3) = sy-tabix.
            LOOP AT lt_gl_ky_compare INTO ls_gl_ky_compare FROM lv_tabix_3.
              IF ls_gl_ky_compare-parentnode <> lw_zfes2-hierarchynode.
                EXIT.
              ELSE.
                lw_data-ky_so_sanh += ls_gl_ky_compare-amount.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "giá trị luy ke so sánh
          READ TABLE lt_gl_luyke_compare INTO DATA(ls_gl_luyke_compare) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix_4) = sy-tabix.
            LOOP AT lt_gl_luyke_compare INTO ls_gl_luyke_compare FROM lv_tabix_4.
              IF ls_gl_luyke_compare-parentnode <> lw_zfes2-hierarchynode.
                EXIT.
              ELSE.
                lw_data-luy_ke_so_sanh += ls_gl_luyke_compare-amount.
              ENDIF.
            ENDLOOP.
          ENDIF.
          IF lw_data-ma_so = '001'.
            lw_data-ky_bao_cao = lw_data-ky_bao_cao * -1.
            lw_data-ky_so_sanh = lw_data-ky_so_sanh * -1.
            lw_data-luy_ke_bao_cao = lw_data-luy_ke_bao_cao * -1.
            lw_data-luy_ke_so_sanh = lw_data-luy_ke_so_sanh * -1.
          ENDIF.
          APPEND lw_data TO lt_data.
          CLEAR: lw_data.
        ENDLOOP.
        DATA(lt_zfes2_tmp) = lt_data.
        DELETE lt_zfes2_tmp WHERE level_node <> '8'.
        SORT lt_data BY parent_node.
        DATA(lv_level_node) = '7'.

        WHILE ( lv_level_node <> '1' ).
          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE level_node = lv_level_node.
*        IF <lfs_data>-ma_so = '010'.
            READ TABLE lt_data INTO DATA(lw_zfes2_tmp) WITH KEY parent_node = <lfs_data>-ma_so BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_tabix) = sy-tabix.
              LOOP AT lt_data INTO lw_zfes2_tmp FROM lv_tabix.
                IF lw_zfes2_tmp-parent_node = <lfs_data>-ma_so.
                  IF ( lw_zfes2_tmp-parent_node = '010' AND lw_zfes2_tmp-ma_so = '001' )
                  OR ( lw_zfes2_tmp-parent_node = '020' AND lw_zfes2_tmp-ma_so = '010' )
                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '020' )
                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '021' )
                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '022' )
                 OR ( lw_zfes2_tmp-parent_node = '040' AND lw_zfes2_tmp-ma_so = '032' )
*                OR ( lw_zfes2_tmp-parent_node = '040' AND lw_zfes2_tmp-ma_so = '031' )
                  OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '030' )
*                OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '040' )
                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '050' )
                  OR ( lw_zfes2_tmp-parent_node = '023' AND lw_zfes2_tmp-ma_so = '024.5' )
                  OR ( lw_zfes2_tmp-parent_node = '023' AND lw_zfes2_tmp-ma_so = '024' )
                  OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '040' )
                  .

                    <lfs_data>-ky_bao_cao += lw_zfes2_tmp-ky_bao_cao.
                    <lfs_data>-ky_so_sanh += lw_zfes2_tmp-ky_so_sanh.
                    <lfs_data>-luy_ke_bao_cao += lw_zfes2_tmp-luy_ke_bao_cao.
                    <lfs_data>-luy_ke_so_sanh += lw_zfes2_tmp-luy_ke_so_sanh.
                  ELSEIF ( lw_zfes2_tmp-parent_node = '010' AND lw_zfes2_tmp-ma_so = '002' )
                  OR ( lw_zfes2_tmp-parent_node = '020' AND lw_zfes2_tmp-ma_so = '011' )

                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '023' )
                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '025' )
                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '026' )

                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '051' )
                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '052' )


                  .
                    <lfs_data>-ky_bao_cao -= lw_zfes2_tmp-ky_bao_cao.
                    <lfs_data>-ky_so_sanh -= lw_zfes2_tmp-ky_so_sanh.
                    <lfs_data>-luy_ke_bao_cao -= lw_zfes2_tmp-luy_ke_bao_cao.
                    <lfs_data>-luy_ke_so_sanh -= lw_zfes2_tmp-luy_ke_so_sanh.
                  ELSEIF <lfs_data>-ma_so = '022'.
                    <lfs_data>-ky_bao_cao += lw_zfes2_tmp-ky_bao_cao.
                    <lfs_data>-ky_so_sanh += lw_zfes2_tmp-ky_so_sanh.
                    <lfs_data>-luy_ke_bao_cao += lw_zfes2_tmp-luy_ke_bao_cao.
                    <lfs_data>-luy_ke_so_sanh += lw_zfes2_tmp-luy_ke_so_sanh.
                  ELSEIF lw_zfes2_tmp-parent_node = '040' AND lw_zfes2_tmp-ma_so = '031' .
                    <lfs_data>-ky_bao_cao += lv_bao_cao_031.
                    <lfs_data>-ky_so_sanh += lv_so_sanh_031.
                    <lfs_data>-luy_ke_bao_cao += lv_bao_cao_031_luyke.
                    <lfs_data>-luy_ke_so_sanh += lv_so_sanh_031_luyke.
*                elseif ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '021' ).
*                    <lfs_data>-ky_bao_cao += lw_zfes2_tmp-ky_bao_cao * -1.
*                  <lfs_data>-ky_so_sanh += lw_zfes2_tmp-ky_so_sanh * -1.
*                  <lfs_data>-luy_ke_bao_cao += lw_zfes2_tmp-luy_ke_bao_cao * -1.
*                  <lfs_data>-luy_ke_so_sanh += lw_zfes2_tmp-luy_ke_so_sanh * -1.
                  ENDIF.
                ELSE.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
*        ENDIF.
            IF <lfs_data>-ma_so = '060'
            OR <lfs_data>-ma_so = '070'
            OR <lfs_data>-ma_so = '080'.
              lv_report_total += <lfs_data>-ky_bao_cao.
              lv_compare_total += <lfs_data>-ky_so_sanh.
              lv_report_total_luy_ke += <lfs_data>-luy_ke_bao_cao.
              lv_compare_total_luy_ke += <lfs_data>-luy_ke_so_sanh.
            ENDIF.
            IF <lfs_data>-ma_so = '090'.
              <lfs_data>-ky_bao_cao = lv_report_total.
              <lfs_data>-ky_so_sanh = lv_compare_total.
              <lfs_data>-luy_ke_bao_cao = lv_report_total_luy_ke.
              <lfs_data>-luy_ke_so_sanh = lv_compare_total_luy_ke.
            ENDIF.
            IF <lfs_data>-ma_so = '031' .
              lv_bao_cao_031 = <lfs_data>-ky_bao_cao .
              lv_so_sanh_031 = <lfs_data>-ky_so_sanh .
              lv_bao_cao_031_luyke = <lfs_data>-luy_ke_bao_cao .
              lv_so_sanh_031_luyke = <lfs_data>-luy_ke_so_sanh .
              <lfs_data>-ky_bao_cao = <lfs_data>-ky_bao_cao * -1.
              <lfs_data>-ky_so_sanh = <lfs_data>-ky_so_sanh * -1.
              <lfs_data>-luy_ke_bao_cao = <lfs_data>-luy_ke_bao_cao * -1.
              <lfs_data>-luy_ke_so_sanh = <lfs_data>-luy_ke_so_sanh * -1.

            ELSEIF <lfs_data>-ma_so = '021' .
              <lfs_data>-ky_bao_cao = <lfs_data>-ky_bao_cao * -1.
              <lfs_data>-ky_so_sanh = <lfs_data>-ky_so_sanh * -1.
              <lfs_data>-luy_ke_bao_cao = <lfs_data>-luy_ke_bao_cao * -1.
              <lfs_data>-luy_ke_so_sanh = <lfs_data>-luy_ke_so_sanh * -1.
            ELSEIF <lfs_data>-ma_so = '022' .
              <lfs_data>-ky_bao_cao = <lfs_data>-ky_bao_cao * -1.
              <lfs_data>-ky_so_sanh = <lfs_data>-ky_so_sanh * -1.
              <lfs_data>-luy_ke_bao_cao = <lfs_data>-luy_ke_bao_cao * -1.
              <lfs_data>-luy_ke_so_sanh = <lfs_data>-luy_ke_so_sanh * -1.
            ENDIF.
            IF <lfs_data>-ma_so = '040' .
              <lfs_data>-ky_bao_cao = <lfs_data>-ky_bao_cao * -1.
              <lfs_data>-ky_so_sanh = <lfs_data>-ky_so_sanh * -1.
              <lfs_data>-luy_ke_bao_cao = <lfs_data>-luy_ke_bao_cao * -1.
              <lfs_data>-luy_ke_so_sanh = <lfs_data>-luy_ke_so_sanh * -1.
            ENDIF.

          ENDLOOP.
          lv_level_node -= 1.
        ENDWHILE.

        SELECT SINGLE
        tencty_vn,
        diachi_vn,
        concat_with_space( 'Mã số thuế:' , mst , 1  ) AS mst
        FROM zcds_company
        WHERE companycode = @lw_header-companycode
        INTO @DATA(ls_company).


        SHIFT lv_period_report LEFT DELETING LEADING '0'.
        DATA(lv_subtitle) = |Tháng{ lv_period_report } năm{ lw_report_year-low }|.
        DATA(lv_ky_bao_cao) = |{ lv_period_report }/{ lw_report_year-low }|.
        DATA(lv_ky_so_sanh) = |{ lv_period_compare }/{ lw_compare_year-low }|.
      ENDIF.
      DATA : lv_lines TYPE int8.
      SORT lt_data BY ma_so.
      DELETE lt_data WHERE ma_so = '024.5'.
      lv_lines = lines( lt_data ).
      IF lines( lt_data ) > 0.
        DATA(lt_data_tmp) = lt_data.
        FREE lt_data.
        LOOP AT lt_data_tmp INTO DATA(ls_row) FROM skip + 1 TO skip + top  . "#EC CI_NOORDER
          ls_row-ma_so = ls_row-ma_so+1(2).

          ls_row-ky_bao_cao = ls_row-ky_bao_cao * 100.
          ls_row-ky_so_sanh = ls_row-ky_so_sanh * 100.
          ls_row-luy_ke_bao_cao = ls_row-luy_ke_bao_cao * 100.
          ls_row-luy_ke_so_sanh = ls_row-luy_ke_so_sanh * 100.
          APPEND ls_row TO lt_data.
        ENDLOOP.
      ENDIF.
    ENDIF.
    io_response->set_data( lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lv_lines ).
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
ENDCLASS.
