@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity  Phiếu Thu'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_R_PHIEUTHU as select from ZFA_I_PHIEUTHU as main
left outer join ZI_FIDOC_NOTOBJECT_ADDRESS as Addresnoobject on Addresnoobject.AccountingDocument = main.AccountingDocument 
and Addresnoobject.FiscalYear = main.FiscalYear  and Addresnoobject.CompanyCode = main.CompanyCode
association [0..1] to ZCDS_COMPANY as _Company on $projection.CompanyCode = _Company.CompanyCode

{
 key ( concat(  main.CompanyCode, concat(  main.FiscalYear, main.AccountingDocument ) ) ) as Object ,
  main.AccountingDocument,
  main.CompanyCode, 
  main.FiscalYear,
  main.PostingDate,
  main.DocumentDate,
  main.CreateUser,
  _Company.tencty_vn,
  _Company.diachi_vn23 as diachi_vn,
  _Company.mst,
  main.Debit,
  main.credit,
  main.CustomerName,
   case when main.CustomerAdress is not initial then main.CustomerAdress else Addresnoobject.YY1_DiaChi1_COB end as CustomerAdress,
// main.CustomerAdress,
  main.Reason,
  @Semantics.amount.currencyCode: 'curency'
  main.AmountDebit,
  main.DocumentReferenceID,
  main.Assignment,
  main.ExchangeRate,
  main.curency,
   @Semantics.amount.currencyCode: 'curency_vnd'
  main.AmountDebit_VND,
  main.curency_vnd,
  main.attachment,
  main.filename,
  main.mimetype

}
