@AbapCatalog.sqlViewName: 'ZCDS_ZCC_111MIN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View account 111 line item min'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_CDS_ACC_111_MIN as select from ZFA_CDS_ACC_111 as header
 inner join I_OperationalAcctgDocItem     as fi_item on  header.AccountingDocument =   fi_item.AccountingDocument
             and   header.CompanyCode =   fi_item.CompanyCode and   header.FiscalYear =   fi_item.FiscalYear and  header.AccountingDocumentItem =   fi_item.AccountingDocumentItem
{
                fi_item.CompanyCode,
                fi_item.AccountingDocument,
                fi_item.FiscalYear,
                fi_item.GLAccount,
                fi_item.DebitCreditCode,
                fi_item.DocumentItemText,
                fi_item.AccountingDocumentItem,
                fi_item.TransactionCurrency,
                fi_item.AssignmentReference,
                fi_item.CompanyCodeCurrency
}
