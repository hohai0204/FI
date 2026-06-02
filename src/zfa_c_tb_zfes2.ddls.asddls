@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZFA_C_TB_ZFES2
  provider contract transactional_query
  as projection on ZFA_R_TB_ZFES2
{
  key Uuid,
  FsVersion,
  @ObjectModel.text.element: [ 'HierarchyNodeText' ]
  FinancialStatement,
  Node_Text,
  Bold,
  Italic,
  ThuyetMinh,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _text.HierarchyNodeText as HierarchyNodeText
  
}
