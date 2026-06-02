*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_fa_zgl04n_pdf IMPLEMENTATION.
  METHOD save_pdf.

    DATA lv_date_after TYPE datum.
    lv_date_after = syst-datum - 1.
    DELETE FROM ztb_zgl04n_pdf WHERE create_date < @lv_date_after OR ( create_date = @lv_date_after AND create_time < @syst-uzeit ).

    DATA(ls_data) = VALUE ztb_zgl04n_pdf(
          objectid = iv_objectid
          reportid = iv_reportid
          sndkey   = iv_key
          filename = |{  cl_abap_context_info=>get_system_date( ) }_{ cl_abap_context_info=>get_system_time( ) }.pdf|
          mimetype = 'application/pdf'
          attachment = iv_pdf

           " Metadata fields
    create_time            = syst-uzeit
    create_date            = syst-datum
        ).
    INSERT ztb_zgl04n_pdf FROM @ls_data.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_zgl04n_pdf FROM @ls_data.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
