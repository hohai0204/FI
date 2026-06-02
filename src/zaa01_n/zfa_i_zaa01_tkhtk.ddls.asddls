@AbapCatalog.sqlViewName: 'ZFA_ZAA01_TKHTK'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View tính tăng khấu hao theo kì'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZAA01_TKHTK
  as select from I_GLAccountLineItemRawData as header
{
  key     header.SourceLedger,
  key     header.CompanyCode,
  key     header.FiscalYear,
  key     header.MasterFixedAsset,
  key     header.FixedAsset,
  key     header.FiscalPeriod as report_period,
  key     header.FiscalYear   as report_year,
          header.LedgerFiscalYear,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          sum( AmountInTransactionCurrency ) as tang_khau_hao_trong_ki,
          TransactionCurrency
          
}
where
      header.SourceLedger          = '0L'
  and header.AssetTransactionType  = '500'
  and header.AssetDepreciationArea = '01'
  group by 
          header.SourceLedger,
          header.CompanyCode,
          header.FiscalYear,
          header.MasterFixedAsset,
          header.FixedAsset,
          header.FiscalPeriod,
          header.FiscalYear,
          header.LedgerFiscalYear,
          TransactionCurrency
