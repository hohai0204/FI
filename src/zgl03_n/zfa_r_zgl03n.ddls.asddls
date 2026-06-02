@EndUserText.label: 'Custom Entity ZGL03'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CUS_ZGL03'
@Metadata.allowExtensions: true
define root custom entity ZFA_R_ZGL03N
{
  key companycode   : abap.char(4);
   uuid          : uuid;
      phien_bao_cao : abap.char(4);
      ky_bao_cao    : abap.char(4);
      nam_bao_cao   : abap.char(4);
      Ky_so_sanh    : abap.char(4);
      nam_so_sanh   : abap.char(4);
      Attachment    : zattachment;

}
