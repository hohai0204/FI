CLASS zcl_virtual_zpm03_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRTUAL_ZPM03_TEST IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
   DATA: lt_data_i TYPE STANDARD TABLE OF zfa_i_zpm03_n WITH DEFAULT KEY. "

    lt_data_i = CORRESPONDING #( it_original_data ).
    DATA: lv_numc TYPE int1.
     LOOP AT lt_data_i ASSIGNING FIELD-SYMBOL(<LFS_test>).
      lv_numc += 1.
*      <LFS_test>-testdec = lv_numc * 10.
      ENDLOOP.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
