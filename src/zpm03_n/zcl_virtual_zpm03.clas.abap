CLASS zcl_virtual_zpm03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRTUAL_ZPM03 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_data_i TYPE STANDARD TABLE OF zc_fa_zpm03_nw WITH DEFAULT KEY. "

    lt_data_i = CORRESPONDING #( it_original_data ).
    DATA: lv_numc TYPE int4.
    TYPES: BEGIN OF lty_sumtotal,
             tax_group      TYPE char05,
             dgdv type zde_text255,
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
with
+item_min as (
select  item_YY~AccountingDocument ,min( item_YY~AccountingDocumentItem )  as AccountingDocumentItem
from I_JournalEntryItem as item_YY
GROUP BY item_YY~AccountingDocument
)
select min~AccountingDocument, item_YY~YY1_GCHD_JEI
from @lt_data_i as fidoc
inner join +item_min as min on min~AccountingDocument = fidoc~AccountingDocument
inner join I_JournalEntryItem as item_YY on  min~AccountingDocument = item_YY~AccountingDocument
and min~AccountingDocumentItem = item_YY~AccountingDocumentItem
ORDER BY min~AccountingDocument
into table @data(lt_itemmin).
*data: lr_range type range of zc_fa_zpm03_nw-Object.
*select
* data~Object
*,data~tax_group
*,data~amount
*,data~Taxamount
*,data~CompanyCodeCurrency
*,data~dgdv
*,data~Totalline
*,data~stt
* from zc_fa_zpm03_nw as data
*where Object in @lr_range
*into table @data(lt_zpm03).
data: ls_group type  zc_fa_zpm03_nw,
*      ls_result type  zc_fa_zpm03_nw,
      ls_last type  zc_fa_zpm03_nw,
      lt_group type STANDARD TABLE OF  zc_fa_zpm03_nw.
data: lv_stt type I.

*LOOP AT lt_zpm03 into data(ls_result)
*     GROUP BY ( tax_group = ls_result-tax_group ) INTO DATA(group_key).
*
*  LOOP AT GROUP group_key ASSIGNING FIELD-SYMBOL(<lfs_line>).
*<lfs_line>-Totalline = <lfs_line>-Taxamount + <lfs_line>-amount.
*lv_stt += 1.
*<lfs_line>-stt = lv_stt.
*
*ls_group-amount += <lfs_line>-amount.
*ls_group-Taxamount += <lfs_line>-Taxamount.
*ls_group-tax_group = <lfs_line>-tax_group.
*ls_group-Object = |{ ls_group-tax_group  }TOTAL|.
*ls_group-CompanyCodeCurrency = <lfs_line>-CompanyCodeCurrency.
*ls_group-dgdv = <lfs_line>-dgdv.
*ls_last-amount += <lfs_line>-amount.
*ls_last-Taxamount += <lfs_line>-Taxamount.
*ls_last-CompanyCodeCurrency = <lfs_line>-CompanyCodeCurrency.
*  ENDLOOP.
*ls_group-dgdv = |Tổng: { ls_group-dgdv }|.
*ls_group-Totalline = ls_group-amount + ls_group-Taxamount.
*append ls_group to lt_group.
*CLear: lv_stt, ls_group.
*
*ENDLOOP.
*ls_last-Object = 'DSUMTOTAL'.
*ls_last-dgdv = 'Tổng cộng:'.
*ls_last-Totalline = ls_last-amount + ls_last-Taxamount.
*
*SORT lt_zpm03 BY Object.
SORT LT_Group BY tax_group.
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





   LOOP AT lt_data_i ASSIGNING FIELD-SYMBOL(<lfs_item>).
*    LOOP AT lt_data_i INTO ls_item GROUP BY ls_item-dgdv INTO DATA(group).
*     lv_numc = 0.
*      LOOP AT GROUP group ASSIGNING FIELD-SYMBOL(<lfs_item>).

    <lfs_item>-Totalline = <lfs_item>-Taxamount + <lfs_item>-amount.
READ TABLE lt_itemmin INTO DATA(ls_intemmin) WITH KEY AccountingDocument = <lfs_item>-AccountingDocument BINARY SEARCH.
IF SY-SUBRC = 0.
<lfs_item>-YY1_GCHD_JEI = ls_intemmin-yy1_gchd_jei.
ENDIF.
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
