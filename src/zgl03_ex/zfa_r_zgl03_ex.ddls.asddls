@EndUserText.label: 'Root Custom Entity ZGL03 (Excel)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_ZGL03_EX'
@Metadata.allowExtensions: true
define root custom entity ZFA_R_ZGL03_EX

{

  key chi_tieu       : abap.string;
  key ma_so          : abap.string;
      thuyet_minh    : abap.string;
      @Semantics.amount.currencyCode: 'currency'
      ky_bao_cao     : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      ky_so_sanh     : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      luy_ke_so_sanh : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      luy_ke_bao_cao : abap.dec(25,2);
      style          : abap.string;
      currency       : abap.cuky( 5 );
      companycode    : abap.char(4);
      uuid           : uuid;
      phien_bao_cao  : abap.char(4);
      ky_bao_cao_t     : abap.char(4);
      nam_bao_cao    : abap.char(4);
      Ky_so_sanh_t     : abap.char(4);
      nam_so_sanh    : abap.char(4);
}
