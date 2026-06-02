@AbapCatalog.sqlViewName: 'ZAA01_GNGTK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View total balance asset with period'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZAA01_GNGTK
  as select from I_GLAccountLineItemRawData as header
  //    left outer join ztb_calendar               as Calendar on Calendar.compnanycode = header.CompanyCode
{
  key     header.SourceLedger,
  key     header.CompanyCode,
  key     header.FiscalYear,
          //  key   header.AccountingDocument,
          //  key   header.LedgerGLLineItem,
  key     header.MasterFixedAsset,
  key     header.FixedAsset,
  key     header.FiscalPeriod                       as report_period,
  key     header.FiscalYear                         as report_year,
          header.LedgerFiscalYear,

          header.FiscalYearPeriod,


          header.TransactionCurrency,

          @Semantics.amount.currencyCode: 'TransactionCurrency'
          sum( header.AmountInTransactionCurrency ) as amount_in_transaction_currency

}
where
       header.SourceLedger         = '0L'
  and  header.DebitCreditCode      = 'H'
  and  header.FinancialAccountType = 'A'
  and(
       header.AssetTransactionType = '105'
    or header.AssetTransactionType = '160'
  )
  and  header.AssetDepreciationArea = '01'
group by
  header.SourceLedger,
  header.CompanyCode,
  header.FiscalYear,
  //  header.AccountingDocument,
  //  header.LedgerGLLineItem,
  header.LedgerFiscalYear,
  header.FiscalPeriod,
  header.FiscalYear,
  header.FiscalYearPeriod,
  header.MasterFixedAsset,
  header.FixedAsset,
  header.TransactionCurrency
