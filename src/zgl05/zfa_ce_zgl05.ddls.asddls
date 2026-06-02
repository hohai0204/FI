@EndUserText.label: 'Custom entity ZGL05'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_CE_ZGL05'
@Metadata.allowExtensions: true
define root custom entity ZFA_CE_ZGL05
{

  key CompanyCode                 : abap.char(4);
  key FiscalYear                  : abap.numc(4);
  key AccountingDocument          : abap.char(10);
  key PdfId                       : abap.char(100);
      @ObjectModel.text.element   : ['GLAccountText']
      GLAccount                   : abap.char(10);
      GLAccountText               : abap.char(20);

      PostingDate                 : abap.dats(8);
      DocumentDate                : abap.dats(8);
      DocumentItemText            : abap.char(50);
      OffsettingAccount           : abap.char(10);
      OffsettingAccountName       : abap.char(80);
      ReconciliationAccount       : abap.char(10);

      @ObjectModel.text.element   : ['AccDocTypeText']
      AccountingDocumentType      : abap.char(2);
      AccDocTypeText              : abap.char(20);

      DebitCreditCode             : abap.char(1);
      Direction                   : abap.char(1);
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ZGL05_CurrVH', element: 'TransactionCurrency' } }]
      TransactionCurrency         : abap.cuky(5);
      cukyVND                     : abap.cuky(5);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DebitAmountInTransCrcy      : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CreditAmountInTransCrcy     : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      AmountInTransactionCurrency : abap.curr(23,2);
      AssignmentReference         : abap.char(18);
      AbsoluteExchangeRate        : abap.dec(9,5);

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      BeginningBalance            : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      EndingBalance               : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      CurrentBalance              : abap.curr(23,2);


      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuDauKyVND                  : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuDauKyNgoaiTe              : abap.curr(23,2);

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TonVND                      : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TonNgoaiTe                  : abap.curr(23,2);

      @Semantics.amount.currencyCode: 'cukyVND'
      ThuVND                      : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'cukyVND'
      ChiVND                      : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ThuNgoaiTe                  : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ChiNgoaiTe                  : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuTrongKyVND                : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuTrongKyUSD                : abap.curr(23,2);

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuCuoiKyVND                 : abap.curr(23,2);
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      DuCuoiKyNgoaiTe             : abap.curr(23,2);

      CurrentYear                 : abap.char(4);
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_IncludeReverseVH', element: 'Value' } } ]
      IsIncludeReversal           : abap_boolean;

      @Semantics.largeObject      : {
          fileName                : 'FileName',
          mimeType                : 'MimeType',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes     : [ '*' ]
      }
      Attachment                  : zattachment;
      FileName                    : abap.char(128);
      @Semantics.mimeType         : true
      MimeType                    : abap.char(128);


      @Semantics.largeObject      : {
          fileName                : 'FileName_Xml',
          mimeType                : 'MimeType_Xml',
          contentDispositionPreference: #ATTACHMENT,
          acceptableMimeTypes     : [ '*' ]
      }
      Attachment_Xml              : zattachment;
      FileName_Xml                : abap.char(128);
      @Semantics.mimeType         : true
      MimeType_Xml                : abap.char(128);
      
     @Semantics.largeObject     : { mimeType: 'mimetype_exc',   //case-sensitive
                               fileName: 'filename_exc',         //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #INLINE } //#ATTACHMENT
      attachment_exc                 :    zattachment;
      mimetype_exc                   : abap.char(128);
      filename_exc                   : abap.char(128);

}
