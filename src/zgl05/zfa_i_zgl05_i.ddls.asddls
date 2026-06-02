@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity for ZGL05 PDF Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zfa_i_zgl05_i
  as select from zfa_i_zgl05_h
  //  association [1..*] to ZFA_CE_ZGL05 as CustomEntity on  CustomEntity.CompanyCode = $projection.CompanyCode
  //                                                     and CustomEntity.GLAccount   = $projection.GLAccount
  //  association to parent zfa_i_zgl05_h as Header on  $projection.CompanyCode = Header.CompanyCode
  //                                                and $projection.GLAccount   = Header.GLAccount
{
  key CompanyCode,
  key GLAccount

}
