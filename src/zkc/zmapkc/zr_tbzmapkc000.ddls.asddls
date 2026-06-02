@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBZMAPKC000'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBZMAPKC000
  as select from ztb_zmapkc
  association [0..1] to I_SupplierCompany as Account on Account.Supplier = $projection.account and Account.CompanyCode = $projection.Bukrs
  association [0..1] to zi_rult_f4 as RultText on $projection.Rulty = RultText.value_low
{
  key sacct                 as Sacct,
  key bukrs                 as Bukrs,
      rulty                 as Rulty,
      RultText.text         as Rultname,
      dacct                 as Dacct,
      dcost                 as Dcost,
      Account.ReconciliationAccount as Dacct2,
      acct as account,
      dprctr                as Dprctr,
      oacct                 as Oacct,
      ocost                 as Ocost,
      oprctr                as Oprctr,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
