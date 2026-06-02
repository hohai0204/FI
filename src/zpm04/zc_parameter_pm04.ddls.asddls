@EndUserText.label: 'Parameter for Phiếu Chi'
define abstract entity ZC_PARAMETER_PM04 
{
 @UI.facet: [{label: 'Giám đốc'}]
  director   : zde_director;
  accountant : zde_accountant;
  treasurer  : zde_treasure;
  preparer   : zde_preparer;
  payer      : zde_recived;
  
}
