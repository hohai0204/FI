@EndUserText.label: 'View Entity for ZI_FA_ZPM01_EX'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZI_FA_ZPM01_EX'
@Metadata.allowExtensions: true

define root custom entity  ZI_FA_ZPM01_EX
{

  key supplier_account_group         : ktokk;
  key Supplier                       : lifnr;
  key CompanyCode                    : abap.char(4);
  key FiscalYear                     : abap.char(4);
  key AccountingDocument             : abap.char(10);
  key GLAccount_26                   : abap.char(10);
  key GLAccount                      : abap.char(10);
  key stt                            : abap.char(100);

      des                            : abap.char(255);
      PostingDate                    : abap.dats;

   JournalEntryLastChangeDateTime : tzntstmps;
      DocumentDate                    : abap.dats;
       Z_TOKHAI                       : abap.char(200);
        Z_INVOICENO                    : abap.char(200);
      DocumentReferenceID            : abap.char(100);
      AccountingDocumentHeaderText   : abap.char(50);
      
      TransactionCurrency            : abap.cuky;
      TaxExchangeRate                : abap.dec(23,5);

      ZNO_VND                        : abap.char(200);
      ZCO_VND                        : abap.char(200);
      ZNO_NT                         : abap.char(200);
      ZCO_NT                         : abap.char(200);
      ZNO                         : abap.char(200);
      ZCO                         : abap.char(200);
      AmountInBalanceTransacCrcy_46  : abap.char(200);
      AmountInBalanceTransacCrcy_47  : abap.char(200);
      
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT46_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT47_CURR                      : abap.curr( 23, 2 );
      
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT30_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT31_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT32_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT33_CURR                      : abap.curr( 23, 2 );


      BalanceTransactionCurrency     : abap.cuky;
      
      NCC            : abap.char(255);
    SupplierAccountGroup           : abap.char(255);
     IsReversal                     : co_stflg;
     IsNegativePosting              : abap.char(1);
     Customer        :kunnr;
      BillingDoc                     : abap.char(16);

      ZLAYOUT                     : zde_layout_ex;
            OriginalReferenceDocument      : awkey;
     AccountingDocumentType           : blart;
}
