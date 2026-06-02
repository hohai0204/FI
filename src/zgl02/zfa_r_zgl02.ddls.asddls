@EndUserText.label: 'Custom Enity ZGL02'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_ENITY_ZGL02'
@Metadata.allowExtensions: true
define custom entity ZFA_R_ZGL02
{
  key keysubtotal      : abap.char(20);
  key glaccount        : abap.char(20);
  key uuid             : uuid;
      companycode      : abap.char(4);
      account_text     : abap.char(255);
      fiscalyear       : abap.char(4);
      fiscalperiod     : abap.char(2);
      display_subtotal : zde_display_subtotal;
      dauky_co         : abap.dec(13,2);
      dauky_no         : abap.dec(13,2);
      phatsinh_co      : abap.dec(13,2);
      phatsinh_no      : abap.dec(13,2);
      cuoiky_co        : abap.dec(13,2);
      cuoiky_no        : abap.dec(13,2);
      t_dauky_co       : abap.char(100);
      t_dauky_no       : abap.char(100);
      t_phatsinh_co    : abap.char(100);
      t_phatsinh_no    : abap.char(100);
      t_cuoiky_co      : abap.char(100);
      t_cuoiky_no      : abap.char(100);
      // Footer
      Nguoi_lap        : abap.char(255);
      Ke_toan          : abap.char(255);
      Giam_doc         : abap.char(255);
      // PDF
      ReportId         : abap.char(100);
      ObjectId         : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'MimeType',   //case-sensitive
                          fileName: 'FileName',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                          contentDispositionPreference: #INLINE }
      Attachment       : zattachment;
      Mimetype         : abap.char(100);
      Filename         : abap.char(100);
      // Excel
      ReportId_Exc     : abap.char(100);
      ObjectId_Exc     : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'Mimetype_Exc',   //case-sensitive
                          fileName: 'Filename_Exc',   //case-sensitive
                          acceptableMimeTypes: ['application/vnd.ms-excel' ],
                          contentDispositionPreference: #INLINE }
      Attachment_Exc   : zattachment;
      Mimetype_Exc     : abap.char(100);
      Filename_Exc     : abap.char(100);
      group_lv_1 : abap.char(20);
      group_lv_2 : abap.char(20);
      zlevel : abap.char(1);
      incl_reserve       : abap_boolean;

}
