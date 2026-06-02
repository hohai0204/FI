@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view Account'
//@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_ZGL02_ACCOUNT
  as select from    ZI_ZGL02_ACCOUNT as data
  //I_GLAccountLineItemRawData as acdoca
    left outer join ZCDS_COMPANY     as ccode on data.CompanyCode = ccode.CompanyCode
    left outer join ztb_zgl02_pdf_n  as PDF   on data.GLAccount = PDF.object_id
  //composition of target_data_source_name as _association_name
{
  key data.SourceLedger,
  key data.CompanyCode,
  key data.FiscalYear,
  key data.GLAccount,
  key data.period,

      //        acdoca._GLAccountInCompanyCode._Text.GLAccountLongName as GLAccountName,
      data.CompanyCodeCurrency,
      data.SubtotalOpt,

      ccode.tencty_vn as CompanyCodeName,
      ccode.diachi_vn as Address,
      ccode.mst       as MST,
      @EndUserText: { quickInfo: 'Attachment' }
      @Semantics: {
          largeObject.acceptableMimeTypes: [ 'image/png', 'image/jpeg', 'application/pdf' ],
          largeObject.contentDispositionPreference: #ATTACHMENT,
          largeObject.fileName: 'FileName',
          largeObject.mimeType: 'MimeType'
      }
      PDF.attachment,
      PDF.filename,
      @Semantics.mimeType: true
      PDF.mimetype,
      @Semantics.user.createdBy: true
      PDF.created_by,
      @Semantics.systemDateTime.createdAt: true
      PDF.created_at,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      PDF.local_last_changed_at,
      @Semantics.systemDateTime.lastChangedAt: true
      PDF.last_changed_at

}
