@EndUserText.label: 'Sổ tổng hợp công nợ phải thu KH'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ZRM02_IMPL'
@Metadata.allowExtensions: true
define root custom entity ZFA_I_ZRM02
{
  key CompanyCode                : abap.char(4);
  key FiscalYear                 : abap.char(4);
  key object_id                  : uuid;
      PostingDate                : abap.dats;
      postingdate_fromto         : abap.char(255);
      BalanceTransactionCurrency : abap.char(3);

      GLAccount                  : abap.char(10);
      FinancialAccountType       : abap.char(1);
      Customer                   : abap.char(10);
      CustomerAccountGroup       : abap.char(4);
      CustomerName               : abap.char(255);

      compName                   : abap.char(255);
      compAdd                    : abap.char(255);
      compMST                    : abap.char(255);

      nguoilap                   : abap.char(255);
      ketoan                     : abap.char(255);
      giamdoc                    : abap.char(255);
      currentdate                : abap.char(30);

      is_clrdoc                  : abap_boolean;


      //      PDF
      @Semantics.largeObject     : { mimeType: 'MimeType',   //case-sensitive
                                     fileName: 'FileName',         //case-sensitive
                                     acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                                     contentDispositionPreference: #INLINE } //#ATTACHMENT
      attachment                 : zattachment;
      mimetype                   : abap.char(128);
      filename                   : abap.char(128);

      //      Excel
      @Semantics.largeObject     : { mimeType: 'mimetype_exc',   //case-sensitive
                               fileName: 'filename_exc',         //case-sensitive
                               acceptableMimeTypes: ['image/png', 'image/jpeg', 'application/pdf' ],
                               contentDispositionPreference: #INLINE } //#ATTACHMENT
      attachment_exc             : zattachment;
      mimetype_exc               : abap.char(128);
      filename_exc               : abap.char(128);

      @ObjectModel.sort.enabled  : false
      @ObjectModel.filter.enabled: false
      _ItemsZRM02                : composition [1..*] of zfa_i_zrm02_lines;

}
