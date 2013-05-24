//From: "David" <dshiel@yahoo.com>
//References: <OrLORzYrBHA.2056@tkmsftngp03> <u#cTAPZrBHA.2252@tkmsftngp03> <ORyHV7arBHA.1608@tkmsftngp04> <Os0mXLbrBHA.2540@tkmsftngp04> <OWjg1lbrBHA.2324@tkmsftngp03>
//Subject: How to bulk copy data from program variables in C# (ODBC) was Re: Fast way to get data into SQL Server from C# app
//Date: Sun, 10 Feb 2002 08:13:08 -0500
//Lines: 805
//X-Priority: 3
//X-MSMail-Priority: Normal
//X-Newsreader: Microsoft Outlook Express 6.00.2600.0000
//X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2600.0000
//Message-ID: <#sTGuSjsBHA.2396@tkmsftngp05>
//Newsgroups: microsoft.public.dotnet.framework.adonet,microsoft.public.dotnet.framework.performance,microsoft.public.sqlserver.programming
//NNTP-Posting-Host: dftc-177-97-106.jacksonville.net 66.177.97.106
//
//
//Here is a rough first start of a utility class. Any helpful suggestions are
//welcome.
//David
//P.S. Would it be better to post the code as an attachment?
//________________________________________________________________

using System;
using System.Runtime.InteropServices;
using System.Text;

namespace MetraTech.DataAccess
{
/// <summary>
/// Summary description for OdbcSSHeader.
/// </summary>
[ComVisible(false)]
public class bcp
{
		[DllImport("odbc32.dll")]
		public static extern Int16 SQLAllocHandle(Int16 HandleType, IntPtr
			InputHandle, out IntPtr OutputHandle);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLSetEnvAttr(IntPtr EnvironmentHandle,
			Int32 attribute, IntPtr valuePtr, Int32 stringLength);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLSetConnectAttr(IntPtr connectionHandle,
			Int32 attribute, IntPtr valuePtr, Int32 stringLength);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLConnect(IntPtr connectionHandle,
			string serverName,	Int16 nameLength1, string userName,
			Int16 nameLength2, string authentication, Int16 nameLength3);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLDriverConnect(IntPtr connectionHandle,
																								IntPtr hwnd,
			string connStr, Int16 nameLength1, StringBuilder connStrOut,
																								Int16 connStrOutMax,
																								out Int16 connStrOutLength,
																								UInt16 driverCompletion);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLDisconnect(IntPtr connectionHandle);

		[DllImport("odbc32.dll")]
		public static extern Int16 SQLFreeHandle(Int16 handleType, IntPtr handle);

	  [DllImport("odbc32.dll")]
	public static extern Int16 SQLGetDiagRec(Int16 handleType, IntPtr handle,
																					 Int16 recNumber, StringBuilder sqlState,
																					 out Int32 nativeError, StringBuilder messageText,
																						Int16 bufferLength, out Int16 textLength);



		[DllImport("odbcbcp.dll")]
		public static extern Int16 bcp_init(IntPtr hdbc, string table, 
			string dataFile, string errorFile, Int16 eDirection);

		[DllImport("odbcbcp.dll")]
		public static extern Int16 bcp_readfmt(IntPtr hdbc, string formatFile);

		[DllImport("odbcbcp.dll")]
		public static extern Int16 bcp_exec(IntPtr hdbc, out Int16 rowsProcessed);

	//	[DllImport("Odbcbcp.dll")]
	//	public static externInt16 /*SQL_API*/ bcp_bind (  hdbc, byte lpcbyte1, System.Int32 i1, System.Int64 dbint, byte lpcbyte2, System.Int32 i2, System.Int32 i3, System.Int32 i4);

	  [DllImport("Odbcbcp.dll")]
	  public static extern Int16 bcp_colfmt ( IntPtr hdbc, Int32 file_column, byte userDataType, Int32 prefixLength, Int64 dataLen, string terminator, Int32 termLength, System.Int32 serverCol);

	  [DllImport("Odbcbcp.dll")]
	  public static extern Int16 bcp_columns (IntPtr hdbc, Int32 count);

	  [DllImport("Odbcbcp.dll")]
	  public static extern Int64 bcp_done (IntPtr hdbc);



public const int NULL=0;
//from SqlTypes.h
public const int SQL_MAX_NUMERIC_LEN=16;
//from SqlExt.h
public const int SQL_TYPE_NULL=0;
public const int SQL_ATTR_ENLIST_IN_DTC = 1207;
public const int SQL_ATTR_ENLIST_IN_XA = 1208;
public const int SQL_DESC_BASE_COLUMN_NAME = 22;
#region OdbcSS.H contents
///*
//** ODBCSS.H - This is the application include file for the
//** SQL Server driver specific defines.
//**
//** (C) Copyright 1993-1998 By Microsoft Corp.
//**
//*/
//#ifndef __ODBCSS
//#define __ODBCSS
//#ifdef __cplusplus
//extern "C" { /* Assume C declarations for C++ */
//#endif /* __cplusplus */
// Useful defines
public const int SQL_MAX_SQLSERVERNAME = 128; // max SQL Server identifier length
// SQLSetConnectOption/SQLSetStmtOption driver specific defines.
// Microsoft has 1200 thru 1249 reserved for Microsoft SQL Server driver usage.
// Connection Options
public const int SQL_COPT_SS_BASE = 1200;
public const int SQL_COPT_SS_REMOTE_PWD = (SQL_COPT_SS_BASE+1); // dbrpwset SQLSetConnectOption only
public const int SQL_COPT_SS_USE_PROC_FOR_PREP = (SQL_COPT_SS_BASE+2); // Use create proc for SQLPrepare
public const int SQL_COPT_SS_INTEGRATED_SECURITY = (SQL_COPT_SS_BASE+3); // Force integrated security on login
public const int SQL_COPT_SS_PRESERVE_CURSORS = (SQL_COPT_SS_BASE+4); // Preserve server cursors after SQLTransact
public const int SQL_COPT_SS_USER_DATA = (SQL_COPT_SS_BASE+5); // dbgetuserdata/dbsetuserdata
public const int SQL_COPT_SS_ENLIST_IN_DTC = SQL_ATTR_ENLIST_IN_DTC; // Enlist in a DTC transaction
public const int SQL_COPT_SS_ENLIST_IN_XA = SQL_ATTR_ENLIST_IN_XA; // Enlist in a XA transaction 
//SQL_ATTR_CONNECTION_DEAD 1209 (It will return current connection status, it will not go to server)
public const int SQL_COPT_SS_FALLBACK_CONNECT = (SQL_COPT_SS_BASE+10); // Enables FallBack connections
public const int SQL_COPT_SS_PERF_DATA = (SQL_COPT_SS_BASE+11); // Used to access SQL Server ODBC driver performance data
public const int SQL_COPT_SS_PERF_DATA_LOG = (SQL_COPT_SS_BASE+12); // Used to set the logfile name for the Performance data
public const int SQL_COPT_SS_PERF_QUERY_INTERVAL = (SQL_COPT_SS_BASE+13); // Used to set the query logging threshold in milliseconds.
public const int SQL_COPT_SS_PERF_QUERY_LOG = (SQL_COPT_SS_BASE+14); // Used to set the logfile name for saving queryies.
public const int SQL_COPT_SS_PERF_QUERY = (SQL_COPT_SS_BASE+15); // Used to start and stop query logging.
public const int SQL_COPT_SS_PERF_DATA_LOG_NOW = (SQL_COPT_SS_BASE+16); // Used to make a statistics log entry to disk.
public const int SQL_COPT_SS_QUOTED_IDENT = (SQL_COPT_SS_BASE+17); // Enable/Disable Quoted Identifiers
public const int SQL_COPT_SS_ANSI_NPW = (SQL_COPT_SS_BASE+18); // Enable/Disable ANSI NULL, Padding and Warnings
public const int SQL_COPT_SS_BCP = (SQL_COPT_SS_BASE+19); // Allow BCP usage on connection
public const int SQL_COPT_SS_TRANSLATE = (SQL_COPT_SS_BASE+20); // Perform code page translation
public const int SQL_COPT_SS_ATTACHDBFILENAME = (SQL_COPT_SS_BASE+21); // File name to be attached as a database
public const int SQL_COPT_SS_CONCAT_NULL = (SQL_COPT_SS_BASE+22); // Enable/Disable CONCAT_NULL_YIELDS_NULL
public const int SQL_COPT_SS_ENCRYPT = (SQL_COPT_SS_BASE+23); // Allow strong encryption for data
public const int SQL_COPT_SS_MAX_USED = SQL_COPT_SS_ENCRYPT;
// Statement Options
public const int SQL_SOPT_SS_BASE = 1225;
public const int SQL_SOPT_SS_TEXTPTR_LOGGING = (SQL_SOPT_SS_BASE+0); // Text pointer logging
public const int SQL_SOPT_SS_CURRENT_COMMAND = (SQL_SOPT_SS_BASE+1); // dbcurcmd SQLGetStmtOption only
public const int SQL_SOPT_SS_HIDDEN_COLUMNS = (SQL_SOPT_SS_BASE+2); // Expose FOR BROWSE hidden columns
public const int SQL_SOPT_SS_NOBROWSETABLE = (SQL_SOPT_SS_BASE+3); // Set NOBROWSETABLE option
public const int SQL_SOPT_SS_REGIONALIZE = (SQL_SOPT_SS_BASE+4); // Regionalize output character conversions
public const int SQL_SOPT_SS_CURSOR_OPTIONS = (SQL_SOPT_SS_BASE+5); // Server cursor options
public const int SQL_SOPT_SS_NOCOUNT_STATUS = (SQL_SOPT_SS_BASE+6); // Real vs. Not Real row count indicator
public const int SQL_SOPT_SS_DEFER_PREPARE = (SQL_SOPT_SS_BASE+7); // Defer prepare until necessary
public const int SQL_SOPT_SS_MAX_USED = SQL_SOPT_SS_DEFER_PREPARE;
public const int SQL_COPT_SS_BASE_EX = 1240;
public const int SQL_COPT_SS_BROWSE_CONNECT = (SQL_COPT_SS_BASE_EX+1); // Browse connect mode of operation
public const int SQL_COPT_SS_BROWSE_SERVER = (SQL_COPT_SS_BASE_EX+2); // Single Server browse request.
public const int SQL_COPT_SS_WARN_ON_CP_ERROR = (SQL_COPT_SS_BASE_EX+3); // Issues warning when data from the server
// had a loss during code page conversion.
public const int SQL_COPT_SS_CONNECTION_DEAD = (SQL_COPT_SS_BASE_EX+4); // dbdead SQLGetConnectOption only
// It will try to ping the server.
// Expensive connection check
public const int SQL_COPT_SS_BROWSE_CACHE_DATA = (SQL_COPT_SS_BASE_EX+5);
//Determines if we should cache browse info
//Used when returned buffer is greater then ODBC limit (32K)
public const int SQL_COPT_SS_RESET_CONNECTION = (SQL_COPT_SS_BASE_EX+6);
//When this option is set, we will perform connection reset
//on next packet

public const int SQL_COPT_SS_EX_MAX_USED = SQL_COPT_SS_RESET_CONNECTION;
// Defines for use with SQL_COPT_SS_USE_PROC_FOR_PREP
public const int SQL_UP_OFF = 0; //was :dL // Procedures won't be used for prepare
public const int SQL_UP_ON = 1; //was :dL // Procedures will be used for prepare
public const int SQL_UP_ON_DROP = 2; //was :dL // Temp procedures will be explicitly dropped
public const int SQL_UP_DEFAULT = SQL_UP_ON;
// Defines for use with SQL_COPT_SS_INTEGRATED_SECURITY - Pre-Connect Option only
public const int SQL_IS_OFF = 0; //was :dL // Integrated security isn't used
public const int SQL_IS_ON = 1; //was :dL // Integrated security is used
public const int SQL_IS_DEFAULT = SQL_IS_OFF;
// Defines for use with SQL_COPT_SS_PRESERVE_CURSORS
public const int SQL_PC_OFF = 0; //was :dL // Cursors are closed on SQLTransact
public const int SQL_PC_ON = 1; //was :dL // Cursors remain open on SQLTransact
public const int SQL_PC_DEFAULT = SQL_PC_OFF;
// Defines for use with SQL_COPT_SS_USER_DATA
public const int SQL_UD_NOTSET = NULL; // No user data pointer set
// Defines for use with SQL_COPT_SS_TRANSLATE
public const int SQL_XL_OFF = 0; //was :dL // Code page translation is not performed
public const int SQL_XL_ON = 1; //was :dL // Code page translation is performed
public const int SQL_XL_DEFAULT = SQL_XL_ON;
// Defines for use with SQL_COPT_SS_FALLBACK_CONNECT - Pre-Connect Option only
public const int SQL_FB_OFF = 0; //was :dL // FallBack connections are disabled
public const int SQL_FB_ON = 1; //was :dL // FallBack connections are enabled
public const int SQL_FB_DEFAULT = SQL_FB_OFF;
// Defines for use with SQL_COPT_SS_BCP - Pre-Connect Option only
public const int SQL_BCP_OFF = 0; //was :dL // BCP is not allowed on connection
public const int SQL_BCP_ON = 1; //was :dL // BCP is allowed on connection
public const int SQL_BCP_DEFAULT = SQL_BCP_OFF;
// Defines for use with SQL_COPT_SS_QUOTED_IDENT
public const int SQL_QI_OFF = 0; //was :dL // Quoted identifiers are enable
public const int SQL_QI_ON = 1; //was :dL // Quoted identifiers are disabled
public const int SQL_QI_DEFAULT = SQL_QI_ON;
// Defines for use with SQL_COPT_SS_ANSI_NPW - Pre-Connect Option only
public const int SQL_AD_OFF = 0; //was :dL // ANSI NULLs, Padding and Warnings are enabled
public const int SQL_AD_ON = 1; //was :dL // ANSI NULLs, Padding and Warnings are disabled
public const int SQL_AD_DEFAULT = SQL_AD_ON;
// Defines for use with SQL_COPT_SS_CONCAT_NULL - Pre-Connect Option only
public const int SQL_CN_OFF = 0; //was :dL // CONCAT_NULL_YIELDS_NULL is off
public const int SQL_CN_ON = 1; //was :dL // CONCAT_NULL_YIELDS_NULL is on
public const int SQL_CN_DEFAULT = SQL_CN_ON;

// Defines for use with SQL_SOPT_SS_TEXTPTR_LOGGING
public const int SQL_TL_OFF = 0; //was :dL // No logging on text pointer ops
public const int SQL_TL_ON = 1; //was :dL // Logging occurs on text pointer ops
public const int SQL_TL_DEFAULT = SQL_TL_ON;
// Defines for use with SQL_SOPT_SS_HIDDEN_COLUMNS
public const int SQL_HC_OFF = 0; //was :dL // FOR BROWSE columns are hidden
public const int SQL_HC_ON = 1; //was :dL // FOR BROWSE columns are exposed
public const int SQL_HC_DEFAULT = SQL_HC_OFF;
// Defines for use with SQL_SOPT_SS_NOBROWSETABLE
public const int SQL_NB_OFF = 0; //was :dL // NO_BROWSETABLE is off
public const int SQL_NB_ON = 1; //was :dL // NO_BROWSETABLE is on
public const int SQL_NB_DEFAULT = SQL_NB_OFF;
// Defines for use with SQL_SOPT_SS_REGIONALIZE
public const int SQL_RE_OFF = 0; //was :dL // No regionalization occurs on output character conversions
public const int SQL_RE_ON = 1; //was :dL // Regionalization occurs on output character conversions
public const int SQL_RE_DEFAULT = SQL_RE_OFF;
// Defines for use with SQL_SOPT_SS_CURSOR_OPTIONS
public const int SQL_CO_OFF = 0; //was :dL // Clear all cursor options
public const int SQL_CO_FFO = 1; //was :dL // Fast-forward cursor will be used
public const int SQL_CO_AF = 2; //was :dL // Autofetch on cursor open
public const int SQL_CO_FFO_AF = (SQL_CO_FFO|SQL_CO_AF); // Fast-forward cursor with autofetch
public const int SQL_CO_FIREHOSE_AF = 4; //was :dL // Auto fetch on fire-hose cursors
public const int SQL_CO_DEFAULT = SQL_CO_OFF;
//SQL_SOPT_SS_NOCOUNT_STATUS
public const int SQL_NC_OFF = 0; //was :dL
public const int SQL_NC_ON = 1; //was :dL
//SQL_SOPT_SS_DEFER_PREPARE
public const int SQL_DP_OFF = 0; //was :dL
public const int SQL_DP_ON = 1; //was :dL
//SQL_COPT_SS_ENCRYPT
public const int SQL_EN_OFF = 0; //was :dL
public const int SQL_EN_ON = 1; //was :dL
//SQL_COPT_SS_BROWSE_CONNECT
public const int SQL_MORE_INFO_NO = 0; //was :dL
public const int SQL_MORE_INFO_YES = 1; //was :dL
//SQL_COPT_SS_BROWSE_CACHE_DATA
public const int SQL_CACHE_DATA_NO = 0; //was :dL
public const int SQL_CACHE_DATA_YES = 1; //was :dL
//SQL_COPT_SS_RESET_CONNECTION
public const int SQL_RESET_YES = 1; //was :dL
//SQL_COPT_SS_WARN_ON_CP_ERROR
public const int SQL_WARN_NO = 0; //was :dL
public const int SQL_WARN_YES = 1; //was :dL
// Defines returned by SQL_ATTR_CURSOR_TYPE/SQL_CURSOR_TYPE
public const int SQL_CURSOR_FAST_FORWARD_ONLY = 8; // Only returned by SQLGetStmtAttr/Option

// SQLColAttributes driver specific defines.
// SQLSet/GetDescField driver specific defines.
// Microsoft has 1200 thru 1249 reserved for Microsoft SQL Server driver usage.
public const int SQL_CA_SS_BASE = 1200;
public const int SQL_CA_SS_COLUMN_SSTYPE = (SQL_CA_SS_BASE+0); // dbcoltype/dbalttype
public const int SQL_CA_SS_COLUMN_UTYPE = (SQL_CA_SS_BASE+1); // dbcolutype/dbaltutype
public const int SQL_CA_SS_NUM_ORDERS = (SQL_CA_SS_BASE+2); // dbnumorders
public const int SQL_CA_SS_COLUMN_ORDER = (SQL_CA_SS_BASE+3); // dbordercol
public const int SQL_CA_SS_COLUMN_VARYLEN = (SQL_CA_SS_BASE+4); // dbvarylen
public const int SQL_CA_SS_NUM_COMPUTES = (SQL_CA_SS_BASE+5); // dbnumcompute
public const int SQL_CA_SS_COMPUTE_ID = (SQL_CA_SS_BASE+6); // dbnextrow status return
public const int SQL_CA_SS_COMPUTE_BYLIST = (SQL_CA_SS_BASE+7); // dbbylist
public const int SQL_CA_SS_COLUMN_ID = (SQL_CA_SS_BASE+8); // dbaltcolid
public const int SQL_CA_SS_COLUMN_OP = (SQL_CA_SS_BASE+9); // dbaltop
public const int SQL_CA_SS_COLUMN_SIZE = (SQL_CA_SS_BASE+10); // dbcollen
public const int SQL_CA_SS_COLUMN_HIDDEN = (SQL_CA_SS_BASE+11); // Column is hidden (FOR BROWSE)
public const int SQL_CA_SS_COLUMN_KEY = (SQL_CA_SS_BASE+12); // Column is key column (FOR BROWSE)
//#define SQL_DESC_BASE_COLUMN_NAME_OLD (SQL_CA_SS_BASE+13) //This is defined at another location.
public const int SQL_CA_SS_COLUMN_COLLATION = (SQL_CA_SS_BASE+14); // Column collation (only for chars)
public const int SQL_CA_SS_VARIANT_TYPE = (SQL_CA_SS_BASE+15);
public const int SQL_CA_SS_VARIANT_SQL_TYPE = (SQL_CA_SS_BASE+16);
public const int SQL_CA_SS_VARIANT_SERVER_TYPE = (SQL_CA_SS_BASE+17);
public const int SQL_CA_SS_MAX_USED = (SQL_CA_SS_BASE+18);



// SQL Server Data Type Tokens.
// New types for 6.0 and later servers
///* SQL Server Data Type Tokens. */
public const int SQLTEXT = 0x23;
public const int SQLVARBINARY = 0x25;
public const int SQLINTN = 0x26;
public const int SQLVARCHAR = 0x27;
public const int SQLBINARY = 0x2d;
public const int SQLIMAGE = 0x22;
public const int SQLCHARACTER = 0x2f;
public const int SQLINT1 = 0x30;
public const int SQLBIT = 0x32;
public const int SQLINT2 = 0x34;
public const int SQLINT4 = 0x38;
public const int SQLMONEY = 0x3c;
public const int SQLDATETIME = 0x3d;
public const int SQLFLT8 = 0x3e;
public const int SQLFLTN = 0x6d;
public const int SQLMONEYN = 0x6e;
public const int SQLDATETIMN = 0x6f;
public const int SQLFLT4 = 0x3b;
public const int SQLMONEY4 = 0x7a;
public const int SQLDATETIM4 = 0x3a;
// New types for 6.0 and later servers
public const int SQLDECIMAL = 0x6a;
public const int SQLNUMERIC = 0x6c;
// New types for 7.0 and later servers
public const int SQLUNIQUEID = 0x24;
public const int SQLBIGCHAR = 0xaf;
public const int SQLBIGVARCHAR = 0xa7;
public const int SQLBIGBINARY = 0xad;
public const int SQLBIGVARBINARY = 0xa5;
public const int SQLBITN = 0x68;
public const int SQLNCHAR = 0xef;
public const int SQLNVARCHAR = 0xe7;
public const int SQLNTEXT = 0x63;
// New for 7.x
public const int SQLINT8 = 0x7f;
public const int SQLVARIANT = 0x62;
// User Data Type definitions.
// Returned by SQLColAttributes/SQL_CA_SS_COLUMN_UTYPE.
public const int SQLudtBINARY = 3;
public const int SQLudtBIT = 16;
public const int SQLudtBITN = 0;
public const int SQLudtCHAR = 1;
public const int SQLudtDATETIM4 = 22;
public const int SQLudtDATETIME = 12;
public const int SQLudtDATETIMN = 15;
public const int SQLudtDECML = 24;
public const int SQLudtDECMLN = 26;
public const int SQLudtFLT4 = 23;
public const int SQLudtFLT8 = 8;
public const int SQLudtFLTN = 14;
public const int SQLudtIMAGE = 20;
public const int SQLudtINT1 = 5;
public const int SQLudtINT2 = 6;
public const int SQLudtINT4 = 7;
public const int SQLudtINTN = 13;
public const int SQLudtMONEY = 11;
public const int SQLudtMONEY4 = 21;
public const int SQLudtMONEYN = 17;
public const int SQLudtNUM = 10;
public const int SQLudtNUMN = 25;
public const int SQLudtSYSNAME = 18;
public const int SQLudtTEXT = 19;
public const int SQLudtTIMESTAMP = 80;
public const int SQLudtUNIQUEIDENTIFIER = 0;
public const int SQLudtVARBINARY = 4;
public const int SQLudtVARCHAR = 2;
public const int MIN_USER_DATATYPE = 256;
// Aggregate operator types.
// Returned by SQLColAttributes/SQL_CA_SS_COLUMN_OP.
public const int SQLAOPSTDEV = 0x30; // Standard deviation
public const int SQLAOPSTDEVP = 0x31; // Standard deviation population
public const int SQLAOPVAR = 0x32; // Variance
public const int SQLAOPVARP = 0x33; // Variance population
public const int SQLAOPCNT = 0x4b; // Count
public const int SQLAOPSUM = 0x4d; // Sum
public const int SQLAOPAVG = 0x4f; // Average
public const int SQLAOPMIN = 0x51; // Min
public const int SQLAOPMAX = 0x52; // Max
public const int SQLAOPANY = 0x53; // Any
public const int SQLAOPNOOP = 0x56; // None

// SQLGetInfo driver specific defines.
// Microsoft has 1151 thru 1200 reserved for Microsoft SQL Server driver usage.
public const int SQL_INFO_SS_FIRST = 1199;
public const int SQL_INFO_SS_NETLIB_NAMEW = (SQL_INFO_SS_FIRST+0); // dbprocinfo
public const int SQL_INFO_SS_NETLIB_NAMEA = (SQL_INFO_SS_FIRST+1); // dbprocinfo
public const int SQL_INFO_SS_MAX_USED = SQL_INFO_SS_NETLIB_NAMEA;
//#ifdef UNICODE
public const int SQL_INFO_SS_NETLIB_NAME = SQL_INFO_SS_NETLIB_NAMEW;
//#else
//public const int SQL_INFO_SS_NETLIB_NAME = SQL_INFO_SS_NETLIB_NAMEA;
//#endif

// Driver specific SQL type defines.
// Microsoft has -150 thru -199 reserved for Microsoft SQL Server driver usage.
public const int SQL_SS_VARIANT = -150;

// SQLGetDiagField driver specific defines.
// Microsoft has -1150 thru -1199 reserved for Microsoft SQL Server driver usage.
public const int SQL_DIAG_SS_BASE = (-1150);
public const int SQL_DIAG_SS_MSGSTATE = (SQL_DIAG_SS_BASE);
public const int SQL_DIAG_SS_SEVERITY = (SQL_DIAG_SS_BASE-1);
public const int SQL_DIAG_SS_SRVNAME = (SQL_DIAG_SS_BASE-2);
public const int SQL_DIAG_SS_PROCNAME = (SQL_DIAG_SS_BASE-3);
public const int SQL_DIAG_SS_LINE = (SQL_DIAG_SS_BASE-4);

// SQLGetDiagField/SQL_DIAG_DYNAMIC_FUNCTION_CODE driver specific defines.
// Microsoft has -200 thru -299 reserved for Microsoft SQL Server driver usage.
public const int SQL_DIAG_DFC_SS_BASE = (-200);
public const int SQL_DIAG_DFC_SS_ALTER_DATABASE = (SQL_DIAG_DFC_SS_BASE-0);
public const int SQL_DIAG_DFC_SS_CHECKPOINT = (SQL_DIAG_DFC_SS_BASE-1);
public const int SQL_DIAG_DFC_SS_CONDITION = (SQL_DIAG_DFC_SS_BASE-2);
public const int SQL_DIAG_DFC_SS_CREATE_DATABASE = (SQL_DIAG_DFC_SS_BASE-3);
public const int SQL_DIAG_DFC_SS_CREATE_DEFAULT = (SQL_DIAG_DFC_SS_BASE-4);
public const int SQL_DIAG_DFC_SS_CREATE_PROCEDURE = (SQL_DIAG_DFC_SS_BASE-5);
public const int SQL_DIAG_DFC_SS_CREATE_RULE = (SQL_DIAG_DFC_SS_BASE-6);
public const int SQL_DIAG_DFC_SS_CREATE_TRIGGER = (SQL_DIAG_DFC_SS_BASE-7);
public const int SQL_DIAG_DFC_SS_CURSOR_DECLARE = (SQL_DIAG_DFC_SS_BASE-8);
public const int SQL_DIAG_DFC_SS_CURSOR_OPEN = (SQL_DIAG_DFC_SS_BASE-9);
public const int SQL_DIAG_DFC_SS_CURSOR_FETCH = (SQL_DIAG_DFC_SS_BASE-10);
public const int SQL_DIAG_DFC_SS_CURSOR_CLOSE = (SQL_DIAG_DFC_SS_BASE-11);
public const int SQL_DIAG_DFC_SS_DEALLOCATE_CURSOR = (SQL_DIAG_DFC_SS_BASE-12);
public const int SQL_DIAG_DFC_SS_DBCC = (SQL_DIAG_DFC_SS_BASE-13);
public const int SQL_DIAG_DFC_SS_DISK = (SQL_DIAG_DFC_SS_BASE-14);
public const int SQL_DIAG_DFC_SS_DROP_DATABASE = (SQL_DIAG_DFC_SS_BASE-15);
public const int SQL_DIAG_DFC_SS_DROP_DEFAULT = (SQL_DIAG_DFC_SS_BASE-16);
public const int SQL_DIAG_DFC_SS_DROP_PROCEDURE = (SQL_DIAG_DFC_SS_BASE-17);
public const int SQL_DIAG_DFC_SS_DROP_RULE = (SQL_DIAG_DFC_SS_BASE-18);
public const int SQL_DIAG_DFC_SS_DROP_TRIGGER = (SQL_DIAG_DFC_SS_BASE-19);
public const int SQL_DIAG_DFC_SS_DUMP_DATABASE = (SQL_DIAG_DFC_SS_BASE-20);
public const int SQL_DIAG_DFC_SS_DUMP_TABLE = (SQL_DIAG_DFC_SS_BASE-21);
public const int SQL_DIAG_DFC_SS_DUMP_TRANSACTION = (SQL_DIAG_DFC_SS_BASE-22);
public const int SQL_DIAG_DFC_SS_GOTO = (SQL_DIAG_DFC_SS_BASE-23);
public const int SQL_DIAG_DFC_SS_INSERT_BULK = (SQL_DIAG_DFC_SS_BASE-24);
public const int SQL_DIAG_DFC_SS_KILL = (SQL_DIAG_DFC_SS_BASE-25);
public const int SQL_DIAG_DFC_SS_LOAD_DATABASE = (SQL_DIAG_DFC_SS_BASE-26);
public const int SQL_DIAG_DFC_SS_LOAD_HEADERONLY = (SQL_DIAG_DFC_SS_BASE-27);
public const int SQL_DIAG_DFC_SS_LOAD_TABLE = (SQL_DIAG_DFC_SS_BASE-28);
public const int SQL_DIAG_DFC_SS_LOAD_TRANSACTION = (SQL_DIAG_DFC_SS_BASE-29);
public const int SQL_DIAG_DFC_SS_PRINT = (SQL_DIAG_DFC_SS_BASE-30);
public const int SQL_DIAG_DFC_SS_RAISERROR = (SQL_DIAG_DFC_SS_BASE-31);
public const int SQL_DIAG_DFC_SS_READTEXT = (SQL_DIAG_DFC_SS_BASE-32);
public const int SQL_DIAG_DFC_SS_RECONFIGURE = (SQL_DIAG_DFC_SS_BASE-33);
public const int SQL_DIAG_DFC_SS_RETURN = (SQL_DIAG_DFC_SS_BASE-34);
public const int SQL_DIAG_DFC_SS_SELECT_INTO = (SQL_DIAG_DFC_SS_BASE-35);
public const int SQL_DIAG_DFC_SS_SET = (SQL_DIAG_DFC_SS_BASE-36);
public const int SQL_DIAG_DFC_SS_SET_IDENTITY_INSERT = (SQL_DIAG_DFC_SS_BASE-37);
public const int SQL_DIAG_DFC_SS_SET_ROW_COUNT = (SQL_DIAG_DFC_SS_BASE-38);
public const int SQL_DIAG_DFC_SS_SET_STATISTICS = (SQL_DIAG_DFC_SS_BASE-39);
public const int SQL_DIAG_DFC_SS_SET_TEXTSIZE = (SQL_DIAG_DFC_SS_BASE-40);
public const int SQL_DIAG_DFC_SS_SETUSER = (SQL_DIAG_DFC_SS_BASE-41);
public const int SQL_DIAG_DFC_SS_SHUTDOWN = (SQL_DIAG_DFC_SS_BASE-42);
public const int SQL_DIAG_DFC_SS_TRANS_BEGIN = (SQL_DIAG_DFC_SS_BASE-43);
public const int SQL_DIAG_DFC_SS_TRANS_COMMIT = (SQL_DIAG_DFC_SS_BASE-44);
public const int SQL_DIAG_DFC_SS_TRANS_PREPARE = (SQL_DIAG_DFC_SS_BASE-45);
public const int SQL_DIAG_DFC_SS_TRANS_ROLLBACK = (SQL_DIAG_DFC_SS_BASE-46);
public const int SQL_DIAG_DFC_SS_TRANS_SAVE = (SQL_DIAG_DFC_SS_BASE-47);
public const int SQL_DIAG_DFC_SS_TRUNCATE_TABLE = (SQL_DIAG_DFC_SS_BASE-48);
public const int SQL_DIAG_DFC_SS_UPDATE_STATISTICS = (SQL_DIAG_DFC_SS_BASE-49);
public const int SQL_DIAG_DFC_SS_UPDATETEXT = (SQL_DIAG_DFC_SS_BASE-50);
public const int SQL_DIAG_DFC_SS_USE = (SQL_DIAG_DFC_SS_BASE-51);
public const int SQL_DIAG_DFC_SS_WAITFOR = (SQL_DIAG_DFC_SS_BASE-52);
public const int SQL_DIAG_DFC_SS_WRITETEXT = (SQL_DIAG_DFC_SS_BASE-53);
public const int SQL_DIAG_DFC_SS_DENY = (SQL_DIAG_DFC_SS_BASE-54);
public const int SQL_DIAG_DFC_SS_SET_XCTLVL = (SQL_DIAG_DFC_SS_BASE-55);
// Severity codes for SQL_DIAG_SS_SEVERITY
public const int EX_ANY = 0;
public const int EX_INFO = 10;
public const int EX_MAXISEVERITY = EX_INFO;
public const int EX_MISSING = 11;
public const int EX_TYPE = 12;
public const int EX_DEADLOCK = 13;
public const int EX_PERMIT = 14;
public const int EX_SYNTAX = 15;
public const int EX_USER = 16;
public const int EX_RESOURCE = 17;
public const int EX_INTOK = 18;
public const int MAXUSEVERITY = EX_INTOK;
public const int EX_LIMIT = 19;
public const int EX_CMDFATAL = 20;
public const int MINFATALERR = EX_CMDFATAL;
public const int EX_DBFATAL = 21;
public const int EX_TABCORRUPT = 22;
public const int EX_DBCORRUPT = 23;
public const int EX_HARDWARE = 24;
public const int EX_CONTROL = 25;
// Internal server datatypes - used when binding to SQL_C_BINARY
//#ifndef MAXNUMERICLEN // Resolve ODS/DBLib conflicts
// DB-Library datatypes
public const int DBMAXCHAR = (8000+1); // Max length of DBVARBINARY and DBVARCHAR, etc. +1 for zero byte
public const int MAXNAME = (SQL_MAX_SQLSERVERNAME+1); // Max server identifier length including zero byte
//#ifdef UNICODE
//typedef wchar_t DBCHAR;
//#else
//typedef char DBCHAR;
//#endif
//typedef unsigned char DBBINARY;
//typedef unsigned char DBTINYINT;
//typedef short DBSMALLINT;
//typedef unsigned short DBUSMALLINT;
//typedef double DBFLT8;
//typedef unsigned char DBBIT;
//typedef unsigned char DBBOOL;
//typedef float DBFLT4;
//typedef DBFLT4 DBREAL;
//typedef UINT DBUBOOL;
//typedef struct dbvarychar
//{
// DBSMALLINT len;
// DBCHAR str[DBMAXCHAR];
//} DBVARYCHAR;
//typedef struct dbvarybin
//{
// DBSMALLINT len;
// BYTE array[DBMAXCHAR];
//} DBVARYBIN;
//typedef struct dbmoney
//{ // Internal representation of MONEY data type
// LONG mnyhigh; // Money value *10,000 (High 32 bits/signed)
// ULONG mnylow; // Money value *10,000 (Low 32 bits/unsigned)
//} DBMONEY;
//typedef struct dbdatetime
//{ // Internal representation of DATETIME data type
// LONG dtdays; // No of days since Jan-1-1900 (maybe negative)
// ULONG dttime; // No. of 300 hundredths of a second since midnight
//} DBDATETIME;
//typedef struct dbdatetime4
//{ // Internal representation of SMALLDATETIME data type
// USHORT numdays; // No of days since Jan-1-1900
// USHORT nummins; // No. of minutes since midnight
//} DBDATETIM4;
//typedef LONG DBMONEY4; // Internal representation of SMALLMONEY data type
// Money value *10,000
//typedef DBNUM_PREC_TYPE = BYTE;
//typedef DBNUM_SCALE_TYPE = BYTE;
//typedef DBNUM_VAL_TYPE = BYTE;
//#if (ODBCVER < 0x0300)
//public const int MAXNUMERICLEN = 16;
//typedef struct dbnumeric
//{ // Internal representation of NUMERIC data type
// DBNUM_PREC_TYPE precision; // Precision
// DBNUM_SCALE_TYPE scale; // Scale
// BYTE sign; // Sign (1 if positive, 0 if negative)
// DBNUM_VAL_TYPE val[MAXNUMERICLEN]; // Value
//} DBNUMERIC;
//typedef DBNUMERIC DBDECIMAL;// Internal representation of DECIMAL data type
//#else // Use ODBC 3.0 definitions since same as DBLib
public const int MAXNUMERICLEN = SQL_MAX_NUMERIC_LEN;
//typedef SQL_NUMERIC_STRUCT DBNUMERIC;
//typedef SQL_NUMERIC_STRUCT DBDECIMAL;
//#endif
//#endif // MAXNUMERICLEN
//#ifndef System.Int32 i
//typedef int System.Int32 i;
//typedef long System.Int64 dbint;
//#ifndef _LPCBYTE_DEFINED
//#define _LPCBYTE_DEFINED
//typedef const LPBYTE byte lpcbyte;
//#endif
//typedef System.Int64 dbint * LPDBINT;
//#endif
///*****************************************************************
// This struct is a global used for
// gathering statistical data on the driver.
// Access to this structure is controlled via the
// pStatCrit;
//******************************************************************/
//typedef struct sqlperf
//{
// Application Profile Statistics
// DWORD TimerResolution;
// DWORD SQLidu;
// DWORD SQLiduRows;
// DWORD SQLSelects;
// DWORD SQLSelectRows;
// DWORD Transactions;
// DWORD SQLPrepares;
// DWORD ExecDirects;
// DWORD SQLExecutes;
// DWORD CursorOpens;
// DWORD CursorSize;
// DWORD CursorUsed;
// LDOUBLE PercentCursorUsed;
// LDOUBLE AvgFetchTime;
// LDOUBLE AvgCursorSize;
// LDOUBLE AvgCursorUsed;
// DWORD SQLFetchTime;
// DWORD SQLFetchCount;
// DWORD CurrentStmtCount;
// DWORD MaxOpenStmt;
// DWORD SumOpenStmt;
// Connection Statistics
// DWORD CurrentConnectionCount;
// DWORD MaxConnectionsOpened;
// DWORD SumConnectionsOpened;
// DWORD SumConnectiontime;
// LDOUBLE AvgTimeOpened;
// Network Statistics
// DWORD ServerRndTrips;
// DWORD BuffersSent;
// DWORD BuffersRec;
// DWORD BytesSent;
// DWORD BytesRec;
// Time Statistics;
// DWORD msExecutionTime;
// DWORD msNetWorkServerTime;
//} SQLPERF;
// The following are options for SQL_COPT_SS_PERF_DATA and SQL_COPT_SS_PERF_QUERY
public const int SQL_PERF_START = 1; // Starts the driver sampling performance data.
public const int SQL_PERF_STOP = 2; // Stops the counters from sampling performance data.
// The following are defines for SQL_COPT_SS_PERF_DATA_LOG
//public const int SQL_SS_DL_DEFAULT = TEXT("C:\\STATS.LOG");
// The following are defines for SQL_COPT_SS_PERF_QUERY_LOG
//public const int SQL_SS_QL_DEFAULT = TEXT("C:\\QUERY.LOG");
// The following are defines for SQL_COPT_SS_PERF_QUERY_INTERVAL
public const int SQL_SS_QI_DEFAULT = 30000; // 30,000 milliseconds
// ODBC BCP prototypes and defines
// Return codes
public const int SUCCEED = 1;
public const int FAIL = 0;
public const int SUCCEED_ABORT = 2;
public const int SUCCEED_ASYNC = 3;
// Transfer directions
public const int DB_IN = 1; // Transfer from client to server
public const int DB_OUT = 2; // Transfer from server to client
// bcp_control option
public const int BCPMAXERRS = 1; // Sets max errors allowed
public const int BCPFIRST = 2; // Sets first row to be copied out
public const int BCPLAST = 3; // Sets number of rows to be copied out
public const int BCPBATCH = 4; // Sets input batch size
public const int BCPKEEPNULLS = 5; // Sets to insert NULLs for empty input values
public const int BCPABORT = 6; // Sets to have bcpexec return SUCCEED_ABORT
public const int BCPODBC = 7; // Sets ODBC canonical character output
public const int BCPKEEPIDENTITY = 8; // Sets IDENTITY_INSERT on
public const int BCP6xFILEFMT = 9; // DEPRECATED: Sets 6x file format on
public const int BCPHINTSA = 10; // Sets server BCP hints (ANSI string)
public const int BCPHINTSW = 11; // Sets server BCP hints (UNICODE string)
public const int BCPFILECP = 12; // Sets clients code page for the file
public const int BCPUNICODEFILE = 13; // Sets that the file contains unicode header
public const int BCPTEXTFILE = 14; // Sets BCP mode to expect a text file and to detect Unicode or ANSI automatically
public const int BCPFILEFMT = 15; // Sets file format version 
// BCPFILECP values
// Any valid code page that is installed on the client can be passed plus:
public const int BCPFILECP_ACP = 0; // Data in file is in Windows code page
public const int BCPFILECP_OEMCP = 1; // Data in file is in OEM code page (default)
public const int BCPFILECP_RAW = (-1);// Data in file is in Server code page (no conversion)
// bcp_collen definition
public const int SQL_VARLEN_DATA = (-10); // Use default length for column

//#ifdef UNICODE
//typedef SQLLinkedCatalogs = SQLLinkedCatalogsW;
//#else
//typedef SQLLinkedCatalogs = SQLLinkedCatalogsA;
//#endif
// BCP column format properties
public const int BCP_FMT_TYPE = 0x01;
public const int BCP_FMT_INDICATOR_LEN = 0x02;
public const int BCP_FMT_DATA_LEN = 0x03;
public const int BCP_FMT_TERMINATOR = 0x04;
public const int BCP_FMT_SERVER_COL = 0x05;
public const int BCP_FMT_COLLATION = 0x06;
public const int BCP_FMT_COLLATION_ID = 0x07;
// The following options have been deprecated
public const int SQL_FAST_CONNECT = (SQL_COPT_SS_BASE+0);
// Defines for use with SQL_FAST_CONNECT - only useable before connecting
public const int SQL_FC_OFF = 0; //was :dL // Fast connect is off
public const int SQL_FC_ON = 1; //was :dL // Fast connect is on
public const int SQL_FC_DEFAULT = SQL_FC_OFF;
public const int SQL_COPT_SS_ANSI_OEM = (SQL_COPT_SS_BASE+6);
public const int SQL_AO_OFF = 0; //was :dL
public const int SQL_AO_ON = 1; //was :dL
public const int SQL_AO_DEFAULT = SQL_AO_OFF;
// Define old names
public const int SQL_REMOTE_PWD = SQL_COPT_SS_REMOTE_PWD;
public const int SQL_USE_PROCEDURE_FOR_PREPARE =
SQL_COPT_SS_USE_PROC_FOR_PREP;
public const int SQL_INTEGRATED_SECURITY = SQL_COPT_SS_INTEGRATED_SECURITY;
public const int SQL_PRESERVE_CURSORS = SQL_COPT_SS_PRESERVE_CURSORS;
public const int SQL_TEXTPTR_LOGGING = SQL_SOPT_SS_TEXTPTR_LOGGING;
public const int SQL_CA_SS_BASE_COLUMN_NAME = SQL_DESC_BASE_COLUMN_NAME;
public const int SQLDECIMALN = 0x6a;
public const int SQLNUMERICN = 0x6c;
//#ifdef __cplusplus
//} /* End of extern "C" { */
//#endif /* __cplusplus */
//#endif
// End of odbcss.h
//
#endregion
}

	[ComVisible(false)]
	public class OdbcException : System.Exception
	{
		public OdbcException(string msg)
			: base(msg)
		{ }

		public static void ThrowOnError(Int16 result, OdbcHandleType type, IntPtr connectionHandle)
		{
			if (result == 0 || result == 1)
				return;

			//			SQLCHAR sqlstate [5];
			//			SQLINTEGER nativeErrorPtr;
			//			SQLCHAR messageText[1024];
			//			SQLSMALLINT messageLength;

			StringBuilder sqlstate = new StringBuilder(new string(' ', 256));
			Int32 nativeError;
			StringBuilder messageText = new StringBuilder(new string(' ', 256));
			//messageText.Resize(512);
			Int16 messageLength;

			Int16 sqlReturn = bcp.SQLGetDiagRec((Int16) type, connectionHandle,
																					1, sqlstate, out nativeError, messageText,
																					(Int16) messageText.Length, out messageLength);

			//																					 out Int32 nativeError, out string messageText,
			//																						Int16 bufferLength, out Int16 textLength);

			//			SQLRETURN sqlReturn = SQLGetDiagRecA(SQL_HANDLE_DBC, hConnection, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);

			throw new OdbcException(messageText.ToString());
		}
	}



// -----------------------------------------------------------------

// Enumerations

public enum OdbcHandleType
{
Env = 1,
Dbc = 2,
Stmt = 3,
Desc = 4
};

public enum OdbcReturn : short
{
Error = -1,
InvalidHandle = -2,
StillExecuting = 2,
NeedData = 99,
Success = 0,
SuccessWithInfo = 1
}

public enum OdbcEnv
{
OdbcVersion = 200,
ConnectionPooling = 201,
CPMatch = 202
}

[StructLayout(LayoutKind.Sequential)]
public struct OdbcTimestamp
{
public short year;
public ushort month;
public ushort day;
public ushort hour;
public ushort minute;
public ushort second;
public ulong fraction;
}


struct DBNUMERIC
{ // Internal representation of NUMERIC data type
//typedef DBNUM_PREC_TYPE = BYTE;
//typedef DBNUM_SCALE_TYPE = BYTE;
//typedef DBNUM_VAL_TYPE = BYTE;
//byte precision; // Precision
//byte scale; // Scale
//byte sign; // Sign (1 if positive, 0 if negative)
//byte[] val; //[MAXNUMERICLEN]; // Value
}
}





