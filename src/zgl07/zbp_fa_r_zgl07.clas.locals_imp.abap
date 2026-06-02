CLASS lhc_zgl07 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zgl07 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zgl07 RESULT result.

    METHODS printpdf FOR MODIFY
      IMPORTING keys FOR ACTION zgl07~printpdf RESULT result.

ENDCLASS.

CLASS lhc_zgl07 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD printpdf.
    TYPES: BEGIN OF lty_item,
             stt        TYPE string,
             doituong   TYPE string,
             noidung    TYPE string,
             taikhoanco TYPE string,
             taikhoanno TYPE string,
             thanhtien  TYPE i_journalentryitem-debitamountinbalancetranscrcy,
           END OF lty_item.
    DATA : lt_item TYPE TABLE OF lty_item.
    DATA: ls_item TYPE lty_item.
    DATA: lv_stt TYPE i VALUE '1'.
    DATA lt_create TYPE TABLE FOR CREATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA lt_update TYPE TABLE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA: lv_xml TYPE string.
    DATA: lv_total_thanhtien TYPE i_journalentryitem-debitamountinbalancetranscrcy.
    DATA: lv_total_thanhtien_debit TYPE i_journalentryitem-debitamountinbalancetranscrcy.
    DATA: lv_total_thanhtien_credit TYPE i_journalentryitem-debitamountinbalancetranscrcy.
    DATA : lv_object TYPE string.
    READ ENTITIES OF zfa_r_zgl07 IN LOCAL MODE
    ENTITY zgl07
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).
    IF lt_header IS NOT INITIAL.
      DATA(ls_header) = lt_header[ 1 ].
    ENDIF.
    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_service_instance_name   = 'ZADSTEMPLSTORE'
             iv_use_destination_service = abap_false
            ).

*        DATA(ls_template) = lo_store->get_template_by_name(
*          iv_get_binary    = abap_true
*          iv_form_name     = 'ZFA_F_GL07'
*          iv_template_name = 'ZFA_F_GL07'
*        ).
        DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZGL07' ).
      CATCH cx_root INTO DATA(lx_error)  ##NO_HANDLER.
        " Handle error
    ENDTRY.



    SELECT
        item_kd~companycode,
        item_kd~fiscalyear,
        item_kd~accountingdocument,
        item_kd~accountingdocumentitem,
        item_kd~ledgergllineitem,
        item_kd~financialaccounttype,
        bp~isonetimeaccount AS ota,
       CASE  WHEN ota_sup~businesspartnername1 IS NOT INITIAL THEN
    concat_with_space( ota_sup~businesspartnername1,
    concat_with_space( ota_sup~businesspartnername2,
    concat_with_space( ota_sup~businesspartnername3, ota_sup~businesspartnername4, 1 ), 1 ) ,1 )
     ELSE bp~name  END                                                AS customername,
*        case when ota_cust~BusinessPartnerName1 is not iNITIAL then
*    concat_with_space( ota_cust~businesspartnername1,
*    concat_with_space( ota_cust~businesspartnername2,
*    concat_with_space( ota_cust~businesspartnername3, ota_cust~businesspartnername4, 1 ), 1 ) ,1 )
*     ELSE bp~name  END                                                AS customername,
       bp_profile~organizationbpname1,
        bp_profile~organizationbpname2,
        bp_profile~organizationbpname3,
        bp_profile~organizationbpname4,
bp~isonetimeaccount,
bp~name,
    item_kd~product,
    product~productname,
    item_kd~masterfixedasset,
    asset~fixedassetdescription,
    item_kd~documentitemtext,
    item_kd~glaccount,
    item_kd~debitcreditcode,

    item_kd~debitamountintranscrcy  AS amount_debit,

    item_kd~creditamountintranscrcy  AS amount_credit,
     item_kd~costcenter,
     cost~costcentername,
     item_kd~profitcenter,
    profit~profitcentername,
    ota_sup~businesspartnername1,
    CASE WHEN
        item_kd~customer IS NOT INITIAL
        THEN item_kd~customer ELSE item_kd~supplier
        END AS customer
    FROM i_journalentry AS header_kd
    INNER JOIN i_journalentryitem AS item_kd ON item_kd~accountingdocument = header_kd~accountingdocument
                                            AND item_kd~companycode = header_kd~companycode
*    INNER JOIN i_operationalacctgdocitem AS item_kd ON item_kd~accountingdocument = header_kd~accountingdocument
                                                AND item_kd~companycode       = header_kd~companycode
                                                AND item_kd~fiscalyear             = header_kd~fiscalyear
*    LEFT JOIN i_onetimeaccountsupplier AS ota_sup ON ota_sup~accountingdocument = item_kd~accountingdocument
    LEFT JOIN zi_view_fi_ota AS ota_sup ON ota_sup~accountingdocument = header_kd~accountingdocument
                                                AND ota_sup~companycode       = header_kd~companycode
                                                AND ota_sup~fiscalyear             = header_kd~fiscalyear
*                                                AND ota_sup~accountingdocumentitem = item_kd~accountingdocumentitem
    LEFT JOIN zcds_bp_profile AS bp ON ( bp~businesspartner = item_kd~supplier OR bp~businesspartner = item_kd~customer )
    LEFT JOIN i_producttext AS product ON product~product = item_kd~product AND product~language = 'E'
    LEFT JOIN i_fixedasset AS asset ON item_kd~fixedasset = asset~fixedasset
    AND asset~masterfixedasset = item_kd~masterfixedasset
    AND asset~companycode = header_kd~companycode
*    and asset~AssetClass = item_kd~assetclass
    LEFT JOIN i_profitcentertext AS profit ON profit~profitcenter = item_kd~profitcenter
    LEFT JOIN i_costcentertext AS cost ON cost~costcenter = item_kd~costcenter
     LEFT JOIN i_businesspartner AS bp_profile ON ( bp_profile~businesspartner = item_kd~customer OR bp_profile~businesspartner = item_kd~supplier )
*    leFT jOIN I_JournalEntryItemOneTimeData as ota_cust on ota_cust~AccountingDocument = item_kd~accountingdocument
*    and  ota_cust~AccountingDocumentItem = item_kd~AccountingDocumentItem
    WHERE header_kd~accountingdocument = @ls_header-journalentry
    AND item_kd~ledger = '0L'
    AND header_kd~companycode = @ls_header-companycode
    INTO TABLE @DATA(lt_items).
    SORT lt_items BY customer DESCENDING.

    IF lt_items IS INITIAL.

      SELECT
          item_kd~companycode,
          item_kd~fiscalyear,
          item_kd~accountingdocument,
          item_kd~accountingdocumentitem,
          item_kd~ledgergllineitem,
          item_kd~financialaccounttype,
          bp~isonetimeaccount AS ota,
         CASE  WHEN bp~isonetimeaccount IS NOT INITIAL THEN
      concat_with_space( ota_sup~businesspartnername1,
      concat_with_space( ota_sup~businesspartnername2,
      concat_with_space( ota_sup~businesspartnername3, ota_sup~businesspartnername4, 1 ), 1 ) ,1 )
       ELSE bp~name  END                                                AS customername,
       bp_profile~organizationbpname1,
        bp_profile~organizationbpname2,
        bp_profile~organizationbpname3,
        bp_profile~organizationbpname4,
        bp~isonetimeaccount,
        bp~name,
      item_kd~product,
      product~productname,
      item_kd~fixedasset,
      asset~fixedassetdescription,
      item_kd~documentitemtext,
      item_kd~glaccount,
      item_kd~debitcreditcode,
      CASE WHEN item_kd~debitcreditcode = 'S' THEN
      item_kd~amountincompanycodecurrency END AS amount_debit,
      CASE WHEN item_kd~debitcreditcode = 'H' THEN
      item_kd~amountincompanycodecurrency END AS amount_credit,
           item_kd~costcenter,
     cost~costcentername,
     item_kd~profitcenter,
    profit~profitcentername,
      CASE WHEN
          item_kd~customer IS NOT INITIAL
          THEN item_kd~customer ELSE item_kd~supplier
          END AS customer
      FROM i_journalentry AS header_kd
*    INNER JOIN i_journalentryitem AS item_kd ON item_kd~accountingdocument = header_kd~accountingdocument
      INNER JOIN i_operationalacctgdocitem AS item_kd ON item_kd~accountingdocument = header_kd~accountingdocument
                                                  AND item_kd~companycode       = header_kd~companycode
                                                  AND item_kd~fiscalyear             = header_kd~fiscalyear
      LEFT JOIN i_onetimeaccountsupplier AS ota_sup ON ota_sup~accountingdocument = item_kd~accountingdocument
                                                  AND ota_sup~companycode       = item_kd~companycode
                                                  AND ota_sup~fiscalyear             = item_kd~fiscalyear
                                                  AND ota_sup~accountingdocumentitem = item_kd~accountingdocumentitem
      LEFT JOIN i_businesspartner AS bp_profile ON ( bp_profile~businesspartner = item_kd~customer OR bp_profile~businesspartner = item_kd~supplier )
      LEFT JOIN zcds_bp_profile AS bp ON ( bp~businesspartner = item_kd~supplier OR bp~businesspartner = item_kd~customer )
      LEFT JOIN i_producttext AS product ON product~product = item_kd~product AND product~language = 'E'
      LEFT JOIN i_fixedasset AS asset ON item_kd~fixedasset = asset~fixedasset
      AND asset~masterfixedasset = item_kd~masterfixedasset
*    and asset~AssetClass = item_kd~assetclass
    LEFT JOIN i_profitcentertext AS profit ON profit~profitcenter = item_kd~profitcenter
    LEFT JOIN i_costcentertext AS cost ON cost~costcenter = item_kd~costcenter
      WHERE header_kd~accountingdocument = @ls_header-journalentry
      AND header_kd~companycode = @ls_header-companycode
*    AND item_kd~ledger = '0L'
      INTO TABLE @lt_items.
      SORT lt_items BY customer DESCENDING.
    ENDIF.
*    DELETE ADJACENT DUPLICATES FROM lt_items COMPARING accountingdocument accountingdocumentitem ledgergllineitem.
    DATA: lv_doituong_ota TYPE string.
    LOOP AT lt_items INTO DATA(ls_items).
*      ls_item-stt = lv_stt.
      IF ls_items-financialaccounttype EQ 'D' OR ls_items-financialaccounttype EQ 'K'.
        IF ls_items-businesspartnername1 IS NOT INITIAL.
          lv_object = ls_items-customer.
          SHIFT lv_object LEFT DELETING LEADING '0'.
          ls_item-doituong = |{ lv_object }-{ ls_items-customername }|.
          lv_doituong_ota = ls_item-doituong.
        ELSE.
          lv_object = ls_items-customer.
          SHIFT lv_object LEFT DELETING LEADING '0'.
          ls_item-doituong = |{ lv_object }-{ ls_items-organizationbpname1 } { ls_items-organizationbpname2 } { ls_items-organizationbpname3 } { ls_items-organizationbpname4 }|.
        ENDIF.
      ELSEIF ls_items-financialaccounttype EQ 'M'.
        lv_object = ls_items-product.
        SHIFT lv_object LEFT DELETING LEADING '0'.
        ls_item-doituong = |{ lv_object }-{ ls_items-productname }|.
      ELSEIF ls_items-financialaccounttype EQ 'A'.
        lv_object = ls_items-masterfixedasset.
        SHIFT lv_object LEFT DELETING LEADING '0'.
        ls_item-doituong = |{ lv_object }-{ ls_items-fixedassetdescription }|.
      ELSEIF ls_items-financialaccounttype EQ 'S'.
        lv_object = ls_items-costcenter.
        SHIFT lv_object LEFT DELETING LEADING '0'.
        IF lv_object IS INITIAL.
          lv_object = ls_items-profitcenter.
          SHIFT lv_object LEFT DELETING LEADING '0'.
          ls_item-doituong = |{ lv_object }-{ ls_items-profitcentername }|.
        ELSE.
          ls_item-doituong = |{ lv_object }-{ ls_items-costcentername }|.
        ENDIF.

      ENDIF.

      IF lv_doituong_ota IS NOT INITIAL.
        ls_item-doituong = lv_doituong_ota.
      ELSE.
        IF lv_object IS NOT INITIAL.
          DATA(lv_doituong) = ls_item-doituong.
        ELSE.
          ls_item-doituong = lv_doituong .
        ENDIF.
      ENDIF.
      ls_item-noidung = ls_items-documentitemtext.
      IF ls_item-noidung IS INITIAL.
        ls_item-noidung = ls_header-documentheadertext.
      ENDIF.

      IF ls_items-debitcreditcode = 'S'.
        ls_item-taikhoanno = ls_items-glaccount.
        IF ls_items-amount_debit < 0.
          ls_item-thanhtien = ls_items-amount_debit * ( -1 ).
        ELSE.
          ls_item-thanhtien = ls_items-amount_debit.
        ENDIF.
        lv_total_thanhtien_debit = lv_total_thanhtien_debit + ls_item-thanhtien.
      ELSE.
        ls_item-taikhoanco = ls_items-glaccount.
        IF ls_items-amount_credit < 0.
          ls_item-thanhtien = ls_items-amount_credit * ( -1 ).
        ELSE.
          ls_item-thanhtien = ls_items-amount_credit.
        ENDIF.
        lv_total_thanhtien_credit = lv_total_thanhtien_credit + ls_item-thanhtien..
      ENDIF.
      IF  ls_item-taikhoanno CP '133*' OR  ls_item-taikhoanco CP '133*'
      OR ls_item-taikhoanno CP '333*' OR  ls_item-taikhoanco CP '333*'.
        CLEAR ls_item-doituong.
      ENDIF.
      APPEND ls_item TO lt_item.
      CLEAR ls_item.
*      lv_stt += 1.
    ENDLOOP.
    IF lv_total_thanhtien_debit IS NOT INITIAL.
      lv_total_thanhtien = lv_total_thanhtien_debit.
    ELSE.
      lv_total_thanhtien = lv_total_thanhtien_credit.
    ENDIF.
    SORT lt_item BY taikhoanno DESCENDING .
    "get logo
    DATA: lo_logo       TYPE REF TO zcl_get_logo_company.
    DATA: lv_logo TYPE string.
    DATA: lv_company TYPE c LENGTH 4.
    lv_company = ls_header-CompanyCode.
    lo_logo = NEW #( ).
    lo_logo->get_logo( EXPORTING iv_company = lv_company IMPORTING lv_logo = lv_logo ).
    IF lv_logo IS INITIAL.
      lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
    ENDIF.


    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      lv_xml = |<zgl07>|.
      lv_xml = lv_xml && |<Logo>{ lv_logo }</Logo>|.
      lv_xml = |{ lv_xml }<ten_cong_ty>{ <ls_header>-tencongty }</ten_cong_ty>|.
      lv_xml = |{ lv_xml }<dia_chi_cong_ty>{ <ls_header>-diachicongty }</dia_chi_cong_ty>|.
      DATA(lv_mst) = |Mã số thuế: { <ls_header>-masothue }|.
      lv_xml = |{ lv_xml }<ma_so_thue>{ lv_mst }</ma_so_thue>|.
      lv_xml = |{ lv_xml }<loai_chung_tu>{ <ls_header>-journalentrytype }</loai_chung_tu>|.
      lv_xml = |{ lv_xml }<so_chung_tu>{ <ls_header>-journalentry }</so_chung_tu>|.
      DATA(lv_ngay_chung_tu) = |{ <ls_header>-entrydate+6(2) }.{ <ls_header>-entrydate+4(2) }.{ <ls_header>-entrydate+0(4) }|.
      DATA(lv_ngay_hach_toan) = |{ <ls_header>-postingdate+6(2) }.{ <ls_header>-postingdate+4(2) }.{ <ls_header>-postingdate+0(4) }|.
      DATA(lv_ngay_chung_tu_text) = |Ngày { <ls_header>-entrydate+6(2) } tháng { <ls_header>-entrydate+4(2) } năm { <ls_header>-entrydate+0(4) }|.
      lv_xml = |{ lv_xml }<ngay_chung_tu>{ lv_ngay_chung_tu }</ngay_chung_tu>|.
      lv_xml = |{ lv_xml }<ngay_hach_toan>{ lv_ngay_hach_toan }</ngay_hach_toan>|.
      lv_xml = |{ lv_xml }<don_vi_tinh>{ <ls_header>-donvitinh }</don_vi_tinh>|.
      LOOP AT lt_item INTO ls_item.
        ls_item-stt = lv_stt.
        lv_xml = lv_xml && |<item>|.
        lv_xml = lv_xml && |<stt>{ ls_item-stt }</stt>|.
        lv_xml = lv_xml && |<doituong>{ ls_item-doituong }</doituong>|.
        lv_xml = lv_xml && |<taikhoanco>{ ls_item-taikhoanco }</taikhoanco>|.
        lv_xml = lv_xml && |<taikhoanno>{ ls_item-taikhoanno }</taikhoanno>|.
        lv_xml = lv_xml && |<noidung>{ ls_item-noidung }</noidung>|.
        lv_xml = lv_xml && |<thanhtien>{ ls_item-thanhtien }</thanhtien>|.
        " Close item tag
        lv_xml = lv_xml && '</item>'.
        lv_stt += 1.
      ENDLOOP.
      lv_xml = |{ lv_xml }<tong_thanhtien>{ lv_total_thanhtien }</tong_thanhtien>|.
      GET TIME STAMP FIELD DATA(lv_timestamp) .
      CONVERT TIME STAMP lv_timestamp TIME ZONE 'UTC+7' INTO DATE DATA(lv_current_date).
      CONVERT TIME STAMP lv_timestamp TIME ZONE 'UTC+7' INTO TIME DATA(lv_current_time).


*      DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
      DATA(lv_current_date_text) = lv_current_date+6(2) && '.' && lv_current_date+4(2) && '.' && lv_current_date+0(4).
*      DATA(lv_current_time) = cl_abap_context_info=>get_system_time( ).
      DATA(lv_current_time_text) = |{ lv_current_time+0(2) }:{ lv_current_time+2(2) }:{ lv_current_time+4(2) }|.
      DATA(lv_user) = cl_abap_context_info=>get_user_alias( ).
      DATA(lv_footer) = |Printed: { lv_current_time_text } Ngày: { lv_current_date_text } - User: { lv_user }|.
      lv_xml = |{ lv_xml }<ngay_thang_nam>{ lv_ngay_chung_tu_text }</ngay_thang_nam>|.
      lv_xml = |{ lv_xml }<nguoi_lap_phieu>{ keys[ 1 ]-%param-nguoi_lap_phieu }</nguoi_lap_phieu>|.
      lv_xml = |{ lv_xml }<ke_toan>{ keys[ 1 ]-%param-ke_toan }</ke_toan>|.
      lv_xml = |{ lv_xml }<giam_doc>{ keys[ 1 ]-%param-giam_doc }</giam_doc>|.
      lv_xml = |{ lv_xml }<footer>{ lv_footer }</footer>|.
      lv_xml = |{ lv_xml }</zgl07>|.

      DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.

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
        CATCH cx_fp_ads_util INTO DATA(lw_err_ads).
          DATA(lv_err) = lw_err_ads->get_text( ).
          " Handle error
      ENDTRY.
      IF lv_err IS INITIAL.
        SELECT SINGLE
         1
         FROM ztb_fi_pdf_draf
         WHERE object_id = concat( @ls_header-journalentry , @ls_header-companycode )
         AND report_id = 'ZFA_ZGL07'
         INTO @DATA(lv_check).
        IF lv_check IS INITIAL.
          lt_create = VALUE #( ( attachment = lv_pdf
                                        reportid = 'ZFA_ZGL07'
                                        mimetype = 'application/pdf'
                                        filename = |{ <ls_header>-journalentry }_{ lv_current_date }.pdf|
                                        objectid = |{ <ls_header>-journalentry }{ <ls_header>-companycode }|
                                          ) ).
        ELSE.
          lt_update =  VALUE #( ( attachment = lv_pdf
                                      reportid = 'ZFA_ZGL07'
                                      mimetype = 'application/pdf'
                                      filename = |{ <ls_header>-journalentry }_{ lv_current_date }.pdf|
                                      objectid = |{ <ls_header>-journalentry }{ <ls_header>-companycode }|
                                        ) ).
        ENDIF.

      ENDIF.
    ENDLOOP.
    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zr_tb_fi_pdf_draf
          ENTITY zrtbfipdfdraf
          CREATE  FIELDS ( reportid objectid attachment filename mimetype   )
          AUTO FILL CID WITH lt_create
          REPORTED DATA(reported_pdf_cre)
          FAILED DATA(failed_pdf_cre)
          MAPPED DATA(mapped_pdf_cre).
    ENDIF.
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_tb_fi_pdf_draf
        ENTITY zrtbfipdfdraf
        UPDATE
        FIELDS (
                        attachment
                        filename
                        mimetype
         ) WITH lt_update
        REPORTED DATA(reported_pdf_update)
        FAILED DATA(failed_pdf_update)
        MAPPED DATA(mapped_pdf_update).
    ENDIF.



  ENDMETHOD.

ENDCLASS.
