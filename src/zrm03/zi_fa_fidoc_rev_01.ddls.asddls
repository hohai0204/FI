@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for FI Doc revered cùng kỳ'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FA_FIDOC_REV_01 as select from I_JournalEntry as Fidoc
left outer join I_JournalEntry as REvedDoc on REvedDoc.AccountingDocument = Fidoc.ReverseDocument  
and Fidoc.CompanyCode = REvedDoc.CompanyCode
and Fidoc.AccountingDocumentType <> 'RE' //and REvedDoc.FiscalPeriod = Fidoc.FiscalPeriod
left outer join I_JournalEntry as REvedDocNo on REvedDocNo.ReversalReferenceDocument = substring( Fidoc.OriginalReferenceDocument,1,10 ) //and REvedDocNo.FiscalPeriod = Fidoc.FiscalPeriod 
and REvedDocNo.AccountingDocument <> Fidoc.AccountingDocument
and REvedDocNo.CompanyCode = Fidoc.CompanyCode
 and REvedDocNo.IsReversal is not initial
left outer join I_SupplierInvoiceAPI01 as Invoice on Invoice.SupplierInvoice = REvedDocNo.ReversalReferenceDocument
left outer join I_JournalEntry as REvedDocRE on REvedDocRE.ReversalReferenceDocument = substring( Fidoc.OriginalReferenceDocument,1,10 ) 
 and Fidoc.AccountingDocumentType = 'RE' //and REvedDocRE.FiscalPeriod = Fidoc.FiscalPeriod
{
    Fidoc.AccountingDocument,
    Fidoc.CompanyCode,
    Fidoc.FiscalYear,
    case when REvedDoc.AccountingDocument is not initial then REvedDoc.AccountingDocument
         when REvedDocNo.AccountingDocument is not initial then REvedDocNo.AccountingDocument
         when REvedDocRE.AccountingDocument is not initial then REvedDocRE.AccountingDocument end as ReverseDocument,
         
         case when REvedDoc.AccountingDocument is not initial then REvedDoc.FiscalYear
         when REvedDocNo.AccountingDocument is not initial then REvedDocNo.FiscalYear
         when REvedDocRE.AccountingDocument is not initial then REvedDocRE.FiscalYear end as ReverseFiscalYear,
           case when REvedDoc.AccountingDocument is not initial then REvedDoc.CompanyCode
         when REvedDocNo.AccountingDocument is not initial then REvedDocNo.CompanyCode
         when REvedDocRE.AccountingDocument is not initial then REvedDocRE.CompanyCode end as ReverseCompanyCode,

             
    case when REvedDoc.AccountingDocument is not initial then Fidoc.IsReversed
         when REvedDocNo.AccountingDocument is not initial then Fidoc.IsReversed
         when REvedDocRE.AccountingDocument is not initial then Fidoc.IsReversed
         else ''
         end as Isrevered,
         case when REvedDocRE.FiscalPeriod = Fidoc.FiscalPeriod then 'X' 
          when REvedDocNo.FiscalPeriod = Fidoc.FiscalPeriod then 'X' 
           when REvedDoc.FiscalPeriod = Fidoc.FiscalPeriod then 'X' 
           else '' end as PeriodRV
}            

where Fidoc.IsReversed is not initial 
and (  REvedDoc.AccountingDocument is not initial or  
( REvedDocNo.AccountingDocument is not initial and Invoice.SupplierInvoice is not initial ) or  
REvedDocRE.AccountingDocument is not initial )

