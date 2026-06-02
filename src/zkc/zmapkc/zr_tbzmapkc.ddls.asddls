@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBZMAPKC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBZMAPKC
  as select from ztb_zmapkc
  //  association to parent ZR_TBZMAPKC_H as _Header on $projection.Bukrs = _Header.bukrs
  association[0..1] to zi_rult_f4 as RultText on $projection.Rulty = RultText.value_low
{
key sacct as Sacct,
key  bukrs as Bukrs,

 rulty as Rulty,
RultText.text as RulTName,
 
  dacct as Dacct,
  dcost as Dcost,
  oacct as Oacct,
  ocost as Ocost,
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
 //  _Header // Make association public
}
