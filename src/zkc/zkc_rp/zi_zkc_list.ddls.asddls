@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for list data in ZKC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ZKC_LIST 
with parameters p_startdate : abap.dats,
                  p_enddate : abap.dats 
as select from I_GLAccountLineItem   as GLLine
{
 key GLLine.GLAccount,
 GLLine.CompanyCode,
 GLLine.FiscalYear,
 GLLine.FiscalPeriod,
 GLLine.CompanyCodeCurrency,
 @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
 sum(  GLLine.AmountInCompanyCodeCurrency ) as Amount
}
where GLLine.Ledger = '0L' and GLLine.SourceLedger = '0L' 
//and GLLine.IsReversal is initial
//and GLLine.IsReversed is initial and GLLine.ClearingJournalEntry is initial
//and GLLine.IsOpenItemManaged is not initial
and GLLine.PostingDate >= $parameters.p_startdate 
and GLLine.PostingDate <= $parameters.p_enddate 
group by GLLine.GLAccount,
 GLLine.CompanyCode,
 GLLine.FiscalYear,
  GLLine.FiscalPeriod,
 GLLine.CompanyCodeCurrency
