@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZPM01 ITEM_JOURNALENTRY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_ZPM01_JournalEntryItem_K   as select from I_JournalEntryItem
{
     AccountingDocument,
    CompanyCode,
    FiscalYear,
    Supplier,
    GLAccount,
    PostingKey,
       DocumentItemText,
    BalanceTransactionCurrency,
    ClearingJournalEntry
}group by
    AccountingDocument,
    CompanyCode,
    FiscalYear,
    Supplier,
    GLAccount,
    PostingKey,
   DocumentItemText,
   BalanceTransactionCurrency,
   ClearingJournalEntry
