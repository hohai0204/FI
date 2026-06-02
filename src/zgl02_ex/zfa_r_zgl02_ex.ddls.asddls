@EndUserText.label: 'Root Custom Entity ZGL02 (Excel)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_ENITY_ZGL02_EX'
@Metadata.allowExtensions: true
define root custom entity ZFA_R_ZGL02_EX

{
  key keysubtotal      : abap.char(20);
  key glaccount        : abap.char(20);
  key uuid             : uuid;
      companycode      : abap.char(4);
      account_text     : abap.char(255);
      fiscalyear       : abap.char(4);
      fiscalperiod     : abap.char(2);
      display_subtotal : zde_display_subtotal;
      @Semantics.amount.currencyCode: 'currency'
      dauky_co         : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      dauky_no         : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      phatsinh_co      : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      phatsinh_no      : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      cuoiky_co        : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      cuoiky_no        : abap.dec(25,2);
      currency         : abap.cuky( 5 );
      group_lv_1       : abap.char(20);
      group_lv_2       : abap.char(20);
      zlevel           : abap.char(1);
      //////      // Footer
      //////      Nguoi_lap        : abap.char(255);
      //////      Ke_toan          : abap.char(255);
      //////      Giam_doc         : abap.char(255);
      //////      // PDF
      //////      ReportId         : abap.char(100);
      //////      ObjectId         : abap.char(100);
      //////      @Semantics.largeObject      : { mimeType: 'MimeType',   //case-sensitive
      //////                          fileName: 'FileName',   //case-sensitive
      //////                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
      //////                          contentDispositionPreference: #INLINE }
      //////      Attachment       : zattachment;
      //////      Mimetype         : abap.char(100);
      //////      Filename         : abap.char(100);

}
