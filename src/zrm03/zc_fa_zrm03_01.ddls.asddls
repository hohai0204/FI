@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Root Entity TGTGT Đầu Ra'
}
@AccessControl.authorizationCheck: #CHECK
@UI.presentationVariant: [{
  maxItems: 1000,
    sortOrder: [

       { by: 'AccountingDocument'} ],

     groupBy: [ 'DGDV' ],

     visualizations: [{ type: #AS_LINEITEM }]

//     requestAtLeast: [ 'DGDV'],
//     total: [ 'Taxamount' ]


     }]
     
define root view entity ZC_FA_ZRM03_01
  provider contract transactional_query
  as projection on ZFA_R_ZRM03_01
{
  key Object,
  @EndUserText: {
    quickInfo: 'Company Code'
  }
  CompanyCode,
  tencty_vn,
  diachi_vn,
  @EndUserText: {
    quickInfo: 'VAT Registration Number'
  }
  MST_Company,
  @EndUserText: {
    quickInfo: 'Journal Entry'
  }
  AccountingDocument,
  @EndUserText: {
    quickInfo: 'Posting Date'
  }
    @Consumption.filter.selectionType: #RANGE
  PostingDate,
  Period,
  @EndUserText: {
    quickInfo: 'Supplier'
  }
  customer,
  CustomerName,
  CustomerAdress,
  @EndUserText: {
    quickInfo: 'Tax Number 1'
  }
  MST_Customer,
  @EndUserText: {
    quickInfo: 'Document Reference ID'
  }
  DocumentReferenceID,
  @EndUserText: {
    quickInfo: 'Journal Entry Date'
  }
    @Consumption.filter.selectionType: #RANGE
  DocumentDate,
  ReverseDocument,
  
  @EndUserText: {
    quickInfo: 'Indicator: Item is Reversed'
  }
  IsReversed,
  @EndUserText: {
    quickInfo: 'Object key'
  }
  OriginalReferenceDocument,
  DGDV,
  @EndUserText: {
    quickInfo: 'Text (100 characters)'
  }
  taxcode_desc,
  tax_group,
  @EndUserText: {
    quickInfo: 'Assignment Reference'
  }
  AssignmentReference,
  @EndUserText: {
    quickInfo: 'Item Text'
  }
  itemtext,
  @EndUserText: {
    quickInfo: 'Journal Entry Posting View Item'
  }
  acc_item,
    Pattern,
    Invoice_Num,
    AccountingDocumentType,
  @EndUserText: {
    quickInfo: 'Quantity'
  }
  @Semantics: {
    quantity.unitOfMeasure: 'BaseUnit'
  }
  Quantity,
  @EndUserText: {
    quickInfo: 'Base Unit of Measure'
  }
  BaseUnit,
  @EndUserText: {
    quickInfo: 'G/L Account'
  }
  GLAccount,
  @EndUserText: {
    quickInfo: 'Tax on Sales/Purchases Code'
  }
  TaxCode,
  @EndUserText: {
    quickInfo: 'Amount in Company Code Currency'
  }
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
  amount,
  @EndUserText: {
    quickInfo: 'Company Code Currency'
  }
  CompanyCodeCurrency,
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
  Taxamount,
  TaxRate,
  @EndUserText: {
    quickInfo: 'Amount in Company Code Currency'
  }
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
  Price,
                 @Semantics.amount.currencyCode: 'TransactionCurrency'
TaxBaseAmountInTransCrcy,
   @Semantics.amount.currencyCode: 'TransactionCurrency'
 TAXAMOUNTTRANS,
     @Semantics.amount.currencyCode: 'TransactionCurrency'
  amount_NT,
  TransactionCurrency,
  
  //  STT,
//  ztesst
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
//  virtual STT   : abap.int4,

//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
//  virtual Totalamount   : abap.curr( 17, 2 ),
//    @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//}
//  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
//  virtual Totaltaxamount   : abap.curr( 17, 2 ),
//  
//    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
//  virtual Custom_Name   : abap.char( 255 ),
//      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
//  virtual Custom_MST   : abap.char( 100 )
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual STT   : abap.int4,
    @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Totalline   : abap.curr( 17, 2 ),
  
  @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Totalamount   : abap.curr( 17, 2 ),
    @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Totaltaxamount   : abap.curr( 17, 2 ),
      @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Total_SUMLINE   : abap.curr( 17, 2 ),
  
      @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual SUMtotal   : abap.curr( 17, 2 ),
        @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual SUMtotal_VAT   : abap.curr( 17, 2 ),
  
  //=====================================
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_NonTaxTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_TaxTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_amountTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_NonTax   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_Tax   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual NT_amountfull   : abap.curr( 17, 2 ),
  //==========================================
  
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Custom_Name   : abap.char( 255 ),
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual Custom_MST   : abap.char( 255 ),
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03'
  virtual YY1_GCHD_JEI   : abap.char( 255 )

}
