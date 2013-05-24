/**************************************************************************
 * @doc DBSQLRowset
 *
 * @module  Encapsulation for accessing the MTRowset.
 *
 * This class encapsulates accessing the DBSQLRowset, a rowset that was
 * generated from a SQL statement.
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | DBSQLRowset
 ***************************************************************************/

#ifndef __DBSQLRowset_H
#define __DBSQLRowset_H

#include <comdef.h>
#include <DBRowset.h>
#include <errobj.h>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <map>
#include <string>

// import the ADO typelibrary - to allow easy syntax for ADO
#pragma warning( disable : 4146 )
#import <..\ThirdParty\ADO\msado15.dll> no_namespace rename( "EOF", "adoEOF" )
#pragma warning( default : 4146 )

// disable warning ...
#pragma warning( disable : 4251 4275 )

// create typedefs for the fields collections
typedef std::map<long, FieldPtr> RowsetFieldMapByLong ;
typedef std::pair<long, FieldPtr> RowsetFieldPairByLong ;
typedef std::map<std::wstring, FieldPtr> RowsetFieldMapByString ;
typedef std::pair<std::wstring, FieldPtr> RowsetFieldPairByString ;

extern	BOOL gDBTypeIsOracle ;

// @class DBSQLRowset
class DBSQLRowset :
public DBRowset,
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBSQLRowset() ;

	// @cmember Destructor
  DLL_EXPORT virtual ~DBSQLRowset() ;

  // @cmember Get the name of the specified column
  DLL_EXPORT virtual BOOL GetName (const _variant_t &arIndex, std::wstring &aName) ;
  // @cmember Get the value of the specified column
  DLL_EXPORT virtual BOOL GetValue (const _variant_t &arIndex, _variant_t &aValue,bool bLog=true) ;
  // @cmember Get the integer value of the specified column
  DLL_EXPORT virtual BOOL GetIntValue (const _variant_t &arIndex, int &aValue) ;
  // @cmember Get the long value of the specified column
  DLL_EXPORT virtual BOOL GetLongValue (const _variant_t &arIndex, long &aValue) ;
  // @cmember Get the float value of the specified column
  DLL_EXPORT virtual BOOL GetFloatValue (const _variant_t &arIndex, double &aValue) ;
  DLL_EXPORT virtual BOOL GetDecimalValue (const _variant_t &arIndex, DECIMAL &aValue) ;
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetCharValue (const _variant_t &arIndex, std::string &aValue) ;
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetWCharValue (const _variant_t &arIndex, std::wstring &aValue) ;
  // @cmember Get the type of the specified column
  DLL_EXPORT virtual BOOL GetType (const _variant_t &arIndex, std::wstring &aType) ;
  // @cmember Get the number of columns per row
  DLL_EXPORT virtual int GetCount() ;
  // @cmember Move to the next row in the rowset
  DLL_EXPORT virtual BOOL MoveNext() ;
  // @cmember Move to the first row in the rowset
  DLL_EXPORT virtual BOOL MoveFirst() ;
  // @cmember Move to the last row in the rowset
  DLL_EXPORT virtual BOOL MoveLast() ;
  // @cmember Get the number of items in the rowset
  DLL_EXPORT virtual int GetRecordCount() ;
  // @cmember Get the current page size
  DLL_EXPORT virtual int GetPageSize() ;
   // @cmember Set the current page size
  DLL_EXPORT virtual void SetPageSize(int aPageSize);
  // @cmember Get the number of pages in the current rowset
  DLL_EXPORT virtual int GetPageCount() ;
  // @cmember Go to the specified page
  DLL_EXPORT virtual BOOL GoToPage(int nPageNum) ;
  // @cmember Get the current page
  DLL_EXPORT virtual int GetPage();
  // @cmember Check to see if we've reached the end of the rowset
  DLL_EXPORT virtual BOOL AtEOF() ;
  DLL_EXPORT virtual BOOL Sort(const std::wstring &arSortOrder);
  DLL_EXPORT virtual BOOL Filter(const std::wstring &arFilterCriteria) ;
  DLL_EXPORT virtual BOOL Refresh() ;
  DLL_EXPORT virtual BOOL PutValue (const _variant_t &arIndex, const _variant_t &aValue) ;

	// The AddRow method adds a row to the rowset.
	DLL_EXPORT void AddRow();

	// The AddColumnData adds the data in the specified column.
	// CS
	// I changed this stupid API so I didn't need to check trivial boolean results on
	// every friggin method.  These call now throw COM errors

	/////////////////////////////////////////////////////////////////////////////////
	// disconnected recordset API

	DLL_EXPORT void AddColumnData(const wchar_t * apName, _variant_t aValue);

	// The ModifyColumnData modifies the data in the specified column.
	DLL_EXPORT void ModifyColumnData(const wchar_t * apName, _variant_t aValue);

	// The AddColumnDefinition method adds a new column to the rowset definition.
	DLL_EXPORT void AddColumnDefinition(const wchar_t * apName, const wchar_t * apType,
																			int aLen);
	DLL_EXPORT void AddColumnDefinition(const wchar_t * apName, DataTypeEnum aType,
																			int aLen);
	//
	/////////////////////////////////////////////////////////////////////////////////

  // class specific member functions ...
  // @cmember Initialize the Rowset
  DLL_EXPORT BOOL Init() ;
  DLL_EXPORT BOOL InitDisconnected();
  DLL_EXPORT BOOL OpenDisconnected();

  // @cmember Get the recordset pointer
  DLL_EXPORT _RecordsetPtr &GetRecordsetPtr() ;
	DLL_EXPORT void PutRecordSet(_RecordsetPtr&);
	DLL_EXPORT BOOL PutRecordSetAsIDispatch(IDispatch* pDisp);

	DLL_EXPORT static void SetDBTypeIsOracleFlag(BOOL aDBTypeIsOracle) ;
	DLL_EXPORT BOOL GetDBTypeIsOracleFlag() ;

	// filter support
	DLL_EXPORT BOOL SetFilterString(const wchar_t* pFilter);
	DLL_EXPORT void ResetFilter();
  DLL_EXPORT void RemoveRow();
// @access Protected:
protected:
  void GetFieldPtr(const _variant_t &arIndex, FieldPtr &arFieldPtr) ;
  void TearDown() ;

  _RecordsetPtr  mRowset ;
  RowsetFieldMapByLong mFieldCollByLong ;
  RowsetFieldMapByString mFieldCollByString ;

// @access Private:
private:
  // @cmember the logging object
	MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger;

	static BOOL mDBTypeIsOracle ;
} ;

// reenable warning ...
#pragma warning( default : 4251 4275)

#endif

