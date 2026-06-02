@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help  Is Revesed'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ISREVESED_VKH as select from 
 DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZDO_ISREVESED')
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
