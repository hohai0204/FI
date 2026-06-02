@AbapCatalog.sqlViewName: 'ZV_ZRM03N'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View ZRM03'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_ZRM03N
  as select from    I_JournalEntry  as Fi_head

    left outer join ZFA_V_TAXFI_SUM as ItemTax    on  ItemTax.AccountingDocument = Fi_head.AccountingDocument
                                                  and ItemTax.CompanyCode        = Fi_head.CompanyCode
    inner join      ztb_fi_ztax     as _Tax_Group on  _Tax_Group.tax_code = ItemTax.TaxCode
                                                  and _Tax_Group.tax_type = 'B'
{
  key concat(
   concat(
    concat( Fi_head.CompanyCode, Fi_head.AccountingDocument)
     , _Tax_Group.tax_group ), ItemTax.TaxCode ) as Object,
     Fi_head.CompanyCode
}
