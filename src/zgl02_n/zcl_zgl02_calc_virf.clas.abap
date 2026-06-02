CLASS zcl_zgl02_calc_virf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZGL02_CALC_VIRF IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_data TYPE STANDARD TABLE OF zc_zgl02_account WITH DEFAULT KEY,
          lv_calc TYPE zde_hsl.

    lt_data = CORRESPONDING #( it_original_data ).


* Detail _ GL Account 10
    SELECT DISTINCT
        acdoca~amountincompanycodecurrency AS amount,
        acdoca~debitcreditcode,
        acdoca~fiscalyear,
        acdoca~fiscalperiod,
        acdoca~glaccount,
        acdoca~sourceledger,
        acdoca~companycode
    FROM i_glaccountlineitemrawdata AS acdoca
    INNER JOIN @lt_data AS data ON data~companycode = acdoca~companycode
                               AND data~sourceledger = acdoca~sourceledger
                               AND data~glaccount = acdoca~glaccount
                               AND data~fiscalyear = acdoca~fiscalyear
    INTO TABLE @DATA(lt_acdoca).


* Level 1 _ GL Account 3
    SELECT DISTINCT
        acdoca~amountincompanycodecurrency AS amount,
        acdoca~debitcreditcode,
        acdoca~fiscalyear,
        acdoca~fiscalperiod,
        data~glaccount,
        acdoca~sourceledger,
        acdoca~companycode
    FROM i_glaccountlineitemrawdata AS acdoca
    INNER JOIN @lt_data AS data ON data~companycode = acdoca~companycode
                               AND data~sourceledger = acdoca~sourceledger
                               AND data~glaccount = substring( acdoca~glaccount, 1, 3 )
                               AND data~fiscalyear = acdoca~fiscalyear
    APPENDING TABLE @lt_acdoca.


* Level 2 _ GL Account 4
    SELECT DISTINCT
        acdoca~amountincompanycodecurrency AS amount,
        acdoca~debitcreditcode,
        acdoca~fiscalyear,
        acdoca~fiscalperiod,
        data~glaccount,
        acdoca~sourceledger,
        acdoca~companycode
    FROM i_glaccountlineitemrawdata AS acdoca
    INNER JOIN @lt_data AS data ON data~companycode = acdoca~companycode
                               AND data~sourceledger = acdoca~sourceledger
                               AND data~glaccount = substring( acdoca~glaccount, 1, 4 )
                               AND data~fiscalyear = acdoca~fiscalyear
    APPENDING TABLE @lt_acdoca.



    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>) .

      <fs_data>-daukyno = REDUCE #(
          INIT x TYPE zde_hsl
          FOR ls_acdoca IN lt_acdoca
          WHERE ( fiscalperiod < <fs_data>-period AND debitcreditcode = 'S' AND glaccount = <fs_data>-glaccount
              AND companycode = <fs_data>-companycode AND fiscalyear = <fs_data>-fiscalyear AND sourceledger = <fs_data>-sourceledger )
          NEXT x += ls_acdoca-amount ).

      <fs_data>-daukyco = REDUCE #(
          INIT x TYPE zde_hsl
          FOR ls_acdoca IN lt_acdoca
          WHERE ( fiscalperiod < <fs_data>-period AND debitcreditcode = 'H' AND glaccount = <fs_data>-glaccount
              AND companycode = <fs_data>-companycode AND fiscalyear = <fs_data>-fiscalyear AND sourceledger = <fs_data>-sourceledger )
          NEXT x += ls_acdoca-amount * -1 ) .

      <fs_data>-trongkyno = REDUCE #(
          INIT x TYPE zde_hsl
          FOR ls_acdoca IN lt_acdoca
          WHERE ( fiscalperiod = <fs_data>-period AND debitcreditcode = 'S' AND glaccount = <fs_data>-glaccount
              AND companycode = <fs_data>-companycode AND fiscalyear = <fs_data>-fiscalyear AND sourceledger = <fs_data>-sourceledger )
          NEXT x += ls_acdoca-amount ) .

      <fs_data>-trongkyco = REDUCE #(
         INIT x TYPE zde_hsl
         FOR ls_acdoca IN lt_acdoca
         WHERE ( fiscalperiod = <fs_data>-period AND debitcreditcode = 'H' AND glaccount = <fs_data>-glaccount
             AND companycode = <fs_data>-companycode AND fiscalyear = <fs_data>-fiscalyear AND sourceledger = <fs_data>-sourceledger )
         NEXT x += ls_acdoca-amount * -1 ) .

      lv_calc = <fs_data>-daukyno - <fs_data>-daukyco + <fs_data>-trongkyno - <fs_data>-trongkyco.

      IF lv_calc > 0.
        <fs_data>-CuoikyNo = lv_calc.
      ELSE.
        <fs_data>-CuoikyCo = lv_calc * -1.
      ENDIF.

      CLEAR lv_calc.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
