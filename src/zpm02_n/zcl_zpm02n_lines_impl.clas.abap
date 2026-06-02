CLASS zcl_zpm02n_lines_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.
    TYPES: tt_data_output TYPE STANDARD TABLE OF zfa_i_zpm02n_lines.
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS get_data
      IMPORTING io_request TYPE REF TO if_rap_query_request
      EXPORTING et_table   TYPE tt_data_output
      .
ENDCLASS.



CLASS ZCL_ZPM02N_LINES_IMPL IMPLEMENTATION.


  METHOD get_data.
    DATA lt_data_output TYPE tt_data_output.

    " Filter bar
    DATA(ro_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = ro_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range ##NO_HANDLER.
    ENDTRY.

    IF lt_range IS NOT INITIAL.
      LOOP AT lt_range INTO DATA(ls_range).
        CASE ls_range-name.
          WHEN 'OBJECT_ID'.
            READ TABLE ls_range-range ASSIGNING FIELD-SYMBOL(<ls_any_range>) INDEX 1.
            IF sy-subrc = 0.
              DATA(lv_objectid) = <ls_any_range>-low.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    "-- get data from table ztb_exc_zpm02n
    SELECT *
    FROM ztb_exc_zpm02 AS exc_zpm02
    WHERE report_id = 'ZPM02'
    AND object_id = @lv_objectid
    INTO CORRESPONDING FIELDS OF TABLE @lt_data_output.

    et_table = lt_data_output.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lt_data_output TYPE tt_data_output.
    DATA: lt_linestop TYPE tt_data_output.

    CHECK io_request->is_data_requested( ).
    DATA(rt_requested_elements) = io_request->get_requested_elements( ).
    DATA(ro_aggregation) = io_request->get_aggregation( ).
    DATA(ro_filter) = io_request->get_filter(  ).

    DATA(rt_aggregated_elements) = ro_aggregation->get_aggregated_elements( ).
    DATA(rt_grouped_elements) = ro_aggregation->get_grouped_elements( ).

    " Top
    DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    " Skip
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).

    me->get_data(
      EXPORTING
        io_request = io_request
      IMPORTING
        et_table   = lt_data_output
    ).
    SORT lt_data_output BY companycode fiscalyear object_id.
    IF lines( lt_data_output ) > 0.
      LOOP AT lt_data_output INTO DATA(ls_row) FROM lv_skip + 1 TO lv_skip + lv_top.
        APPEND ls_row TO lt_linestop.
      ENDLOOP.
    ENDIF.

    io_response->set_data( lt_linestop ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data_output ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
