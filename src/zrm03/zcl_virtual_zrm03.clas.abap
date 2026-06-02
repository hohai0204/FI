CLASS zcl_virtual_zrm03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRTUAL_ZRM03 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_data_i TYPE STANDARD TABLE OF zc_fa_zrm03_01 WITH DEFAULT KEY. "zsd_c_zsd03_items

    lt_data_i = CORRESPONDING #( it_original_data ).
    DATA: lv_numc TYPE int4.
    TYPES: BEGIN OF lty_sumtotal,
             tax_group      TYPE char05,
             dgdv           TYPE zde_text255,
             totalamount    TYPE zde_amount,
             totaltaxamount TYPE zde_amount,
             total_sumline  TYPE zde_amount,
             NT_NonTax    TYPE zde_amount,
             NT_Tax TYPE zde_amount,
             NT_full  TYPE zde_amount,
           END OF lty_sumtotal.
    DATA: ls_total TYPE lty_sumtotal,
          lt_total TYPE TABLE OF lty_sumtotal.
    DATA: ls_total_t TYPE lty_sumtotal,
          lt_total_t TYPE TABLE OF lty_sumtotal.
    WITH
    +item_min AS (
    SELECT  item_yy~accountingdocument ,MIN( item_yy~accountingdocumentitem )  AS accountingdocumentitem
    FROM i_journalentryitem AS item_yy
    GROUP BY item_yy~accountingdocument
    )
    SELECT min~accountingdocument, item_yy~yy1_gchd_jei
    FROM @lt_data_i AS fidoc
    INNER JOIN +item_min AS min ON min~accountingdocument = fidoc~accountingdocument
    INNER JOIN i_journalentryitem AS item_yy ON  min~accountingdocument = item_yy~accountingdocument
    AND min~accountingdocumentitem = item_yy~accountingdocumentitem
    ORDER BY min~accountingdocument
    INTO TABLE @DATA(lt_itemmin).
    SELECT DISTINCT fidoc~customer,
    CASE WHEN fidoc~accountingdocumenttype = 'RV' THEN
    CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
             ota_cus~name
               ELSE customer_fi~name  END
               ELSE
               CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
              concat_with_space( ota_cusfi~businesspartnername1,
              concat_with_space( ota_cusfi~businesspartnername2,
              concat_with_space( ota_cusfi~businesspartnername3, ota_cusfi~businesspartnername4, 1 ), 1 ) ,1 )

               ELSE customer_fi~name  END
                END                                                                                                 AS customername,

          CASE WHEN fidoc~accountingdocumenttype = 'RV' THEN
          CASE  WHEN customer_fi~isonetimeaccount IS NOT INITIAL THEN
          concat( concat(  concat(
                concat_with_space( ota_cus~street1, ota_cus~street2, 1 ),  ota_cus~street3 ),ota_cus~street4 ), ota_cus~street5 )

          ELSE customer_fi~address  END
          ELSE
          CASE  when customer_fi~isonetimeaccount is not initial then
          concat_with_space( ota_cusfi~streetaddressname, ota_cusfi~cityname, 1 )
          ELSE
          customer_fi~address      END
          END                                                                                                       as customeradress,

          customer_fi~mst                                                                                              as mst_customer

    from @lt_data_i as fidoc
        left outer join zcds_bp_profile  as customer_fi   ON fidoc~customer = customer_fi~businesspartner
        left outer join zcds_bp_ota                   as ota_cus         ON  fidoc~customer          = ota_cus~customer
                                                                         and fidoc~originalreferencedocument = ota_cus~billingdocument
        left outer join i_onetimeaccountsupplier      as ota_cusfi       ON  ota_cusfi~accountingdocument     = fidoc~accountingdocument
                                                                         and ota_cusfi~companycode            = fidoc~companycode
                                                                         and fidoc~customer          = ota_cusfi~Supplier
    ORDER BY fidoc~customer
    into table @DATA(lt_customer).
    LOOP AT lt_data_i INTO DATA(ls_item) GROUP BY ls_item-dgdv INTO DATA(group).
      lv_numc = 0.
      LOOP AT GROUP group ASSIGNING FIELD-SYMBOL(<lfs_change>).
        lv_numc += 1.
        <lfs_change>-stt = lv_numc.
        <lfs_change>-totalline = <lfs_change>-amount + <lfs_change>-taxamount.

        ls_total-tax_group = <lfs_change>-tax_group.
        ls_total-dgdv = <lfs_change>-dgdv.

        ls_total-totalamount += <lfs_change>-amount.
        ls_total-totaltaxamount += <lfs_change>-taxamount.
        ls_total-total_sumline += <lfs_change>-totalline.
        "=================================================
        ls_total-nt_nontax += <lfs_change>-TaxBaseAmountInTransCrcy.
        ls_total-nt_tax += <lfs_change>-taxamounttrans.
        ls_total-nt_full += <lfs_change>-amount_NT.
        ls_total_t-nt_nontax += <lfs_change>-TaxBaseAmountInTransCrcy.
        ls_total_t-nt_tax += <lfs_change>-taxamounttrans.
        ls_total_t-nt_full += <lfs_change>-amount_NT.
        "===================================================
        ls_total_t-totalamount += <lfs_change>-amount.
        ls_total_t-totaltaxamount += <lfs_change>-taxamount.
        ls_total_t-total_sumline += <lfs_change>-totalline.

        READ TABLE lt_total  ASSIGNING FIELD-SYMBOL(<lfs_total>) WITH KEY dgdv = <lfs_change>-dgdv.
        IF sy-subrc = 0.
          <lfs_total>-totalamount = ls_total-totalamount .
          <lfs_total>-totaltaxamount = ls_total-totaltaxamount .
          <lfs_total>-total_sumline = ls_total-total_sumline .
          "===========================================
          <lfs_total>-nt_nontax = ls_total-nt_nontax .
          <lfs_total>-nt_tax = ls_total-nt_tax .
          <lfs_total>-nt_full = ls_total-nt_full .
          "=============================================
        ELSE.
          APPEND ls_total TO lt_total.
        ENDIF.
      ENDLOOP.
      CLEAR: lv_numc, ls_total.
    ENDLOOP.
    DATA: lo_api       TYPE REF TO zcl_get_long_text.

    lo_api = NEW #( ).
    DATA: lt_longtext TYPE zcl_get_long_text=>tt_longtext_res.
    DATA: lt_longtext_out TYPE zcl_get_long_text=>tt_longtext_res.
    DATA: lv_billing TYPE i_billingdocument-billingdocument.
    LOOP AT lt_data_i ASSIGNING FIELD-SYMBOL(<lfs_item>).
      READ TABLE lt_itemmin INTO DATA(ls_intemmin) WITH KEY accountingdocument = <lfs_item>-accountingdocument BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_item>-yy1_gchd_jei = ls_intemmin-yy1_gchd_jei.
      ENDIF.

      lv_billing = <lfs_item>-originalreferencedocument.
      lv_billing = |{ lv_billing  ALPHA = IN }|.
      lo_api->get_longtext_billing_header( EXPORTING billingdocument = lv_billing
                                 IMPORTING result           = lt_longtext ).
      READ TABLE lt_longtext INTO DATA(ls_longtext) WITH KEY tdid = 'TX06' BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_item>-custom_name = ls_longtext-longtext.
      ELSE.
      REad TABLE lt_customer INTO DATA(LS_CUS) WITH KEY customer = <lfs_item>-customer BINARY SEARCH.
      IF SY-SUBRC = 0.
        <lfs_item>-custom_name = LS_CUS-customername.
      ENDIF.
      ENDIF.
      READ TABLE lt_longtext INTO ls_longtext WITH KEY tdid = 'TX15' BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_item>-custom_mst = ls_longtext-longtext.
      ELSE.
        <lfs_item>-custom_mst = LS_CUS-mst_customer.
      ENDIF.
      CLEAR lt_longtext.


      READ TABLE  lt_total INTO DATA(ls_tong) WITH KEY dgdv = <lfs_item>-dgdv BINARY SEARCH.
      IF sy-subrc = 0.
        <lfs_item>-totalamount = ls_tong-totalamount.
        <lfs_item>-totaltaxamount = ls_tong-totaltaxamount.
        <lfs_item>-total_sumline = ls_tong-total_sumline.
        <lfs_item>-NT_NonTaxTS = ls_tong-nt_nontax.
        <lfs_item>-NT_TaxTS = ls_tong-nt_tax.
        <lfs_item>-NT_amountTS = ls_tong-nt_full.
      ENDIF.
      <lfs_item>-sumtotal = ls_total_t-totalamount.
      <lfs_item>-sumtotal_vat = ls_total_t-totaltaxamount.
      <lfs_item>-NT_NonTax = ls_total_t-nt_nontax.
      <lfs_item>-NT_Tax = ls_total_t-nt_tax.
      <lfs_item>-NT_amountfull = ls_total_t-nt_full.
    ENDLOOP.
    IF lt_data_i IS NOT INITIAL.
      ct_calculated_data = CORRESPONDING #(  lt_data_i ).
    ENDIF.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
