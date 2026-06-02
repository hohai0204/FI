@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Mapping tài khoản kết chuyển'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBZMAPKC'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED

define root view entity ZC_TBZMAPKC
 provider contract transactional_query
  as  projection  on ZR_TBZMAPKC
{
key  Sacct,

key   Bukrs,
  @ObjectModel.text.element: [ 'RulTName' ]
    @Consumption.valueHelpDefinition: [ { entity: { name: 'zi_rult_f4', element: 'value_low' },
                                            distinctValues: true,
                                             label  : 'Rule Type - Value Help', useForValidation: true
                                            } ]
                                            
 Rulty,
RulTName,
  Dacct,
  Dcost,
  Oacct,
  Ocost,
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
    systemDateTime.lastChangedAt: true
  }
    @Consumption.filter.selectionType: #RANGE
  LocalLastChangedAt,
  
  LocalLastChangedBy
  

//  _Header : redirected to parent ZC_TBZMAPKC_H
}
