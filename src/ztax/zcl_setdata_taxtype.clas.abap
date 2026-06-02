CLASS zcl_setdata_taxtype DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SETDATA_TAXTYPE IMPLEMENTATION.


METHOD if_rap_query_provider~select.
DATA ls_values TYPE  ZFI_I_TAXTYPE_VIEW.
    DATA lt_values TYPE STANDARD TABLE OF ZFI_I_TAXTYPE_VIEW WITH EMPTY KEY.
    DATA lt_values_out TYPE STANDARD TABLE OF ZFI_I_TAXTYPE_VIEW WITH EMPTY KEY.
    ls_values-tax_type = 'A'.
    ls_values-taxtype_desc = 'BKTGTGT Đầu vào'.
    APPEND ls_values TO lt_values.
     ls_values-tax_type = 'B'.
    ls_values-taxtype_desc = 'BKTGTGT Đầu ra'.
      APPEND ls_values TO lt_values.
       io_response->set_total_number_of_records( lines( lt_values ) ).
    io_response->set_data( lt_values ).
    io_request->get_sort_elements( ).
    io_request->get_paging( ).
ENDMETHOD.
ENDCLASS.
