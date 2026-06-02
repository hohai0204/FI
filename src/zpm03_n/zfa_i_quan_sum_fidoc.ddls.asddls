@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity Sum Quantity in FI Doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_QUAN_SUM_FIDOC as 
select from
 I_JournalEntryItem            as fi_item        
    left outer join ZFA_V_MINITEMTAX_LG      as minitem_tax on  fi_item.AccountingDocument = minitem_tax.AccountingDocument
                                                            and fi_item.FiscalYear         = minitem_tax.FiscalYear
                                                            and fi_item.TaxCode            = minitem_tax.TaxCode
    inner join      I_JournalEntryItem            as fi_itemmin         on  minitem_tax.AccountingDocument     = fi_itemmin.AccountingDocument
                                                                     and minitem_tax.CompanyCode            = fi_itemmin.CompanyCode
                                                                     and minitem_tax.FiscalYear             = fi_itemmin.FiscalYear
                                                                     and minitem_tax.TaxCode            = fi_itemmin.TaxCode
                                                                     and fi_itemmin.Ledger                 = '0L'
                                                                     and fi_itemmin.AccountingDocumentItem = minitem_tax.AccountingDocumentItem
                                                                    and fi_itemmin.LedgerGLLineItem       = minitem_tax.LG_Item
                                                                
   
{
    fi_item.AccountingDocument,
    fi_item.FiscalYear,
    fi_item.TaxCode,    
    fi_itemmin.BaseUnit,
     @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    sum(fi_item.Quantity ) as Quantity
}
where   fi_item.Ledger                 = '0L'
and fi_item.Quantity is not initial
group by fi_item.AccountingDocument,
 fi_item.FiscalYear,
    fi_item.TaxCode,
    fi_itemmin.BaseUnit
