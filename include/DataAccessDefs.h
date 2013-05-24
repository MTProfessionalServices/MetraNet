/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 ***************************************************************************/

#ifndef __DATAACCESSDEFS_H
#define __DATAACCESSDEFS_H

#include <list>
#include <string>

// define string constants ...
const wchar_t * const DEFAULT_DATABASE_TYPE = L"{SQL Server}";
const wchar_t * const ORACLE_DATABASE_TYPE = L"{Oracle}" ;
const wchar_t * const DEFAULT_PROVIDER_TYPE = L"MSDASQL";
const wchar_t * const SQLSERVER_PROVIDER_TYPE = L"SQLOLEDB" ;
const wchar_t * const ORACLE_PROVIDER_TYPE = L"OraOLEDB.Oracle"; // L"MSDAORA" ;
const wchar_t * const EARLIEST_SUPPORTED_ADO_VERSION = L"1.50.2404" ;
const wchar_t * const ADO_FILE_DIRECTORY = L"\\program files\\common files\\system\\ado\\msado15.dll" ;
const DWORD ADOERROR_OBJECT_CLOSED = 0x800A0E78 ;
const long DEFAULT_TIMEOUT_VALUE = 30 ;

const wchar_t * const MTACCESSTYPE_ADO = L"ADO" ;
const wchar_t * const MTACCESSTYPE_ADO_DSN = L"ADO-DSN" ;
const wchar_t * const MTACCESSTYPE_OLEDB = L"OLEDB" ;
const wchar_t * const MTACCESSTYPE_OLEDB_DSN = L"OLEDB-DSN" ;
const wchar_t * const ENCRYPTED_STRING = L"encrypted" ;

// defines ...
const char * const QUERY_ADAPTER_FILE = "QueryAdapter.xml" ;
const char * const DATABASE_CONFIGDIR = "\\queries\\Database" ;
const char * const DBACCESS_FILE = "dbaccess.xml" ;

typedef std::list<std::wstring> ErrorList;
typedef ErrorList::iterator ErrorListIter;

#endif
