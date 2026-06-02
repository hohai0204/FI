@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity ZPM03'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZFA_I_ZPM03_NW_N2
  as

  select from ZFA_I_ZPM03_01_N2 //ZFA_I_ZPM03_N
{
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
  ReverseDocument,
  IsReversed,
  OriginalReferenceDocument,
  DGDV,
  taxcode_desc,
  tax_group,
  //AssignmentReference,
    substring(
  DocumentReferenceID,1,1 )      as AssignmentReference,
  itemtext,
  acc_item,

  substring(
  DocumentReferenceID,2,
  instr( DocumentReferenceID, '.' ) - 2
                                          )      as Pattern,
  substring(
  DocumentReferenceID,
  instr( DocumentReferenceID, '.' ) + 1,
  100
                                               ) as Invoice_Num,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  Quantity,
  BaseUnit,
  GLAccount,
  TaxCode,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  amount,
  CompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  Taxamount,
  TaxRate,
  TaxRate_Text,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  Price,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
 TaxBaseAmountInTransCrcy,
   @Semantics.amount.currencyCode: 'TransactionCurrency'
  TAXAMOUNTTRANS,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
    amount_NT,
  TransactionCurrency
}
//union 
//  select from ZFA_I_ZPM03_TYPEK
//{
//  CompanyCode,
//  tencty_vn,
//  diachi_vn,
//  MST_Company,
//  AccountingDocument,
//  PostingDate,
//  Period,
//  Customer,
//  SupplierName,
//  SupplierAdress,
//  MST_Supplier,
//  DocumentDate,
//  IsReversed,
//  OriginalReferenceDocument,
//  DGDV,
//  taxcode_desc,
//  tax_group,
//  AssignmentReference,
//  itemtext,
//  acc_item,
//  substring(
//  DocumentReferenceID,1,
//  instr( DocumentReferenceID, '.' ) - 1
//                                          )      as Pattern,
//  substring(
//  DocumentReferenceID,
//  instr( DocumentReferenceID, '.' ) + 1,
//  100
//                                               ) as Invoice_Num,
//  Quantity,
//  BaseUnit,
//  GLAccount,
//  TaxCode,
//  amount,
//  CompanyCodeCurrency,
//  Taxamount,
//  TaxRate,
//  TaxRate_Text,
//  Price
//}
