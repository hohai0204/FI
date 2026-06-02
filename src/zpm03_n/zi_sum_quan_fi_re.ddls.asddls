@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Quantity FI Doc type RE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SUM_QUAN_FI_RE as select from 
I_JournalEntry as Fidoc
inner join I_SuplrInvcItemPurOrdRefAPI01 as poInvoice on poInvoice.SupplierInvoice = substring(Fidoc.OriginalReferenceDocument,1,10) and 
poInvoice.FiscalYear = substring(Fidoc.OriginalReferenceDocument,11,4) 
inner join I_PurchaseOrderItemAPI01  as PO_itemline on PO_itemline.PurchaseOrder = poInvoice.PurchaseOrder  and poInvoice.PurchaseOrderItem = PO_itemline.PurchaseOrderItem
{
    Fidoc.AccountingDocument,
    Fidoc.CompanyCode,
     Fidoc.FiscalYear,
     min(PO_itemline.PurchaseOrder) as PurchaseOrder,
     min(PO_itemline.PurchaseOrderItem) as PurchaseOrderItem,
 cast( sum( poInvoice.QuantityInPurchaseOrderUnit ) as abap.dec(20,3) ) as Quantity
 
}
group by  Fidoc.AccountingDocument,Fidoc.CompanyCode,
     Fidoc.FiscalYear
