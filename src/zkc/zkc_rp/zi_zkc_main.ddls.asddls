@EndUserText.label: 'ZKC - Kết chuyển cuối kỳ '
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MAIN_ZKC'
@Metadata.allowExtensions: true
define root custom entity ZI_ZKC_MAIN

{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'zi_rult_f4', element: 'value_low' },
                                              distinctValues: true,
                                               label  : 'Rule Type - Value Help', useForValidation: true
                                              } ]

  key rulty                        : zde_rulty_2;
  key lineid                       : abap.numc( 10 );
      @Consumption.valueHelpDefinition: [{
       qualifier                   : '',
       entity                      : {
           name                    : 'I_CompanyCode',
           element                 : 'CompanyCode'
       }
      }]
  key bukrs                        : bukrs;
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_FiscalYearForCompanyCode', element: 'FiscalYear' },
                                              distinctValues: true,
                                               label  : 'Fiscal Year - Value Help', useForValidation: true
                                              } ]
  key FiscalYear                   : fis_gjahr_no_conv;

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_FiscalYearPeriodForCmpnyCode', element: 'FiscalPeriod' },
                                          distinctValues: true,
                                           label  : 'Fiscal Period - Value Help', useForValidation: true
                                          } ]

  key period                       : fins_fiscalperiod;
  key AccountingDocumentType       : blart;
      @Consumption.filter.selectionType: #RANGE
  key DocumentDate                 : bldat;
      @Consumption.filter.selectionType: #RANGE
  key PostingDate                  : budat;
  key AccountingDocumentHeaderText : bktxt;
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_ISREVESED_VKH', element: 'value_low' },
                                            distinctValues: true,
                                             label  : 'Is Revesed - Value Help', useForValidation: true
                                            } ]

  key IsReversed                   : abap.char( 1 );
      sacct                        : zde_sacct;
      dacct                        : zde_dacct;
      dcost                        : zde_dcost;
      dprctr                       : zde_dprctr;
      oacct                        : zde_oacct;
      ocost                        : zde_ocost;
      oprctr                       : zde_oprctr;
      @Semantics.amount.currencyCode:'waers'
      Amount                       : zde_amount23;
      waers                        : abap.cuky( 5 );
      rultname                     : val_text;
      belnr                        : belnr_d;
      GLAccountLongName:txt50_skat; 
}
