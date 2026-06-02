@AbapCatalog.sqlViewName: 'ZC_FI_LINEKD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view item Fi.Doc account type K D'
@Metadata.ignorePropagatedAnnotations: true
define view ZCDS_FI_KD as select from   I_OperationalAcctgDocItem     as fi_item      
         inner join   I_JournalEntry      on         I_JournalEntry.AccountingDocument =   fi_item.AccountingDocument    
         and   I_JournalEntry.CompanyCode =   fi_item.CompanyCode and   I_JournalEntry.FiscalYear =   fi_item.FiscalYear   
         inner join I_JournalEntryItem as item_cus on fi_item.AccountingDocument = item_cus.AccountingDocument
and fi_item.AccountingDocumentItem = item_cus.AccountingDocumentItem and fi_item.FiscalYear = item_cus.FiscalYear
and fi_item.CompanyCode = item_cus.CompanyCode and item_cus.SourceLedger = '0L' 
                           
{
fi_item.CompanyCode,
fi_item.AccountingDocument,
fi_item.FiscalYear,
fi_item.FinancialAccountType,
min(fi_item.AccountingDocumentItem) as AccountingDocumentItem,
min(item_cus.LedgerGLLineItem) as LedgerGLLineItem
}
where ( fi_item.FinancialAccountType = 'K'
 or  fi_item.FinancialAccountType  = 'D' )
// and I_JournalEntry.AccountingDocumentType = 'DR'
//  or      I_JournalEntry.AccountingDocumentType = 'KR'
 group by    fi_item.CompanyCode,
fi_item.AccountingDocument,
fi_item.FiscalYear,
fi_item.FinancialAccountType
