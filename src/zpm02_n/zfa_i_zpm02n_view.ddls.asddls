@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View entity ZPM02N'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZPM02N_VIEW
  as select from    I_JournalEntryItem          as JournalEntryItem
    inner join      I_JournalEntry              as JournalEntry              on  JournalEntry.CompanyCode        = JournalEntryItem.CompanyCode
                                                                             and JournalEntry.AccountingDocument = JournalEntryItem.AccountingDocument
                                                                             and JournalEntry.FiscalYear         = JournalEntryItem.FiscalYear
    left outer join ZCDS_COMPANY                as Company                   on JournalEntry.CompanyCode = Company.CompanyCode
    left outer join I_Supplier                  as SupplierAccGrp            on SupplierAccGrp.Supplier = JournalEntryItem.Supplier
    left outer join I_SupplierToBusinessPartner as SupplierToBusinessPartner on JournalEntryItem.Supplier = SupplierToBusinessPartner.Supplier
    left outer join I_BusinessPartner           as BusinessPartner           on SupplierToBusinessPartner.BusinessPartnerUUID = BusinessPartner.BusinessPartnerUUID
    left outer join ZCDS_BP_PROFILE             as Supplier                  on JournalEntryItem.Supplier = Supplier.BusinessPartner
    left outer join I_OneTimeAccountSupplier    as OTA_SUP                   on  OTA_SUP.AccountingDocument     = JournalEntry.AccountingDocument
                                                                             and OTA_SUP.CompanyCode            = JournalEntry.CompanyCode
                                                                             and OTA_SUP.FiscalYear             = JournalEntry.FiscalYear
                                                                             and OTA_SUP.AccountingDocumentItem = JournalEntryItem.AccountingDocumentItem

  association [0..*] to I_GLAccountText as _AlternativeGLAccountText on  'YCOA'                     = _AlternativeGLAccountText.ChartOfAccounts
                                                                     and JournalEntryItem.GLAccount = _AlternativeGLAccountText.GLAccount
{
  key JournalEntry.CompanyCode,
  key JournalEntry.FiscalYear,
  key JournalEntryItem.GLAccount,
      _AlternativeGLAccountText.GLAccountLongName,
      JournalEntryItem.Ledger,
      //      JournalEntryItem.SpecialGLCode,
      JournalEntryItem.FinancialAccountType,

      Company.tencty_vn            as compName,
      Company.diachi_vn23          as compAdd,
      Company.mst                  as compMST,

      JournalEntryItem.Supplier,
      SupplierAccGrp.SupplierAccountGroup,
      BusinessPartner.IsMarkedForArchiving,
      case  when Supplier.IsOneTimeAccount is not initial then
          concat_with_space( OTA_SUP.BusinessPartnerName1,
          concat_with_space( OTA_SUP.BusinessPartnerName2,
          concat_with_space( OTA_SUP.BusinessPartnerName3, OTA_SUP.BusinessPartnerName4, 1), 1) ,1 )

           else Supplier.name  end as SupplierName,

      JournalEntryItem.AccountingDocumentType //24.05.2026 TrucTT19 add

      //      JournalEntryItem.PostingDate,
      //      JournalEntryItem.IsReversal,
      //      JournalEntryItem.IsReversed
}
where
          JournalEntryItem.Ledger                 = '0L'
  and(
          JournalEntryItem.FinancialAccountType   = 'K'
    or(
          JournalEntryItem.AccountingDocumentType = 'SA'
      and JournalEntryItem.Supplier               is not initial
    )
  ) //ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
//  and JournalEntryItem.SpecialGLCode        <> 'A'
//  and     JournalEntryItem.IsReversal             is initial
//  and     JournalEntryItem.IsReversed             is initial
group by
  JournalEntry.CompanyCode,
  JournalEntry.FiscalYear,
  JournalEntryItem.Ledger,
  JournalEntryItem.GLAccount,
  _AlternativeGLAccountText.GLAccountLongName,
  //  JournalEntryItem.SpecialGLCode,
  JournalEntryItem.FinancialAccountType,
  JournalEntryItem.PostingDate,
  JournalEntryItem.IsReversal,
  JournalEntryItem.IsReversed,
  JournalEntryItem.Supplier,
  SupplierAccGrp.SupplierAccountGroup,
  BusinessPartner.IsMarkedForArchiving,
  Supplier.IsOneTimeAccount,
  OTA_SUP.BusinessPartnerName1,
  OTA_SUP.BusinessPartnerName2,
  OTA_SUP.BusinessPartnerName3,
  OTA_SUP.BusinessPartnerName4,
  Supplier.name,
  Company.tencty_vn,
  Company.diachi_vn23,
  Company.mst,
  JournalEntryItem.AccountingDocumentType //24.05.2026 TrucTT19 add
