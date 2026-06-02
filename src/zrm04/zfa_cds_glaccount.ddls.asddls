@AbapCatalog.sqlViewName: 'ZCDS_GLACCOUNT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View for GL Account  line'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_CDS_GLACCOUNT as select from I_JournalEntry as header

left outer join I_OperationalAcctgDocItem     as fi_item on  header.AccountingDocument =   fi_item.AccountingDocument
            and   header.CompanyCode =   fi_item.CompanyCode and   header.FiscalYear =   fi_item.FiscalYear

{
    header.CompanyCode,
      header.FiscalYear,
      header.AccountingDocument,
    fi_item.DebitCreditCode,
    fi_item.GLAccount,
     sum( fi_item.AmountInTransactionCurrency ) as amount,
                 sum( fi_item.AmountInCompanyCodeCurrency ) as amount_VND
}
            where  ( fi_item.DebitCreditCode = 'S' or fi_item.DebitCreditCode = 'H' ) 
            and fi_item.GLAccount not like '133%'
            group by     header.CompanyCode,
      header.FiscalYear,
      header.AccountingDocument,
    fi_item.DebitCreditCode,
    fi_item.GLAccount
           
           
