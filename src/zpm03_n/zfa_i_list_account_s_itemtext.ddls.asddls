@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity list FI doc accounttype S Item Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_LIST_ACCOUNT_S_ITEMTEXT as select from 
 I_OperationalAcctgDocItem     as fi_item 
 left outer join ZFA_I_KD_PM03 as listKD on fi_item.AccountingDocument = listKD.AccountingDocument
{
   fi_item.AccountingDocument,
      fi_item.CompanyCode,
   fi_item.FiscalYear,
    min( fi_item.AccountingDocumentItem ) as Item
}
where fi_item.DocumentItemText is not initial
group by fi_item.AccountingDocument,  fi_item.CompanyCode,
   fi_item.FiscalYear
