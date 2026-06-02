@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View HierarchyNode VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_HierarchyNodeVH as select from I_GLAccountHierarchyNodeT
{
    key GLAccountHierarchy,
    key HierarchyNode,
    HierarchyNodeShortText     
}
where Language = $session.system_language
