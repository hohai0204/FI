@AbapCatalog.sqlViewName: 'ZZAA01_TYPE_650'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Amount Transaction Type 650 for ZAA01'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZAA01_650 as select from I_GLAccountLineItemRawData
{
    key SourceLedger,
    key CompanyCode,
    key MasterFixedAsset,
    key FixedAsset,
    FiscalPeriod,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    AmountInBalanceTransacCrcy,
    TransactionCurrency
     
}
where SourceLedger = '0L'
and AssetDepreciationArea = '01'
and AssetTransactionType = '650'
