@EndUserText.label: 'Custom entity ZRM02 lines export excel'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZRM02_EXC_LINES_IMPL'
@Metadata.allowExtensions: true
define custom entity zfa_i_zrm02_exc_lines
{

  key title_type                 : abap.int1;
  key title                      : abap.string;
  key CompanyCode                : abap.char(4);
  key FiscalYear                 : abap.char(4);

  key PostingDate                : abap.dats;
  key postingdate_fromto         : abap.char(255);
  key BalanceTransactionCurrency : abap.cuky( 5 );
  key CompanyCodeCurrency        : abap.cuky( 5 );

  key Customer                   : abap.char(10);
  key GLAccount                  : abap.char(10);
      Customercode               : abap.char(10);
      CustomerAccountGroup       : abap.char(4);
      CustomerName               : abap.char(255);
      FinancialAccountType       : abap.char(1);


      compName                   : abap.char(255);
      compAdd                    : abap.char(255);
      compMST                    : abap.char(255);

      nguoilap                   : abap.char(255);
      ketoan                     : abap.char(255);
      giamdoc                    : abap.char(255);
      currentdate                : abap.char(30);

      @Semantics                 : { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      dauki_no_nt                : zde_amount23;
      @Semantics                 : { amount : {currencyCode: 'companycodecurrency'} }
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


}
