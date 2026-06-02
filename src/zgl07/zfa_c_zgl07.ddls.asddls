@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Phiếu kế toán'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZFA_C_ZGL07
  provider contract transactional_query
  as projection on ZFA_R_ZGL07
{
  key CompanyCode,
  key FiscalYear,
  key JournalEntry,
      JournalEntryType,
      PostingDate,
      EntryDate,
      UserName,
      TenCongTy,
      DiaChiCongTy,
      MaSoThue,
      DonViTinh,
      object_id,
      report_id,
      @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                              fileName: 'FileName',   //case-sensitive
                              acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                              contentDispositionPreference: #INLINE }
      attachment,
      filename,
      mimetype
}
