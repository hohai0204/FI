@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Quantity in FI Doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_MINITEM_FI_Quantity as select from I_OperationalAcctgDocItem as FI_item
{
    FI_item.AccountingDocument,
   FI_item.CompanyCode,
    min( FI_item.AccountingDocumentItem ) as Item
}
where 
( FI_item.Quantity is not initial and FI_item.AccountingDocumentType <> 'RE' ) 
or 
( FI_item.AccountingDocumentType = 'RE'  )
group by FI_item.AccountingDocument, FI_item.CompanyCode
