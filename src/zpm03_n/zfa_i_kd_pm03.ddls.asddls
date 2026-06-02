@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for Customer Supplier in PM03'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_KD_PM03 as select distinct from ZCDS_FI_KD_DATA as main
left outer join I_Supplier on I_Supplier.TaxNumber1 = main.AssignmentReference and   I_Supplier.TaxNumber1 is not initial
{
    main.CompanyCode ,
    main.FiscalYear,
    main.AccountingDocument,
    main.AccountingDocumentItem,
    main.LedgerGLLineItem,
    main.FinancialAccountType,
    main.DocumentItemText,
   case when main.GLAccount like '141%'  or  main.GLAccount = '3331200001'
   then case when I_Supplier.Supplier is not initial then I_Supplier.Supplier 
              else  main.customer end
   else main.customer end as Customer
}
