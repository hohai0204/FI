@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Root Entity Phiếu Thu'
}
@AccessControl.authorizationCheck: #CHECK
define root view entity ZFA_C_PHIEUTHU_01
  provider contract transactional_query
  as projection on ZFA_R_PHIEUTHU
{
  key Object,
  @EndUserText: {
    quickInfo: 'Journal Entry'
  }
  AccountingDocument,
  @EndUserText: {
    quickInfo: 'Company Code'
  }
  CompanyCode,
  @EndUserText: {
    quickInfo: 'Fiscal Year'
  }
  FiscalYear,
  @EndUserText: {
    quickInfo: 'Posting Date'
  }
      @Consumption.filter.selectionType: #RANGE
  PostingDate,
      @Consumption.filter.selectionType: #RANGE
  DocumentDate,
  CreateUser,
  tencty_vn,
  diachi_vn,
  @EndUserText: {
    quickInfo: 'VAT Registration Number'
  }
  mst,
  @EndUserText: {
    quickInfo: 'G/L Account'
  }
  Debit,
  @EndUserText: {
    quickInfo: 'G/L Account'
  }
  credit,
  CustomerName,
  CustomerAdress,
  @EndUserText: {
    quickInfo: 'Item Text'
  }
  Reason,
  @Semantics: {
    amount.currencyCode: 'curency'
  }
  AmountDebit,
  @EndUserText: {
    quickInfo: 'Document Reference ID'
  }
  DocumentReferenceID,
  @EndUserText: {
    quickInfo: 'Assignment Reference'
  }
  Assignment,
  @EndUserText: {
    quickInfo: 'Exchange Rate'
  }
  ExchangeRate,
  @EndUserText: {
    quickInfo: 'Transaction Currency'
  }
  curency,
  @Semantics: {
    amount.currencyCode: 'curency_vnd'
  }
  AmountDebit_VND,
  @EndUserText: {
    quickInfo: 'Company Code Currency'
  }
  curency_vnd,
           @Semantics.largeObject: { mimeType: 'MimeType',   //case-sensitive
                            fileName: 'FileName',   //case-sensitive
                            acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                            contentDispositionPreference:  #INLINE }
      attachment,
      filename,
      @Semantics.mimeType: true
     mimetype
  
}
