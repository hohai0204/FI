@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZPM01 ITEM_JOURNALENTRY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_ZPM01_ITEM_JOURNALENTRY  as select from I_JournalEntryItem
{
  key AccountingDocument,
  key CompanyCode,
  key FiscalYear,
  key Ledger,
  Supplier,
  GLAccount,
  PostingKey,
//  DebitCreditCode,
  FinancialAccountType,
  ClearingJournalEntry,
//@Aggregation.default: #SUM
//@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
//  AmountInCompanyCodeCurrency,
//@Aggregation.default: #SUM
//@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
//  AmountInTransactionCurrency,
//  CompanyCodeCurrency,
  TransactionCurrency,
  DocumentItemText,
  LedgerGLLineItem,
  IsReversal,
  IsReversed
}
where
      Ledger = '0L'
  and FinancialAccountType = 'K'
  group by  AccountingDocument,
  CompanyCode,
  FiscalYear,
  Ledger,
  Supplier,
  GLAccount,
  PostingKey,
    FinancialAccountType,
  ClearingJournalEntry,
    TransactionCurrency,
    DocumentItemText,
  LedgerGLLineItem,
  IsReversal,
  IsReversed
