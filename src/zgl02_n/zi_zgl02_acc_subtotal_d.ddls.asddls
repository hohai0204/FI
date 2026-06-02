//@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity View Subtotal Detail'
//@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ZGL02_ACC_SUBTOTAL_D
  as select from I_GLAccountLineItemRawData as balance
{
  key balance.SourceLedger,
  key cast( balance.GLAccount as zzde_racct) as GLAccount,
  key balance.CompanyCode,
  key balance.FiscalYear,
  key balance.FiscalPeriod,
      balance.CompanyCodeCurrency,

      'DETAIL'                               as SubtotalOpt,
      'dummy'                                as dummy
}

where
      balance.ChartOfAccounts = 'YCOA'
  and balance.SourceLedger    = '0L'

group by
  balance.SourceLedger,
  balance.GLAccount,
  balance.CompanyCode,
  balance.FiscalYear,
  balance.FiscalPeriod,
  balance.CompanyCodeCurrency
