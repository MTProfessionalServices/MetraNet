/**************************************************************************
 * @doc DBProductViewProperty
 * 
 * @module  Encapsulation of a product view property|
 * 
 * This class encapsulates a property of a product view.
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
 * @index | DBProductViewProperty
 ***************************************************************************/

#include <metra.h>
#include <comdef.h>
#include <DBProductViewProperty.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <MSIXProperties.h>


//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBProductViewProperty::DBProductViewProperty()
: mEnumTypeFlag(FALSE), mUserVisible(TRUE), mFilterable(TRUE), mExportable(TRUE)
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBProductViewProperty::~DBProductViewProperty()
{
}

//
//	@mfunc
//	Initialize the product view property 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code is
//  stored in the mLastError data member.
//
BOOL DBProductViewProperty::Init(const std::wstring &arName, const std::wstring &arColumn, 
                                 const std::wstring &arType, 
																 const CMSIXProperties::PropertyType &arMSIXType,
																 const int &arDesc, 
                                 const VARIANT_BOOL &arUserVisible,
																 const VARIANT_BOOL &arFilterable,
                                 const VARIANT_BOOL &arExportable,
																 const _variant_t &arDefault, const VARIANT_BOOL &arIsRequired)
{
  // local variables
  BOOL bRetCode=TRUE ;

  // copies the parameters
  mDescID = arDesc ;

	mDefault = arDefault;


  // initialize the property ...
  bRetCode = DBProperty::Init (arName, arColumn, arType, arMSIXType) ;
  
  // copy the boolean info ...
  if (arUserVisible == VARIANT_FALSE)
  {
    mUserVisible = FALSE ;
  }
  else
  {
    mUserVisible = TRUE ;
  }

  if (arFilterable == VARIANT_FALSE)
  {
    mFilterable = FALSE ;
  }
  else
  {
    mFilterable = TRUE ;
  }
  if (arExportable == VARIANT_FALSE)
  {
    mExportable = FALSE ;
  }
  else
  {
    mExportable = TRUE ;
  }


  if (arIsRequired == VARIANT_FALSE)
    mIsRequired = FALSE ;
  else
    mIsRequired = TRUE ;

  // if the data type is enum set the flag ...
 // if (arType.compareTo (DB_ENUM_TYPE, RWWString::ignoreCase) == 0)
  if (_wcsicmp(arType.c_str(), DB_ENUM_TYPE) == 0)
  {
    mEnumTypeFlag = TRUE ;
  }

  return bRetCode ;
}
