@EndUserText.label: 'Root Custom Enitiy ZAA01'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZI_FA_ZAA01'
@Metadata.allowExtensions: true
define root custom entity ZFA_R_ZAA01_N
{
  key masterfixedasset            : abap.char(20);
  key companycode                 : abap.char(4);
  key fixedasset                  : abap.char(10);
  key uuid                        : uuid;
  key stt                         : abap.int4;
      MasterFixedAssetDescription : abap.char(100);
      Assetnumber                 : abap.char(20);
      AssetClass                  : abap.char(20);
      AssetClass_Desc             : abap.char(255);
      TenCongTy                   : abap.char(255);
      DiaChiCongTy                : abap.char(255);
      MSTCongTy                   : abap.char(40);
      plant                       : abap.char(50);
      profitcenter                : abap.char(100);
      assetlocation               : abap.char(100);
      assetlocation_desc          : abap.char(100);
      AssetCapitalizationDate     : abap.dats;
      AssetDeactivationDate       : abap.dats;
      CostCenter                  : abap.char(20);
      costcenter_desc             : abap.char(100);
      Quantity                    : abap.dec(13,3);
      BaseUnit                    : abap.char(3);
      DepreciationStartDate       : abap.dats;
      Inventory                   : abap.char(20);
      PlannedUsefulLifeInPeriods  : abap.numc(3);
      PlannedUsefulLifeInYears    : abap.numc( 3 );
      So_ky_khau_hao              : abap.char(10);
      So_ky_da_khua_hao           : abap.char(10);
      So_ky_khao_hao_con_lai      : abap.char(10);
      tang_nguyen_gia_trong_ki    : abap.dec(20,2);
      tang_khau_hao_trong_ki      : abap.dec(20,2);
      giam_nguyen_gia_trong_ky    : abap.dec(20,2);
      giam_khau_hao_trong_ky      : abap.dec(20,2);
      nguyen_gia_dau_ky           : abap.dec(20,2);
      khau_hao_luy_ke_dau_ky      : abap.dec(20,2);
      gia_tri_con_lai_dau_ky      : abap.dec(20,2);
      tk_nguyen_gia               : abap.char(20);
      tk_chi_phi                  : abap.char(20);
      tk_khau_hao                 : abap.char(20);
      nguyen_gia_cuoi_ky          : abap.dec(20,2);
      khau_hao_luy_ke_cuoi_ky     : abap.dec(20,2);
      gia_tri_con_lai_cuoi_ky     : abap.dec(20,2);
      Trang_Thai                  : abap.char(30);
      //Text
      tukydenky                   : abap.char(100);
      Tu_ky                       : abap.char(02);
      Den_ky                      : abap.char(02);
      Nam_bao_cao                 : abap.char(04);
      // PDF
      ReportId                    : abap.char(100);
      ObjectId                    : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'MimeType',   //case-sensitive
                          fileName: 'FileName',   //case-sensitive
                          acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                          contentDispositionPreference: #INLINE }
      Attachment                  : zattachment;
      Mimetype                    : abap.char(100);
      Filename                    : abap.char(100);
      //EXCEL
      ReportId_Exc                    : abap.char(100);
      ObjectId_exc                    : abap.char(100);
      @Semantics.largeObject      : { mimeType: 'Mimetype_exc',   //case-sensitive
                          fileName: 'Filename_exc',   //case-sensitive
                          acceptableMimeTypes:['image/png', 'image/jpeg', 'application/pdf' , 'application/vnd.ms-excel'],
                          contentDispositionPreference: #INLINE }
      Attachment_exc                  : zattachment;
      Mimetype_exc                    : abap.char(100);
      Filename_exc                    : abap.char(100);
      //Tham số
      Nguoi_lap                   : abap.char(100);
      Ke_toan                     : abap.char(100);
      Giam_doc                    : abap.char(100);

}
