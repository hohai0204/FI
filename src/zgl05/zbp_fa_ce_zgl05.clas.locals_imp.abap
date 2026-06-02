CLASS lhc_zfa_ce_zgl05 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zgl05 RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zgl05.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zgl05.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zgl05.

    METHODS read FOR READ
      IMPORTING keys FOR READ zgl05 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zgl05.
    METHODS createpdf FOR MODIFY
      IMPORTING keys FOR ACTION zgl05~createpdf.

ENDCLASS.

CLASS lhc_zfa_ce_zgl05 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    READ ENTITIES OF zfa_ce_zgl05 IN LOCAL MODE
    ENTITY zgl05
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD createpdf.
    READ ENTITIES OF zfa_ce_zgl05 IN LOCAL MODE
    ENTITY zgl05
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
     text = 'test' ) ) TO reported-zgl05.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zfa_ce_zgl05 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zfa_ce_zgl05 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
