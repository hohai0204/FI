@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Product Document for FI ZRM03'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_ITEMBILLING_FIDOC as select from I_OperationalAcctgDocItem as FI_item
inner join ZI_FA_MINITEM_BILLING  as MinBill on MinBill.AccountingDocument = FI_item.AccountingDocument  and MinBill.FiscalYear = FI_item.FiscalYear and MinBill.CompanyCode = FI_item.CompanyCode
inner join I_BillingDocumentItem as Bill_Item on FI_item.OriginalReferenceDocument = Bill_Item.BillingDocument and MinBill.Billitem = Bill_Item.BillingDocumentItem
{
    FI_item.AccountingDocument,
    FI_item.FiscalYear,
    FI_item.CompanyCode,
    Bill_Item.BillingDocumentItemText as Text
}
group by  FI_item.AccountingDocument,
    FI_item.FiscalYear,
    FI_item.CompanyCode,
    Bill_Item.BillingDocumentItemText
