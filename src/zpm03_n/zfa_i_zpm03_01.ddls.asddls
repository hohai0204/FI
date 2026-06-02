@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Enity for ZPM03 logic phân line theo TaxCode'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZPM03_01
  as select from    I_JournalEntry           as Fi_head

    left outer join ZFA_I_KD_PM03            as item_KD     on  item_KD.CompanyCode          = Fi_head.CompanyCode
                                                            and Fi_head.AccountingDocument   = item_KD.AccountingDocument
                                                            and Fi_head.FiscalYear           = item_KD.FiscalYear
                                                            and item_KD.FinancialAccountType = 'K'

    left outer join ZCDS_BP_PROFILE          as Supplier    on item_KD.Customer = Supplier.BusinessPartner
    left outer join I_OneTimeAccountSupplier as OTA_SUP     on  OTA_SUP.AccountingDocument     = item_KD.AccountingDocument
                                                            and OTA_SUP.CompanyCode            = item_KD.CompanyCode
                                                            and OTA_SUP.FiscalYear             = item_KD.FiscalYear
                                                            and OTA_SUP.AccountingDocumentItem = item_KD.AccountingDocumentItem

    left outer join ZCDS_COMPANY             as _Company    on Fi_head.CompanyCode = _Company.CompanyCode
    left outer join ZFA_V_LISTTAX_FIDOC      as linetax     on  linetax.AccountingDocument = Fi_head.AccountingDocument
                                                            and linetax.CompanyCode        = Fi_head.CompanyCode
                                                            and linetax.FiscalYear         = Fi_head.FiscalYear
    left outer join ZFA_V_TAXFI_SUM          as ItemTax     on  ItemTax.AccountingDocument = Fi_head.AccountingDocument
                                                            and ItemTax.CompanyCode        = Fi_head.CompanyCode
                                                            and ItemTax.FiscalYear         = Fi_head.FiscalYear
    left outer join ZFA_V_MINITEMTAX_LG      as minitem_tax on  Fi_head.AccountingDocument = minitem_tax.AccountingDocument
                                                            and Fi_head.FiscalYear         = minitem_tax.FiscalYear
                                                            and Fi_head.CompanyCode        = minitem_tax.CompanyCode
                                                            and ItemTax.TaxCode            = minitem_tax.TAXcode_CV
    left outer join I_JournalEntryItem       as fi_item     on  minitem_tax.AccountingDocument = fi_item.AccountingDocument
                                                            and minitem_tax.CompanyCode        = fi_item.CompanyCode
                                                            and minitem_tax.FiscalYear         = fi_item.FiscalYear
                                                            and minitem_tax.TaxCode            = fi_item.TaxCode
                                                            and fi_item.Ledger                 = '0L'
                                                            and fi_item.AccountingDocumentItem = minitem_tax.AccountingDocumentItem
                                                            and fi_item.LedgerGLLineItem       = minitem_tax.LG_Item
  //left outer join ZFA_I_QUAN_SUM_FIDOC as Quantity on Quantity.AccountingDocument =  Fi_head.AccountingDocument
  /// and     Fi_head.FiscalYear         = Quantity.FiscalYear
  //   and     ItemTax.TaxCode          = Quantity.TaxCode
    inner join      ztb_fi_ztax              as _Tax_Group  on  (
         _Tax_Group.tax_code                                                        = ItemTax.TaxCode
       )
                                                            and _Tax_Group.tax_type = 'A'
    inner join      I_TaxCodeRate                           on  I_TaxCodeRate.TaxCode                 = _Tax_Group.tax_code
                                                            and I_TaxCodeRate.Country                 = 'VN'
                                                            and I_TaxCodeRate.TaxCalculationProcedure = '0TXVN'
    left outer join ZI_FA_FI_QUANTITY_PM03   as Quantity    on  Quantity.AccountingDocument = Fi_head.AccountingDocument
                                                            and Fi_head.FiscalYear          = Quantity.FiscalYear
                                                            and Fi_head.CompanyCode         = Quantity.CompanyCode
    left outer join ZI_FA_FIDOC_REV_01       as REv01       on  REv01.AccountingDocument = Fi_head.AccountingDocument
                                                            and REv01.FiscalYear         = Fi_head.FiscalYear
                                                            and REv01.CompanyCode        = Fi_head.CompanyCode
    left outer join ZI_FA_FIDOC_REV_01       as REv01_r     on  REv01_r.ReverseDocument    = Fi_head.AccountingDocument
                                                            and REv01_r.ReverseFiscalYear  = Fi_head.FiscalYear
                                                            and REv01_r.ReverseCompanyCode = Fi_head.CompanyCode
    left outer join I_JournalEntry           as RE_journal  on  RE_journal.ReversalReferenceDocument = substring(
      Fi_head.OriginalReferenceDocument, 1, 10
    )
                                                            and RE_journal.ReverseDocumentFiscalYear = substring(
      Fi_head.OriginalReferenceDocument, 11, 4
    )

                                                            and (
                                                               RE_journal.IsReversal                 is not initial
                                                               or RE_journal.IsReversed              is not initial
                                                             )

    left outer join ZI_FA_FIDOC_A_V_DCCT1    as DCCT1       on  DCCT1.AccountingDocument = Fi_head.AccountingDocument
                                                            and Fi_head.FiscalYear       = DCCT1.FiscalYear
                                                            and Fi_head.CompanyCode      = DCCT1.CompanyCode

    left outer join ZFA_I_LIST_S_ITEMTEXT    as itemtextS   on  itemtextS.AccountingDocument = Fi_head.AccountingDocument
                                                            and Fi_head.FiscalYear           = itemtextS.FiscalYear
                                                            and Fi_head.CompanyCode          = itemtextS.CompanyCode
    left outer join ZFA_I_LIST_ACCOUNT_S     as listaccS    on  listaccS.AccountingDocument = Fi_head.AccountingDocument
                                                            and listaccS.TaxCode            = I_TaxCodeRate.TaxCode
                                                            and Fi_head.FiscalYear          = listaccS.FiscalYear
                                                            and Fi_head.CompanyCode         = listaccS.CompanyCode
    left outer join zi_view_tennguoiban      as tennguoiban on  tennguoiban.AccountingDocument = Fi_head.AccountingDocument
                                                            and tennguoiban.CompanyCode        = Fi_head.CompanyCode
                                                                and tennguoiban.AccountingDocumentItem = ItemTax.AccountingDocumentItem  
    left outer join ZI_VIEW_MST              as mst         on  mst.AccountingDocument = Fi_head.AccountingDocument
                                                            and mst.CompanyCode        = Fi_head.CompanyCode
                                                            and mst.AccountingDocumentItem = ItemTax.AccountingDocumentItem  

{
  Fi_head.CompanyCode,
  _Company.tencty_vn,
  _Company.diachi_vn23                                                                                                                                as diachi_vn,
  _Company.mst                                                                                                                                        as MST_Company,
  Fi_head.AccountingDocument,
  ItemTax.AccountingDocumentItem                                                                                                                      as AccItemTax,
  Fi_head.PostingDate,
  concat( substring(Fi_head.PostingDate,5,2), concat('.',substring(Fi_head.PostingDate,1,4) ) )                                                       as Period,
  item_KD.Customer,
  tennguoiban.YY1_TDV_JEI                                                                                                                             as SupplierName_th1,

  //  case when item_KD.Customer is not initial then
  //   case  when Supplier.IsOneTimeAccount is not initial then
  //       concat_with_space( OTA_SUP.BusinessPartnerName1,
  //       concat_with_space( OTA_SUP.BusinessPartnerName2,
  //       concat_with_space( OTA_SUP.BusinessPartnerName3, OTA_SUP.BusinessPartnerName4, 1), 1) ,1 )
  //
  //        else Supplier.name  end
  //    else
  //      listaccS.SupplierName
  //        end                                                                                                                                           as SupplierName,
  case
      when tennguoiban.YY1_TDV_JEI is not null
          then tennguoiban.YY1_TDV_JEI
      else
          case
              when item_KD.Customer is not null
                  then
  //                        case
  //                            when Supplier.IsOneTimeAccount is not null
  //                                then concat_with_space(
  //                                        OTA_SUP.BusinessPartnerName1,
  //                                        concat_with_space(
  //                                            OTA_SUP.BusinessPartnerName2,
  //                                            concat_with_space(
  //                                                OTA_SUP.BusinessPartnerName3,
  //                                                OTA_SUP.BusinessPartnerName4,
  //                                                1
  //                                            ),
  //                                            1
  //                                        ),
  //                                        1
  //                                    )
  //                            else Supplier.name
  //                        end
                Supplier.name1234
              else listaccS.SupplierName
          end
  end                                                                                                                                                 as SupplierName,


  case when item_KD.Customer is not initial then
  case  when Supplier.IsOneTimeAccount is not initial then
      concat_with_space( OTA_SUP.StreetAddressName, OTA_SUP.CityName, 1)
       else
  Supplier.ADDRESS      end
    else
     listaccS.SupplierAdress
       end                                                                                                                                            as SupplierAdress,


  //  case when item_KD.Customer is not initial then Supplier.MST    else       listaccS.MST end                                                          as MST_Supplier,
  //  case when item_KD.Customer is not initial then Supplier.MST    else   mst.AssignmentReference     end                                               as MST_Supplier,
  case when  mst.AssignmentReference is not initial then mst.AssignmentReference
  else Supplier.MST  end                                                                                                                              as MST_Supplier,
  Fi_head.DocumentReferenceID,
// fi_item.YY1_SoHoaDon_1_COB as DocumentReferenceID,
  Fi_head.DocumentDate,
  case when REv01.ReverseDocument is not initial then REv01.ReverseDocument
      when REv01_r.AccountingDocument  is not initial then REv01_r.AccountingDocument  end                                                            as ReverseDocument,
  @Semantics.signReversalIndicator: true
  case when REv01.PeriodRV is not initial then REv01.Isrevered
       when REv01_r.PeriodRV  is not initial then REv01_r.Isrevered
      else '' end                                                                                                                                     as IsReversed,

  Fi_head.OriginalReferenceDocument,
  cast( _Tax_Group.taxgroup_desc as abap.char( 255 ) )                                                                                                as DGDV,
  _Tax_Group.taxcode_desc,
  _Tax_Group.tax_group,
    fi_item.AssignmentReference                                                                                                                         as AssignmentReference,
//  fi_item.YY1_SoHoaDon_1_COB                                                                                                                          as AssignmentReference,
  case when Fi_head.AccountingDocumentType = 'RE' then Quantity.shorttext
  else
   case
        when item_KD.DocumentItemText is not initial or fi_item.DocumentItemText is not initial
            then case when linetax.Count_taxcode = 1 then
                           case when item_KD.DocumentItemText is not initial then item_KD.DocumentItemText else fi_item.DocumentItemText  end
                     when fi_item.DocumentItemText  is not initial then fi_item.DocumentItemText end
        when itemtextS.DocumentItemText is not initial then  itemtextS.DocumentItemText

                      else Fi_head.AccountingDocumentHeaderText end

                    end                                                                                                                               as itemtext,
  case
  when ItemTax.AccountingDocumentItem is not initial then ItemTax.AccountingDocumentItem
  when fi_item.LedgerGLLineItem is not initial then fi_item.LedgerGLLineItem
  else '000000' end                                                                                                                                   as acc_item,

  minitem_tax.AccountingDocumentItem,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  // fi_item.Quantity,

  case when Quantity.Quantity  is not initial then     Quantity.Quantity else cast(1 as abap.quan( 10, 3 )) end                                       as Quantity,
  // fi_item.BaseUnit,
  case when Quantity.Unit is not initial then  Quantity.Unit  else cast('CAI' as meins ) end                                                          as BaseUnit,
  ItemTax.GLAccount,
  _Tax_Group.tax_code                                                                                                                                 as TaxCode,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  ItemTax.BaseAmount                                                                                                                                  as amount,
  case when ItemTax.CompanyCodeCurrency is not initial then ItemTax.CompanyCodeCurrency
       else  fi_item.CompanyCodeCurrency end                                                                                                          as CompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  cast(  ItemTax.TaxAmount   as abap.curr( 17, 2 )    )                                                                                               as Taxamount,
  ItemTax.TaxRate,
  case when _Tax_Group.tax_code = 'KH' then 'KHAC' else cast( cast( I_TaxCodeRate.ConditionRateRatio  as abap.dec( 24, 2 ) ) as abap.char( 27 ) ) end as TaxRate_Text,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  case
    when  Quantity.Quantity is initial or Quantity.Quantity = 0 or Quantity.Quantity is null then ItemTax.BaseAmount
    else cast(
           division(
             cast(coalesce(ItemTax.BaseAmount,cast( 0 as abap.curr( 17, 2 ) ) ) as abap.dec(16,3)) ,
             cast(Quantity.Quantity as abap.dec(10,3)),
             3
           ) as abap.curr(16,2)
         )
  end                                                                                                                                                 as Price,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  ItemTax.TaxBaseAmountInTransCrcy,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  ItemTax.TAXAMOUNTTRANS,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  ItemTax.TaxBaseAmountInTransCrcy + ItemTax.TAXAMOUNTTRANS                                                                                           as amount_NT,
  ItemTax.TransactionCurrency
}
where
       Fi_head.AccountingDocumentType <> 'CL'
  and  Fi_head.AccountingDocumentType <> 'DA'
  and  Fi_head.AccountingDocumentType <> 'SA'
  and  Fi_head.AccountingDocumentType <> 'DR'
  and  Fi_head.AccountingDocumentType <> 'DG'
  and  Fi_head.AccountingDocumentType <> 'RV'

  and(
       DCCT1.AccountingDocument       is null
    or I_TaxCodeRate.TaxType          <> 'V'
  )
