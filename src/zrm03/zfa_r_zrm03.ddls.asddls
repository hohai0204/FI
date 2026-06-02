@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity TGTGT Đầu Ra'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//define root view entity ZFA_R_ZRM03 as select from ZFA_I_ZRM03
define root view entity ZFA_R_ZRM03
  as select from    ZFA_I_ZRM03  as main
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
         main.Price
 
}
where
  main.TaxCode is not initial
