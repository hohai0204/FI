@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Phiếu kế toán'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZGL07
  as select from    I_JournalEntry                as header
    left outer join ZCDS_COMPANY                  as company  on company.CompanyCode = header.CompanyCode
    left outer join ztb_fi_pdf_draf               as pdf      on  pdf.object_id = concat(
      header.AccountingDocument, header.CompanyCode
    )
                                                              and pdf.report_id = 'ZFA_ZGL07'
//    left outer join I_JournalEntryItemOneTimeData as OTA_cust on OTA_cust.AccountingDocument = header.AccountingDocument
{
  key header.CompanyCode,
  key header.FiscalYear,
  key header.AccountingDocument                                as JournalEntry,
      header.AccountingDocumentType                            as JournalEntryType,
      header.PostingDate,
      header.DocumentDate                                      as EntryDate,
      header.AccountingDocCreatedByUser                        as UserName,
      concat( header.AccountingDocument , header.CompanyCode ) as attachment_id,
      company.tencty_vn                                        as TenCongTy,
      company.diachi_vn23                                        as DiaChiCongTy,
      company.mst                                              as MaSoThue,
      header.TransactionCurrency                               as DonViTinh,
      header.AccountingDocumentHeaderText                      as DocumentHeaderText,
//      OTA_cust.BusinessPartnerName1,
      //      header.
      pdf.object_id,
      pdf.report_id,
      pdf.attachment,
      pdf.filename,
      pdf.mimetype



}
