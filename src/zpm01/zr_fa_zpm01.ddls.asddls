@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity ZPM01– Sổ chi tiết CNPT NCC, NV'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_FA_ZPM01
  as select from    I_Supplier         as Supplier
    inner join      I_JournalEntryItem as Item_JournalEntry      on  Supplier.Supplier                      = Item_JournalEntry.Supplier
                                                                 and Item_JournalEntry.FinancialAccountType = 'K'
    //                                                          and Item_JournalEntry.GLAccountType        <> 'X'
                                                                 and Item_JournalEntry.Ledger               = '0L'
    inner join      I_JournalEntry     as JournalEntry           on JournalEntry.AccountingDocument = Item_JournalEntry.AccountingDocument
    left outer join ZI_FA_ZPM01_GITEM  as group_JournalEntryItem_vnd on  group_JournalEntryItem_vnd.CompanyCode = JournalEntry.CompanyCode
                                                                 and JournalEntry.AccountingDocument    = group_JournalEntryItem_vnd.AccountingDocument
                                                                 and Supplier.Supplier                  = group_JournalEntryItem_vnd.Supplier
                                                                 and group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
        left outer join ZI_FA_ZPM01_GITEM  as group_JournalEntryItem on  group_JournalEntryItem.CompanyCode = JournalEntry.CompanyCode
                                                                 and JournalEntry.AccountingDocument    = group_JournalEntryItem.AccountingDocument
                                                                 and Supplier.Supplier                  = group_JournalEntryItem.Supplier
                                                                 and group_JournalEntryItem.BalanceTransactionCurrency <> 'VND'
    left outer join ZCDS_BP            as BP                     on Supplier.Supplier = BP.BusinessPartner
    left outer join ztb_fi_pdf_draf     as pdf    on JournalEntry.AccountingDocument = pdf.object_id and pdf.report_id                 = 'ZFA_ZPM01'
    left outer join ZI_FA_ZPM01_TKDU as TKDU on TKDU.CompanyCode = JournalEntry.CompanyCode
                                                                 and JournalEntry.AccountingDocument    = TKDU.AccountingDocument
                                                                 and JournalEntry.FiscalYear = TKDU.FiscalYear 
association [0..1] to ZCDS_COMPANY as _Company on $projection.CompanyCode = _Company.CompanyCode                                                      {
  key Supplier.Supplier,
  key JournalEntry.CompanyCode,
  key JournalEntry.FiscalYear,
  key JournalEntry.AccountingDocument, // ct21
      JournalEntry.JournalEntryLastChangeDateTime,
      JournalEntry.PostingDate,
      substring (JournalEntry.DocumentReferenceID ,
      instr(JournalEntry.DocumentReferenceID ,'.') + 1 ,
      100 )                   as DocumentReferenceID,
      JournalEntry.AccountingDocumentHeaderText, // ct25
      case when Item_JournalEntry.FinancialAccountType =  'K' then Item_JournalEntry.GLAccount
      end                     as GLAccount_26, //ct26 Tài khoản
      TKDU.GLAccount,//ct27 Tài khoản đối ứng
      JournalEntry.TransactionCurrency, //ct28 Loaị tiền
      case when JournalEntry.TransactionCurrency <>  'VND' then  JournalEntry.TaxAbsoluteExchangeRate * JournalEntry.AbsoluteExchangeRate
      end                     as TaxExchangeRate, //29
      cast(
       case
         when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
              and group_JournalEntryItem_vnd.IsReversal = 'X'
         then concat(
                concat('{', cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_30 as abap.char(25))),
                '}'
              )

         when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
         then cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_30 as abap.char(27))
       end as abap.char(27) ) as AmountInBalanceTransacCrcy_30,
//      @Aggregation.default: #SUM
      cast(
        case
          when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
               and group_JournalEntryItem_vnd.IsReversal = 'X'
          then concat(
                 concat('{', cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_31 as abap.char(25))),
                 '}'
               )
          when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
          then cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_31 as abap.char(27))
        end as abap.char(30)
      ) as AmountInBalanceTransacCrcy_31,//31
      cast(
        case
          when JournalEntry.TransactionCurrency <> 'VND'
               and group_JournalEntryItem.IsReversal = 'X'
          then concat(
                 concat('{', cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_30 as abap.char(25))),
                 '}'
               )
          when JournalEntry.TransactionCurrency <> 'VND'
          then cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_30 as abap.char(27))
          else ''
        end as abap.char(30)
      )                       as AmountInBalanceTransacCrcy_32, //32
      cast(
        case
          when JournalEntry.TransactionCurrency <> 'VND'
               and group_JournalEntryItem.IsReversal = 'X'
          then concat(
                 concat('{', cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_31 as abap.char(25))),
                 '}'
               )
          when JournalEntry.TransactionCurrency <> 'VND'
          then cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_31 as abap.char(27))
          else ''
        end as abap.char(30)
      )                       as AmountInBalanceTransacCrcy_33, //33
    
     cast(
      case
       when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
         then cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_30 as abap.char(27))
       end as abap.char(27))  as CT30_CURR,
        case
 when group_JournalEntryItem_vnd.BalanceTransactionCurrency = 'VND'
          then cast(group_JournalEntryItem_vnd.AmountInBalanceTransacCrcy_31 as abap.char(27))
      end as CT31_CURR ,//31
        case
         when JournalEntry.TransactionCurrency <> 'VND'
          then cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_30 as abap.char(27))
      end as ct32_curr, //32
        case
                    when JournalEntry.TransactionCurrency <> 'VND'
          then cast(group_JournalEntryItem.AmountInBalanceTransacCrcy_31 as abap.char(27))
      end as ct33_curr, //33
      
      _Company.tencty_vn,
      _Company.diachi_vn,
      _Company.mst,
      Supplier.SupplierAccountGroup, //3
      concat(
                 concat(Supplier.Supplier, '-'),
                 BP.name
               )              as NCC,
      Item_JournalEntry.BalanceTransactionCurrency,
            @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                               fileName: 'FileName',   //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #ATTACHMENT }
      pdf.attachment,
      pdf.filename,
      pdf.mimetype,
    JournalEntry.IsReversal,

  cast ( 0 as abap.dec(23,2) ) as ct9_nodk_vnd,
cast ( 0 as abap.dec(23,2) ) as ct10_codk_vnd ,
cast (0 as abap.dec(23,2) ) as ct11_nodk ,
cast (0 as abap.dec(23,2) ) as ct12_codk
}

