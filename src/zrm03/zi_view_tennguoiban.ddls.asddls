@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View tên người bán'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_view_tennguoiban
  as select distinct from I_JournalEntryItem
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
      min( AccountingDocumentItem ) as AccountingDocumentItem,
      YY1_TenDonVi_COB as YY1_TDV_JEI
}
where
  YY1_TenDonVi_COB is not initial
group by
  CompanyCode,
  AccountingDocument,
  FiscalYear,
  YY1_TenDonVi_COB
//check check 
