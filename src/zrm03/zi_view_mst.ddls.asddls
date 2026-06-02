@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View MST'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VIEW_MST as select distinct from I_JournalEntryItem
{
  key AccountingDocument,
  key CompanyCode,
  key FiscalYear,
      min( AccountingDocumentItem ) as AccountingDocumentItem,
      AssignmentReference
}
where
  AssignmentReference is not initial
  and GLAccount like '133%'
  and YY1_CCT1_JEI is initial
  and YY1_DCCT2_COB is not initial
group by
  CompanyCode,
  AccountingDocument,
  FiscalYear,
  AssignmentReference
