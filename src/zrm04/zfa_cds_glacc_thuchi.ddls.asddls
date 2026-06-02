@AbapCatalog.sqlViewName: 'ZV_ACC_THUCHI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS GL_Account Thu - Chi'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_CDS_GLACC_THUCHI as select from ZFA_CDS_GLACCOUNT as main
inner join ZFA_CDS_GLACCOUNT_COUNT1 as _count on _count.CompanyCode = main.CompanyCode
and _count.FiscalYear = main.FiscalYear
and _count.AccountingDocument = main.AccountingDocument
and _count.DebitCreditCode = main.DebitCreditCode
and _count.CompanyCode = main.CompanyCode
{
    main.CompanyCode,
    main.FiscalYear,
    main.AccountingDocument,
    main.DebitCreditCode,
    main.GLAccount,
    main.amount,
    main.amount_VND
}
where _count.count_line = 1
