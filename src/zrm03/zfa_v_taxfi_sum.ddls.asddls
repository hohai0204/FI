@AbapCatalog.sqlViewName: 'ZVFA_TAXSUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Tax FA SUM TaxCode'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_TAXFI_SUM as select from ZFA_V_TAXITEM as base
inner join I_OperationalAcctgDocItem as tax
  on base.CompanyCode = tax.CompanyCode
  and base.AccountingDocument = tax.AccountingDocument
   and base.AccountingDocumentItem = tax.AccountingDocumentItem
  and base.tAXCODE_AT = tax.TaxCode
// and tax.AccountingDocumentItemType <> 'T'
{
  key base.CompanyCode,
  key base.FiscalYear,
  key base.AccountingDocument,
  base.TaxCode,
// base.DebitCreditCode,
  base.GLAccount,
  base.TaxBaseAmountInCoCodeCrcy as BaseAmount,
  base.TaxBaseAmountInCoCodeCrcy,
  base.TaxAmount,
  base.CompanyCodeCurrency,
  base.TaxRate,
  base.TaxBaseAmountInTransCrcy,
  base.TAXAMOUNTTRANS,
  base.TransactionCurrency,
  base.YY1_CCT1_JEI,
  tax.AccountingDocumentItem
}
where ( base.FinancialAccountType = 'S' or base.FinancialAccountType = 'A' )
and  base.AccountingDocumentItemType <> 'R'
//where base.DebitCreditCode = 'S'
group by    base.CompanyCode,
base.FiscalYear,
  base.AccountingDocument,
  base.TaxCode,
// base.DebitCreditCode,
  base.GLAccount,
  base.TaxBaseAmountInCoCodeCrcy,
 // base.BaseAmount,
  base.TaxAmount,
  base.CompanyCodeCurrency,
  base.TaxRate,
    base.TaxBaseAmountInTransCrcy,
  base.TAXAMOUNTTRANS,
  base.TransactionCurrency,
   base.YY1_CCT1_JEI,
   tax.AccountingDocumentItem
  // data FI doc Taxcode can have TAX amount
  union select  from I_JournalEntryItem as base
inner join I_JournalEntry on I_JournalEntry.AccountingDocument = base.AccountingDocument
and I_JournalEntry.FiscalYear = base.FiscalYear and I_JournalEntry.CompanyCode = base.CompanyCode
left outer join I_OperationalAcctgDocItem as tax
  on base.CompanyCode = tax.CompanyCode
  and base.AccountingDocument = tax.AccountingDocument
  and base.TaxCode = tax.TaxCode
  and ( tax.AccountingDocumentItemType = 'T' or tax.GLAccount = '1331000001' or tax.GLAccount ='3331000001' )
      inner join      I_TaxCodeRate                           on  I_TaxCodeRate.TaxCode                 = base.TaxCode
                                                            and I_TaxCodeRate.Country                 = 'VN'
                                                            and I_TaxCodeRate.TaxCalculationProcedure = '0TXVN'
{
  key base.CompanyCode,
  key base.FiscalYear,
  key base.AccountingDocument,
  base.TaxCode,
// base.DebitCreditCode,
  case 
  when tax.GLAccount <> '' then tax.GLAccount
  when base.TaxCode like 'O%'  then '3331000001'
  else '1331000001'
end as GLAccount,
 sum( base.AmountInCompanyCodeCurrency )  as BaseAmount,
// case when 
 
 cast( 0  as abap.curr( 20, 2 )) as TaxBaseAmountInCoCodeCrcy,
 cast( 0  as abap.curr( 20, 2 )) as TaxAmount,
  
base.CompanyCodeCurrency,

  cast( I_TaxCodeRate.ConditionRateRatio  as abap.dec( 5, 2 ) )  as TaxRate,
  sum( base.AmountInTransactionCurrency ) as TaxBaseAmountInTransCrcy,
  cast( 0  as abap.curr( 20, 2 )) as TAXAMOUNTTRANS,
  base.TransactionCurrency,
   base.YY1_CCT1_JEI,
   tax.AccountingDocumentItem
}
where  base.TaxCode is not initial  and base.Ledger = '0L'  
and tax.AccountingDocument is null //and base.DebitCreditCode = 'S'
and  base.FinancialAccountType = 'S' 
group by   base.CompanyCode,
 base.AccountingDocument,
  base.FiscalYear,
  base.TaxCode,
//  base.DebitCreditCode,
  base.FinancialAccountType,
  tax.GLAccount,
  tax.AmountInCompanyCodeCurrency,
  base.CompanyCodeCurrency,
  I_JournalEntry.ExchangeRate,
  tax.TaxBaseAmountInCoCodeCrcy ,
  I_TaxCodeRate.ConditionRateRatio,
  base.TransactionCurrency,
   base.YY1_CCT1_JEI,
   tax.AccountingDocumentItem
