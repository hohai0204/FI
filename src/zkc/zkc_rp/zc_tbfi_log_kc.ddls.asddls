@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBFI_LOG_KC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBFI_LOG_KC
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBFI_LOG_KC
  association [1..1] to ZR_TBFI_LOG_KC as _BaseEntity on $projection.RULTY = _BaseEntity.RULTY and $projection.LINEID = _BaseEntity.LINEID and $projection.BUKRS = _BaseEntity.BUKRS and $projection.FISCALYEAR = _BaseEntity.FISCALYEAR and $projection.PERIOD = _BaseEntity.PERIOD and $projection.ACCOUNTINGDOCUMENTTYPE = _BaseEntity.ACCOUNTINGDOCUMENTTYPE and $projection.DOCUMENTDATE = _BaseEntity.DOCUMENTDATE and $projection.POSTINGDATE = _BaseEntity.POSTINGDATE and $projection.ACCOUNTINGDOCUMENTHEADERTEXT = _BaseEntity.ACCOUNTINGDOCUMENTHEADERTEXT and $projection.ISREVERSED = _BaseEntity.ISREVERSED
{
  key Rulty,
  key Lineid,
  key Bukrs,
  key Fiscalyear,
  key Period,
  key Accountingdocumenttype,
  key Documentdate,
  key Postingdate,
  key Accountingdocumentheadertext,
  key Isreversed,
  Sacct,
  Dacct,
  Dcost,
  Oacct,
  Ocost,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  Waers,
  Amount,
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
