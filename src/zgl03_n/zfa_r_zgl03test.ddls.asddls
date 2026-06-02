@EndUserText.label: 'ZGL03 Custom entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CUS_ZGL03'
@Metadata.allowExtensions: true
define custom entity ZFA_R_ZGL03TEST
  // with parameters parameter_name : parameter_type
{
      //  key uuid        : uuid;
      //  key companycode : abap.char( 5 );

  key companycode   : abap.char(4);
  key uuid          : uuid;
  key phien_bao_cao : abap.char(4);
  key ky_bao_cao    : abap.char(4);
  key nam_bao_cao   : abap.char(4);
  key Ky_so_sanh    : abap.char(4);
  key nam_so_sanh   : abap.char(4);
      //      scaleratio    : zde_scale_ratio;
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

}
