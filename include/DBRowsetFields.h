/**************************************************************************
 * @doc DBRowsetFields
 * 
 * @module  Encapsulation of a product view item|
 * 
 * This class encapsulates a product view item
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
 * @index | DBRowsetFields
 ***************************************************************************/

#ifndef __DBRowsetFields_H
#define __DBRowsetFields_H

#include <comdef.h>
#include <string>
#include <map>
#include <errobj.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

// disnable warning ...
#pragma warning( disable : 4275 4251 )

typedef std::map<std::wstring, _variant_t> DBROWSETFIELDSMAP ;
typedef std::pair<std::wstring, _variant_t> DBROWSETFIELDSPAIR ;

// @class DBRowsetFields
class DBRowsetFields :
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBRowsetFields() ;
  // @cmember Destructor
  DLL_EXPORT ~DBRowsetFields() ;

  // @cmember Initialize the rowset fields collection
  DLL_EXPORT BOOL Init (const std::map<std::wstring, int> &arValidFields) ;
  // @cmember Add a field to the rowset 
  DLL_EXPORT BOOL AddField (const std::wstring &arName, const std::wstring &arValue, const int &arType) ;
  // @cmember Add a field to the rowset 
  DLL_EXPORT BOOL AddField (const std::wstring &arName, const _variant_t &arValue) ;
  // @cmember Modify a field in the rowset 
  DLL_EXPORT BOOL ModifyField (const std::wstring &arName, const _variant_t &arValue) ;
  // @cmember Get the field 
  DLL_EXPORT BOOL GetField (const _variant_t &arName, _variant_t &arValue) ;

// @access Private:
private:
  // @cmember the list of fields
  DBROWSETFIELDSMAP mFields ;
  // @cmember the logging object
	MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger; 

} ;

// disnable warning ...
#pragma warning( default : 4275 4251 )

#endif 
