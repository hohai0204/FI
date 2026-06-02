CLASS zcl_fa_zgl04n_excel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: r_companycode    TYPE if_rap_query_filter=>tt_range_option,
          r_postingdate    TYPE if_rap_query_filter=>tt_range_option,
          r_fiscalyear     TYPE if_rap_query_filter=>tt_range_option,
          r_accdoc         TYPE if_rap_query_filter=>tt_range_option,
          cb_incl_reversed TYPE abap_boolean,
          r_uuid           TYPE if_rap_query_filter=>tt_range_option.
    TYPES tt_zgl04n TYPE STANDARD TABLE OF zr_fa_zgl04n_excel WITH EMPTY KEY.

    DATA: BEGIN OF s_footer,
            nguoi_lap TYPE zde_desc_255,
            ke_toan   TYPE zde_desc_255,
            giam_doc  TYPE zde_desc_255,
          END OF s_footer.

    METHODS set_selscreen
      IMPORTING
        it_filter TYPE if_rap_query_filter=>tt_name_range_pairs.

    METHODS get_data
      RETURNING
        VALUE(rt_data) TYPE tt_zgl04n.

ENDCLASS.



CLASS ZCL_FA_ZGL04N_EXCEL IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lt_data TYPE tt_zgl04n,
          lt_tmp  TYPE tt_zgl04n.

**  Phân trang
    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).


**  Set data from Selection Screen.
    TRY.
        me->set_selscreen( io_request->get_filter( )->get_as_ranges( ) ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).
    ENDTRY.


**  Query data
**********************************************************************
*   Origin Doc = Reversed Doc: Chứng từ hủy
*   Reversal Doc: Chứng từ đảo ( dùng để hủy chứng từ gốc )
**********************************************************************
    lt_data =  me->get_data( ).
    SORT lt_data BY
      companycode
      fiscalyear
      postingdate DESCENDING
      accountingdocument DESCENDING
      item ASCENDING.



    lt_tmp = VALUE tt_zgl04n( FOR ls_row IN lt_data
                               FROM skip + 1 TO skip + top
                               ( ls_row ) ).
*
*    SORT lt_tmp BY companycode fiscalyear
*                    postingdate  accountingdocument
*                    s_glaccount h_glaccount.


    io_response->set_data( lt_tmp ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.
  ENDMETHOD.


  METHOD set_selscreen.
    LOOP AT it_filter INTO DATA(lw_filter).
      CHECK lw_filter-range IS NOT INITIAL.
      CASE lw_filter-name.
        WHEN 'COMPANYCODE'.
          r_companycode = lw_filter-range.

        WHEN 'POSTINGDATE'.
          r_postingdate = lw_filter-range.
          DELETE r_postingdate WHERE low EQ '00000000' AND high EQ '00000000'.

        WHEN 'FISCALYEAR'. "Mandatory - Single
          r_fiscalyear = lw_filter-range.

        WHEN 'INCL_RESERVE'.
          DATA(lr_incl_reserve) = lw_filter-range.
          cb_incl_reversed = lr_incl_reserve[ 1 ]-low.

        WHEN 'UUID'.
          r_uuid = lw_filter-range.

        WHEN 'NGUOI_LAP'.
          s_footer-nguoi_lap = lw_filter-range[ 1 ]-low.

        WHEN 'KE_TOAN'.
          s_footer-ke_toan = lw_filter-range[ 1 ]-low.

        WHEN 'GIAM_DOC'.
          s_footer-giam_doc = lw_filter-range[ 1 ]-low.

        WHEN 'ACCOUNTINGDOCUMENT'. " hoangtd21 test
          r_accdoc = lw_filter-range.

      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_data.
    DATA: lw_data TYPE zr_fa_zgl04n_excel,
          lt_data TYPE tt_zgl04n,
          lt_tmp  TYPE tt_zgl04n.

    SELECT
         header~companycode,
         header~fiscalyear,
         header~accountingdocument,
         header~postingdate,
         header~documentdate,
         header~isreversed,
         header~reversedocument,
*         coalesce( item~documentitemtext,
*                  header~accountingdocumentheadertext )
*                AS description,
        item~ledgergllineitem AS item, " hoangtd21 test
        CASE WHEN item~documentitemtext <> ' '
             THEN item~documentitemtext
             ELSE header~accountingdocumentheadertext
             END AS description,

         CASE WHEN item~debitcreditcode = 'S'
              THEN item~glaccount
              END AS s_glaccount,
         CASE WHEN item~debitcreditcode = 'H'
              THEN item~glaccount
              END AS h_glaccount,
         CASE WHEN item~debitcreditcode = 'S'
              THEN item~debitamountincocodecrcy
              END AS s_amount,
         CASE WHEN item~debitcreditcode = 'H'
              THEN item~creditamountincocodecrcy
              END AS h_amount,
         @me->s_footer-nguoi_lap AS nguoi_lap,
         @me->s_footer-ke_toan   AS ke_toan,
         @me->s_footer-giam_doc  AS giam_doc
       FROM i_journalentry AS header
       INNER JOIN i_journalentryitem AS item
               ON item~companycode = header~companycode
              AND item~fiscalyear  = header~fiscalyear
              AND item~accountingdocument  = header~accountingdocument
      WHERE item~ledger = '0L'
        AND header~fiscalyear  IN @me->r_fiscalyear
        AND header~postingdate IN @me->r_postingdate
        AND header~companycode IN @me->r_companycode
        AND header~accountingdocument IN @me->r_accdoc " hoangtd21 test
     ORDER BY header~companycode,
              header~fiscalyear,
              header~accountingdocument,
          item~ledgergllineitem,
              header~postingdate
         INTO TABLE @DATA(lt_origindoc).
*         UP TO @i_top ROWS
*         OFFSET @i_skip.

*   Get Reversal Document
    SELECT
        header~companycode,
        header~fiscalyear,
        header~accountingdocument,
        header~postingdate,
        header~documentdate,
        header~isreversed,
        header~reversedocument,
        item~ledgergllineitem AS item, " hoangtd21 test
*        coalesce( item~documentitemtext,
*                  header~accountingdocumentheadertext )
*                AS description,

        CASE WHEN item~documentitemtext <> ' '
             THEN item~documentitemtext
             ELSE header~accountingdocumentheadertext
             END AS description,

        CASE WHEN item~debitcreditcode = 'S'
             THEN item~glaccount
             END AS s_glaccount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~glaccount
             END AS h_glaccount,
        CASE WHEN item~debitcreditcode = 'S'
             THEN item~debitamountincocodecrcy
             END AS s_amount,
        CASE WHEN item~debitcreditcode = 'H'
             THEN item~creditamountincocodecrcy
             END AS h_amount,
        @me->s_footer-nguoi_lap AS nguoi_lap,
        @me->s_footer-ke_toan   AS ke_toan,
        @me->s_footer-giam_doc  AS giam_doc
      FROM @lt_origindoc AS origindoc
      LEFT JOIN
       ( i_journalentry AS header INNER JOIN i_journalentryitem AS item
           ON item~companycode = header~companycode
          AND item~fiscalyear  = header~fiscalyear
          AND item~accountingdocument = header~accountingdocument
       )   ON header~companycode      = origindoc~companycode
          AND header~reversedocument  = origindoc~accountingdocument
      WHERE  item~ledger = '0L'
        AND origindoc~isreversed = 'X'
        AND header~companycode IN @me->r_companycode
        AND header~accountingdocument IN @me->r_accdoc " hoangtd21
        AND header~isreversal = 'X'
    INTO TABLE @DATA(lt_reversaldoc).



**  Checkbox Include Reversed
    IF cb_incl_reversed = abap_false AND lt_reversaldoc IS NOT INITIAL.
      "Hiển thị chứng từ reversed khác kỳ
      LOOP AT lt_origindoc ASSIGNING FIELD-SYMBOL(<lf_origin>)
                               WHERE isreversed IS NOT INITIAL.
        READ TABLE lt_reversaldoc ASSIGNING FIELD-SYMBOL(<lf_reversal>)
           WITH KEY accountingdocument = <lf_origin>-reversedocument.
        IF sy-subrc = 0 AND ( <lf_reversal>-fiscalyear <> <lf_origin>-fiscalyear
                         OR   <lf_reversal>-postingdate+4(2) <> <lf_origin>-postingdate+4(2) ).

          lw_data = CORRESPONDING #(  <lf_reversal>  ).
          APPEND lw_data TO lt_data. CLEAR lw_data.
        ENDIF.

        lw_data = CORRESPONDING #(  <lf_origin> ).
        APPEND lw_data TO lt_data. CLEAR lw_data.
      ENDLOOP.

      "Get Normal Origin Document
      DELETE lt_origindoc WHERE isreversed IS NOT INITIAL.
      lt_tmp =  CORRESPONDING #( lt_origindoc ).
      APPEND LINES OF lt_tmp TO lt_data.
      CLEAR lt_tmp.


    ELSE.
      APPEND LINES OF lt_reversaldoc TO lt_origindoc.
      lt_data = CORRESPONDING #( lt_origindoc ).
    ENDIF.

*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>)
*                                 GROUP BY ( companycode = <ls_data>-companycode
*                                            fiscalyear  = <ls_data>-fiscalyear
*                                            accountingdocument = <ls_data>-accountingdocument
*                                            postingdate = <ls_data>-postingdate
*                                            s_glaccount = <ls_data>-s_glaccount
*                                            h_glaccount = <ls_data>-h_glaccount  ).
*      CLEAR lw_data.
*      lw_data = CORRESPONDING #( <ls_data> EXCEPT s_amount h_amount ).
*      LOOP AT GROUP  <ls_data> ASSIGNING FIELD-SYMBOL(<lf_group>).
*        lw_data-s_amount += <lf_group>-s_amount.
*        lw_data-h_amount += <lf_group>-h_amount.
*      ENDLOOP.
*      APPEND lw_data TO rt_data.
*    ENDLOOP.

    rt_data = CORRESPONDING #( lt_data ). " hoangtd21
    DATA: lv_item TYPE i,
          lv_doc  TYPE belnr_d.

    SORT rt_data BY companycode fiscalyear postingdate accountingdocument.

    CLEAR: lv_item, lv_doc.

    LOOP AT rt_data ASSIGNING FIELD-SYMBOL(<ls>).

      IF lv_doc <> <ls>-accountingdocument.
        lv_doc = <ls>-accountingdocument.
        lv_item = 1.
      ELSE.
        lv_item += 1.
      ENDIF.

      <ls>-item = lv_item.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
