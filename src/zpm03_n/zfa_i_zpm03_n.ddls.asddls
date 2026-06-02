@AbapCatalog.sqlViewName: 'ZFA_V_PM03'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity ZPM03-Bảng kê thuế GTGT đầu vào'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZPM03_N
  as select from    I_JournalEntry           as Fi_head
    left outer join I_JournalEntryItem       as fi_item    on  Fi_head.AccountingDocument   =  fi_item.AccountingDocument
                                                          
                                                          and ( ( ( ( fi_item.GLAccountType        <> 'X'  and fi_item.FinancialAccountType =  'S' )
                                                            or ( fi_item.GLAccountType = 'X'  and fi_item.FinancialAccountType =  'A' )
                                                            
                                                             )
                                                           and fi_item.Ledger               =  '0L'
                                                           and fi_item.TaxCode              is not initial
                                                           ) 
                                                         
                                                            )
    left outer join I_JournalEntryItem       as fi_item_IV on  Fi_head.AccountingDocument      = fi_item_IV.AccountingDocument
                                                           and fi_item_IV.FinancialAccountType = 'S'
                                                           and (
                                                              fi_item_IV.GLAccount             = '3310999901'
                                                              or fi_item_IV.GLAccount          = '3310999902'
                                                            )
                                                           and fi_item_IV.Ledger               = '0L'
    left outer join ZFA_V_TAXITEM            as ItemTax    on 
                                                          ( ItemTax.AccountingDocument     = fi_item.AccountingDocument
                                                           and ItemTax.CompanyCode            = fi_item.CompanyCode
                                                           and ItemTax.AccountingDocumentItem = fi_item.AccountingDocumentItem 
                                                           and ItemTax.LedgerGLLineItem = fi_item.LedgerGLLineItem
                                                           ) 
                                                           or  ( ItemTax.AccountingDocument     = fi_item_IV.AccountingDocument
                                                           and ItemTax.CompanyCode            = fi_item_IV.CompanyCode
                                                           and ItemTax.AccountingDocumentItem = fi_item_IV.AccountingDocumentItem
                                                            and ItemTax.LedgerGLLineItem = fi_item_IV.LedgerGLLineItem
                                                            ) 
  //   left outer join I_OperationalAcctgDocItem as bseg_tax on  bseg_tax.AccountingDocument         = fi_item.AccountingDocument
  //                                                          and bseg_tax.AccountingDocumentItemType = 'T'
  //                                                          and bseg_tax.TaxCode                    = fi_item.TaxCode
//    inner join      ZCDS_FI_KD_DATA          as item_KD    on  item_KD.CompanyCode          = Fi_head.CompanyCode
//                                                           and Fi_head.AccountingDocument   = item_KD.AccountingDocument
//                                                           and Fi_head.FiscalYear           = item_KD.FiscalYear
//                                                           and item_KD.FinancialAccountType = 'K'
    inner join      ZFA_I_KD_PM03         as item_KD    on  item_KD.CompanyCode          = Fi_head.CompanyCode
                                                           and Fi_head.AccountingDocument   = item_KD.AccountingDocument
                                                           and Fi_head.FiscalYear           = item_KD.FiscalYear
                                                           and item_KD.FinancialAccountType = 'K'                                                       
                                                          
    left outer join ZCDS_BP_PROFILE          as Supplier   on item_KD.Customer = Supplier.BusinessPartner
    left outer join I_OneTimeAccountSupplier as OTA_SUP    on  OTA_SUP.AccountingDocument     = item_KD.AccountingDocument
                                                           and OTA_SUP.CompanyCode            = item_KD.CompanyCode
                                                           and OTA_SUP.FiscalYear             = item_KD.FiscalYear
                                                           and OTA_SUP.AccountingDocumentItem = item_KD.AccountingDocumentItem
    left outer join I_ProductText            as _Product   on fi_item.Product = _Product.Product
   
    left outer join ZCDS_COMPANY             as _Company   on Fi_head.CompanyCode = _Company.CompanyCode
    left outer join ZFA_V_LISTTAX_FIDOC as linetax on linetax.AccountingDocument = Fi_head.AccountingDocument
inner join    ztb_fi_ztax              as _Tax_Group on 
                                              (  _Tax_Group.tax_code = fi_item.TaxCode or _Tax_Group.tax_code = fi_item_IV.TaxCode )
                                                           and _Tax_Group.tax_type = 'A'
inner join I_TaxCodeRate on I_TaxCodeRate.TaxCode = _Tax_Group.tax_code and I_TaxCodeRate.Country = 'VN' and I_TaxCodeRate.TaxCalculationProcedure = '0TXVN'

{
  Fi_head.CompanyCode,
  _Company.tencty_vn,
  _Company.diachi_vn,
  _Company.mst                                                                                  as MST_Company,
  Fi_head.AccountingDocument,
  Fi_head.PostingDate,
  concat( substring(Fi_head.PostingDate,5,2), concat('.',substring(Fi_head.PostingDate,1,4) ) ) as Period,
  item_KD.Customer,
  case  when Supplier.IsOneTimeAccount is not initial then
      concat_with_space( OTA_SUP.BusinessPartnerName1,
      concat_with_space( OTA_SUP.BusinessPartnerName2,
      concat_with_space( OTA_SUP.BusinessPartnerName3, OTA_SUP.BusinessPartnerName4, 1), 1) ,1 )

       else Supplier.name  end                                                                  as SupplierName,
  case  when Supplier.IsOneTimeAccount is not initial then
      concat_with_space( OTA_SUP.StreetAddressName, OTA_SUP.CityName, 1)
       else
  Supplier.ADDRESS      end                                                                     as SupplierAdress,
  Supplier.MST                                                                                  as MST_Supplier,
  Fi_head.DocumentReferenceID,
  Fi_head.DocumentDate,
  Fi_head.IsReversed,
  Fi_head.OriginalReferenceDocument,
  cast( _Tax_Group.taxgroup_desc as abap.char( 255 ) )                                          as DGDV,
  _Tax_Group.taxcode_desc,
  _Tax_Group.tax_group,
  case when fi_item.AssignmentReference is not initial then fi_item.AssignmentReference
  else fi_item_IV.AssignmentReference end                                                       as AssignmentReference,
  //   case when    fi_item.DocumentItemText is not initial then  fi_item.DocumentItemText else 'text' end as itemtext,
  case when Fi_head.AccountingDocumentType = 'RE'  then  _Product.ProductName
       when linetax.Count_taxcode = 1 then item_KD.DocumentItemText
       when fi_item.DocumentItemText  is not initial then fi_item.DocumentItemText
                 else 'null' end                                                                as itemtext,
//  case when fi_item.AccountingDocumentItem is not initial then fi_item.AccountingDocumentItem
//  //   when bseg_tax.AccountingDocumentItem is not initial then bseg_tax.AccountingDocumentItem
//    when fi_item_IV.AccountingDocumentItem is not initial then fi_item_IV.AccountingDocumentItem
//  else '001' end                                                                                as acc_item,

  case when fi_item.LedgerGLLineItem is not initial then fi_item.LedgerGLLineItem
    when fi_item_IV.LedgerGLLineItem is not initial then fi_item_IV.LedgerGLLineItem
  else '000001' end                                                                                as acc_item,
  
  ItemTax.AccountingDocumentItem,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  // fi_item.Quantity,

  case when fi_item.Quantity is not initial then fi_item.Quantity
  else fi_item_IV.Quantity end                                                                  as Quantity,
  // fi_item.BaseUnit,
  case when fi_item.BaseUnit is not initial then fi_item.BaseUnit
  else fi_item_IV.BaseUnit end                                                                  as BaseUnit,
  ItemTax.GLAccount,
  //fi_item.GLAccount,
  //  case when fi_item.TaxCode is not initial then fi_item.TaxCode
  //  else fi_item_IV.TaxCode end as TaxCode,
  _Tax_Group.tax_code as TaxCode ,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  //  case when ItemTax.TaxBaseAmountInCoCodeCrcy is not initial then ItemTax.TaxBaseAmountInCoCodeCrcy
  //      when  fi_item.AmountInCompanyCodeCurrency is not initial then  fi_item.AmountInCompanyCodeCurrency
  //       else fi_item_IV.AmountInCompanyCodeCurrency end as amount,
  ItemTax.BaseAmount                                                                            as amount,
  case when ItemTax.CompanyCodeCurrency is not initial then ItemTax.CompanyCodeCurrency
       when fi_item.CompanyCodeCurrency is not initial then fi_item.CompanyCodeCurrency
  else fi_item_IV.CompanyCodeCurrency end                                                       as CompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  cast( ItemTax.Taxamountline  as abap.curr( 17, 2 )    )                                       as Taxamount,
  I_TaxCodeRate.ConditionRateRatio  as TaxRate,
 case when _Tax_Group.tax_code = 'KH' then 'KHAC' else cast( cast( I_TaxCodeRate.ConditionRateRatio  as abap.dec( 24, 9 ) ) as abap.char( 34 ) ) end  as TaxRate_Text,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  //cast( division(
  //    cast( ItemTax.BaseAmount as abap.dec(16, 3)),
  //    cast( coalesce( fi_item.Quantity, 1 )  as abap.dec(10, 3)),
  //    3
  //  )  as abap.curr( 17, 2 )  )  as Price
  case
    when fi_item.Quantity is null or fi_item.Quantity = 0 then ItemTax.BaseAmount
    else cast(
           division(
             cast(coalesce(ItemTax.BaseAmount, 0) as abap.dec(16,3)),
             cast(fi_item.Quantity as abap.dec(10,3)),
             3
           ) as abap.curr(16,2)
         )
  end                                                                                           as Price
//,
//@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
// cast( 0 as abap.int4 ) as  STT   ,
//    @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//  cast( 0 as abap.curr( 17, 2 ) ) as  Totalline  ,
//  
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//  cast( 0 as abap.curr( 17, 2 ) ) as Totalamount  ,
//    @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//  cast( 0 as abap.curr( 17, 2 ) ) as Totaltaxamount ,
//      @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
// cast( 0 as abap.curr( 17, 2 ) ) as  Total_SUMLINE ,
//  
//      @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//   cast( 0 as abap.curr( 17, 2 ) ) as SUMtotal ,
//        @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//   cast( 0 as abap.curr( 17, 2 ) ) as  SUMtotal_VAT   ,
//     @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03_TEST'
//   cast( 0 as abap.dec( 17, 2 ) ) as  testdec 
}
