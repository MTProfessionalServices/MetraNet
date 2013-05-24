/**************************************************************************
 * @doc DBRowset
 * 
 * @module  Encapsulation for accessing the MTRowset.
 * 
 * This class encapsulates accessing the DBRowset, a rowset that was
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
 * @index | DBRowset
 ***************************************************************************/

#ifndef __DBRowset_H
#define __DBRowset_H

#include <string>
#include <errobj.h>

// disable warning ...
#pragma warning( disable : 4275)

// defines for exporting dll ...
#undef DLL_EXPORT
#define DLL_EXPORT		__declspec (dllexport)


// @class DBRowset
class DBRowset 
: public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBRowset() {} ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBRowset() {} ;

  // @cmember Get the name of the specified column
  DLL_EXPORT virtual BOOL GetName (const _variant_t &arIndex, std::wstring &aName)= 0 ;
  // @cmember Get the value of the specified column
  DLL_EXPORT virtual BOOL GetValue (const _variant_t &arIndex, _variant_t &aValue,bool bLog=true)= 0 ;
  // @cmember Get the integer value of the specified column
  DLL_EXPORT virtual BOOL GetIntValue (const _variant_t &arIndex, int &aValue)= 0 ;
  // @cmember Get the float value of the specified column
  DLL_EXPORT virtual BOOL GetFloatValue (const _variant_t &arIndex, double &aValue)= 0 ;
  DLL_EXPORT virtual BOOL GetDecimalValue (const _variant_t &arIndex, DECIMAL &aValue)= 0 ;
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetCharValue (const _variant_t &arIndex, std::string &aValue)= 0 ;
  // @cmember Get the character string value of the specified column
  DLL_EXPORT virtual BOOL GetWCharValue (const _variant_t &arIndex, std::wstring &aValue)= 0 ;
  // @cmember Get the type of the specified column
  DLL_EXPORT virtual BOOL GetType (const _variant_t &arIndex, std::wstring &aType)= 0 ;
  // @cmember Get the number of columns per row
  DLL_EXPORT virtual int GetCount()= 0 ;
  // @cmember Move to the next row in the rowset
  DLL_EXPORT virtual BOOL MoveNext()= 0 ;
  // @cmember Move to the first row in the rowset
  DLL_EXPORT virtual BOOL MoveFirst()= 0 ;
  // @cmember Move to the last row in the rowset
  DLL_EXPORT virtual BOOL MoveLast()= 0 ;
  // @cmember Get the number of items in the rowset
  DLL_EXPORT virtual int GetRecordCount()= 0 ;
  // @cmember Get the current page size
  DLL_EXPORT virtual int GetPageSize()= 0 ;
   // @cmember Set the current page size
  DLL_EXPORT virtual void SetPageSize(int aPageSize)= 0 ;
  // @cmember Get the number of pages in the current rowset
  DLL_EXPORT virtual int GetPageCount()= 0 ;
  // @cmember Go to the specified page
  DLL_EXPORT virtual BOOL GoToPage(int nPageNum)= 0 ;
  // @cmember Get the current page
  DLL_EXPORT virtual int GetPage()= 0 ;
  // @cmember Check to see if we've reached the end of the rowset
  DLL_EXPORT virtual BOOL AtEOF()= 0 ;
  DLL_EXPORT virtual BOOL Sort(const std::wstring &arSortOrder)= 0 ;
  DLL_EXPORT virtual BOOL Filter(const std::wstring &arFilterCriteria)= 0 ;
  DLL_EXPORT virtual BOOL Refresh()= 0 ;
	DLL_EXPORT virtual BOOL SetFilterString(const wchar_t* pFilter) = 0;
	DLL_EXPORT virtual void ResetFilter() = 0;
  DLL_EXPORT virtual void RemoveRow() = 0;
// @access Protected:
protected:

  // @access Private:
private:
  

} ;

// reenable warning ...
#pragma warning( default : 4275)

#endif 

