/**************************************************************************
 * @doc DBProperty
 * 
 * @module  Encapsulation of a property|
 * 
 * This class encapsulates a property.
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
 * @index | DBProperty
 ***************************************************************************/

#ifndef __DBProperty_H
#define __DBProperty_H


#include <errobj.h>
#include <string>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include "MSIXProperties.h"

// disable warning ...
#pragma warning( disable : 4275)

// @class DBProperty
class DBProperty : public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProperty() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBProperty() ;

  // @cmember Initialize the product view property
  DLL_EXPORT BOOL Init (const std::wstring &arName, const std::wstring &arColumn, 
    const std::wstring &arType, const CMSIXProperties::PropertyType &arMSIXType) ;
  // @cmember Get the name of the property
  DLL_EXPORT std::wstring GetName() const ;
  // @cmember Get the column name of the property
  DLL_EXPORT std::wstring GetColumnName() const ;
  // @cmember Get the data type of the property
  DLL_EXPORT int GetType() const ;

  // @cmember Get the MSIX type of the property
  DLL_EXPORT CMSIXProperties::PropertyType GetMSIXType() const ;
// @access Protected:
protected:
  // @cmember the property name
  std::wstring      mName ;
  // @cmember the column name of the property
  std::wstring      mColumn ;
  // @cmember the type of the property
  int               mType ;
  // @cmember the MSIX type of the property
  CMSIXProperties::PropertyType mMSIXType ;
  // @cmember the logging object
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
// @access Private:
private:

} ;

//
//	@mfunc
//	Create the product view properties query. 
//  @rdesc 
//  The product view properties query.
//
inline std::wstring DBProperty::GetName() const
{
  return mName ;
}

//
//	@mfunc
//	Create the product view properties query. 
//  @rdesc 
//  The product view properties query.
//
inline std::wstring DBProperty::GetColumnName() const
{
  return mColumn ;
}

//
//	@mfunc
//	Create the product view properties query. 
//  @rdesc 
//  The product view properties query.
//
inline int DBProperty::GetType() const
{
  return mType ;
}

//gets the MSIX type of the property
//this was introduced to help in the 
//ambigous case of booleans, since their
//data type (DB type) is varchar, but further
//processing must be done on them (as compared
//to other varchar types such as date)
inline CMSIXProperties::PropertyType  DBProperty::GetMSIXType() const
{
  return mMSIXType;
}

// reenable the warning ...
#pragma warning( default : 4275)

#endif 
