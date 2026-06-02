@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZFA_R_TB_ZFES2
  as select from ztb_zfes2
  association to I_GLAccountHierarchyNodeT as _text on  _text.GLAccountHierarchy = $projection.FsVersion
                                                    and _text.HierarchyNode      = $projection.FinancialStatement
                                                    and _text.Language           = $session.system_language
{
  key uuid                  as Uuid,
      fs_version            as FsVersion,
      financial_statement   as FinancialStatement,
      node_text as Node_Text,
      bold                  as Bold,
      italic                as Italic,
      thuyet_minh           as ThuyetMinh,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _text

}
