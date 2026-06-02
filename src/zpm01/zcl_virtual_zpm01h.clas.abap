CLASS zcl_virtual_zpm01h DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRTUAL_ZPM01H IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
  DATA: lt_data_h TYPE STANDARD TABLE OF zr_fa_zpm01 WITH DEFAULT KEY.

    lt_data_h = CORRESPONDING #( it_original_data ).

    SELECT FROM zr_fa_zpm01
  FIELDS *
  INTO TABLE @DATA(lt_zpm01).


DATA: lv_min_postingdate        TYPE dats,
      lv_prev_month_first_day   TYPE dats,
      lv_prev_month_last_day    TYPE dats.

" Giả sử đã tính trước được ngày nhỏ nhất
lv_min_postingdate = REDUCE #(
  INIT min = '99991231'
  FOR wa IN lt_data_h
  NEXT min = COND #( WHEN wa-postingdate < min THEN wa-postingdate ELSE min )
).


if lv_min_postingdate+4(2) = '01'.
  lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) - 1 }1201|.
ELSE.
if lv_min_postingdate+4(2) - 1  > 9.
  lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) }{ lv_min_postingdate+4(2) - 1 }01|.
ELSE.
    lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) }0{ lv_min_postingdate+4(2) - 1 }01|.
endif.

endif.


    select
sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency > 0 AND Item_JournalEntry~CompanyCodeCurrency = 'VND' then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as noDauKyVND,
     sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency <= 0 AND Item_JournalEntry~CompanyCodeCurrency = 'VND'  then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as coDauKyVND,
sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency > 0 AND Item_JournalEntry~CompanyCodeCurrency <> 'VND' then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as noDauKy,
     sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency <= 0 AND Item_JournalEntry~CompanyCodeCurrency <> 'VND'  then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as coDauKy

*JournalEntry~AccountingDocument,
*Item_JournalEntry~CompanyCodeCurrency,
*Item_JournalEntry~AmountInCompanyCodeCurrency
    from    I_Supplier         as Supplier
    left outer join I_JournalEntryItem as Item_JournalEntry on  Supplier~Supplier        = Item_JournalEntry~Supplier
                                                            and Item_JournalEntry~Ledger = '0L'
                                                            and Item_JournalEntry~FinancialAccountType =  'K'
    left outer join I_JournalEntry     as JournalEntry      on JournalEntry~AccountingDocument = Item_JournalEntry~AccountingDocument
    where JournalEntry~postingdate BETWEEN @lv_prev_month_first_day AND @lv_min_postingdate
    into table @data(LT_DAUKY).
LOOP AT lt_data_h ASSIGNING FIELD-SYMBOL(<lfs_h>).

    READ TABLE LT_DAUKY ASSIGNING FIELD-SYMBOL(<lfs_DAUKY>) INDEX 1.
    IF sy-subrc = 0.
      <lfs_h>-ct9_nodk_vnd = <lfs_DAUKY>-noDauKyVND.
      <lfs_h>-ct10_codk_vnd = <lfs_DAUKY>-coDauKyVND.
      <lfs_h>-ct11_nodk = <lfs_DAUKY>-noDauKy.
      <lfs_h>-ct12_codk = <lfs_DAUKY>-coDauKy.
    endif.
ENDLOOP.

    IF lt_data_h IS NOT INITIAL.
      ct_calculated_data = CORRESPONDING #(  lt_data_h ).
      CLEAR: lt_data_h.
    ENDIF.
    CLEAR: LT_DAUKY,lv_prev_month_first_day,lv_min_postingdate.
  ENDMETHOD.


    METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
