@Analytics.query: true
@VDM.viewType: #CONSUMPTION
@EndUserText.label: 'Query for ZPM03 Analytical'
@Metadata.allowExtensions: true
define view entity ZFA_Q_ZPM03_AT_QUERY
  as select from ZFA_I_ZPM03_AT
{
  // Key Fields
  key Object,
  CompanyCode,
  AccountingDocument,
  acc_item,
  PostingDate,
   Period,

  // Grouped Fields (dimension-like)
  tencty_vn,
  diachi_vn,
  MST_Company,
  customer,
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
  Pattern,
  Invoice_Num,
  GLAccount,
  TaxCode,
  TaxRate,
  BaseUnit,

  // Quantity
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  @DefaultAggregation: #SUM
  @Aggregation.default: #SUM
  Quantity,

  // Amount
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  @DefaultAggregation: #SUM
  @Aggregation.default: #SUM
  amount,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  @DefaultAggregation: #SUM
  @Aggregation.default: #SUM
  Taxamount,

  // Price – KHÔNG tổng được nên không đặt aggregation
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  Price,

  // Currency field (no aggregation needed)
  CompanyCodeCurrency
}
