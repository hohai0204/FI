@AbapCatalog.sqlViewName: 'ZFA_V_TAXITEMFI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View Tax Item FA'
@Metadata.ignorePropagatedAnnotations: true
define view ZFA_V_TAXITEM as select  from I_JournalEntryItem as base
// left outer join I_OperationalAcctgDocItem as tax
inner join I_JournalEntry on I_JournalEntry.AccountingDocument = base.AccountingDocument 
and I_JournalEntry.FiscalYear = base.FiscalYear
and I_JournalEntry.CompanyCode = base.CompanyCode
inner join I_OperationalAcctgDocItem as tax
  on base.CompanyCode = tax.CompanyCode
  and base.AccountingDocument = tax.AccountingDocument
  and base.TaxCode = tax.TaxCode
   and base.AccountingDocumentItem = tax.AccountingDocumentItem
  and ( tax.AccountingDocumentItemType = 'T' or tax.GLAccount = '1331000001' or tax.GLAccount ='3331000001' )
  left outer join ZI_FA_FIDOC_A_V as FIconvert on FIconvert.AccountingDocument = I_JournalEntry.AccountingDocument 
  and FIconvert.CompanyCode = I_JournalEntry.CompanyCode and FIconvert.FiscalYear = I_JournalEntry.FiscalYear  
{
  key base.CompanyCode,
  key base.AccountingDocument,
  key base.FiscalYear,
  key base.AccountingDocumentItem,
  key base.LedgerGLLineItem,
  base.TaxCode as tAXCODE_AT,
  
  case when FIconvert.AccountingDocument is not initial then replace(base.TaxCode, 'O', 'I')
  else base.TaxCode  end as TaxCode,
  base.DebitCreditCode,
    base.FinancialAccountType,
  substring( base.TaxCode, 1, 1 ) as TaxCodePrefix,
  case when FIconvert.AccountingDocument is not initial then  FIconvert.YY1_CCT2_JEI 
  else
case 
  when tax.GLAccount <> '' then tax.GLAccount
  when base.TaxCode like 'I%'  then '1331000001'
  else '3331000001'
end
end

 as GLAccount,
 case when tax.TaxBaseAmountInCoCodeCrcy is not  initial then tax.TaxBaseAmountInCoCodeCrcy  else base.AmountInCompanyCodeCurrency end as BaseAmount,
  
  tax.TaxBaseAmountInCoCodeCrcy,
  tax.AmountInCompanyCodeCurrency as TaxAmount,
  base.CompanyCodeCurrency,
  division(
  cast( tax.AmountInCompanyCodeCurrency as abap.dec(16, 3) ),
   cast( tax.TaxBaseAmountInCoCodeCrcy  as abap.dec(16, 3) ),
  3
) * 100  as TaxRate,
 
cast( 
  cast( ( case when tax.AccountingDocumentItemType = 'T' then base.AmountInTransactionCurrency else tax.TaxBaseAmountInTransCrcy end ) as abap.dec(16, 3)) *
division(
    cast( tax.AmountInTransactionCurrency as abap.dec(16, 3)),
    cast( tax.TaxBaseAmountInTransCrcy  as abap.dec(16, 3)),
    3
  )
as abap.curr( 17, 2 )) as Taxamountline_NT,
//cast( 
//  cast( ( case when tax.AccountingDocumentItemType = 'T' then base.AmountInCompanyCodeCurrency else tax.TaxBaseAmountInCoCodeCrcy end ) as abap.dec(16, 3)) *
//  division(
//    cast( tax.AmountInCompanyCodeCurrency as abap.dec(16, 3)),
//    cast( tax.TaxBaseAmountInCoCodeCrcy  as abap.dec(16, 3)),
//    3
//  )
//as abap.curr( 17, 3 )  ) as Taxamountline,

case when base.TransactionCurrency <> 'VND' then 
cast( 
 cast( 
  cast( ( case when tax.AccountingDocumentItemType = 'T' then base.AmountInTransactionCurrency else tax.TaxBaseAmountInTransCrcy end ) as abap.dec(16, 3)) *
division(
    cast( tax.AmountInTransactionCurrency as abap.dec(16, 3)),
    cast( tax.TaxBaseAmountInTransCrcy  as abap.dec(16, 3)),
    3
  )
as abap.curr( 17, 2 )) * cast( I_JournalEntry.ExchangeRate * 10 as abap.curr( 8, 3 ) ) 

as abap.curr( 17, 2 )  ) 
else 

cast( 
round( 
  cast( ( case when tax.AccountingDocumentItemType = 'T' then base.AmountInCompanyCodeCurrency else tax.TaxBaseAmountInCoCodeCrcy end ) as abap.dec(16, 3)) *
division(
    cast( tax.AmountInCompanyCodeCurrency as abap.dec(16, 3) ),
   cast( tax.TaxBaseAmountInCoCodeCrcy  as abap.dec(16, 3) ),
  3
  ) ,
        2 )
as abap.curr( 17, 2 )) 

end
as Taxamountline,
cast( I_JournalEntry.ExchangeRate as abap.curr( 8, 3 ) ) as ExchangeRate,

tax.AccountingDocumentItemType,
  tax.TaxBaseAmountInTransCrcy,
  tax.AmountInTransactionCurrency as TAXAMOUNTTRANS,
  tax.TransactionCurrency,
  tax.AccountingDocumentItem as itemtax,
  base.YY1_CCT1_JEI,
  base.YY1_SoHoaDon_1_COB
}
//where tax.GLAccount <> '1331000001' and tax.GLAccount <> '3331000001'
where base.TaxCode is not initial and base.Ledger = '0L' 

union 
select  from I_JournalEntryItem as base
inner join I_JournalEntry on I_JournalEntry.AccountingDocument = base.AccountingDocument  
and I_JournalEntry.FiscalYear = base.FiscalYear
and I_JournalEntry.CompanyCode = base.CompanyCode
left outer join I_OperationalAcctgDocItem as tax
  on base.CompanyCode = tax.CompanyCode
  and base.AccountingDocument = tax.AccountingDocument
  and base.TaxCode = tax.TaxCode
  and base.AccountingDocumentItem = tax.AccountingDocumentItem
  and ( tax.AccountingDocumentItemType = 'T' or tax.GLAccount = '1331000001' or tax.GLAccount ='3331000001' )
{
  key base.CompanyCode,
  key base.AccountingDocument,
  key base.FiscalYear,
  key base.AccountingDocumentItem,
  key base.LedgerGLLineItem,
   base.TaxCode as tAXCODE_AT,
  base.TaxCode,
  base.DebitCreditCode,
  base.FinancialAccountType,
  substring( base.TaxCode, 1, 1 ) as TaxCodePrefix,
  case 
  when tax.GLAccount <> '' then tax.GLAccount
  when base.TaxCode like 'I%'  then '1331000001'
  else '3331000001'
end as GLAccount,
 base.AmountInCompanyCodeCurrency as BaseAmount,
 base.AmountInCompanyCodeCurrency  as TaxBaseAmountInCoCodeCrcy,
  tax.AmountInCompanyCodeCurrency as TaxAmount,
  base.CompanyCodeCurrency,
  division(
  cast( tax.AmountInCompanyCodeCurrency as abap.dec(16, 3) ),
   cast( tax.TaxBaseAmountInCoCodeCrcy  as abap.dec(16, 3) ),
  3
) * 100  as TaxRate,
 
cast( 
  0
as abap.curr( 17, 2 )) as Taxamountline_NT,
 cast( 
 0 as abap.curr( 17, 2 )) as Taxamountline,
cast( I_JournalEntry.ExchangeRate as abap.curr( 8, 3 ) ) as ExchangeRate,

'R' as AccountingDocumentItemType,
  tax.TaxBaseAmountInTransCrcy,
   tax.AmountInTransactionCurrency as TAXAMOUNTTRANS,
  tax.TransactionCurrency,
  tax.AccountingDocumentItem as itemtax,
   base.YY1_CCT1_JEI,
   base.YY1_SoHoaDon_1_COB
}
where  base.TaxCode is not initial  and base.Ledger = '0L'  
and tax.AccountingDocument is null //and base.DebitCreditCode = 'S'

  

