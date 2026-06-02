CLASS zcl_fa_zgl04n DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    TYPES: BEGIN OF lty_item,
             stt                TYPE string,
             postingdate        TYPE string,
             accountingdocument TYPE string,
             documentdate       TYPE string,
             item               TYPE i_journalentryitem-ledgergllineitem, "hoangtd21
             description        TYPE string,
             s_glaccount        TYPE string,
             h_glaccount        TYPE string,
             s_amount           TYPE p DECIMALS 2 LENGTH 16,
             h_amount           TYPE p DECIMALS 2 LENGTH 16,
           END OF lty_item,
           gtt_item TYPE STANDARD TABLE OF lty_item WITH EMPTY KEY.



    TYPES: gtt_data  TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY.
    TYPES: BEGIN OF gty_excel,
             h_company_name       TYPE string,
             h_company_add        TYPE string,
             h_company_mst        TYPE string,
             h_title              TYPE string,
             h_title_subtitle     TYPE string,
             "Item
             i_title_stt          TYPE string,
             i_title_ngayhachtoan TYPE string,
             i_title_chungtu      TYPE string,
             i_title_sochungtu    TYPE string,
             i_title_ngaychungtu  TYPE string,
             i_title_diengiai     TYPE string,
             i_title_taikhoanno   TYPE string,
             i_title_taikhoanco   TYPE string,
             i_title_novnd        TYPE string,
             i_title_covnd        TYPE string,
             item                 TYPE gtt_item,
             "Footer
             f_ngaythangnam       TYPE string,
             f_title_nguoilap     TYPE string,
             f_title_ketoantruong TYPE string,
             f_title_tonggiamdoc  TYPE string,
             f_kyten              TYPE string,
             f_nguoilap           TYPE string,
             f_ketoantruong       TYPE string,
             f_tonggiamdoc        TYPE string,
           END OF gty_excel,
           tt_excel TYPE STANDARD TABLE OF gty_excel WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: r_companycode    TYPE if_rap_query_filter=>tt_range_option,
          r_postingdate    TYPE if_rap_query_filter=>tt_range_option,
          r_fiscalyear     TYPE if_rap_query_filter=>tt_range_option,
          cb_incl_reversed TYPE abap_boolean,
          r_uuid           TYPE if_rap_query_filter=>tt_range_option.
    TYPES tt_zgl04n TYPE STANDARD TABLE OF zr_fa_zgl04n WITH EMPTY KEY.

    DATA: BEGIN OF s_footer,
            nguoi_lap TYPE zde_desc_255,
            ke_toan   TYPE zde_desc_255,
            giam_doc  TYPE zde_desc_255,
          END OF s_footer.

    METHODS set_selscreen
      IMPORTING
        it_filter TYPE if_rap_query_filter=>tt_name_range_pairs.

    METHODS get_dataa
      EXPORTING
        et_data TYPE STANDARD TABLE.

    METHODS get_data
      IMPORTING
        i_top          TYPE int8
        i_skip         TYPE int8
      EXPORTING
        et_header      TYPE STANDARD TABLE
      RETURNING
        VALUE(rt_data) TYPE tt_zgl04n.

    METHODS format_date
      IMPORTING
        i_date        TYPE datum
      RETURNING
        VALUE(r_date) TYPE char13.

    METHODS create_excel
      IMPORTING i_data     TYPE tt_excel
      EXPORTING e_excel    TYPE zde_attachment_tmpl
                e_filename TYPE string
                e_mimetype TYPE string
      .
ENDCLASS.



CLASS ZCL_FA_ZGL04N IMPLEMENTATION.


  METHOD format_date.
    DATA: BEGIN OF w_date,
            year  TYPE gjahr,
            month TYPE char03,
            day   TYPE char03,
          END OF w_date.

    w_date = i_date.
    r_date = |{ i_date+6(2) }/{ i_date+4(2) }/{ i_date+0(4) }|. " hoangtd21
*    CONCATENATE w_date-day '/' w_date-month '/' w_date-year INTO r_date.
  ENDMETHOD.


  METHOD get_dataa.
    DATA: lw_data TYPE zr_fa_zgl04n,
          lt_data TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY.



    SELECT
          header~companycode,
          header~fiscalyear,
          header~accountingdocument,
          header~postingdate,
          header~documentdate,
          header~isreversed,
          header~reversedocument,
          item~ledgergllineitem AS item,
          CASE WHEN item~documentitemtext  IS NOT INITIAL
               THEN item~documentitemtext
               ELSE header~accountingdocumentheadertext
               END AS description,
          CASE WHEN item~debitcreditcode = 'S'
               THEN item~glaccount
               END AS s_glaccount,
          CASE WHEN item~debitcreditcode = 'H'
               THEN item~glaccount
               END AS h_glaccount,
          CASE WHEN item~debitcreditcode = 'S'
               THEN item~debitamountincocodecrcy
               END AS s_amount,
          CASE WHEN item~debitcreditcode = 'H'
               THEN item~creditamountincocodecrcy
               END AS h_amount,
          @me->s_footer-nguoi_lap AS nguoi_lap,
          @me->s_footer-ke_toan   AS ke_toan,
          @me->s_footer-giam_doc  AS giam_doc
        FROM i_journalentry AS header
        INNER JOIN i_journalentryitem AS item
                ON item~companycode = header~companycode
               AND item~fiscalyear  = header~fiscalyear
               AND item~accountingdocument  = header~accountingdocument
       WHERE item~ledger = '0L'
         AND header~fiscalyear  IN @me->r_fiscalyear
         AND header~postingdate IN @me->r_postingdate " hoangtd21 27/04/2026
         AND header~companycode IN @me->r_companycode
      ORDER BY header~companycode,
               header~fiscalyear,
               header~accountingdocument,
*               item~ledgergllineitem,
               header~postingdate
      INTO TABLE @DATA(lt_origindoc).

*   Get Reversal Document
    SELECT
        header~companycode,
        header~fiscalyear,
        header~accountingdocument,
        header~postingdate,
        header~documentdate,
        header~isreversed,
        header~reversedocument,
        item~ledgergllineitem AS item,
        CASE WHEN item~documentitemtext IS NOT INITIAL
             THEN item~documentitemtext
             ELSE header~accountingdocumentheadertext
             END AS description,
        CASE WHEN item~debitcreditcode = 'S'
             THEN item~glaccount
             END AS s_glaccount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~glaccount
             END AS h_glaccount,
        CASE WHEN item~debitcreditcode = 'S'
             THEN item~debitamountincocodecrcy
             END AS s_amount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~creditamountincocodecrcy
             END AS h_amount,
        @me->s_footer-nguoi_lap AS nguoi_lap,
        @me->s_footer-ke_toan   AS ke_toan,
        @me->s_footer-giam_doc  AS giam_doc
      FROM @lt_origindoc AS origindoc
      LEFT JOIN
       ( i_journalentry AS header INNER JOIN i_journalentryitem AS item
           ON item~companycode = header~companycode
          AND item~fiscalyear  = header~fiscalyear
          AND item~accountingdocument  = header~accountingdocument
       )   ON header~companycode     = origindoc~companycode
          AND header~reversedocument = origindoc~accountingdocument
      WHERE origindoc~isreversed = 'X'
        AND header~companycode IN @me->r_companycode
        AND header~postingdate IN @me->r_postingdate " 27/04/2026
        AND header~isreversal = 'X'
    INTO TABLE @DATA(lt_reversaldoc).



**  Checkbox Include Reversed
    IF cb_incl_reversed = abap_true AND lt_reversaldoc IS NOT INITIAL.
      "Hiển thị chứng từ reversed khác kỳ
      LOOP AT lt_origindoc ASSIGNING FIELD-SYMBOL(<lf_origin>)
                               WHERE isreversed IS NOT INITIAL.
        READ TABLE lt_reversaldoc ASSIGNING FIELD-SYMBOL(<lf_reversal>)
           WITH KEY accountingdocument = <lf_origin>-reversedocument
                    fiscalyear         = <lf_origin>-fiscalyear
                    postingdate+4(2)   = <lf_origin>-postingdate+4(2).
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        lw_data = CORRESPONDING #(  <lf_origin> ).
        APPEND lw_data TO lt_data. CLEAR lw_data.

        lw_data = CORRESPONDING #(  <lf_reversal>  ).
        APPEND lw_data TO lt_data. CLEAR lw_data.
      ENDLOOP.

      "Get Normal Origin Document
      DELETE lt_origindoc WHERE isreversed IS NOT INITIAL.
      lt_data = CORRESPONDING #( lt_origindoc ).

    ELSE.
      APPEND LINES OF lt_reversaldoc TO lt_origindoc.
      lt_data = CORRESPONDING #( lt_origindoc ).

    ENDIF.

    SORT lt_data.

    et_data = lt_data.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TYPES: BEGIN OF lty_date,
             year  TYPE gjahr,
             month TYPE char03,
             day   TYPE char03,
           END OF lty_date.
    DATA: ls_date_fr TYPE lty_date,
          ls_date_to TYPE lty_date.

    DATA: lt_data   TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY,
          lt_header TYPE STANDARD TABLE OF zr_fa_zgl04n WITH EMPTY KEY.

    DATA: lv_xml   TYPE string,
          lv_index TYPE int4.




**  Phân trang
    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).


**  Set data from Selection Screen.
    TRY.
        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    me->set_selscreen( lo_filter ).



    IF r_uuid IS NOT INITIAL.
      DATA(l_uuid) =  r_uuid[ 1 ]-low.
      SELECT ztb_zgl04n_pdf~objectid AS uuid,
             ztb_zgl04n_pdf~*
        FROM ztb_zgl04n_pdf
       WHERE objectid = @l_uuid
      INTO CORRESPONDING FIELDS OF TABLE @lt_header.

      CHECK sy-subrc = 0.
      SELECT SINGLE
         *
         FROM zr_tbfile_export
         WHERE reportid = 'ZGL04_EXC'
         INTO @DATA(ls_excel).
      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_header>).
        <lfs_header>-attachment_exc = ls_excel-attachment.
        <lfs_header>-filename_exc = ls_excel-filename.
        <lfs_header>-mimetype_exc = ls_excel-mimetype.
      ENDLOOP.
*** SET response
      io_response->set_data( lt_header ).

      IF io_request->is_total_numb_of_rec_requested(  ).
        io_response->set_total_number_of_records( lines( lt_header ) ).
      ENDIF.
    ENDIF.


    CHECK lt_header IS INITIAL.
***  Init uuid
*    TRY.
*        DATA(lv_uuid_fi) = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version(
*                                          version = 4 ).
*        ##NO_HANDLER
*      CATCH cx_uuid_error.
*    ENDTRY.

**  Query data
**********************************************************************
*   Origin Doc = Reversed Doc: Chứng từ hủy
*   Reversal Doc: Chứng từ đảo ( dùng để hủy chứng từ gốc )
**********************************************************************
    me->get_data(
      EXPORTING
        i_top     = top
        i_skip    = skip
      IMPORTING
        et_header = lt_header
      RECEIVING
        rt_data   = lt_data
    ).
    DELETE ADJACENT DUPLICATES FROM lt_header COMPARING companycode fiscalyear.

**  Get Posting date
*    IF r_postingdate IS INITIAL.
    " 27/04/2026

    SELECT data~companycode,
                data~fiscalyear,
                MIN( postingdate ) AS min_postdate,
                MAX( postingdate ) AS max_postdate
           FROM @lt_data AS data
           GROUP BY data~companycode,
                    data~fiscalyear

         INTO TABLE @DATA(lt_postdate).
         sort lt_postdate by companycode fiscalyear.
    IF r_postingdate IS NOT INITIAL.

      READ TABLE r_postingdate INTO DATA(ls_range_fix) INDEX 1.

      IF sy-subrc = 0 AND ls_range_fix IS NOT INITIAL.

        ls_date_fr = ls_range_fix-low.

        ls_date_to = COND #(
          WHEN ls_range_fix-high IS INITIAL
          THEN ls_range_fix-low
          ELSE ls_range_fix-high
        ).
        CLEAR lt_postdate.

      ENDIF.

    ENDIF.
** PDF Header
    SELECT companycode,
           tencty_vn,
           diachi_vn23 AS diachi_vn,
           concat_with_space( 'Mã số thuế:' , mst , 1  ) AS mst
      FROM zcds_company
      WHERE companycode IN @r_companycode
      order by companycode
     INTO TABLE @DATA(lt_company).

    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_service_instance_name   = 'ZADSTEMPLSTORE'
             iv_use_destination_service = abap_false
           ).

        DATA(ls_template) = lo_store->get_template_by_tcode(  'ZGL04N' ).
      CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error1).
        DATA(lv_err1) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    "get logo
    DATA: lo_logo       TYPE REF TO zcl_get_logo_company.
    DATA: lv_logo TYPE string.
    DATA: lv_company TYPE c LENGTH 4.
    lv_company = r_companycode[ 1 ]-low.
    lo_logo = NEW #( ).
    lo_logo->get_logo( EXPORTING iv_company = lv_company IMPORTING lv_logo = lv_logo ).
    IF lv_logo IS INITIAL.
      lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
    ENDIF.



**  Fill XML
*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lf_data>)
*                               WHERE companycode IS NOT INITIAL AND
*                                     fiscalyear IS NOT INITIAL
*                               GROUP BY ( companycode = <lf_data>-companycode
*                                          fiscalyear  = <lf_data>-fiscalyear ).
*      "Header
*      lv_xml = |<Header>|.
*      lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
*      READ TABLE lt_company ASSIGNING FIELD-SYMBOL(<lf_cmpany>)
*                            WITH KEY companycode = <lf_data>-companycode.
*      IF sy-subrc = 0.
*        lv_xml = lv_xml && |<CompanyCode>{ <lf_cmpany>-tencty_vn }</CompanyCode>|.
*        lv_xml = lv_xml && |<Address>{ <lf_cmpany>-diachi_vn }</Address>|.
*        lv_xml = lv_xml && |<MST>{ <lf_cmpany>-mst }</MST>|.
*      ENDIF.
*
*      READ TABLE lt_postdate ASSIGNING FIELD-SYMBOL(<ls_postdate>)
*                                        WITH KEY companycode = <lf_data>-companycode
*                                                 fiscalyear  = <lf_data>-fiscalyear.
*      IF sy-subrc = 0 AND <ls_postdate> IS ASSIGNED.
*        ls_date_fr = <ls_postdate>-min_postdate.
*        ls_date_to = <ls_postdate>-max_postdate.
*      ENDIF.
*
*      DATA(lv_postingdate) =
*      |Từ ngày { ls_date_fr+6(2) }/{ ls_date_fr+4(2) }/{ ls_date_fr(4) } đến { ls_date_to+6(2) }/{ ls_date_to+4(2) }/{ ls_date_to(4) }|. " hoangtd21
*
*
*
*      lv_xml = lv_xml && |<SubTitle>{ lv_postingdate }</SubTitle>|.
*
*      CLEAR lv_index.
*      lv_xml = lv_xml && |<Data>|.
*      LOOP AT lt_data INTO DATA(lw_item) WHERE companycode = <lf_data>-companycode
*                                           AND fiscalyear  = <lf_data>-fiscalyear .
*        lv_index += 1.
*        lv_xml = lv_xml && |<Item>|.
*
*        lv_xml = lv_xml && |<STT>{ lv_index }</STT>|.
*        lv_xml = lv_xml && |<NgayHachToan>{ format_date( lw_item-postingdate ) }</NgayHachToan>|.
*        lv_xml = lv_xml && |<SoChungTu>{ lw_item-accountingdocument }</SoChungTu>|.
*        lv_xml = lv_xml && |<NgayChungTu>{ format_date( CONV #( lw_item-documentdate ) ) }</NgayChungTu>|.
*        lv_xml = lv_xml && |<DienGiai>{ lw_item-description }</DienGiai>|.
*        lv_xml = lv_xml && |<TKNo>{ lw_item-s_glaccount }</TKNo>|.
*        lv_xml = lv_xml && |<TKCo>{ lw_item-h_glaccount }</TKCo>|.
*        lv_xml = lv_xml && |<No>{ lw_item-s_amount }</No>|.
*        lv_xml = lv_xml && |<Co>{ lw_item-h_amount }</Co>|.
*
*        lv_xml = lv_xml && |</Item>|.
*
*
*
*
*      ENDLOOP.
*      lv_xml = lv_xml && |</Data>|.
*
*      lv_xml = lv_xml && |<NguoiLap>{ me->s_footer-nguoi_lap }</NguoiLap>|.
*      lv_xml = lv_xml && |<KeToan>{ me->s_footer-ke_toan }</KeToan>|.
*      lv_xml = lv_xml && |<GiamDoc>{ me->s_footer-giam_doc }</GiamDoc>|.
*
*      lv_xml = lv_xml && |</Header>|.
*
*      CLEAR: ls_date_fr, ls_date_to.
*
*      DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring(
*                          xco_cp_character=>code_page->utf_8 )->value.
*
*      TRY.
*          cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xstring "lv_xml
*                                                iv_xdp_layout   = ls_template-xdp_template
*                                                iv_locale       = 'de_DE'
*                                                is_options      = VALUE #(
*                                               trace_level = 4 "Use 0 in production environment
*          )
*                                      IMPORTING ev_pdf          = DATA(lv_pdf)
*                                                ev_pages        = DATA(ev_pages)
*                                                ev_trace_string = DATA(ev_trace_string)
*                                               ).
*        CATCH cx_fp_ads_util INTO DATA(lx_error2).
*          DATA(lv_err2) = lx_error2->get_text( ).  " Hoặc ghi log, v.v.
*      ENDTRY.
*
*      READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<ls_header>) WITH KEY companycode = <lf_data>-companycode
*                                                                        fiscalyear  = <lf_data>-fiscalyear.
*      CHECK sy-subrc = 0.
*      <ls_header>-attachment = lv_pdf.
*      <ls_header>-uuid = lv_uuid_fi.
*      <ls_header>-mimetype = 'application/pdf'.
*      <ls_header>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
*
*      <lf_data>-attachment = lv_pdf.
*      <lf_data>-uuid = lv_uuid_fi.
*      <lf_data>-mimetype = 'application/pdf'.
*      <lf_data>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.
*
*
*      lcl_fa_zgl04n_pdf=>save_pdf(
*             iv_objectid = CONV #( lv_uuid_fi )
*             iv_key      = |{ <lf_data>-companycode }{ <lf_data>-fiscalyear }|
*             iv_reportid = 'ZFA_ZGL04'
*             iv_pdf      = lv_pdf
*           ).
*
*
*      CLEAR: lv_pdf, lv_xstring, lv_xml.
*    ENDLOOP.


    "Fill PDF
    DATA: lv_from     TYPE int4,
          lv_to       TYPE int4,
          lv_limit    TYPE int4 VALUE 2000,
          lv_pdf_file TYPE int4,
          lt_alv      TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY.




    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      "Create an instance of the PDF merger class
      DATA(l_merger) = cl_rspo_pdf_merger=>create_instance( ).

      SELECT COUNT( * )
        FROM @lt_data AS lt_data
        WHERE companycode = @<ls_header>-companycode
          AND fiscalyear  = @<ls_header>-fiscalyear
       INTO @DATA(lv_records).

      IF lv_records < lv_limit.
        lv_pdf_file = 1.
      ELSE.
        lv_pdf_file = ceil( lv_records / lv_limit ).
      ENDIF.

      lv_to = lv_limit.
      DO lv_pdf_file TIMES.
        LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lf_data>) FROM lv_from TO lv_to
                                   WHERE companycode = <ls_header>-companycode
                                     AND fiscalyear  = <ls_header>-fiscalyear
                                   GROUP BY ( companycode = <lf_data>-companycode
                                              fiscalyear  = <lf_data>-fiscalyear ).


          "Header
          lv_xml = |<Header>|.
          lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
          READ TABLE lt_company ASSIGNING FIELD-SYMBOL(<lf_cmpany>)
                                WITH KEY companycode = <lf_data>-companycode.
          IF sy-subrc = 0.
            lv_xml = lv_xml && |<CompanyCode>{ <lf_cmpany>-tencty_vn }</CompanyCode>|.
            lv_xml = lv_xml && |<Address>{ <lf_cmpany>-diachi_vn }</Address>|.
            lv_xml = lv_xml && |<MST>{ <lf_cmpany>-mst }</MST>|.
          ENDIF.

          READ TABLE lt_postdate ASSIGNING FIELD-SYMBOL(<ls_postdate>)
                                            WITH KEY companycode = <lf_data>-companycode
                                                     fiscalyear  = <lf_data>-fiscalyear.
          IF sy-subrc = 0 AND <ls_postdate> IS ASSIGNED.
            ls_date_fr = <ls_postdate>-min_postdate.
            ls_date_to = <ls_postdate>-max_postdate.
          ENDIF.

          DATA(lv_postingdate) =
          |Từ ngày { ls_date_fr+6(2) }/{ ls_date_fr+4(2) }/{ ls_date_fr(4) } đến { ls_date_to+6(2) }/{ ls_date_to+4(2) }/{ ls_date_to(4) }|. " hoangtd21



          lv_xml = lv_xml && |<SubTitle>{ lv_postingdate }</SubTitle>|.

          CLEAR lv_index.
          lv_xml = lv_xml && |<Data>|.
          LOOP AT GROUP <lf_data> INTO DATA(lw_item)." WHERE companycode = <lf_data>-companycode  AND fiscalyear  = <lf_data>-fiscalyear .
            lv_index += 1.
            lv_xml = lv_xml && |<Item>|.

            lv_xml = lv_xml && |<STT>{ lv_index }</STT>|.
            lv_xml = lv_xml && |<NgayHachToan>{ format_date( lw_item-postingdate ) }</NgayHachToan>|.
            lv_xml = lv_xml && |<SoChungTu>{ lw_item-accountingdocument }</SoChungTu>|.
            lv_xml = lv_xml && |<NgayChungTu>{ format_date( CONV #( lw_item-documentdate ) ) }</NgayChungTu>|.
            lv_xml = lv_xml && |<DienGiai>{ lw_item-description }</DienGiai>|.
            lv_xml = lv_xml && |<TKNo>{ lw_item-s_glaccount }</TKNo>|.
            lv_xml = lv_xml && |<TKCo>{ lw_item-h_glaccount }</TKCo>|.
            lv_xml = lv_xml && |<No>{ lw_item-s_amount }</No>|.
            lv_xml = lv_xml && |<Co>{ lw_item-h_amount }</Co>|.

            lv_xml = lv_xml && |</Item>|.
          ENDLOOP.

          lv_xml = lv_xml && |</Data>|.
          lv_xml = lv_xml && |<NguoiLap>{ me->s_footer-nguoi_lap }</NguoiLap>|.
          lv_xml = lv_xml && |<KeToan>{ me->s_footer-ke_toan }</KeToan>|.
          lv_xml = lv_xml && |<GiamDoc>{ me->s_footer-giam_doc }</GiamDoc>|.

          lv_xml = lv_xml && |</Header>|.

          CLEAR: ls_date_fr, ls_date_to.

          REPLACE '&' IN lv_xml WITH '&amp;'.

          DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring(
                              xco_cp_character=>code_page->utf_8 )->value.

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
            CATCH cx_fp_ads_util INTO DATA(lx_error3).
              DATA(lv_err3) = lx_error3->get_text( ).  " Hoặc ghi log, v.v.
          ENDTRY.

          " Add the data of the first PDF document to the list of files which shall be merged
          IF lv_err3 IS INITIAL.
            l_merger->add_document( lv_pdf ).
          ENDIF.
          CLEAR: lv_pdf, lv_xml, lv_xstring, lv_err3.
        ENDLOOP.
        lv_from = lv_to + 1.
        lv_to += lv_limit.
      ENDDO.

      TRY.
          DATA(lv_uuid) = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version(
                                            version = 4 ).
        CATCH cx_uuid_error.
          CLEAR lv_uuid.
      ENDTRY.
      TRY.
          " Merge both documents and receive the result
          DATA(l_merged_pdf) = l_merger->merge_documents( ).
          ##no_handler
        CATCH cx_rspo_pdf_merger INTO DATA(l_exception).
*          CLEAR l_merged_pdf.
      ENDTRY.

      <ls_header>-attachment = l_merged_pdf.
      <ls_header>-uuid = lv_uuid.
      <ls_header>-mimetype = 'application/pdf'.
      <ls_header>-filename = |{ cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( )  }.pdf|.

      lcl_fa_zgl04n_pdf=>save_pdf(
             iv_objectid = CONV #( lv_uuid )
             iv_key      = |{ <ls_header>-companycode }{ <ls_header>-fiscalyear }|
             iv_reportid = 'ZFA_ZGL04'
             iv_pdf      = l_merged_pdf
           ).

      CLEAR: lv_pdf_file, l_merged_pdf, lv_uuid,
             lv_from, lv_to, l_merger.
    ENDLOOP.



*** Excel File
    DATA: lt_excel TYPE tt_excel.
    DATA: lt_item TYPE gtt_item.
    DATA: lv_excel  TYPE zde_attachment_tmpl.
    DATA : lv_filename TYPE string.
    DATA: lv_mimetype TYPE string.
    MOVE-CORRESPONDING lt_data TO lt_item.
    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<lfs_item>).
      <lfs_item>-stt = sy-tabix.
      <lfs_item>-s_amount = <lfs_item>-s_amount * 100.
      <lfs_item>-h_amount = <lfs_item>-h_amount * 100.
      " format ngày
      <lfs_item>-postingdate =
        |{ <lfs_item>-postingdate+6(2) }.{ <lfs_item>-postingdate+4(2) }.{ <lfs_item>-postingdate(4) }|.

      <lfs_item>-documentdate =
        |{ <lfs_item>-documentdate+6(2) }.{ <lfs_item>-documentdate+4(2) }.{ <lfs_item>-documentdate(4) }|.
    ENDLOOP.
    APPEND VALUE #(
         h_company_name  = lt_company[ 1 ]-tencty_vn
         h_company_add   = lt_company[ 1 ]-diachi_vn
         h_company_mst   = lt_company[ 1 ]-mst
         h_title         = 'SỔ NHẬT KÝ CHUNG'
         h_title_subtitle  = lv_postingdate
         i_title_stt = 'STT nhóm'
         i_title_ngayhachtoan = 'Ngày hạch toán'
         i_title_chungtu = 'Chứng từ'
         i_title_sochungtu = 'Số chứng từ'
         i_title_ngaychungtu = 'Ngày chứng từ'
         i_title_diengiai = 'Diễn giải'
         i_title_taikhoanno = 'Tài khoản nợ'
         i_title_taikhoanco = 'Tài khoản có'
         i_title_novnd = 'Nợ VNĐ'
         i_title_covnd = 'Có VNĐ'
         item                 = lt_item
         f_ngaythangnam = 'Ngày .... tháng .... năm ...'
         f_kyten = '(Ký, họ tên)'
         f_title_nguoilap = 'Người lập'
         f_title_ketoantruong = 'Kế toán'
         f_title_tonggiamdoc = 'Giám đốc'
         f_nguoilap = me->s_footer-nguoi_lap
         f_ketoantruong = me->s_footer-ke_toan
         f_tonggiamdoc = me->s_footer-giam_doc


    ) TO lt_excel.

    me->create_excel(
      EXPORTING
        i_data     =  lt_excel
      IMPORTING
        e_excel    = lv_excel
        e_filename = lv_filename
        e_mimetype = lv_mimetype
    ).
    LOOP AT lt_header ASSIGNING <lfs_header>.
      <lfs_header>-attachment_exc = lv_excel.
      <lfs_header>-filename_exc = lv_filename.
      <lfs_header>-mimetype_exc = lv_mimetype.
    ENDLOOP.
*** SET response
    io_response->set_data( lt_header ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_header ) ).
    ENDIF.
  ENDMETHOD.


  METHOD set_selscreen.
    LOOP AT it_filter INTO DATA(lw_filter).
      CHECK lw_filter-range IS NOT INITIAL.
      CASE lw_filter-name.
        WHEN 'COMPANYCODE'.
          r_companycode = lw_filter-range.

        WHEN 'POSTINGDATE'.
          r_postingdate = lw_filter-range.
          DELETE r_postingdate WHERE low EQ '00000000' AND high EQ '00000000'.


        WHEN 'FISCALYEAR'. "Mandatory - Single
          r_fiscalyear = lw_filter-range.

        WHEN 'INCL_RESERVE'.
          DATA(lr_incl_reserve) = lw_filter-range.
          cb_incl_reversed = lr_incl_reserve[ 1 ]-low.

        WHEN 'UUID'.
          r_uuid = lw_filter-range.

        WHEN 'NGUOI_LAP'.
          s_footer-nguoi_lap = lw_filter-range[ 1 ]-low.

        WHEN 'KE_TOAN'.
          s_footer-ke_toan = lw_filter-range[ 1 ]-low.

        WHEN 'GIAM_DOC'.
          s_footer-giam_doc = lw_filter-range[ 1 ]-low.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_data.
    DATA: lw_data TYPE zr_fa_zgl04n,
          lt_data TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY,
          lt_tmp  TYPE STANDARD TABLE OF zr_fa_zgl04n WITH DEFAULT KEY.

** Get header
    SELECT header~companycode,
           header~fiscalyear,
           header~accountingdocument,
           header~postingdate,
           header~documentdate,
           header~isreversed,
           header~reversedocument,
           @me->s_footer-nguoi_lap AS nguoi_lap,
           @me->s_footer-ke_toan   AS ke_toan,
           @me->s_footer-giam_doc  AS giam_doc,
           header~accountingdocumentheadertext
      FROM i_journalentry AS header
      WHERE header~fiscalyear  IN @me->r_fiscalyear
        AND header~postingdate IN @me->r_postingdate
        AND header~companycode IN @me->r_companycode
      ORDER BY header~companycode,
               header~fiscalyear,
               header~accountingdocument,
               header~postingdate
     INTO TABLE @DATA(lt_header).
*        UP TO @i_top ROWS
*        OFFSET @i_skip .

    et_header = CORRESPONDING #( lt_header ).


*    lt_tmp = CORRESPONDING #( lt_header ).
*    APPEND LINES OF lt_tmp FROM i_skip + 1 TO i_skip + i_top TO et_header.


    SELECT
         header~companycode,
         header~fiscalyear,
         header~accountingdocument,
         header~postingdate,
         header~documentdate,
         header~isreversed,
         header~reversedocument,
         item~ledgergllineitem AS item," hoangtd21
*         coalesce( item~documentitemtext,
*                  header~accountingdocumentheadertext )
*                AS description,
          CASE WHEN item~documentitemtext IS NOT INITIAL
          THEN item~documentitemtext
          ELSE header~accountingdocumentheadertext
          END AS description, " hoangtd21
         CASE WHEN item~debitcreditcode = 'S'
              THEN item~glaccount
              END AS s_glaccount,
         CASE WHEN item~debitcreditcode = 'H'
              THEN item~glaccount
              END AS h_glaccount,
         CASE WHEN item~debitcreditcode = 'S'
              THEN item~debitamountincocodecrcy
              END AS s_amount,
         CASE WHEN item~debitcreditcode = 'H'
              THEN item~creditamountincocodecrcy
              END AS h_amount,
         @me->s_footer-nguoi_lap AS nguoi_lap,
         @me->s_footer-ke_toan   AS ke_toan,
         @me->s_footer-giam_doc  AS giam_doc
       FROM @lt_header AS header
       INNER JOIN i_journalentryitem AS item
               ON item~companycode = header~companycode
              AND item~fiscalyear  = header~fiscalyear
              AND item~accountingdocument  = header~accountingdocument
      WHERE item~ledger = '0L'
        AND header~fiscalyear  IN @me->r_fiscalyear
        AND header~postingdate IN @me->r_postingdate
        AND header~companycode IN @me->r_companycode
     ORDER BY header~companycode,
              header~fiscalyear,
              header~accountingdocument,
              item~ledgergllineitem, " hoangtd21
              header~postingdate
         INTO TABLE @DATA(lt_origindoc).

*   Get Reversal Document
    SELECT
        header~companycode,
        header~fiscalyear,
        header~accountingdocument,
        header~postingdate,
        header~documentdate,
        header~isreversed,
        header~reversedocument,
        item~ledgergllineitem AS item, "hoangtd21
*        coalesce( item~documentitemtext,
*                  header~accountingdocumentheadertext )
*                AS description,
          CASE WHEN item~documentitemtext IS NOT INITIAL
          THEN item~documentitemtext
          ELSE header~accountingdocumentheadertext
          END AS description, " hoangtd21
        CASE WHEN item~debitcreditcode = 'S'
             THEN item~glaccount
             END AS s_glaccount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~glaccount
             END AS h_glaccount,
        CASE WHEN item~debitcreditcode = 'S'
             THEN item~debitamountincocodecrcy
             END AS s_amount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~creditamountincocodecrcy
             END AS h_amount,
        @me->s_footer-nguoi_lap AS nguoi_lap,
        @me->s_footer-ke_toan   AS ke_toan,
        @me->s_footer-giam_doc  AS giam_doc
      FROM @lt_origindoc AS origindoc
      LEFT JOIN
       ( i_journalentry AS header INNER JOIN i_journalentryitem AS item
           ON item~companycode = header~companycode
          AND item~fiscalyear  = header~fiscalyear
          AND item~accountingdocument = header~accountingdocument
       )   ON header~companycode      = origindoc~companycode
          AND header~reversedocument  = origindoc~accountingdocument
      WHERE  item~ledger = '0L'
        AND origindoc~isreversed = 'X'
        AND header~companycode IN @me->r_companycode
        AND header~postingdate IN @me->r_postingdate
        AND header~isreversal = 'X'
    INTO TABLE @DATA(lt_reversaldoc).



**  Checkbox Include Reversed
    IF cb_incl_reversed = abap_false AND lt_reversaldoc IS NOT INITIAL.
      "Hiển thị chứng từ reversed khác kỳ
      LOOP AT lt_origindoc ASSIGNING FIELD-SYMBOL(<lf_origin>)
                               WHERE isreversed IS NOT INITIAL.
        READ TABLE lt_reversaldoc ASSIGNING FIELD-SYMBOL(<lf_reversal>)
           WITH KEY accountingdocument = <lf_origin>-reversedocument.
        IF sy-subrc = 0 AND ( <lf_reversal>-fiscalyear <> <lf_origin>-fiscalyear
                         OR   <lf_reversal>-postingdate+4(2) <> <lf_origin>-postingdate+4(2) ).

          lw_data = CORRESPONDING #(  <lf_reversal>  ).
          APPEND lw_data TO lt_data. CLEAR lw_data.
        ENDIF.

        lw_data = CORRESPONDING #(  <lf_origin> ).
        APPEND lw_data TO lt_data. CLEAR lw_data.
      ENDLOOP.

      "Get Normal Origin Document
      DELETE lt_origindoc WHERE isreversed IS NOT INITIAL.
      lt_tmp =  CORRESPONDING #( lt_origindoc ).
      APPEND LINES OF lt_tmp TO lt_data.
      CLEAR lt_tmp.


    ELSE.
      APPEND LINES OF lt_reversaldoc TO lt_origindoc.
      lt_data = CORRESPONDING #( lt_origindoc ).
    ENDIF.

*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>)
*                                 GROUP BY ( companycode = <ls_data>-companycode
*                                            fiscalyear  = <ls_data>-fiscalyear
*                                            accountingdocument = <ls_data>-accountingdocument
*                                            postingdate = <ls_data>-postingdate
*                                            s_glaccount = <ls_data>-s_glaccount
*                                            h_glaccount = <ls_data>-h_glaccount  ).
*      CLEAR lw_data.
*      lw_data = CORRESPONDING #( <ls_data> EXCEPT s_amount h_amount ).
*      LOOP AT GROUP  <ls_data> ASSIGNING FIELD-SYMBOL(<lf_group>).
*        lw_data-s_amount += <lf_group>-s_amount.
*        lw_data-h_amount += <lf_group>-h_amount.
*      ENDLOOP.
*      APPEND lw_data TO rt_data.
*    ENDLOOP.
    rt_data = CORRESPONDING #( lt_data ). " test hoangtd21
    SORT rt_data BY companycode fiscalyear postingdate accountingdocument item.


  ENDMETHOD.


  METHOD create_excel.
    DATA: lo_excel    TYPE REF TO zcl_export_excel_xlsx,
          lv_report   TYPE char72 VALUE 'ZGL04',
          lv_template TYPE char72 VALUE 'ZGL04_EXC',
          lv_filename TYPE string VALUE 'ZGL04.xlsx',
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
