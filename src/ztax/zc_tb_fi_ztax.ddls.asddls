@Metadata.allowExtensions: true
@EndUserText.label: 'Bảng kê khai thuế GTGT'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_FI_ZTAX
  provider contract transactional_query
  as projection on ZR_TB_FI_ZTAX
{
  key TaxType,
  key TaxGroup,
  key TaxCode,
  TaxtypeDesc,
  TaxgroupDesc,
  TaxcodeDesc,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
