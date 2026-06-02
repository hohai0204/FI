CLASS zcl_cus_zgl03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
    INTERFACES if_rap_query_request .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUS_ZGL03 IMPLEMENTATION.


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
           END OF lty_data.

***
***    DATA : lt_header TYPE TABLE OF zfa_r_zgl03.
***    DATA : lw_header TYPE zfa_r_zgl03.
***    DATA: lt_data TYPE TABLE OF lty_data.
***    DATA : lw_data TYPE lty_data.
***    DATA lr_compnaycode    TYPE if_rap_query_filter=>tt_range_option.
***    " TODO: variable is assigned but never used (ABAP cleaner)
***    DATA lr_report_year    TYPE if_rap_query_filter=>tt_range_option.
***    " TODO: variable is assigned but never used (ABAP cleaner)
***    DATA lr_report_period  TYPE if_rap_query_filter=>tt_range_option.
***    " TODO: variable is assigned but never used (ABAP cleaner)
***    DATA lr_compare_year   TYPE if_rap_query_filter=>tt_range_option.
***    " TODO: variable is assigned but never used (ABAP cleaner)
***    DATA lr_compare_period TYPE if_rap_query_filter=>tt_range_option.
***    DATA lr_uuid TYPE if_rap_query_filter=>tt_range_option.
***    DATA lr_nguoi_lap TYPE if_rap_query_filter=>tt_range_option.
***    DATA lr_ke_toan TYPE if_rap_query_filter=>tt_range_option.
***    DATA lr_giam_doc TYPE if_rap_query_filter=>tt_range_option.
***    DATA: lv_xml TYPE string.
***
***    TRY.
***        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
***      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
***        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
***    ENDTRY.
***
***    DATA(top)              = io_request->get_paging( )->get_page_size( ).
***    DATA(skip)             = io_request->get_paging( )->get_offset( ).
***    DATA(requested_fields) = io_request->get_requested_elements( ).
***
***    IF lo_filter IS NOT INITIAL.
***      LOOP AT lo_filter INTO DATA(lw_filter).
***        CASE lw_filter-name.
***          WHEN 'COMPANYCODE'.
***            lr_compnaycode = lw_filter-range.
***            DATA(lw_companycode) = lr_compnaycode[ 1 ].
***            lw_header-companycode = lw_companycode-low.
***          WHEN 'KY_BAO_CAO'.
***            lr_report_period = lw_filter-range.
***            DATA(lw_report_period) = lr_report_period[ 1 ].
***            lw_header-ky_bao_cao = lw_report_period-low.
***          WHEN 'NAM_BAO_CAO'.
***            lr_report_year = lw_filter-range.
***            DATA(lw_report_year) = lr_report_year[ 1 ].
***            lw_header-nam_bao_cao = lw_report_year-low.
***          WHEN 'KY_SO_SANH'.
***            lr_compare_period = lw_filter-range.
***            DATA(lw_compare_period) = lr_compare_period[ 1 ].
***            lw_header-ky_so_sanh = lw_compare_period-low.
***          WHEN 'NAM_SO_SANH'.
***            lr_compare_year = lw_filter-range.
***            DATA(lw_compare_year) = lr_compare_year[ 1 ].
***            lw_header-nam_so_sanh = lw_compare_year-low.
***          WHEN 'UUID'.
***            lr_uuid = lw_filter-range.
***            DATA(lw_uuid) = lr_uuid[ 1 ].
***          WHEN 'NGUOI_LAP'.
***            lr_nguoi_lap = lw_filter-range.
***            DATA(lw_nguoi_lap) = lr_nguoi_lap[ 1 ].
***          WHEN 'KE_TOAN'.
***            lr_ke_toan = lw_filter-range.
***            DATA(lw_ke_toan) = lr_ke_toan[ 1 ].
***          WHEN 'GIAM_DOC'.
***            lr_giam_doc = lw_filter-range.
***            DATA(lw_giam_doc) = lr_giam_doc[ 1 ].
***        ENDCASE.
***        IF lw_header-companycode IS INITIAL.
***          lw_header-companycode = '1100'.
***        ENDIF.
***      ENDLOOP.
***    ENDIF.
***
***    DATA(lv_period_report) = lw_report_period-low.
***    SHIFT lv_period_report LEFT DELETING LEADING '0'.
***    IF lv_period_report < 10.
***      DATA(lv_fiscal_report) = |{ lw_report_year-low }00{ lv_period_report }|.
***    ELSE.
***      lv_fiscal_report = |{ lw_report_year-low }0{ lv_period_report }|.
***    ENDIF.
***
***    DATA(lv_period_compare) = lw_compare_period-low.
***    SHIFT lv_period_compare LEFT DELETING LEADING '0'.
***    IF lv_period_compare < 10.
***      DATA(lv_fiscal_compare) = |{ lw_compare_year-low }00{ lv_period_compare }|.
***    ELSE.
***      lv_fiscal_compare = |{ lw_compare_year-low }0{ lv_period_compare }|.
***    ENDIF.
***    IF lr_uuid IS NOT INITIAL.
***
***      SELECT
***      *
***      FROM ztb_zgl03_pdf
***      WHERE object_id = @lw_uuid-low
***      INTO TABLE @DATA(lt_pdf).
***    ENDIF.
***
***    IF lt_pdf IS INITIAL.
***      TRY.
***          DATA(lv_uuid_fi) = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
***        CATCH cx_uuid_error.
***      ENDTRY.
***      lw_header-companycode = lw_companycode-low.
***      lw_header-ky_bao_cao = lw_report_period-low.
***      lw_header-nam_bao_cao = lw_report_year-low.
***      lw_header-ky_so_sanh = lw_compare_period-low.
***      lw_header-nam_so_sanh = lw_compare_year-low.
***      lw_header-uuid = lv_uuid_fi.
***      append lw_header TO lt_header.
***      SELECT
***        text~glaccounthierarchy,
***        text~hierarchynode,
***        text~hierarchynodetext,
***        head~hierarchynodelevel,
***        zfes2~thuyet_minh,
***        CASE WHEN zfes2~bold = 'X' AND zfes2~italic IS INITIAL THEN 'B'
***            WHEN zfes2~bold IS INITIAL AND zfes2~italic = 'X' THEN 'I'
***            WHEN zfes2~bold = 'X' AND zfes2~italic = 'X' THEN 'X'
***            ELSE ' ' END AS style
***        FROM i_glaccounthierarchynode AS head
***        INNER JOIN i_glaccounthierarchynodet AS text ON head~glaccounthierarchy = text~glaccounthierarchy
***        LEFT JOIN ztb_zfes2 AS zfes2 ON head~glaccounthierarchy = zfes2~fs_version
***                                    AND head~hierarchynode = zfes2~financial_statement
***        AND head~hierarchynode = text~hierarchynode
***        WHERE head~glaccounthierarchy = 'ZIS1'
***        AND head~parentnode NOT LIKE '00%'
***        AND head~hierarchynode NOT LIKE '00%'
***        AND text~language = 'E'
***        AND head~hierarchynode NE '0ZBS1'
***        ORDER BY head~hierarchynode , head~hierarchynodelevel
***        INTO TABLE @DATA(lt_zfes2)
***     .
***
***      SELECT
***      SUM( amountincompanycodecurrency ) AS amount,
***      gl_data~glaccount,
***      zsfe2~parentnode,
***       companycodecurrency AS balancetransactioncurrency
***        FROM i_glaccountlineitemrawdata AS gl_data
***        LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
***        WHERE
****          fiscalperiod IN @lr_report_period
****          AND fiscalyear IN @lr_report_year
***        fiscalyearperiod = @lv_fiscal_report
***        AND sourceledger = '0L'
***        AND zsfe2~glaccounthierarchy = 'ZIS1'
***        AND zsfe2~parentnode NOT LIKE '00%'
***        AND zsfe2~hierarchynode NOT LIKE '0%'
****          and gl_data~FinancialAccountType = 'K'
****          AND gl_data~glaccount NOT LIKE '3%1'
***        GROUP BY zsfe2~parentnode,
***        gl_data~glaccount,
****          fiscalperiod,
****          fiscalyear,
***        companycodecurrency
***        ORDER BY zsfe2~parentnode
***        INTO TABLE @DATA(lt_gl_ky_report).
***
***      SELECT
***  SUM( amountincompanycodecurrency ) AS amount,
***  gl_data~glaccount,
***  zsfe2~parentnode,
***   companycodecurrency AS balancetransactioncurrency
***    FROM i_glaccountlineitemrawdata AS gl_data
***    LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
***    WHERE
****          fiscalperiod IN @lr_report_period
****          AND fiscalyear IN @lr_report_year
***    fiscalyearperiod <= @lv_fiscal_report
***    AND sourceledger = '0L'
***    AND zsfe2~glaccounthierarchy = 'ZIS1'
***    AND zsfe2~parentnode NOT LIKE '00%'
***    AND zsfe2~hierarchynode NOT LIKE '0%'
****          and gl_data~FinancialAccountType = 'K'
****          AND gl_data~glaccount NOT LIKE '3%1'
***    GROUP BY zsfe2~parentnode,
***    gl_data~glaccount,
****          fiscalperiod,
****          fiscalyear,
***    companycodecurrency
***    ORDER BY zsfe2~parentnode
***    INTO TABLE @DATA(lt_gl_luyke_report).
***
***
***      SELECT
***  SUM( amountincompanycodecurrency ) AS amount,
***  gl_data~glaccount,
***  zsfe2~parentnode,
***   companycodecurrency AS balancetransactioncurrency
***    FROM i_glaccountlineitemrawdata AS gl_data
***    LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
***    WHERE
****          fiscalperiod IN @lr_report_period
****          AND fiscalyear IN @lr_report_year
***    fiscalyearperiod = @lv_fiscal_compare
***    AND sourceledger = '0L'
***    AND zsfe2~glaccounthierarchy = 'ZIS1'
***    AND zsfe2~parentnode NOT LIKE '00%'
***    AND zsfe2~hierarchynode NOT LIKE '0%'
****          and gl_data~FinancialAccountType = 'K'
****          AND gl_data~glaccount NOT LIKE '3%1'
***    GROUP BY zsfe2~parentnode,
***    gl_data~glaccount,
****          fiscalperiod,
****          fiscalyear,
***    companycodecurrency
***    ORDER BY zsfe2~parentnode
***    INTO TABLE @DATA(lt_gl_ky_compare).
***
***      SELECT
***  SUM( amountincompanycodecurrency ) AS amount,
***  gl_data~glaccount,
***  zsfe2~parentnode,
***   companycodecurrency AS balancetransactioncurrency
***    FROM i_glaccountlineitemrawdata AS gl_data
***    LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
***    WHERE
****          fiscalperiod IN @lr_report_period
****          AND fiscalyear IN @lr_report_year
***    fiscalyearperiod <= @lv_fiscal_compare
***    AND sourceledger = '0L'
***    AND zsfe2~glaccounthierarchy = 'ZIS1'
***    AND zsfe2~parentnode NOT LIKE '00%'
***    AND zsfe2~hierarchynode NOT LIKE '0%'
****          and gl_data~FinancialAccountType = 'K'
****          AND gl_data~glaccount NOT LIKE '3%1'
***    GROUP BY zsfe2~parentnode,
***    gl_data~glaccount,
****          fiscalperiod,
****          fiscalyear,
***    companycodecurrency
***    ORDER BY zsfe2~parentnode
***    INTO TABLE @DATA(lt_gl_luyke_compare).
***
***      LOOP AT lt_zfes2 INTO DATA(lw_zfes2).
***        lw_data-chi_tieu = lw_zfes2-hierarchynodetext.
***        lw_data-ma_so = lw_zfes2-hierarchynode.
***        lw_data-thuyet_minh = lw_zfes2-thuyet_minh.
***        lw_data-style = lw_zfes2-style.
***
***        "giá trị ky bao cao
***        READ TABLE lt_gl_ky_report INTO DATA(ls_gl_ky_report) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
***        IF sy-subrc = 0.
***          DATA(lv_tabix_1) = sy-tabix.
***          LOOP AT lt_gl_ky_report INTO ls_gl_ky_report FROM lv_tabix_1.
***            IF ls_gl_ky_report-parentnode = lw_zfes2-hierarchynode.
***              EXIT.
***            ELSE.
***              lw_data-ky_bao_cao += ls_gl_ky_report-amount.
***            ENDIF.
***          ENDLOOP.
***        ENDIF.
***
***        "giá trị luy ke ky bao cao
***        READ TABLE lt_gl_luyke_report INTO DATA(ls_gl_luyke_report) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
***        IF sy-subrc = 0.
***          DATA(lv_tabix_2) = sy-tabix.
***          LOOP AT lt_gl_luyke_report INTO ls_gl_luyke_report FROM lv_tabix_2.
***            IF ls_gl_luyke_report-parentnode = lw_zfes2-hierarchynode.
***              EXIT.
***            ELSE.
***
***              lw_data-ky_bao_cao += ls_gl_luyke_report-amount.
***            ENDIF.
***          ENDLOOP.
***        ENDIF.
***
***        "giá trị ky so sanh
***        READ TABLE lt_gl_ky_compare INTO DATA(ls_gl_ky_compare) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
***        IF sy-subrc = 0.
***          DATA(lv_tabix_3) = sy-tabix.
***          LOOP AT lt_gl_ky_compare INTO ls_gl_ky_compare FROM lv_tabix_3.
***            IF ls_gl_ky_compare-parentnode = lw_zfes2-hierarchynode.
***              EXIT.
***            ELSE.
***              lw_data-ky_bao_cao += ls_gl_ky_compare-amount.
***            ENDIF.
***          ENDLOOP.
***        ENDIF.
***
***        "giá trị luy ke so sánh
***        READ TABLE lt_gl_luyke_compare INTO DATA(ls_gl_luyke_compare) WITH KEY parentnode = lw_zfes2-hierarchynode BINARY SEARCH.
***        IF sy-subrc = 0.
***          DATA(lv_tabix_4) = sy-tabix.
***          LOOP AT lt_gl_luyke_compare INTO ls_gl_luyke_compare FROM lv_tabix_4.
***            IF ls_gl_luyke_compare-parentnode = lw_zfes2-hierarchynode.
***              EXIT.
***            ELSE.
***              lw_data-ky_bao_cao += ls_gl_luyke_compare-amount.
***            ENDIF.
***          ENDLOOP.
***        ENDIF.
***
***      ENDLOOP.
***
***      SELECT SINGLE
***      tencty_vn,
***      diachi_vn,
***      concat_with_space( 'Mã số thuế:' , mst , 1  ) AS mst
***      FROM zcds_company
***      WHERE companycode = @lw_header-companycode
***      INTO @DATA(ls_company).
***
***      SHIFT lv_period_report LEFT DELETING LEADING '0'.
***      DATA(lv_subtitle) = |Tháng{ lv_period_report } năm{ lw_report_year-low }|.
***      DATA(lv_ky_bao_cao) = |{ lv_period_report }/{ lw_report_year-low }|.
***      DATA(lv_ky_so_sanh) = |{ lv_period_compare }/{ lw_compare_year-low }|.
***      lv_xml = |<Header>|.
***      lv_xml = lv_xml && |<CompanyCode>{ ls_company-tencty_vn }</CompanyCode>|.
***      lv_xml = lv_xml && |<Address>{ ls_company-diachi_vn }</Address>|.
***      lv_xml = lv_xml && |<MST>{ ls_company-mst }</MST>|.
***      lv_xml = lv_xml && |<DonViTinh></DonViTinh>|.
***      lv_xml = lv_xml && |<SubTitle>{ lv_subtitle }</SubTitle>|.
***      lv_xml = lv_xml && |<KyBaoCao>{ lv_ky_bao_cao }</KyBaoCao>|.
***      lv_xml = lv_xml && |<KySoSanh>{ lv_ky_so_sanh }</KySoSanh>|.
***      DATA(lv_luyke_report) = |Lũy kế đầu năm đến tháng { lv_ky_bao_cao }|.
***      DATA(lv_luyke_compare) = |Lũy kế đầu năm đến tháng { lv_ky_so_sanh }|.
***      lv_xml = lv_xml && |<KyLuyKeBaoCao>{ lv_luyke_report }</KyLuyKeBaoCao>|.
***      lv_xml = lv_xml && |<KyLuyKeSoSanh>{ lv_luyke_compare }</KyLuyKeSoSanh>|.
***      lv_xml = lv_xml && |<Data>|.
***      LOOP AT lt_data INTO lw_data.
***        lv_xml = lv_xml && |<Item>|.
***        lv_xml = lv_xml && |<ChiTieu>{ lw_data-chi_tieu }</ChiTieu>|.
***        lv_xml = lv_xml && |<MaSo>{ lw_data-ma_so }</MaSo>|.
***        lv_xml = lv_xml && |<ThuyetMinh>{ lw_data-thuyet_minh }</ThuyetMinh>|.
***        lv_xml = lv_xml && |<KyBaoCao>{ lw_data-ky_bao_cao }</KyBaoCao>|.
***        lv_xml = lv_xml && |<KySoSanh>{ lw_data-ky_so_sanh }</KySoSanh>|.
***        lv_xml = lv_xml && |<LuyKeSoSanh>{ lw_data-luy_ke_so_sanh }</LuyKeSoSanh>|.
***        lv_xml = lv_xml && |<LuyKeBaoCao>{ lw_data-luy_ke_bao_cao }</LuyKeBaoCao>|.
***        lv_xml = lv_xml && |<Style>{ lw_data-style }</Style>|.
***        lv_xml = lv_xml && |</Item>|.
***      ENDLOOP.
***      lv_xml = lv_xml && |</Data>|.
***      lv_xml = lv_xml && |<NguoiLap>{ lw_nguoi_lap-low }</NguoiLap>|.
***      lv_xml = lv_xml && |<KeToan>{ lw_ke_toan-low }</KeToan>|.
***      lv_xml = lv_xml && |<GiamDoc>{ lw_giam_doc-low }</GiamDoc>|.
***      lv_xml = lv_xml && |</Header>|.
***
***
****      IF 1 = 2.
***      DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
***
***      TRY.
***          DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
***               iv_service_instance_name   = 'ZADSTEMPLSTORE'
***               iv_use_destination_service = abap_false
***             ).
***
***          DATA(ls_template) = lo_store->get_template_by_name(
***            iv_get_binary    = abap_true
***            iv_form_name     = 'DEV_ZGL03'
***            iv_template_name = 'DEV_ZGL03'
***          ).
***        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error1).
***          DATA(lv_err1) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
***      ENDTRY.
***
***      TRY.
***          cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xstring "lv_xml
***                                                iv_xdp_layout   = ls_template-xdp_template
***                                                iv_locale       = 'de_DE'
***                                                is_options      = VALUE #(
***                                               trace_level = 4 "Use 0 in production environment
***          )
***                                      IMPORTING ev_pdf          = DATA(lv_pdf)
***                                                ev_pages        = DATA(ev_pages)
***                                                ev_trace_string = DATA(ev_trace_string)
***                                               ).
***        CATCH cx_fp_ads_util INTO DATA(lx_error2).
***          DATA(lv_err2) = lx_error2->get_text( ).  " Hoặc ghi log, v.v.
***      ENDTRY.
***
***      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_print>) .
***
****        IF <lfs_print>-attachment IS INITIAL.
***        <lfs_print>-attachment = lv_pdf.
***        <lfs_print>-mimetype = 'application/pdf'.
***        <lfs_print>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
***
****        ENDIF.
***      ENDLOOP.
***
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
****      ENDIF.
***    ELSE.
***      MOVE-CORRESPONDING lt_pdf TO lt_header.
***
***    ENDIF.
***    io_response->set_data( lt_header ).
***
***    IF io_request->is_total_numb_of_rec_requested(  ).
***      io_response->set_total_number_of_records( lines( lt_header ) ).
***    ENDIF.

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
