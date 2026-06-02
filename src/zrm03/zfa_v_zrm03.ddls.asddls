@AbapCatalog.sqlViewName: 'ZV_ZRM03'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View ZRM03'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_ZRM03
  as select from ZFA_I_ZRM03
{
  key concat(
    concat(
     concat(  coalesce(CompanyCode, ''),
        coalesce(AccountingDocument, '')
      ),
      coalesce(tax_group, '')
    ),
    coalesce(TaxCode, '')
  )                                  as Object,
      CompanyCode,
      tencty_vn,
      diachi_vn,
      MST_Company,
      AccountingDocument,
      PostingDate,
      Period,
      customer,
      CustomerName,
      CustomerAdress,
      MST_Customer,
      DocumentReferenceID,
      DocumentDate,
      IsReversed,
      OriginalReferenceDocument,
      DGDV,
      taxcode_desc,
      tax_group,
      AssignmentReference,
      itemtext,
      acc_item,
      Pattern,
      Invoice_Num,
      Quantity,
      BaseUnit,
      GLAccount,
      TaxCode,
      amount,
      CompanyCodeCurrency,
      Taxamount,
      TaxRate,
      Price,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03_V'
      cast( 0 as abap.dec( 10, 2 ) ) as STT,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ZRM03_V'
      cast( '' as abap.char( 100 ) ) as ztesst
}
