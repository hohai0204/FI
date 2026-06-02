CLASS zcl_save_pdf_zgl03 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
"
  PUBLIC SECTION.
    METHODS save_pdf
      IMPORTING
        iv_objectid       TYPE ztb_zgl03_pdf-object_id
        iv_reportid       TYPE ztb_zgl03_pdf-report_id
        iv_pdf      TYPE ztb_zgl03_pdf-attachment.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SAVE_PDF_ZGL03 IMPLEMENTATION.


  METHOD save_pdf.

  data lv_date_after type datum.
        lv_date_after = syst-datum - 1.
       DELETE FROM ztb_zgl03_pdf WHERE create_date < @lv_date_after or ( create_date = @lv_date_after and create_time < @syst-uzeit ).
"insert new pdf file into ztb_zgl03_pdf table
    DATA(ls_data) = VALUE ztb_zgl03_pdf(
          object_id = iv_objectid
          report_id = iv_reportid
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
          mimetype = 'application/pdf'
          attachment = iv_pdf

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum

        ).
    INSERT ztb_zgl03_pdf FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_zgl03_pdf FROM @ls_data.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
