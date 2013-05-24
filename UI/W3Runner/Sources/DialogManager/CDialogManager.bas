Attribute VB_Name = "CDialogManagerModule"
Option Explicit

Public Const CDialogManager_SQL_SELECT = "select * from [TABLENAME] order by [IDCOLUMN]"
Public Const CDialogManager_SQL_SELECT_RECORD_BY_ID = "select * from [TABLENAME] where [IDCOLUMN]=[ID]"
Public Const CDialogManager_SQL_UPDATE_RECORD_BY_ID = "update [TABLENAME] set [FIELDS] where [IDCOLUMN]=[ID]"
Public Const CDialogManager_SQL_INSERT_RECORD_BY_ID = "insert into [TABLENAME] ([FIELDS]) values ([VALUES])"
Public Const CDialogManager_SQL_DELETE_RECORD_BY_ID = "delete from [TABLENAME] where [IDCOLUMN]=[ID]"
Public Const CDialogManager_SQL_DELETE_ALL_RECORD = "delete from [TABLENAME]"
Public Const CDialogManager_SQL_GET_NEW_ID = "select max([IDCOLUMN]) from [TABLENAME]" ' This query is not secure in a multi user environment


Public Const DBDialogManager_ERROR_1000 = "DBDMERR1000-Cannot add the list '[LISTNAME]' to the DBListManager. TableName=[TABLENAME]."
Public Const DBDialogManager_ERROR_1001 = "DBDMERR1001-UnExpected error [DETAILS] populating fied [FIELD]."
Public Const DBDialogManager_ERROR_1002 = "DBDMERR1002-UnExpected error [DETAILS]."
Public Const DBDialogManager_ERROR_1003 = "DBDMERR1003-Field [FIELD] is required"
Public Const DBDialogManager_ERROR_1004 = "DBDMERR1004-The record was inserted, but retreiving the new id failed."


Public Const DBDialogManager_MSG_1000 = "Executing query"
Public Const DBDialogManager_MSG_1001 = "Populating ListView"

Public g_static_objDBListManager As New CDBListManager
