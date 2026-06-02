@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Data ZAA01'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZAA01
  as select from    I_FixedAsset               as header
    left outer join      I_AssetValuationForLedger  as valuation                on  header.FixedAsset              = valuation.FixedAsset
                                                                           and header.MasterFixedAsset        = valuation.MasterFixedAsset
                                                                           and valuation.Ledger               = '0L'
//                                                                           and valuation.DepreciationAreaType = '1'
    left outer join      I_FixedAssetAssgmt         as Assgmt                   on  header.FixedAsset       = Assgmt.FixedAsset
                                                                           and header.MasterFixedAsset = Assgmt.MasterFixedAsset
                                                                           and header.CompanyCode      = Assgmt.CompanyCode
//////    left outer join I_JournalEntryItem         as Journal                  on  Journal.MasterFixedAsset       = header.MasterFixedAsset
//////                                                                           and Journal.FixedAsset             = header.FixedAsset
//////                                                                           and Journal.CompanyCode            = header.CompanyCode
//////                                                                           and Journal.FinancialAccountType   = 'A'
//////                                                                           and Journal.Ledger                 = '0L'
//////                                                                           and (
//////                                                                              Journal.AssetTransactionType    = '970'
//////                                                                              or Journal.AssetTransactionType = '100'
//////                                                                            )
//////                                                                            and Journal.DebitCreditCode = 'S'
    left outer join      I_GLAccountLineItemRawData as Account_GL_Assign_KTANSW on  Account_GL_Assign_KTANSW.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTANSW.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTANSW.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTANSW.AccountAssignment = 'KTANSW'
                                                                           and Account_GL_Assign_KTANSW.CompanyCode = header.CompanyCode
                                                                           and Account_GL_Assign_KTANSW.SourceLedger = '0L'
    left outer join      I_GLAccountLineItemRawData as Account_GL_Assign_KTNAFG on  Account_GL_Assign_KTNAFG.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTNAFG.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTNAFG.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTNAFG.AccountAssignment = 'KTNAFG'
                                                                           and Account_GL_Assign_KTNAFG.CompanyCode = header.CompanyCode
                                                                           and Account_GL_Assign_KTNAFG.SourceLedger = '0L'
   left outer join      I_GLAccountLineItemRawData as Account_GL_Assign_KTNAFB on  Account_GL_Assign_KTNAFB.MasterFixedAsset  = header.MasterFixedAsset
                                                                           and Account_GL_Assign_KTNAFB.FixedAsset        = header.FixedAsset
                                                                           and Account_GL_Assign_KTNAFB.AssetClass        = header.AssetClass
                                                                           and Account_GL_Assign_KTNAFB.CompanyCode = header.CompanyCode
                                                                           and Account_GL_Assign_KTNAFB.AccountAssignment = 'KTNAFB'
                                                                           and Account_GL_Assign_KTNAFB.SourceLedger = '0L'
//    left outer join ztb_calendar as calendar on calendar.compnanycode = header.CompanyCode

{
  key header.FixedAsset,
  key header.MasterFixedAsset,
  key header.CompanyCode,
      header.AssetClass,
      header.FixedAssetDescription,
      header._FixedAssetAssgmt.Plant,
      header._FixedAssetAssgmt.ProfitCenter,
      header._FixedAssetAssgmt.AssetLocation,
      header.AssetCapitalizationDate,
      header.AssetDeactivationDate,
      case when valuation.IsShutDown is not initial then 'Bị khóa'
          when valuation.IsShutDown is initial then 'Bị khóa' else '' end as IsShutDown,
      Assgmt.CostCenter,
      header.Inventory,
      valuation.DepreciationStartDate,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      header.Quantity,
      header.BaseUnit,
      valuation.PlannedUsefulLifeInPeriods                                as UL_Periods,
      valuation.PlannedUsefulLifeInYears                                  as UL_Years,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
//      Journal.AmountInTransactionCurrency,
//      Journal.TransactionCurrency,
      Account_GL_Assign_KTANSW.GLAccount                                  as Tk_nguyen_gia,
      Account_GL_Assign_KTNAFG.GLAccount                                  as Tk_chi_phi,
      Account_GL_Assign_KTNAFB.GLAccount                                  as tk_khau_hao
//      case  when ( Journal.AmountInTransactionCurrency  > 0 )
//        and Journal.DebitCreditCode = 'H' then cast( 'X' as abap.char(1) )
//      when ( Journal.AmountInTransactionCurrency  < 0 )
//        and Journal.DebitCreditCode = 'S' then cast( 'X' as abap.char(1) )
//      else cast( ' ' as abap.char(1) ) end                                as IsNegativePosting,
//      @Semantics.amount.currencyCode: 'BalanceTransactionCurrency'
//      Journal.DebitAmountInBalanceTransCrcy,
//      Journal.BalanceTransactionCurrency,
//      @Semantics.amount.currencyCode: 'BalanceTransactionCurrency'
//      Journal.CreditAmountInBalanceTransCrcy,
//      calendar.period_report,
//      calendar.year_report




}
