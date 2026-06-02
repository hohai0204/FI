CLASS lhc_zr_zgl02_account DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_zgl02_account RESULT result.

    METHODS createpdf FOR MODIFY
      IMPORTING keys FOR ACTION zgl02~createpdf RESULT result.

ENDCLASS.

CLASS lhc_zr_zgl02_account IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD createpdf.

    READ ENTITIES OF zr_zgl02_account IN LOCAL MODE
      ENTITY zgl02
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_selected).

    SELECT data~*
      FROM  zr_zgl02_account AS data
      INNER JOIN @lt_selected AS selected ON selected~glaccount = data~glaccount
                                         AND selected~companycode = data~companycode
                                         AND selected~fiscalyear = data~fiscalyear
      ORDER BY data~glaccount
      INTO TABLE @DATA(lt_data).


* Process Total line

* Process Adobe Form


  ENDMETHOD.

ENDCLASS.
