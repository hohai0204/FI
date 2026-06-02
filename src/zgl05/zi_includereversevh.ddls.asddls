@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help Include Reverse Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_IncludeReverseVH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE(
                      p_domain_name : 'ZDO_IN_REVERSE_OPT') as Values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T(
                      p_domain_name : 'ZDO_IN_REVERSE_OPT') as Texts on  Texts.domain_name    = Values.domain_name
                                                                     and Texts.value_position = Values.value_position
                                                                     and Texts.language       = $session.system_language
{
  key cast(Values.value_low as abap_boolean) as Value,
      Texts.text                             as Description
}
