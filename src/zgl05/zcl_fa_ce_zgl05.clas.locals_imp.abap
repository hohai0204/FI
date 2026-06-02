CLASS zcl_currency_formatter DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_currency_config,
             currency TYPE waers,
             decimal_places TYPE i,
             thousand_sep TYPE c LENGTH 1,
             decimal_sep TYPE c LENGTH 1,
           END OF ty_currency_config.
    types: ty_dec2 type p length 16 DECIMALS 2.
    CLASS-METHODS:
      format_currency
        IMPORTING
          iv_amount TYPE ty_dec2
          iv_currency TYPE waers
          iv_is_negative_bracket type abap_bool DEFAULT abap_false
        RETURNING
          VALUE(rv_formatted) TYPE string,

      get_currency_config
        IMPORTING
          iv_currency TYPE waers
        RETURNING
          VALUE(rs_config) TYPE ty_currency_config.

  PRIVATE SECTION.
    CLASS-DATA: gt_currency_config TYPE TABLE OF ty_currency_config.
    CLASS-METHODS: initialize_config.
ENDCLASS.

CLASS zcl_currency_formatter IMPLEMENTATION.
  METHOD format_currency.
    DATA: lv_amount_str TYPE string,
          lv_integer_part TYPE string,
          lv_decimal_part TYPE string,
          lv_temp TYPE string,
          lv_len TYPE i,
          lv_pos TYPE i,
          lv_is_negative TYPE abap_bool,
          lv_abs_amount TYPE p DECIMALS 2,
          ls_config TYPE ty_currency_config.

    " Get currency configuration
    ls_config = get_currency_config( iv_currency ).


    " Check if amount is negative
    IF iv_amount < 0.
      lv_is_negative = abap_true.
      lv_abs_amount = abs( iv_amount ).
    ELSE.
      lv_is_negative = abap_false.
      lv_abs_amount = iv_amount.
    ENDIF.

    " Convert amount to string with proper decimal places
    IF ls_config-decimal_places = 0.
      " For VND - no decimal places
      lv_amount_str = |{ lv_abs_amount DECIMALS = 0 }|.
      CONDENSE lv_amount_str NO-GAPS.
    ELSE.
      " For USD - with decimal places
      lv_amount_str = |{ lv_abs_amount DECIMALS = 2 }|.
      CONDENSE lv_amount_str NO-GAPS.
    ENDIF.

    " Split integer and decimal parts
    IF ls_config-decimal_places > 0.
      SPLIT lv_amount_str AT ls_config-decimal_sep INTO lv_integer_part lv_decimal_part.
    ELSE.
      " Remove any decimal part for VND
      SPLIT lv_amount_str AT '.' INTO lv_integer_part lv_decimal_part.
    ENDIF.

    " Add thousand separators to integer part
    lv_len = strlen( lv_integer_part ).
    lv_pos = lv_len MOD 3.

    IF lv_pos > 0.
      rv_formatted = lv_integer_part+0(lv_pos).
      IF lv_len > lv_pos.
        rv_formatted = |{ rv_formatted }{ ls_config-thousand_sep }|.
      ENDIF.
    ENDIF.

    " Add remaining groups of 3 digits
    WHILE lv_pos < lv_len.
      IF lv_pos > 0 AND rv_formatted IS NOT INITIAL.
        lv_temp = lv_integer_part+lv_pos(3).
        rv_formatted = |{ rv_formatted }{ lv_temp }|.
      ELSE.
        lv_temp = lv_integer_part+lv_pos(3).
        rv_formatted = lv_temp.
      ENDIF.

      lv_pos = lv_pos + 3.
      IF lv_pos < lv_len.
        rv_formatted = |{ rv_formatted }{ ls_config-thousand_sep }|.
      ENDIF.
    ENDWHILE.

    " Add decimal part if needed
    IF ls_config-decimal_places > 0 AND lv_decimal_part IS NOT INITIAL.
      rv_formatted = |{ rv_formatted }{ ls_config-decimal_sep }{ lv_decimal_part }|.
    ENDIF.


    " Handle negative values based on parameter
    IF lv_is_negative = abap_true.
      IF iv_is_negative_bracket = abap_true.
        " Use parentheses for negative values
        rv_formatted = |({ rv_formatted })|.
      ELSE.
        " Use minus sign (default behavior)
        rv_formatted = |-{ rv_formatted }|.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_currency_config.
    " Initialize config if not done yet
    IF gt_currency_config IS INITIAL.
      initialize_config( ).
    ENDIF.

    " Find configuration for currency
    READ TABLE gt_currency_config INTO rs_config
      WITH KEY currency = iv_currency.

    " Default to USD format if not found
    IF sy-subrc <> 0.
      rs_config-currency = iv_currency.
      rs_config-decimal_places = 2.
      rs_config-thousand_sep = ','.
      rs_config-decimal_sep = '.'.
    ENDIF.
  ENDMETHOD.

  METHOD initialize_config.
    DATA: ls_config TYPE ty_currency_config.

    " VND Configuration
    ls_config-currency = 'VND'.
    ls_config-decimal_places = 0.
    ls_config-thousand_sep = ','.
    ls_config-decimal_sep = '.'.
    APPEND ls_config TO gt_currency_config.

    " USD Configuration
    ls_config-currency = 'USD'.
    ls_config-decimal_places = 2.
    ls_config-thousand_sep = ','.
    ls_config-decimal_sep = '.'.
    APPEND ls_config TO gt_currency_config.

    " EUR Configuration (bonus)
    ls_config-currency = 'EUR'.
    ls_config-decimal_places = 2.
    ls_config-thousand_sep = '.'.
    ls_config-decimal_sep = ','.
    APPEND ls_config TO gt_currency_config.
  ENDMETHOD.
ENDCLASS.
