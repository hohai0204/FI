@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity TGTGT Đầu Vào'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_R_ZPM03_NW as 

select from ZFA_I_ZPM03_NW
  
       association [0..*] to I_UnitOfMeasureText            as _UnitText               on  $projection.BaseUnit = _UnitText.UnitOfMeasure and _UnitText.Language = $session.system_language
 
{
key tax_group,
key  DocumentDate,
 key concat(concat(
  concat(
   concat( 
   concat(  coalesce(CompanyCode, ''),
      coalesce(AccountingDocument, '')
    ), 
    acc_item ),
    coalesce(tax_group, '')
  ),
  coalesce(TaxCode, '')
),coalesce(Customer, '') 
 
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

    ReverseDocument,
    IsReversed,
    OriginalReferenceDocument,
    DGDV,
    taxcode_desc,

    AssignmentReference,
    itemtext,
    acc_item,
    Pattern,
   Invoice_Num,
    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    Quantity,
     @ObjectModel.text.element: [ 'BaseUnitText' ]
    BaseUnit,
   _UnitText.UnitOfMeasureLongName  as BaseUnitText,
    GLAccount,
    TaxCode,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    amount,
    CompanyCodeCurrency,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    @DefaultAggregation: #SUM
    Taxamount,
    TaxRate,
    TaxRate_Text,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    Price,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
 case when TransactionCurrency <> 'VND' then TaxBaseAmountInTransCrcy else cast(0 as abap.curr( 17, 2 )) end as TaxBaseAmountInTransCrcy,
   @Semantics.amount.currencyCode: 'TransactionCurrency'
  case when TransactionCurrency <> 'VND' then TAXAMOUNTTRANS else cast(0 as abap.curr( 17, 2 )) end as TAXAMOUNTTRANS,
     @Semantics.amount.currencyCode: 'TransactionCurrency'
  case when TransactionCurrency <> 'VND' then amount_NT else cast(0 as abap.curr( 17, 2 )) end as amount_NT,
  
 case when TransactionCurrency = 'VND' then cast('USD' as abap.cuky( 5 )) else TransactionCurrency end as TransactionCurrency
,   _UnitText
}


