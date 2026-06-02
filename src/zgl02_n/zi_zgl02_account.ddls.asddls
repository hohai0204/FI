//@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity View ZGL02'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ZGL02_ACCOUNT 
as select from ZI_ZGL02_ACC_SUBTOTAL_D as d
inner join ZI_ZGL02_PERIOD as period on period.dummy = d.dummy
{
    key d.SourceLedger,
    key d.GLAccount,
    key d.CompanyCode,
    key d.FiscalYear,
    period.period,
    d.CompanyCodeCurrency,
    d.SubtotalOpt    
}

union select from ZI_ZGL02_ACC_SUBTOTAL_1 as l1
inner join ZI_ZGL02_PERIOD as period on period.dummy = l1.dummy
{
    key l1.SourceLedger,
    key l1.GLAccount,
    key l1.CompanyCode,
    key l1.FiscalYear,
    period.period,
    l1.CompanyCodeCurrency,
    l1.SubtotalOpt
}

union select from ZI_ZGL02_ACC_SUBTOTAL_2 as l2
inner join ZI_ZGL02_PERIOD as period on period.dummy = l2.dummy
{
    key l2.SourceLedger,
    key l2.GLAccount,
    key l2.CompanyCode,
    key l2.FiscalYear,
    period.period,
    l2.CompanyCodeCurrency,
    l2.SubtotalOpt
}
