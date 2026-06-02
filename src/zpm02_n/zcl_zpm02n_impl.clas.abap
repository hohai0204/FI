CLASS zcl_zpm02n_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.

    TYPES: BEGIN OF ty_data_output,
             companycode        TYPE string,
             fiscalyear         TYPE string,
             postingdate_fromto TYPE string,
             object_id          TYPE uuid,

             attachment         TYPE zattachment,
             filename           TYPE c LENGTH 128,
             mimetype           TYPE c LENGTH 128,
             attachment_exc     TYPE zattachment,
             filename_exc       TYPE c LENGTH 128,
             mimetype_exc       TYPE c LENGTH 128,
           END OF ty_data_output.

    TYPES: tt_data_output TYPE STANDARD TABLE OF ty_data_output.
    "----------------------------------"
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
               zlevel                     TYPE char03,
             END OF items,
           END OF ty_lines.

    "-- table type item line PDF
    TYPES tt_zpm02_lines TYPE STANDARD TABLE OF ty_lines WITH EMPTY KEY.

    "-- structure item line Excel
    TYPES: BEGIN OF ty_lines_exc,
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
             zlevel                     TYPE char03,
           END OF ty_lines_exc.

    TYPES tt_zpm02_lines_exc TYPE STANDARD TABLE OF ty_lines_exc WITH EMPTY KEY.

    "-- structure header PDF
    TYPES: BEGIN OF ty_data,
             companycode          TYPE string,
             fiscalyear           TYPE string,
             postingdate_fromto   TYPE string,
             glaccount_1line      TYPE string,
             currentdate          TYPE string,

             "-- about company
             compname             TYPE string,
             compadd              TYPE string,
             compmst              TYPE string,

             nguoilap             TYPE string,
             ketoan               TYPE string,
             giamdoc              TYPE string,
             object_id            TYPE uuid,

             "-- items
             items                TYPE tt_zpm02_lines,
             zlogo                TYPE string,

             "-- items_excel
             itemsexc             TYPE tt_zpm02_lines_exc,

             "-- sum total
             total_dauki_no_nt    TYPE string,
             total_dauki_no_vn    TYPE string,
             total_dauki_co_nt    TYPE string,
             total_dauki_co_vn    TYPE string,

             total_phatsinh_no_nt TYPE string,
             total_phatsinh_no_vn TYPE string,
             total_phatsinh_co_nt TYPE string,
             total_phatsinh_co_vn TYPE string,

             total_cuoiki_no_nt   TYPE string,
             total_cuoiki_no_vn   TYPE string,
             total_cuoiki_co_nt   TYPE string,
             total_cuoiki_co_vn   TYPE string,

             "title excel
             nguoilap_tt          TYPE string,
             ketoan_tt            TYPE string,
             giamdoc_tt           TYPE string,
             report_name          TYPE string,
             mancc_tt             TYPE string,
             tenncc_tt            TYPE string,
             taikhoan_tt          TYPE string,
             dvt_tt               TYPE string,
             nt_tt                TYPE string,
             opvnd_tt             TYPE string,
             psnt_tt              TYPE string,
             psvnd_tt             TYPE string,
             clnt_tt              TYPE string,
             clvnd_tt             TYPE string,
             nnt_tt               TYPE string,
             cnt_tt               TYPE string,
             nvnd_tt              TYPE string,
             cvnd_tt              TYPE string,
             tong_tt              TYPE string,
             t1                   TYPE string,
             t2                   TYPE string,
             t3                   TYPE string,
           END OF ty_data.
    TYPES: BEGIN OF ty_datapdf,
             companycode          TYPE string,
             fiscalyear           TYPE string,
             postingdate_fromto   TYPE string,
             glaccount_1line      TYPE string,
             currentdate          TYPE string,

             "-- about company
             compname             TYPE string,
             compadd              TYPE string,
             compmst              TYPE string,

             nguoilap             TYPE string,
             ketoan               TYPE string,
             giamdoc              TYPE string,
             object_id            TYPE uuid,

             "-- items
             items                TYPE tt_zpm02_lines,
             zlogo                TYPE string,
             "-- sum total
             total_dauki_no_nt    TYPE string,
             total_dauki_no_vn    TYPE string,
             total_dauki_co_nt    TYPE string,
             total_dauki_co_vn    TYPE string,

             total_phatsinh_no_nt TYPE string,
             total_phatsinh_no_vn TYPE string,
             total_phatsinh_co_nt TYPE string,
             total_phatsinh_co_vn TYPE string,

             total_cuoiki_no_nt   TYPE string,
             total_cuoiki_no_vn   TYPE string,
             total_cuoiki_co_nt   TYPE string,
             total_cuoiki_co_vn   TYPE string,

             "title excel
             nguoilap_tt          TYPE string,
             ketoan_tt            TYPE string,
             giamdoc_tt           TYPE string,
             report_name          TYPE string,
             mancc_tt             TYPE string,
             tenncc_tt            TYPE string,
             taikhoan_tt          TYPE string,
             dvt_tt               TYPE string,
             nt_tt                TYPE string,
             opvnd_tt             TYPE string,
             psnt_tt              TYPE string,
             psvnd_tt             TYPE string,
             clnt_tt              TYPE string,
             clvnd_tt             TYPE string,
             nnt_tt               TYPE string,
             cnt_tt               TYPE string,
             nvnd_tt              TYPE string,
             cvnd_tt              TYPE string,
             tong_tt              TYPE string,
             t1                   TYPE string,
             t2                   TYPE string,
             t3                   TYPE string,
           END OF ty_datapdf.

    "-- form pdf
    TYPES: BEGIN OF ty_form,
             BEGIN OF form,
               headers TYPE STANDARD TABLE OF ty_datapdf WITH EMPTY KEY,
               BEGIN OF items,
                 item TYPE tt_zpm02_lines,
               END OF items,
             END OF form,
           END OF ty_form.


    TYPES: ty_curr TYPE p LENGTH 13 DECIMALS 2.

    CLASS-METHODS format_amount
      IMPORTING
        i_amount        TYPE ty_curr
        i_currency      TYPE waers
      RETURNING
        VALUE(r_amount) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS get_data
      IMPORTING io_request TYPE REF TO if_rap_query_request
      EXPORTING et_table   TYPE tt_data_output
      .
    METHODS render_form
      IMPORTING ia_abap       TYPE any
      RETURNING VALUE(rv_pdf) TYPE xstring.
    .
    METHODS abap2xml
      IMPORTING ia_abap            TYPE any
      RETURNING VALUE(rv_xml_data) TYPE string
      .
    METHODS dynamic_data
      IMPORTING i_data         TYPE any
                i_name_mapping TYPE /ui2/cl_json=>name_mappings OPTIONAL
                i_kind_type    TYPE c DEFAULT cl_abap_typedescr=>typekind_struct2
      CHANGING  co_writer      TYPE REF TO if_sxml_writer OPTIONAL
      .
ENDCLASS.



CLASS ZCL_ZPM02N_IMPL IMPLEMENTATION.


  METHOD abap2xml.
    DATA(writer) = CAST if_sxml_writer( cl_sxml_string_writer=>create( type     = if_sxml=>co_xt_xml10
                                                                               encoding = 'UTF-8' ) ).

    dynamic_data( EXPORTING i_data         = ia_abap
                            i_kind_type    = cl_abap_typedescr=>typekind_struct2
                            i_name_mapping = zcl_einvoice=>name_mappings_request-preview_invoice
                  CHANGING  co_writer      = writer ).

    DATA(xml) = CAST cl_sxml_string_writer( writer )->get_output(  ).
    DATA(lv_xml) = xco_cp=>xstring( xml )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    REPLACE '<?xml version="1.0" encoding="utf-8"?>' IN lv_xml WITH ''.

    RETURN lv_xml.
  ENDMETHOD.


  METHOD dynamic_data.
    DATA: lo_table_descr      TYPE REF TO cl_abap_tabledescr,
          lo_struct_descr     TYPE REF TO cl_abap_structdescr,
          lo_struct_descr1    TYPE REF TO cl_abap_structdescr,
          lo_line_type        TYPE REF TO cl_abap_typedescr,
          lt_components       TYPE cl_abap_structdescr=>component_table,
          lt_components_child TYPE cl_abap_structdescr=>component_table,
          ls_component        TYPE cl_abap_structdescr=>component,
          lo_data_descr       TYPE REF TO cl_abap_datadescr,
          lv_abap_type_kind   TYPE abap_typekind.

    DATA: lv_field_name_mapping TYPE string,
          lv_row_index          TYPE i.
    FIELD-SYMBOLS: <lv_field> TYPE any.

    TRY.

        IF i_kind_type = cl_abap_typedescr=>typekind_table OR i_kind_type = cl_abap_typedescr=>kind_table.
          lo_table_descr ?= cl_abap_typedescr=>describe_by_data( i_data ).
          lo_line_type = lo_table_descr->get_table_line_type( ).
          lo_struct_descr ?= lo_line_type.
        ELSE.

          lo_struct_descr ?= cl_abap_typedescr=>describe_by_data( i_data ).
        ENDIF.


        lt_components = lo_struct_descr->get_components( ).
        LOOP AT lt_components INTO ls_component.
          lv_row_index = sy-tabix.

          CASE i_kind_type.
            WHEN cl_abap_typedescr=>typekind_table OR cl_abap_typedescr=>kind_table.
              LOOP AT i_data ASSIGNING FIELD-SYMBOL(<lfs_struct>).
                dynamic_data(
                  EXPORTING
                    i_data       = <lfs_struct>
                  i_name_mapping = i_name_mapping
                    i_kind_type  = cl_abap_typedescr=>typekind_struct2
                    CHANGING co_writer = co_writer
                ).
              ENDLOOP.

          ENDCASE.

          CHECK i_kind_type <> cl_abap_typedescr=>typekind_table AND
                i_kind_type <> cl_abap_typedescr=>kind_table.


          IF ls_component-as_include = abap_true.
            lo_struct_descr1 ?= ls_component-type.
*            APPEND LINES OF lo_struct_descr1->get_components( ) TO lt_components.
            lv_row_index += 1.
            INSERT LINES OF  lo_struct_descr1->get_components( ) INTO lt_components INDEX lv_row_index.
            CONTINUE.
          ENDIF.

          CHECK ls_component-name IS NOT INITIAL.
          "lv_field_name_mapping = i_name_mapping[ abap = to_lower( ls_component-name ) ]-json.
          lv_field_name_mapping = ls_component-name.
          co_writer->open_element( name = lv_field_name_mapping ).

          ASSIGN COMPONENT ls_component-name OF STRUCTURE i_data TO <lv_field>.
          CHECK <lv_field> IS ASSIGNED.

          CASE ls_component-type->type_kind.

            WHEN cl_abap_typedescr=>typekind_struct1 OR cl_abap_typedescr=>typekind_struct2 OR
            cl_abap_typedescr=>typekind_table OR cl_abap_typedescr=>kind_table.

              dynamic_data( EXPORTING i_data         = <lv_field>
                                      i_name_mapping = i_name_mapping
                                      i_kind_type    = ls_component-type->type_kind
                            CHANGING  co_writer      = co_writer ).

            WHEN cl_abap_typedescr=>typekind_string
                OR cl_abap_typedescr=>typekind_char
                OR cl_abap_typedescr=>typekind_num
                OR cl_abap_typedescr=>typekind_int
                OR cl_abap_typedescr=>typekind_int1
                OR cl_abap_typedescr=>typekind_int2
                OR cl_abap_typedescr=>typekind_int8.
              co_writer->write_value( condense( <lv_field> ) ).

          ENDCASE.


          co_writer->close_element( ).
        ENDLOOP.


      CATCH cx_sxml_state_error INTO DATA(lx_sxml_error).
        DATA(lv_error_message) = lx_sxml_error->get_text( ).

      CATCH cx_sxml_name_error INTO DATA(lx_sxml_name_error).
        DATA(lv_error_message_1) = lx_sxml_name_error->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_data.
    DATA lt_data_output TYPE tt_data_output.

    "------------------------------------ Begin: Màn hình tham số nhập  ------------------------------------"
    " Top
    DATA(lv_top) = io_request->get_paging( )->get_page_size( ).
    IF lv_top < 0.
      lv_top = 1.
    ENDIF.

    " Skip
    DATA(lv_skip) = io_request->get_paging( )->get_offset( ).

    " Sort
    DATA(lt_sort) = io_request->get_sort_elements( ).
    DATA lv_orderby TYPE string VALUE `COMPANYCODE`.
    IF lt_sort IS NOT INITIAL.
      " lv_orderby = |GLACCOUNT|.
      lv_orderby = REDUCE #( INIT s TYPE string
                             FOR ls_sort IN lt_sort
                             NEXT s &&= |{ ls_sort-element_name } { COND #( WHEN ls_sort-descending = abap_true
                                                                            THEN 'DESCENDING' ) }, | ).
      REPLACE ALL OCCURRENCES OF PCRE `\s*,\s*$` IN lv_orderby WITH space.
    ENDIF.

    " Filter bar
    DATA(ro_filter) = io_request->get_filter(  ).
    TRY.
        DATA(lt_range) = ro_filter->get_as_ranges(  ).
      CATCH cx_rap_query_filter_no_range ##NO_HANDLER.
    ENDTRY.

    DATA lr_supplier_range TYPE RANGE OF lifnr.
    IF lt_range IS NOT INITIAL.
      LOOP AT lt_range INTO DATA(ls_range).
        CASE ls_range-name.
          WHEN 'COMPANYCODE'.
            DATA(lr_compcode_range) = ls_range-range.
          WHEN 'SUPPLIERACCOUNTGROUP'.
            DATA(lr_supaccgrp_range) = ls_range-range.
          WHEN 'SUPPLIER'.
            LOOP AT ls_range-range ASSIGNING FIELD-SYMBOL(<ls_any_range>).
              APPEND VALUE #( sign = <ls_any_range>-sign
                              option = <ls_any_range>-option
                              low = |{ <ls_any_range>-low ALPHA = IN }|
                              high = |{ <ls_any_range>-high ALPHA = IN }| ) TO lr_supplier_range.
            ENDLOOP.
          WHEN 'GLACCOUNT'.
            DATA(lr_glaccount_range) = ls_range-range.
          WHEN 'BALANCETRANSACTIONCURRENCY'.
            DATA(lr_cuki_range) = ls_range-range.
          WHEN 'POSTINGDATE'.
            DATA(lr_postingdate_range) = ls_range-range.
          WHEN 'FISCALYEAR'.
            DATA(lr_fiscalyear_range) = ls_range-range.
          WHEN 'NGUOILAP'.
            DATA(lr_nguoilap) = ls_range-range.
          WHEN 'KETOAN'.
            DATA(lr_ketoan) = ls_range-range.
          WHEN 'GIAMDOC'.
            DATA(lr_giamdoc) = ls_range-range.
          WHEN 'IS_CLRDOC'.
            IF ls_range-range IS NOT INITIAL.
              DATA(l_isclrdoc) = ls_range-range[ 1 ]-low.
            ENDIF.

            "-- pdf
          WHEN 'OBJECT_ID'.
            DATA(lr_object_id) = ls_range-range.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    "-- Check pdf ? --"
    IF lr_object_id IS NOT INITIAL.
      SELECT
      *
      FROM ztb_pdf_zpm02
      WHERE object_id IN @lr_object_id
      ORDER BY object_id
      INTO TABLE @DATA(lt_pdf).

      SELECT
        *
        FROM ztb_fifa_excel
        WHERE object_id IN @lr_object_id
        AND report_id = 'ZPM02'
        ORDER BY object_id
        INTO TABLE @DATA(lt_excel).
    ENDIF.

    DATA(lv_currdate) = cl_abap_context_info=>get_system_date(  ).
    DATA(lv_current_date) = |Ngày { lv_currdate+6(2) } Tháng { lv_currdate+4(2) } Năm { lv_currdate+0(4) }|.


    " Begin: Fill data in to itab ouput
    IF lt_pdf IS INITIAL.
      "-- Get parameter input
      DATA: lv_postingdate_from_fm TYPE string,
            lv_postingdate_to_fm   TYPE string,
            lv_date_from_fm        TYPE string,
            lv_date_to_fm          TYPE string.

      READ TABLE lr_postingdate_range INTO DATA(ls_date) INDEX 1.
      IF sy-subrc = 0.
        DATA(lv_prev_postingdate) =  ls_date-low. "|{ ls_date-low+0(4) }-{ ls_date-low+4(2) }-{ ls_date-low+6(2) }|.
        DATA(lv_next_postingdate) =  ls_date-high. "|{ ls_date-high+0(4) }-{ ls_date-high+4(2) }-{ ls_date-high+6(2) }|.
      ENDIF.

      IF lv_prev_postingdate IS NOT INITIAL.
        lv_postingdate_from_fm = |{ lv_prev_postingdate+6(2) }-{ lv_prev_postingdate+4(2) }-{ lv_prev_postingdate+0(4) }|.
        lv_date_from_fm        = |{ lv_prev_postingdate+6(2) }/{ lv_prev_postingdate+4(2) }/{ lv_prev_postingdate+0(4) }|.
      ELSE.
      ENDIF.

      IF lv_next_postingdate IS NOT INITIAL.
        lv_postingdate_to_fm = |{ lv_next_postingdate+6(2) }-{ lv_next_postingdate+4(2) }-{ lv_next_postingdate+0(4) }|.
        lv_date_to_fm        = |{ lv_next_postingdate+6(2) }/{ lv_next_postingdate+4(2) }/{ lv_next_postingdate+0(4) }|.
      ELSE.
      ENDIF.

      LOOP AT lr_cuki_range ASSIGNING FIELD-SYMBOL(<lfs_cuki_r>).
        TRANSLATE <lfs_cuki_r>-low TO UPPER CASE.
        TRANSLATE <lfs_cuki_r>-high TO UPPER CASE.
      ENDLOOP.
      "------------------------------------ End: Màn hình tham số nhập  ------------------------------------"

      "------------------------------------ Begin: Get data processing ------------------------------------"
      " Begin: include TOP
      DATA: lt_data TYPE TABLE OF ty_data,
            ls_data TYPE ty_data.

      DATA: lt_lines TYPE TABLE OF ty_lines,
            ls_lines TYPE ty_lines.

      DATA:  lt_lines_exc TYPE TABLE OF ty_lines_exc.

      DATA: lt_header TYPE TABLE OF zfa_i_zpm02n,
            ls_header TYPE zfa_i_zpm02n.
      " End: include TOP

      " Begin: Processing data from CDS
      "-----------------------------------------------"
      "-- Tài khoản
      SELECT view_entity~companycode,
        view_entity~compname,
        view_entity~compadd,
        view_entity~compmst,
        view_entity~ledger,

        view_entity~supplieraccountgroup,
        view_entity~fiscalyear,
        view_entity~supplier,
        view_entity~suppliername,
        view_entity~ismarkedforarchiving,

        journalentryitem~glaccount,
        view_entity~glaccountlongname,
         view_entity~accountingdocumenttype "24.05.2026 TrucTT19 add
      FROM zfa_i_zpm02n_view AS view_entity
      INNER JOIN i_journalentryitem AS journalentryitem ON view_entity~companycode = journalentryitem~companycode
                                                       AND view_entity~fiscalyear = journalentryitem~fiscalyear
                                                       AND view_entity~glaccount = journalentryitem~glaccount
                                                       AND journalentryitem~ledger               =  view_entity~ledger
                                                       AND journalentryitem~supplier               =  view_entity~supplier
      WHERE journalentryitem~balancetransactioncurrency IN @lr_cuki_range
        AND journalentryitem~postingdate IN @lr_postingdate_range
        AND view_entity~companycode IN @lr_compcode_range
        AND view_entity~fiscalyear IN @lr_fiscalyear_range
        AND view_entity~supplieraccountgroup IN @lr_supaccgrp_range
        AND view_entity~glaccount IN @lr_glaccount_range
        AND view_entity~supplier IN @lr_supplier_range
        AND view_entity~ismarkedforarchiving IS INITIAL
      GROUP BY view_entity~companycode,view_entity~fiscalyear,
               view_entity~compname,
               view_entity~compadd,
               view_entity~compmst,
               view_entity~ledger,
               view_entity~supplier,
               view_entity~supplieraccountgroup,
               view_entity~suppliername,
               view_entity~ismarkedforarchiving,
               journalentryitem~glaccount,
               view_entity~glaccountlongname,
               view_entity~accountingdocumenttype "24.05.2026 TrucTT19 add
      INTO TABLE @DATA(lt_about_glaccount).

      SELECT view_entity~companycode,
          view_entity~compname,
          view_entity~compadd,
          view_entity~compmst,
          view_entity~ledger,

          view_entity~supplieraccountgroup,
           view_entity~fiscalyear,
          view_entity~supplier,
          view_entity~suppliername,
          view_entity~ismarkedforarchiving,

          journalentryitem~glaccount,
          view_entity~glaccountlongname,
          view_entity~accountingdocumenttype "24.05.2026 TrucTT19 add
        FROM zfa_i_zpm02n_view AS view_entity
        INNER JOIN i_journalentryitem AS journalentryitem ON view_entity~companycode = journalentryitem~companycode
                                                        "AND view_entity~fiscalyear = journalentryitem~fiscalyear
                                                         AND view_entity~glaccount = journalentryitem~glaccount
                                                         AND journalentryitem~ledger               =  view_entity~ledger
                                                         AND journalentryitem~supplier               =  view_entity~supplier
        WHERE journalentryitem~balancetransactioncurrency IN @lr_cuki_range
          AND journalentryitem~postingdate < @lv_prev_postingdate
          AND view_entity~companycode IN @lr_compcode_range
*          AND view_entity~fiscalyear IN @lr_fiscalyear_range
          AND view_entity~supplieraccountgroup IN @lr_supaccgrp_range
          AND view_entity~glaccount IN @lr_glaccount_range
          AND view_entity~supplier IN @lr_supplier_range
          AND view_entity~ismarkedforarchiving IS INITIAL
        GROUP BY view_entity~companycode,view_entity~fiscalyear,
                 view_entity~compname,
                 view_entity~compadd,
                 view_entity~compmst,
                 view_entity~ledger,
                 view_entity~supplier,
                 view_entity~supplieraccountgroup,
                 view_entity~ismarkedforarchiving,
                 view_entity~suppliername,
                 journalentryitem~glaccount,
                 view_entity~glaccountlongname,
                 view_entity~accountingdocumenttype "24.05.2026 TrucTT19 add
        APPENDING TABLE @lt_about_glaccount.

      IF lt_about_glaccount IS INITIAL.
        EXIT.
      ENDIF.

      IF l_isclrdoc = abap_false.
        DELETE lt_about_glaccount WHERE accountingdocumenttype = 'CL'.
      ENDIF.

      "-- GLACCOUNT 1 LINE --"
      DATA lv_glacc_grp TYPE string.
      SORT lt_about_glaccount BY companycode supplieraccountgroup supplier glaccount.
      DELETE ADJACENT DUPLICATES FROM lt_about_glaccount COMPARING companycode supplieraccountgroup supplier glaccount.

      IF    lr_glaccount_range IS INITIAL.
        lv_glacc_grp = |Tài khoản: All|.
      ELSE.
*        SELECT gl~glaccount, gl~glaccountlongname
*        FROM @lt_about_glaccount AS gl
*        GROUP BY gl~glaccount, gl~glaccountlongname
*        ORDER BY gl~glaccount
*        INTO TABLE @DATA(lt_1line_gl).

        SELECT gl~glaccount, gl~glaccountlongname
        FROM i_glaccounttext AS gl
        WHERE 'YCOA' = gl~chartofaccounts
         AND  gl~glaccount IN @lr_glaccount_range
        GROUP BY gl~glaccount, gl~glaccountlongname
        ORDER BY gl~glaccount
        INTO TABLE @DATA(lt_1line_gl).

        LOOP AT lt_1line_gl INTO DATA(ls_grp_glacc).
          DATA(glaccountname) = |{ ls_grp_glacc-glaccount }-{ ls_grp_glacc-glaccountlongname }|.
          lv_glacc_grp = |{ lv_glacc_grp }; { glaccountname }|.
          CLEAR: ls_grp_glacc.
        ENDLOOP.

        SHIFT lv_glacc_grp LEFT BY 2 PLACES.
        lv_glacc_grp = |Tài khoản: { lv_glacc_grp }|.
      ENDIF.

      "-----------------------------------------------"

      TYPES: BEGIN OF ty_sodu,
               supplieraccountgroup       TYPE ktokk,
               supplier                   TYPE lifnr,
               suppliername               TYPE string,
               glaccount                  TYPE string,
               balance                    TYPE p LENGTH 13 DECIMALS 2,
               balancetransactioncurrency TYPE waers,
               amountcompcode             TYPE p LENGTH 13 DECIMALS 2,
               companycodecurrency        TYPE waers,
               typesodu                   TYPE string,
             END OF ty_sodu.
      DATA lt_sodu TYPE TABLE OF ty_sodu.

      "-- Đầu kì
**      "------------------------ NaVTT/ 03.04.2026/ Đầu kì check reversed -----------------------"
**      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
**             SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
**             journalentryitem~balancetransactioncurrency,
**             "-- quy đổi
**             SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency ,
**             journalentryitem~companycodecurrency,
**             'DK' AS typesodu,
**
**             journalentryitem~accountingdocument,
**             journalentry~reversalreferencedocument,
**             journalentryitem~fiscalperiod
**
**       FROM @lt_about_glaccount AS gl_account
**          INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
**                                                          AND gl_account~ledger            = journalentryitem~ledger
**                                                          AND gl_account~glaccount         = journalentryitem~glaccount
**                                                          AND gl_account~supplier               =  journalentryitem~supplier
**          INNER JOIN i_journalentry AS journalentry  ON journalentryitem~companycode        = journalentry~companycode
**                                                    AND journalentryitem~accountingdocument = journalentry~accountingdocument
**       WHERE journalentryitem~postingdate < @lv_prev_postingdate
**             AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
**         AND journalentryitem~isreversal IS NOT INITIAL
**          GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
**            journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency,
**            journalentryitem~accountingdocument,
**          journalentry~reversalreferencedocument,
**          journalentryitem~fiscalperiod
**          ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount
**          INTO TABLE @DATA(lt_dk_isreversal).
**
**
**      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
**             SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
**             journalentryitem~balancetransactioncurrency,
**             "-- quy đổi
**             SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency ,
**             journalentryitem~companycodecurrency,
**             'DK' AS typesodu,
**
**             journalentryitem~accountingdocument,
**             journalentry~reversalreferencedocument,
**             journalentryitem~fiscalperiod
**
**       FROM @lt_about_glaccount AS gl_account
**        INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
**                                                        AND gl_account~ledger            = journalentryitem~ledger
**                                                        AND gl_account~glaccount         = journalentryitem~glaccount
**                                                        AND gl_account~supplier               =  journalentryitem~supplier
**        INNER JOIN i_journalentry AS journalentry  ON journalentryitem~companycode        = journalentry~companycode
**                                                  AND journalentryitem~accountingdocument = journalentry~accountingdocument
**         WHERE journalentryitem~postingdate < @lv_prev_postingdate
**           AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
**           AND journalentryitem~isreversed IS NOT INITIAL
**        GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
**          journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency,
**          journalentryitem~accountingdocument,
**          journalentry~reversalreferencedocument,
**          journalentryitem~fiscalperiod
**        ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount
**        INTO TABLE @DATA(lt_dk_isreversed).
**
**
**      LOOP AT lt_dk_isreversal INTO DATA(ls_dk_isreversal).
**        lv_count_reversal = sy-tabix.
**        READ TABLE lt_dk_isreversed INTO DATA(ls_dk_isreversed) WITH KEY supplier = ls_dk_isreversal-supplier
**                                                                         glaccount = ls_dk_isreversal-glaccount
**                                                                         balancetransactioncurrency = ls_dk_isreversal-balancetransactioncurrency
**                                                                         reversalreferencedocument = ls_dk_isreversal-accountingdocument BINARY SEARCH.
**        IF sy-subrc = 0.
**          lv_count_reversed = sy-tabix.
**          IF ls_dk_isreversal-fiscalperiod = ls_dk_isreversed-fiscalperiod.
**            DELETE lt_dk_isreversal INDEX lv_count_reversal.
**            DELETE lt_dk_isreversed INDEX lv_count_reversed.
**            CLEAR: lv_count_reversal, lv_count_reversed.
**          ENDIF.
**        ENDIF.
**      ENDLOOP.
**
**      "------------------------ NaVTT/ 03.04.2026/ Đầu kì check reversed -----------------------"
      "-----------------------------------------------"
      "- Đầu kì
      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
        SUM( journalentryitem~amountinbalancetransaccrcy ) AS balance,
        journalentryitem~balancetransactioncurrency,
        "-- quy đổi
        SUM( journalentryitem~amountincompanycodecurrency ) AS amountcompcode ,
        journalentryitem~companycodecurrency,
       'DK' AS typesodu
      FROM @lt_about_glaccount AS gl_account
      INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                       AND gl_account~ledger            = journalentryitem~ledger
                                                       AND gl_account~glaccount         = journalentryitem~glaccount
                                                       AND gl_account~supplier               =  journalentryitem~supplier
      INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                       "AND journalentryitem~fiscalyear         = journalentry~fiscalyear "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
                                                       AND journalentryitem~accountingdocument = journalentry~accountingdocument
      WHERE journalentryitem~postingdate < @lv_prev_postingdate
        "AND journalentryitem~fiscalyear IN @lr_fiscalyear_range "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
        AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
*      AND journalentry~reversalreason <> '01' "--> loại chứng từ Reversal

***-- Begin: NaVTT/03.04.2026/
*          AND journalentryitem~isreversed IS INITIAL
*          AND journalentryitem~isreversal IS INITIAL
***-- End: NaVTT/03.04.2026/
      GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, ", journalentry~absoluteexchangerate
      journalentryitem~balancetransactioncurrency,journalentryitem~companycodecurrency
      ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount
      INTO TABLE @DATA(lt_dk).
*      INTO TABLE @lt_sodu.

**      "- Đầu kì (reversed check) NaVTT/update 03.04.2025
**      SELECT a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
**       SUM( a~amountinbalancetransaccrcy ) AS balance ,
**       a~balancetransactioncurrency,
**        "-- quy đổi
**        SUM( a~amountincompanycodecurrency ) AS amountcompcode ,
**        a~companycodecurrency,
**        a~typesodu
**        FROM @lt_dk_isreversal AS a
**        GROUP BY a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
**         a~balancetransactioncurrency, a~companycodecurrency, a~typesodu
**         ORDER BY a~supplieraccountgroup, a~supplier, a~glaccount, a~balancetransactioncurrency
**         APPENDING TABLE @lt_dk.

      "- Sum Đầu kì
      SELECT a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
        SUM( a~balance ) AS balance,
        a~balancetransactioncurrency,
        "-- quy đổi
        SUM( a~amountcompcode ) AS amountcompcode ,
        a~companycodecurrency,
        a~typesodu
      FROM @lt_dk AS a
      GROUP BY a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,a~balancetransactioncurrency,a~companycodecurrency,a~typesodu
      ORDER BY a~supplieraccountgroup, a~supplier, a~glaccount
      INTO TABLE @lt_sodu.

      "-----------------------------------------------"
      "-- Phát sinh từ [App] Manage Supplier Line Items
      "------------------------ NaVTT/ 03.04.2026/ Phát sinh nợ check reversed -----------------------"
      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~postingdate,

                  SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy ,
                  journalentryitem~balancetransactioncurrency,

                  'PS_NO' AS typesodu,
                  journalentryitem~isreversal, journalentryitem~debitcreditcode,

                  "-- quy đổi
                  SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency,
                  journalentryitem~companycodecurrency,


             journalentryitem~accountingdocument,
             journalentry~reversalreferencedocument,
             journalentryitem~fiscalperiod

             FROM @lt_about_glaccount AS gl_account
             INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                              AND gl_account~ledger            = journalentryitem~ledger
                                                              AND gl_account~glaccount         = journalentryitem~glaccount
                                                              AND gl_account~supplier          = journalentryitem~supplier
              INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                       AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                       AND journalentryitem~accountingdocument = journalentry~accountingdocument
              WHERE journalentryitem~postingdate IN @lr_postingdate_range
                AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
                AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
                AND journalentryitem~ledger = '0L'
                AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) ) "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
                AND journalentryitem~debitcreditcode = 'S'
                AND journalentryitem~isreversal IS NOT INITIAL
              GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~balancetransactioncurrency, journalentryitem~postingdate,
                journalentryitem~isreversal, journalentryitem~debitcreditcode, journalentryitem~companycodecurrency, journalentryitem~accountingdocument, journalentry~reversalreferencedocument, journalentryitem~fiscalperiod
              ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency
              INTO TABLE @DATA(lt_phatsinh_no_isreversal).


      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~postingdate,

                  SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy ,
                  journalentryitem~balancetransactioncurrency,

                  'PS_NO' AS typesodu,
                  journalentryitem~isreversal, journalentryitem~debitcreditcode,

                  "-- quy đổi
                  SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency ,
                  journalentryitem~companycodecurrency,


             journalentryitem~accountingdocument,
             journalentry~reversalreferencedocument,
             journalentryitem~fiscalperiod

             FROM @lt_about_glaccount AS gl_account
             INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                              AND gl_account~ledger            = journalentryitem~ledger
                                                              AND gl_account~glaccount         = journalentryitem~glaccount
                                                              AND gl_account~supplier          = journalentryitem~supplier
              INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                       AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                       AND journalentryitem~accountingdocument = journalentry~accountingdocument
              WHERE journalentryitem~postingdate IN @lr_postingdate_range
                AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
                AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
                AND journalentryitem~ledger = '0L'
                AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) )
                AND journalentryitem~debitcreditcode = 'S'
                AND journalentryitem~isreversed IS NOT INITIAL
              GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~balancetransactioncurrency, journalentryitem~postingdate,
                journalentryitem~isreversal, journalentryitem~debitcreditcode, journalentryitem~companycodecurrency, journalentryitem~accountingdocument, journalentry~reversalreferencedocument, journalentryitem~fiscalperiod
              ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency
              INTO TABLE @DATA(lt_phatsinh_no_isreversed).

      DATA: lv_count_reversed TYPE i,
            lv_count_reversal TYPE i.

      LOOP AT lt_phatsinh_no_isreversal INTO DATA(ls_rv_ps_no_isreversal).
        lv_count_reversal = sy-tabix.
        READ TABLE lt_phatsinh_no_isreversed INTO DATA(ls_rv_ps_no_isreversed) WITH KEY supplier = ls_rv_ps_no_isreversal-supplier
                                                                                        glaccount = ls_rv_ps_no_isreversal-glaccount
                                                                                        balancetransactioncurrency = ls_rv_ps_no_isreversal-balancetransactioncurrency
                                                                                        reversalreferencedocument = ls_rv_ps_no_isreversal-accountingdocument BINARY SEARCH.
        IF sy-subrc = 0.
          lv_count_reversed = sy-tabix.
          IF ls_rv_ps_no_isreversal-fiscalperiod = ls_rv_ps_no_isreversed-fiscalperiod.
            DELETE lt_phatsinh_no_isreversal INDEX lv_count_reversal.
            DELETE lt_phatsinh_no_isreversed INDEX lv_count_reversed.
            CLEAR: lv_count_reversal, lv_count_reversed.
          ENDIF.
        ENDIF.
      ENDLOOP.

      APPEND LINES OF lt_phatsinh_no_isreversed TO lt_phatsinh_no_isreversal.
      DELETE lt_phatsinh_no_isreversal WHERE postingdate NOT IN lr_postingdate_range.

      "------------------------ NaVTT/ 03.04.2026/ Phát sinh có check reversed -----------------------"
      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~postingdate,

       SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
       journalentryitem~balancetransactioncurrency,

       'PS_CO' AS typesodu,
        journalentryitem~isreversal, journalentryitem~debitcreditcode,

        SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency,
        journalentryitem~companycodecurrency,

      journalentryitem~accountingdocument,
      journalentry~reversalreferencedocument,
      journalentryitem~fiscalperiod
      FROM @lt_about_glaccount AS gl_account
      INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                   AND gl_account~ledger            = journalentryitem~ledger
                                   AND gl_account~glaccount         = journalentryitem~glaccount
                                   AND gl_account~supplier = journalentryitem~supplier
      INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                       AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                       AND journalentryitem~accountingdocument = journalentry~accountingdocument
      WHERE journalentryitem~postingdate IN @lr_postingdate_range
        AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
        AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
        AND journalentryitem~ledger = '0L'
        AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) )
        AND journalentryitem~debitcreditcode = 'H'
        AND journalentryitem~isreversal IS NOT INITIAL
      GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~balancetransactioncurrency, journalentryitem~postingdate,
      journalentryitem~isreversal, journalentryitem~debitcreditcode, journalentryitem~companycodecurrency, journalentryitem~accountingdocument, journalentry~reversalreferencedocument, journalentryitem~fiscalperiod
      ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency, journalentryitem~accountingdocument
      INTO TABLE @DATA(lt_phatsinh_co_isreversal).


      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~postingdate,

       SUM( journalentryitem~amountinbalancetransaccrcy ) AS amountinbalancetransaccrcy,
       journalentryitem~balancetransactioncurrency,

       'PS_CO' AS typesodu,
        journalentryitem~isreversal, journalentryitem~debitcreditcode,

        SUM( journalentryitem~amountincompanycodecurrency ) AS amountincompanycodecurrency,
        journalentryitem~companycodecurrency,

      journalentryitem~accountingdocument,
      journalentry~reversalreferencedocument,
      journalentryitem~fiscalperiod
      FROM @lt_about_glaccount AS gl_account
      INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                   AND gl_account~ledger            = journalentryitem~ledger
                                   AND gl_account~glaccount         = journalentryitem~glaccount
                                   AND gl_account~supplier = journalentryitem~supplier
      INNER JOIN i_journalentry AS journalentry         ON journalentryitem~companycode        = journalentry~companycode
                                                       AND journalentryitem~fiscalyear         = journalentry~fiscalyear
                                                       AND journalentryitem~accountingdocument = journalentry~accountingdocument
      WHERE journalentryitem~postingdate IN @lr_postingdate_range
        AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
        AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
        AND journalentryitem~ledger = '0L'
        AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) ) "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
        AND journalentryitem~debitcreditcode = 'H'
        AND journalentryitem~isreversed IS NOT INITIAL
      GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount, journalentryitem~balancetransactioncurrency, journalentryitem~postingdate,
      journalentryitem~isreversal, journalentryitem~debitcreditcode, journalentryitem~companycodecurrency, journalentryitem~accountingdocument, journalentry~reversalreferencedocument, journalentryitem~fiscalperiod
      ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency
      INTO TABLE @DATA(lt_phatsinh_co_isreversed).

      LOOP AT lt_phatsinh_co_isreversal INTO DATA(ls_rv_ps_co_isreversal).
        lv_count_reversal = sy-tabix.
        READ TABLE lt_phatsinh_co_isreversed INTO DATA(ls_rv_ps_co_isreversed) WITH KEY supplier = ls_rv_ps_co_isreversal-supplier
                                                                             glaccount = ls_rv_ps_co_isreversal-glaccount
                                                                             balancetransactioncurrency = ls_rv_ps_co_isreversal-balancetransactioncurrency
                                                                             reversalreferencedocument = ls_rv_ps_co_isreversal-accountingdocument BINARY SEARCH.
        IF sy-subrc = 0.
          lv_count_reversed = sy-tabix.
          IF ls_rv_ps_co_isreversal-fiscalperiod = ls_rv_ps_co_isreversed-fiscalperiod.
            DELETE lt_phatsinh_co_isreversal INDEX lv_count_reversal.
            DELETE lt_phatsinh_co_isreversed INDEX lv_count_reversed.
            CLEAR: lv_count_reversal, lv_count_reversed.
          ENDIF.
        ENDIF.
      ENDLOOP.

      APPEND LINES OF lt_phatsinh_co_isreversed TO lt_phatsinh_co_isreversal.
      DELETE lt_phatsinh_co_isreversal WHERE postingdate NOT IN lr_postingdate_range.
      "-------------------------- test 03/04/2026 --------------------------"

      "-----------------------------------------------"
      "- Phát sinh NỢ
      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
            SUM( journalentryitem~amountinbalancetransaccrcy ) AS balance ,
            journalentryitem~balancetransactioncurrency,
            'PS_NO' AS typesodu,
            journalentryitem~isreversal, journalentryitem~debitcreditcode,
            "-- quy đổi
            SUM( journalentryitem~amountincompanycodecurrency ) AS amountcompcode ,
            journalentryitem~companycodecurrency
       FROM @lt_about_glaccount AS gl_account
       INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                        AND gl_account~ledger            = journalentryitem~ledger
                                                        AND gl_account~glaccount         = journalentryitem~glaccount
                                                        AND gl_account~supplier          = journalentryitem~supplier
        WHERE journalentryitem~postingdate IN @lr_postingdate_range
          AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
          AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
          AND journalentryitem~ledger = '0L'
         " AND journalentryitem~financialaccounttype = 'K'
          AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) ) "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
**-- Begin: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> NỢ = S
*          AND journalentryitem~isreversal IS INITIAL AND journalentryitem~debitcreditcode = 'S'
          AND journalentryitem~debitcreditcode = 'S'
**-- End: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> NỢ = S

**-- Begin: NaVTT/03.04.2026/
          AND journalentryitem~isreversed IS INITIAL
          AND journalentryitem~isreversal IS INITIAL
**-- End: NaVTT/03.04.2026/
       GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
         journalentryitem~balancetransactioncurrency, journalentryitem~companycodecurrency,
         journalentryitem~isreversal, journalentryitem~debitcreditcode
        ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency
        INTO TABLE @DATA(lt_phatsinh_no).

      "- Phát sinh NỢ (reversed check) NaVTT/update 03.04.2025
      SELECT a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
       SUM( a~amountinbalancetransaccrcy ) AS balance ,
       a~balancetransactioncurrency,
       a~typesodu,
       a~isreversal, a~debitcreditcode,
        "-- quy đổi
        SUM( a~amountincompanycodecurrency ) AS amountcompcode ,
        a~companycodecurrency
        FROM @lt_phatsinh_no_isreversal AS a
        GROUP BY a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
         a~balancetransactioncurrency, a~companycodecurrency,
         a~isreversal, a~debitcreditcode, a~typesodu
         ORDER BY a~supplieraccountgroup, a~supplier, a~glaccount, a~balancetransactioncurrency
         APPENDING TABLE @lt_phatsinh_no.


      "-----------------------------------------------"
      "- Phát sinh CÓ
      SELECT gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
       SUM( journalentryitem~amountinbalancetransaccrcy ) AS balance ,
       journalentryitem~balancetransactioncurrency,
       'PS_CO' AS typesodu,
       journalentryitem~isreversal, journalentryitem~debitcreditcode,
        "-- quy đổi
        SUM( journalentryitem~amountincompanycodecurrency ) AS amountcompcode ,
        journalentryitem~companycodecurrency
        FROM @lt_about_glaccount AS gl_account
        INNER JOIN i_journalentryitem AS journalentryitem ON gl_account~companycode       = journalentryitem~companycode
                                                         AND gl_account~ledger            = journalentryitem~ledger
                                                         AND gl_account~glaccount         = journalentryitem~glaccount
                                                         AND gl_account~supplier = journalentryitem~supplier
       WHERE journalentryitem~postingdate IN @lr_postingdate_range
         AND journalentryitem~fiscalyear IN @lr_fiscalyear_range
         AND journalentryitem~balancetransactioncurrency IN @lr_cuki_range
         AND journalentryitem~ledger = '0L'
         AND ( journalentryitem~financialaccounttype = 'K' OR ( journalentryitem~accountingdocumenttype = 'SA' AND journalentryitem~supplier IS NOT INITIAL ) ) "ViHT9/13.01.2026/ update ZPM02 ver 2.2.3
**-- Begin: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> CÓ = H
*         AND ( journalentryitem~isreversal IS INITIAL AND journalentryitem~debitcreditcode = 'H' )
         AND journalentryitem~debitcreditcode = 'H'
**-- End: NaVTT/ 31.10.2025/ Update PHUTAI_SAP_2025_BH-208 -> CÓ = H

**-- Begin: NaVTT/03.04.2026/
          AND journalentryitem~isreversed IS INITIAL
          AND journalentryitem~isreversal IS INITIAL
**-- End: NaVTT/03.04.2026/
         GROUP BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~suppliername, gl_account~glaccount,
         journalentryitem~balancetransactioncurrency, journalentryitem~companycodecurrency,
         journalentryitem~isreversal, journalentryitem~debitcreditcode
         ORDER BY gl_account~supplieraccountgroup, gl_account~supplier, gl_account~glaccount, journalentryitem~balancetransactioncurrency
*         APPENDING TABLE @lt_phatsinh_co.
         INTO TABLE @DATA(lt_phatsinh_co).

      "- Phát sinh CÓ (reversed check) NaVTT/update 03.04.2025
      SELECT a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
       SUM( a~amountinbalancetransaccrcy ) AS balance ,
       a~balancetransactioncurrency,
       a~typesodu,
       a~isreversal, a~debitcreditcode,
        "-- quy đổi
        SUM( a~amountincompanycodecurrency ) AS amountcompcode ,
        a~companycodecurrency
        FROM @lt_phatsinh_co_isreversal AS a
        GROUP BY a~supplieraccountgroup, a~supplier, a~suppliername, a~glaccount,
         a~balancetransactioncurrency, a~companycodecurrency,
         a~isreversal, a~debitcreditcode, a~typesodu
         ORDER BY a~supplieraccountgroup, a~supplier, a~glaccount, a~balancetransactioncurrency
         APPENDING TABLE @lt_phatsinh_co.


      "-----------------------------------------------"
      "-- sum PS Có
      SELECT ps_co~supplieraccountgroup, ps_co~supplier, ps_co~suppliername, ps_co~glaccount,
      SUM( ps_co~balance ) AS balance ,
      ps_co~balancetransactioncurrency,
      SUM( ps_co~amountcompcode ) AS amountcompcode ,
      ps_co~companycodecurrency,
      ps_co~typesodu
      FROM @lt_phatsinh_co AS ps_co
      GROUP BY ps_co~supplieraccountgroup, ps_co~supplier, ps_co~suppliername, ps_co~glaccount,ps_co~balancetransactioncurrency, ps_co~companycodecurrency, ps_co~typesodu
      APPENDING TABLE @lt_sodu.

      "-- sum PS Nợ
      SELECT ps_no~supplieraccountgroup, ps_no~supplier, ps_no~suppliername, ps_no~glaccount,
      SUM( ps_no~balance ) AS balance ,
      ps_no~balancetransactioncurrency,
      SUM( ps_no~amountcompcode ) AS amountcompcode ,
      ps_no~companycodecurrency,
      ps_no~typesodu
      FROM @lt_phatsinh_no AS ps_no
      GROUP BY ps_no~supplieraccountgroup, ps_no~supplier, ps_no~suppliername, ps_no~glaccount,ps_no~balancetransactioncurrency, ps_no~companycodecurrency, ps_no~typesodu
      APPENDING TABLE @lt_sodu.

      "-----------------------------------------------"

      DATA: lt_sodu_vn TYPE TABLE OF ty_sodu,
            lt_sodu_nt TYPE TABLE OF ty_sodu,
            ls_sodu    TYPE ty_sodu.

      LOOP AT lt_sodu INTO ls_sodu.
        CASE ls_sodu-balancetransactioncurrency.
          WHEN 'VND'.
            APPEND ls_sodu TO lt_sodu_vn.
          WHEN OTHERS.
            APPEND ls_sodu TO lt_sodu_nt.
        ENDCASE.
      ENDLOOP.

      SORT lt_sodu_vn BY supplieraccountgroup supplier glaccount typesodu.
      SORT lt_sodu_nt BY supplieraccountgroup supplier glaccount typesodu.
      "-----------------------------------------------"
      "-- Cuối kì -> Ending Balance = Starting Balance + Total Debit – Total Credit
      "-----------------------------------------------"
      " End: Processing data from CDS
      "-------------------------------------------------------------------------------------------------------------------------------"

      DATA: lv_dauki_no_nt    TYPE p LENGTH 13 DECIMALS 2,
            lv_dauki_no_vn    TYPE p LENGTH 13 DECIMALS 2,
            lv_dauki_co_nt    TYPE p LENGTH 13 DECIMALS 2,
            lv_dauki_co_vn    TYPE p LENGTH 13 DECIMALS 2,

            lv_phatsinh_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_phatsinh_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_phatsinh_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_phatsinh_co_vn TYPE p LENGTH 13 DECIMALS 2,

            lv_cuoiki_vn      TYPE p LENGTH 13 DECIMALS 2,
            lv_cuoiki_nt      TYPE p LENGTH 13 DECIMALS 2,
            lv_cuoiki_no_nt   TYPE p LENGTH 13 DECIMALS 2,
            lv_cuoiki_no_vn   TYPE p LENGTH 13 DECIMALS 2,
            lv_cuoiki_co_nt   TYPE p LENGTH 13 DECIMALS 2,
            lv_cuoiki_co_vn   TYPE p LENGTH 13 DECIMALS 2.

      DATA: lv_total_dk_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_dk_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_total_dk_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_dk_co_vn TYPE p LENGTH 13 DECIMALS 2,

            lv_total_ps_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ps_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ps_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ps_co_vn TYPE p LENGTH 13 DECIMALS 2,

            lv_total_ck_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ck_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ck_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_total_ck_co_vn TYPE p LENGTH 13 DECIMALS 2.

      DATA: lv_subtotal_dk_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_dk_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_dk_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_dk_co_vn TYPE p LENGTH 13 DECIMALS 2,

            lv_subtotal_ps_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ps_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ps_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ps_co_vn TYPE p LENGTH 13 DECIMALS 2,

            lv_subtotal_ck_no_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ck_no_vn TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ck_co_nt TYPE p LENGTH 13 DECIMALS 2,
            lv_subtotal_ck_co_vn TYPE p LENGTH 13 DECIMALS 2.

      DATA lv_uuid_fi          TYPE uuid.
      TRY.
          lv_uuid_fi = cl_system_uuid=>if_system_uuid_rfc4122_static~create_uuid_c36_by_version( version = 4 ).
        CATCH cx_uuid_error INTO DATA(lx_err).
          DATA(lv_error3) = lx_err->get_text( ).  " Hoặc ghi log, v.v.
      ENDTRY.

      LOOP AT lt_about_glaccount INTO DATA(ls_glaccount).

        READ TABLE lt_sodu_vn TRANSPORTING NO FIELDS WITH KEY supplieraccountgroup = ls_glaccount-supplieraccountgroup supplier = ls_glaccount-supplier glaccount = ls_glaccount-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_sodu_vn INTO DATA(ls_sd_vn) FROM sy-tabix.
            IF ls_sd_vn-supplieraccountgroup = ls_glaccount-supplieraccountgroup AND ls_sd_vn-supplier = ls_glaccount-supplier AND ls_sd_vn-glaccount = ls_glaccount-glaccount.

              ls_lines-items-balancetransactioncurrency = ls_sd_vn-balancetransactioncurrency.
              ls_lines-items-companycodecurrency = ls_sd_vn-companycodecurrency.
              IF ls_sd_vn-typesodu = 'DK'.

                IF ls_sd_vn-amountcompcode >= 0.
                  lv_dauki_no_vn = abs( ls_sd_vn-amountcompcode ).
                ELSE.
                  lv_dauki_co_vn =  abs( ls_sd_vn-amountcompcode ).
                ENDIF.

              ELSEIF ls_sd_vn-typesodu = 'PS_CO'.

                IF ls_sd_vn-amountcompcode > 0.
                  lv_phatsinh_co_vn = ls_sd_vn-amountcompcode * -1.
                ELSE.
                  lv_phatsinh_co_vn = abs( ls_sd_vn-amountcompcode ).
                ENDIF.

              ELSEIF ls_sd_vn-typesodu = 'PS_NO'.

                lv_phatsinh_no_vn = ls_sd_vn-amountcompcode .

              ENDIF.

            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.

          MOVE-CORRESPONDING ls_glaccount TO ls_lines-items.
          ls_lines-items-suppliercode = |{ ls_lines-items-supplier ALPHA = OUT }|.

          IF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS NOT INITIAL.

            IF lv_date_from_fm <> lv_date_to_fm.
              ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm } - { lv_date_to_fm }|.
            ELSE.
              ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm }|.
            ENDIF.

          ELSEIF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS INITIAL.
            ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm }|.
          ENDIF.

          "-- cuoi ki
          lv_cuoiki_vn =  lv_dauki_no_vn - lv_dauki_co_vn + lv_phatsinh_no_vn - lv_phatsinh_co_vn.
          IF lv_cuoiki_vn >= 0.
            lv_cuoiki_no_vn = lv_cuoiki_vn.
          ELSE.
            lv_cuoiki_co_vn =  lv_cuoiki_vn  .
          ENDIF.

          "-- currency excel
          ls_lines-items-dauki_co_vn    = lv_dauki_co_vn .
          ls_lines-items-dauki_no_vn    = lv_dauki_no_vn .
          ls_lines-items-phatsinh_co_vn = lv_phatsinh_co_vn.
          ls_lines-items-phatsinh_no_vn = lv_phatsinh_no_vn.
          ls_lines-items-cuoiki_co_vn   = lv_cuoiki_co_vn.
          ls_lines-items-cuoiki_no_vn   = lv_cuoiki_no_vn.
          ls_lines-items-dauki_co_vn    = lv_dauki_co_vn .
          ls_lines-items-dauki_no_vn    = lv_dauki_no_vn .
          ls_lines-items-phatsinh_co_vn = lv_phatsinh_co_vn.
          ls_lines-items-phatsinh_no_vn = lv_phatsinh_no_vn.
          ls_lines-items-cuoiki_co_vn   = lv_cuoiki_co_vn.
          ls_lines-items-cuoiki_no_vn   = lv_cuoiki_no_vn.

          "-- format currency
          IF lv_dauki_co_vn IS NOT INITIAL.
            ls_lines-items-dauki_co_vn_fm = |{ format_amount( i_amount = lv_dauki_co_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_dauki_no_vn IS NOT INITIAL.
            ls_lines-items-dauki_no_vn_fm = |{ format_amount( i_amount = lv_dauki_no_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_phatsinh_co_vn IS NOT INITIAL.
            IF lv_phatsinh_co_vn < 0 .
              ls_lines-items-phatsinh_co_vn_fm = |({ format_amount( i_amount = abs( lv_phatsinh_co_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_co_vn_fm = |{ format_amount( i_amount = abs( lv_phatsinh_co_vn ) i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF lv_phatsinh_no_vn IS NOT INITIAL.
            IF lv_phatsinh_no_vn < 0 .
              ls_lines-items-phatsinh_no_vn_fm = |({ format_amount( i_amount = abs( lv_phatsinh_no_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_no_vn_fm = |{ format_amount( i_amount = lv_phatsinh_no_vn i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF lv_cuoiki_co_vn IS NOT INITIAL.
            ls_lines-items-cuoiki_co_vn_fm = |{ format_amount( i_amount = abs( lv_cuoiki_co_vn ) i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_cuoiki_no_vn IS NOT INITIAL.
            ls_lines-items-cuoiki_no_vn_fm = |{ format_amount( i_amount = abs( lv_cuoiki_no_vn ) i_currency = 'VND' ) }|.
          ENDIF.

*          ls_lines-items-dauki_co_vn_fm    = |{ lv_dauki_co_vn CURRENCY = 'VND' NUMBER = USER }|.
*          ls_lines-items-dauki_no_vn_fm    = |{ lv_dauki_no_vn CURRENCY = 'VND' NUMBER = USER }|.
*          ls_lines-items-phatsinh_co_vn_fm = |{ lv_phatsinh_co_vn CURRENCY = 'VND' NUMBER = USER }|.
*          ls_lines-items-phatsinh_no_vn_fm = |{ lv_phatsinh_no_vn CURRENCY = 'VND' NUMBER = USER }|.
*          ls_lines-items-cuoiki_co_vn_fm   = |{ lv_cuoiki_co_vn CURRENCY = 'VND' NUMBER = USER }|.
*          ls_lines-items-cuoiki_no_vn_fm   = |{ lv_cuoiki_no_vn CURRENCY = 'VND' NUMBER = USER }|.

*          ls_lines-items-dauki_co_nt_fm    = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.
*          ls_lines-items-dauki_no_nt_fm    = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.
*          ls_lines-items-phatsinh_co_nt_fm = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.
*          ls_lines-items-phatsinh_no_nt_fm = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.
*          ls_lines-items-cuoiki_co_nt_fm   = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.
*          ls_lines-items-cuoiki_no_nt_fm   = |{ 0 CURRENCY = 'USD' NUMBER = USER }|.

          "-- line total
          lv_total_dk_no_vn = lv_total_dk_no_vn + lv_dauki_no_vn.
          lv_total_dk_co_vn = lv_total_dk_co_vn + lv_dauki_co_vn.
          lv_total_ps_no_vn = lv_total_ps_no_vn +  lv_phatsinh_no_vn.
          lv_total_ps_co_vn = lv_total_ps_co_vn +  lv_phatsinh_co_vn.

          IF lv_cuoiki_vn >= 0.
            lv_total_ck_no_vn = lv_total_ck_no_vn + lv_cuoiki_vn.
          ELSE.
            lv_total_ck_co_vn = lv_total_ck_co_vn + lv_cuoiki_vn.
          ENDIF.

          "-- line subtotal key customer quy đổi usd - vnd
          lv_subtotal_dk_no_vn = lv_subtotal_dk_no_vn + lv_dauki_no_vn.
          lv_subtotal_dk_co_vn = lv_subtotal_dk_co_vn + lv_dauki_co_vn.
          lv_subtotal_ps_no_vn = lv_subtotal_ps_no_vn +  lv_phatsinh_no_vn.
          lv_subtotal_ps_co_vn = lv_subtotal_ps_co_vn +  lv_phatsinh_co_vn.

          IF lv_cuoiki_vn >= 0.
            lv_subtotal_ck_no_vn = lv_subtotal_ck_no_vn + lv_cuoiki_vn.
          ELSE.
            lv_subtotal_ck_co_vn = lv_subtotal_ck_co_vn + lv_cuoiki_vn.
          ENDIF.

          IF  ls_lines-items-dauki_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-dauki_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-dauki_co_vn_fm IS NOT INITIAL
           OR ls_lines-items-dauki_no_vn_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_co_vn_fm  IS NOT INITIAL
           OR ls_lines-items-phatsinh_no_vn_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_co_vn_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_no_vn_fm IS NOT INITIAL.
            APPEND ls_lines TO lt_lines.
            APPEND ls_lines-items TO lt_lines_exc. " excel
          ENDIF.

          CLEAR: ls_lines, lv_cuoiki_vn,
          lv_dauki_no_vn, lv_dauki_co_vn, lv_phatsinh_no_vn, lv_phatsinh_co_vn, lv_cuoiki_no_vn, lv_cuoiki_co_vn,
          lv_dauki_no_nt, lv_dauki_co_nt, lv_phatsinh_no_nt, lv_phatsinh_co_nt, lv_cuoiki_no_nt, lv_cuoiki_co_nt .
        ENDIF.

        READ TABLE lt_sodu_nt TRANSPORTING NO FIELDS WITH KEY supplieraccountgroup = ls_glaccount-supplieraccountgroup supplier = ls_glaccount-supplier glaccount = ls_glaccount-glaccount BINARY SEARCH.
        IF sy-subrc = 0.
          LOOP AT lt_sodu_nt INTO DATA(ls_sd_nt) FROM sy-tabix.
            IF ls_sd_nt-supplieraccountgroup = ls_glaccount-supplieraccountgroup AND ls_sd_nt-supplier = ls_glaccount-supplier AND ls_sd_nt-glaccount = ls_glaccount-glaccount.

              ls_lines-items-balancetransactioncurrency = ls_sd_nt-balancetransactioncurrency.
              ls_lines-items-companycodecurrency = ls_sd_nt-companycodecurrency.

              IF ls_sd_nt-typesodu = 'DK'.

                IF ls_sd_nt-balance >= 0.
                  lv_dauki_no_nt =  ls_sd_nt-balance.
                  lv_dauki_no_vn =  ls_sd_nt-amountcompcode. " quy đổi usd - vnd
                ELSE.
                  lv_dauki_co_nt = abs( ls_sd_nt-balance ).
                  lv_dauki_co_vn = abs( ls_sd_nt-amountcompcode ). " quy đổi usd - vnd
                ENDIF.

              ELSEIF ls_sd_nt-typesodu = 'PS_CO'.

                IF ls_sd_nt-balance > 0.
                  lv_phatsinh_co_nt = ls_sd_nt-balance * -1.
                ELSE.
                  lv_phatsinh_co_nt = abs( ls_sd_nt-balance ) .
                ENDIF.

                IF ls_sd_nt-amountcompcode > 0.
                  lv_phatsinh_co_vn =  ls_sd_nt-amountcompcode * -1." quy đổi usd - vnd
                ELSE.
                  lv_phatsinh_co_vn =  abs( ls_sd_nt-amountcompcode )." quy đổi usd - vnd
                ENDIF.

              ELSEIF ls_sd_nt-typesodu = 'PS_NO'.

                lv_phatsinh_no_nt = ls_sd_nt-balance.
                lv_phatsinh_no_vn = ls_sd_nt-amountcompcode." quy đổi usd - vnd

              ENDIF.

            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.

          MOVE-CORRESPONDING ls_glaccount TO ls_lines-items.
          ls_lines-items-suppliercode = |{ ls_lines-items-supplier ALPHA = OUT }|.

          IF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS NOT INITIAL.

            IF lv_date_from_fm <> lv_date_to_fm.
              ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm } - { lv_date_to_fm }|.
            ELSE.
              ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm }|.
            ENDIF.

          ELSEIF lv_date_from_fm IS NOT INITIAL AND lv_date_to_fm IS INITIAL.
            ls_lines-items-postingdate_fromto  = |{ lv_date_from_fm }|.
          ENDIF.

          "-- cuoi ki
          lv_cuoiki_nt =  lv_dauki_no_nt - lv_dauki_co_nt + lv_phatsinh_no_nt - lv_phatsinh_co_nt.

          IF lv_cuoiki_nt >= 0.
            lv_cuoiki_no_nt = lv_cuoiki_nt.
          ELSE.
            lv_cuoiki_co_nt =  lv_cuoiki_nt.
          ENDIF.

          "-- quy đổi cuối kì usd - vnd
          lv_cuoiki_vn = lv_dauki_no_vn - lv_dauki_co_vn + lv_phatsinh_no_vn - lv_phatsinh_co_vn.

          IF lv_cuoiki_vn >= 0.
            lv_cuoiki_no_vn = lv_cuoiki_vn.
          ELSE.
            lv_cuoiki_co_vn =  lv_cuoiki_vn  .
          ENDIF.

          "-- currency excel
          ls_lines-items-dauki_co_nt    = lv_dauki_co_nt .
          ls_lines-items-dauki_no_nt    = lv_dauki_no_nt .
          ls_lines-items-phatsinh_co_nt = lv_phatsinh_co_nt.
          ls_lines-items-phatsinh_no_nt = lv_phatsinh_no_nt.
          ls_lines-items-cuoiki_co_nt   = lv_cuoiki_co_nt .
          ls_lines-items-cuoiki_no_nt   = lv_cuoiki_no_nt .
          ls_lines-items-dauki_co_vn    = lv_dauki_co_vn .
          ls_lines-items-dauki_no_vn    = lv_dauki_no_vn .
          ls_lines-items-phatsinh_co_vn = lv_phatsinh_co_vn.
          ls_lines-items-phatsinh_no_vn = lv_phatsinh_no_vn.
          ls_lines-items-cuoiki_co_vn   = lv_cuoiki_co_vn.
          ls_lines-items-cuoiki_no_vn   = lv_cuoiki_no_vn.

          "-- format currency
          IF lv_dauki_co_nt IS NOT INITIAL.
            ls_lines-items-dauki_co_nt_fm = |{ format_amount( i_amount = lv_dauki_co_nt i_currency = 'USD' ) }|.
          ENDIF.

          IF lv_dauki_no_nt IS NOT INITIAL.
            ls_lines-items-dauki_no_nt_fm = |{ format_amount( i_amount = lv_dauki_no_nt i_currency = 'USD' ) }|.
          ENDIF.

          IF lv_phatsinh_co_nt IS NOT INITIAL.
            IF lv_phatsinh_co_nt < 0.
              ls_lines-items-phatsinh_co_nt_fm = |({ format_amount( i_amount = abs( lv_phatsinh_co_nt ) i_currency = 'USD' ) })|.
            ELSE.
              ls_lines-items-phatsinh_co_nt_fm = |{ format_amount( i_amount = lv_phatsinh_co_nt i_currency = 'USD' ) }|.
            ENDIF.
          ENDIF.

          IF lv_phatsinh_no_nt IS NOT INITIAL.
            IF lv_phatsinh_no_nt < 0.
              ls_lines-items-phatsinh_no_nt_fm = |({ format_amount( i_amount = abs( lv_phatsinh_no_nt ) i_currency = 'USD' ) })|.
            ELSE.
              ls_lines-items-phatsinh_no_nt_fm = |{ format_amount( i_amount = lv_phatsinh_no_nt i_currency = 'USD' ) }|.
            ENDIF.
          ENDIF.

          IF lv_cuoiki_co_nt IS NOT INITIAL.
            ls_lines-items-cuoiki_co_nt_fm = |{ format_amount( i_amount = abs( lv_cuoiki_co_nt ) i_currency = 'USD' ) }|.
          ENDIF.

          IF lv_cuoiki_no_nt IS NOT INITIAL.
            ls_lines-items-cuoiki_no_nt_fm = |{ format_amount( i_amount = abs( lv_cuoiki_no_nt ) i_currency = 'USD' ) }|.
          ENDIF.


          "-- format currency quy đổi usd - vnd
          IF lv_dauki_co_vn IS NOT INITIAL.
            ls_lines-items-dauki_co_vn_fm = |{ format_amount( i_amount = lv_dauki_co_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_dauki_no_vn IS NOT INITIAL.
            ls_lines-items-dauki_no_vn_fm = |{ format_amount( i_amount = lv_dauki_no_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_phatsinh_co_vn IS NOT INITIAL.
            IF lv_phatsinh_co_vn < 0.
              ls_lines-items-phatsinh_co_vn_fm = |({ format_amount( i_amount = abs( lv_phatsinh_co_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_co_vn_fm = |{ format_amount( i_amount = abs( lv_phatsinh_co_vn ) i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF lv_phatsinh_no_vn IS NOT INITIAL.
            IF lv_phatsinh_no_vn < 0 .
              ls_lines-items-phatsinh_no_vn_fm = |({ format_amount( i_amount = abs( lv_phatsinh_no_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_no_vn_fm = |{ format_amount( i_amount = lv_phatsinh_no_vn i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF lv_cuoiki_co_vn IS NOT INITIAL.
            ls_lines-items-cuoiki_co_vn_fm = |{ format_amount( i_amount = abs( lv_cuoiki_co_vn ) i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_cuoiki_no_vn IS NOT INITIAL.
            ls_lines-items-cuoiki_no_vn_fm = |{ format_amount( i_amount = abs( lv_cuoiki_no_vn ) i_currency = 'VND' ) }|.
          ENDIF.

          "-- line total
          lv_total_dk_no_nt = lv_total_dk_no_nt + lv_dauki_no_nt.
          lv_total_dk_co_nt = lv_total_dk_co_nt + lv_dauki_co_nt.
          lv_total_ps_no_nt = lv_total_ps_no_nt +  lv_phatsinh_no_nt.
          lv_total_ps_co_nt = lv_total_ps_co_nt +  lv_phatsinh_co_nt.

          IF lv_cuoiki_nt >= 0.
            lv_total_ck_no_nt = lv_total_ck_no_nt + lv_cuoiki_nt.
          ELSE.
            lv_total_ck_co_nt = lv_total_ck_co_nt + lv_cuoiki_nt.
          ENDIF.

          "-- line total quy đổi usd - vnd
          lv_total_dk_no_vn = lv_total_dk_no_vn + lv_dauki_no_vn.
          lv_total_dk_co_vn = lv_total_dk_co_vn + lv_dauki_co_vn.
          lv_total_ps_no_vn = lv_total_ps_no_vn +  lv_phatsinh_no_vn.
          lv_total_ps_co_vn = lv_total_ps_co_vn +  lv_phatsinh_co_vn.

          IF lv_cuoiki_vn >= 0.
            lv_total_ck_no_vn = lv_total_ck_no_vn +  lv_cuoiki_vn.
          ELSE.
            lv_total_ck_co_vn = lv_total_ck_co_vn +  lv_cuoiki_vn.
          ENDIF.

          "-- line subtotal key customer
          lv_subtotal_dk_no_nt = lv_subtotal_dk_no_nt + lv_dauki_no_nt.
          lv_subtotal_dk_co_nt = lv_subtotal_dk_co_nt + lv_dauki_co_nt.
          lv_subtotal_ps_no_nt = lv_subtotal_ps_no_nt +  lv_phatsinh_no_nt.
          lv_subtotal_ps_co_nt = lv_subtotal_ps_co_nt +  lv_phatsinh_co_nt.

          IF lv_cuoiki_nt >= 0.
            lv_subtotal_ck_no_nt = lv_subtotal_ck_no_nt + lv_cuoiki_nt.
          ELSE.
            lv_subtotal_ck_co_nt = lv_subtotal_ck_co_nt + lv_cuoiki_nt.
          ENDIF.

          "-- line subtotal key customer quy đổi usd - vnd
          lv_subtotal_dk_no_vn = lv_subtotal_dk_no_vn + lv_dauki_no_vn.
          lv_subtotal_dk_co_vn = lv_subtotal_dk_co_vn + lv_dauki_co_vn.
          lv_subtotal_ps_no_vn = lv_subtotal_ps_no_vn +  lv_phatsinh_no_vn.
          lv_subtotal_ps_co_vn = lv_subtotal_ps_co_vn +  lv_phatsinh_co_vn.

          IF lv_cuoiki_vn >= 0.
            lv_subtotal_ck_no_vn = lv_subtotal_ck_no_vn + lv_cuoiki_vn.
          ELSE.
            lv_subtotal_ck_co_vn = lv_subtotal_ck_co_vn + lv_cuoiki_vn.
          ENDIF.

          IF  ls_lines-items-dauki_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-dauki_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_co_nt_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_no_nt_fm IS NOT INITIAL
           OR ls_lines-items-dauki_co_vn_fm IS NOT INITIAL
           OR ls_lines-items-dauki_no_vn_fm IS NOT INITIAL
           OR ls_lines-items-phatsinh_co_vn_fm  IS NOT INITIAL
           OR ls_lines-items-phatsinh_no_vn_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_co_vn_fm IS NOT INITIAL
           OR ls_lines-items-cuoiki_no_vn_fm IS NOT INITIAL.
            ls_lines-items-zlevel = 'A'.

            APPEND ls_lines TO lt_lines.
            APPEND ls_lines-items TO lt_lines_exc. " excel

          ENDIF.

          CLEAR: ls_lines, lv_cuoiki_vn, lv_cuoiki_nt,
          lv_dauki_no_vn, lv_dauki_co_vn, lv_phatsinh_no_vn, lv_phatsinh_co_vn, lv_cuoiki_no_vn, lv_cuoiki_co_vn,
          lv_dauki_no_nt, lv_dauki_co_nt, lv_phatsinh_no_nt, lv_phatsinh_co_nt, lv_cuoiki_no_nt, lv_cuoiki_co_nt .
        ENDIF.

**-- Subtotal
        AT END OF supplieraccountgroup.
          CLEAR: ls_lines.
          "-- begin: total line
          IF ls_glaccount-supplieraccountgroup = 'Z10'.
            ls_lines-items-glaccount = |Tổng nhóm trong nước|.
          ELSEIF ls_glaccount-supplieraccountgroup = 'Z20'.
            ls_lines-items-glaccount = |Tổng nhóm nước ngoài|.
          ELSEIF ls_glaccount-supplieraccountgroup = 'Z30'.
            ls_lines-items-glaccount = |Tổng nhóm NH, HQ, CQNN|.
          ELSEIF ls_glaccount-supplieraccountgroup = 'Z40'.
            ls_lines-items-glaccount = |Tổng nhóm nội bộ|.
          ELSEIF ls_glaccount-supplieraccountgroup = 'Z50'.
            ls_lines-items-glaccount = |Tổng nhóm nhân viên|.
          ELSE.
            ls_lines-items-glaccount = |Tổng|.
          ENDIF.

*          ls_lines-items-balancetransactioncurrency = 'USD'.
*          ls_lines-items-companycodecurrency = 'VND'.

          IF lv_subtotal_dk_co_nt IS NOT INITIAL.
            ls_lines-items-dauki_co_nt_fm = |{ format_amount( i_amount = lv_subtotal_dk_co_nt i_currency = 'USD' ) }|.
          ENDIF.

          IF lv_subtotal_dk_no_nt IS NOT INITIAL.
            ls_lines-items-dauki_no_nt_fm = |{ format_amount( i_amount = lv_subtotal_dk_no_nt i_currency = 'USD' ) }|.
          ENDIF.

          IF lv_subtotal_ps_co_nt IS NOT INITIAL.
            IF lv_subtotal_ps_co_nt < 0 .
              ls_lines-items-phatsinh_co_nt_fm = |({ format_amount( i_amount = abs( lv_subtotal_ps_co_nt ) i_currency = 'USD' ) })|.
            ELSE.
              ls_lines-items-phatsinh_co_nt_fm = |{ format_amount( i_amount = abs( lv_subtotal_ps_co_nt ) i_currency = 'USD' ) }|.
            ENDIF.
          ENDIF.

          IF lv_subtotal_ps_no_nt IS NOT INITIAL.
            IF lv_subtotal_ps_no_nt < 0 .
              ls_lines-items-phatsinh_no_nt_fm = |({ format_amount( i_amount = abs( lv_subtotal_ps_no_nt ) i_currency = 'USD' ) })|.
            ELSE.
              ls_lines-items-phatsinh_no_nt_fm = |{ format_amount( i_amount = lv_subtotal_ps_no_nt i_currency = 'USD' ) }|.
            ENDIF.
          ENDIF.

          IF ( lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt ) < 0.
            ls_lines-items-cuoiki_co_nt_fm = |{ format_amount( i_amount = abs( lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt ) i_currency = 'USD' ) }|.
          ELSE.
            ls_lines-items-cuoiki_no_nt_fm = |{ format_amount( i_amount = lv_subtotal_ck_co_nt + lv_subtotal_ck_no_nt i_currency = 'USD' ) }|.
          ENDIF.


          IF lv_subtotal_dk_co_vn IS NOT INITIAL.
            ls_lines-items-dauki_co_vn_fm = |{ format_amount( i_amount = lv_subtotal_dk_co_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_subtotal_dk_no_vn IS NOT INITIAL.
            ls_lines-items-dauki_no_vn_fm = |{ format_amount( i_amount = lv_subtotal_dk_no_vn i_currency = 'VND' ) }|.
          ENDIF.

          IF lv_subtotal_ps_co_vn IS NOT INITIAL.
            IF lv_subtotal_ps_co_vn < 0 .
              ls_lines-items-phatsinh_co_vn_fm = |({ format_amount( i_amount = abs( lv_subtotal_ps_co_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_co_vn_fm = |{ format_amount( i_amount = lv_subtotal_ps_co_vn i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF lv_subtotal_ps_no_vn IS NOT INITIAL.
            IF lv_subtotal_ps_no_vn < 0 .
              ls_lines-items-phatsinh_no_vn_fm = |({ format_amount( i_amount = abs( lv_subtotal_ps_no_vn ) i_currency = 'VND' ) })|.
            ELSE.
              ls_lines-items-phatsinh_no_vn_fm = |{ format_amount( i_amount = lv_subtotal_ps_no_vn i_currency = 'VND' ) }|.
            ENDIF.
          ENDIF.

          IF ( lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn ) > 0 .
            ls_lines-items-cuoiki_no_vn_fm = |{ format_amount( i_amount = lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn i_currency = 'VND' ) }|.
          ELSE.
            ls_lines-items-cuoiki_co_vn_fm = |{ format_amount( i_amount = abs( lv_subtotal_ck_co_vn + lv_subtotal_ck_no_vn ) i_currency = 'VND' ) }|.
          ENDIF.

          ls_lines-items-zlevel = 'B'.

          APPEND ls_lines TO lt_lines.
          APPEND ls_lines-items TO lt_lines_exc." excel

          CLEAR: ls_lines, lv_subtotal_dk_co_nt, lv_subtotal_dk_no_nt, lv_subtotal_ps_co_nt, lv_subtotal_ps_no_nt, lv_subtotal_ck_co_nt, lv_subtotal_ck_no_nt,
                 lv_subtotal_dk_co_vn, lv_subtotal_dk_no_vn, lv_subtotal_ps_co_vn, lv_subtotal_ps_no_vn, lv_subtotal_ck_co_vn, lv_subtotal_ck_no_vn.
          "-- end: total line
        ENDAT.
      ENDLOOP.

      "--
*      LOOP AT lt_lines INTO ls_lines.
*        APPEND ls_lines TO tt_exc.
*      ENDLOOP.
      " End: Fill line item

      DATA: lv_logo TYPE string.
      DATA: lo_logo       TYPE REF TO zcl_get_logo_company.
      DATA: lo_api  TYPE REF TO zcl_get_long_text.

      lo_logo = NEW #( ).
      lo_api = NEW #( ).

      " Begin: Fill header line
      LOOP AT lt_about_glaccount ASSIGNING FIELD-SYMBOL(<lfs_header>).
        AT NEW companycode.

          MOVE-CORRESPONDING <lfs_header> TO ls_header.
          ls_header-object_id = lv_uuid_fi.
          ls_header-currentdate = lv_current_date.

          IF lv_postingdate_from_fm IS NOT INITIAL AND lv_postingdate_to_fm IS NOT INITIAL.
            IF lv_postingdate_from_fm <> lv_postingdate_to_fm.
              ls_header-postingdate_fromto = |Từ ngày: { lv_postingdate_from_fm } đến ngày: { lv_postingdate_to_fm }|.
            ELSE.
              ls_header-postingdate_fromto = |Ngày: { lv_postingdate_from_fm }|.
            ENDIF.
          ELSEIF lv_postingdate_from_fm IS NOT INITIAL.
            ls_header-postingdate_fromto = |Ngày: { lv_postingdate_from_fm }|.
          ENDIF.

          ls_header-postingdate = lv_prev_postingdate.
          APPEND ls_header TO lt_header.
          CLEAR ls_header.

          "-- itab export PDF Header
          MOVE-CORRESPONDING <lfs_header> TO ls_data.
          ls_data-object_id = lv_uuid_fi.
          ls_data-compmst = |Mã số thuế: { ls_data-compmst }|.
          ls_data-glaccount_1line = lv_glacc_grp.
          ls_data-currentdate = lv_current_date.

          IF lv_postingdate_from_fm IS NOT INITIAL AND lv_postingdate_to_fm IS NOT INITIAL.
            IF lv_postingdate_from_fm <> lv_postingdate_to_fm.
              ls_data-postingdate_fromto = |Từ ngày: { lv_postingdate_from_fm } đến ngày: { lv_postingdate_to_fm }|.
            ELSE.
              ls_data-postingdate_fromto = |Ngày: { lv_postingdate_from_fm }|.
            ENDIF.
          ELSEIF lv_postingdate_from_fm IS NOT INITIAL.
            ls_data-postingdate_fromto = |Ngày: { lv_postingdate_from_fm }|.
          ENDIF.

          READ TABLE lr_nguoilap INTO DATA(ls_nl) INDEX 1.
          IF sy-subrc = 0. ls_data-nguoilap = ls_nl-low. ENDIF.

          READ TABLE lr_ketoan INTO DATA(ls_kt) INDEX 1.
          IF sy-subrc = 0. ls_data-ketoan = ls_kt-low. ENDIF.

          READ TABLE lr_giamdoc INTO DATA(ls_gd) INDEX 1.
          IF sy-subrc = 0. ls_data-giamdoc = ls_gd-low. ENDIF.

          ls_data-items = lt_lines. "-items itab
          ls_data-itemsexc = lt_lines_exc. "-items itab excel

          "================ USD =================

          IF lv_total_dk_no_nt IS NOT INITIAL.
            ls_data-total_dauki_no_nt = format_amount( i_amount = abs( lv_total_dk_no_nt ) i_currency = 'USD' ).
          ENDIF.

          IF lv_total_dk_co_nt IS NOT INITIAL.
            ls_data-total_dauki_co_nt = format_amount( i_amount = abs( lv_total_dk_co_nt ) i_currency = 'USD' ).
          ENDIF.

          IF lv_total_ps_no_nt IS NOT INITIAL.
            ls_data-total_phatsinh_no_nt = format_amount( i_amount = abs( lv_total_ps_no_nt ) i_currency = 'USD' ).
          ENDIF.

          IF lv_total_ps_co_nt IS NOT INITIAL.
            ls_data-total_phatsinh_co_nt = format_amount( i_amount = abs( lv_total_ps_co_nt ) i_currency = 'USD' ).
          ENDIF.

          IF lv_total_ck_co_nt IS NOT INITIAL.
            ls_data-total_cuoiki_co_nt = format_amount( i_amount = abs( lv_total_ck_co_nt ) i_currency = 'USD' ).
          ENDIF.

          IF lv_total_ck_no_nt IS NOT INITIAL.
            ls_data-total_cuoiki_no_nt = format_amount( i_amount = abs( lv_total_ck_no_nt ) i_currency = 'USD' ).
          ENDIF.


          "================ VND =================
          IF lv_total_dk_no_vn IS NOT INITIAL.
            ls_data-total_dauki_no_vn = format_amount( i_amount = abs( lv_total_dk_no_vn ) i_currency = 'VND' ).
          ENDIF.

          IF lv_total_dk_co_vn IS NOT INITIAL.
            ls_data-total_dauki_co_vn = format_amount( i_amount = abs( lv_total_dk_co_vn ) i_currency = 'VND' ).
          ENDIF.

          IF lv_total_ps_no_vn IS NOT INITIAL.
            ls_data-total_phatsinh_no_vn = format_amount( i_amount = abs( lv_total_ps_no_vn ) i_currency = 'VND' ).
          ENDIF.

          IF lv_total_ps_co_vn IS NOT INITIAL.
            ls_data-total_phatsinh_co_vn = format_amount( i_amount = abs( lv_total_ps_co_vn ) i_currency = 'VND' ).
          ENDIF.

          IF lv_total_ck_co_vn IS NOT INITIAL.
            ls_data-total_cuoiki_co_vn = format_amount( i_amount = abs( lv_total_ck_co_vn ) i_currency = 'VND' ).
          ENDIF.

          IF lv_total_ck_no_vn IS NOT INITIAL.
            ls_data-total_cuoiki_no_vn = format_amount( i_amount = abs( lv_total_ck_no_vn ) i_currency = 'VND' ).
          ENDIF.

          "title excel
          ls_data-report_name = 'SỔ TỔNG HỢP CÔNG NỢ PHẢI TRẢ NHÀ CUNG CẤP'.
          ls_data-mancc_tt = 'Mã nhà cung cấp'.
          ls_data-tenncc_tt = 'Tên nhà cung cấp'.
          ls_data-taikhoan_tt = 'Tài khoản'.
          ls_data-dvt_tt = 'Đơn vị tiền tệ'.
          ls_data-nt_tt = 'Số dư đầu kỳ ngoại tệ'.
          ls_data-opvnd_tt = 'Số dư đầu kỳ VND'.
          ls_data-psnt_tt = 'Phát sinh trong kỳ ngoại tệ'.
          ls_data-psvnd_tt = 'Phát sinh trong kỳ VND'.
          ls_data-clnt_tt = 'Số dư cuối kỳ ngoại tệ'.
          ls_data-clvnd_tt = 'Số dư cuối kỳ VND'.
          ls_data-nnt_tt = 'Nợ ngoại tệ'.
          ls_data-cnt_tt = 'Có ngoại tệ'.
          ls_data-nvnd_tt = 'Nợ VND'.
          ls_data-cvnd_tt = 'Có VND'.
          ls_data-nguoilap_tt = 'Người lập'.
          ls_data-giamdoc_tt = 'Giám đốc'.
          ls_data-ketoan_tt = 'Kế Toán Trưởng'.
          ls_data-tong_tt = 'Tổng cộng'.

          " ZLOGO
          lo_logo->get_logo( EXPORTING iv_company = <lfs_header>-companycode IMPORTING lv_logo = lv_logo ).
          IF lv_logo IS INITIAL.
            lo_logo->get_logo( EXPORTING iv_company = '1000' IMPORTING lv_logo = lv_logo ).
          ENDIF.
          ls_data-zlogo = lv_logo.

          APPEND ls_data TO lt_data.
          CLEAR ls_data.

        ENDAT.
      ENDLOOP.

      DATA lt_pdfdata TYPE TABLE OF ty_datapdf.
      lt_pdfdata  = CORRESPONDING #( lt_data ).
      "-- form
      DATA: ls_data_form TYPE ty_form.

      ls_data_form = VALUE #( form = VALUE #( headers = lt_pdfdata ) ).

      "render form PDF
      DATA(lv_pdf) = render_form(
        EXPORTING
          ia_abap = ls_data_form
      ).

      "export Excel attachment
      DATA: lv_attacment_exc TYPE zde_attachment,
            lv_report        TYPE char72 VALUE 'ZPM02',
            lv_template      TYPE char72 VALUE 'ZPM02_EXC'.

      DATA: lo_excel       TYPE REF TO zcl_export_excel_xlsx.
      lo_excel = NEW #( ).
      lo_excel->export_excel( EXPORTING
                              iv_template = lv_template
                              iv_report = lv_report
                              it_data = lt_data
                              iv_generate = abap_false
                              IMPORTING lv_context = lv_attacment_exc ).



      GET TIME STAMP FIELD DATA(lv_timestamp).
      LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_data>).
        <lfs_data>-attachment = lv_pdf.
        <lfs_data>-mimetype = 'application/pdf'.
        <lfs_data>-filename = |{ lv_timestamp }.pdf|.

        "excel attachment
        <lfs_data>-attachment_exc = lv_attacment_exc.
        <lfs_data>-mimetype_exc = 'application/vnd.ms-excel'.
        <lfs_data>-filename_exc = |{ lv_timestamp }.xlsx|.
      ENDLOOP.

      DATA(lo_saver) = NEW zcl_save_pdf_zpm02( ).

      lo_saver->save_pdf_zpm02(
        iv_reportid = 'ZPM02'
        iv_objectid = lv_uuid_fi
        iv_pdf      = lv_pdf
      ).

      lo_saver->save_excel_zpm02(
        iv_reportid = 'ZPM02'
        iv_objectid = lv_uuid_fi
        iv_pdf      = lv_attacment_exc
      ).

*      DATA(lo_exc) = NEW zcl_save_exc_zpm02( ).
*      lo_exc->save_exc_zpm02(
*        iv_reportid = 'ZPM02'
*        iv_objectid = lv_uuid_fi
*        iv_item = tt_exc
*      ).
*      CLEAR tt_exc.
    ELSE.

      "-- Current date print
      READ TABLE lt_pdf ASSIGNING FIELD-SYMBOL(<lfs_pdf>) INDEX 1.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <lfs_pdf> TO ls_header.
*        ls_header-currentdate = lv_current_date.

        READ TABLE lt_excel ASSIGNING FIELD-SYMBOL(<lfs_excel>) INDEX 1.
        IF sy-subrc = 0.
          ls_header-attachment_exc = <lfs_excel>-attachment.
          ls_header-mimetype_exc = <lfs_excel>-mimetype.
          ls_header-filename_exc = <lfs_excel>-filename.
        ENDIF.

        APPEND ls_header TO lt_header.
      ENDIF.
    ENDIF.
    "------------------------------------ End: Get data processing ------------------------------------"

    lt_data_output = CORRESPONDING #( lt_header ).
    et_table = lt_data_output.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    DATA: lt_data_output TYPE tt_data_output.

    CHECK io_request->is_data_requested( ).
    DATA(rt_requested_elements) = io_request->get_requested_elements( ).
    DATA(ro_aggregation) = io_request->get_aggregation( ).
    DATA(ro_filter) = io_request->get_filter(  ).

    DATA(rt_aggregated_elements) = ro_aggregation->get_aggregated_elements( ).
    DATA(rt_grouped_elements) = ro_aggregation->get_grouped_elements( ).

    me->get_data(
      EXPORTING
        io_request = io_request
      IMPORTING
        et_table   = lt_data_output
    ).


    io_response->set_data( lt_data_output ).

    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( lines( lt_data_output ) ).
    ENDIF.
  ENDMETHOD.


  METHOD render_form.
    TRY.
        "-- Render Form
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
              iv_use_destination_service = abap_false
              iv_service_instance_name   = 'ZADSTEMPLSTORE'
            ).

        "-- test lấy abap2xml
        DATA: lv_xml_string TYPE xstring,
              lv_xml        TYPE string.
        lv_xml = abap2xml( ia_abap ).

        DATA(ls_template) = lo_store->get_template_by_tcode( iv_tcode = 'ZPM02' ).

        lv_xml_string = xco_cp=>string( lv_xml )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
        cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = lv_xml_string
                                              iv_xdp_layout   = ls_template-xdp_template
                                              iv_locale       = 'en_US'
                                              is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
                                    IMPORTING
                                    " TODO: variable is assigned but never used (ABAP cleaner)
                                              ev_trace_string = DATA(lv_trace)
                                    " TODO: variable is assigned but never used (ABAP cleaner)
                                              ev_pdf          = DATA(lv_pdf) ).
        rv_pdf = lv_pdf.
      CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util INTO DATA(exc).
        "Exception occurred whiling render_form
        DATA(lv_error_message) = exc->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD format_amount.

    DATA: lv_str      TYPE string,
          lv_dec      TYPE string,
          lv_amount   TYPE p LENGTH 13 DECIMALS 2,
          lv_decimals TYPE i.

    " --- Nhân theo loại tiền ---
    CASE i_currency.
      WHEN 'VND'.
        lv_amount   = i_amount * 100.
        lv_decimals = 0.
      WHEN 'USD'.
        lv_amount   = i_amount.
        lv_decimals = 2.
      WHEN OTHERS.
        lv_amount   = i_amount * 100.
        lv_decimals = 0.
    ENDCASE.

    " --- Convert sang string theo số decimal ---
    lv_str = |{ lv_amount DECIMALS = lv_decimals }|.

    " --- Split integer + decimal ---
    DATA(lv_int) = lv_str.
    CLEAR lv_dec.

    IF lv_decimals > 0.
      SPLIT lv_str AT '.' INTO lv_int lv_dec.

      " đảm bảo đủ số decimal
      WHILE strlen( lv_dec ) < lv_decimals.
        lv_dec = lv_dec && '0'.
      ENDWHILE.

    ELSE.
      lv_int = lv_str.
    ENDIF.

    " --- Insert thousand separator (.) ---
    DATA lv_formatted_int TYPE string.
    DATA(l_length) = strlen( lv_int ).
    DATA lv_len TYPE i.
    lv_len = l_length.

    DATA lv_pos TYPE i.
    lv_pos = lv_len.

    WHILE lv_pos > 3.
      lv_pos = lv_pos - 3.
      lv_formatted_int = substring( val = lv_int off = lv_pos len = 3 ) && lv_formatted_int.
      lv_formatted_int = '.' && lv_formatted_int.
      lv_int = substring( val = lv_int off = 0 len = lv_pos ).
    ENDWHILE.

    lv_formatted_int = lv_int && lv_formatted_int.

    " --- Combine ---
    IF lv_decimals > 0.
      r_amount = lv_formatted_int && ',' && lv_dec.
    ELSE.
      r_amount = lv_formatted_int.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
