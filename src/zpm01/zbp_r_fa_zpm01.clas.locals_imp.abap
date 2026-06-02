CLASS lhc_zr_fa_zpm01 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_fa_zpm01 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_fa_zpm01 RESULT result.

    METHODS printpdf FOR MODIFY
      IMPORTING keys FOR ACTION zr_fa_zpm01~printpdf RESULT result.

ENDCLASS.

CLASS lhc_zr_fa_zpm01 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD printpdf.
    TYPES: BEGIN OF lty_journal_entry,
             accountingdocument             TYPE string,
             journalentrylastchangedatetime TYPE string,
             postingdate                    TYPE string,
             documentreferenceid            TYPE string,
             accountingdocumentheadertext   TYPE string,
             glaccount_26                   TYPE string,
             glaccount_27                   TYPE string,
             transactioncurrency            TYPE string,
             taxexchangerate                TYPE string,
             amountinbalancetransaccrcy_30  TYPE string,
             amountinbalancetransaccrcy_31  TYPE string,
             amountinbalancetransaccrcy_32  TYPE string,
             amountinbalancetransaccrcy_33  TYPE string,
           END OF lty_journal_entry.

    TYPES tt_journal_entrys TYPE STANDARD TABLE OF lty_journal_entry WITH EMPTY KEY.

    TYPES: BEGIN OF lty_supplier,
             supplieraccountgroup TYPE string,
             ncc                  TYPE string,
             sum_ct9              TYPE string,
             sum_ct10             TYPE string,
             sum_ct11             TYPE string,
             sum_ct12             TYPE string,
             ct9_nodk_vnd         TYPE string,
             ct10_codk_vnd        TYPE string,
             ct11_nodk            TYPE string,
             ct12_codk            TYPE string,
             ct13_cpsn_vnd        TYPE string,
             ct14_cpsc_vnd        TYPE string,
             ct15_cpsn            TYPE string,
             ct16_cpsc            TYPE string,
             ct17_sdnck_vnd       TYPE string,
             ct18_sdcck_vnd       TYPE string,
             ct19_sdnck           TYPE string,
             ct20_sdcck           TYPE string,
             journal_entrys       TYPE tt_journal_entrys,


           END OF lty_supplier.
    TYPES tt_suppliers TYPE STANDARD TABLE OF lty_supplier WITH EMPTY KEY.
    TYPES: BEGIN OF lty_header,
             tencty_vn     TYPE string,
             diachi_vn     TYPE string,
             mst           TYPE string,

             tk            TYPE string,
             day           TYPE string,
             suppliers     TYPE tt_suppliers,
             nguoilap      TYPE string,

             sum_cpsn_vnd  TYPE string,
             sum_cpsc_vnd  TYPE string,
             sum_cpsn      TYPE string,
             sum_cpsc      TYPE string,
             sum_sdnck_vnd TYPE string,
             sum_sdcck_vnd TYPE string,
             sum_sdnck     TYPE string,
             sum_sdcck     TYPE string,

             ketoantruong  TYPE string,
             giamdoc       TYPE string,
             day_print     TYPE string,

           END OF lty_header.


    DATA: lt_post            TYPE TABLE OF lty_header,
          ls_post            TYPE lty_header,
          ls_supplier        TYPE lty_supplier,
          ls_supplier_header TYPE lty_supplier,
          lt_suppliers       TYPE TABLE OF lty_supplier,
          ls_journal_entry   TYPE lty_journal_entry,
          lt_journal_entrys  TYPE TABLE OF lty_journal_entry.

    "-- select data from DB
    READ ENTITIES OF zr_fa_zpm01 IN LOCAL MODE
            ENTITY zr_fa_zpm01
           ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_selected).


    SELECT header~*
        FROM zr_fa_zpm01 AS header
        INNER JOIN @lt_selected AS selected ON selected~AccountingDocument = header~AccountingDocument
        ORDER BY header~AccountingDocument
        INTO TABLE @DATA(lt_zpm01).

*
*    SELECT FROM zr_fa_zpm01
*  FIELDS *
*  INTO TABLE @DATA(lt_zpm01_data).
*
*
*DATA: lv_min_postingdate        TYPE dats,
*      lv_prev_month_first_day   TYPE dats,
*      lv_prev_month_last_day    TYPE dats.
*
*" Giả sử đã tính trước được ngày nhỏ nhất
*lv_min_postingdate = REDUCE #(
*  INIT min = '99991231'
*  FOR wa IN lt_data_h
*  NEXT min = COND #( WHEN wa-postingdate < min THEN wa-postingdate ELSE min )
*).
*
*
*if lv_min_postingdate+4(2) = '01'.
*  lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) - 1 }1201|.
*ELSE.
*if lv_min_postingdate+4(2) - 1  > 9.
*  lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) }{ lv_min_postingdate+4(2) - 1 }01|.
*ELSE.
*    lv_prev_month_first_day  = |{ lv_min_postingdate+0(4) }0{ lv_min_postingdate+4(2) - 1 }01|.
*endif.
*
*endif.
*
*
*    select
*sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency > 0 AND Item_JournalEntry~CompanyCodeCurrency = 'VND' then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as noDauKyVND,
*     sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency <= 0 AND Item_JournalEntry~CompanyCodeCurrency = 'VND'  then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as coDauKyVND,
*sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency > 0 AND Item_JournalEntry~CompanyCodeCurrency <> 'VND' then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as noDauKy,
*     sum( case when Item_JournalEntry~AmountInCompanyCodeCurrency <= 0 AND Item_JournalEntry~CompanyCodeCurrency <> 'VND'  then Item_JournalEntry~AmountInCompanyCodeCurrency END ) as coDauKy
*
**JournalEntry~AccountingDocument,
**Item_JournalEntry~CompanyCodeCurrency,
**Item_JournalEntry~AmountInCompanyCodeCurrency
*    from    I_Supplier         as Supplier
*    left outer join I_JournalEntryItem as Item_JournalEntry on  Supplier~Supplier        = Item_JournalEntry~Supplier
*                                                            and Item_JournalEntry~Ledger = '0L'
*                                                            and Item_JournalEntry~FinancialAccountType =  'K'
*    left outer join I_JournalEntry     as JournalEntry      on JournalEntry~AccountingDocument = Item_JournalEntry~AccountingDocument
*    where JournalEntry~postingdate BETWEEN @lv_prev_month_first_day AND @lv_min_postingdate
*    into table @data(LT_DAUKY).

        READ TABLE keys INTO DATA(ls_key) INDEX 1.
        IF sy-subrc = 0.
          ls_post-giamdoc = ls_key-%param-zgiamdoc.
             ls_post-ketoantruong = ls_key-%param-zketoantruong.
               ls_post-nguoilap = ls_key-%param-znguoilap.
        ENDIF.


    LOOP AT lt_zpm01 ASSIGNING FIELD-SYMBOL(<lfs_zpm01>)."INTO DATA(ls_zsd07).

* Start - Get data lt_journal_entrys
      MOVE-CORRESPONDING <lfs_zpm01> TO ls_journal_entry.

*      ls_supplier-sum_ct9   = ls_supplier-sum_ct9 + <lfs_zpm01>-ct9_nodk_vnd.
*      ls_supplier-sum_ct10  = ls_supplier-sum_ct10 + <lfs_zpm01>-ct10_codk_vnd.
*      ls_supplier-sum_ct11  = ls_supplier-sum_ct11 + <lfs_zpm01>-ct11_nodk.
*      ls_supplier-sum_ct12  = ls_supplier-sum_ct12 + <lfs_zpm01>-ct12_codk.

      ls_supplier-ct13_cpsn_vnd   = ls_supplier-ct13_cpsn_vnd + <lfs_zpm01>-CT30_CURR.
      ls_supplier-ct14_cpsc_vnd   = ls_supplier-ct14_cpsc_vnd + <lfs_zpm01>-CT31_CURR.
      ls_supplier-ct15_cpsn       = ls_supplier-ct15_cpsn + <lfs_zpm01>-CT32_CURR.
      ls_supplier-ct16_cpsc       = ls_supplier-ct16_cpsc + <lfs_zpm01>-CT33_CURR.

      APPEND ls_journal_entry TO lt_journal_entrys.
      CLEAR: ls_journal_entry.

* End - Get data lt_journal_entrys

* Start - Get data lt_suppliers


      AT END OF supplier.
        MOVE-CORRESPONDING <lfs_zpm01> TO ls_supplier_header.
        ls_supplier_header-sum_ct9 = ls_supplier-sum_ct9.
        ls_supplier_header-sum_ct10 = ls_supplier-sum_ct10.
        ls_supplier_header-sum_ct11 = ls_supplier-sum_ct11.
        ls_supplier_header-sum_ct12 = ls_supplier-sum_ct12.

        ls_supplier_header-ct13_cpsn_vnd = ls_supplier-ct13_cpsn_vnd.
        ls_supplier_header-ct14_cpsc_vnd = ls_supplier-ct14_cpsc_vnd.
        ls_supplier_header-ct15_cpsn = ls_supplier-ct15_cpsn.
        ls_supplier_header-ct16_cpsc = ls_supplier-ct16_cpsc.
        IF ( ls_supplier_header-sum_ct9 - ls_supplier_header-sum_ct10 + ls_supplier-ct13_cpsn_vnd + ls_supplier-ct14_cpsc_vnd ) > 0.
          ls_supplier_header-ct17_sdnck_vnd =  ls_supplier_header-sum_ct9 - ls_supplier_header-sum_ct10 + ls_supplier-ct13_cpsn_vnd + ls_supplier-ct14_cpsc_vnd.
        ELSE.
          ls_supplier_header-ct18_sdcck_vnd = ls_supplier_header-sum_ct9 - ls_supplier_header-sum_ct10 + ls_supplier-ct13_cpsn_vnd + ls_supplier-ct14_cpsc_vnd.
        ENDIF.
        IF ( ls_supplier_header-sum_ct11 - ls_supplier_header-sum_ct12 + ls_supplier-ct15_cpsn + ls_supplier-ct16_cpsc ) > 0.
          ls_supplier_header-ct19_sdnck =  ls_supplier_header-sum_ct11 - ls_supplier_header-sum_ct12 + ls_supplier-ct15_cpsn + ls_supplier-ct16_cpsc.
        ELSE.
          ls_supplier_header-ct20_sdcck = ls_supplier_header-sum_ct11 - ls_supplier_header-sum_ct12 + ls_supplier-ct15_cpsn + ls_supplier-ct16_cpsc.
        ENDIF.

        ls_post-sum_cpsn_vnd = ls_post-sum_cpsn_vnd + ls_supplier_header-ct13_cpsn_vnd.
        ls_post-sum_cpsc_vnd = ls_post-sum_cpsc_vnd + ls_supplier_header-ct14_cpsc_vnd.
        ls_post-sum_cpsc = ls_post-sum_cpsc + ls_supplier_header-ct15_cpsn.
        ls_post-sum_cpsc = ls_post-sum_cpsc + ls_supplier_header-ct16_cpsc.
        ls_post-sum_sdnck_vnd = ls_post-sum_sdnck_vnd + ls_supplier_header-ct17_sdnck_vnd.
        ls_post-sum_sdcck_vnd = ls_post-sum_sdcck_vnd + ls_supplier_header-ct18_sdcck_vnd.
        ls_post-sum_sdnck = ls_post-sum_sdnck + ls_supplier_header-ct19_sdnck.
        ls_post-sum_sdcck = ls_post-sum_sdcck + ls_supplier_header-ct20_sdcck.
        ls_supplier_header-journal_entrys = lt_journal_entrys.
        APPEND ls_supplier_header TO lt_suppliers.
        CLEAR: ls_supplier,ls_supplier_header.
      ENDAT.
      AT LAST.
        MOVE-CORRESPONDING <lfs_zpm01> TO ls_post.
      ENDAT.
    ENDLOOP.

    ls_post-suppliers = lt_suppliers.


    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
             iv_service_instance_name   = 'ZADSTEMPLSTORE'
             iv_use_destination_service = abap_false
           ).

        DATA(ls_template) = lo_store->get_template_by_name(
          iv_get_binary    = abap_true
          iv_form_name     = 'ZFA_F_ZPM01'
          iv_template_name = 'ZFA_F_ZPM01'
        ).
      CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    DATA update TYPE TABLE FOR UPDATE zr_fa_zpm01\\zr_fa_zpm01.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_fa_zpm01\\zr_fa_zpm01 .
    DATA lt_update TYPE TABLE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA ls_update TYPE STRUCTURE FOR UPDATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.

    DATA lt_create TYPE TABLE FOR CREATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.
    DATA ls_create TYPE STRUCTURE FOR CREATE zr_tb_fi_pdf_draf\\zrtbfipdfdraf.

    DATA: lv_xml TYPE string.

    lv_xml = '<Header>'.

    lv_xml = |{ lv_xml }<tencty_en>{ ls_post-tencty_vn }</tencty_en>|.
    lv_xml = |{ lv_xml }<diachi_en>{ ls_post-diachi_vn }</diachi_en>|.
    lv_xml = |{ lv_xml }<mst>{ ls_post-mst }</mst>|.
    lv_xml = |{ lv_xml }<tk>{ ls_post-tk }</tk>|.
    lv_xml = |{ lv_xml }<day>{ ls_post-day }</day>|.
    lv_xml = |{ lv_xml }<nguoilap>{ ls_post-nguoilap }</nguoilap>|.

    lv_xml = |{ lv_xml }<sum_cpsn_vnd>{ ls_post-sum_cpsn_vnd }</sum_cpsn_vnd>|.
    lv_xml = |{ lv_xml }<sum_cpsc_vnd>{ ls_post-sum_cpsc_vnd }</sum_cpsc_vnd>|.
    lv_xml = |{ lv_xml }<sum_cpsn>{ ls_post-sum_cpsn }</sum_cpsn>|.
    lv_xml = |{ lv_xml }<sum_cpsc>{ ls_post-sum_cpsc }</sum_cpsc>|.

    lv_xml = |{ lv_xml }<sum_sdnck_vnd>{ ls_post-sum_sdnck_vnd }</sum_sdnck_vnd>|.
    lv_xml = |{ lv_xml }<sum_sdcck_vnd>{ ls_post-sum_sdcck_vnd }</sum_sdcck_vnd>|.
    lv_xml = |{ lv_xml }<sum_sdnck>{ ls_post-sum_sdnck }</sum_sdnck>|.
    lv_xml = |{ lv_xml }<sum_sdcck>{ ls_post-sum_sdcck }</sum_sdcck>|.

    lv_xml = |{ lv_xml }<ketoantruong>{ ls_post-ketoantruong }</ketoantruong>|.
    lv_xml = |{ lv_xml }<giamdoc>{ ls_post-giamdoc }</giamdoc>|.
    lv_xml = |{ lv_xml }<day_print>{ ls_post-day_print }</day_print>|.

    lv_xml = |{ lv_xml }<Suppliers>|.

    LOOP AT ls_post-suppliers INTO DATA(ls_supplierxml).
      lv_xml = |{ lv_xml }<Supplier>|.

      lv_xml = |{ lv_xml }<supplieraccountgroup>{ ls_supplierxml-supplieraccountgroup }</supplieraccountgroup>|.
      lv_xml = |{ lv_xml }<ncc>{ ls_supplierxml-ncc }</ncc>|.

      lv_xml = |{ lv_xml }<sum_ct9>{ ls_supplierxml-sum_ct9 }</sum_ct9>|.
      lv_xml = |{ lv_xml }<sum_ct10>{ ls_supplierxml-sum_ct10 }</sum_ct10>|.
      lv_xml = |{ lv_xml }<sum_ct11>{ ls_supplierxml-sum_ct11 }</sum_ct11>|.
      lv_xml = |{ lv_xml }<sum_ct12>{ ls_supplierxml-sum_ct12 }</sum_ct12>|.

      lv_xml = |{ lv_xml }<ct9_nodk_vnd>{ ls_supplierxml-ct9_nodk_vnd }</ct9_nodk_vnd>|.
      lv_xml = |{ lv_xml }<ct10_codk_vnd>{ ls_supplierxml-ct10_codk_vnd }</ct10_codk_vnd>|.
      lv_xml = |{ lv_xml }<ct11_nodk>{ ls_supplierxml-ct11_nodk }</ct11_nodk>|.
      lv_xml = |{ lv_xml }<ct12_codk>{ ls_supplierxml-ct12_codk }</ct12_codk>|.

      lv_xml = |{ lv_xml }<ct13_cpsn_vnd>{ ls_supplierxml-ct13_cpsn_vnd }</ct13_cpsn_vnd>|.
      lv_xml = |{ lv_xml }<ct14_cpsc_vnd>{ ls_supplierxml-ct14_cpsc_vnd }</ct14_cpsc_vnd>|.
      lv_xml = |{ lv_xml }<ct15_cpsn>{ ls_supplierxml-ct15_cpsn }</ct15_cpsn>|.
      lv_xml = |{ lv_xml }<ct16_cpsc>{ ls_supplierxml-ct16_cpsc }</ct16_cpsc>|.

      lv_xml = |{ lv_xml }<ct17_sdnck_vnd>{ ls_supplierxml-ct17_sdnck_vnd }</ct17_sdnck_vnd>|.
      lv_xml = |{ lv_xml }<ct18_sdcck_vnd>{ ls_supplierxml-ct18_sdcck_vnd }</ct18_sdcck_vnd>|.
      lv_xml = |{ lv_xml }<ct19_sdnck>{ ls_supplierxml-ct19_sdnck }</ct19_sdnck>|.
      lv_xml = |{ lv_xml }<ct20_sdcck>{ ls_supplierxml-ct20_sdcck }</ct20_sdcck>|.

      " Journal Entries
      lv_xml = |{ lv_xml }<JournalEntrys>|.
      LOOP AT ls_supplierxml-journal_entrys INTO DATA(ls_entry).
        lv_xml = |{ lv_xml }<JournalEntry>|.

        lv_xml = |{ lv_xml }<accountingdocument>{ ls_entry-accountingdocument }</accountingdocument>|.
        lv_xml = |{ lv_xml }<journalentrylastchangedatetime>{ ls_entry-journalentrylastchangedatetime }</journalentrylastchangedatetime>|.
        lv_xml = |{ lv_xml }<postingdate>{ ls_entry-postingdate }</postingdate>|.
        lv_xml = |{ lv_xml }<documentreferenceid>{ ls_entry-documentreferenceid }</documentreferenceid>|.
        lv_xml = |{ lv_xml }<accountingdocumentheadertext>{ ls_entry-accountingdocumentheadertext }</accountingdocumentheadertext>|.
        lv_xml = |{ lv_xml }<glaccount_26>{ ls_entry-glaccount_26 }</glaccount_26>|.
        lv_xml = |{ lv_xml }<glaccount_27>{ ls_entry-glaccount_27 }</glaccount_27>|.
        lv_xml = |{ lv_xml }<transactioncurrency>{ ls_entry-transactioncurrency }</transactioncurrency>|.
        lv_xml = |{ lv_xml }<taxexchangerate>{ ls_entry-taxexchangerate }</taxexchangerate>|.
        lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_30>{ ls_entry-amountinbalancetransaccrcy_30 }</amountinbalancetransaccrcy_30>|.
        lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_31>{ ls_entry-amountinbalancetransaccrcy_31 }</amountinbalancetransaccrcy_31>|.
        lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_32>{ ls_entry-amountinbalancetransaccrcy_32 }</amountinbalancetransaccrcy_32>|.
        lv_xml = |{ lv_xml }<amountinbalancetransaccrcy_33>{ ls_entry-amountinbalancetransaccrcy_33 }</amountinbalancetransaccrcy_33>|.

        lv_xml = |{ lv_xml }</JournalEntry>|.

      ENDLOOP.
      lv_xml = |{ lv_xml }</JournalEntrys>|.

      lv_xml = |{ lv_xml }</Supplier>|.
    ENDLOOP.

    lv_xml = |{ lv_xml }</Suppliers>|.

    lv_xml = |{ lv_xml }</Header>|.


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
      CATCH cx_fp_ads_util INTO DATA(lx_error1).
        DATA(lv_err1) = lx_error1->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    LOOP AT keys INTO DATA(ls_key_od).
      update_line-attachment = lv_pdf.
      update_line-mimetype = 'application/pdf'.
      update_line-filename = |{ ls_key_od-%key-accountingdocument }.pdf|.
      APPEND update_line TO update.

      SELECT SINGLE * FROM ztb_fi_pdf_draf WHERE object_id = @ls_key_od-%key-accountingdocument AND report_id = 'ZFA_ZPM01'
      INTO @DATA(lv_exsist).
      IF lv_exsist IS NOT INITIAL.
        ls_update-attachment = lv_pdf.
        ls_update-mimetype = 'application/pdf'.
        ls_update-filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|.
        ls_update-objectid =  ls_key_od-%key-accountingdocument.
        ls_update-reportid = 'ZFA_ZPM01'.
        APPEND ls_update TO lt_update.
      ELSE.
        ls_create-attachment = lv_pdf.
        ls_create-mimetype = 'application/pdf'.
        ls_create-filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|.
        ls_create-objectid =  ls_key_od-%key-accountingdocument.
        ls_create-reportid = 'ZFA_ZPM01'.
        APPEND ls_create TO lt_create.
      ENDIF.
      CLEAR lv_exsist.
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
      READ ENTITIES OF zr_fa_zpm01 IN LOCAL MODE
        ENTITY zr_fa_zpm01
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(lt_data2).
      result = VALUE #( FOR ls_data2 IN lt_data2 ( %tky   = ls_data2-%tky
                                                   %param = ls_data2 ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
