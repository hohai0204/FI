@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view Phiếu kế toán'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFA_R_ZGL07
  as select from ZFA_I_ZGL07
  //composition of target_data_source_name as _association_name
{
  key CompanyCode,
  key FiscalYear,
  key JournalEntry,
      JournalEntryType,
      PostingDate,
      EntryDate,
      UserName,
      TenCongTy,
      DiaChiCongTy,
      MaSoThue,
      DonViTinh,
      object_id,
      report_id,
      attachment,
      filename,
      mimetype,
      DocumentHeaderText
      //    _association_name // Make association public
}
