@EndUserText.label: 'Custom Entity Phiếu Thu'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_GETDATA_PHIEUTHU'
    }
}
define custom entity ZFA_I_CUSTOM_PHIEUTHU
{
  key Object : abap.char( 20 );
  AcountingDocument : belnr_d;
  CompanyCode : bukrs;
  FisYear : gjahr;
  budat : budat;
  bldat: bldat;
  CompanyName: zde_text255;
  CompanyAdress: zde_text255;
  TaxNum: abap.char( 20 );
  Debit : abap.char( 10 );
   Crebit : abap.char( 10 );
   WAERS : abap.cuky( 5 );
   NguoiNopTien : abap.char( 100 );
   user_creat: abap.char( 20 );
   bp_adress: zde_text255;
   reason: zde_text255;
   @Semantics.amount.currencyCode: 'WAERS' 
   amount :abap.curr( 31, 11 );
   amountAsWord : zde_text255;
   DocumentReferenceID : xblnr1;
   
}
