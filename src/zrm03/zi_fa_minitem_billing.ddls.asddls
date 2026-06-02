@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Item FI Doc Min with Billing'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_MINITEM_BILLING as select from I_OperationalAcctgDocItem as FI_item
inner join ZI_FA_MINITEM_FIDOCBILLING as ItemMin on FI_item.AccountingDocument = ItemMin.AccountingDocument and FI_item.AccountingDocumentItem = ItemMin.Item
inner join I_BillingDocumentItem as Bill_Item on FI_item.OriginalReferenceDocument = Bill_Item.BillingDocument 
{
    FI_item.AccountingDocument,
    FI_item.CompanyCode,
    FI_item.FiscalYear,
    ItemMin.Item,
    min( Bill_Item.BillingDocumentItem ) as Billitem
}
where FI_item.OriginalReferenceDocument is not initial
group by FI_item.AccountingDocument,  ItemMin.Item,     FI_item.CompanyCode,
    FI_item.FiscalYear
