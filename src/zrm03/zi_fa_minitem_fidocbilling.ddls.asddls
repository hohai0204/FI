@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Item FI Doc Min with Billing'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_MINITEM_FIDOCBILLING as select from I_OperationalAcctgDocItem as FI_item
inner join I_BillingDocumentItem as Bill_Item on FI_item.OriginalReferenceDocument = Bill_Item.BillingDocument 
{
    FI_item.AccountingDocument,
    min( FI_item.AccountingDocumentItem ) as Item
}
where FI_item.OriginalReferenceDocument is not initial
group by FI_item.AccountingDocument
