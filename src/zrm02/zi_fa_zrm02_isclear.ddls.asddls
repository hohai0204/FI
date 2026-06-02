@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity for Clearing Doc'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_FA_ZRM02_ISCLEAR
  as select from I_JournalEntryItem
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,

      // Logic: Đếm số lượng GL và Supplier duy nhất trong cùng mã chứng từ
      case when count( distinct GLAccount ) = 1
            and count( distinct Customer ) = 1
           then 'X'
           else ' '
      end as IsClear
}
where
  AccountingDocumentType = 'CL'
group by
  CompanyCode,
  AccountingDocument,
  FiscalYear
