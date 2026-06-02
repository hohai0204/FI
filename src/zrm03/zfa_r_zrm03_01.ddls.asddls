@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity TGTGT Đầu Ra'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//define root view entity ZFA_R_ZRM03 as select from ZFA_I_ZRM03
define root view entity ZFA_R_ZRM03_01
  as select from   ZFA_I_ZRM03_01  as main
//    left outer join ZFA_V_ZRM03N as virtual on main.Object = virtual.Object
{

  key    main.Object,
         main.CompanyCode,
         main.tencty_vn,
         main.diachi_vn,
         main.MST_Company,
         main.AccountingDocument,
         main.PostingDate,
         main.AccountingDocumentType,
         main.Period,
         main.customer,
         main.CustomerName,
         main.CustomerAdress,
         main.MST_Customer,
         main.DocumentReferenceID,
         main.DocumentDate,
         main.ReverseDocument,
         main.IsReversed,
         main.OriginalReferenceDocument,
         main.DGDV,
         main.taxcode_desc,
         main.tax_group,
         main.AssignmentReference,
         main.itemtext,
         main.acc_item,
         main.Pattern,
         main.Invoice_Num,
         @Semantics.quantity.unitOfMeasure: 'BaseUnit'
         main.Quantity,
         main.BaseUnit,
         main.GLAccount,
         main.TaxCode,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         main.amount,
         main.CompanyCodeCurrency,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         main.Taxamount,
         main.TaxRate,
         @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
         main.Price,
               @Semantics.amount.currencyCode: 'TransactionCurrency'
 case when TransactionCurrency <> 'VND' then TaxBaseAmountInTransCrcy else cast(0 as abap.curr( 17, 2 )) end as TaxBaseAmountInTransCrcy,
   @Semantics.amount.currencyCode: 'TransactionCurrency'
  case when TransactionCurrency <> 'VND' then TAXAMOUNTTRANS else cast(0 as abap.curr( 17, 2 )) end as TAXAMOUNTTRANS,
     @Semantics.amount.currencyCode: 'TransactionCurrency'
  case when TransactionCurrency <> 'VND' then amount_NT else cast(0 as abap.curr( 17, 2 )) end as amount_NT,
  
 case when TransactionCurrency = 'VND' then cast('USD' as abap.cuky( 5 )) else TransactionCurrency end as TransactionCurrency
 
}
where
  main.TaxCode is not initial
