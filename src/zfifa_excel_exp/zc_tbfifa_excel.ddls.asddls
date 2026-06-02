@Metadata.allowExtensions: true

@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBFIFA_EXCEL'
}

define root view entity ZC_TBFIFA_EXCEL
  provider contract transactional_query
  as projection on ZR_TBFIFA_EXCEL
  association [1..1] to ZR_TBFIFA_EXCEL as _BaseEntity on $projection.ReportID = _BaseEntity.ReportID and $projection.ObjectID = _BaseEntity.ObjectID
{
  key ReportID,
  key ObjectID,
       @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                            fileName: 'FileName',   //case-sensitive
                            acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                            contentDispositionPreference: #INLINE }
  Attachment,
  @Semantics.mimeType: true
  Mimetype,
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
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
