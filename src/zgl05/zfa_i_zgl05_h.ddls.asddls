@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity for ZGL05 PDF Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zfa_i_zgl05_h
  as select from ZFA_I_ZGL05 as Header
//  composition [0..*] of zfa_i_zgl05_i as Item
{
    key CompanyCode,
    key GLAccount,
    GLAccountText, GLAccountLongName
}
 group by CompanyCode, GLAccount, GLAccountText, GLAccountLongName
  
