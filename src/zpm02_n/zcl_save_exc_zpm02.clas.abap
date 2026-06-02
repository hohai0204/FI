CLASS zcl_save_exc_zpm02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "-- structure item line PDF
    TYPES: BEGIN OF ty_lines,
             BEGIN OF items,
               companycode                TYPE string,
               fiscalyear                 TYPE string,
               object_id                  TYPE uuid,
               postingdate_fromto         TYPE string,
               glaccount                  TYPE string,
               balancetransactioncurrency TYPE waers,
               companycodecurrency        TYPE waers,

               "-- about supplier
               supplier                   TYPE string,
               suppliercode               TYPE string,
               suppliername               TYPE string,
               supplieraccountgroup       TYPE string,

               dauki_no_nt_fm             TYPE string,
               dauki_no_vn_fm             TYPE string,
               dauki_co_nt_fm             TYPE string,
               dauki_co_vn_fm             TYPE string,
               phatsinh_no_nt_fm          TYPE string,
               phatsinh_no_vn_fm          TYPE string,
               phatsinh_co_nt_fm          TYPE string,
               phatsinh_co_vn_fm          TYPE string,
               cuoiki_no_nt_fm            TYPE string,
               cuoiki_no_vn_fm            TYPE string,
               cuoiki_co_nt_fm            TYPE string,
               cuoiki_co_vn_fm            TYPE string,

               "-- exc
               dauki_no_nt                TYPE zde_amount,
               dauki_no_vn                TYPE zde_amount,
               dauki_co_nt                TYPE zde_amount,
               dauki_co_vn                TYPE zde_amount,
               phatsinh_no_nt             TYPE zde_amount,
               phatsinh_no_vn             TYPE zde_amount,
               phatsinh_co_nt             TYPE zde_amount,
               phatsinh_co_vn             TYPE zde_amount,
               cuoiki_no_nt               TYPE zde_amount,
               cuoiki_no_vn               TYPE zde_amount,
               cuoiki_co_nt               TYPE zde_amount,
               cuoiki_co_vn               TYPE zde_amount,
             END OF items,
           END OF ty_lines.
    TYPES tt_zpm02_lines TYPE STANDARD TABLE OF ty_lines WITH EMPTY KEY.
    METHODS save_exc_zpm02
      IMPORTING
        iv_objectid TYPE ztb_exc_zpm02-object_id
        iv_reportid TYPE ztb_exc_zpm02-report_id
        iv_item     TYPE tt_zpm02_lines.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SAVE_EXC_ZPM02 IMPLEMENTATION.


  METHOD save_exc_zpm02.
    DATA: lt_db    TYPE TABLE OF ztb_exc_zpm02,
          ls_db    TYPE ztb_exc_zpm02,
          ls_input TYPE ty_lines.

*    DELETE FROM ztb_exc_zpm02 WHERE report_id = 'ZPM02'.

    DATA: lv_date_after TYPE datum.
    lv_date_after = syst-datum - 1.
    DELETE FROM ztb_exc_zpm02 WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).

    LOOP AT iv_item INTO ls_input.
      CLEAR: ls_db.

      MOVE-CORRESPONDING ls_input-items TO ls_db.
      ls_db-supplier = |{ ls_db-supplier ALPHA = OUT }|.
      ls_db-client                   = sy-mandt.
      ls_db-object_id                = iv_objectid.
      ls_db-report_id                = iv_reportid.
      ls_db-create_date              = sy-datum.
      ls_db-create_time              = sy-uzeit.
      ls_db-created_by               = sy-uname.
      ls_db-created_at               = cl_abap_context_info=>get_system_time( ).

      APPEND ls_db TO lt_db.
      CLEAR: ls_db.

    ENDLOOP.

    INSERT ztb_exc_zpm02 FROM TABLE @lt_db.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_exc_zpm02 FROM TABLE @lt_db.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
