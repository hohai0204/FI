@EndUserText.label: 'Custom Entity for ZGL04N Excel Report'
@ObjectModel.query.implementedBy:'ABAP:ZCL_FA_ZGL04N_EXCEL'
@Metadata.allowExtensions: true
define custom entity ZR_FA_ZGL04N_EXCEL
{
      @Consumption.valueHelpDefinition:
                           [{ entity       : { name: 'ZI_FA_ZGL04N_COMP_HELP',
                      element: 'CompanyCode' },
             useForValidation: true }]
  key companyCode        : abap.char(4);
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FA_ZGL04N_YEAR_HELP', element: 'FiscalYear' } }]
  key fiscalYear         : abap.char( 4 );
  key postingDate        : datum;
  key accountingDocument : belnr_d;
  key item               : abap.int4; // hoangtd21
      s_glaccount        : abap.char(10);
      h_glaccount        : abap.char(10);

      documentDate       : datum;

      description        : abap.char(255);
      s_amount           : abap.dec(15, 2);
      h_amount           : abap.dec(15, 2);
      incl_reserve       : abap_boolean;
      // Footer
      Nguoi_lap          : abap.char(255);
      Ke_toan            : abap.char(255);
      Giam_doc           : abap.char(255);

}
