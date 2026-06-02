@EndUserText.label: 'Custom Entity for ZGL04N'
@ObjectModel.query.implementedBy:'ABAP:ZCL_FA_ZGL04N'
@Metadata.allowExtensions: true
define custom entity ZR_FA_ZGL04N
{

  key uuid               : uuid;
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FA_ZGL04N_COMP_HELP', element: 'CompanyCode' } }]
  key companyCode        : abap.char(4);
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FA_ZGL04N_YEAR_HELP', element: 'FiscalYear' } }]
  key fiscalYear         : abap.char(4);



      postingDate        : datum;
      accountingdocument : belnr_d;
      item               : abap.int4; // hoangtd21
      //  key companyCode        : abap.char(4);
      //  key fiscalYear         : abap.char(4);
      //  key postingDate        : datum;
      //  key accountingdocument : belnr_d;
      documentdate       : datum;
      description        : abap.char(255);
      s_glaccount        : abap.char(10);
      h_glaccount        : abap.char(10);
      s_amount           : abap.dec(15, 2);
      h_amount           : abap.dec(15, 2);

      incl_reserve       : abap_boolean;

      // Footer
      Nguoi_lap          : abap.char(255);
      Ke_toan            : abap.char(255);
      Giam_doc           : abap.char(255);
      // PDF
      ReportId           : abap.char(100);
      ObjectId           : uuid;
      @Semantics.largeObject      : { mimeType: 'MimeType',   //case-sensitive
                          fileName: 'FileName',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                          contentDispositionPreference: #INLINE }
      Attachment         : zattachment;
      Mimetype           : abap.char(100);
      Filename           : abap.char(100);
      // Excel
      ReportId_Exc       : abap.char(100);
      ObjectId_Exc       : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'Mimetype_Exc',   //case-sensitive
                          fileName: 'Filename_Exc',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf','application/vnd.ms-excel' ],
                          contentDispositionPreference: #INLINE }
      Attachment_Exc     : zattachment;
      Mimetype_Exc       : abap.char(100);
      Filename_Exc       : abap.char(100);
}
