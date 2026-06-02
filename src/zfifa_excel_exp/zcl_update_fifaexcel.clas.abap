CLASS zcl_update_fifaexcel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  methods update_fifaexcel
      IMPORTING
         ls_update_fifaexcel type ztb_fifa_excel.

        methods delete_fifaexcel
        IMPORTING
         lv_date type sy-datum
         iv_report_id type zde_reptext.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_UPDATE_FIFAEXCEL IMPLEMENTATION.


method update_fifaexcel.

   INSERT ztb_fifa_excel FROM @ls_update_fifaexcel.
    IF sy-subrc <> 0.
      " Có thể update nếu đã tồn tại
      UPDATE ztb_fifa_excel FROM @ls_update_fifaexcel.
    ENDIF.
   endmethod.


   method delete_fifaexcel.
       DELETE FROM ztb_fifa_excel WHERE  report_id = @iv_report_id and  create_date < @lv_date OR ( create_date = @lv_date AND create_time < @syst-uzeit ).

   enDMETHOD.
ENDCLASS.
