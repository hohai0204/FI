@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Quantity in FI Doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_FI_QUANTITY_PM03 as select from I_OperationalAcctgDocItem as FI_item
inner join ZI_FA_MINITEM_FI_Quantity as minitem on FI_item.AccountingDocument = minitem.AccountingDocument 
and FI_item.CompanyCode = minitem.CompanyCode
and FI_item.AccountingDocumentItem = minitem.Item
left outer join ZI_SUM_QUAN_FI_RE  as PO_sum on PO_sum.AccountingDocument = FI_item.AccountingDocument
and FI_item.CompanyCode = PO_sum.CompanyCode
and FI_item.FiscalYear = PO_sum.FiscalYear
left outer join I_PurchaseOrderItemAPI01  as PO_item on PO_item.PurchaseOrder = PO_sum.PurchaseOrder and PO_item.PurchaseOrderItem = PO_sum.PurchaseOrderItem

{
    FI_item.AccountingDocument,
    FI_item.CompanyCode,
     FI_item.FiscalYear,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    case when FI_item.AccountingDocumentType = 'RE' then cast( PO_sum.Quantity as abap.quan( 20, 3 ) )
    else FI_item.Quantity end as Quantity,
    case when FI_item.AccountingDocumentType = 'RE' then PO_item.PurchaseOrderQuantityUnit
    else FI_item.BaseUnit end as Unit,
        case when FI_item.AccountingDocumentType = 'RE' then PO_item.PurchaseOrderItemText
  end as shorttext
}
