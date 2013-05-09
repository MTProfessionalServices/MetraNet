using System;
using System.Runtime.InteropServices;

namespace WindowsInstaller
{
	[ComImport, Guid("000C1090-0000-0000-C000-000000000046")] 
	public class Installer
	{
	}

	public enum PropertyId
	{
		//PID_DICTIONARY = 0, // Special format, not support by SummaryInfo object 
		PID_CODEPAGE = 1, //  VT_I2 
		PID_TITLE = 2, //  VT_LPSTR 
		PID_SUBJECT = 3, //  VT_LPSTR 
		PID_AUTHOR = 4, //  VT_LPSTR 
		PID_KEYWORDS = 5, //  VT_LPSTR 
		PID_COMMENTS = 6, //  VT_LPSTR 
		PID_TEMPLATE = 7, //  VT_LPSTR 
		PID_LASTAUTHOR = 8, //  VT_LPSTR 
		PID_REVNUMBER = 9, //  VT_LPSTR 
		PID_EDITTIME = 10, //  VT_FILETIME 
		PID_LASTPRINTED = 11, //  VT_FILETIME 
		PID_CREATE_DTM = 12, //  VT_FILETIME 
		PID_LASTSAVE_DTM = 13, //  VT_FILETIME 
		PID_PAGECOUNT = 14, //  VT_I4 
		PID_WORDCOUNT = 15, //  VT_I4 
		PID_CHARCOUNT = 16, //  VT_I4 
		PID_THUMBNAIL = 17, //  VT_CF (not supported) 
		PID_APPNAME = 18, //  VT_LPSTR 
		PID_SECURITY = 19, //  VT_I4 
	}

	public enum ColumnType
	{
		icdLong       = 0,
		icdShort      = 0x400,
		icdObject     = 0x800,
		icdString     = 0xC00,
		icdNullable   = 0x1000,
		icdPrimaryKey = 0x2000,
		icdNoNulls    = 0x0000,
		icdPersistent = 0x0100,
		icdTemporary  = 0x0000,
	}
}
