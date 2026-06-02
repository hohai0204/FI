@AbapCatalog.sqlViewName: 'ZFA_V_PM03_K'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity ZPM03-Bảng kê thuế GTGT đầu vào'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZPM03_TYPEK
  as select from    I_JournalEntry           as Fi_head
  inner join I_OperationalAcctgDocItem as tax
  on Fi_head.CompanyCode = tax.CompanyCode
  and Fi_head.AccountingDocument = tax.AccountingDocument
  and tax.AccountingDocumentItemType <> 'T' and tax.GLAccount = '1331000001'
    left outer join I_JournalEntryItem       as fi_item    on  Fi_head.AccountingDocument   =  fi_item.AccountingDocument
                                                          
                                                          and (
                                                            fi_item.Ledger               =  '0L'
                                                           and fi_item.TaxCode              is not initial 
                                                           and fi_item.AccountingDocumentItem = tax.AccountingDocumentItem
                                                           )
  
    left outer join ZFA_V_TAXITEM            as ItemTax    on 
                                                          ( ItemTax.AccountingDocument     = fi_item.AccountingDocument
                                                           and ItemTax.CompanyCode            = fi_item.CompanyCode
           )
//  inner join      ZCDS_FI_KD_DATA          as item_KD    on  item_KD.CompanyCode          = Fi_head.CompanyCode
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
inner join    ztb_fi_ztax              as _Tax_Group on   _Tax_Group.tax_code = ItemTax.TaxCode 
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
 fi_item.AssignmentReference                                                       as AssignmentReference,
  //   case when    fi_item.DocumentItemText is not initial then  fi_item.DocumentItemText else 'text' end as itemtext,
  case when Fi_head.AccountingDocumentType = 'RE'  then  _Product.ProductName
       when linetax.Count_taxcode = 1 then item_KD.DocumentItemText
       when fi_item.DocumentItemText  is not initial then fi_item.DocumentItemText
                 else 'null' end                                                                as itemtext,
  case when fi_item.AccountingDocumentItem is not initial then fi_item.AccountingDocumentItem
  else '001' end                                                                                as acc_item,
  ItemTax.AccountingDocumentItem,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
fi_item.Quantity                                                                 as Quantity,
 fi_item.BaseUnit                                                                  as BaseUnit,
  ItemTax.GLAccount,
  tax.TaxCode as TaxCode ,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  ItemTax.BaseAmount                                                                            as amount,
  case when ItemTax.CompanyCodeCurrency is not initial then ItemTax.CompanyCodeCurrency
       when fi_item.CompanyCodeCurrency is not initial then fi_item.CompanyCodeCurrency
 end                                                       as CompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  cast( ItemTax.Taxamountline  as abap.curr( 17, 2 )    )                                       as Taxamount,
I_TaxCodeRate.ConditionRateRatio  as TaxRate,
  case when _Tax_Group.tax_code = 'KH' then 'KHAC' else cast( cast( I_TaxCodeRate.ConditionRateRatio  as abap.dec( 24, 9 ) ) as abap.char( 34 ) ) end  as TaxRate_Text,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
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

}
