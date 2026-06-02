@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity Analytical ZPM03'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
@Analytics.internalName: #LOCAL
define view entity ZFA_I_ZPM03_AT as select from ZFA_I_ZPM03_NW
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
    acc_item,
    Pattern,
    Invoice_Num,
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
     @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    Price
}
