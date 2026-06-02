@AbapCatalog.sqlViewName: 'ZCDS_MINTAXITEM'
@AbapCatalog.compiler.compareFilter: true

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Tax Item Min FI doc'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_MINITEMTAX as select distinct from ZFA_V_TAXITEM as base
{
     key base.CompanyCode,
     key base.FiscalYear, 
  key base.AccountingDocument,
  base.tAXCODE_AT as TaxCode,
  min( base.AccountingDocumentItem ) as AccountingDocumentItem
} 
//where base.FinancialAccountType = 'S' 
group by base.CompanyCode,
base.FiscalYear,
  base.AccountingDocument,
 base.tAXCODE_AT
