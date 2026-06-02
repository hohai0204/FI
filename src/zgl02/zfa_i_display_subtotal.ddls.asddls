@AbapCatalog.sqlViewName: 'ZDISPLAYSUBTOTAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Display Subtotal'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_I_DISPLAY_SUBTOTAL
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_DISPLAY_SUBTOTAL')
{
  key value_position,
      @Semantics.language: true
  key language,
      value_low,
      @Semantics.text: true
      text
}
