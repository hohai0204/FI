@EndUserText.label: 'Bảng kê thuế GTGT Đầu ra'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FA_ZRM03_EX'
@Metadata.allowExtensions: true
define custom entity ZFA_I_RZRM03_EX
{
  
  key Object                    : abap.char( 50 );
  key object_id         : uuid;
      CompanyCode               : abap.char( 4 );
      tencty_vn                 : abap.char( 255 );
      diachi_vn                 : abap.char( 255 );
      MST_Company               : abap.char( 50 );
      AccountingDocument        : abap.char( 50 );
      @Consumption.filter.selectionType: #RANGE
      PostingDate               : abap.dats;
      Period                    : abap.char( 50 );
      customer                  : abap.char( 50 );
      CustomerName              : abap.char(255 );
      CustomerAdress            : abap.char( 255 );
      MST_Customer              : abap.char( 50 );
      DocumentReferenceID       : abap.char( 50 );
      @Consumption.filter.selectionType: #RANGE
      DocumentDate              : abap.dats;
      reversedocument           : abap.char( 50 );
      @Semantics.signReversalIndicator: true
      IsReversed                : boole_d;
      OriginalReferenceDocument : abap.char( 50 );
      DGDV                      : abap.char( 250 );
      DGDV_exc                      : abap.char( 250 );
      taxcode_desc              : abap.char( 50 );
      tax_group                 : abap.char( 50 );
      AssignmentReference       : abap.char( 50 );
      itemtext                  : abap.char( 50 );
      acc_item                  : abap.char( 50 );
      Pattern                   : abap.char( 50 );
      Invoice_Num               : abap.char( 50 );
      AccountingDocumentType    : abap.char( 50 );
      @Semantics.quantity.unitOfMeasure  : 'BaseUnit'
      Quantity                  : abap.quan( 17, 3 );
      BaseUnit                  : abap.unit( 3 );
      GLAccount                 : abap.char( 10 );
      TaxCode                   : abap.char( 2 );
      @Semantics.amount.currencyCode     : 'CompanyCodeCurrency'
      amount                    :zde_amount23;
      CompanyCodeCurrency       : abap.cuky( 5 );
      @Semantics.amount.currencyCode     : 'CompanyCodeCurrency'
      Taxamount                 : zde_amount23;
      TaxRate                   : abap.dec( 10, 7 );
      @Semantics.amount.currencyCode     : 'CompanyCodeCurrency'
      Price                     : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TaxBaseAmountInTransCrcy  : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TAXAMOUNTTRANS            : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      amount_NT                 : abap.curr( 23, 2 );
      TransactionCurrency       : abap.cuky( 5 );
      STT                       : abap.int4;
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      Totalline                 : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      Totalamount               : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      Totaltaxamount            : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      Total_SUMLINE             : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      SUMtotal                  : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'CompanyCodeCurrency'
      SUMtotal_VAT              : abap.curr( 17, 2 );

      //=====================================
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_NonTaxTS               : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_TaxTS                  : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_amountTS               : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_NonTax                 : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_Tax                    : abap.curr( 17, 2 );
      @Semantics.amount.currencyCode       : 'TransactionCurrency'
      NT_amountfull             : abap.curr( 17, 2 );


amount_text : abap.string;
taxamount_text: abap.string;
      //=====================================
      Custom_Name               : abap.char( 255 );
      Custom_MST                : abap.char( 255 );
      YY1_GCHD_JEI              : abap.char( 255 );
      Zsort                     : abap.char( 1 );
      row_type                  : abap.string;
      
      
             //      Excel
      @Semantics.largeObject     : { mimeType: 'mimetype_exc',   //case-sensitive
                               fileName: 'filename_exc',         //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #INLINE } //#ATTACHMENT
      attachment_exc                 : zattachment;
      mimetype_exc                   : abap.char(128);
      filename_exc                   : abap.char(128);
}
