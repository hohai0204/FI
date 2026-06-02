@EndUserText.label: 'Root Custom Entity ZGL01 (Excel)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_ZGL01_EX_N'
@Metadata.allowExtensions: true
define custom entity ZFA_R_ZGL01_EX

{
  key chi_tieu      : abap.char(100);
  key ma_so         : abap.char(10);
      thuyet_minh   : abap.char(100);
      @Semantics.amount.currencyCode: 'currency'
      so_cuoi_ki    : abap.dec(25,2);
      @Semantics.amount.currencyCode: 'currency'
      so_dau_ki     : abap.dec(25,2);
      currency      : abap.cuky( 5 );
      level_maso    : abap.char(10);
      companycode   : abap.char(4);
      phien_bao_cao : abap.char(4);
      ky_bao_cao    : abap.char(4);
      nam_bao_cao   : abap.char(4);
      Ky_so_sanh    : abap.char(4);
      nam_so_sanh   : abap.char(4);
}
