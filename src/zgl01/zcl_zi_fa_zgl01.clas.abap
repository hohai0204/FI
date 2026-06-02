CLASS zcl_zi_fa_zgl01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF gty_data,
             chi_tieu    TYPE string,
             ma_so       TYPE string,
             thuyet_minh TYPE string,
             so_cuoi_ki   TYPE zde_amount23,
             so_dau_ki    TYPE zde_amount23,
             t_so_cuoi_ki TYPE string,
             t_so_dau_ki  TYPE string,
             level       TYPE string,
             style       TYPE string,
             parent_node TYPE string,
             zlevel      TYPE string,
           END OF gty_data,
           gtt_data TYPE STANDARD TABLE OF gty_data WITH EMPTY KEY.
    "excel
    TYPES: BEGIN OF gty_excel,
             h_company_name       TYPE string,
             h_company_add        TYPE string,
             h_company_mst        TYPE string,
             h_title_vn           TYPE string,
             h_title_en           TYPE string,
             h_title_subtitle     TYPE string,
             h_donvitinh          TYPE string,
             h_title_mauso_1      TYPE string,
             h_title_mauso_2      TYPE string,
             h_title_mauso_3      TYPE string,
             i_title_chitieu      TYPE string,
             i_title_maso         TYPE string,
             i_title_thuyetminh   TYPE string,
             i_title_socuoiky     TYPE string,
             i_title_sodauky      TYPE string,
             item                 TYPE gtt_data,
             f_ngaythangnam       TYPE string,
             f_title_nguoilap     TYPE string,
             f_title_ketoantruong TYPE string,
             f_title_tonggiamdoc  TYPE string,
             f_nguoilap           TYPE string,
             f_ketoantruong       TYPE string,
             f_tonggiamdoc        TYPE string,
           END OF gty_excel,
           tt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.
    INTERFACES if_rap_query_provider .
*    INTERFACES if_rap_query_request .

    METHODS convert_date
      IMPORTING i_date      TYPE d
      EXPORTING e_text_date TYPE string.

    METHODS create_excel
      IMPORTING i_data     TYPE tt_excel
      EXPORTING e_excel    TYPE zde_attachment_tmpl
                e_filename TYPE string
                e_mimetype TYPE string
      .

    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZI_FA_ZGL01 IMPLEMENTATION.


  METHOD convert_date.
    e_text_date = |{ i_date+6(2) }.{ i_date+4(2) }.{ i_date+0(4) }|.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF lty_data,
             chi_tieu     TYPE string,
             ma_so        TYPE string,
             thuyet_minh  TYPE string,
             so_cuoi_ki   TYPE zde_amount23,
             so_dau_ki    TYPE zde_amount23,
             t_so_cuoi_ki TYPE string,
             t_so_dau_ki  TYPE string,
             level        TYPE string,
             style        TYPE string,
             parent_node  TYPE string,
             zlevel       TYPE string,
           END OF lty_data,
           tt_data TYPE STANDARD TABLE OF lty_data WITH EMPTY KEY.
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
*    DATA: lv_sum_153_313_report TYPE p DECIMALS 2 LENGTH 13.
*    DATA: lv_sum_153_313_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_153_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_153_compare TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_313_report TYPE p DECIMALS 2 LENGTH 13.
    DATA: lv_sum_313_compare TYPE p DECIMALS 2 LENGTH 13.
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
        APPEND lw_header TO lt_header.
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
        diachi_vn23 AS diachi_vn,
        concat_with_space( 'Mã số thuế:' , mst , 1 ) AS mst
        FROM zcds_company
        WHERE companycode EQ @lw_header-companycode
        INTO @DATA(ls_company).

        TYPES : BEGIN OF ly_zfse2,
                  glaccounthierarchy TYPE string,
                  hierarchynode      TYPE string,
                  hierarchynodetext  TYPE string,
                  hierarchynodelevel TYPE string,
                  level_string       TYPE string,
                  parent_node        TYPE string,
                  debitcreditcode    TYPE string,
                END OF ly_zfse2.
        DATA: lt_zfse2 TYPE STANDARD TABLE OF ly_zfse2 WITH EMPTY KEY.

        SELECT
*        text~HierarchyNode,
         text~hierarchynode,
         text~hierarchynodetext,
         head~hierarchylevel AS hierarchynodelevel,
         head~parentnode AS parent_node
         FROM i_financialstatementhiernode AS head
         INNER JOIN i_financialstatementhiernodet AS text ON head~financialstatementhierarchy = text~financialstatementhierarchy
         AND head~hierarchynode = text~hierarchynode
         WHERE head~financialstatementhierarchy = 'ZBS1'
         AND head~parentnode NOT LIKE '00%'
         AND head~hierarchynode NOT LIKE '00%'
         AND text~language = 'E'
         AND head~hierarchynode NE '0ZBS1'
         ORDER BY head~hierarchynode , head~hierarchylevel
         INTO CORRESPONDING FIELDS OF TABLE @lt_zfse2
          .

        SELECT
*        text~glaccounthierarchy,
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchylevel AS hierarchynodelevel,
        head~parentnode AS parent_node
*        FROM i_glaccounthierarchynode AS head
*        INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
*        AND head~hierarchynode = text~hierarchynode
        FROM i_financialstatementhiernode AS head
        INNER JOIN i_financialstatementhiernodet AS text ON head~financialstatementhierarchy = text~financialstatementhierarchy
        AND head~hierarchynode = text~hierarchynode
*        leFT jOIN I_UniversalHierNodeText as extra_text on left( extra_text~UniversalHierNodeLowValueTxt , 50 ) = left( text~hierarchynodetext , 50 )
        WHERE head~financialstatementhierarchy = 'ZBS1'
        AND head~parentnode EQ '00ASSETS'
        AND text~language = 'E'
        ORDER BY head~hierarchynode , head~hierarchylevel
        APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
         .


        SELECT
*  text~glaccounthierarchy,
**case when head~hierarchynode = '00ASSETS' then '0270' else text~hierarchynode end as hierarchynode,
*  text~hierarchynode,
*  text~hierarchynodetext,
*  head~hierarchynodelevel,
*  head~parentnode AS parent_node
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchylevel AS hierarchynodelevel,
        head~parentnode AS parent_node
*  FROM i_glaccounthierarchynode AS head
*  INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
*  AND head~hierarchynode = text~hierarchynode
  FROM i_financialstatementhiernode AS head
        INNER JOIN i_financialstatementhiernodet AS text ON head~financialstatementhierarchy = text~financialstatementhierarchy
        AND head~hierarchynode = text~hierarchynode
  WHERE head~financialstatementhierarchy = 'ZBS1'
  AND head~hierarchynode EQ '00ASSETS'
  AND text~language = 'E'
  ORDER BY head~hierarchynode , head~hierarchylevel
  APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
  .


        SELECT
*      text~glaccounthierarchy,
*      text~hierarchynode,
*      text~hierarchynodetext,
*      head~hierarchynodelevel,
*      head~parentnode AS parent_node
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchylevel AS hierarchynodelevel,
        head~parentnode AS parent_node
*      FROM i_glaccounthierarchynode AS head
*      INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
*      AND head~hierarchynode = text~hierarchynode
        FROM i_financialstatementhiernode AS head
        INNER JOIN i_financialstatementhiernodet AS text ON head~financialstatementhierarchy = text~financialstatementhierarchy
        AND head~hierarchynode = text~hierarchynode
      WHERE head~financialstatementhierarchy = 'ZBS1'
      AND head~parentnode EQ '00LIABILITS'
      AND text~language = 'E'
      ORDER BY head~hierarchynode , head~hierarchylevel
      APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2
       .


        SELECT
*  text~glaccounthierarchy,
**case when head~hierarchynode = '00ASSETS' then '0270' else text~hierarchynode end as hierarchynode,
*  text~hierarchynode,
*  text~hierarchynodetext,
*  head~hierarchynodelevel,
*  head~parentnode AS parent_node
        text~hierarchynode,
        text~hierarchynodetext,
        head~hierarchylevel AS hierarchynodelevel,
        head~parentnode AS parent_node
*  FROM i_glaccounthierarchynode AS head
*  INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
*  AND head~hierarchynode = text~hierarchynode
  FROM i_financialstatementhiernode AS head
        INNER JOIN i_financialstatementhiernodet AS text ON head~financialstatementhierarchy = text~financialstatementhierarchy
        AND head~hierarchynode = text~hierarchynode
  WHERE head~financialstatementhierarchy = 'ZBS1'
  AND head~hierarchynode EQ '00LIABILITS'
  AND text~language = 'E'
  ORDER BY head~hierarchynode , head~hierarchylevel
  APPENDING CORRESPONDING FIELDS OF TABLE @lt_zfse2.



        SORT lt_zfse2 BY hierarchynode hierarchynodelevel.
        SELECT
            SUM( amountincompanycodecurrency ) AS balance_amount,
            zsfe2~parentnode,
            gl_data~glaccount,
            zsfe2~debitcreditcode,
*          fiscalperiod,
*          fiscalyear,
            companycodecurrency AS balancetransactioncurrency
            FROM i_glaccountlineitemrawdata AS gl_data
            LEFT JOIN i_financialstatementhiernode AS zsfe2 ON zsfe2~hierarchynodeval = gl_data~glaccount
            WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
            fiscalyearperiod <= @lv_fiscal_report
            AND sourceledger = '0L'
            AND zsfe2~financialstatementhierarchy = 'ZBS1'
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
            companycodecurrency,
            zsfe2~debitcreditcode
            ORDER BY zsfe2~parentnode
            INTO TABLE @DATA(lt_gl_report).
*        SELECT
*            SUM( amountincompanycodecurrency ) AS balance_amount,
*            zsfe2~parentnode,
*            gl_data~glaccount,
*            companycodecurrency AS balancetransactioncurrency
*            FROM i_glaccountlineitemrawdata AS gl_data
*            LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
*            WHERE
*            fiscalyearperiod <= @lv_fiscal_compare
*            AND sourceledger = '0L'
*            AND zsfe2~glaccounthierarchy = 'ZBS1'
*            AND zsfe2~parentnode NOT LIKE '00%'
*            AND zsfe2~hierarchynode NOT LIKE '0%'
*            AND gl_data~companycode = @lw_header-companycode
*            AND gl_data~fiscalyear = @lw_header-nam_so_sanh
*            GROUP BY zsfe2~parentnode,
*            gl_data~glaccount,
*            companycodecurrency
*            ORDER BY zsfe2~parentnode
*            INTO TABLE @DATA(lt_gl_compare).

        SELECT
    SUM( amountincompanycodecurrency ) AS balance_amount,
    zsfe2~parentnode,
    gl_data~glaccount,
    zsfe2~debitcreditcode,
*          fiscalperiod,
*          fiscalyear,
    companycodecurrency AS balancetransactioncurrency
    FROM i_glaccountlineitemrawdata AS gl_data
    LEFT JOIN i_financialstatementhiernode AS zsfe2 ON zsfe2~hierarchynodeval = gl_data~glaccount
    WHERE
*          fiscalperiod IN @lr_report_period
*          AND fiscalyear IN @lr_report_year
    fiscalyearperiod <= @lv_fiscal_compare
    AND sourceledger = '0L'
    AND zsfe2~financialstatementhierarchy = 'ZBS1'
    AND zsfe2~parentnode NOT LIKE '00%'
    AND zsfe2~hierarchynode NOT LIKE '0%'
    AND gl_data~companycode = @lw_header-companycode
    AND gl_data~fiscalyear = @lw_header-nam_so_sanh
*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
    GROUP BY zsfe2~parentnode,
    gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
    companycodecurrency,
    zsfe2~debitcreditcode
    ORDER BY zsfe2~parentnode
    INTO TABLE @DATA(lt_gl_compare).

        SELECT
        *
        FROM ztb_zfes2 AS zsfe2
        WHERE zsfe2~fs_version = 'ZBS1'
        ORDER BY financial_statement
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


        me->convert_date(
          EXPORTING
            i_date      = lv_ngay_cuoi_ki
          IMPORTING
            e_text_date = DATA(lv_ngay_cuoi_ki_char)
        ).

        me->convert_date(
          EXPORTING
            i_date      = lv_ngay_dau_ki
          IMPORTING
            e_text_date = DATA(lv_ngay_dau_ki_char)
        ).
        IF lt_gl_report IS NOT INITIAL.
          DATA(lv_dvt) = lt_gl_report[ 1 ]-balancetransactioncurrency.
        ENDIF.
        "get logo
        DATA: lo_logo       TYPE REF TO zcl_get_logo_company.
        DATA: lv_logo TYPE string.
        DATA: lv_company TYPE c LENGTH 4.
        lv_company = lw_companycode-low.
        lo_logo = NEW #( ).
        lo_logo->get_logo( EXPORTING iv_company = lv_company IMPORTING lv_logo = lv_logo ).
        IF lv_logo IS INITIAL.
          lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
        ENDIF.
        lv_xml = |<Header>|.
        lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
        lv_xml = lv_xml && |<TenCongTy>{ ls_company-tencty_vn }</TenCongTy>|.
        lv_xml = lv_xml && |<DiaChi>{ ls_company-diachi_vn }</DiaChi>|.
        lv_xml = lv_xml && |<MaSoThue>{ ls_company-mst }</MaSoThue>|.
        DATA(lv_taingay) = |Tại ngày: { lv_ngay_cuoi_ki_char }|.
        lv_xml = lv_xml && |<TaiNgay>{ lv_taingay }</TaiNgay>|.
        lv_xml = lv_xml && |<DonViTinh>{ lv_dvt }</DonViTinh>|.
        lv_xml = lv_xml && |<NgaySoCuoiKy>{ lv_ngay_cuoi_ki_char }</NgaySoCuoiKy>|.
        lv_xml = lv_xml && |<NgaySoDauKy>{ lv_ngay_dau_ki_char }</NgaySoDauKy>|.
        lv_xml = lv_xml && |<Info>|.

        LOOP AT lt_zfse2 INTO DATA(lw_zfse2) .

          IF lw_zfse2-hierarchynode = '0410'.
            DATA(lv_x) = 'X'.
          ENDIF.
          lw_data-chi_tieu = lw_zfse2-hierarchynodetext.
          lw_data-ma_so = lw_zfse2-hierarchynode.
          lw_data-thuyet_minh = ''.
          lw_data-level = lw_zfse2-hierarchynodelevel.
*          lw_data-currency = 'VND'.
          SHIFT lw_data-level LEFT DELETING LEADING '0'.
          lw_data-parent_node  = lw_zfse2-parent_node.
          READ TABLE lt_gl_report INTO DATA(lw_gl_report) WITH KEY parentnode = lw_zfse2-hierarchynode BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_tabix) = sy-tabix.
            LOOP AT lt_gl_report INTO lw_gl_report FROM lv_tabix.
              IF lw_zfse2-hierarchynode <> lw_gl_report-parentnode.
                EXIT.
              ELSE.
                IF lw_gl_report-debitcreditcode IS INITIAL."nếu DebitCreditCode trống thì lấy cả giá trị âm và dương của glaccount
                  lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                ELSE.
                  IF lw_gl_report-debitcreditcode = 'S'."nếu DebitCreditCode = S chỉ lấy giá trị amount > 0 của glaccount
                    IF lw_gl_report-balance_amount > 0.
                      lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                    ENDIF.
                  ELSEIF lw_gl_report-debitcreditcode = 'H'."nếu DebitCreditCode = H chỉ lấy giá trị amount < 0 của glaccount
                    IF lw_gl_report-balance_amount < 0.
                      lw_data-so_cuoi_ki += lw_gl_report-balance_amount.
                    ENDIF.
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
                IF lw_gl_compare-debitcreditcode IS INITIAL."nếu DebitCreditCode trống thì lấy cả giá trị âm và dương của glaccount
                  lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                ELSE.
                  IF lw_gl_compare-debitcreditcode = 'S'."nếu DebitCreditCode = S chỉ lấy giá trị amount > 0 của glaccount
                    IF lw_gl_compare-balance_amount > 0.
                      lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                    ENDIF.
                  ELSEIF lw_gl_compare-debitcreditcode = 'H'."nếu DebitCreditCode = H chỉ lấy giá trị amount < 0 của glaccount
                    IF lw_gl_compare-balance_amount < 0.
                      lw_data-so_dau_ki += lw_gl_compare-balance_amount.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.

          ENDIF.

          READ TABLE lt_style_zsfe2 INTO DATA(lw_style) WITH KEY
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
          IF lw_data-ma_so CP '03*' OR lw_data-ma_so CP '04*'.
            lw_data-so_dau_ki =  lw_data-so_dau_ki * -1.
            lw_data-so_cuoi_ki =  lw_data-so_cuoi_ki * -1.
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
            ENDIF.
            IF <lfs_data>-ma_so = '00LIABILITS'.
              <lfs_data>-ma_so = '440'.
            ENDIF.
          ENDLOOP.
          lv_level_node -= 1.
        ENDWHILE.

        SORT lt_data BY ma_so.
        LOOP AT lt_data INTO lw_data.

           zcl_format_amount=>format_amount(
          EXPORTING
            i_amount   = lw_data-so_cuoi_ki
            i_currency = 'VND'
          RECEIVING
            r_amount   = lw_data-t_so_cuoi_ki
        ).

         zcl_format_amount=>format_amount(
          EXPORTING
            i_amount   = lw_data-so_dau_ki
            i_currency = 'VND'
          RECEIVING
            r_amount   = lw_data-t_so_dau_ki
        ).

          lv_xml = lv_xml && |<Data>|.
          lv_xml = lv_xml && |<ChiTieu>{ lw_data-chi_tieu }</ChiTieu>|.
          SHIFT lw_data-ma_so LEFT DELETING LEADING '0'.
          lv_xml = lv_xml && |<MaSo>{ lw_data-ma_so }</MaSo>|.
          lv_xml = lv_xml && |<ThuyetMinh>{ lw_data-thuyet_minh }</ThuyetMinh>|.
          IF lw_data-so_cuoi_ki IS INITIAL OR lw_data-so_cuoi_ki = '0.00'.
            lv_xml = lv_xml && |<SoCuoiKy></SoCuoiKy>|.
          ELSE.
            lv_xml = lv_xml && |<SoCuoiKy>{ lw_data-t_so_cuoi_ki }</SoCuoiKy>|.
          ENDIF.
          IF lw_data-so_dau_ki IS INITIAL OR lw_data-so_dau_ki = '0.00'.
            lv_xml = lv_xml && |<SoDauKy></SoDauKy>|.
          ELSE.
            lv_xml = lv_xml && |<SoDauKy>{ lw_data-t_so_dau_ki }</SoDauKy>|.
          ENDIF.
          lv_xml = lv_xml && |<Style>{ lw_data-style }</Style>|.
          lv_xml = lv_xml && |</Data>|.
        ENDLOOP.
        lv_xml = lv_xml && |</Info>|.
        lv_xml = lv_xml && |<NguoiLap>{ lv_nguoi_lap }</NguoiLap>|.
        lv_xml = lv_xml && |<KeToan>{ lv_ke_toan }</KeToan>|.
        lv_xml = lv_xml && |<GiamDoc>{ lv_giam_doc }</GiamDoc>|.
        lv_xml = lv_xml && |</Header>|.
        DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
*
*      TRY.
*          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
*               iv_service_instance_name   = 'ZADSTEMPLSTORE'
*               iv_use_destination_service = abap_false
*             ).
*
*          DATA(ls_template) = lo_store->get_template_by_name(
*            iv_get_binary    = abap_true
*            iv_form_name     = 'DEV_ZGL01'
*            iv_template_name = 'DEV_ZGL01'
*          ).
*        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error1).
*          DATA(lv_err1) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
*      ENDTRY.
        TRY.
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
      iv_service_instance_name   = 'ZADSTEMPLSTORE'
      iv_use_destination_service = abap_false
      ).

            DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZGL01' ).
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
        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data_exc>).
          SHIFT <lfs_data_exc>-ma_so LEFT DELETING LEADING '0'.
          <lfs_data_exc>-so_cuoi_ki = <lfs_data_exc>-so_cuoi_ki * 100.
          <lfs_data_exc>-so_dau_ki = <lfs_data_exc>-so_dau_ki * 100.
          IF <lfs_data_exc>-style = 'B'.
            <lfs_data_exc>-zlevel = 'A'.
          ELSEIF <lfs_data_exc>-style = 'I'.
            <lfs_data_exc>-zlevel = 'B'.
          ELSEIF <lfs_data_exc>-style = 'X'.
            <lfs_data_exc>-zlevel = 'C'.
          ELSE.
            <lfs_data_exc>-zlevel = 'D'.
          ENDIF.
        ENDLOOP.
        DATA: lt_excel TYPE tt_excel.
        APPEND VALUE #(
                h_company_name       =   ls_company-tencty_vn
                h_company_add        = ls_company-diachi_vn
                h_company_mst        = ls_company-mst
                h_title_vn           = 'BÁO CÁO TÌNH HÌNH TÀI CHÍNH'
                h_title_en           = 'BALANCE SHEET'
                h_title_subtitle     = lv_taingay
                h_title_mauso_1      = 'Mẫu số B 01-DN'
                h_title_mauso_2      = '(Kèm theo Thông tư số 99/2025/TT-BTC'
                h_title_mauso_3      = 'Ngày 27/10/2025 của Bộ trưởng Bộ Tài chính)'
                h_donvitinh          = 'Đơn vị tính: VND'
                i_title_chitieu      = 'Chỉ tiêu'
                i_title_maso         = 'Mã số'
                i_title_thuyetminh   = 'Thuyết minh'
                i_title_socuoiky     = 'Số cuối kỳ'
                i_title_sodauky      = 'Số đầu kỳ'
                item                 = lt_data
                f_ngaythangnam       = 'Ngày ... Tháng ... Năm ...'
                f_title_nguoilap     = 'Người lập'
                f_title_ketoantruong = 'Kế toán trưởng'
                f_title_tonggiamdoc  = 'Tổng giám đốc'
                f_nguoilap           = lv_nguoi_lap
                f_ketoantruong       = lv_ke_toan
                f_tonggiamdoc        = lv_giam_doc

         ) TO lt_excel.
        DATA: lv_excel  TYPE zde_attachment_tmpl.
        DATA : lv_filename TYPE string.
        DATA: lv_mimetype TYPE string.
        me->create_excel(
          EXPORTING
            i_data  = lt_excel
          IMPORTING
            e_excel = lv_excel
            e_filename = lv_filename
            e_mimetype = lv_mimetype
        ).


        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_print>) .

*        IF <lfs_print>-attachment IS INITIAL.
          <lfs_print>-attachment = lv_pdf.
          <lfs_print>-mimetype   = 'application/pdf'.
          <lfs_print>-filename   = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
          <lfs_print>-attachment_exc = lv_excel.
          <lfs_print>-mimetype_exc = lv_mimetype.
          <lfs_print>-filename_exc = lv_filename.
*        ENDIF.
        ENDLOOP.

**      DATA(ls_data) = VALUE ztb_zgl01_pdf(
**          object_id = lv_uuid_fi
**          report_id = 'ZFA_ZGL01'
**          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
**          mimetype = 'application/pdf'
**          attachment = lv_pdf
**
**           " Metadata fields
**        create_time            = cl_abap_context_info=>get_system_time( )
**        create_date            = cl_abap_context_info=>get_system_date( )
**
**        ).
***      INSERT ztb_zgl01_pdf FROM @ls_data.
***      IF sy-subrc <> 0.
***        " Có thể update nếu đã tồn tại
***        UPDATE ztb_zgl01_pdf FROM @ls_data.
***      ENDIF.
**    modify ztb_zgl01_pdf from @ls_data.
        DATA(lo_saver) = NEW zcl_savepdf_zgl01_n( ).
        lo_saver->save_pdf(
              iv_reportid = 'ZFA_ZGL01'
              iv_objectid      = lv_uuid_fi
              iv_pdf      = lv_pdf
            ).

      ELSE.
        MOVE-CORRESPONDING lt_pdf TO lt_header.
        SELECT SINGLE
          *
          FROM zr_tbfile_export
          WHERE reportid = 'ZGL01_EXC'
          INTO @DATA(ls_excel).
        LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_header>).
          <lfs_header>-attachment_exc = ls_excel-attachment.
          <lfs_header>-filename_exc = ls_excel-filename.
          <lfs_header>-mimetype_exc = ls_excel-mimetype.
        ENDLOOP.
      ENDIF.
    ENDIF.
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
          lv_report   TYPE char72 VALUE 'ZGL01',
          lv_template TYPE char72 VALUE 'ZGL01_EXC',
          lv_filename TYPE string VALUE 'ZGL01.xlsx',
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
