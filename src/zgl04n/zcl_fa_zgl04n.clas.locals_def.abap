*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

CLASS lcl_fa_zgl04n_pdf DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS save_pdf
      IMPORTING
        iv_objectid TYPE zr_fa_zgl04n-objectid
        iv_reportid TYPE zr_fa_zgl04n-reportid
        iv_key      TYPE ztb_zgl04n_pdf-sndkey OPTIONAL
        iv_pdf      TYPE zr_fa_zgl04n-attachment.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
