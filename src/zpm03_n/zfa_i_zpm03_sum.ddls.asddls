@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity Sum ZPM03'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZPM03_SUM as select from ZFA_I_ZPM03_NW as main
{
 main.DGDV,
 @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
 sum( main.Taxamount ) as Taxamount,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
 sum( main.amount ) as amount,
 CompanyCodeCurrency
}
group by main.DGDV, CompanyCodeCurrency
