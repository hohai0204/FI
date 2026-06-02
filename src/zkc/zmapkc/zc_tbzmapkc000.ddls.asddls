@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Mapping TK Kết chuyển cuối kỳ'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBZMAPKC000'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBZMAPKC000
  provider contract transactional_query
  as projection on ZR_TBZMAPKC000
  association [1..1] to ZR_TBZMAPKC000 as _BaseEntity on $projection.Sacct = _BaseEntity.Sacct and $projection.Bukrs = _BaseEntity.Bukrs
{
  key Sacct,
  key Bukrs,  
  @ObjectModel.text.element: [ 'RulTName' ]
    @Consumption.valueHelpDefinition: [ { entity: { name: 'zi_rult_f4', element: 'value_low' },
                                            distinctValues: true,
                                             label  : 'Rule Type - Value Help', useForValidation: true
                                            } ]
  
  Rulty,
  Rultname,
  Dacct,
  Dcost,
  Dacct2,
  account,
  Dprctr,
  Oacct,
  Ocost,
  Oprctr,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
    @Consumption.filter.selectionType: #RANGE
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
    @Consumption.filter.selectionType: #RANGE
  LastChangedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
    @Consumption.filter.selectionType: #RANGE
  LocalLastChangedAt,
  _BaseEntity
}
