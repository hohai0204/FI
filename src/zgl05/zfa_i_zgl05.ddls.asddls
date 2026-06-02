@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity ZGL05'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #D,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZFA_I_ZGL05
  as select from  I_GLAccountLineItem as gl
    inner join I_JournalEntry as je
      on je.AccountingDocument = gl.AccountingDocument
  and je.CompanyCode =  gl.CompanyCode 
 and je.FiscalYear =  gl.FiscalYear
    association [0..1] to I_CustomerCompany            as _CustomerCompany
      on  $projection.CompanyCode       = _CustomerCompany.CompanyCode
      and $projection.OffsettingAccount = _CustomerCompany.Customer

    association [0..1] to I_SupplierCompany            as _SupplierCompany
      on  $projection.CompanyCode       = _SupplierCompany.CompanyCode
      and $projection.OffsettingAccount = _SupplierCompany.Supplier

    association [0..1] to I_GlAccountTextInCompanycode as _GlAccountText
      on  $projection.CompanyCode = _GlAccountText.CompanyCode
      and $projection.GLAccount   = _GlAccountText.GLAccount
      and _GlAccountText.Language = $session.system_language

{
  key gl.SourceLedger,
  key gl.CompanyCode,
  key gl.FiscalYear,
  key gl.Ledger,
  key gl.AccountingDocument,
  key gl.LedgerGLLineItem,

      gl.PostingDate,
      gl.DocumentDate,

      case when gl.DocumentItemText is not initial
           then gl.DocumentItemText
           else je.AccountingDocumentHeaderText
      end as DocumentItemText,

      gl.OffsettingAccount,
      gl.OffsettingAccountType,
      gl._OffsettingAccountText.OffsettingAccountName,

      coalesce(_CustomerCompany.ReconciliationAccount,
               _SupplierCompany.ReconciliationAccount) as ReconciliationAccount,

      gl.GLAccount,
      gl.GLAccountType,
      _GlAccountText.GLAccountLongName,

      gl.IsReversed,
      gl.IsReversal,
      gl.ReversalReferenceDocument,
      gl.ReversalTransactionSubitem,

      case when gl.IsReversed = 'X' or gl.IsReversal = 'X' then ''
           else 'X'
      end as IsNotReversal,

      'X' as IsIncludeReversal,

      gl.DebitCreditCode,
      je.AbsoluteExchangeRate,
      gl.TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gl.DebitAmountInTransCrcy,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gl.CreditAmountInTransCrcy,

      gl.PostingKey,
      gl.FiscalPeriod,
      gl.FiscalYearPeriod,
      gl.FiscalYearVariant,
      gl.ProfitCenter,
      gl.Segment,
      gl.BalanceTransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      gl.AmountInTransactionCurrency,

      gl.AssignmentReference,
      gl.AccountingDocumentType,
      gl.AccountingDocumentItem,

      _GlAccountText.GLAccountName as GLAccountText,
      gl._AccountingDocumentTypeText[Language = $session.system_language].AccountingDocumentTypeName as AccDocTypeText,
      cast( 'VND' as abap.cuky(5) ) as cukyVND,
       gl.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'cukyVND'
      case when gl.TransactionCurrency = 'VND' and gl.DebitCreditCode = 'S'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.DebitAmountInTransCrcy) * -1
                       else abs(gl.DebitAmountInTransCrcy) end )
           when gl.TransactionCurrency <> 'VND' and gl.DebitCreditCode = 'S'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.DebitAmountInCoCodeCrcy) * -1
                       else abs(gl.DebitAmountInCoCodeCrcy) end )
           else cast( 0 as abap.curr( 23, 2 ))
      end as ThuVND,

      @Semantics.amount.currencyCode: 'cukyVND'
      case when gl.TransactionCurrency = 'VND' and gl.DebitCreditCode = 'H'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.CreditAmountInTransCrcy) * -1
                       else abs(gl.CreditAmountInTransCrcy) end )
           when gl.TransactionCurrency <> 'VND' and gl.DebitCreditCode = 'H'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.CreditAmountInCoCodeCrcy) * -1
                       else abs(gl.CreditAmountInCoCodeCrcy) end )
           else cast( 0 as abap.curr( 23, 2 ))
      end as ChiVND,
    
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when gl.TransactionCurrency <> 'VND' and gl.DebitCreditCode = 'S'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.DebitAmountInTransCrcy) * -1
                       else abs(gl.DebitAmountInTransCrcy) end )
           else cast( 0 as abap.curr( 23, 2 ))
      end as ThuNgoaiTe,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when gl.TransactionCurrency <> 'VND' and gl.DebitCreditCode = 'H'
           then ( case when gl.IsReversal = 'X'
                       then abs(gl.CreditAmountInTransCrcy) * -1
                       else abs(gl.CreditAmountInTransCrcy) end )
           else cast( 0 as abap.curr( 23, 2 ))
      end as ChiNgoaiTe,

      _CustomerCompany,
      _SupplierCompany
}
where
       gl.SourceLedger = '0L'
  and  gl.Ledger       = '0L'
  and ( gl.GLAccount like '111%' )

