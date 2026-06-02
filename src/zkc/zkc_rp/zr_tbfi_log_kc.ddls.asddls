@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBFI_LOG_KC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBFI_LOG_KC
  as select from ZTB_FI_LOG_KC
{
  key rulty as Rulty,
  key lineid as Lineid,
  key bukrs as Bukrs,
  key fiscalyear as Fiscalyear,
  key period as Period,
  key accountingdocumenttype as Accountingdocumenttype,
  key documentdate as Documentdate,
  key postingdate as Postingdate,
  key accountingdocumentheadertext as Accountingdocumentheadertext,
  key isreversed as Isreversed,
  sacct as Sacct,
  dacct as Dacct,
  dcost as Dcost,
  oacct as Oacct,
  ocost as Ocost,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  waers as Waers,
  amount as Amount,
  belnr as Belnr,
  gjahr as Gjahr,
  belnr_r as BelnrR,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
