@EndUserText.label: 'Custom Entity Tax Type'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_SETDATA_TAXTYPE'
    }
}
define custom entity ZFI_I_TAXTYPE_VIEW
{
  key tax_type : zde_taxtype;
  TAXTYPE_DESC : text100;
  
}
