@AbapCatalog.sqlViewName: 'ZV_TAXFI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View List TaxCode of FI Document'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_LISTTAX_FIDOC as select from I_JournalEntryItem as base
{
    base.AccountingDocument,
    base.CompanyCode,
    base.FiscalYear,
    count( distinct base.TaxCode ) as Count_taxcode
}
where base.TaxCode is not initial
group by  base.AccountingDocument,base.CompanyCode,
    base.FiscalYear
