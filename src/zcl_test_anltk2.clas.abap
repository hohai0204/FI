CLASS zcl_test_anltk2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST_ANLTK2 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
**   data: lv_dates type dats value '20250701'.
**   data: lv_period type string value '09'.
**   data: lv_year type string value '01'.
**   data: lv_new_month_char type string.
**   data(lv_old_month) = lv_dates+4(2).
**   data(lv_old_year) = lv_dates+0(4).
**   data(lv_old_date) = lv_dates+6(2).
**   data(lv_new_month) = lv_period + lv_old_month.
**   if lv_new_month > 12.
**     lv_new_month = lv_new_month - 12.
**     lv_year = lv_year + 1.
**     if lv_new_month < 10.
**        lv_new_month_char = |0{ lv_new_month }|.
**     endif.
**   endif.
**   data(lv_new_year) = lv_old_year + lv_year.
**   data(lv_new_date) = lv_new_year && lv_new_month_char && lv_old_date.
**   out->write( |New date is { lv_new_date }| ).

*    select
*    glaccount
*    from i_glaccounthierarchynode AS zsfe2
*    where zsfe2~glaccounthierarchy = 'ZIS1'
*    AND zsfe2~parentnode = '001'
*    into TABLE @data(lt_gl).
*
*
*      SELECT
*          SUM( amountincompanycodecurrency ) AS balance_amount,
*          zsfe2~parentnode,
*          gl_data~glaccount,
**          fiscalperiod,
**          fiscalyear,
*          companycodecurrency AS balancetransactioncurrency
*          FROM i_glaccountlineitemrawdata AS gl_data
*          LEFT JOIN i_glaccounthierarchynode AS zsfe2 ON zsfe2~glaccount = gl_data~glaccount
*          WHERE
**          fiscalperiod IN @lr_report_period
**          AND fiscalyear IN @lr_report_year
*          fiscalyearperiod <= '2025007'
*          AND sourceledger = '0L'
*          AND zsfe2~glaccounthierarchy = 'ZBS1'
*          AND zsfe2~parentnode NOT LIKE '00%'
*          AND zsfe2~hierarchynode NOT LIKE '0%'
**          and gl_data~FinancialAccountType = 'K'
**          AND gl_data~glaccount NOT LIKE '3%1'
*          GROUP BY zsfe2~parentnode,
*          gl_data~glaccount,
**          fiscalperiod,
**          fiscalyear,
*          companycodecurrency
*          ORDER BY zsfe2~parentnode
*          INTO TABLE @DATA(lt_gl_report).


*    "-------------------test custom form excel-------------------"
*    TYPES: BEGIN OF lty_item,
*             companycode       TYPE ZDE_char4,
*             masterfixedasset  TYPE string,
*             fixedasset        TYPE string,
*             assetclass        TYPE string,
*             assetserialnumber TYPE string,
*           END OF lty_item,
*           tt_item TYPE STANDARD TABLE OF lty_item WITH EMPTY KEY.
*
*    TYPES: BEGIN OF lty_excel,
*             com_name     TYPE string,
*             com_add      TYPE string,
*             title_report TYPE string,
*             title_item01 TYPE string,
*             title_item02 TYPE string,
*             title_item03 TYPE string,
*             title_item04 TYPE string,
*             item         TYPE tt_item,
*           END OF lty_excel,
*           tt_excel TYPE STANDARD TABLE OF lty_excel WITH EMPTY KEY.
*    DATA: lt_excel TYPE tt_excel.
*    DATA: lt_item TYPE tt_item.
*
*    DATA: lv_attacment TYPE zde_attachment,
*          lv_report    TYPE char72 VALUE 'TEST_EX',
*          lv_template  TYPE char72 VALUE 'TEST_EX'.
*
*    "select data
*    SELECT
*    companycode,
*    masterfixedasset,
*    fixedasset,
*    assetclass,
*    assetserialnumber
*    FROM i_fixedasset
*    INTO CORRESPONDING FIELDS OF TABLE @lt_item
*    UP TO 10 ROWS.
*
*    CHECK lt_item IS NOT INITIAL.
*    DATA(lw_data) = lt_item[ 1 ].
*    SELECT SINGLE
*    *
*    FROM zcds_company
*    WHERE companycode = @lw_data-companycode
*    INTO @DATA(ls_com).
*
*    APPEND VALUE #(
*                      com_add = ls_com-diachi_vn
*                      com_name = ls_com-tencty_vn
*                      title_report = 'BÁO CÁO TÀI CHÍNH'
*                      title_item01 = 'Master Fixed Asset'
*                      title_item02 = 'Fixed Asset'
*                      title_item03 = 'Asset Class'
*                      title_item04 = 'Asset Serial Number'
*                      item = lt_item
*    ) TO lt_excel.
*
*
*
*
*    DATA: lo_excel       TYPE REF TO zcl_export_excel_xlsx.
*    lo_excel = NEW #( ).
*    lo_excel->export_excel( EXPORTING
*                            iv_template = lv_template
*                            iv_report = lv_report
*                            it_data = lt_excel
*                            IMPORTING lv_context = lv_attacment ).
*
*
*
*
*    SELECT SINGLE
*    report_id
*    FROM ztb_file_export WHERE report_id = @lv_template
*    INTO @DATA(lv_exist).
*    " Return file content
*
*    IF lv_exist IS INITIAL.
*      MODIFY ENTITIES OF zr_tbfile_export
*         ENTITY zrtbfileexport
*        CREATE AUTO FILL CID FIELDS ( reportid template  attachment filename mimetype ) WITH VALUE #(
*            (
*           reportid      = lv_template
*           template = lv_template
*            filename   = 'template_ex.xlsx'
*            mimetype   = 'application/vnd.ms-excel'
*            attachment = lv_attacment
*            ) )
*         MAPPED DATA(ls_mapped_cr)
*         REPORTED DATA(ls_reported_cr)
*         FAILED DATA(ls_failed_cr).
*    ELSE.
*      MODIFY ENTITIES OF zr_tbfile_export
*     ENTITY zrtbfileexport
*    UPDATE  FIELDS (    attachment filename mimetype ) WITH VALUE #(
*        (
*       reportid      = lv_template
*       template = lv_template
*        filename   = 'template_ex12.xlsx'
*        mimetype   = 'application/vnd.ms-excel'
*        attachment = lv_attacment
*        ) )
*     MAPPED DATA(ls_mapped_update)
*     REPORTED DATA(ls_reported_update)
*     FAILED DATA(ls_failed_update).
*    ENDIF.
*    COMMIT ENTITIES.

    "------------------------------------------------------------"

*read enTITIES OF I_PRODUNIVERSALHIERARCHYTP
*eNTITY ProductUniversalHierarchyText
*ALL FIELDS WITH VALUE #( ( ProdUnivHierarchy = 'ZBS1' ) )
*RESULT   DATA(lt_result_head_text)
*             REPORTED DATA(ls_reported)
*             FAILED   DATA(ls_failed_read).
DATA(lv_num) = 1000000.
DATA lv_text1 TYPE string.

DATA(lv_text) = |{ lv_num }|.

    " Regex: chèn dấu chấm sau mỗi nhóm 3 chữ số từ phải sang trái
    REPLACE ALL OCCURRENCES OF REGEX '(\d)(?=(\d{3})+(?!\d))'
      IN lv_text WITH '$1.'.

    lv_text1 = lv_text.


  ENDMETHOD.
ENDCLASS.
