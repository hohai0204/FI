@EndUserText.label: 'Custom entity ZRM02 in excel'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZRM02_LINES_IMPL'
@Metadata.allowExtensions: true
define custom entity zfa_i_zrm02_lines
{
  key CompanyCode                : abap.char(4);
  key FiscalYear                 : abap.char(4);
  key object_id                  : uuid;

  key postingdate_fromto         : abap.char(255);
  key BalanceTransactionCurrency : abap.cuky( 5 );
  key GLAccount                  : abap.char(10);
  key Customer                   : abap.char(10);
      FinancialAccountType       : abap.char(1);

      companycodecurrency        : abap.cuky( 5 );
      
      compName                   : abap.char(255);
      compAdd                    : abap.char(255);
      compMST                    : abap.char(255);
      Customercode               : abap.char(10);
      CustomerAccountGroup       : abap.char(4);
      CustomerName               : abap.char(255);

      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      dauki_no_nt                : zde_amount23;
      @Semantics.amount.currencyCode: 'companycodecurrency'
      dauki_no_vn                : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      dauki_co_nt                : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
      dauki_co_vn                : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      phatsinh_no_nt             : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
      phatsinh_no_vn             : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      phatsinh_co_nt             : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
      phatsinh_co_vn             : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      cuoiki_no_nt               : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
      cuoiki_no_vn               : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      cuoiki_co_nt               : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
      cuoiki_co_vn               : zde_amount23;
      
      //      dauki_no_nt_fm             : abap.string;
      //      dauki_no_vn_fm             : abap.string;
      //      dauki_co_nt_fm             : abap.string;
      //      dauki_co_vn_fm             : abap.string;
      //
      //      phatsinh_no_nt_fm          : abap.string;
      //      phatsinh_no_vn_fm          : abap.string;
      //      phatsinh_co_nt_fm          : abap.string;
      //      phatsinh_co_vn_fm          : abap.string;
      //
      //      cuoiki_no_nt_fm            : abap.string;
      //      cuoiki_no_vn_fm            : abap.string;
      //      cuoiki_co_nt_fm            : abap.string;
      //      cuoiki_co_vn_fm            : abap.string;
      
      @ObjectModel.sort.enabled  : false
      @ObjectModel.filter.enabled: false
      _HeaderZRM02               : association to parent ZFA_I_ZRM02 on  $projection.CompanyCode = _HeaderZRM02.CompanyCode
                                                                     and $projection.FiscalYear  = _HeaderZRM02.FiscalYear
                                                                     and $projection.object_id   = _HeaderZRM02.object_id;
}
