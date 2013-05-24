/**************************************************************************
 * @doc DBInMemRowset
 * 
 * @module  Encapsulation for accessing the MTRowset.
 * 
 * This class encapsulates accessing the MTRowset.
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
 * @index | DBInMemRowset
 ***************************************************************************/

#ifndef __DBInMemRowset_H
#define __DBInMemRowset_H

#include <comdef.h>
#include <string>
#include <vector>
#include <map>
#include <DBRowset.h>
#include <DBRowsetFields.h>
#include <errobj.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

// disable warning ...
#pragma warning( disable : 4251 4275 )

typedef std::map<std::wstring, int> DBFIELDSDEFINITIONMAP ;
typedef std::pair<std::wstring, int> DBFIELDSDEFINITIONPAIR ;

typedef struct 
{
  wchar_t FieldName[30] ;
  wchar_t FieldType[30] ;
} FIELD_DEFINITION ;

class DBRowsetFields ;

// @class DBInMemRowset
class DBInMemRowset :
public DBRowset,
private std::vector<DBRowsetFields *>,
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBInMemRowset() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBInMemRowset() ;

  // @cmember Get the name of the specified column
  DLL_EXPORT virtual BOOL GetName (const _variant_t &arIndex, std::wstring  &aName) ;
  // @cmember Get the value of the specified column
  DLL_EXPORT virtual BOOL GetValue (const _variant_t &arIndex, _variant_t &aValue,bool bLog=true) ;
  // @cmember Get the integer value of the specified column
  DLL_EXPORT virtual BOOL GetIntValue (const _variant_t &arIndex, int &aValue) ;
  // @cmember Get the float value of the specified column
  DLL_EXPORT virtual BOOL GetFloatValue (const _variant_t &arIndex, double &aValue) ;
  DLL_EXPORT virtual BOOL GetDecimalValue (const _variant_t &arIndex, DECIMAL &aValue);
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetCharValue (const _variant_t &arIndex, std::string  &aValue) ;
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetWCharValue (const _variant_t &arIndex, std::wstring  &aValue) ;
  // @cmember Get the type of the specified column
  DLL_EXPORT virtual BOOL GetType (const _variant_t &arIndex, std::wstring  &aType) ;
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
  DLL_EXPORT virtual BOOL Sort(const std::wstring  &arSortOrder) ;
  DLL_EXPORT virtual BOOL Filter(const std::wstring  &arFilterCriteria) ;
  DLL_EXPORT virtual BOOL Refresh() ;

	// class specific member functions ...
	// @cmember Add a field definition
	DLL_EXPORT BOOL AddFieldDefinition (const std::wstring  &arName, const std::wstring  &arType) ;
	// @cmember Add field data to the current row in the rowset
	DLL_EXPORT BOOL AddFieldData (const std::wstring  &arName, const std::wstring  &arValue) ;
  // @cmember Add field data to the current row in the rowset
	DLL_EXPORT BOOL AddFieldData (const std::wstring  &arName, const _variant_t &arValue) ;
  // @cmember Modify the field data in the current row in the rowset
	DLL_EXPORT BOOL ModifyFieldData (const std::wstring  &arName, const _variant_t &arValue) ;
	// @cmember Add a new row to the rowset and make it the current row
	DLL_EXPORT BOOL AddRow() ;
  DLL_EXPORT virtual BOOL SetFilterString(const wchar_t* pFilter) { return Filter(pFilter); }

	// no implementation!!
	DLL_EXPORT virtual void ResetFilter() {}
  DLL_EXPORT virtual void RemoveRow() {}

// @access Protected:
protected:

// @access Private:
private:
	// @cmember the valid fields of the rowset
	DBFIELDSDEFINITIONMAP							mValidFields ;
	// @cmember the iterator for the rowset
	std::vector<DBRowsetFields *>::iterator	mIter ;
  // @cmember the current row 
  DBRowsetFields *                  mpDBFields ;
  // @cmember the logging object
	MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger; 
} ;

// reenable warning ...
#pragma warning( default : 4251 4275 )

#endif 

