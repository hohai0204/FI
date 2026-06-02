CLASS zcl_getdata_phieuthu DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GETDATA_PHIEUTHU IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA ls_values TYPE  zfa_i_custom_phieuthu .
    DATA lt_values TYPE STANDARD TABLE OF zfa_i_custom_phieuthu WITH EMPTY KEY.
    DATA lt_values_out TYPE STANDARD TABLE OF zfa_i_custom_phieuthu WITH EMPTY KEY.
    SELECT
    fi_head~companycode,
    fi_head~fiscalyear,
    fi_head~accountingdocument,
    fi_head~postingdate,
    fi_head~documentdate,
    fi_head~documentreferenceid,
    zcds_company~tencty_vn ,
    zcds_company~diachi_vn,
    zcds_company~mst
    FROM i_journalentry AS fi_head
    LEFT JOIN zcds_company ON zcds_company~companycode = fi_head~companycode
   INTO TABLE @DATA(lt_header).

    SELECT
      header~companycode,
      header~fiscalyear,
      header~accountingdocument,
    fi_item~debitcreditcode,
    fi_item~accountingdocumentitem,
    fi_item~glaccount
      FROM @lt_header AS header
      LEFT JOIN i_operationalacctgdocitem     AS fi_item ON  header~accountingdocument =   fi_item~accountingdocument
            AND   header~companycode =   fi_item~companycode AND   header~fiscalyear =   fi_item~fiscalyear
            WHERE  ( debitcreditcode = 'S' OR debitcreditcode = 'H' )
            ORDER BY header~companycode,
      header~fiscalyear,
      header~accountingdocument,
    fi_item~debitcreditcode,
    fi_item~accountingdocumentitem

     INTO TABLE @DATA(lt_glaccount).

    SELECT
             fi_item~companycode,
             fi_item~accountingdocument,
             fi_item~fiscalyear,
             MIN( fi_item~accountingdocumentitem ) AS accountingdocumentitem,
             MIN( item_cus~ledgergllineitem ) AS ledgergllineitem
      FROM  @lt_header AS header INNER JOIN i_operationalacctgdocitem     AS fi_item ON  header~accountingdocument =   fi_item~accountingdocument
          AND   header~companycode =   fi_item~companycode AND   header~fiscalyear =   fi_item~fiscalyear
          INNER JOIN   i_journalentry      ON         i_journalentry~accountingdocument =   fi_item~accountingdocument
          AND   i_journalentry~companycode =   fi_item~companycode AND   i_journalentry~fiscalyear =   fi_item~fiscalyear
          INNER JOIN i_journalentryitem AS item_cus ON fi_item~accountingdocument = item_cus~accountingdocument
         AND fi_item~accountingdocumentitem = item_cus~accountingdocumentitem AND fi_item~fiscalyear = item_cus~fiscalyear
         AND fi_item~companycode = item_cus~companycode AND item_cus~sourceledger = '0L'
         WHERE ( fi_item~financialaccounttype = 'K'
                 OR  fi_item~financialaccounttype  = 'D' )
              GROUP BY    fi_item~companycode,
             fi_item~accountingdocument,
             fi_item~fiscalyear
             ORDER BY  fi_item~companycode,
             fi_item~accountingdocument,
             fi_item~fiscalyear
 INTO TABLE @DATA(lt_kd_data).

    SELECT
     fi_item~companycode,
                fi_item~accountingdocument,
                fi_item~fiscalyear,
                fi_item~glaccount,
                fi_item~debitcreditcode,
                fi_item~documentitemtext,
                fi_item~accountingdocumentitem

       FROM  @lt_header AS header INNER JOIN i_operationalacctgdocitem     AS fi_item ON  header~accountingdocument =   fi_item~accountingdocument
             AND   header~companycode =   fi_item~companycode AND   header~fiscalyear =   fi_item~fiscalyear
             WHERE fi_item~glaccount LIKE '111*'
             ORDER BY  fi_item~accountingdocument,
                fi_item~fiscalyear,
                fi_item~glaccount,
                fi_item~debitcreditcode,
                fi_item~documentitemtext,
                fi_item~accountingdocumentitem
             INTO TABLE @DATA(lt_debitcredit).
    SELECT
                fi_item~companycode,
                fi_item~accountingdocument,
                fi_item~fiscalyear,
                fi_item~glaccount,
                fi_item~debitcreditcode,
                fi_item~transactioncurrency,
                SUM(  fi_item~amountintransactioncurrency ) AS amount

       FROM  @lt_header AS header INNER JOIN i_operationalacctgdocitem     AS fi_item ON  header~accountingdocument =   fi_item~accountingdocument
             AND   header~companycode =   fi_item~companycode AND   header~fiscalyear =   fi_item~fiscalyear
             WHERE fi_item~glaccount LIKE '111*'
             GROUP BY fi_item~companycode,fi_item~accountingdocument,
                fi_item~fiscalyear,
                fi_item~glaccount,
                fi_item~debitcreditcode,
             fi_item~transactioncurrency
             ORDER BY  fi_item~companycode,fi_item~accountingdocument,
                fi_item~fiscalyear,
                fi_item~glaccount,
                fi_item~debitcreditcode
             INTO TABLE @DATA(lt_debitcredit_amount).

    LOOP AT lt_header INTO DATA(ls_header).
      ls_values-acountingdocument = ls_header-accountingdocument.
      ls_header-companycode  = ls_header-companycode.
      ls_values-companyname = ls_header-tencty_vn.
      ls_values-companyadress = ls_header-diachi_vn.
      ls_values-taxnum = ls_header-mst.
      ls_values-fisyear = ls_header-fiscalyear.
      ls_values-object = |{ ls_header-companycode }{ ls_header-fiscalyear }{ ls_header-accountingdocument }|.
      ls_values-budat = ls_header-postingdate.
      ls_values-bldat = ls_header-documentdate.
      ls_values-documentreferenceid = ls_header-documentreferenceid.
      READ TABLE lt_glaccount INTO DATA(ls_glaccount) WITH KEY companycode = ls_header-companycode  fiscalyear = ls_values-fisyear
                                                               accountingdocument = ls_values-acountingdocument debitcreditcode = 'S' BINARY SEARCH.
      IF sy-subrc = 0.
        ls_values-debit = ls_glaccount-glaccount.
      ENDIF.
      READ TABLE lt_glaccount INTO ls_glaccount WITH KEY companycode = ls_header-companycode  fiscalyear = ls_values-fisyear
                                                               accountingdocument = ls_values-acountingdocument debitcreditcode = 'H' BINARY SEARCH.
      IF sy-subrc = 0.
        ls_values-crebit = ls_glaccount-glaccount.
      ENDIF.
      READ TABLE lt_kd_data INTO DATA(ls_kddata) WITH KEY companycode = ls_header-companycode  fiscalyear = ls_values-fisyear
                                                          accountingdocument = ls_values-acountingdocument BINARY SEARCH.
      IF sy-subrc = 0.

      ENDIF.

      READ TABLE lt_debitcredit INTO DATA(ls_111) WITH KEY companycode = ls_header-companycode  fiscalyear = ls_values-fisyear
                                                           accountingdocument = ls_values-acountingdocument BINARY SEARCH.
      IF sy-subrc = 0.


      ENDIF.
    ENDLOOP.

    "test
*    DATA: lv_numc TYPE zde_numc3.
*    TRY.
*    DO 100 TIMES.
*      lv_numc += 1.
*      ls_values-acountingdocument = lv_numc .
*      ls_values-companyname = '1000'.
*    ENDDO.
*
*    DATA(top)     = io_request->get_paging( )->get_page_size( ).
*    DATA(skip)    = io_request->get_paging( )->get_offset( ).
*    DATA(lv_start) = skip + 1.
*    DATA(lt_requested_elements) = io_request->get_requested_elements( ).
*    DATA(lv_end) = skip + top.
*
*    IF lv_end < 1 OR lv_start < 1.
*    ELSE.
*      APPEND LINES OF lt_values FROM lv_start TO lv_end TO lt_values_out.
*    ENDIF.
*    DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).
*
*    io_response->set_total_number_of_records( lines( lt_values ) ).
*    io_response->set_data( lt_values ).
*    io_request->get_sort_elements( ).
*    io_request->get_paging( ).
*    " Set requested fields
**IF lt_requested_elements IS NOT INITIAL.
**  io_response->set_select_properties( CORRESPONDING #( lt_requested_elements ) ).
**ENDIF.
*
*  CATCH cx_root INTO DATA(exception).
**exception_message = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
*ENDTRY.

  ENDMETHOD.
ENDCLASS.
