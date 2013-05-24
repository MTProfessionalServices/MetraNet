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
 * $Header: DBProperty.cpp, 21, 9/11/2002 9:28:58 AM, Alon Becker$
 *
 * @index | DBProperty
 ***************************************************************************/

#include <metra.h>
#include <comdef.h>
#include <DBProperty.h>
#include <SharedDefs.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include	<MTDec.h>

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBProperty::DBProperty()
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBProperty::~DBProperty()
{
}

//
//	@mfunc
//	Initialize the property 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code is
//  stored in the mLastError data member.
//
BOOL DBProperty::Init(const std::wstring &arName, const std::wstring &arColumn, 
                      const std::wstring &arType, const CMSIXProperties::PropertyType &arMSIXType)
{
  // local variables
  BOOL bRetCode=TRUE ;

  // initialize the property name, and column name ...
  mName = arName ;
  StrToLower(mName) ;
  mColumn = arColumn ;
  StrToLower(mColumn);
	mMSIXType = arMSIXType;

  // convert the type to its integer form ...
	if (wcscmp(arType.c_str(), DB_INTEGER_TYPE) == 0)
  {
		mType = VT_I4;
  }
  else if (wcscmp(arType.c_str(), DB_INT_TYPE) == 0)
  {
		mType = VT_I4;
  }
  else if (wcscmp(arType.c_str(), DB_BIGINT_TYPE) == 0)
  {
		mType = VT_I8;
  }
	else if (wcscmp(arType.c_str(), DB_VARCHAR_TYPE) == 0)
  {
		mType = VT_LPSTR;
  }
	else if (wcscmp(arType.c_str(), DB_DATE_TYPE) == 0)
  {
		mType = VT_DATE; 
  }
	else if (wcscmp(arType.c_str(), DB_DATE_TYPE_ORACLE) == 0)
  {
		mType = VT_DATE; 
  }
	else if (wcscmp(arType.c_str(), DB_FLOAT_TYPE) == 0)
  {
		mType = VT_R4;
  }
	else if (wcscmp(arType.c_str(), DB_DOUBLE_TYPE) == 0)
  {
		mType = VT_R8;
  }
	else if (wcscmp(arType.c_str(), W_DB_DOUBLE_STR) == 0)
  {
		mType = VT_R8;
  }
	else if (wcscmp(arType.c_str(), DB_CHAR_TYPE) == 0)
  {
		mType = VT_LPSTR;
  }
	else if (wcscmp(arType.c_str(), DB_SMALLINT_TYPE) == 0)
  {
		mType = VT_I2;
  }
	else if (wcscmp(arType.c_str(), DB_NUMERIC_TYPE) == 0)
  {
		mType = VT_DECIMAL;
  }
	else if (wcscmp(arType.c_str(), DB_DECIMAL_TYPE) == 0)
  {
		mType = VT_DECIMAL;
  }
	else if (wcscmp(arType.c_str(), DB_WSTRING_TYPE) == 0)
  {
		mType = VT_BSTR;
  }
	else if (wcscmp(arType.c_str(), DB_WSTRING_TYPE_ORACLE) == 0)
  {
		mType = VT_BSTR;
  }
	else if (wcscmp(arType.c_str(), DB_STRING_TYPE) == 0)
  {
		mType = VT_LPSTR;
  }
	else if (wcscmp(arType.c_str(), DB_INT32_TYPE) == 0)
  {
		mType = VT_I4;
  }
	else if (wcscmp(arType.c_str(), DB_INT64_TYPE) == 0)
  {
		mType = VT_I8;
  }
	else if (wcscmp(arType.c_str(), DB_TIMESTAMP_TYPE) == 0)
  {
		mType = VT_DATE;
  }
  else if (wcscmp(arType.c_str(), DB_ENUM_TYPE) == 0)
  {
    mType = VT_I4 ;
  }

    
	else 
  {
		bRetCode = FALSE; // indicate a failure
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, "DBProperty::Init");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Invalid property type. Type = %s", 
      ascii(arType).c_str()) ;
	}

  return bRetCode ;
}
