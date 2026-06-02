
@EndUserText.label: 'View Entity for ZRM01 - Sổ chi tiết công nợ phải thu KH'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZI_FA_ZRM01'
@Metadata.allowExtensions: true
define root custom entity ZI_FA_ZRM01
{
  key Supplier                       : kunnr;
  key CompanyCode                    : abap.char(4);
  key FiscalYear                     : abap.char(4);
  key AccountingDocument             : abap.char(10);
  key object_id                      : uuid;

  key GLAccount_26                   : abap.char(10);
  key GLAccount                      : abap.char(10);
    key stt                          : abap.char(100);
   key flag                            : abap.char(1); 
      tencty_vn                      : abap.char(100);
      diachi_vn                      : abap.char(200);
      mst                            : abap.char(20);

      //  key flag                        : abap.char(1000);
      PostingDate                    : abap.dats;
      DocumentDate                    : abap.dats;
      JournalEntryLastChangeDateTime : tzntstmps;
      DocumentReferenceID            : abap.char(100);
      AccountingDocumentHeaderText   : abap.char(50);
      @EndUserText                   : {
        quickInfo                    : 'GL Account'
      }
      @Consumption.dynamicLabel      : {
      label                          : 'GL Account'
      }
      //  GLAccount_26                  : abap.char(10);
      //  GLAccount                     : abap.char(10); // TK đối ứng
      TransactionCurrency            : abap.cuky;
      TaxExchangeRate                : abap.dec(23,5);

      AmountInBalanceTransacCrcy_30  : abap.char(30);
      AmountInBalanceTransacCrcy_31  : abap.char(30);
      AmountInBalanceTransacCrcy_32  : abap.char(30);
      AmountInBalanceTransacCrcy_33  : abap.char(30);
            AmountInBalanceTransacCrcy_46  : abap.char(30);
      AmountInBalanceTransacCrcy_47  : abap.char(30);
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT30_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT31_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT32_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT33_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT46_CURR                      : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'BalanceTransactionCurrency'
      CT47_CURR                      : abap.curr( 23, 2 );

      SupplierAccountGroup           : abap.char(255);
      NCC                            : abap.char(255);
      BalanceTransactionCurrency     : abap.cuky;
      IsReversal                     :  co_stflg;
      IsNegativePosting             : abap.char(1);

      @Semantics.largeObject         : { mimeType: 'MimeType',   //case-sensitive
                                fileName: 'FileName',            //case-sensitive
                                acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                                contentDispositionPreference: #INLINE }
      attachment                     : zattachment;
      @Semantics.mimeType
      mimetype                       : abap.char(128);
      filename                       : abap.char(128);
      
      @Semantics.largeObject     : { mimeType: 'mimetype_exc',   //case-sensitive
                               fileName: 'filename_exc',         //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #INLINE } //#ATTACHMENT
      attachment_exc                 :    zattachment;
      mimetype_exc                   : abap.char(128);
      filename_exc                   : abap.char(128);
      

      ct9_nodk_vnd                   : abap.dec(23,2);
      ct10_codk_vnd                  : abap.dec(23,2);
      ct11_nodk                      : abap.dec(23,2);
      ct12_codk                      : abap.dec(23,2);
      ct44_nodk                      : abap.dec(23,2);
      ct45_codk                      : abap.dec(23,2);

      BillingDoc                     : abap.char(16);
      Z_INVOICENO                    : abap.char(200);
      Z_TOKHAI                       : abap.char(200);

      nguoilap                       : abap.char(128);
      ketoantruong                   : abap.char(128);
      giamdoc                        : abap.char(128);
      debitcreditcode                : abap.char(1);
            OriginalReferenceDocument      : awkey;
      AccountingDocumentType           : blart;
}
