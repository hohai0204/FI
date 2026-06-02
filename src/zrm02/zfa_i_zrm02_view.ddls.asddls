@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View entity ZRM02'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZRM02_VIEW
  as select from    I_JournalEntryItem          as JournalEntryItem
    inner join      I_JournalEntry              as JournalEntry              on  JournalEntry.CompanyCode        = JournalEntryItem.CompanyCode
                                                                             and JournalEntry.AccountingDocument = JournalEntryItem.AccountingDocument
                                                                             and JournalEntry.FiscalYear         = JournalEntryItem.FiscalYear
    left outer join ZCDS_COMPANY                as Company                   on JournalEntry.CompanyCode = Company.CompanyCode
    left outer join I_Customer                  as CustomerAccGrp            on CustomerAccGrp.Customer = JournalEntryItem.Customer
    left outer join I_CustomerToBusinessPartner as CustomerToBusinessPartner on JournalEntryItem.Customer = CustomerToBusinessPartner.Customer
    left outer join I_BusinessPartner           as BusinessPartner           on CustomerToBusinessPartner.BusinessPartnerUUID = BusinessPartner.BusinessPartnerUUID
    left outer join ZCDS_BP_PROFILE             as Customer                  on JournalEntryItem.Customer = Customer.BusinessPartner
    left outer join I_OneTimeAccountCustomer    as OTA_CUST                  on  OTA_CUST.AccountingDocument     = JournalEntry.AccountingDocument
                                                                             and OTA_CUST.CompanyCode            = JournalEntry.CompanyCode
                                                                             and OTA_CUST.FiscalYear             = JournalEntry.FiscalYear
                                                                             and OTA_CUST.AccountingDocumentItem = JournalEntryItem.AccountingDocumentItem

  association [0..*] to I_GLAccountText     as _AlternativeGLAccountText on  'YCOA'                     = _AlternativeGLAccountText.ChartOfAccounts
                                                                         and JournalEntryItem.GLAccount = _AlternativeGLAccountText.GLAccount
  association [0..1] to ZI_FA_ZRM02_ISCLEAR as _ClearingDocument         on  _ClearingDocument.CompanyCode        = JournalEntryItem.CompanyCode
                                                                         and _ClearingDocument.FiscalYear         = JournalEntryItem.FiscalYear
                                                                         and _ClearingDocument.AccountingDocument = JournalEntryItem.AccountingDocument
{
  key JournalEntry.CompanyCode,
  key JournalEntry.FiscalYear,
  key JournalEntryItem.GLAccount,
      _AlternativeGLAccountText.GLAccountLongName,
      JournalEntryItem.Ledger,
      JournalEntryItem.FinancialAccountType,
      Company.tencty_vn            as compName,
      Company.diachi_vn23          as compAdd,
      Company.mst                  as compMST,

      JournalEntryItem.Customer,
      CustomerAccGrp.CustomerAccountGroup,
      BusinessPartner.IsMarkedForArchiving,
      case  when Customer.IsOneTimeAccount is not initial then
          concat_with_space( OTA_CUST.BusinessPartnerName1,
          concat_with_space( OTA_CUST.BusinessPartnerName2,
          concat_with_space( OTA_CUST.BusinessPartnerName3, OTA_CUST.BusinessPartnerName4, 1), 1) ,1 )

           else Customer.name  end as CustomerName,
      _ClearingDocument.IsClear //TrucTT19 add

}
where
      JournalEntryItem.Ledger               = '0L'
  //  and(
  //          JournalEntryItem.FinancialAccountType   = 'D'
  //    or(
  //          JournalEntryItem.AccountingDocumentType = 'SA'
  //      and JournalEntryItem.Supplier               is not initial
  //    )
  //  )

  and JournalEntryItem.FinancialAccountType = 'D'
//  and JournalEntryItem.IsReversal           is initial
//  and JournalEntryItem.IsReversed           is initial

group by
  JournalEntry.CompanyCode,
  JournalEntry.FiscalYear,
  JournalEntryItem.Ledger,
  JournalEntryItem.GLAccount,
  _AlternativeGLAccountText.GLAccountLongName,
  JournalEntryItem.FinancialAccountType,
  JournalEntryItem.Customer,
  CustomerAccGrp.CustomerAccountGroup,
  BusinessPartner.IsMarkedForArchiving,
  Customer.IsOneTimeAccount,
  OTA_CUST.BusinessPartnerName1,
  OTA_CUST.BusinessPartnerName2,
  OTA_CUST.BusinessPartnerName3,
  OTA_CUST.BusinessPartnerName4,
  Customer.name,
  Company.tencty_vn,
  Company.diachi_vn23,
  Company.mst,
  _ClearingDocument.IsClear //TrucTT19 add
