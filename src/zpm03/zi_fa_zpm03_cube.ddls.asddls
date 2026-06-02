
@Analytics.query: true
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_FA_ZPM03_CUBE
  as select from ZFA_I_ZPM03_NW
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
  acc_item,
  Quantity,
  BaseUnit,
  GLAccount,
  TaxCode,

  @DefaultAggregation: #SUM
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  amount,

  @DefaultAggregation: #SUM
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  Taxamount,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  Price,

  CompanyCodeCurrency,
  TaxRate
}
