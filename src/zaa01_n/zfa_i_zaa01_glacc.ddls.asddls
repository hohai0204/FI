@AbapCatalog.sqlViewName: 'ZGLACCZAA01'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View GL Account for ZAA01'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_ZAA01_GLACC 
with parameters p_asset_trans_type : abap.char(3)
as select from I_GLAccountLineItemRawData

{
    key CompanyCode,
    key MasterFixedAsset,
    key FixedAsset,
    key AssetClass,
    FiscalYear,
    GLAccount,
    AssetTransactionType,
    PostingKey
    
}
where AssetTransactionType = $parameters.p_asset_trans_type
and AssetClass is not initial
and SourceLedger = '0L'
