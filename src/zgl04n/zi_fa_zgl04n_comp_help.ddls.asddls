@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Company Code'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_ZGL04N_COMP_HELP
  as select from ZCDS_COMPANY
{
      @ObjectModel.text.element: [ 'tencty_vn' ]
  key ZCDS_COMPANY.CompanyCode,
      @EndUserText.label: 'Company Name'
      @Semantics.text: true
      ZCDS_COMPANY.tencty_vn
}
