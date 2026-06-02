@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity list FI doc accounttype S Item Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_LIST_S_ITEMTEXT as select from ZFA_I_LIST_ACCOUNT_S_ITEMTEXT as FI_doc
inner join I_OperationalAcctgDocItem     as fi_item  on fi_item.AccountingDocument = FI_doc.AccountingDocument 
and fi_item.CompanyCode = FI_doc.CompanyCode
and fi_item.FiscalYear = FI_doc.FiscalYear
and fi_item.AccountingDocumentItem = FI_doc.Item
{
   FI_doc.AccountingDocument,
       FI_doc.CompanyCode,
    FI_doc.FiscalYear,
   fi_item.DocumentItemText
}

