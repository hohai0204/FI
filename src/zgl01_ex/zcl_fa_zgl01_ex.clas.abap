CLASS zcl_fa_zgl01_ex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ZGL01_EX IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF lty_data,
             chi_tieu    TYPE string,
             ma_so       TYPE string,
             thuyet_minh TYPE string,
             so_cuoi_ki  TYPE p DECIMALS 2 LENGTH 13,
             so_dau_ki   TYPE p DECIMALS 2 LENGTH 13,
             level       TYPE string,
             style       TYPE string,
             parent_node TYPE string,
             currency    TYPE zfa_r_zgl01_ex-currency,
           END OF lty_data.
    DATA lw_data           TYPE lty_data.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lt_data           TYPE STANDARD TABLE OF lty_data.
    " TODO: variable is assigned but never used (ABAP cleaner)
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
    DATA: lt_header TYPE STANDARD TABLE OF zfa_r_zgl01.
    DATA: lw_header TYPE zfa_r_zgl01.
    DATA : lv_uuid_fi TYPE uuid.
    DATA : lv_xml TYPE string.
    DATA: lv_cuoiky_0110 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0120 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0130 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0140 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0150 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0210 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0220 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0230 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0240 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0250 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0260 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0310 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0320 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0330 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0340 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0410 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0420 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0430 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0440 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0100 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0200 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0300 TYPE p DECIMALS 2 LENGTH 13,
          lv_cuoiky_0400 TYPE p DECIMALS 2 LENGTH 13.

    DATA: lv_dauky_0110 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0120 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0130 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0140 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0150 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0210 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0220 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0230 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0240 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0250 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0260 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0310 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0320 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0330 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0340 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0410 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0420 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0430 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0440 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0100 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0200 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0300 TYPE p DECIMALS 2 LENGTH 13,
          lv_dauky_0400 TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_153_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_153_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_313_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_313_compare TYPE p DECIMALS 2 LENGTH 13.
*    DATA: lv_sum_314_report TYPE p DECIMALS 2 LENGTH 13.
*    DATA: lv_sum_314_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_319_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_319_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_314_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_314_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_411_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_411_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_421_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_421_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_440_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_440_compare TYPE p DECIMALS 2 LENGTH 13.

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
            lw_header-companycode = lw_companycode-low.
          WHEN 'KY_BAO_CAO'.
            lr_report_period = lw_filter-range.
            DATA(lw_report_period) = lr_report_period[ 1 ].
            lw_header-ky_bao_cao = lw_report_period-low.
          WHEN 'NAM_BAO_CAO'.
            lr_report_year = lw_filter-range.
            DATA(lw_report_year) = lr_report_year[ 1 ].
            lw_header-nam_bao_cao = lw_report_year-low.
          WHEN 'KY_SO_SANH'.
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
          WHEN 'KE_TOAN'.
            lr_ke_toan = lw_filter-range.
          WHEN 'GIAM_DOC'.
            lr_giam_doc = lw_filter-range.
        ENDCASE.
*        IF lw_header-companycode IS INITIAL.
*          lw_header-companycode = '1100'.
*        ENDIF.
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
        FROM ztb_zgl01_pdf
        WHERE object_id = @lw_uuid-low
        INTO TABLE @DATA(lt_pdf).
      ENDIF.

      IF lt_pdf IS INITIAL.

        TRY.
            lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
          CATCH cx_uuid_error INTO DATA(lw_error).
            DATA(lv_err_txt) = lw_error->get_text( ).  " Hoặc ghi log, v.v.

        ENDTRY.
        lw_header-uuid = lv_uuid_fi.
*        APPEND lw_header TO lt_header.
*        CLEAR : lw_header.
        IF lr_nguoi_lap IS NOT INITIAL.
          DATA(lv_nguoi_lap) = lr_nguoi_lap[ 1 ]-low.
        ENDIF.

        IF lr_giam_doc IS NOT INITIAL.
          DATA(lv_giam_doc) = lr_giam_doc[ 1 ]-low.
        ENDIF.

        IF lr_ke_toan IS NOT INITIAL.
          DATA(lv_ke_toan) = lr_ke_toan[ 1 ]-low.
        ENDIF.

        SELECT SINGLE
        tencty_vn,
        diachi_vn,
        concat_with_space( 'Mã số thuế:' , mst , 1 ) AS mst
        FROM zcds_company
        WHERE companycode EQ '1100'
        INTO @DATA(ls_company).

        TYPES : BEGIN OF ly_zfse2,
                  glaccounthierarchy TYPE string,
                  hierarchynode      TYPE string,
                  hierarchynodetext  TYPE string,
                  hierarchynodelevel TYPE string,
                  level_string       TYPE string,
                  parent_node        TYPE string,
                END OF ly_zfse2.
        DATA: lt_zfse2 TYPE STANDARD TABLE OF ly_zfse2 WITH EMPTY KEY.
        SELECT
        text~glaccounthierarchy,
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchynodelevel,
        head~parentnode AS parent_node
        FROM i_glaccounthierarchynode AS head
        INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
        AND head~hierarchynode = text~hierarchynode
        WHERE head~glaccounthierarchy = 'ZBS1'
        AND head~parentnode NOT LIKE '00%'
        AND head~hierarchynode NOT LIKE '00%'
        AND text~language = 'E'
        AND head~hierarchynode NE '0ZBS1'
        ORDER BY head~hierarchynode , head~hierarchynodelevel
        INTO CORRESPONDING FIELDS OF TABLE @lt_zfse2
         .

        SELECT
        text~glaccounthierarchy,
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchynodelevel,
        head~parentnode AS parent_node
        FROM i_glaccounthierarchynode AS head
        INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
        AND head~hierarchynode = text~hierarchynode
        WHERE head~glaccounthierarchy = 'ZBS1'
        AND head~parentnode EQ '00ASSETS'
        AND text~language = 'E'
        ORDER BY head~hierarchynode , head~hierarchynodelevel
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
         .


        SELECT
  text~glaccounthierarchy,
*case when head~hierarchynode = '00ASSETS' then '0270' else text~hierarchynode end as hierarchynode,
  text~hierarchynode,
  text~hierarchynodetext,
  head~hierarchynodelevel,
  head~parentnode AS parent_node
  FROM i_glaccounthierarchynode AS head
  INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
  AND head~hierarchynode = text~hierarchynode
  WHERE head~glaccounthierarchy = 'ZBS1'
  AND head~hierarchynode EQ '00ASSETS'
  AND text~language = 'E'
  ORDER BY head~hierarchynode , head~hierarchynodelevel
  APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
  .


        SELECT
      text~glaccounthierarchy,
      text~hierarchynode,
      text~hierarchynodetext,
      head~hierarchynodelevel,
      head~parentnode AS parent_node
      FROM i_glaccounthierarchynode AS head
      INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
      AND head~hierarchynode = text~hierarchynode
      WHERE head~glaccounthierarchy = 'ZBS1'
      AND head~parentnode EQ '00LIABILITS'
      AND text~language = 'E'
      ORDER BY head~hierarchynode , head~hierarchynodelevel
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
       .


        SELECT
  text~glaccounthierarchy,
*case when head~hierarchynode = '00ASSETS' then '0270' else text~hierarchynode end as hierarchynode,
  text~hierarchynode,
  text~hierarchynodetext,
  head~hierarchynodelevel,
  head~parentnode AS parent_node
  FROM i_glaccounthierarchynode AS head
  INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
  AND head~hierarchynode = text~hierarchynode
  WHERE head~glaccounthierarchy = 'ZBS1'
  AND head~hierarchynode EQ '00LIABILITS'
  AND text~language = 'E'
  ORDER BY head~hierarchynode , head~hierarchynodelevel
  APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2.



        SORT lt_zfse2 BY hierarchynode hierarchynodelevel.
        SELECT
            SUM( amountincompanycodecurrency ) AS balance_amount,
            zsfe2~parentnode,
            gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
            companycodecurrency AS balancetransactioncurrency
            FROM i_glaccountlineitemrawdata AS gl_data
            LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
            WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
            fiscalyearperiod <= @lv_fiscal_report
            AND sourceledger = '0L'
            AND zsfe2~glaccounthierarchy = 'ZBS1'
            AND zsfe2~parentnode NOT LIKE '00%'
            AND zsfe2~hierarchynode NOT LIKE '0%'
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
            INTO TABLE @DATA(lt_gl_report).
        SELECT
            SUM( amountincompanycodecurrency ) AS balance_amount,
            zsfe2~parentnode,
            gl_data~glaccount,
            companycodecurrency AS balancetransactioncurrency
            FROM i_glaccountlineitemrawdata AS gl_data
            LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
            WHERE
            fiscalyearperiod <= @lv_fiscal_compare
            AND sourceledger = '0L'
            AND zsfe2~glaccounthierarchy = 'ZBS1'
            AND zsfe2~parentnode NOT LIKE '00%'
            AND zsfe2~hierarchynode NOT LIKE '0%'
            AND gl_data~companycode = @lw_header-companycode
            AND gl_data~fiscalyear = @lw_header-nam_so_sanh
            GROUP BY zsfe2~parentnode,
            gl_data~glaccount,
            companycodecurrency
            ORDER BY zsfe2~parentnode
            INTO TABLE @DATA(lt_gl_compare).

        SELECT
        *
        FROM ztb_zfes2 AS zsfe2
        WHERE zsfe2~fs_version = 'ZBS1'
        ORDER BY fs_version, financial_statement
        INTO TABLE @DATA(lt_style_zsfe2).

        DATA: lv_ngay_cuoi_ki TYPE d.
        DATA: lv_ngay_dau_ki TYPE d.
        IF lw_report_period-low EQ '13'
        OR lw_report_period-low EQ '14'
        OR lw_report_period-low EQ '15'
        OR lw_report_period-low EQ '16'.

          lv_ngay_cuoi_ki = |{ lw_report_year-low }1231|.
        ELSE.
          DATA(lv_report_period) = lw_report_period-low + 1.
          IF lv_report_period < 10.
            DATA(lv_next) = |0{ lv_report_period }|.
          ENDIF.
          lv_ngay_cuoi_ki = |{ lw_report_year-low }{ lv_next }01|.
          lv_ngay_cuoi_ki = CONV d( lv_ngay_cuoi_ki - 1 ).
        ENDIF.

        IF lw_compare_period-low EQ '12'
        OR lw_compare_period-low EQ '13'
        OR lw_compare_period-low EQ '14'
        OR lw_compare_period-low EQ '15'
        OR lw_compare_period-low EQ '16'.

          DATA(lv_next_year) = lw_compare_year-low + 1.
          lv_ngay_dau_ki = |{ lv_next_year }0101|.
        ELSE.
          DATA(lv_compare_period) = lw_compare_period-low.
          lv_compare_period = lv_compare_period + 1.
          SHIFT lv_compare_period LEFT DELETING LEADING '0'.
          IF lv_compare_period < 10.
            lv_compare_period = |0{ lv_compare_period }|.
            CONDENSE lv_compare_period NO-GAPS.
          ENDIF.
          lv_ngay_dau_ki = |{ lw_compare_year-low }{ lv_compare_period }01|.
        ENDIF.

        IF lt_gl_report IS NOT INITIAL.
          DATA(lv_dvt) = lt_gl_report[ 1 ]-balancetransactioncurrency.
        ENDIF.

        LOOP AT lt_zfse2 INTO DATA(lw_zfse2) .

          IF lw_zfse2-hierarchynode = '0410'.
            DATA(lv_x) = 'X'.
          ENDIF.
          lw_data-chi_tieu = lw_zfse2-hierarchynodetext.
          lw_data-ma_so = lw_zfse2-hierarchynode.
          lw_data-thuyet_minh = ''.
          lw_data-level = lw_zfse2-hierarchynodelevel.
          lw_data-currency = 'VND'.
          SHIFT lw_data-level LEFT DELETING LEADING '0'.
          lw_data-parent_node  = lw_zfse2-parent_node.
          READ TABLE lt_gl_report INTO DATA(lw_gl_report) WITH KEY parentnode = lw_zfse2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix) = sy-tabix.
            LOOP AT lt_gl_report INTO lw_gl_report FROM lv_tabix.
              IF lw_zfse2-hierarchynode <> lw_gl_report-parentnode.
                EXIT.
              ELSE.
**              IF lw_gl_report-balancetransactioncurrency NE 'VND'.
**                lw_data-so_cuoi_ki += ( lw_gl_report-balance_amount ) * 250.
**              ELSE.
**                lw_data-so_cuoi_ki += lw_gl_report-balance_amount * 1.
**              ENDIF.
                IF ( lw_gl_report-glaccount CP '338*'
                OR lw_gl_report-glaccount CP '334*'
                OR lw_gl_report-glaccount CP '1388*'
                OR lw_gl_report-glaccount CP '1385*'
                OR lw_gl_report-glaccount CP '141*') AND lw_gl_report-parentnode = '0136'.
                  IF lw_gl_report-balance_amount > 0.
                    lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                  ELSE.
                    IF  lw_gl_report-glaccount NP '334*' .
                      lv_sum_319_report += lw_gl_report-balance_amount.
*                    ELSE.
*                      lv_sum_314_report += lw_gl_report-balance_amount.
                    ENDIF.
                  ENDIF.
                ELSE.
                  IF lw_gl_report-parentnode = '0153'.
                    IF lw_gl_report-balance_amount > 0 .
                      lv_sum_153_report += lw_gl_report-balance_amount.
                    ELSE.
                      lv_sum_313_report += lw_gl_report-balance_amount.
                    ENDIF.

                  ELSEIF lw_gl_report-parentnode = '0163' AND  lw_gl_report-glaccount CP '333*'.
                    IF lw_gl_report-balance_amount > 0.
                      lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                    ELSE.
                      lv_sum_314_report += lw_gl_report-balance_amount.
                    ENDIF.
                  ELSE.
                    lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.

          READ TABLE lt_gl_compare INTO DATA(lw_gl_compare) WITH KEY parentnode = lw_zfse2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
            LOOP AT lt_gl_compare INTO lw_gl_compare FROM lv_tabix.
              IF lw_zfse2-hierarchynode <> lw_gl_compare-parentnode.
                EXIT.
              ELSE.

                IF ( lw_gl_compare-glaccount CP '338*'
                OR lw_gl_compare-glaccount CP '1388*'
                OR lw_gl_compare-glaccount CP '1385*'
                OR lw_gl_compare-glaccount CP '334*'
                OR lw_gl_compare-glaccount CP '141*' ) AND lw_gl_compare-parentnode = '0136'.
                  IF lw_gl_compare-balance_amount > 0.
                    lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                  ELSE.
                    IF  lw_gl_compare-glaccount NP '334*' .
                      lv_sum_319_compare += lw_gl_compare-balance_amount.

                    ENDIF.
                  ENDIF.
                ELSE.
                  IF lw_gl_compare-parentnode = '0153'.
                    IF lw_gl_report-balance_amount > 0 .
                      lv_sum_153_compare += lw_gl_compare-balance_amount.
                    ELSE.
                      lv_sum_313_compare += lw_gl_compare-balance_amount.
                    ENDIF.
                  ELSEIF lw_gl_compare-parentnode = '0163' AND  lw_gl_compare-glaccount CP '333*'.
                    IF lw_gl_compare-balance_amount > 0.
                      lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                    ELSE.
                      lv_sum_314_compare += lw_gl_compare-balance_amount.
                    ENDIF..
                  ELSE.
                    lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.

          ENDIF.

          READ TABLE lt_style_zsfe2 INTO DATA(lw_style) WITH KEY fs_version = lw_zfse2-glaccounthierarchy
                                                                   financial_statement = lw_zfse2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            IF lw_style-bold EQ abap_true AND lw_style-italic NE abap_true.
              lw_data-style = 'B'.
            ELSEIF lw_style-bold NE abap_true AND lw_style-italic EQ abap_true.
              lw_data-style = 'I'.
            ELSEIF lw_style-bold EQ abap_true AND lw_style-italic EQ abap_true.
              lw_data-style = 'X'.
            ENDIF.
            lw_data-thuyet_minh = lw_style-thuyet_minh.
            IF lw_style-node_text IS NOT INITIAL.
              lw_data-chi_tieu = lw_style-node_text.
            ENDIF.
          ENDIF.

          IF lw_zfse2-hierarchynode = '0153'.
*            IF lv_sum_153_313_report > 0.
*              lw_data-so_cuoi_ki = lv_sum_153_313_report.
*            ENDIF.
*            IF lv_sum_153_313_compare > 0.
*              lw_data-so_dau_ki = lv_sum_153_313_compare.
*            ENDIF.
            lw_data-so_cuoi_ki = lv_sum_153_report.
            lw_data-so_dau_ki = lv_sum_153_compare.
          ELSEIF lw_zfse2-hierarchynode = '0313'.
*            IF lv_sum_153_313_report < 0.
*              lw_data-so_cuoi_ki = lv_sum_153_313_report.
*            ENDIF.
*            IF lv_sum_153_313_compare < 0.
*              lw_data-so_dau_ki = lv_sum_153_313_compare.
*            ENDIF.
            lw_data-so_cuoi_ki = lv_sum_313_report.
            lw_data-so_dau_ki = lv_sum_313_compare.
          ENDIF.

          IF lw_zfse2-hierarchynode = '0319'.
            lw_data-so_cuoi_ki = lv_sum_319_report.
            lw_data-so_dau_ki = lv_sum_319_compare.
          ENDIF.

          IF lw_zfse2-hierarchynode = '0314'.
            lw_data-so_cuoi_ki = lv_sum_314_report.
            lw_data-so_dau_ki = lv_sum_314_compare.
          ENDIF.


          IF lw_data-ma_so CP '03*' OR lw_data-ma_so CP '04*'.
            lw_data-so_dau_ki =  lw_data-so_dau_ki * -1.
            lw_data-so_cuoi_ki =  lw_data-so_cuoi_ki * -1.
          ENDIF.

          IF lw_zfse2-hierarchynode CP '0411*'.
            lv_sum_411_compare += lw_data-so_dau_ki.
            lv_sum_411_report += lw_data-so_cuoi_ki.
          ENDIF.
          IF lw_zfse2-hierarchynode CP '0421*'.
            lv_sum_421_compare += lw_data-so_dau_ki.
            lv_sum_421_report += lw_data-so_cuoi_ki.
          ENDIF.

          IF lw_zfse2-hierarchynode CP '011*'.
            lv_cuoiky_0110 += lw_data-so_cuoi_ki.
            lv_dauky_0110 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '012*'.
            lv_cuoiky_0120 += lw_data-so_cuoi_ki.
            lv_dauky_0120 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '013*'.
            lv_cuoiky_0130 += lw_data-so_cuoi_ki.
            lv_dauky_0130 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '014*'.
            lv_cuoiky_0140 += lw_data-so_cuoi_ki.
            lv_dauky_0140 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '015*'.
            lv_cuoiky_0150 += lw_data-so_cuoi_ki.
            lv_dauky_0150 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '021*'.
            lv_cuoiky_0210 += lw_data-so_cuoi_ki.
            lv_dauky_0210 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '022*'.
            lv_cuoiky_0220 += lw_data-so_cuoi_ki.
            lv_dauky_0220 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '023*'.
            lv_cuoiky_0230 += lw_data-so_cuoi_ki.
            lv_dauky_0230 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '024*'.
            lv_cuoiky_0240 += lw_data-so_cuoi_ki.
            lv_dauky_0240 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '025*'.
            lv_cuoiky_0250 += lw_data-so_cuoi_ki.
            lv_dauky_0250 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '026*'.
            lv_cuoiky_0260 += lw_data-so_cuoi_ki.
            lv_dauky_0260 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '031*' OR lw_zfse2-hierarchynode CP '032*'..
            lv_cuoiky_0310 += lw_data-so_cuoi_ki.
            lv_dauky_0310 += lw_data-so_dau_ki.
*        ELSEIF lw_zfse2-hierarchynode CP '032*'.
          ELSEIF lw_zfse2-hierarchynode CP '033*' OR lw_zfse2-hierarchynode CP '034*'.
            lv_cuoiky_0330 += lw_data-so_cuoi_ki.
            lv_dauky_0330 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '041*' AND ( NOT lw_zfse2-hierarchynode CP '*A' OR NOT lw_zfse2-hierarchynode CP '*B' ).
            lv_cuoiky_0410 += lw_data-so_cuoi_ki.
            lv_dauky_0410 += lw_data-so_dau_ki.
            lv_cuoiky_0400 += lw_data-so_cuoi_ki.
            lv_dauky_0400 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '042*' AND ( NOT lw_zfse2-hierarchynode CP '*A' OR NOT lw_zfse2-hierarchynode CP '*B' ).
            lv_cuoiky_0420 += lw_data-so_cuoi_ki.
            lv_dauky_0420 += lw_data-so_dau_ki.
            lv_cuoiky_0400 += lw_data-so_cuoi_ki.
            lv_dauky_0400 += lw_data-so_dau_ki.
          ELSEIF lw_zfse2-hierarchynode CP '043*'.
            lv_cuoiky_0430 += lw_data-so_cuoi_ki.
            lv_dauky_0430 += lw_data-so_dau_ki.
            lv_cuoiky_0400 += lw_data-so_cuoi_ki.
            lv_dauky_0400 += lw_data-so_dau_ki.
          ENDIF.


          DATA(lv_so_dau_ki) = lw_data-so_dau_ki.
          DATA(lv_so_cuoi_ki) = lw_data-so_cuoi_ki.
          APPEND lw_data TO lt_data.
          CLEAR : lv_so_cuoi_ki, lv_so_dau_ki, lw_data.
        ENDLOOP.

        SORT lt_data BY parent_node.
        DATA(lv_level_node) = '6'.

        WHILE ( lv_level_node <> '1' ).
          LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE level = lv_level_node.
            READ TABLE lt_data INTO DATA(lw_data_tmp) WITH KEY parent_node = <lfs_data>-ma_so BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_tabix_tmp) = sy-tabix.
              LOOP AT lt_data INTO lw_data_tmp FROM lv_tabix_tmp.
                IF lw_data_tmp-parent_node <> <lfs_data>-ma_so.
                  EXIT.
                ELSE.
                  <lfs_data>-so_cuoi_ki += lw_data_tmp-so_cuoi_ki.
                  <lfs_data>-so_dau_ki += lw_data_tmp-so_dau_ki.
                ENDIF.
              ENDLOOP.
            ENDIF.
            IF <lfs_data>-ma_so = '00ASSETS'.
              <lfs_data>-ma_so = '0280'.
              <lfs_data>-chi_tieu = <lfs_data>-chi_tieu ."&& '(280 = 100 + 200)' .
            ENDIF.
            IF <lfs_data>-ma_so = '00LIABILITS'.
              <lfs_data>-ma_so = '440'.
              <lfs_data>-chi_tieu = <lfs_data>-chi_tieu ."&& '(280 = 100 + 200)' .
            ENDIF.
          ENDLOOP.
          lv_level_node -= 1.
        ENDWHILE.

        SORT lt_data BY ma_so.
        DATA lv_line TYPE int8.
        IF lines( lt_data ) > 0.
          lv_line = lines( lt_data ).
          DATA(lt_data_tmp) = lt_data.
          FREE lt_data.
          LOOP AT lt_data_tmp INTO DATA(ls_row) FROM skip + 1 TO skip + top  . "#EC CI_NOORDER
            ls_row-ma_so = ls_row-ma_so+1(2).
            ls_row-so_cuoi_ki = ls_row-so_cuoi_ki * 100.
            ls_row-so_dau_ki = ls_row-so_dau_ki * 100 .
            APPEND ls_row TO lt_data.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
    io_response->set_data( lt_data ).
    IF lv_line IS INITIAL.
      lv_line = 1 .
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lv_line ).
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
