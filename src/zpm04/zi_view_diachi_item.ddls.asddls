@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View địa chỉ item'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_view_diachi_item
  as select distinct from I_JournalEntryItem
{
  key CompanyCode,
  key AccountingDocument,
      min( AccountingDocumentItem ) as AccountingDocumentItem,
      YY1_DiaChi1_COB
}
where
  YY1_DiaChi1_COB is not initial
group by
  CompanyCode,
  AccountingDocument,
  YY1_DiaChi1_COB
