@EndUserText.label: 'Custom Entity ZGL01'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZI_FA_ZGL01'
@Metadata.allowExtensions: true
define custom entity ZFA_R_ZGL01
{
  key companycode   : abap.char(4);
  key uuid          : uuid;
      phien_bao_cao : abap.char(4);
      ky_bao_cao    : abap.char(4);
      nam_bao_cao   : abap.char(4);
      Ky_so_sanh    : abap.char(4);
      nam_so_sanh   : abap.char(4);
      // Footer
      Nguoi_lap     : abap.char(255);
      Ke_toan       : abap.char(255);
      Giam_doc      : abap.char(255);
      // PDF
      ReportId      : abap.char(100);
      ObjectId      : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'MimeType',   //case-sensitive
                          fileName: 'FileName',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                          contentDispositionPreference: #INLINE }
      Attachment    : zattachment;
      Mimetype      : abap.char(100);
      Filename      : abap.char(100);
      // Excel
      ReportId_Exc      : abap.char(100);
      ObjectId_Exc      : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'Mimetype_Exc',   //case-sensitive
                          fileName: 'Filename_Exc',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf','application/vnd.ms-excel' ],
                          contentDispositionPreference: #INLINE }
      Attachment_Exc    : zattachment;
      Mimetype_Exc      : abap.char(100);
      Filename_Exc      : abap.char(100);


}
