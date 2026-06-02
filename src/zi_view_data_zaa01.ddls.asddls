@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View data ZAA01'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_View_data_zaa01   with parameters
    p_year         : abap.char(4),
    p_companycode  : abap.char(4),
    p_ledger       : abap.char(2),
    p_statementver : abap.char(4),
    p_period       : abap.char(2)
  as select from    I_GLAccountLineItemRawData   as acdoca
    left outer join I_FinancialStatementHierNode as head_node on head_node.HierarchyNodeVal = acdoca.GLAccount
{
  key head_node.ParentNode,
      acdoca.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      sum( acdoca.AmountInCompanyCodeCurrency ) as amount
}
where
      acdoca.SourceLedger                   = $parameters.p_ledger
  and acdoca.FiscalYear                     = $parameters.p_year
  and head_node.FinancialStatementHierarchy = $parameters.p_statementver
  and acdoca.CompanyCode                    = $parameters.p_companycode
  and acdoca.FiscalYearPeriod <= concat( $parameters.p_year,  concat( '0' , $parameters.p_period ) )
group by
  head_node.ParentNode,
  acdoca.CompanyCodeCurrency
