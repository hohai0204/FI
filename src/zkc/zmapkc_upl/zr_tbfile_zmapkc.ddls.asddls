@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBFILE_ZMAPKC'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBFILE_ZMAPKC
  as select from ztb_file_zmapkc
{
  key uuid as UUID,
//  key type_uload as TypeUload,
  end_user as EndUser,
  status as Status,
  attachment as Attachment,
  mimetype as Mimetype,
  filename as Filename,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
