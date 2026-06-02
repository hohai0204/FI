@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBFI_KC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBFI_KC
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBFI_KC
  association [1..1] to ZR_TBFI_KC as _BaseEntity on $projection.RULTY = _BaseEntity.RULTY and $projection.BUKRS = _BaseEntity.BUKRS and $projection.FISCALYEAR = _BaseEntity.FISCALYEAR and $projection.PERIOD = _BaseEntity.PERIOD and $projection.ACCOUNTINGDOCUMENTTYPE = _BaseEntity.ACCOUNTINGDOCUMENTTYPE
{
  key Rulty,
  key Bukrs,
  key Fiscalyear,
  key Period,
  key Accountingdocumenttype,
  Belnr,
  Gjahr,
  BelnrR,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LastChangedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
