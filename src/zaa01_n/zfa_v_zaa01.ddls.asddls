@AbapCatalog.sqlViewName: 'ZVIEWDATAZAA01'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Define View Data ZAA01'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_ZAA01
  with parameters
    P_tu_ki  : abap.dats,
    P_den_ki : abap.dats
  ////                P_year : zcompany_code
  as select from    I_FixedAsset               as header
    left outer join I_AssetValuationForLedger  as valuation                on  header.FixedAsset       = valuation.FixedAsset
                                                                           and header.MasterFixedAsset = valuation.MasterFixedAsset
                                                                           and valuation.Ledger        = '0L'
  //                                                                           and valuation.DepreciationAreaType = '1'
    left outer join I_FixedAssetAssgmt         as Assgmt                   on  header.MasterFixedAsset = Assgmt.MasterFixedAsset
                                                                           and  header.FixedAsset       = Assgmt.FixedAsset
                                                                           and header.CompanyCode      = Assgmt.CompanyCode
    left outer join I_GLAccountLineItemRawData as Account_GL_Assign_KTANSW on  Account_GL_Assign_KTANSW.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTANSW.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTANSW.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTANSW.AccountAssignment = 'KTANSW'
                                                                           and Account_GL_Assign_KTANSW.CompanyCode       = header.CompanyCode
                                                                           and Account_GL_Assign_KTANSW.SourceLedger      = '0L'
    left outer join I_GLAccountLineItemRawData as Account_GL_Assign_KTNAFG on  Account_GL_Assign_KTNAFG.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTNAFG.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTNAFG.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTNAFG.AccountAssignment = 'KTNAFG'
                                                                           and Account_GL_Assign_KTNAFG.CompanyCode       = header.CompanyCode
                                                                           and Account_GL_Assign_KTNAFG.SourceLedger      = '0L'
    left outer join I_GLAccountLineItemRawData as Account_GL_Assign_KTNAFB on  Account_GL_Assign_KTNAFB.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTNAFB.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTNAFB.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTNAFB.CompanyCode       = header.CompanyCode
                                                                           and Account_GL_Assign_KTNAFB.AccountAssignment = 'KTNAFB'
                                                                           and Account_GL_Assign_KTNAFB.SourceLedger      = '0L'
    left outer join ztb_fi_pdf_draf            as pdf                      on  pdf.object_id = header.MasterFixedAsset
                                                                           and pdf.report_id = 'ZAA01'
  //    left outer join ZFA_I_ZAA01_SUM_ASSET      as sum_asset                on  sum_asset.FixedAsset       = header.FixedAsset
  //                                                                           and sum_asset.MasterFixedAsset = header.MasterFixedAsset
  //                                                                           and sum_asset.CompanyCode      = header.CompanyCode
  //                                                                           and sum_asset.SourceLedger     = '0L'
  //    left outer join ztb_calendar               as calendar                 on calendar.compnanycode = header.CompanyCode
    left outer join      ZCDS_COMPANY               as company                  on company.CompanyCode = header.CompanyCode
    left outer join      I_MasterFixedAsset         as master_fixed_asset       on  master_fixed_asset.MasterFixedAsset = header.MasterFixedAsset
                                                                           and master_fixed_asset.CompanyCode      = header.CompanyCode
    left outer join I_Location                 as location                 on location.Location = Assgmt.AssetLocation
    left outer join I_AssetAcctDeterminationText           as asset_class_text         on  asset_class_text.AssetAccountDetermination = header.AssetClass
                                                                           and asset_class_text.Language   = 'E'
    left outer join I_Plant                    as plant                    on  plant.Plant    = Assgmt.Plant
                                                                           and plant.Language = 'E'
    left outer join I_ProfitCenterText         as profitcenter             on  profitcenter.ProfitCenter = Assgmt.ProfitCenter
                                                                           and profitcenter.Language     = 'E'
    left outer join I_CostCenterText           as costcenter               on  costcenter.CostCenter = Assgmt.CostCenter
                                                                           and costcenter.Language   = 'E'
{
  key header.FixedAsset,
  key header.MasterFixedAsset,
  key header.CompanyCode,
      concat(header.MasterFixedAsset, concat( ' - ', header.FixedAsset ) )           as Assetnumber,
      company.tencty_vn                                                              as TenCongTy,
      company.diachi_vn                                                              as DiaChiCongTy,
      company.mst                                                                    as MSTCongTy,

      header.AssetClass,
      concat( header.AssetClass, concat( ' - ', asset_class_text.AssetAccountDeterminationDesc ) )  as assetclass_desc,
      header.FixedAssetDescription,
      master_fixed_asset.MasterFixedAssetDescription,
      concat( Assgmt.Plant , concat( ' - ', plant.PlantName ) )                      as plant,
      concat( Assgmt.ProfitCenter , concat( ' - ', profitcenter.ProfitCenterName ) ) as profitcenter,
      Assgmt.AssetLocation,
      concat( Assgmt.AssetLocation, concat( ' - ', location.LocationName ) )         as assetlocation_desc,
      valuation.AssetOpgReadinessDate as AssetCapitalizationDate,
      header.AssetDeactivationDate,
      case when valuation.IsShutDown is not initial then 'Bị khóa'
          when valuation.IsShutDown is initial then 'Đang KH' else '' end            as IsShutDown,
      Assgmt.CostCenter,
      concat( Assgmt.CostCenter , concat( ' - ', costcenter.CostCenterName ) )       as costcenter_desc,

      header.Inventory,
      valuation.DepreciationStartDate,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      header.Quantity,
      header.BaseUnit,
      valuation.PlannedUsefulLifeInPeriods                                           as UL_Periods,
      valuation.PlannedUsefulLifeInYears                                             as UL_Years,
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      //      Journal.AmountInTransactionCurrency,
      //      Journal.TransactionCurrency,
      Account_GL_Assign_KTANSW.GLAccount                                             as Tk_nguyen_gia,
      Account_GL_Assign_KTNAFG.GLAccount                                             as Tk_chi_phi,
      Account_GL_Assign_KTNAFB.GLAccount                                             as tk_khau_hao,
      pdf.report_id                                                                  as ReportId,
      pdf.object_id                                                                  as ObjectId,
      pdf.attachment                                                                 as Attachment,
      pdf.mimetype                                                                   as Mimetype,
      pdf.filename                                                                   as Filename,
      left( valuation.AssetOpgReadinessDate , 6 ) as period_year 
      //      calendar.period_report                                              as report_period,
      //      calendar.year_report                                                as report_year
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      //      sum_asset.amount_in_transaction_currency                            as tang_nguyen_gia_trong_ki,
      //      sum_asset.TransactionCurrency
}
//where header.AssetCapitalizationDate >=  $parameters.P_tu_ki
//and header.AssetCapitalizationDate <= $parameters.P_den_ki 
