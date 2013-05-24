/**************************************************************************
 * @doc DBRowsetFields
 * 
 * @module  |
 * 
 * This class 
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

#include <metra.h>
#include <DBRowsetFields.h>
#include <stdlib.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <tchar.h>

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBRowsetFields::DBRowsetFields()
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBRowsetFields::~DBRowsetFields()
{
  DBROWSETFIELDSMAP::iterator Iter ;

  // delete the allocated memory ...
  mFields.erase(mFields.begin(), mFields.end()) ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBRowsetFields::Init (const std::map<std::wstring, int> &arValidFields)
{
  // local variables 
  BOOL bRetCode = TRUE ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBRowsetFields::AddField (const std::wstring &arName, const std::wstring &arValue, 
                               const int &arType)
{
  // local variables 
  BOOL bRetCode = TRUE ;
  DBROWSETFIELDSMAP::iterator Iter ;
  _bstr_t newValue ;
  _variant_t vtValue ;

  switch (arType)
  {
  case VT_I2:
    vtValue.iVal = _ttoi (arValue.c_str());
    break ;
    
  case VT_I4:
    vtValue.lVal = _ttol (arValue.c_str());
    break ;
    
  case VT_R4:
    vtValue.fltVal = (float) _tcstod (arValue.c_str(), NULL);
    break ;
    
  case VT_R8:
    vtValue.dblVal = _tcstod (arValue.c_str(), NULL);
    break ;
    
  case VT_BSTR:      
    newValue = arValue.c_str() ;
    vtValue.bstrVal = newValue.copy() ;
    break ;
    
  case VT_DATE:
  default:
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBRowsetFields::AddField");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
    break ;
  }

  // set the value in the map to the new value 
  DBROWSETFIELDSPAIR newEntry (arName, vtValue) ;
  
  mFields.insert (newEntry) ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBRowsetFields::AddField (const std::wstring &arName, const _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode = TRUE ;
  _variant_t vtValue ;
  
  // set the value in the map to the new value 
  DBROWSETFIELDSPAIR newEntry (arName, arValue) ;

  mFields.insert (newEntry) ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBRowsetFields::ModifyField (const std::wstring &arName, const _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode = TRUE ;
  DBROWSETFIELDSMAP::iterator fieldIter ;

  // find the field to modify ...
  fieldIter = mFields.find(arName) ;
  if (fieldIter == mFields.end())
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
      "DBRowsetFields::ModifyField");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  else
  {
    (*fieldIter).second = arValue ;
  }
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBRowsetFields::GetField (const _variant_t &arName, _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode = TRUE ;
  DBROWSETFIELDSMAP::iterator fieldIter ;
  std::wstring wstrString, myString;
  int nIndex ;

  // if we're getting the name by index ...
  if ((arName.vt == VT_I4) || (arName.vt == VT_I2) ||
    (arName.vt == (VT_I4 | VT_BYREF)) || (arName.vt == (VT_I2 | VT_BYREF)))
  {
    // get the value of the index ...
    if (arName.vt == VT_I4)
    {
      nIndex = arName.lVal ;
    }
    else if (arName.vt == VT_I2)
    {
      nIndex = arName.iVal ;
    }
    else if (arName.vt == (VT_I4 | VT_BYREF))
    {
      nIndex = *(arName.plVal) ;
    }
    else if (arName.vt == (VT_I2 | VT_BYREF))
    {
      nIndex = *(arName.piVal) ;
    }
    fieldIter = mFields.begin() ;
    for (long i=0; i < nIndex && fieldIter != mFields.end() ; i++)
    {
      fieldIter++ ;
    }
    // if the iterator is at the end the name wasnt found ... indicate error
    if (fieldIter == mFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBRowsetFields::GetField");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      arValue.Clear() ;
    }
    // otherwise ... we found the value ...
    else
    {
      arValue = (*fieldIter).second ;
    }
  }
  // otherwise ... we're getting the name by name ...
  else if (arName.vt == VT_BSTR)
  {
    wstrString = arName.bstrVal ;
    //wstrString.toLower() ;
	myString = _wcslwr((wchar_t *)wstrString.c_str());

    fieldIter = mFields.find(myString) ;

    // if the iterator is at the end the name wasnt found ... indicate error
    if (fieldIter == mFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBRowsetFields::GetField");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      arValue.Clear() ;
    }
    // otherwise ... we found the value ...
    else
    {
      arValue = (*fieldIter).second ;
    }
  }
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBRowsetFields::GetField");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}
