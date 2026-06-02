@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Projection View ZPM01'
}
@AccessControl.authorizationCheck: #CHECK
@UI.presentationVariant:
    [{
        qualifier: 'DefaultPVariant',
        maxItems: 1000,
        visualizations: [{type: #AS_LINEITEM}]
    }]
define root view entity ZC_FA_ZPM01001
  provider contract transactional_query    
  as projection on ZR_FA_ZPM01
  
{
  @EndUserText: {
    quickInfo: 'Supplier'
  }
  key Supplier,
  @EndUserText: {
    quickInfo: 'Company Code'
  }
  key CompanyCode,
  @EndUserText: {
    quickInfo: 'Fiscal Year'
  }
  key FiscalYear,
  @EndUserText: {
    quickInfo: 'Journal Entry'
  }
  key AccountingDocument,
  @EndUserText: {
    quickInfo: 'Posting Date'
  }
  PostingDate,
  @EndUserText: {
    quickInfo: 'Ngày hóa đơn'
  }
  JournalEntryLastChangeDateTime,
  tencty_vn,
  diachi_vn,
  @EndUserText: {
    quickInfo: 'Mã số thuế'
  }
  mst,
    @EndUserText: {
    quickInfo: 'Supplier group'
  }
  SupplierAccountGroup,
    @EndUserText: {
    quickInfo: 'Nhà cung cấp (Supplier)'
  }
  NCC,
  DocumentReferenceID,
  @EndUserText: {
    quickInfo: 'Diễn giải '
  }
  AccountingDocumentHeaderText,
  @EndUserText: {
    quickInfo: 'G/L Account'
  }
  GLAccount_26,
    @EndUserText: {
    quickInfo: 'Tài khoản đối ứng '
  }
   GLAccount,
  @EndUserText: {
    quickInfo: 'Loại tiền'
  }
  TransactionCurrency,
  @EndUserText: {
    quickInfo: 'Tỷ giá'
  }
  TaxExchangeRate,
  @EndUserText: {
    quickInfo: 'Số phát sinh Nợ VND'
  }
  AmountInBalanceTransacCrcy_30,
//    @Aggregation.default: #SUM
//    @Semantics: { amount : {currencyCode: 'BalanceTransactionCurrency'} }
  @EndUserText: {
    quickInfo: 'Số phát sinh Có VND'
  }
  AmountInBalanceTransacCrcy_31,
  @EndUserText: {
    quickInfo: 'Số phát sinh Nợ ngoại tệ'
  }
  AmountInBalanceTransacCrcy_32,
  @EndUserText: {
    quickInfo: 'Số phát sinh Có ngoại tệ '
  }
  AmountInBalanceTransacCrcy_33,

  @EndUserText: {
    quickInfo: 'Balance Transaction Currency'
  }
  @Semantics.currencyCode:true
  BalanceTransactionCurrency,
//  posting,
      @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                               fileName: 'FileName',   //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #INLINE }
  attachment,
  filename,
  mimetype,
  
IsReversal,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM01H'
 @EndUserText.label: 'Số dư nợ VND đầu kỳ'
 
  virtual ct9_nodk_vnd                : abap.dec( 23, 2 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM01H'
 @EndUserText.label: 'Số dư nợ VND đầu kỳ'
  virtual ct10_codk_vnd                : abap.dec( 23, 2 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM01H'
 @EndUserText.label: 'Số dư nợ VND đầu kỳ'
  virtual ct11_nodk                : abap.dec( 23, 2 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM01H'
 @EndUserText.label: 'Số dư nợ VND đầu kỳ'
  virtual ct12_codk                : abap.dec( 23, 2 )
  
  
  
}
