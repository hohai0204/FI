@AbapCatalog.sqlViewName: 'ZFA_VZPM03N'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Analytical ZPM03'
@Metadata.ignorePropagatedAnnotations: true

define view ZFA_V_ZPM03_NW as select from ZFA_I_ZPM03_NW 
{
    key concat(
  concat(
   concat( 
   concat(  coalesce(CompanyCode, ''),
      coalesce(AccountingDocument, '')
    ), 
    acc_item ),
    coalesce(tax_group, '')
  ),
  coalesce(TaxCode, '')
) as Object,
  CompanyCode,
  tencty_vn,
  diachi_vn,

  MST_Company,

  AccountingDocument,
  PostingDate,
  Period,
  Customer,
  SupplierName,
  SupplierAdress,

  MST_Supplier,

  DocumentDate,

  IsReversed,

  OriginalReferenceDocument,
  DGDV,
 
  taxcode_desc,
  tax_group,
 
  AssignmentReference,

  itemtext,
//  Pattern,
//   Invoice_Num,
  acc_item,
  @Semantics: {
    quantity.unitOfMeasure: 'BaseUnit'
  }
  Quantity,
  BaseUnit,
  GLAccount,
  TaxCode,
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
  amount,
  CompanyCodeCurrency,
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
   @UI.lineItem: [{ position: 210, label: 'Thuế GTGT' }]
    @DefaultAggregation: #SUM
  Taxamount,
  TaxRate,
  @Semantics: {
    amount.currencyCode: 'CompanyCodeCurrency'
  }
  Price
//            @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZPM03'
//  virtual STT   : abap.int4
}
