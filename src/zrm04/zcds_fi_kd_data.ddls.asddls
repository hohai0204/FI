@AbapCatalog.sqlViewName: 'ZC_FITYPEKD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view item Fi.Doc account type K D data'
@Metadata.ignorePropagatedAnnotations: true
define view ZCDS_FI_KD_DATA as select from ZCDS_FI_KD as fi_kd
inner join I_JournalEntryItem as fi_item on fi_kd.CompanyCode = fi_item.CompanyCode 
and fi_kd.FiscalYear = fi_item.FiscalYear and fi_kd.AccountingDocument = fi_item.AccountingDocument
and fi_kd.AccountingDocumentItem = fi_item.AccountingDocumentItem and fi_kd.LedgerGLLineItem = fi_item.LedgerGLLineItem
and  fi_item.SourceLedger = '0L'  and fi_item.Ledger = '0L'
{
    fi_item.CompanyCode ,
    fi_item.FiscalYear,
    fi_item.AccountingDocument,
    fi_item.AccountingDocumentItem,
    fi_item.LedgerGLLineItem,
    fi_item.FinancialAccountType,
    fi_item.DocumentItemText,
    fi_item.AssignmentReference,
    fi_item.GLAccount,
    case when fi_item.Customer is not initial then fi_item.Customer else fi_item.Supplier end as customer
}
