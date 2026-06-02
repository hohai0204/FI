CLASS zcl_save_pdf_zrm01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS save_pdf
      IMPORTING
        iv_objectid       TYPE ztb_zrm01_pdf-object_id
        iv_reportid       TYPE ztb_zrm01_pdf-report_id
        iv_pdf      TYPE ztb_zrm01_pdf-attachment
        iv_ex       TYPE ztb_zrm01_pdf-attachment_exc.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SAVE_PDF_ZRM01 IMPLEMENTATION.


  METHOD save_pdf.
data lv_date_after type datum.
        lv_date_after  = syst-datum - 1.
       DELETE FROM ztb_zrm01_pdf WHERE create_date < @lv_date_after or ( create_date = @lv_date_after and create_time < @syst-uzeit ).

    DATA(ls_data) = VALUE ztb_zrm01_pdf(
          object_id = iv_objectid
          report_id = iv_reportid
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
          mimetype = 'application/pdf'
          attachment = iv_pdf

          filename_exc = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.xlsx|
          attachment_exc = iv_ex
          mimetype_exc = 'application/vnd.ms-excel'

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum

        ).


    INSERT ztb_zrm01_pdf FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_zrm01_pdf FROM @ls_data.
    ENDIF.




  ENDMETHOD.
ENDCLASS.
