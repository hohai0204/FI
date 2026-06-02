@AbapCatalog.sqlViewName: 'ZV_FA_PM01_TKDU'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZPM01 Tài khoản đối ứng'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_FA_ZPM01_TKDU as select from I_JournalEntryItem as Item_JournalEntry
{
  key Item_JournalEntry.CompanyCode,
  key Item_JournalEntry.FiscalYear,
  key Item_JournalEntry.AccountingDocument, 
max( Item_JournalEntry.GLAccount ) as GLAccount
}where   Item_JournalEntry.FinancialAccountType <> 'K'
         and Item_JournalEntry.Ledger               = '0L'
group by Item_JournalEntry.CompanyCode,
  Item_JournalEntry.FiscalYear,
  Item_JournalEntry.AccountingDocument
