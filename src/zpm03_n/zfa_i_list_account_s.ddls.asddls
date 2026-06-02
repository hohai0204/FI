@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity list FI doc accounttype S'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_LIST_ACCOUNT_S as select from I_JournalEntry as FI_doc
left outer join ZCDS_FI_KD as listKD on listKD.AccountingDocument = FI_doc.AccountingDocument
inner join I_OperationalAcctgDocItem    as fi_item  on fi_item.AccountingDocument = FI_doc.AccountingDocument //and fi_item.AccountingDocumentItemType = 'T'
and fi_item.CompanyCode = FI_doc.CompanyCode and fi_item.FiscalYear = FI_doc.FiscalYear 
inner join I_JournalEntryItem as lineitem on  lineitem.CompanyCode = fi_item.CompanyCode 
and lineitem.FiscalYear = fi_item.FiscalYear and lineitem.AccountingDocument = fi_item.AccountingDocument
and lineitem.AccountingDocumentItem = fi_item.AccountingDocumentItem //and ( lineitem.LedgerGLLineItem = fi_item.LedgerGLLineItem or fi_item.LedgerGLLineItem is initial )
and  lineitem.SourceLedger = '0L'  and lineitem.Ledger = '0L'
left outer join I_Supplier on I_Supplier.TaxNumber1 = fi_item.AssignmentReference and   I_Supplier.TaxNumber1 is not initial
    left outer join ZCDS_BP_PROFILE          as Supplier    on I_Supplier.Supplier  = Supplier.BusinessPartner
   left outer join I_OneTimeAccountSupplier as OTA_SUP     on  OTA_SUP.AccountingDocument     = fi_item.AccountingDocument
                                                            and OTA_SUP.CompanyCode            = fi_item.CompanyCode
                                                            and OTA_SUP.FiscalYear             = fi_item.FiscalYear
                                                            and OTA_SUP.AccountingDocumentItem = fi_item.AccountingDocumentItem
  
{
    
    FI_doc.AccountingDocument,
    FI_doc.CompanyCode,
    FI_doc.FiscalYear,
    fi_item.TaxCode,
    I_Supplier.Supplier ,
      case  when Supplier.IsOneTimeAccount is not initial then
      concat_with_space( OTA_SUP.BusinessPartnerName1,
      concat_with_space( OTA_SUP.BusinessPartnerName2,
      concat_with_space( OTA_SUP.BusinessPartnerName3, OTA_SUP.BusinessPartnerName4, 1), 1) ,1 )

       else Supplier.name1234  end                                                                                                                        as SupplierName,
  case  when Supplier.IsOneTimeAccount is not initial then
      concat_with_space( OTA_SUP.StreetAddressName, OTA_SUP.CityName, 1)
       else
  Supplier.ADDRESS      end                                                                                                                           as SupplierAdress,
  Supplier.MST                 
}
where listKD.AccountingDocument is null and lineitem.YY1_CCT1_JEI is initial and lineitem.YY1_DCCT2_COB is not initial
and ( fi_item.GLAccount like '133%' or  fi_item.GLAccount like '333%' )
