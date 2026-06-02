@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity list FI Doc convert Tax Type A to Type V'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_FIDOC_A_V_DCCT1 as select from  I_JournalEntryItem as FIdoc
{
    FIdoc.AccountingDocument,
    FIdoc.CompanyCode,
    FIdoc.FiscalYear
}
where FIdoc.YY1_CCT1_JEI is not initial  and FIdoc.YY1_DCCT2_COB is initial
//and FIdoc.TaxCode is not initial
group by FIdoc.AccountingDocument ,    FIdoc.CompanyCode,
    FIdoc.FiscalYear
