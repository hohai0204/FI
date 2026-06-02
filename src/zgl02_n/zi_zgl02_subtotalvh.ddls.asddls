@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Display Subtotal option'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ZGL02_SubtotalVH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name: 'ZDO_SUBTOTAL_OPT' )   as Values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_SUBTOTAL_OPT' ) as Texts on  Texts.domain_name    = Values.domain_name
                                                                                                and Texts.value_position = Values.value_position
                                                                                                and Texts.language       = $session.system_language
{
  key Values.value_low as Value,
      Texts.text       as Description
}
