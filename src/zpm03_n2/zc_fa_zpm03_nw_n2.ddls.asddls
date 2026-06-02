@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Root Entity TGTGT Đầu Vào'
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
define root view entity ZC_FA_ZPM03_NW_N2
 provider contract transactional_query
 as projection on ZFA_R_ZPM03_NW_N2
{


key tax_group,
  @EndUserText: {
    quickInfo: 'Journal Entry Date'
  }
    @Consumption.filter.selectionType: #RANGE
   
key  DocumentDate,
  key Object,

  @EndUserText: {
    quickInfo: 'Company Code'
  }
  CompanyCode,
  @DefaultAggregation: #NONE
  tencty_vn,
  @DefaultAggregation: #NONE
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
  @DefaultAggregation: #NONE
  Customer,
  @DefaultAggregation: #NONE
  SupplierName,
  @DefaultAggregation: #NONE
  SupplierAdress,
  @EndUserText: {
    quickInfo: 'Tax Number 1'
  }
  @DefaultAggregation: #NONE
  MST_Supplier,

  ReverseDocument,
  
  @EndUserText: {
    quickInfo: 'Indicator: Item is Reversed'
  }
  IsReversed,
  @EndUserText: {
    quickInfo: 'Object key'
  }
  @DefaultAggregation: #NONE
  OriginalReferenceDocument,

  DGDV,
  @EndUserText: {
    quickInfo: 'Text (100 characters)'
  }
  @DefaultAggregation: #NONE
  taxcode_desc,


  @EndUserText: {
    quickInfo: 'Assignment Reference'
  }
  AssignmentReference,
  @EndUserText: {
    quickInfo: 'Item Text'
  }
  itemtext,
  Pattern,
   Invoice_Num,
  acc_item,
@Semantics: {
  quantity.unitOfMeasure: 'BaseUnit'
}
Quantity,
// @DefaultAggregation: #NONE
  @EndUserText: {
    quickInfo: 'Base Unit of Measure'
  }
// @Aggregation.default: #NONE
     @ObjectModel.text.element: [ 'BaseUnitText' ]
  BaseUnit,
  BaseUnitText,
  @EndUserText: {
    quickInfo: 'G/L Account'
  }
 // @DefaultAggregation: #NONE
  GLAccount,
  @EndUserText: {
    quickInfo: 'Tax on Sales/Purchases Code'
  }
//  @DefaultAggregation: #NONE
  TaxCode,
  @EndUserText: {
    quickInfo: 'Amount in Company Code Currency'
  }
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
//  @DefaultAggregation: #SUM
  amount,
  @EndUserText: {
    quickInfo: 'Company Code Currency'
  }
// @AnalyticsDetails.query.display: #TEXT
//    @AnalyticsDetails.query.axis: #FREE
//  @Aggregation.default: #NONE
//  @DefaultAggregation: #NONE
  CompanyCodeCurrency,
  @EndUserText: {
    quickInfo: 'Amount in Company Code Currency'
  }
@UI.lineItem: [{ position: 210, label: 'Thuế GTGT' }]
//@DefaultAggregation: #SUM
//@Aggregation.default: #SUM
@Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
Taxamount,
  TaxRate,
  TaxRate_Text,
//@DefaultAggregation: #SUM
//@Aggregation.default: #SUM
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
  
// stt,
//  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//  Totalline,
//
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//  }
//  Totalamount,
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//  }
//  Totaltaxamount,
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//  }
//  Total_SUMLINE,
//
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//  }
//  SUMtotal,
//  @Semantics: {
//  amount.currencyCode: 'CompanyCodeCurrency'
//  }
//  SUMtotal_VAT
@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual STT   : abap.int4,
    @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual Totalline   : abap.curr( 17, 2 ),
  
  @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual Totalamount   : abap.curr( 17, 2 ),
    @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual Totaltaxamount   : abap.curr( 17, 2 ),
      @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual Total_SUMLINE   : abap.curr( 17, 2 ),
  
      @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual SUMtotal   : abap.curr( 17, 2 ),
        @Semantics: {
  amount.currencyCode: 'CompanyCodeCurrency'
}
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual SUMtotal_VAT   : abap.curr( 17, 2 ),
  
  
    //=====================================
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_NonTaxTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_TaxTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_amountTS   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_NonTax   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_Tax   : abap.curr( 17, 2 ),
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual NT_amountfull   : abap.curr( 17, 2 ),
  //==========================================
  
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
  virtual YY1_GCHD_JEI   : abap.char( 255 )
  
//,testdec
}
