@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity ZRM03'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFA_I_ZRM03
  as select from    I_JournalEntry                as Fi_head
  //    left outer join I_JournalEntryItem       as fi_item    on  Fi_head.AccountingDocument   =  fi_item.AccountingDocument
  //                                                           and fi_item.FinancialAccountType =  'S'
  //                                                           and fi_item.GLAccountType        <> 'X'
  //                                                           and fi_item.Ledger               =  '0L'
  //                                                           and fi_item.TaxCode              is not initial
    left outer join ZCDS_FI_KD_DATA               as item_KD         on  item_KD.CompanyCode          = Fi_head.CompanyCode
                                                                     and Fi_head.AccountingDocument   = item_KD.AccountingDocument
                                                                     and Fi_head.FiscalYear           = item_KD.FiscalYear
                                                                   //  and item_KD.FinancialAccountType = 'D'
    left outer join ZFA_V_TAXFI_SUM               as ItemTax         on  ItemTax.AccountingDocument = Fi_head.AccountingDocument
                                                                     and ItemTax.CompanyCode        = Fi_head.CompanyCode

    left outer join ZFA_V_MINITEMTAX_LG           as minitem_tax     on  Fi_head.AccountingDocument = minitem_tax.AccountingDocument
                                                                     and Fi_head.FiscalYear         = minitem_tax.FiscalYear
                                                                     and ItemTax.TaxCode            = minitem_tax.TaxCode
    inner join      I_JournalEntryItem            as fi_item         on  minitem_tax.AccountingDocument     = fi_item.AccountingDocument
                                                                     and minitem_tax.CompanyCode            = fi_item.CompanyCode
                                                                     and minitem_tax.FiscalYear             = fi_item.FiscalYear
                                                                     and minitem_tax.TaxCode            = fi_item.TaxCode
                                                                     and fi_item.Ledger                 = '0L'
                                                                     and fi_item.AccountingDocumentItem = minitem_tax.AccountingDocumentItem
                                                                    and fi_item.LedgerGLLineItem       = minitem_tax.LG_Item
    left outer join I_BillingDocumentPartnerBasic as PartnerBasic_RE on  Fi_head.OriginalReferenceDocument = PartnerBasic_RE.BillingDocument
                                                                     and PartnerBasic_RE.PartnerFunction   = 'RE'
    left outer join ZCDS_BP_PROFILE               as Customer        on PartnerBasic_RE.Customer = Customer.BusinessPartner
    left outer join ZCDS_BP_PROFILE               as Customer_fi     on item_KD.customer = Customer_fi.BusinessPartner

    left outer join ZCDS_BP_OTA                   as OTA_CUS         on  PartnerBasic_RE.Customer          = OTA_CUS.Customer
                                                                     and Fi_head.OriginalReferenceDocument = OTA_CUS.BillingDocument
    left outer join I_OneTimeAccountSupplier      as OTA_CUSFI       on  OTA_CUSFI.AccountingDocument     = item_KD.AccountingDocument
                                                                     and OTA_CUSFI.CompanyCode            = item_KD.CompanyCode
                                                                     and OTA_CUSFI.FiscalYear             = item_KD.FiscalYear
                                                                     and OTA_CUSFI.AccountingDocumentItem = item_KD.AccountingDocumentItem
    inner join      ztb_fi_ztax                   as _Tax_Group      on  _Tax_Group.tax_code = ItemTax.TaxCode
                                                                     and _Tax_Group.tax_type = 'B'
    left outer join ZCDS_COMPANY                  as _Company        on Fi_head.CompanyCode = _Company.CompanyCode

    left outer join ZFA_V_LISTTAX_FIDOC           as linetax         on linetax.AccountingDocument = Fi_head.AccountingDocument
{
  key concat(
   concat(
    concat( Fi_head.CompanyCode, Fi_head.AccountingDocument)
     , _Tax_Group.tax_group ), ItemTax.TaxCode )                                                                as Object,
      Fi_head.CompanyCode,
      _Company.tencty_vn,
      _Company.diachi_vn,
      _Company.mst                                                                                              as MST_Company,
      Fi_head.AccountingDocument,
      Fi_head.PostingDate,
      concat( substring(Fi_head.PostingDate,5,2), concat('.',substring(Fi_head.PostingDate,1,4) ) )             as Period,
      case when Fi_head.AccountingDocumentType = 'RV' then PartnerBasic_RE.Customer
      else item_KD.customer end as customer,
      Fi_head.AccountingDocumentType,
      case when Fi_head.AccountingDocumentType = 'RV' then
      case  when Customer.IsOneTimeAccount is not initial then
         OTA_CUS.name
           else Customer.name  end
           else
           case  when Customer_fi.IsOneTimeAccount is not initial then
          concat_with_space( OTA_CUSFI.BusinessPartnerName1,
          concat_with_space( OTA_CUSFI.BusinessPartnerName2,
          concat_with_space( OTA_CUSFI.BusinessPartnerName3, OTA_CUSFI.BusinessPartnerName4, 1), 1) ,1 )

           else Customer_fi.name  end
            end                                                                                                 as CustomerName,

      case when Fi_head.AccountingDocumentType = 'RV' then
      case  when Customer.IsOneTimeAccount is not initial then
      concat(concat(  concat(
            concat_with_space(  OTA_CUS.street1, OTA_CUS.street2, 1 ),  OTA_CUS.street3 ),OTA_CUS.street4 ), OTA_CUS.street5 )

      else Customer.ADDRESS  end
      else
      case  when Customer_fi.IsOneTimeAccount is not initial then
      concat_with_space( OTA_CUSFI.StreetAddressName, OTA_CUSFI.CityName, 1)
      else
      Customer_fi.ADDRESS      end
      end                                                                                                       as CustomerAdress,

      Customer.MST                                                                                              as MST_Customer,
      Fi_head.DocumentReferenceID,
      Fi_head.DocumentDate,
      Fi_head.IsReversed,
      Fi_head.OriginalReferenceDocument,
      cast( _Tax_Group.taxgroup_desc as abap.char( 255 ) )                                                      as DGDV,
      _Tax_Group.taxcode_desc,
      _Tax_Group.tax_group,
      fi_item.AssignmentReference                                                                               as AssignmentReference,
      case   when linetax.Count_taxcode = 1 then item_KD.DocumentItemText else  fi_item.DocumentItemText    end as itemtext,
      fi_item.AccountingDocumentItem                                                                            as acc_item,
      substring(
      Fi_head.DocumentReferenceID,1,
      instr( Fi_head.DocumentReferenceID, '.' ) - 1
                                             )                                                                  as Pattern,
      substring(
      Fi_head.DocumentReferenceID,
      instr( Fi_head.DocumentReferenceID, '.' ) + 1,
      100
                                                   )                                                            as Invoice_Num,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      fi_item.Quantity                                                                                          as Quantity,
      fi_item.BaseUnit                                                                                          as BaseUnit,
      ItemTax.GLAccount,
      ItemTax.TaxCode,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ItemTax.BaseAmount                                                                                        as amount,
      case when ItemTax.CompanyCodeCurrency is not initial then ItemTax.CompanyCodeCurrency
           when fi_item.CompanyCodeCurrency is not initial then fi_item.CompanyCodeCurrency end                 as CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast( ItemTax.TaxAmount  as abap.curr( 17, 2 )    )                                                       as Taxamount,
      ItemTax.TaxRate,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      case
        when fi_item.Quantity is null or fi_item.Quantity = 0 then ItemTax.BaseAmount
        else cast(
               division(
                 cast(coalesce( cast( ItemTax.BaseAmount as abap.dec(16,3) ), 0 ) as abap.dec(16,3)),
                 cast(fi_item.Quantity as abap.dec(10,3)),
                 3
               ) as abap.curr(16,2)
             )
      end                                                                                                       as Price

}
where
  fi_item.GLAccount not like '333%'
