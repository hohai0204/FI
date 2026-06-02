@AbapCatalog.sqlViewName: 'ZCDS_MINLG_FI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Tax Item Min Ledger min FI doc'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_MINITEMTAX_LG as select from ZFA_V_MINITEMTAX as base
inner join I_JournalEntryItem as item on base.CompanyCode = item.CompanyCode
and base.FiscalYear = item.FiscalYear
and base.AccountingDocument = item.AccountingDocument
and base.TaxCode = item.TaxCode
and base.AccountingDocumentItem = item.AccountingDocumentItem
  left outer join ZI_FA_FIDOC_A_V as FIconvert on FIconvert.AccountingDocument = base.AccountingDocument
  left outer join I_TaxCodeRate on I_TaxCodeRate.TaxCode = base.TaxCode and I_TaxCodeRate.CndnRecordValidityStartDate >= $session.system_date 
  and I_TaxCodeRate.CndnRecordValidityEndDate >= $session.system_date 
{
    key base.CompanyCode,
    key base.FiscalYear,
    key base.AccountingDocument,
    base.TaxCode,
    I_TaxCodeRate.TaxType,
    case when FIconvert.AccountingDocument is not initial then replace(base.TaxCode, 'O', 'I')
    else base.TaxCode end as TAXcode_CV,
    base.AccountingDocumentItem,
    min( item.LedgerGLLineItem ) as LG_Item
} group by base.CompanyCode,
    base.FiscalYear,
    base.AccountingDocument,
    base.TaxCode,
    base.AccountingDocumentItem,
    FIconvert.AccountingDocument,
    I_TaxCodeRate.TaxType
