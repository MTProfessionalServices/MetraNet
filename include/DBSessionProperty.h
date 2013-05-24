/**************************************************************************
 * @doc DBSessionProperty
 * 
 * @module  Encapsulation for Database Session Property |
 * 
 * This class encapsulates the insertion or removal of Session Properties
 * from the database. All access to Session Properties should be done 
 * through this class.
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
 * @index | DBSessionProperty
 ***************************************************************************/

#ifndef __DBSESSIONPROPERTY_H
#define __DBSESSIONPROPERTY_H

#include <comdef.h>
#include <time.h>
#include <errobj.h>
#include <string>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <MSIXProperties.h>

// disable warning ...
#pragma warning( disable : 4251 4275)

// forward declarations ...
class DBProperty ;

// @class DBServiceProperty
class DBSessionProperty :
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBSessionProperty() ;
  // @cmember Destructor
  DLL_EXPORT ~DBSessionProperty() ;

  // @cmember Initialize the session property
#if 0
  DLL_EXPORT BOOL Init(const DBProperty * const apProperty, const std::wstring & arValue) ;
#endif
  // @cmember Get the column name 
  DLL_EXPORT const std::wstring & GetColumnName() const;
  // @cmember Get the column name 
  DLL_EXPORT const std::wstring & GetName() const;
  // @cmember Get the data value
  DLL_EXPORT const _variant_t & GetDataValue() const;
  // @cmember Get the data value
  DLL_EXPORT const unsigned long & GetType() const;
	DLL_EXPORT CMSIXProperties::PropertyType GetMSIXType() const {return mMSIXType;}

  // @cmember Initialize the session property
  DLL_EXPORT BOOL Init(const std::wstring &arName, const std::wstring &arColumnName, 
    const _variant_t &arValue, const unsigned long &arType, const CMSIXProperties::PropertyType& arMSIXType) ;
  // @cmember Initialize the session property
  DLL_EXPORT BOOL Init(const std::wstring &arName, const _variant_t &arValue, 
    const unsigned long &arType, const CMSIXProperties::PropertyType& arMSIXType) ;
// @access Private:
private:
  // @cmember Convert the time from ISO time to UTC
  _bstr_t Parse(const std::wstring & arValue) ;

  // @cmember the database column name
  std::wstring  mDBColumnName ;
  // @cmember the property name 
  std::wstring  mName ;
  // @cmember the variant to hold the data
  _variant_t  mData ;
  unsigned long mType ;
	CMSIXProperties::PropertyType mMSIXType;
  // @cmember the logging object 
  //NTLogger      mLogger ;
} ;

//
//	@mfunc
//	Get the column name
//  @rdesc 
//  Return the mDBColumnName data member
//
inline const std::wstring & DBSessionProperty::GetColumnName() const 
{
  return mDBColumnName ;
}

//
//	@mfunc
//	Get the name
//  @rdesc 
//  Return the mName data member
//
inline const std::wstring & DBSessionProperty::GetName() const 
{
  return mName ;
}

//
//	@mfunc
//	Get the data value
//  @rdesc 
//  Return the mData data member
//
inline const _variant_t & DBSessionProperty::GetDataValue() const
{
  return mData ;
}

//
//	@mfunc
//	Get the data value
//  @rdesc 
//  Return the mData data member
//
inline const unsigned long & DBSessionProperty::GetType() const
{
  return mType ;
}

// disable warning ...
#pragma warning( default : 4251 4275)

#endif // __DBSESSIONPROPERTY_H
