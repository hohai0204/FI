@AbapCatalog.sqlViewName: 'ZFA_GLA_COUNT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Disctine GL_Account Thu - Chi'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_CDS_GLACCOUNT_COUNT1 as select from ZFA_CDS_GLACCOUNT
{
    CompanyCode,
    FiscalYear,
    AccountingDocument,
    DebitCreditCode,
    count( distinct GLAccount ) as count_line
}
group by   CompanyCode,
    FiscalYear,
    AccountingDocument,
    DebitCreditCode
