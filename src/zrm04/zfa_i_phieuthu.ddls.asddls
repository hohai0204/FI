@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity Phiếu Thu'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//define view entity ZFA_I_PHIEUTHU as select from I_JournalEntry
//{
//    I_JournalEntry.CompanyCode,
//    I_JournalEntry.AccountingDocument,
//    I_JournalEntry.FiscalYear,
//    I_JournalEntry.PostingDate
//}


define view entity ZFA_I_PHIEUTHU
  as select from    I_JournalEntry
  //
  //association [1] to ZFA_I_CUSTOM_PHIEUTHU as  _Custom on I_JournalEntry.AccountingDocument = _Custom.AcountingDocument
    left outer join zi_view_diachi_item      as diachi      on  I_JournalEntry.AccountingDocument = diachi.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = diachi.CompanyCode
    left outer join ZFA_CDS_GLACC_THUCHI     as GL_acc_S    on  I_JournalEntry.AccountingDocument = GL_acc_S.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = GL_acc_S.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = GL_acc_S.FiscalYear
                                                            and GL_acc_S.DebitCreditCode          = 'S'
    left outer join ZFA_CDS_GLACC_THUCHI     as GL_acc_H    on  I_JournalEntry.AccountingDocument = GL_acc_H.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = GL_acc_H.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = GL_acc_H.FiscalYear
                                                            and GL_acc_H.DebitCreditCode          = 'H'
    left outer join ZFA_CDS_ACC_111_MIN      as acc_111_S   on  I_JournalEntry.AccountingDocument = acc_111_S.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = acc_111_S.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = acc_111_S.FiscalYear
                                                            and acc_111_S.DebitCreditCode         = 'S'
    left outer join ZFA_CDS_ACC_111_MIN      as acc_111_H   on  I_JournalEntry.AccountingDocument = acc_111_H.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = acc_111_H.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = acc_111_H.FiscalYear
                                                            and acc_111_H.DebitCreditCode         = 'H'
    left outer join ZFA_CDS_ACC_111          as acc_111_S_a on  I_JournalEntry.AccountingDocument = acc_111_S_a.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = acc_111_S_a.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = acc_111_S_a.FiscalYear
                                                            and acc_111_S_a.DebitCreditCode       = 'S'
    left outer join ZFA_CDS_ACC_111          as acc_111_H_a on  I_JournalEntry.AccountingDocument = acc_111_H_a.AccountingDocument
                                                            and I_JournalEntry.CompanyCode        = acc_111_H_a.CompanyCode
                                                            and I_JournalEntry.FiscalYear         = acc_111_H_a.FiscalYear
                                                            and acc_111_H_a.DebitCreditCode       = 'H'
    left outer join ZCDS_FI_KD_DATA          as item_KD     on  item_KD.CompanyCode               = I_JournalEntry.CompanyCode
                                                            and I_JournalEntry.AccountingDocument = item_KD.AccountingDocument
                                                            and I_JournalEntry.FiscalYear         = item_KD.FiscalYear
    left outer join ZCDS_BP_PROFILE          as Customer    on item_KD.customer = Customer.BusinessPartner
    left outer join I_OneTimeAccountCustomer as OTA_SUP     on  OTA_SUP.AccountingDocument     = item_KD.AccountingDocument
                                                            and OTA_SUP.CompanyCode            = item_KD.CompanyCode
                                                            and OTA_SUP.FiscalYear             = item_KD.FiscalYear
                                                            and OTA_SUP.AccountingDocumentItem = item_KD.AccountingDocumentItem
    left outer join ztb_fi_pdf_draf          as pdf         on  I_JournalEntry.CompanyCode        = substring(
      pdf.object_id, 1, 4
    )
                                                            and I_JournalEntry.AccountingDocument = substring(
      pdf.object_id, 9, 10
    )
                                                            and I_JournalEntry.FiscalYear         = substring(
      pdf.object_id, 5, 4
    )
                                                            and pdf.report_id                     = 'ZFI_RM04'
{
  key concat( concat(I_JournalEntry.CompanyCode,I_JournalEntry .FiscalYear ), I_JournalEntry .AccountingDocument ) as Object,
      I_JournalEntry.CompanyCode,
      I_JournalEntry .AccountingDocument,
      I_JournalEntry .FiscalYear,
      I_JournalEntry.PostingDate,
      I_JournalEntry.DocumentDate,
      I_JournalEntry.AccountingDocCreatedByUser                                                                    as CreateUser,
      GL_acc_S.GLAccount                                                                                           as Debit,
      GL_acc_H.GLAccount                                                                                           as credit,
      item_KD.customer,
      case
      when I_JournalEntry.AccountingDocumentHeaderText is not initial then I_JournalEntry.AccountingDocumentHeaderText
      when item_KD.customer is not initial then
      case when Customer.IsOneTimeAccount is not initial then
      case when OTA_SUP.AccountingDocument is not initial then
          concat_with_space( OTA_SUP.BusinessPartnerName1,
          concat_with_space( OTA_SUP.BusinessPartnerName2,
          concat_with_space( OTA_SUP.BusinessPartnerName3, OTA_SUP.BusinessPartnerName4, 1), 1) ,1 )
          else Customer.name end
           else
           case when Customer.BP_cate = '1' then Customer.name
                else Customer.name  end end
           else  I_JournalEntry.AccountingDocumentHeaderText end                                                   as CustomerName,

      case  when diachi.YY1_DiaChi1_COB is not initial then diachi.YY1_DiaChi1_COB
       when Customer.IsOneTimeAccount is not initial and OTA_SUP.AccountingDocument is not initial then
          concat_with_space( OTA_SUP.StreetAddressName, OTA_SUP.CityName, 1)
           else
      Customer.Adress12345      end                                                                                as CustomerAdress,


      case when acc_111_S.DocumentItemText is not initial then acc_111_S.DocumentItemText
      when acc_111_H.DocumentItemText is not initial then acc_111_H.DocumentItemText
      else  I_JournalEntry.AccountingDocumentHeaderText
       end                                                                                                         as Reason,
      @Semantics.amount.currencyCode: 'curency'
      acc_111_S_a.amount                                                                                           as AmountDebit,
      @Semantics.amount.currencyCode: 'curency'
      acc_111_H_a.amount                                                                                           as Amountcredit,
      acc_111_S.TransactionCurrency                                                                                as curency,
      I_JournalEntry.DocumentReferenceID,
      case when acc_111_S.AssignmentReference is not initial then acc_111_S.AssignmentReference
      else acc_111_H.AssignmentReference end                                                                       as Assignment,
      I_JournalEntry.AbsoluteExchangeRate                                                                          as ExchangeRate,
      @Semantics.amount.currencyCode: 'curency_vnd'
      acc_111_S_a.amount_VND                                                                                       as AmountDebit_VND,
      @Semantics.amount.currencyCode: 'curency_vnd'
      acc_111_H_a.amount_VND                                                                                       as Amountcredit_VND,
      acc_111_S.CompanyCodeCurrency                                                                                as curency_vnd,
      pdf.attachment,
      pdf.filename,
      pdf.mimetype
}

where
  I_JournalEntry.AccountingDocumentType = 'CR'
