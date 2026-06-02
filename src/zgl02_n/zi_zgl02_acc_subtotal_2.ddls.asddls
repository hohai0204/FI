@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity View Subtotal Level 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ZGL02_ACC_SUBTOTAL_2
  as select from I_GLAccountLineItemRawData as balance
{
  key balance.SourceLedger,
  key cast( left( balance.GLAccount, 4 ) as zzde_racct) as GLAccount,
  key balance.CompanyCode,
  key balance.FiscalYear,
  key balance.FiscalPeriod,
      balance.CompanyCodeCurrency,

      'LEVEL2'                                          as SubtotalOpt,
      'dummy'                                           as dummy
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
