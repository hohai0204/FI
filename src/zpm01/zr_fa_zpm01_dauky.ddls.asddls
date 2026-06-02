@AbapCatalog.sqlViewName: 'ZV_FA_PM01_DK'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZPM01-Sổ chi tiết CNPT NCC, NV'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_FA_ZPM01_DAUKY
  as select from    I_Supplier         as Supplier
    left outer join I_JournalEntryItem as Item_JournalEntry on  Supplier.Supplier        = Item_JournalEntry.Supplier
                                                            and Item_JournalEntry.Ledger = '0L'
    left outer join I_JournalEntry     as JournalEntry      on JournalEntry.AccountingDocument = Item_JournalEntry.AccountingDocument
{
  key Supplier.Supplier,
  key Item_JournalEntry.CompanyCode,
      //    key Item_JournalEntry.FiscalYear,
  key Item_JournalEntry.AccountingDocument,
      //    Item_JournalEntry.GLAccount,
      JournalEntry.IsReversal,
      @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      sum( case when Item_JournalEntry.DebitCreditCode = 'S' then Item_JournalEntry.AmountInBalanceTransacCrcy
                when Item_JournalEntry.DebitCreditCode = 'H' and Item_JournalEntry.IsReversal = 'X' then Item_JournalEntry.AmountInBalanceTransacCrcy
                else 0 end )   as AmountInBalanceTransacCrcy_30,
      @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
      sum( case when Item_JournalEntry.DebitCreditCode = 'H' then Item_JournalEntry.AmountInBalanceTransacCrcy
                when Item_JournalEntry.DebitCreditCode = 'S' and Item_JournalEntry.IsReversal = 'X' then Item_JournalEntry.AmountInBalanceTransacCrcy
                  else 0 end ) as AmountInBalanceTransacCrcy_31,
      Item_JournalEntry.BalanceTransactionCurrency

}
group by
  Supplier.Supplier,
  Item_JournalEntry.AccountingDocument,
  Item_JournalEntry.CompanyCode,
  //         Item_JournalEntry.FiscalYear,
  JournalEntry.IsReversal,
  Item_JournalEntry.BalanceTransactionCurrency
//         Item_JournalEntry.GLAccount
