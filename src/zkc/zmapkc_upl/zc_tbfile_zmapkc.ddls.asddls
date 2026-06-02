@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Upload ZMAPKC'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBFILE_ZMAPKC'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBFILE_ZMAPKC
  provider contract transactional_query
  as projection on ZR_TBFILE_ZMAPKC
  association [1..1] to ZR_TBFILE_ZMAPKC as _BaseEntity on $projection.UUID = _BaseEntity.UUID 
{
  key UUID,
//  key TypeUload,
  EndUser,
  Status,
  @Semantics.largeObject: { mimeType: 'Mimetype',
                                fileName: 'Filename',
                                contentDispositionPreference: #INLINE }
      Attachment            as Attachment,
      @Semantics.mimeType: true
      Mimetype              as Mimetype,
  Filename,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  _BaseEntity
}
