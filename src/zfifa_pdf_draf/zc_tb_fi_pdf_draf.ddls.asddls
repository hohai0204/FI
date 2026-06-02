@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TB_FI_PDF_DRAF
  provider contract transactional_query
  as projection on ZR_TB_FI_PDF_DRAF
{
  key ReportId,
  key ObjectId,
       @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                            fileName: 'FileName',   //case-sensitive
                            acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                            contentDispositionPreference: #INLINE }
  Attachment,
  @Semantics.mimeType: true
  Mimetype,
  Filename,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
