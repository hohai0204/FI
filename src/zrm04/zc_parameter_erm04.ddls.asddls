@EndUserText.label: 'Parameter for Phiếu Thu'
define abstract entity ZC_PARAMETER_ERM04 
{
 @UI.facet: [{label: 'Giám đốc'}]
  director   : zde_director;
   @UI.facet: [{label: 'Kế toán trưởng'}]
  accountant : zde_accountant;
   @UI.facet: [{label: 'Người nộp tiền'}]
  payer      : zde_payer;
   @UI.facet: [{label: 'Người lập phiếu'}]
  preparer   : zde_preparer;
   @UI.facet: [{label: 'Thủ quỹ'}]
  treasurer  : zde_treasure;
  
}
