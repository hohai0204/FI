CLASS zcl_main_zkc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
    INTERFACES if_rap_query_request.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MAIN_ZKC IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    "khai báo ===========================================================
    DATA: lt_results_head TYPE STANDARD TABLE OF  zi_zkc_main,
          lt_results      TYPE STANDARD TABLE OF  zi_zkc_main,
          lt_result_page  TYPE STANDARD TABLE OF zi_zkc_main.
    TRY.
        DATA(lo_filter) = io_request->get_filter( )->get_as_ranges( ).
        " Filter
        DATA(ro_filter) = io_request->get_filter( ).
        " Conditions
        DATA(lv_conditions) = io_request->get_filter( )->get_as_sql_string( ).

        TRY.
            DATA(rt_ranges) = ro_filter->get_as_ranges( iv_drop_null_comparisons = abap_true ).
          CATCH cx_rap_query_filter_no_range.
            RETURN.
        ENDTRY.
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_error).
        DATA(lv_err) = lx_error->get_text( ).  " Hoặc ghi log, v.v.
    ENDTRY.

    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).

    DATA: lv_reverd     TYPE abap_boolean,
          lv_headertext TYPE text100.
    DATA:
      lr_rult        TYPE   if_rap_query_filter=>tt_range_option,
      lr_compcode    TYPE if_rap_query_filter=>tt_range_option,
      lr_fisyear     TYPE if_rap_query_filter=>tt_range_option,
      lr_period      TYPE if_rap_query_filter=>tt_range_option,
      lr_fitype      TYPE if_rap_query_filter=>tt_range_option,
      lr_docdate     TYPE if_rap_query_filter=>tt_range_option,
      lr_postingdate TYPE if_rap_query_filter=>tt_range_option,
      lr_headertext  TYPE if_rap_query_filter=>tt_range_option,
      lr_reves       TYPE if_rap_query_filter=>tt_range_option.


    IF rt_ranges IS NOT INITIAL.
      LOOP AT rt_ranges INTO DATA(lw_range).
        CASE lw_range-name.

          WHEN 'RULTY'.
            lr_rult = lw_range-range.
          WHEN 'BUKRS'.
            lr_compcode = lw_range-range.
          WHEN 'FISCALYEAR'.
            lr_fisyear = lw_range-range.
          WHEN 'PERIOD'.
            lr_period = lw_range-range.
          WHEN 'ACCOUNTINGDOCUMENTTYPE'.
            lr_fitype = lw_range-range.
          WHEN 'DOCUMENTDATE'.
            lr_docdate = lw_range-range.
          WHEN 'POSTINGDATE'.
            lr_postingdate = lw_range-range.
          WHEN 'ACCOUNTINGDOCUMENTHEADERTEXT'.
            lr_headertext  = lw_range-range.
          WHEN 'ISREVERSED'.
            lr_reves = lw_range-range.
          WHEN OTHERS.
            " Do nothing for other fields
        ENDCASE.
      ENDLOOP.
    ENDIF.
    DATA: lv_rulty TYPE zde_rulty_2.
    READ TABLE lr_rult INDEX 1 INTO DATA(ls_rutyl).
    lv_rulty = ls_rutyl-low.
    "check authority============================================================
    DATA:lv_authority TYPE abap_boolean.
    SELECT SINGLE  companycode
    FROM i_companycode AS comcode
    WHERE comcode~companycode IN @lr_compcode
    INTO @DATA(lv_companycode).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
            ID 'BUKRS' FIELD  lv_companycode
            ID 'ACTVT'      FIELD '03'.

    IF sy-subrc = 0.
    ELSE.
      lv_authority = abap_true.
    ENDIF.

    IF lv_authority IS INITIAL.

      DATA: lr_comp TYPE RANGE OF bukrs,
            lr_comppt TYPE RANGE OF bukrs.
            if lv_rulty = '1' or lv_rulty = '2' or lv_rulty = '3' or lv_rulty = '4' .
      SELECT zoption     AS option,
             zsign       AS sign,
             zlow        AS low,
             zhigh       AS high
         FROM ztb_einv_var_i AS var_comp
          WHERE var_comp~variant_name = 'ZKC_CTDL'
          INTO CORRESPONDING FIELDS OF TABLE @lr_comp.
          ENDIF.
                if lv_rulty = '1' or lv_rulty = '2' or lv_rulty = '3' or lv_rulty = '3A' .

      SELECT zoption     AS option,
             zsign       AS sign,
             zlow        AS low,
             zhigh       AS high
         FROM ztb_einv_var_i AS var_comp
          WHERE var_comp~variant_name = 'ZKC_CTPT'
          APPENDING CORRESPONDING FIELDS OF TABLE @lr_comp.
          endif.
      "get data===============================================

*      SELECT MIN( calendardate )
*      FROM i_calendardate
*      WHERE calendardate IN @lr_postingdate
*      INTO @DATA(lv_datemin).
      SELECT SINGLE fiscalperiodstartdate AS mindate
      FROM i_fiscalcalyearperiodforcocode AS period_d
      WHERE period_d~fiscalperiod IN @lr_period
      AND period_d~fiscalyear IN @lr_fisyear
      AND period_d~companycode IN @lr_compcode
       INTO @DATA(lv_datemin).

*      SELECT MAX( calendardate )
*      FROM i_calendardate
*      WHERE calendardate IN @lr_postingdate
*      INTO @DATA(lv_datemax).
      SELECT SINGLE fiscalperiodenddate AS maxdate
      FROM i_fiscalcalyearperiodforcocode AS period_d
      WHERE period_d~fiscalperiod IN @lr_period
      AND period_d~fiscalyear IN @lr_fisyear
      AND period_d~companycode IN @lr_compcode
       INTO @DATA(lv_datemax).



      SELECT SINGLE  fiscalyear
      FROM i_fiscalyearforcompanycode AS fiscalyear
      WHERE fiscalyear~companycode IN @lr_compcode
       AND fiscalyear~fiscalyear IN @lr_fisyear
      INTO @DATA(lv_fisyear).

      SELECT SINGLE  fiscalperiod
     FROM i_fiscalyearperiodforcmpnycode AS fiscalperiod
     WHERE fiscalperiod~companycode IN @lr_compcode
      AND fiscalperiod~fiscalyear IN @lr_fisyear
        AND fiscalperiod~fiscalperiod IN @lr_period
     INTO @DATA(lv_fisperiod).

      IF lr_reves IS NOT INITIAL.
        lv_reverd = abap_true.
      ENDIF.

      LOOP AT lr_headertext INTO DATA(ls_headertext).
        lv_headertext = ls_headertext-low.
      ENDLOOP.
      SELECT
       glaccount AS sacct,
      companycodecurrency AS waers,
      amount
      FROM zi_zkc_list( p_startdate = @lv_datemin, p_enddate = @lv_datemax )  AS data

       WHERE  companycode = @lv_companycode
       AND fiscalyear = @lv_fisyear
       AND fiscalperiod = @lv_fisperiod
and CompanyCode in @lr_comp
      INTO CORRESPONDING FIELDS OF TABLE @lt_results.

      SELECT
      sacct ,
       bukrs,
        rulty ,
        rulttext~text AS rultname,
        dacct ,
        dcost ,
        CASE WHEN account~reconciliationaccount IS NOT INITIAL THEN
        account~reconciliationaccount
        ELSE ztb_zmapkc~dacct2 END  AS dacct2  ,
        acct,
        dprctr,
        oacct,
        ocost,
        oprctr,
        i_glaccounttext~glaccountlongname
      FROM ztb_zmapkc
      LEFT JOIN  zi_rult_f4 AS rulttext ON ztb_zmapkc~rulty = rulttext~value_low
  LEFT JOIN i_glaccounttext ON i_glaccounttext~chartofaccounts = 'YCOA'
  AND i_glaccounttext~language = @sy-langu AND i_glaccounttext~glaccount = ztb_zmapkc~sacct
  LEFT JOIN i_suppliercompany AS account ON account~supplier = ztb_zmapkc~acct AND account~companycode = ztb_zmapkc~bukrs

      WHERE rulty IN @lr_rult
      AND bukrs IN @lr_compcode
and bukrs  in @lr_comp
  ORDER BY
      bukrs,
      sacct ,
            dacct  ,
            dcost  ,
            dacct2,
            oacct ,
            ocost

      INTO TABLE @DATA(lt_mapkc).
      SELECT
     ztb_fi_kc~rulty ,
     ztb_fi_kc~bukrs,
     ztb_fi_kc~fiscalyear,
      ztb_fi_kc~period,
      belnr,
      belnr_r
     FROM  ztb_fi_kc
     WHERE ztb_fi_kc~bukrs           =   @lv_companycode
  AND  ztb_fi_kc~fiscalyear      =    @lv_fisyear
  AND  ztb_fi_kc~period =  @lv_fisperiod
  ORDER BY  ztb_fi_kc~rulty ,
     ztb_fi_kc~bukrs,
     ztb_fi_kc~fiscalyear,
      ztb_fi_kc~period
    INTO TABLE @DATA(lt_belnr).

      IF lt_mapkc IS NOT INITIAL.
        DATA: lv_lineid TYPE int4.
        LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<lfs_data>).
          lv_lineid += 1.
          <lfs_data>-bukrs = lv_companycode.
          <lfs_data>-lineid = lv_lineid.
          <lfs_data>-fiscalyear = lv_fisyear.
          <lfs_data>-period = lv_fisperiod.
          <lfs_data>-documentdate = lv_datemax.
          <lfs_data>-postingdate = lv_datemax.
          <lfs_data>-accountingdocumenttype = 'KC'.
          <lfs_data>-accountingdocumentheadertext = lv_headertext.
          <lfs_data>-isreversed = lv_reverd.

          READ TABLE lt_mapkc INTO DATA(ls_mapkc) WITH KEY  bukrs = <lfs_data>-bukrs sacct = <lfs_data>-sacct  BINARY SEARCH.
          IF sy-subrc  = 0.
            <lfs_data>-bukrs = ls_mapkc-bukrs.
            <lfs_data>-rulty = ls_mapkc-rulty.
            <lfs_data>-sacct     = ls_mapkc-sacct.
            IF ls_mapkc-rulty = '3A'.
              <lfs_data>-dacct     = ls_mapkc-dacct2.
            ELSE.
              <lfs_data>-dacct     = ls_mapkc-dacct.
            ENDIF.
            <lfs_data>-dcost     = ls_mapkc-dcost.
            <lfs_data>-dprctr     = ls_mapkc-dprctr.
            <lfs_data>-oacct     = ls_mapkc-oacct .
            <lfs_data>-ocost     = ls_mapkc-ocost.
            <lfs_data>-oprctr     = ls_mapkc-oprctr .
            <lfs_data>-glaccountlongname  = ls_mapkc-glaccountlongname.
          ELSE.


          ENDIF.
          READ TABLE lt_belnr INTO DATA(ls_belnr) WITH KEY  rulty = <lfs_data>-rulty
     bukrs = <lfs_data>-bukrs
    fiscalyear = <lfs_data>-fiscalyear
    period = <lfs_data>-period   BINARY SEARCH.
          IF sy-subrc = 0.
            IF lv_reverd = abap_true.
              <lfs_data>-belnr = ls_belnr-belnr_r.

            ELSE.
              <lfs_data>-belnr = ls_belnr-belnr.
            ENDIF.
          ENDIF.
        ENDLOOP.

        DELETE lt_results WHERE rulty IS INITIAL.
        SORT lt_results BY rulty sacct.
      ELSE.
        CLEAR: lt_results.
      ENDIF.
    ELSE.
      CLEAR: lt_results.
    ENDIF.
    TRY.
        "export data entity======================================================
        IF lt_results IS NOT INITIAL.


          " Request Sorting
          DATA: lv_sort_string TYPE string.
          DATA(sort_elements) = io_request->get_sort_elements( ).
          IF sort_elements IS NOT INITIAL.
            DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                       ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true
                                                                                              THEN ' descending'
                                                                                              ELSE ' ascending' ) ) ).

            IF lt_sort_criteria IS INITIAL.
              lv_sort_string = 'primary key'.
            ELSE.
              lv_sort_string = concat_lines_of( table = lt_sort_criteria sep = `, ` ).
            ENDIF.

          ENDIF.
          IF lv_sort_string IS NOT INITIAL.
            SELECT * FROM @lt_results AS data  ORDER BY (lv_sort_string) INTO  TABLE @lt_results.
          ELSE.
            SELECT * FROM @lt_results AS data ORDER BY sacct INTO  TABLE @lt_results.
          ENDIF.


          IF top < 0.
            top = 1.
          ENDIF.

          IF lines( lt_results ) > 1.
            LOOP AT lt_results INTO DATA(ls_row) FROM skip + 1 TO skip + top.
              APPEND ls_row TO lt_result_page.
            ENDLOOP.
          ELSE.
            lt_result_page = lt_results.
          ENDIF.




        ENDIF.

        io_response->set_data( lt_result_page ).
        IF io_request->is_total_numb_of_rec_requested( ).

          io_response->set_total_number_of_records( lines( lt_results ) ).
        ENDIF.


      CATCH cx_root INTO DATA(lv_erorr).
        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_data( lt_result_page ).
          io_response->set_total_number_of_records( 0 ).
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD   if_rap_query_request~get_aggregation.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_entity_id.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_filter.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_paging.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_parameters.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_requested_elements.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_search_expression.
  ENDMETHOD.


  METHOD   if_rap_query_request~get_sort_elements.
  ENDMETHOD.


  METHOD   if_rap_query_request~is_data_requested.
  ENDMETHOD.


  METHOD   if_rap_query_request~is_total_numb_of_rec_requested.
  ENDMETHOD.
ENDCLASS.
