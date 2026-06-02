@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address FI Doc không hạch toán đối tượng'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FIDOC_NOTOBJECT_ADDRESS as select from ZI_FIDOC_NOTOBJECT as object
inner join I_JournalEntryItem as bseg on object.AccountingDocument = bseg.AccountingDocument
and object.CompanyCode = bseg.CompanyCode and object.FiscalYear = bseg.FiscalYear
and object.item = bseg.AccountingDocumentItem and  bseg.Ledger = '0L'
{
    object.AccountingDocument,
    object.CompanyCode,
    object.FiscalYear,
    bseg.YY1_DiaChi1_COB
}
