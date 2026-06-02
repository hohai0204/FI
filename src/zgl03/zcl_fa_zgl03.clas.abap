CLASS zcl_fa_zgl03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF gty_data,
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
             zlevel         TYPE string,
           END OF gty_data,
           gtt_data TYPE STANDARD TABLE OF gty_data WITH EMPTY KEY.
    "excel
    TYPES: BEGIN OF gty_excel,
             h_company_name         TYPE string,
             h_company_add          TYPE string,
             h_company_mst          TYPE string,
             h_title_vn             TYPE string,
             h_title_en             TYPE string,
             h_title_subtitle       TYPE string,
             h_donvitinh            TYPE string,
             h_title_mauso_1        TYPE string,
             h_title_mauso_2        TYPE string,
             h_title_mauso_3        TYPE string,
             i_title_chitieu        TYPE string,
             i_title_maso           TYPE string,
             i_title_thuyetminh     TYPE string,
             i_title_socuoiky       TYPE string,
             i_title_sodauky        TYPE string,
             i_title_socuoiky_luyke TYPE string,
             i_title_sodauky_luyke  TYPE string,
             item                   TYPE gtt_data,
             f_ngaythangnam         TYPE string,
             f_title_nguoilap       TYPE string,
             f_title_ketoantruong   TYPE string,
             f_title_tonggiamdoc    TYPE string,
             f_nguoilap             TYPE string,
             f_ketoantruong         TYPE string,
             f_tonggiamdoc          TYPE string,
           END OF gty_excel,
           tt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.
    INTERFACES if_rap_query_provider .
*    INTERFACES if_rap_query_request .
    METHODS authorization
      IMPORTING i_company TYPE c
      EXPORTING e_allow   TYPE abap_boolean.

    METHODS create_excel
      IMPORTING i_data     TYPE tt_excel
      EXPORTING e_excel    TYPE zde_attachment_tmpl
                e_filename TYPE string
                e_mimetype TYPE string
      .
    METHODS format_number
      IMPORTING i_number      TYPE p
                i_isvnd       TYPE abap_boolean
      EXPORTING e_text_number TYPE string.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FA_ZGL03 IMPLEMENTATION.


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
             zlevel         TYPE string,
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
*          AND length( text~hierarchynode ) = 3
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
*          AND length( zsfe2~parentnode ) = 3
          AND length( zsfe2~parentnode ) < 6
          AND zsfe2~parentnode <> '0ZIS1'
          AND gl_data~companycode = @lw_header-companycode
*          AND gl_data~fiscalyear = @lw_header-nam_bao_cao
*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
          GROUP BY zsfe2~parentnode,
          gl_data~glaccount,
*          fiscalperiod,
*          fiscalyear,
          companycodecurrency
          ORDER BY zsfe2~parentnode
          INTO TABLE @DATA(lt_gl_ky_report).

        SELECT
    amountincompanycodecurrency ,
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
      AND length( zsfe2~parentnode ) = 3
      AND zsfe2~parentnode = '001'

*          and gl_data~FinancialAccountType = 'K'
*          AND gl_data~glaccount NOT LIKE '3%1'
*        GROUP BY zsfe2~parentnode,
*        gl_data~glaccount,
**          fiscalperiod,
**          fiscalyear,
*        companycodecurrency
      ORDER BY zsfe2~parentnode
      INTO TABLE @DATA(lt_check).

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
*      AND gl_data~fiscalyear = @lw_header-nam_bao_cao
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
            node_text,
          CASE WHEN zfes2~bold = 'X' AND zfes2~italic IS INITIAL THEN 'B'
              WHEN zfes2~bold IS INITIAL AND zfes2~italic = 'X' THEN 'I'
              WHEN zfes2~bold = 'X' AND zfes2~italic = 'X' THEN 'X'
              ELSE ' ' END AS style,
        thuyet_minh
               FROM ztb_zfes2 AS zfes2
               WHERE fs_version = 'ZIS1'
               ORDER BY  fs_version,
            financial_statement
               INTO TABLE @DATA(lt_thuyetminh).

        LOOP AT lt_zfes2 INTO DATA(lw_zfes2).
          lw_data-chi_tieu = lw_zfes2-hierarchynodetext.

          lw_data-ma_so = lw_zfes2-hierarchynode.
*          CASE lw_data-ma_so.
*            WHEN '010'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 10 = 01 - 02 )'.
*
*            WHEN '020'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' ( 20 = 10 - 11 )'.
*
*            WHEN '030'.
*              lw_data-chi_tieu = lw_data-chi_tieu && ' { 30 = 20 + ( 21 - 22 ) - ( 25 + 26 ) }'.
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
*                  IF ( lw_zfes2_tmp-parent_node = '010' AND lw_zfes2_tmp-ma_so = '001' )
*                  OR ( lw_zfes2_tmp-parent_node = '020' AND lw_zfes2_tmp-ma_so = '010' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '020' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '021' )
*                  OR ( lw_zfes2_tmp-parent_node = '040' AND lw_zfes2_tmp-ma_so = '032' )
**                OR ( lw_zfes2_tmp-parent_node = '040' AND lw_zfes2_tmp-ma_so = '031' )
*                  OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '030' )
**                OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '040' )
*                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '050' )
*                  OR ( lw_zfes2_tmp-parent_node = '023' AND lw_zfes2_tmp-ma_so = '024.5' )
*                  OR ( lw_zfes2_tmp-parent_node = '023' AND lw_zfes2_tmp-ma_so = '024' )
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
*                  ELSEIF ( lw_zfes2_tmp-parent_node = '010' AND lw_zfes2_tmp-ma_so = '002' )
*                  OR ( lw_zfes2_tmp-parent_node = '020' AND lw_zfes2_tmp-ma_so = '011' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '022' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '023' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '025' )
*                  OR ( lw_zfes2_tmp-parent_node = '030' AND lw_zfes2_tmp-ma_so = '026' )
*                  OR ( lw_zfes2_tmp-parent_node = '050' AND lw_zfes2_tmp-ma_so = '040' )
*                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '051' )
*                  OR ( lw_zfes2_tmp-parent_node = '060' AND lw_zfes2_tmp-ma_so = '052' )
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
        diachi_vn23 AS diachi_vn,
        concat_with_space( 'Mã số thuế:' , mst , 1  ) AS mst
        FROM zcds_company
        WHERE companycode = @lw_header-companycode
        INTO @DATA(ls_company).
        SORT lt_data BY ma_so.
        DELETE lt_data WHERE ma_so = '024.5'.
        SHIFT lv_period_report LEFT DELETING LEADING '0'.
        DATA(lv_subtitle) = |Tháng { lv_period_report } năm { lw_report_year-low }|.
        DATA(lv_ky_bao_cao) = |{ lv_period_report }/{ lw_report_year-low }|.
        DATA(lv_ky_so_sanh) = |{ lv_period_compare }/{ lw_compare_year-low }|.
        lv_xml = |<Header>|.
        lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
        lv_xml = lv_xml && |<CompanyCode>{ ls_company-tencty_vn }</CompanyCode>|.
        lv_xml = lv_xml && |<Address>{ ls_company-diachi_vn }</Address>|.
        lv_xml = lv_xml && |<MST>{ ls_company-mst }</MST>|.
        lv_xml = lv_xml && |<DonViTinh></DonViTinh>|.
        lv_xml = lv_xml && |<SubTitle>{ lv_subtitle }</SubTitle>|.
        lv_xml = lv_xml && |<KyBaoCao>{ lv_ky_bao_cao }</KyBaoCao>|.
        lv_xml = lv_xml && |<KySoSanh>{ lv_ky_so_sanh }</KySoSanh>|.
        DATA(lv_luyke_report) = |Lũy kế đầu năm đến tháng { lv_ky_bao_cao }|.
        DATA(lv_luyke_compare) = |Lũy kế đầu năm đến tháng { lv_ky_so_sanh }|.
        lv_xml = lv_xml && |<KyLuyKeBaoCao>{ lv_luyke_report }</KyLuyKeBaoCao>|.
        lv_xml = lv_xml && |<KyLuyKeSoSanh>{ lv_luyke_compare }</KyLuyKeSoSanh>|.
        lv_xml = lv_xml && |<Data>|.
        DATA: lv_txt_ky_bao_cao TYPE string.
        DATA: lv_txt_ky_so_sanh TYPE string.
        DATA: lv_txt_luy_ke_so_sanh TYPE string.
        DATA: lv_txt_luy_ke_bao_cao TYPE string.

        LOOP AT lt_data INTO lw_data.
*      READ TABLE lt_data INTO lw_data INDEX 1.
          lv_xml = lv_xml && |<Item>|.
          lv_xml = lv_xml && |<ChiTieu>{ lw_data-chi_tieu }</ChiTieu>|.
          lw_data-ma_so = lw_data-ma_so+1(2).
          lv_xml = lv_xml && |<MaSo>{ lw_data-ma_so }</MaSo>|.
          lv_xml = lv_xml && |<ThuyetMinh>{ lw_data-thuyet_minh }</ThuyetMinh>|.
          "format số
          DATA: lv_ky_bao_cao_1 TYPE zde_amount23
          , lv_ky_so_sanh_1 TYPE zde_amount23
          , lv_luy_ke_so_sanh_1 TYPE zde_amount23
            , lv_luy_ke_bao_cao_1 TYPE zde_amount23.
            lv_ky_bao_cao_1 = lw_data-ky_bao_cao.
            lv_ky_so_sanh_1 = lw_data-ky_so_sanh.
            lv_luy_ke_so_sanh_1 = lw_data-luy_ke_so_sanh.
            lv_luy_ke_bao_cao_1 = lw_data-luy_ke_bao_cao.
          zcl_format_amount=>format_amount(
            EXPORTING
              i_amount   = lv_ky_bao_cao_1
              i_currency = 'VND'
            RECEIVING
              r_amount   = lv_txt_ky_bao_cao
          ).
          zcl_format_amount=>format_amount(
            EXPORTING
              i_amount   = lv_ky_so_sanh_1
              i_currency = 'VND'
            RECEIVING
              r_amount   = lv_txt_ky_so_sanh
          ).
          zcl_format_amount=>format_amount(
            EXPORTING
              i_amount   = lv_luy_ke_so_sanh_1
              i_currency = 'VND'
            RECEIVING
              r_amount   = lv_txt_luy_ke_so_sanh
          ).
          zcl_format_amount=>format_amount(
            EXPORTING
              i_amount   = lv_luy_ke_bao_cao_1
              i_currency = 'VND'
            RECEIVING
              r_amount   = lv_txt_luy_ke_bao_cao
          ).
*          me->format_number(
*            EXPORTING
*              i_number      = lw_data-ky_bao_cao * 100 "ViHT9/18.05.2026/Fix ZGL03 format currency
**i_number      = lw_data-ky_bao_cao
*              i_isvnd       = 'X'
*            IMPORTING
*              e_text_number = lv_txt_ky_bao_cao
*          ).
*          me->format_number(
*  EXPORTING
*              i_number      = lw_data-ky_so_sanh * 100 "ViHT9/18.05.2026/Fix ZGL03 format currency
**i_number      = lw_data-ky_so_sanh
*    i_isvnd       = 'X'
*  IMPORTING
*    e_text_number = lv_txt_ky_so_sanh
*).
*          me->format_number(
*  EXPORTING
*              i_number      = lw_data-luy_ke_so_sanh * 100 "ViHT9/18.05.2026/Fix ZGL03 format currency
**i_number      = lw_data-luy_ke_so_sanh
*    i_isvnd       = 'X'
*  IMPORTING
*    e_text_number = lv_txt_luy_ke_so_sanh
*).
*          me->format_number(
*  EXPORTING
*              i_number      = lw_data-luy_ke_bao_cao * 100 "ViHT9/18.05.2026/Fix ZGL03 format currency
**i_number      = lw_data-luy_ke_bao_cao
*    i_isvnd       = 'X'
*  IMPORTING
*    e_text_number = lv_txt_luy_ke_bao_cao
*).
*          lv_xml = lv_xml && |<KyBaoCao>{ lw_data-ky_bao_cao }</KyBaoCao>|.
*          lv_xml = lv_xml && |<KySoSanh>{ lw_data-ky_so_sanh }</KySoSanh>|.
*          lv_xml = lv_xml && |<LuyKeSoSanh>{ lw_data-luy_ke_so_sanh }</LuyKeSoSanh>|.
*          lv_xml = lv_xml && |<LuyKeBaoCao>{ lw_data-luy_ke_bao_cao }</LuyKeBaoCao>|.
          lv_xml = lv_xml && |<KyBaoCao>{ lv_txt_ky_bao_cao }</KyBaoCao>|.
          lv_xml = lv_xml && |<KySoSanh>{ lv_txt_ky_so_sanh }</KySoSanh>|.
          lv_xml = lv_xml && |<LuyKeSoSanh>{ lv_txt_luy_ke_so_sanh }</LuyKeSoSanh>|.
          lv_xml = lv_xml && |<LuyKeBaoCao>{ lv_txt_luy_ke_bao_cao }</LuyKeBaoCao>|.
          lv_xml = lv_xml && |<Style>{ lw_data-style }</Style>|.
          lv_xml = lv_xml && |</Item>|.
        ENDLOOP.
        lv_xml = lv_xml && |</Data>|.
        lv_xml = lv_xml && |<NguoiLap>{ lw_nguoi_lap-low }</NguoiLap>|.
        lv_xml = lv_xml && |<KeToan>{ lw_ke_toan-low }</KeToan>|.
        lv_xml = lv_xml && |<GiamDoc>{ lw_giam_doc-low }</GiamDoc>|.
        lv_xml = lv_xml && |</Header>|.


*      IF 1 = 2.
        DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.

        TRY.
            DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
                 iv_service_instance_name   = 'ZADSTEMPLSTORE'
                 iv_use_destination_service = abap_false
               ).

            DATA(ls_template) = lo_store->get_template_by_name(
              iv_get_binary    = abap_true
              iv_form_name     = 'DEV_ZGL03'
              iv_template_name = 'DEV_ZGL03'
            ).
          CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error1).
            DATA(lv_err1) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
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
          IF <lfs_data_exc>-style = 'B'.
            <lfs_data_exc>-zlevel = 'A'.
          ELSEIF <lfs_data_exc>-style = 'I'.
            <lfs_data_exc>-zlevel = 'B'.
          ELSEIF <lfs_data_exc>-style = 'X'.
            <lfs_data_exc>-zlevel = 'C'.
          ELSE.
            <lfs_data_exc>-zlevel = 'D'.
          ENDIF.
          <lfs_data_exc>-ky_bao_cao = <lfs_data_exc>-ky_bao_cao * 100.
          <lfs_data_exc>-ky_so_sanh = <lfs_data_exc>-ky_so_sanh * 100.
          <lfs_data_exc>-luy_ke_bao_cao = <lfs_data_exc>-luy_ke_bao_cao * 100.
          <lfs_data_exc>-luy_ke_so_sanh = <lfs_data_exc>-luy_ke_so_sanh * 100.
          IF <lfs_data_exc>-ma_so <> '24.5'.
            <lfs_data_exc>-ma_so = <lfs_data_exc>-ma_so+1(2).
          ELSE.
            SHIFT <lfs_data_exc>-ma_so LEFT DELETING LEADING '0'.
          ENDIF.
        ENDLOOP.
        DATA: lt_excel TYPE tt_excel.
        APPEND VALUE #(
                h_company_name       =   ls_company-tencty_vn
                h_company_add        = ls_company-diachi_vn
                h_company_mst        = ls_company-mst
                h_title_vn           = 'BÁO CÁO KẾT QUẢ HOẠT ĐỘNG KINH DOANH'
                h_title_en           = ' '
                h_title_subtitle     = lv_subtitle
                h_title_mauso_1      = 'Mẫu số B 02-DN'
                h_title_mauso_2      = '(Kèm theo Thông tư số 99/2025/TT-BTC'
                h_title_mauso_3      = 'Ngày 27/10/2025 của Bộ trưởng Bộ Tài chính)'
                h_donvitinh          = 'Đơn vị tính: VND'
                i_title_chitieu      = 'Chỉ tiêu'
                i_title_maso         = 'Mã số'
                i_title_thuyetminh   = 'Thuyết minh'
                i_title_socuoiky     = |Kỳ báo cáo { lv_ky_bao_cao }|
                i_title_sodauky      = |Kỳ so sánh { lv_ky_so_sanh }|
                i_title_socuoiky_luyke     = lv_luyke_report
                i_title_sodauky_luyke      = lv_luyke_compare
                item                 = lt_data
                f_ngaythangnam       = 'Ngày ... Tháng ... Năm ...'
                f_title_nguoilap     = 'Người lập'
                f_title_ketoantruong = 'Kế toán trưởng'
                f_title_tonggiamdoc  = 'Tổng giám đốc'
                f_nguoilap           = lw_nguoi_lap-low
                f_ketoantruong       = lw_ke_toan-low
                f_tonggiamdoc        = lw_giam_doc-low

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
          <lfs_print>-mimetype = 'application/pdf'.
          <lfs_print>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
          <lfs_print>-attachment_exc = lv_excel.
          <lfs_print>-mimetype_exc = lv_mimetype.
          <lfs_print>-filename_exc = lv_filename.
*        ENDIF.
        ENDLOOP.

***      DATA(ls_data_pdf) = VALUE ztb_zgl03_pdf(
***          object_id = lv_uuid_fi
***          report_id = 'ZFA_ZGL03'
***          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
***          mimetype = 'application/pdf'
***          attachment = lv_pdf
***
***           " Metadata fields
***        create_time            = cl_abap_context_info=>get_system_time( )
***        create_date            = cl_abap_context_info=>get_system_date( )
***
***        ).
***      INSERT ztb_zgl03_pdf FROM @ls_data_pdf.
***      IF sy-subrc <> 0.
***        " Có thể update nếu đã tồn tại
***        UPDATE ztb_zgl03_pdf FROM @ls_data_pdf.
***      ENDIF.

        DATA(lo_saver) = NEW zcl_save_pdf_zgl03( ).
        lo_saver->save_pdf(
              iv_reportid = 'ZFA_ZGL03'
              iv_objectid      = lv_uuid_fi
              iv_pdf      = lv_pdf
            ).
*      ENDIF.
      ELSE.
        MOVE-CORRESPONDING lt_pdf TO lt_header.
        SELECT SINGLE
          *
          FROM zr_tbfile_export
          WHERE reportid = 'ZGL03_EXC'
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
          lv_report   TYPE char72 VALUE 'ZGL03',
          lv_template TYPE char72 VALUE 'ZGL03_EXC',
          lv_filename TYPE string VALUE 'ZGL03.xlsx',
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


  METHOD format_number.
    DATA(lv_text) = |{ i_number }|.

    " Regex: chèn dấu chấm sau mỗi nhóm 3 chữ số từ phải sang trái
    REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
      IN lv_text WITH '$1.'.
    IF i_isvnd IS NOT INITIAL.
      SPLIT lv_text AT ',' INTO lv_text DATA(lv_a).
    ENDIF.
    e_text_number = lv_text.

  ENDMETHOD.
ENDCLASS.
