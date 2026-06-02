@AbapCatalog.sqlViewName: 'ZDCS_ACC_111'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for line account 111'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_CDS_ACC_111 as select from I_JournalEntry as header
 inner join I_OperationalAcctgDocItem     as fi_item on  header.AccountingDocument =   fi_item.AccountingDocument
             and   header.CompanyCode =   fi_item.CompanyCode and   header.FiscalYear =   fi_item.FiscalYear
{
   
                fi_item.CompanyCode,
                fi_item.AccountingDocument,
                fi_item.FiscalYear,
                fi_item.DebitCreditCode,
                   min( fi_item.AccountingDocumentItem ) as AccountingDocumentItem,
                sum( fi_item.AmountInTransactionCurrency ) as amount,
                 sum( fi_item.AmountInCompanyCodeCurrency ) as amount_VND
    
            
} where fi_item.GLAccount like '111%'
 group by  fi_item.CompanyCode,
                fi_item.AccountingDocument,
                fi_item.FiscalYear,
                fi_item.DebitCreditCode
