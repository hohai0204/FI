CLASS zcl_save_pdf_zpm02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS save_pdf_zpm02
      IMPORTING
        iv_objectid TYPE ztb_pdf_zpm02-object_id
        iv_reportid TYPE ztb_pdf_zpm02-report_id
        iv_pdf      TYPE ztb_pdf_zpm02-attachment.
            METHODS save_excel_zpm02
      IMPORTING
        iv_objectid TYPE ztb_pdf_zpm02-object_id
        iv_reportid TYPE ztb_pdf_zpm02-report_id
        iv_pdf      TYPE ztb_pdf_zpm02-attachment.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SAVE_PDF_ZPM02 IMPLEMENTATION.


  METHOD save_pdf_zpm02.
    DATA: lv_date_after TYPE datum.
    lv_date_after = syst-datum - 1.
    DELETE FROM ztb_pdf_zpm02 WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).

    DATA(ls_data) = VALUE ztb_pdf_zpm02(
          object_id = iv_objectid
          report_id = iv_reportid
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
          mimetype = 'application/pdf'
          attachment = iv_pdf

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum

        ).
    INSERT ztb_pdf_zpm02 FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_pdf_zpm02 FROM @ls_data.
    ENDIF.
  ENDMETHOD.


   METHOD save_excel_zpm02.
    DATA: lv_date_after TYPE datum.
    lv_date_after = syst-datum - 1.
    DELETE FROM ztb_fifa_excel WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).

    DATA(ls_data) = VALUE ztb_fifa_excel(
          object_id = iv_objectid
          report_id = iv_reportid
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.xlsx|
          mimetype =  'application/vnd.ms-excel'
          attachment = iv_pdf

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum

        ).
    INSERT ztb_fifa_excel FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_fifa_excel FROM @ls_data.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
