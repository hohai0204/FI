@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZPM01'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_COUNT_glaccount as select from I_JournalEntryItem as item_journalentry
                     inner join I_JournalEntry as journalentry
            on journalentry.AccountingDocument = item_journalentry.AccountingDocument
{
    item_journalentry.AccountingDocument, 
//    count( item_journalentry.GLAccount ) as c,
    count( * ) as c,
        /* Kiểm tra xem chứng từ có dòng nào được clearing không */   
    max(
      case
        when item_journalentry.ClearingJournalEntry is not initial
        then 1
        else 0
      end
    ) as Clearing,
    /* Kiểm tra xem Supplier có giống nhau không:
     - Nếu số lượng supplier khác biệt > 1 ⇒ có nhiều supplier ⇒ 0
     - Nếu chỉ có 1 supplier ⇒ 1 (tức là giống nhau)
  */
  case
    when count( distinct item_journalentry.Supplier ) = 1
    then 1
    else 0
  end as SameSupplier,

  /* Kiểm tra xem GLAccount có giống nhau không:
     - Nếu số lượng GLAccount khác biệt > 1 ⇒ có nhiều tài khoản ⇒ 0
     - Nếu chỉ có 1 GLAccount ⇒ 1 (giống nhau)
  */
  case
    when count( distinct item_journalentry.GLAccount ) = 1
    then 1
    else 0
  end as SameGLAccount
}where item_journalentry.FinancialAccountType = 'K'
   and item_journalentry.Ledger = '0L'
           group by item_journalentry.AccountingDocument
