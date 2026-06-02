@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TB_FI_ZTAX
  as select from ztb_fi_ztax
{
  key tax_type as TaxType,
  key tax_group as TaxGroup,
  key tax_code as TaxCode,
  case when tax_type = 'A' then 'BKTGTGT Đầu vào' 
       when tax_type = 'B' then 'BKTGTGT Đầu ra' end as TaxtypeDesc,
  taxgroup_desc as TaxgroupDesc,
  taxcode_desc as TaxcodeDesc,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
