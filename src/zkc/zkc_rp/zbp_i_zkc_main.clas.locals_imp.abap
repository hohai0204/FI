CLASS lhc_zi_zkc_main DEFINITION INHERITING FROM cl_abap_behavior_handler.
  CLASS-DATA mt_post_keys TYPE STANDARD TABLE OF zi_zkc_main WITH DEFAULT KEY.  "🟡 static storage

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_zkc_main RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_zkc_main RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_zkc_main RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_zkc_main.

    METHODS post FOR MODIFY
      IMPORTING keys FOR ACTION zi_zkc_main~post RESULT result.

*METHODS post FOR DETERMINE ON SAVE
*      IMPORTING keys FOR  zi_zkc_main~post.

ENDCLASS.

CLASS lhc_zi_zkc_main IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD post.

    READ ENTITIES OF zi_zkc_main IN LOCAL MODE
        ENTITY zi_zkc_main
        FROM CORRESPONDING #( keys )
        RESULT DATA(found_data).
    " Lưu lại keys để dùng sau ở finalize
    mt_post_keys = CORRESPONDING #( keys ).

    result = VALUE #( FOR key1 IN keys (
                         %cid_ref = key1-%cid_ref
                       ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_zkc_main DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    DATA mt_post_keys TYPE STANDARD TABLE OF zi_zkc_main WITH DEFAULT KEY.
    DATA: lv_cid_fi TYPE abp_behv_cid,
          lv_pidfi  TYPE abp_behv_pid.
              DATA: lv_datemax TYPE budat,
          lv_datemin TYPE budat.
    DATA:
      lv_companycode TYPE bukrs,
      lv_fisyear     TYPE gjahr,
      lv_fisperiod   TYPE fins_fiscalperiod,
      lv_rulty       TYPE zde_rulty_2,
      lv_revsed      TYPE char1_run_type,
      lv_headertext  TYPE text100.
       DATA: lt_log TYPE TABLE OF ztb_fi_log_kc.
    DATA lt_updatefi TYPE TABLE FOR UPDATE zr_tbfi_kc\\zrtbfikc.
    DATA ls_updatefi TYPE STRUCTURE FOR UPDATE zr_tbfi_kc\\zrtbfikc.

    DATA lt_createfi TYPE TABLE FOR CREATE zr_tbfi_kc\\zrtbfikc.
    DATA ls_createfi TYPE STRUCTURE FOR CREATE zr_tbfi_kc\\zrtbfikc.
    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_zkc_main IMPLEMENTATION.

  METHOD finalize.
    READ ENTITIES OF zi_zkc_main IN LOCAL MODE
        ENTITY zi_zkc_main
        ALL FIELDS
   WITH VALUE #( ( rulty = '1' ) )
        RESULT DATA(found_data).

    DATA: lt_results_head TYPE STANDARD TABLE OF  zi_zkc_main,
          lt_results      TYPE STANDARD TABLE OF  zi_zkc_main,
          lt_result_page  TYPE STANDARD TABLE OF zi_zkc_main.

    DATA: lt_je_deep  TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          lv_cid      TYPE abp_behv_cid,
          lv_result   TYPE string,

          lv_lineitem TYPE d_journalentrypostglitemp-glaccountlineitem,
          lt_curency  TYPE TABLE OF d_journalentrypostcurrencyamtp,
          ls_curr     TYPE d_journalentrypostcurrencyamtp.
    DATA: lty_cur TYPE TABLE OF d_journalentrypostcurrencyamtp.
    DATA: lty_proft TYPE TABLE OF d_journalentrypostcopap.
    TYPES: BEGIN OF lty_itemgl,
             glaccountlineitem TYPE d_journalentrypostglitemp-glaccountlineitem,
             glaccount         TYPE hkont,
             costcenter        TYPE kostl,
             profitcenter      TYPE prctr,
             ttamount          LIKE lty_cur,
             ttprofit          LIKE lty_proft,
             Supplier type lifnr,
           END OF lty_itemgl.

    DATA: lt_item        TYPE TABLE OF  lty_itemgl,
          ls_item_debit  TYPE lty_itemgl,
          ls_item_credit TYPE lty_itemgl.




    LOOP AT lhc_zi_zkc_main=>mt_post_keys INTO DATA(ls_key).
      lv_datemax = ls_key-documentdate.
      lv_rulty = ls_key-rulty.
      lv_companycode = ls_key-bukrs.
      lv_fisyear = ls_key-fiscalyear.
      lv_fisperiod = ls_key-period.
      lv_revsed  = ls_key-isreversed.
      lv_headertext = ls_key-accountingdocumentheadertext.
    ENDLOOP.

    IF lv_revsed IS INITIAL.
          DATA: lr_comp TYPE RANGE OF bukrs.
            if lv_rulty = '1' or lv_rulty = '2' or lv_rulty = '3' or lv_rulty = '4' .
      SELECT zoption     AS option,
             zsign       AS sign,
             zlow        AS low,
             zhigh       AS high
         FROM ztb_einv_var_i AS var_comp
          WHERE var_comp~variant_name = 'ZKC_CTDL'
          INTO CORRESPONDING FIELDS OF TABLE @lr_comp.
          ENDIF.
                if lv_rulty = '1' or lv_rulty = '2' or lv_rulty = '3' or lv_rulty = '3A' .

      SELECT zoption     AS option,
             zsign       AS sign,
             zlow        AS low,
             zhigh       AS high
         FROM ztb_einv_var_i AS var_comp
          WHERE var_comp~variant_name = 'ZKC_CTPT'
          APPENDING CORRESPONDING FIELDS OF TABLE @lr_comp.
          endif.

*    "get data===============================================
      SELECT SINGLE belnr, gjahr, bukrs, belnr_r
        FROM ztb_fi_kc
        WHERE bukrs = @lv_companycode
           AND fiscalyear = @lv_fisyear
          AND period = @lv_fisperiod
          AND rulty = @lv_rulty
        INTO @DATA(lv_belnr).
      IF lv_belnr-belnr IS NOT INITIAL AND lv_belnr-belnr_r IS INITIAL .
        SELECT SINGLE accountingdocument
        FROM i_journalentryitem
        WHERE reversalreferencedocument = @lv_belnr-belnr INTO @lv_belnr-belnr_r.
*        IF lv_belnr-belnr_r IS NOT INITIAL.
*        UPDATE  ztb_fi_kc
*SET
*  belnr_r  = @lv_belnr-Belnr_R,
*
*  last_changed_by     = @SY-UNAME,
*  last_changed_at             = @sy-datum,
*  local_last_changed_by      = @SY-UNAME,
*  local_last_changed_at = @sy-datum
*where bukrs = @lv_companycode
*and fiscalyear = @lv_fisyear
*and period = @lv_fisperiod
*and  rulty = @lv_rulty
*and accountingdocumenttype = 'KC'.
*        ENDIF.
      ENDIF.
      IF lv_belnr-belnr_r IS NOT INITIAL OR lv_belnr-belnr IS INITIAL .
        SELECT
         glaccount AS sacct,
        companycodecurrency AS waers,
        amount
        FROM zi_zkc_list( p_startdate = @lv_datemin, p_enddate = @lv_datemax )
         AS data
         WHERE  companycode = @lv_companycode
         AND fiscalyear = @lv_fisyear
         AND fiscalperiod = @lv_fisperiod
and CompanyCode in @lr_comp
        INTO CORRESPONDING FIELDS OF TABLE @lt_results.

*        SELECT *
*        FROM ztb_zmapkc
*        WHERE rulty = @lv_rulty
*        and bukrs = @lv_companycode
*        ORDER BY
*        sacct ,
*              dacct  ,
*              dacct2,
*              dcost  ,
*              oacct ,
*              ocost
*
*        INTO TABLE @DATA(lt_mapkc).

      SELECT
      sacct ,
       bukrs,
        rulty ,
*        rulttext~text AS rultname,
        dacct ,
        dcost ,
        case when Account~ReconciliationAccount is not inITIAL then
        Account~ReconciliationAccount
        else ztb_zmapkc~dacct2 end  as Dacct2  ,
        acct,
        dprctr,
        oacct,
        ocost,
        oprctr
*        i_glaccounttext~glaccountlongname
      FROM ztb_zmapkc
left join I_SupplierCompany as Account on Account~Supplier = ztb_zmapkc~acct and Account~CompanyCode = ztb_zmapkc~Bukrs

       WHERE rulty = @lv_rulty
        and bukrs = @lv_companycode
        and bukrs in @lr_comp
      ORDER BY
      bukrs,
      sacct ,
            dacct  ,
            dcost  ,
            dacct2,
            oacct ,
            ocost

      INTO TABLE @DATA(lt_mapkc).

        DATA: lv_lineid TYPE int4.
        LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<lfs_data>).
          lv_lineid += 1.
          <lfs_data>-lineid = lv_lineid.
          <lfs_data>-fiscalyear = lv_fisyear.
          <lfs_data>-period = lv_fisperiod.
      <lfs_data>-PostingDate =  <lfs_data>-DocumentDate = lv_datemax .

      <lfs_data>-bukrs =  lv_companycode .

      <lfs_data>-IsReversed =  lv_revsed .
      <lfs_data>-AccountingDocumentHeaderText =  lv_headertext .

          READ TABLE lt_mapkc INTO DATA(ls_mapkc) WITH KEY sacct = <lfs_data>-sacct BINARY SEARCH.
          IF sy-subrc  = 0.
            <lfs_data>-bukrs = ls_mapkc-bukrs.
            <lfs_data>-rulty = ls_mapkc-rulty.
            <lfs_data>-sacct     = ls_mapkc-sacct.
            if ls_mapkc-rulty = '3A'.
            <lfs_data>-dacct     = ls_mapkc-dacct2.
            ELSE.
            <lfs_data>-dacct     = ls_mapkc-dacct.
            ENDIF.
            <lfs_data>-dcost     = ls_mapkc-dcost.
            <lfs_data>-dprctr     = ls_mapkc-dprctr.
            <lfs_data>-oacct     = ls_mapkc-oacct .
            <lfs_data>-ocost     = ls_mapkc-ocost.
            <lfs_data>-oprctr     = ls_mapkc-oprctr.
            IF <lfs_data>-amount > 0.
              lv_lineitem += 1.
              ls_item_debit-glaccountlineitem = lv_lineitem.
              ls_item_debit-glaccount = <lfs_data>-dacct.
              ls_item_debit-costcenter =  <lfs_data>-dcost.
              ls_item_debit-profitcenter =  <lfs_data>-dprctr.
              ls_item_debit-supplier = ls_mapkc-acct.
              ls_curr-journalentryitemamount = <lfs_data>-amount.
              ls_curr-currency = <lfs_data>-waers.
              APPEND ls_curr TO lt_curency.
              ls_item_debit-ttamount = lt_curency.
              CLEAR: lt_curency.
              lv_lineitem += 1.
              ls_item_credit-glaccountlineitem = lv_lineitem.
              ls_item_credit-glaccount = <lfs_data>-oacct.
              ls_item_credit-costcenter =  <lfs_data>-ocost.
              ls_item_credit-profitcenter =  <lfs_data>-oprctr.
              ls_curr-journalentryitemamount = <lfs_data>-amount * -1.
              ls_curr-currency = <lfs_data>-waers.
              APPEND ls_curr TO lt_curency.
              ls_item_credit-ttamount = lt_curency.
              CLEAR: lt_curency.
            ELSE.
              lv_lineitem += 1.
              ls_item_debit-glaccountlineitem = lv_lineitem.
              ls_item_debit-glaccount = <lfs_data>-oacct.
              ls_item_debit-costcenter =  <lfs_data>-ocost.
              ls_item_debit-profitcenter =  <lfs_data>-oprctr.
              ls_curr-journalentryitemamount = <lfs_data>-amount * -1.
              ls_curr-currency = <lfs_data>-waers.
              APPEND ls_curr TO lt_curency.
              ls_item_debit-ttamount = lt_curency.
              CLEAR: lt_curency.
              lv_lineitem += 1.
              ls_item_credit-glaccountlineitem = lv_lineitem.
              ls_item_credit-glaccount = <lfs_data>-dacct.
              ls_item_debit-supplier = ls_mapkc-acct.
              ls_item_credit-costcenter =  <lfs_data>-dcost.
              ls_item_credit-profitcenter =  <lfs_data>-dprctr.
              ls_curr-journalentryitemamount = <lfs_data>-amount .
              ls_curr-currency = <lfs_data>-waers.
              APPEND ls_curr TO lt_curency.
              ls_item_credit-ttamount = lt_curency.
              CLEAR: lt_curency.
            ENDIF.
            APPEND ls_item_debit TO lt_item.
            APPEND ls_item_credit TO lt_item.



          ENDIF.


        ENDLOOP.
        CLEAR lv_lineitem.
        DELETE lt_results  WHERE rulty IS INITIAL.
        "========================post FI doc =========================
lt_log =  CORRESPONDING #( lt_results ).

        TRY.
            lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.

        APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).

        <je_deep>-%cid = lv_cid.
        <je_deep>-%param = VALUE #(
        companycode = lv_companycode
        documentreferenceid = 'BKPFF'
        createdbyuser = sy-uname
        businesstransactiontype = 'RFBU'
        accountingdocumenttype = 'KC'
        documentdate = lv_datemax
        postingdate = lv_datemax
        accountingdocumentheadertext = lv_headertext


*        _glitems = VALUE #( FOR ls_item IN lt_item
*        (
*         glaccountlineitem = ls_item-glaccountlineitem glaccount = ls_item-glaccount costcenter = ls_item-costcenter profitcenter = ls_item-profitcenter
*        _currencyamount = VALUE #( FOR ls_currr IN ls_item-ttamount ( journalentryitemamount = ls_currr-journalentryitemamount currency = ls_currr-currency ) )
* )
*   )
" 1. Chỉ lấy những dòng KHÔNG CÓ Supplier cấp cho _glitems
_glitems = VALUE #( FOR ls_item IN lt_item WHERE ( supplier IS INITIAL )
    (
     glaccountlineitem = ls_item-glaccountlineitem
     glaccount         = ls_item-glaccount
     costcenter        = ls_item-costcenter
     profitcenter      = ls_item-profitcenter
     _currencyamount   = VALUE #( FOR ls_currr IN ls_item-ttamount
         ( journalentryitemamount = ls_currr-journalentryitemamount
           currency               = ls_currr-currency ) )
    ) )

" 2. Chỉ lấy những dòng CÓ Supplier cấp cho _apitems
_apitems = VALUE #( FOR ls_item IN lt_item WHERE ( supplier IS NOT INITIAL )
    (
     glaccountlineitem = ls_item-glaccountlineitem
     glaccount         = ls_item-glaccount
     supplier          = ls_item-supplier
     profitcenter      = ls_item-profitcenter
     _currencyamount   = VALUE #( FOR ls_currr IN ls_item-ttamount
         ( journalentryitemamount = ls_currr-journalentryitemamount
           currency               = ls_currr-currency ) )
    ) )

    ).
        " 🟢 Gọi sang BO khác bằng EML
        MODIFY ENTITIES OF i_journalentrytp
          ENTITY journalentry
          EXECUTE post
          FROM lt_je_deep
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported)
          MAPPED DATA(ls_mapped).
        IF ls_failed IS NOT INITIAL.

          LOOP AT ls_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
            lv_result = |{ lv_result }, { <ls_reported_deep>-%msg->if_message~get_text( ) }|.
          ENDLOOP.

        ELSE.

          LOOP AT ls_reported-journalentry ASSIGNING <ls_reported_deep>.
            DATA(ls_msg) = |{ <ls_reported_deep>-%msg->if_message~get_text( ) }|.
            DATA(lv_pid) = <ls_reported_deep>-%pid.

          ENDLOOP.
          LOOP AT ls_mapped-journalentry ASSIGNING FIELD-SYMBOL(<ls_mapped_deep>).
            lv_cid_fi   =  <ls_mapped_deep>-%cid.
            lv_pidfi = <ls_mapped_deep>-%pid.
          ENDLOOP.

        ENDIF.
      ELSE.
        APPEND VALUE #(
           %msg = new_message_with_text( severity =
           if_abap_behv_message=>severity-error
           text = 'Đã tồn tại chứng từ FI doc' && ' ' && lv_belnr-belnr ) ) TO reported-zi_zkc_main.

      ENDIF.
    ELSE.

      "revesed accounting document====================================
      DATA: lt_revesed TYPE TABLE FOR ACTION IMPORT i_journalentrytp~reverse.

      SELECT SINGLE belnr, gjahr, bukrs, belnr_r
        FROM ztb_fi_kc
        WHERE bukrs = @lv_companycode
           AND fiscalyear = @lv_fisyear
          AND period = @lv_fisperiod
          AND rulty = @lv_rulty
        INTO @lv_belnr.

      IF lv_belnr-belnr IS NOT INITIAL.
        IF lv_belnr-belnr_r IS INITIAL.
          APPEND INITIAL LINE TO lt_revesed ASSIGNING FIELD-SYMBOL(<je_revesed>).

          <je_revesed>-accountingdocument = lv_belnr-belnr.
          <je_revesed>-companycode =  lv_belnr-bukrs.
          <je_revesed>-fiscalyear =  lv_belnr-gjahr.
          <je_revesed>-%param =  VALUE #(
            reversalreason = '01'
            postingdate = lv_datemax
            createdbyuser = sy-uname
        ).
          MODIFY ENTITIES OF i_journalentrytp
            ENTITY journalentry
            EXECUTE reverse
            FROM lt_revesed
            FAILED DATA(ls_failed_r)
            REPORTED DATA(ls_reported_r)
            MAPPED DATA(ls_mapped_r).


          IF ls_failed_r IS NOT INITIAL.

            LOOP AT ls_reported_r-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_r>).
              lv_result = |{ lv_result }, { <ls_reported_r>-%msg->if_message~get_text( ) }|.
            ENDLOOP.

          ELSE.

            LOOP AT ls_reported_r-journalentry ASSIGNING <ls_reported_r>.
              DATA(ls_msg_r) = |{ <ls_reported_r>-%msg->if_message~get_text( ) }|.
              DATA(lv_pid_r) = <ls_reported_r>-%pid.
              lv_cid_fi   =  <ls_reported_r>-%cid.
              lv_pidfi = <ls_reported_r>-%pid.
            ENDLOOP.

            "Error handling goes here
            "Convert the %pid to the drawn db key
            LOOP AT ls_mapped_r-journalentry ASSIGNING FIELD-SYMBOL(<ls_mapped_r>).
              lv_cid_fi   =  <ls_mapped_r>-%cid.
              lv_pidfi = <ls_mapped_r>-%pid.
*       *   CONVERT KEY OF i_journalentrytp FROM <ls_mapped_r>-%pid TO DATA(lv_key).
*          <ls_mapped_r>-companycode = lv_key-companycode.
*          <ls_mapped_r>-fiscalyear = lv_key-fiscalyear.
*          <ls_mapped_r>-accountingdocument = lv_key-accountingdocument.
              EXIT.
            ENDLOOP.

            DATA(lv_accountingdocument) =  <ls_mapped_r>-accountingdocument.
            DATA(lv_fiscal) =  <ls_mapped_r>-fiscalyear.
            DATA(lv_companycode1) =  <ls_mapped_r>-companycode.

          ENDIF.
        ELSE.
          APPEND VALUE #(
                  %msg = new_message_with_text( severity =
                  if_abap_behv_message=>severity-error
                  text = 'Đã tồn tại chứng từ revesed FI doc' && ' ' && lv_belnr-belnr ) ) TO reported-zi_zkc_main.
        ENDIF.
      ENDIF.
    ENDIF.
    " return result

  ENDMETHOD.

  METHOD check_before_save.
    DATA(lv_test) = 1.
  ENDMETHOD.

  METHOD save.
*=================================================================
    DATA: lt_update_kc TYPE TABLE OF zi_zkc_main,
          ls_updatekkc TYPE  zi_zkc_main.
*============================================================
    IF lv_pidfi IS NOT INITIAL.

      CONVERT KEY OF i_journalentrytp FROM lv_pidfi TO DATA(lv_key).
      LOOP AT lhc_zi_zkc_main=>mt_post_keys INTO DATA(ls_key).
        ls_updatekkc-belnr = lv_key-accountingdocument.
        ls_updatekkc-rulty    = ls_key-rulty.
        ls_updatekkc-bukrs        = ls_key-bukrs.
         ls_updatekkc-lineid       = ls_key-lineid.
        ls_updatekkc-fiscalyear          = ls_key-fiscalyear.
        ls_updatekkc-period             = ls_key-period.
        ls_updatekkc-accountingdocumenttype      = ls_key-accountingdocumenttype.
        ls_updatekkc-documentdate          = ls_key-documentdate.
        ls_updatekkc-postingdate      = ls_key-postingdate.
        ls_updatekkc-accountingdocumentheadertext    = ls_key-accountingdocumentheadertext.
        ls_updatekkc-isreversed    = ls_key-isreversed.
        APPEND ls_updatekkc TO lt_update_kc.
      ENDLOOP.
      " return result

*   MODIFY ENTITIES OF zi_zkc_main IN LOCAL MODE
*   ENTITY zi_zkc_main
*           UPDATE FIELDS (
*                       belnr
*                        ) WITH lt_update_kc
*      REPORTED DATA(reported_pdf_upd)
*      FAILED DATA(failed_pdf_upd)
*      MAPPED DATA(mapped_pdf_upd).

      SELECT SINGLE bukrs, fiscalyear , period ,rulty
      FROM ztb_fi_kc
      WHERE bukrs = @lv_companycode
         AND fiscalyear = @lv_fisyear
        AND period = @lv_fisperiod
        AND rulty = @lv_rulty
      INTO @DATA(lv_checktb).


      IF lv_checktb IS NOT INITIAL.
        IF lv_revsed IS INITIAL.
          lt_updatefi = VALUE #(
        ( bukrs = lv_companycode fiscalyear = lv_fisyear period = lv_fisperiod rulty = lv_rulty accountingdocumenttype = 'KC' belnr = lv_key-accountingdocument gjahr = lv_key-fiscalyear belnrr = '' lastchangedat = sy-datlo lastchangedby = sy-uname )
        ).

        ELSE.
          lt_updatefi = VALUE #(
  ( bukrs = lv_companycode fiscalyear = lv_fisyear period = lv_fisperiod rulty = lv_rulty accountingdocumenttype = 'KC' belnrr = lv_key-accountingdocument   lastchangedat = sy-datlo lastchangedby = sy-uname )
  ).

        ENDIF.
      ELSE.
        lt_createfi = VALUE #(
        ( bukrs = lv_companycode fiscalyear = lv_fisyear period = lv_fisperiod rulty = lv_rulty accountingdocumenttype = 'KC' belnr = lv_key-accountingdocument gjahr = lv_key-fiscalyear  createdat = sy-datlo createdby = sy-uname )
        ).

      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    DATA(lv_test) = 1.
    DATA: lv_logid TYPE uuid.
    TRY.
        lv_logid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.
    IF lt_createfi IS NOT INITIAL.
      MODIFY ENTITIES OF zr_tbfi_kc "IN LOCAL MODE
             ENTITY zrtbfikc
              CREATE FIELDS ( bukrs fiscalyear period rulty accountingdocumenttype belnr gjahr  )
              AUTO FILL CID WITH
              lt_createfi
              REPORTED DATA(reported_cre)
               FAILED DATA(failed_cre)
               MAPPED DATA(mapped_cre).
      DATA: lt_kc TYPE TABLE OF ztb_fi_kc.
      lt_kc = CORRESPONDING #( lt_createfi ).

      LOOP AT  lt_kc ASSIGNING FIELD-SYMBOL(<lfs_createfi>).
        <lfs_createfi>-created_by        = sy-uname.
        <lfs_createfi>-created_at       = lv_now.
      ENDLOOP.


      MODIFY ztb_fi_kc FROM TABLE @lt_kc.
      IF sy-subrc = 0.

      ENDIF.


      LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<lfs_log>).
        <lfs_log>-uuid = lv_logid.
         <lfs_log>-created_by        = sy-uname.
         <lfs_log>-created_at       = lv_now.
      ENDLOOP.
      MODIFY ztb_fi_log_kc FROM TABLE @lt_log.
      IF sy-subrc = 0.

      ENDIF.

    ELSEIF lt_updatefi IS NOT INITIAL.
      LOOP AT lt_updatefi INTO DATA(ls_upfi).
        IF lv_revsed IS INITIAL.
          UPDATE  ztb_fi_kc
          SET belnr  = @ls_upfi-belnr,
            gjahr  = @ls_upfi-gjahr,
            belnr_r  = @ls_upfi-belnrr,

            last_changed_by     = @sy-uname,
*  last_changed_at             = dats_to_datn,
            local_last_changed_by      = @sy-uname
* local_last_changed_at = @sy-datum
          WHERE bukrs = @lv_companycode
          AND fiscalyear = @lv_fisyear
          AND period = @lv_fisperiod
          AND  rulty = @lv_rulty
          AND accountingdocumenttype = 'KC'.
        ELSE.
          UPDATE  ztb_fi_kc
          SET belnr_r  = @ls_upfi-belnrr,
            last_changed_by     = @sy-uname,
            last_changed_at             = @lv_now,
            local_last_changed_by      = @sy-uname,
            local_last_changed_at = @lv_now
          WHERE bukrs = @lv_companycode
          AND fiscalyear = @lv_fisyear
          AND period = @lv_fisperiod
          AND  rulty = @lv_rulty
          AND accountingdocumenttype = 'KC'.
        ENDIF.
      ENDLOOP.



             LOOP AT lt_log ASSIGNING <lfs_log>.
             READ TABLE lt_updatefi INTO data(ls_filog) INDEX 1.
        <lfs_log>-uuid = lv_logid.
        <lfs_log>-created_by        = sy-uname.
        <lfs_log>-created_at       = lv_now.

        <lfs_log>-belnr = ls_filog-belnr.
        <lfs_log>-belnr_r = ls_filog-belnrr.
      ENDLOOP.


      MODIFY ztb_fi_log_kc FROM TABLE @lt_log.
      IF sy-subrc = 0.

      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.

  ENDMETHOD.

ENDCLASS.
