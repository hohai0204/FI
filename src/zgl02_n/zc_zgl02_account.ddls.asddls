@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view Account'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZC_ZGL02_ACCOUNT
  provider contract transactional_query
  as projection on ZR_ZGL02_ACCOUNT
{
  key     SourceLedger,
  key     CompanyCode,
  key     FiscalYear,
  key     GLAccount,
  key     period,
          //          GLAccountName,

          CompanyCodeName,
          Address,
          MST,

          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ZGL02_SubtotalVH', element: 'Value' } } ]
          SubtotalOpt,


          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual DauKyNo         : abap.curr(23,2),
          
          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual DauKyCo         : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual TrongKyNo       : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual TrongkyCo       : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual CuoikyNo        : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual CuoikyCo        : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_DauKyNo   : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_DauKyCo   : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_TrongKyNo : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_TrongKyCo : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_CuoiKyNo  : abap.curr(23,2),

          @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_ZGL02_CALC_VIRF'
  virtual Total_CuoiKyCo  : abap.curr(23,2),

          CompanyCodeCurrency,

  virtual Date_text       : abap.char(100),
  virtual nguoilap        : abap.char(128),
  virtual ketoantruong    : abap.char(128),
  virtual giamdoc         : abap.char(128)
}
