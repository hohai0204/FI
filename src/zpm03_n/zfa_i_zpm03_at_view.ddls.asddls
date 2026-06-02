@Analytics.query: true
@VDM.viewType: #CONSUMPTION
@EndUserText.label: 'Query for ZPM03'
define view entity ZFA_I_ZPM03_AT_VIEW as select from ZFA_I_ZPM03_AT
{
key Object,
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
