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

#ifndef __DBProductViewProperty_H
#define __DBProductViewProperty_H

#include <DBProperty.h>
#include <string>

// @class DBProductViewProperty
class DBProductViewProperty :
  public DBProperty
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProductViewProperty() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBProductViewProperty() ;

  // @cmember Initialize the product view property
  DLL_EXPORT BOOL Init (const std::wstring &arName, const std::wstring &arColumn, 
												const std::wstring &arType, const CMSIXProperties::PropertyType &arMSIXType, 
												const int &arDescID, const VARIANT_BOOL &arUserVisible,
												const VARIANT_BOOL &arFilterable, const VARIANT_BOOL &arExportable,
												const _variant_t &arDefault = _variant_t(),
												const VARIANT_BOOL &arIsRequired = VARIANT_FALSE) ;
  // @cmember Get the description id
  DLL_EXPORT BOOL GetIsRequired() const
	{ return mIsRequired; }
	DLL_EXPORT BOOL GetUserVisible() const
  { return mUserVisible; }
  DLL_EXPORT BOOL GetFilterable() const
  { return mFilterable; }
  DLL_EXPORT BOOL GetExportable() const
  { return mExportable; }

	
	//returns the default value as a variant
	DLL_EXPORT void GetDefault(_variant_t &arDefaultVal) const {
		arDefaultVal = mDefault;
	}
  
	DLL_EXPORT int GetDescriptionID() const
  { return mDescID ; }

  DLL_EXPORT void SetEnumNamespace (const std::wstring &arEnumNamespace)
  { mEnumNamespace = arEnumNamespace ; } 
  DLL_EXPORT void SetEnumEnumeration (const std::wstring &arEnumEnumeration)
  { mEnumEnumeration = arEnumEnumeration ; } 
  DLL_EXPORT void SetEnumColumnName(const int &arEnumNum) ;

  DLL_EXPORT BOOL GetEnumInformation(std::wstring &arEnumNamespace, 
    std::wstring &arEnumEnumeration) ;
  DLL_EXPORT std::wstring GetEnumColumnName() const 
  { return mEnumColumnName ; }
  DLL_EXPORT BOOL IsEnumType () const
  { return mEnumTypeFlag ;}

// @access Private:
private:
  // @cmember the description
  BOOL              mUserVisible ;
  BOOL              mFilterable ;
  BOOL              mExportable ;
  BOOL              mEnumTypeFlag ;
  std::wstring      mEnumNamespace ;
  std::wstring      mEnumEnumeration ;
  std::wstring      mEnumColumnName ;
  _variant_t        mDefault;
  BOOL              mIsRequired;
  int               mDescID ;
} ;

inline void DBProductViewProperty::SetEnumColumnName(const int &arEnumNum) 
{
  wchar_t wstrTempNum[64] ;

  mEnumColumnName = L"d" ;
  mEnumColumnName += _itow (arEnumNum, wstrTempNum, 10) ;
  mEnumColumnName += L".tx_desc" ;
}

inline BOOL DBProductViewProperty::GetEnumInformation(std::wstring &arEnumNamespace, 
                                                      std::wstring &arEnumEnumeration)
{
  // if the data type is enum ...
  if (mEnumTypeFlag == TRUE)
  {
    arEnumNamespace = mEnumNamespace ;
    arEnumEnumeration = mEnumEnumeration ;
  }
  else 
  {
    // not an enum ... invalid operation ...
    return FALSE ;
  }
  return TRUE ;
}


#endif 
