@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Currency ZGL05 Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet: {
    sizeCategory: #XS
}
define view entity ZI_ZGL05_CurrVH
  as select distinct from ZFA_I_ZGL05
{
  key TransactionCurrency
}
