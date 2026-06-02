@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity Sum Tax FI Doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_SUM_TAX as select from ZFA_V_TAXFI_SUM as base 
{
  key base.CompanyCode,
  key base.FiscalYear,
  key base.AccountingDocument,
  base.TaxCode,
//  base.DebitCreditCode,
  base.GLAccount,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  sum( base.BaseAmount ) as BaseAmount,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
   sum( base.TaxBaseAmountInCoCodeCrcy ) as TaxBaseAmountInCoCodeCrcy,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  sum( base.TaxAmount ) as TaxAmount,
  base.CompanyCodeCurrency,
  base.TaxRate,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum( base.TaxBaseAmountInTransCrcy ) as TaxBaseAmountInTransCrcy,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum( base.TAXAMOUNTTRANS ) as TAXAMOUNTTRANS,
  base.TransactionCurrency,
  base.YY1_CCT1_JEI
}
group by base.CompanyCode,
  base.FiscalYear,
  base.AccountingDocument,
  base.TaxCode,
// base.DebitCreditCode,
  base.GLAccount,
  base.CompanyCodeCurrency,
  base.TaxRate,
  base.TransactionCurrency,
  base.YY1_CCT1_JEI
