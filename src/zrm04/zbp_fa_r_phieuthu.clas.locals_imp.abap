CLASS lhc_zfa_r_phieuthu DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zfa_r_phieuthu RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfa_r_phieuthu RESULT result.

    METHODS printpdf FOR MODIFY
      IMPORTING keys FOR ACTION zfa_r_phieuthu~printpdf RESULT result.
          METHODS getdefaultsforsign FOR READ
      IMPORTING keys FOR FUNCTION zfa_r_phieuthu~GetDefaultsForSign RESULT result.
ENDCLASS.

CLASS lhc_zfa_r_phieuthu IMPLEMENTATION.

  METHOD get_instance_features.
 ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD printpdf.


    READ ENTITIES OF zfa_r_phieuthu IN LOCAL MODE
     ENTITY zfa_r_phieuthu
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_phieuthu)
     FAILED failed.
    DATA: lv_xml TYPE string.
     DATA: lv_xml1 TYPE string.
    DATA: lv_amountasword TYPE string.
    DATA: lv_date TYPE string.
    DATA: lv_num TYPE i.
    DATA: lv_number TYPE zde_amount,
          lv_word   TYPE string,
          lv_curr   TYPE i.
          TRY.
    DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
iv_service_instance_name   = 'ZADSTEMPLSTORE'
iv_use_destination_service = abap_false
).

    DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZRM04' ).
          ##no_handler
    CATCH ZCX_FP_TMPL_STORE_ERROR INTO DATA(lx_error).
data(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.
    "get parameter===============================
    DATA(lt_keys) = keys.
    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>) INDEX 1.


    DATA update TYPE TABLE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA lt_update TYPE TABLE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA ls_update TYPE STRUCTURE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.

    DATA lt_create TYPE TABLE FOR CREATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA ls_create TYPE STRUCTURE FOR CREATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    TYPES: BEGIN OF ty_wrapper,
             ZFA_C_PHIEUTHU_01 TYPE zfa_r_phieuthu,
           END OF ty_wrapper.
           DATA: ls_wrap  TYPE ty_wrapper.
    LOOP AT lt_phieuthu INTO DATA(ls_xml).
*    if ls_xml-curency = 'VND'.
*    lv_number = abs( ls_xml-amountdebit * 100 ).
*    ELSE.
*      lv_number = abs( ls_xml-amountdebit ).
*ENDIF.
*      lv_number = lv_number .
*      zcl_convert_amount_to_word=>read_raw(
*        EXPORTING
*          lv_number = lv_number
*        CHANGING
*          lv_word   = lv_word ).\
IF ls_xml-curency = 'VND'.
     zcl_convert_amount_to_word=>excute(
        EXPORTING
          iv_amount   = CONV #( ls_xml-amountdebit )
          iv_currency = CONV #( ls_xml-curency )
          iv_rate     = 100
          iv_langu = 'VI'
        RECEIVING
          rv_text     = lv_word
      ).
ELSE.
     zcl_convert_amount_to_word=>excute(
        EXPORTING
          iv_amount   = CONV #( ls_xml-amountdebit )
          iv_currency = CONV #( ls_xml-curency )
          iv_rate     = 1
          iv_langu = 'VI'
        RECEIVING
          rv_text     = lv_word
      ).
ENDIF.
      lv_amountasword = lv_word.
 ##NO_TEXT     lv_date = |Ngày { ls_xml-postingdate+6(2) } tháng { ls_xml-postingdate+4(2) } Năm { ls_xml-postingdate+0(4) }|.
      lv_xml = |<ZFA_C_PHIEUTHU_01>|.
      lv_xml = |{ lv_xml }<OBJECT>{ ls_xml-object }</OBJECT>|.
      lv_xml = |{ lv_xml }<ACCOUNTINGDOCUMENT>{ ls_xml-accountingdocument }</ACCOUNTINGDOCUMENT>|.
      lv_xml = |{ lv_xml }<COMPANYCODE>{ ls_xml-companycode }</COMPANYCODE>|.
      lv_xml = |{ lv_xml }<FISCALYEAR>{ ls_xml-fiscalyear }</FISCALYEAR>|.
      lv_xml = |{ lv_xml }<POSTINGDATE>{ lv_date }</POSTINGDATE>|.
      lv_xml = |{ lv_xml }<TENCTY_VN>{ ls_xml-tencty_vn }</TENCTY_VN>|.
      lv_xml = |{ lv_xml }<DIACHI_VN>{ ls_xml-diachi_vn }</DIACHI_VN>|.
      lv_xml = |{ lv_xml }<MST>{ ls_xml-mst }</MST>|.
      lv_xml = |{ lv_xml }<DEBIT>{ ls_xml-debit }</DEBIT>|.
      lv_xml = |{ lv_xml }<CREDIT>{ ls_xml-credit }</CREDIT>|.
      lv_xml = |{ lv_xml }<CUSTOMERNAME>{ ls_xml-customername }</CUSTOMERNAME>|.
      lv_xml = |{ lv_xml }<CUSTOMERADRESS>{ ls_xml-customeradress }</CUSTOMERADRESS>|.
      lv_xml = |{ lv_xml }<REASON>{ ls_xml-reason }</REASON>|.
      lv_xml = |{ lv_xml }<AMOUNTDEBIT>{ ls_xml-amountdebit }</AMOUNTDEBIT>|.
      lv_xml = |{ lv_xml }<DOCUMENTREFERENCEID>{ ls_xml-documentreferenceid }</DOCUMENTREFERENCEID>|.
      lv_xml = |{ lv_xml }<ASSIGNMENT>{ ls_xml-assignment }</ASSIGNMENT>|.
      lv_xml = |{ lv_xml }<EXCHANGERATE>{ ls_xml-exchangerate }</EXCHANGERATE>|.
      lv_xml = |{ lv_xml }<CURENCY>{ ls_xml-curency }</CURENCY>|.
      lv_xml = |{ lv_xml }<AMOUNTDEBIT_VND>{ ls_xml-amountdebit_vnd }</AMOUNTDEBIT_VND>|.
      lv_xml = |{ lv_xml }<CURENCY_VND>{ ls_xml-curency_vnd }</CURENCY_VND>|.
      lv_xml = |{ lv_xml }<AMOUNTASWORD>{ lv_amountasword }</AMOUNTASWORD>|.
      lv_xml = |{ lv_xml }<DIRECTOR>{ <fs_key>-%param-director }</DIRECTOR>|.
      lv_xml = |{ lv_xml }<ACCOUNTANT>{ <fs_key>-%param-accountant }</ACCOUNTANT>|.
      lv_xml = |{ lv_xml }<PAYER>{ <fs_key>-%param-payer }</PAYER>|.
      lv_xml = |{ lv_xml }<PREPARER>{ <fs_key>-%param-preparer }</PREPARER>|.
      lv_xml = |{ lv_xml }<TREASURER>{ <fs_key>-%param-treasurer }</TREASURER>|.

      lv_xml = |{ lv_xml }</ZFA_C_PHIEUTHU_01>|.
*      ls_wrap-zfa_c_phieuthu_01 = CORRESPONDING #( ls_xml ).
*         CALL TRANSFORMATION id SOURCE ZFA_C_PHIEUTHU_01 = ls_wrap RESULT XML lv_xml1.
*         REPLACE ALL OCCURRENCES OF '<?xml version="1.0" encoding="utf-16"?><asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values><ZFA_C_PHIEUTHU_01>' IN lv_xml1 WITH ''.
*         REPLACE ALL OCCURRENCES OF '</ZFA_C_PHIEUTHU_01></asx:values></asx:abap>' IN lv_xml1 WITH ''.
*         REPLACE ALL OCCURRENCES OF '><' IN lv_xml1 WITH '>' && cl_abap_char_utilities=>cr_lf && '<'.

      DATA(lv_xstring) = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
TRY.
      cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xstring "lv_xml
                                            iv_xdp_layout   = ls_template-xdp_template
                                            iv_locale       = 'en'
                                            is_options      = VALUE #(
                                           trace_level = 4 "Use 0 in production environment
      )
                                  IMPORTING ev_pdf          = DATA(lv_pdf)
                                            ev_pages        = DATA(ev_pages)
                                            ev_trace_string = DATA(ev_trace_string)
                                           ).
CATCH CX_FP_ADS_UTIL INTO DATA(lx_error1).
data(lv_err1) = lx_error1->get_text( ).  " Hoặc ghi log, v.v.
ENDTRY.

      update_line-attachment = lv_pdf.
      update_line-mimetype = 'application/pdf'.
      update_line-filename = |{ ls_xml-object }.pdf|.
      APPEND update_line TO update.

*      SELECT SINGLE object_id FROM ztb_scm_pdf_draf WHERE object_id = @ls_xml-object AND report_id = 'ZFI_RM04'
*      INTO @DATA(lv_exsist).
      SELECT SINGLE object_id FROM ztb_fi_pdf_draf WHERE object_id = @ls_xml-object AND report_id = 'ZFI_RM04'
      INTO @DATA(lv_exsist).
      IF lv_exsist IS NOT INITIAL.
        ls_update-attachment = lv_pdf.
        ls_update-mimetype = 'application/pdf'.
        ls_update-filename = |{ ls_xml-object }.pdf|.
        ls_update-objectid = ls_xml-object.
        ls_update-reportid = 'ZFI_RM04'.
        APPEND ls_update TO lt_update.
      ELSE.
        ls_create-attachment = lv_pdf.
        ls_create-mimetype = 'application/pdf'.
        ls_create-filename = |{ ls_xml-object }.pdf|.
        ls_create-objectid = ls_xml-object.
        ls_create-reportid = 'ZFI_RM04'.
        APPEND ls_create TO lt_create.
      ENDIF.
    ENDLOOP.
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_tb_fi_pdf_draf
      ENTITY zrtbfipdfdraf
        UPDATE FIELDS (
                        attachment
                        filename
                        mimetype
                        ) WITH lt_update
      REPORTED DATA(reported_pdf_upd)
      FAILED DATA(failed_pdf_upd)
      MAPPED DATA(mapped_pdf_upd).
    ENDIF.
    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zr_tb_fi_pdf_draf
             ENTITY zrtbfipdfdraf
              CREATE FIELDS ( reportid objectid attachment filename mimetype   )
              AUTO FILL CID WITH
              lt_create
              REPORTED DATA(reported_pdf_cre)
               FAILED DATA(failed_pdf_cre)
               MAPPED DATA(mapped_pdf_cre).
    ENDIF.

    IF failed IS INITIAL.
      "Read changed data for action result
      READ ENTITIES OF zfa_r_phieuthu IN LOCAL MODE
        ENTITY zfa_r_phieuthu
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(lt_data2).
      result = VALUE #( FOR ls_data2 IN lt_data2 ( %tky   = ls_data2-%tky
                                                   %param = ls_data2 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GetDefaultsForSign.

      READ ENTITIES OF zfa_r_phieuthu IN LOCAL MODE
      ENTITY zfa_r_phieuthu
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_phieuthu).

    CHECK lt_phieuthu IS NOT INITIAL.

     DATA: lo_chanky       TYPE REF TO zcl_get_zsign_data.

    lo_chanky = NEW #( ).
    DATA: lt_chanky TYPE zcl_get_zsign_data=>tt_sign.
    DATA: lt_chanky02 TYPE zcl_get_zsign_data=>tt_sign.

    data: lv_company type  ztb_zsign-zform.
READ TABLE lt_phieuthu INDEX 1 into data(ls_company).
if sy-subrc = 0.
 lv_company  = ls_company-companycode.
    lo_chanky->get_zsign_data( EXPORTING i_tcode = 'ZRM04' i_zform = lv_company
                                  IMPORTING result    = lt_chanky ).
                                  ELSE.
               lo_chanky->get_zsign_data( EXPORTING i_tcode = 'ZRM04' i_zform = ''
                                  IMPORTING result    = lt_chanky ).
ENDIF.
  LOOP AT lt_phieuthu ASSIGNING FIELD-SYMBOL(<fs_phieuthu>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_result>).

      " If it is create operation, then %cid needs to be used instead of %tky
      <fs_result>-%tky = <fs_phieuthu>-%tky.

      READ TABLE lt_chanky INTO DATA(LS_CHANKY) WITH KEY zposition = 1.
        IF SY-SUBRC = 0.
 <fs_result>-%param-director = LS_CHANKY-zname.
        ENDIF.
          READ TABLE lt_chanky INTO LS_CHANKY  WITH KEY zposition = 2.
        IF SY-SUBRC = 0.
 <fs_result>-%param-accountant = LS_CHANKY-zname.
        ENDIF.
              READ TABLE lt_chanky INTO LS_CHANKY  WITH KEY zposition =  4.
        IF SY-SUBRC = 0.
 <fs_result>-%param-preparer = LS_CHANKY-zname.
        ENDIF.
              READ TABLE lt_chanky INTO LS_CHANKY  WITH KEY zposition =  5.
        IF SY-SUBRC = 0.
 <fs_result>-%param-treasurer = LS_CHANKY-zname.
        ENDIF.


    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
