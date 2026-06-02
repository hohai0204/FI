@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBFIFA_EXCEL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBFIFA_EXCEL
  as select from ZTB_FIFA_EXCEL
{
  key report_id as ReportID,
  key object_id as ObjectID,
  attachment as Attachment,
  mimetype as Mimetype,
  filename as Filename,
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
