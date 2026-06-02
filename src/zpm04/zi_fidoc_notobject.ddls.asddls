@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'List FI Doc không hạch toán đối tượng'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FIDOC_NOTOBJECT as select from I_JournalEntryItem as Bseg_1
left outer join I_JournalEntryItem as Bseg_2 on Bseg_1.AccountingDocument = Bseg_2.AccountAssignment
and Bseg_1.CompanyCode = Bseg_2.CompanyCode and Bseg_1.FiscalYear = Bseg_2.FiscalYear
and ( Bseg_2.FinancialAccountType = 'D' or Bseg_2.FinancialAccountType = 'K' )
inner join I_JournalEntry as bkpf on bkpf.AccountingDocument =  Bseg_1.AccountingDocument 
and Bseg_1.CompanyCode = bkpf.CompanyCode and Bseg_1.FiscalYear = bkpf.FiscalYear
{
    bkpf.AccountingDocument,
    bkpf.CompanyCode,
    bkpf.FiscalYear,
    min( Bseg_1.AccountingDocumentItem ) as item
}
where Bseg_2.AccountingDocument is null and Bseg_1.YY1_DiaChi1_COB is not initial
group by bkpf.AccountingDocument,
    bkpf.CompanyCode,
    bkpf.FiscalYear
