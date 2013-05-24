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

#include <metra.h>
#include <DBSessionProperty.h>
#include <DBProperty.h>
#include <DBConstants.h>
//#include <atlbase.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <tchar.h>


//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
DBSessionProperty::DBSessionProperty()
{
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
DBSessionProperty::~DBSessionProperty()
{
}

//
//	@mfunc
//	Initialize the session property object. 
//  @parm Pointer to the appropriate service property 
//  @parm The value of the property
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code is 
//  saved in the mLastError data member.
//
//
//	@mfunc
//	Initialize the session property object. 
//  @parm The name of the property
//  @parm The value of the property
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code is 
//  saved in the mLastError data member.
//
BOOL DBSessionProperty::Init (const std::wstring &arName, const std::wstring &arColumnName, 
                              const _variant_t &arValue, const unsigned long &arType, const CMSIXProperties::PropertyType& arMSIXType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // initialize the data members ...
  mName = arName ;
  mData = arValue ;
  mDBColumnName = arColumnName ;
  mType = arType;
	mMSIXType = arMSIXType;

  return bRetCode ;
}

BOOL DBSessionProperty::Init (const std::wstring &arName, 
                              const _variant_t &arValue,
                              const unsigned long &arType,
															const CMSIXProperties::PropertyType& arMSIXType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // initialize the data members ...
  mName = arName ;
  mData = arValue ;
  mType = arType ;
	mMSIXType = arMSIXType;

  return bRetCode ;
}

_bstr_t DBSessionProperty::Parse(const std::wstring & arValue)
{
  _bstr_t bstrTime=_T("") ;
  time_t Time ;
  std::string rwString ;
  int nPos ;

  // copy to a _bstr_t ...
  bstrTime = arValue.c_str() ;

  // convert to iso time ...
  MTParseISOTime(bstrTime, &Time) ;

  // format the iso time ...
  MTFormatISOTime(Time, rwString) ;

  // find the T
  nPos = rwString.find('T', 0) ;
  rwString.replace (nPos, 1, " ") ;
  nPos = rwString.find('Z', 0) ;
  rwString.replace (nPos, 1, " ") ;

  // copy the string back to the _bstr_t ...
  bstrTime = rwString.c_str() ;

	return bstrTime ;
}
