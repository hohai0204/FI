@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View ZAA01'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_R_ZAA01
  as select from ZFA_V_ZAA01 ( P_den_ki : '20250101' ,
  P_tu_ki : '20250101' )
//  association [0..1] to ZFA_I_ZAA01_SUM_ASSET as _sumAsset on  _sumAsset.MasterFixedAsset = $projection.MasterFixedAsset
//                                                           and _sumAsset.CompanyCode      = $projection.CompanyCode
//                                                           and _sumAsset.FixedAsset       = $projection.FixedAsset
//                                                           and _sumAsset.report_period    = $projection.report_period
//                                                           and _sumAsset.report_year      = $projection.report_year
//  association [0..1] to ZFA_I_ZAA01_TKHTK     as _sumTkhtk on  _sumTkhtk.MasterFixedAsset = $projection.MasterFixedAsset
//                                                           and _sumTkhtk.CompanyCode      = $projection.CompanyCode
//                                                           and _sumTkhtk.FixedAsset       = $projection.FixedAsset
//                                                           and _sumTkhtk.report_period    = $projection.report_period
//                                                           and _sumTkhtk.report_year      = $projection.report_year
//                                                           and _sumTkhtk.SourceLedger     = '0L'
//  association [0..1] to ZFA_I_ZAA01_GNGTK     as _sumGkhtk on  _sumGkhtk.MasterFixedAsset = $projection.MasterFixedAsset
//                                                           and _sumGkhtk.CompanyCode      = $projection.CompanyCode
//                                                           and _sumGkhtk.FixedAsset       = $projection.FixedAsset
//                                                           and _sumGkhtk.report_period    = $projection.report_period
//                                                           and _sumGkhtk.report_year      = $projection.report_year
//                                                           and _sumGkhtk.SourceLedger     = '0L'

  //composition of target_data_source_name as _association_name
{
           //    _association_name // Make association public
  key      FixedAsset,
  key      MasterFixedAsset,
  key      CompanyCode,
//  key      report_year,
//  key      report_period,
           TenCongTy,
           DiaChiCongTy,
           MSTCongTy,
           AssetClass,
           FixedAssetDescription,
           Plant,
           ProfitCenter,
           AssetLocation,
           AssetCapitalizationDate,
           AssetDeactivationDate,
           IsShutDown,
           CostCenter,
           Inventory,
           DepreciationStartDate,
           @Semantics.quantity.unitOfMeasure: 'BaseUnit'
           Quantity,
           BaseUnit,
           UL_Periods,
           UL_Years,
           ( cast( UL_Periods as abap.int1 ) + ( cast( UL_Years as abap.int1 ) * 12 ) ) as UL,
           Tk_nguyen_gia,
           Tk_chi_phi,
           tk_khau_hao,
           ReportId,
           ObjectId,
           Attachment,
           Mimetype,
           Filename,
//
//           @Semantics.amount.currencyCode: 'TransactionCurrency'
//           _sumAsset.amount_in_transaction_currency                                     as tang_nguyen_gia_trong_ki,
//           _sumAsset.TransactionCurrency,
//           @Semantics.amount.currencyCode: 'TransactionCurrency'
//           _sumTkhtk.tang_khau_hao_trong_ki,
//           @Semantics.amount.currencyCode: 'TransactionCurrency'
//           _sumGkhtk.amount_in_transaction_currency                                     as giam_nguyen_gia_trong_ky,
           ''                                                                           as giam_khau_hao_trong_ky




}
