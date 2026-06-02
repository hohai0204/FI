@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rule Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_rult_f4 as select from   
 DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZDO_RULTY_2')
{
    @UI: {
        hidden: true
    }
    key domain_name,
    
    @UI: {
        hidden: true
    }
    key value_position,
    
    @Semantics.language: true
    key language,
    
    value_low,
    
    @Semantics.text: true
    text
}
