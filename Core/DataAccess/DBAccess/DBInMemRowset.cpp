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

#include <metra.h>
#include <mtglobal_msg.h>
#include <DBInMemRowset.h>
#include <DBMiscUtils.h>
#include <DBConstants.h>
#include <string>
using namespace std ;

//
//	@mfunc
//	Initialize the data member.
//  @rdesc 
//  No return value.
//
DBInMemRowset::DBInMemRowset()
: mpDBFields(NULL)
{
  // initialize the iterator ...
  mIter = end() ;
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value.
//
DBInMemRowset::~DBInMemRowset()
{
  std::vector<DBRowsetFields *>::iterator Iter ;

  for (Iter = begin(); Iter != end(); Iter++)
  {
    delete (*Iter);
  }

  erase(begin(), end()) ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::AddFieldDefinition(const std::wstring &arName, const std::wstring &arType) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  int nType ;
  std::wstring wstrString, myString;
  
  // make sure the type is valid before we add the entry into the mValidFields collection ...
  // convert the type to its integer form ...
  wstrString = arType ;

  //wstrString.toLower();
  myString = _wcslwr((wchar_t *)wstrString.c_str());

	if (arType == DB_INTEGER_TYPE)
  {
		nType = VT_I4;
  }
  else if (arType == DB_INT_TYPE)
  {
		nType = VT_I4;
  }
  else if (arType == DB_BIGINT_TYPE)
  {
		nType = VT_I8;
  }
	else if (arType == DB_VARCHAR_TYPE)
  {
		nType = VT_LPSTR;
  }
	else if (arType == DB_DATE_TYPE)
  {
		nType = VT_DATE; 
  }
	else if (arType == DB_DATE_TYPE_ORACLE)
  {
		nType = VT_DATE; 
  }
	else if (arType == DB_FLOAT_TYPE)
  {
		nType = VT_R4;
  }
	else if (arType == DB_DOUBLE_TYPE)
  {
		nType = VT_R8;
  }
	else if (arType == DB_CHAR_TYPE)
  {
		nType = VT_LPSTR;
  }
	else if (arType == DB_SMALLINT_TYPE)
  {
		nType = VT_I2;
  }
	else if (arType == DB_NUMERIC_TYPE)
  {
		nType = VT_DECIMAL;
  }
	else if (arType == DB_DECIMAL_TYPE)
  {
		nType = VT_DECIMAL;
  }
	else if (arType == DB_WSTRING_TYPE)
  {
		nType = VT_BSTR;
  }
	else if (arType == DB_STRING_TYPE)
  {
		nType = VT_LPSTR;
  }
	else if (arType == DB_INT32_TYPE)
  {
		nType = VT_I4;
  }
	else if (arType == DB_INT64_TYPE)
  {
		nType = VT_I8;
  }
	else if (arType == DB_TIMESTAMP_TYPE)
  {
		nType = VT_DATE;
  }
  else 
  {
    bRetCode = FALSE; // indicate a failure
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::AddFieldDefinition");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    nType = VT_BSTR; // default to string type
  }
  
  // if we have a valid type ... add the entry into the fields collection
  if (bRetCode == TRUE) 
  {
    // conevrt the name to lower case ...
    wstrString = arName ;
    myString = _wcslwr((wchar_t *)wstrString.c_str());

    // add the element to the view collection ...
    DBFIELDSDEFINITIONPAIR newEntry (myString, nType) ;
    
    mValidFields.insert(newEntry) ;
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
BOOL DBInMemRowset::AddFieldData (const std::wstring &arName, const std::wstring &arValue)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBFIELDSDEFINITIONMAP::iterator Iter ;
  std::wstring wstrString, myString;
  
  // is this a valid name ...
  if (arName.empty())
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::AddFieldData");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  else
  {
    // try to find the name in the collection ...
    wstrString = arName ;
    myString = _wcslwr((wchar_t *)wstrString.c_str());
    Iter = mValidFields.find (myString) ;
    if (Iter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBInMemRowset::AddFieldData");
    }
    else
    {      
      // if there are not any rows in the rowset ...
      if (mpDBFields == NULL)
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_NO_ROWS, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::AddFieldData");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      }
      // else there are rows in the rowset ...
      else
      {
        // add the data to the current field collection ...
        bRetCode = mpDBFields->AddField (myString, arValue, (*Iter).second) ;
        if (bRetCode == FALSE)
        {
          SetError(mpDBFields->GetLastError());
          mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
        }
      }
    }
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
BOOL DBInMemRowset::AddFieldData (const std::wstring &arName, const _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBFIELDSDEFINITIONMAP::iterator Iter ;
  std::wstring wstrString, myString ;
  
  // is this a valid name ...
  if (arName.empty())
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::AddFieldData");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  else
  {
    // try to find the name in the collection ...
    wstrString = arName ;
    myString = _wcslwr((wchar_t *)wstrString.c_str());
    Iter = mValidFields.find (myString) ;
    if (Iter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBInMemRowset::AddFieldData");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {      
      // if there are not any rows in the rowset ...
      if (mpDBFields == NULL)
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_NO_ROWS, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::AddFieldData");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      }
      // else there are rows in the rowset ...
      else
      {
        // add the data to the current field collection ...
        bRetCode = mpDBFields->AddField (myString, arValue) ;
        if (bRetCode == FALSE)
        {
          SetError(mpDBFields->GetLastError());
          mLogger->LogThis (LOG_ERROR, "Unable to add field data") ;
        }
      }
    }
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
BOOL DBInMemRowset::ModifyFieldData (const std::wstring &arName, const _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBFIELDSDEFINITIONMAP::iterator Iter ;
  std::wstring wstrString, myString;
  
  // is this a valid name ...
  if (arName.empty())
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::ModifyFieldData");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  else
  {
    // try to find the name in the collection ...
    wstrString = arName ;
    myString = _wcslwr((wchar_t *)wstrString.c_str());
    Iter = mValidFields.find (myString) ;
    if (Iter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBInMemRowset::ModifyFieldData");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {      
      // if there are not any rows in the rowset ...
      if (mpDBFields == NULL)
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_NO_ROWS, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::ModifyFieldData");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      }
      // else there are rows in the rowset ...
      else
      {   
        // add the data to the current field collection ...
        bRetCode = mpDBFields->ModifyField (myString, arValue) ;
        if (bRetCode == FALSE)
        {
          SetError(mpDBFields->GetLastError());
          mLogger->LogThis (LOG_ERROR, "Unable to modify field data") ;
        }
      }
    }
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
BOOL DBInMemRowset::AddRow()
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBRowsetFields *pDBFields=NULL ;
  
  // create a new DBRowsetFields object ...
  pDBFields = new DBRowsetFields ;
  ASSERT (pDBFields) ;

  // add the row to the rowset ...
  push_back(pDBFields) ;
  
  // initialize the iterator
  mIter = begin() ;
  
  mpDBFields = back() ;
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::GetName (const _variant_t &arIndex, std::wstring &wstrName) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBFIELDSDEFINITIONMAP::iterator fielddefIter ;
  int nIndex ;
  
  // if we're getting the name by index ...
  if ((arIndex.vt == VT_I4) || (arIndex.vt == VT_I2) ||
    (arIndex.vt == (VT_I4 | VT_BYREF)) || (arIndex.vt == (VT_I2 | VT_BYREF)))
  {
    // get the value of the index ...
    if (arIndex.vt == VT_I4)
    {
      nIndex = arIndex.lVal ;
    }
    else if (arIndex.vt == VT_I2)
    {
      nIndex = arIndex.iVal ;
    }
    else if (arIndex.vt == (VT_I4 | VT_BYREF))
    {
      nIndex = *(arIndex.plVal) ;
    }
    else if (arIndex.vt == (VT_I2 | VT_BYREF))
    {
      nIndex = *(arIndex.piVal) ;
    }
    fielddefIter = mValidFields.begin() ;
    for (long i=0; i < nIndex && fielddefIter != mValidFields.end(); i++)
    {
      fielddefIter++ ;
    }
    if (fielddefIter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBInMemRowset::GetName");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {
      wstrName = (*fielddefIter).first ;
    }
  }
  // otherwise ... we're getting the name by name ...
  else if (arIndex.vt == VT_BSTR)
  {
    fielddefIter = mValidFields.find(arIndex.bstrVal) ;
    if (fielddefIter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBInMemRowset::GetName");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {
      wstrName = (*fielddefIter).first ;
    }
  }
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetName");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
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
BOOL DBInMemRowset::GetType (const _variant_t &arIndex, std::wstring &wstrType) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  int nType ;
  int nIndex ;
  DBFIELDSDEFINITIONMAP::iterator fielddefIter ;
  
  // if we're getting the name by index ...
  if ((arIndex.vt == VT_I4) || (arIndex.vt == VT_I2) ||
    (arIndex.vt == (VT_I4 | VT_BYREF)) || (arIndex.vt == (VT_I2 | VT_BYREF)))
  {
    // get the value of the index ...
    if (arIndex.vt == VT_I4)
    {
      nIndex = arIndex.lVal ;
    }
    else if (arIndex.vt == VT_I2)
    {
      nIndex = arIndex.iVal ;
    }
    else if (arIndex.vt == (VT_I4 | VT_BYREF))
    {
      nIndex = *(arIndex.plVal) ;
    }
    else if (arIndex.vt == (VT_I2 | VT_BYREF))
    {
      nIndex = *(arIndex.piVal) ;
    }
    fielddefIter = mValidFields.begin() ;
    for (long i=0; i < nIndex && fielddefIter != mValidFields.end(); i++)
    {
      fielddefIter++ ;
    }
    if (fielddefIter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::GetType");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {
      nType = (*fielddefIter).second ;
    }
  }
  // otherwise ... we're getting the name by name ...
  else if (arIndex.vt == VT_BSTR)
  {
    fielddefIter = mValidFields.find(arIndex.bstrVal) ;
    if (fielddefIter == mValidFields.end())
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::GetType");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    }
    else
    {
      nType = (*fielddefIter).second ;
    }
  }
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetType");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  // convert the type to a string ...
  switch (nType)
  {
  case VT_I2:
  case VT_I4:
    wstrType = MTPROP_TYPE_INTEGER ;
    break ;
    
  case VT_I8:
    wstrType = MTPROP_TYPE_BIGINTEGER ;
    break ;
    
  case VT_R4:
  case VT_R8:
    wstrType = MTPROP_TYPE_FLOAT ;
    break ;

  case VT_DECIMAL:
    wstrType = MTPROP_TYPE_DECIMAL ;
    break ;
    
  case VT_BSTR:
    wstrType = MTPROP_TYPE_BSTR ;
    break ;
    
  case VT_DATE:
    wstrType = MTPROP_TYPE_DATE ;
    break ;

  default: 
    wstrType = MTPROP_TYPE_UNKNOWN ;

    SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetType");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>. Value requested = %s", 
        nType, (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>. Value requested = %x", 
        nType, (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>.Value requested = %x", 
        nType, (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>.Unknown value requested = %x", 
        nType, (int)arIndex.vt) ;
    }
    break ;
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
BOOL DBInMemRowset::GetValue (const _variant_t &arIndex, _variant_t &arValue,bool bLog) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBRowsetFields *pDBFields ;

  // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, arValue) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBFields->GetLastError());
      mLogger->LogThis (LOG_WARNING, "Unable to get value of field.") ;

      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {
      /// null out the pointer just to be safe
      pDBFields = NULL ;
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::GetValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
BOOL DBInMemRowset::GetIntValue (const _variant_t &arIndex, int &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  DBRowsetFields *pDBFields ;

   // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBFields->GetLastError());
      mLogger->LogThis (LOG_WARNING, "Unable to get integer value") ;
      
      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {
      /// null out the pointer just to be safe
      pDBFields = NULL ;
      
      // if the value is a long value ... return it ...
      if (vtValue.vt == VT_I4) 
      {
        aValue = (int) vtValue.lVal ;
      }
      // else if its a short value ... return it ...
      else if (vtValue.vt == VT_I2)
      {
        aValue = (int) vtValue.iVal ;
      }
      // else if its a decimal value ... return it ...
      else if (vtValue.vt == VT_DECIMAL)
      {
        DECIMAL decValue = vtValue.decVal ;
        aValue = (int) decValue.Lo32 ;
      }
      else
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::GetIntValue");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
        
        mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;
        
        // get the requested index ...
        if (arIndex.vt == VT_BSTR)
        {
          _bstr_t columnName = arIndex.bstrVal ;
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s. Type = %x", 
            (char*)columnName, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I2)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I4)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
            (int)arIndex.vt) ;
        }
      }
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetIntValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
BOOL DBInMemRowset::GetFloatValue (const _variant_t &arIndex, double &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  DBRowsetFields *pDBFields ;

  // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBFields->GetLastError());
      mLogger->LogThis (LOG_WARNING, "Unable to get float value") ;
      
      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {
      /// null out the pointer just to be safe
      pDBFields = NULL ;
      
      // if the value is a float value ... return it ...
      if (vtValue.vt == VT_R4) 
      {
        aValue = vtValue.fltVal ;
      }
      else if (vtValue.vt == VT_R8) 
      {
        aValue = vtValue.dblVal ;
      }
      else
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::GetFloatValue");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

        mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;
        
        // get the requested index ...
        if (arIndex.vt == VT_BSTR)
        {
          _bstr_t columnName = arIndex.bstrVal ;
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s. Type = %x", 
            (char*)columnName, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I2)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I4)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
            (int)arIndex.vt) ;
        }
      }
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetFloatValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
BOOL DBInMemRowset::GetDecimalValue (const _variant_t &arIndex, DECIMAL &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  DBRowsetFields *pDBFields ;

  // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBFields->GetLastError());
      mLogger->LogThis (LOG_WARNING, "Unable to get float value") ;
      
      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {
      /// null out the pointer just to be safe
      pDBFields = NULL ;
      
      // if the value is a float value ... return it ...
      if (vtValue.vt == VT_DECIMAL) 
      {
        aValue = vtValue.decVal ;
      }
      else
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::GetFloatValue");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

        mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;
        
        // get the requested index ...
        if (arIndex.vt == VT_BSTR)
        {
          _bstr_t columnName = arIndex.bstrVal ;
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s. Type = %x", 
            (char*)columnName, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I2)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I4)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
            (int)arIndex.vt) ;
        }
      }
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetFloatValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
BOOL DBInMemRowset::GetCharValue (const _variant_t &arIndex, std::string &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _bstr_t bstrValue ;
  _variant_t vtValue ;
  DBRowsetFields *pDBFields ;

  // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBFields->GetLastError());
      mLogger->LogThis (LOG_WARNING, "Unable to get character value") ;

      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {
      /// null out the pointer just to be safe
      pDBFields = NULL ;
      
      // if the value is a float value ... return it ...
      if (vtValue.vt == VT_BSTR) 
      {
        bstrValue = vtValue.bstrVal ;
        aValue = (char *) bstrValue ;
      }
      else
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::GetCharValue");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

        mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;
        
        // get the requested index ...
        if (arIndex.vt == VT_BSTR)
        {
          _bstr_t columnName = arIndex.bstrVal ;
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s. Type = %x", 
            (char*)columnName, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I2)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I4)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
            (int)arIndex.vt) ;
        }
      }
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetCharValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
BOOL DBInMemRowset::GetWCharValue (const _variant_t &arIndex, std::wstring &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  DBRowsetFields *pDBFields ;

  // if we arent at the end ...
  if (mIter != end())
  {
    // get the current fields collection ...
    pDBFields = (*mIter) ;
    
    // get the field ...
    bRetCode = pDBFields->GetField (arIndex, vtValue) ;
    if (bRetCode == FALSE)
    {
      DWORD nError = pDBFields->GetLastErrorCode() ;
      SetError(nError, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::GetWCharValue");
      mLogger->LogThis (LOG_WARNING, "Unable to get wide character value") ;

      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
      }
    }
    else
    {    
      // if the value is a float value ... return it ...
      if (vtValue.vt == VT_BSTR) 
      {
        aValue = vtValue.bstrVal ;
      }
      else
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
          "DBInMemRowset::GetWCharValue");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

        mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;
        
        // get the requested index ...
        if (arIndex.vt == VT_BSTR)
        {
          _bstr_t columnName = arIndex.bstrVal ;
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s. Type = %x", 
            (char*)columnName, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I2)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else if (arIndex.vt == VT_I4)
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x. Type = %x.", 
            (int)arIndex.iVal, (int)arIndex.vt) ;
        }
        else
        {
          mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
            (int)arIndex.vt) ;
        }
      }
    }
  }
  // otherwise ... indicate an error ...
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, 
      "DBInMemRowset::GetWCharValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %s", (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Value requested = %x", (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
    }
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
int DBInMemRowset::GetCount() 
{
  return mValidFields.size() ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::MoveNext() 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  
  if (mIter != end())
  {
    mIter++ ;
  }
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::MoveNext");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
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
BOOL DBInMemRowset::MoveLast()
{
  // local variables 
  BOOL bRetCode=TRUE ;
  
  if (mIter != end())
  {
    mIter = end() - 1 ;
  }
  else
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_NO_MORE_DATA, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::MoveLast");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
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
BOOL DBInMemRowset::MoveFirst() 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  
  mIter = begin() ;
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBInMemRowset::GetRecordCount() 
{
  return size() ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBInMemRowset::GetPageSize() 
{
  return 0 ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
void DBInMemRowset::SetPageSize(int aPageSize) 
{
  return ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBInMemRowset::GetPageCount() 
{
  return 0 ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::GoToPage(int nPageNum) 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBInMemRowset::GetPage() 
{
  return 0 ;
}


//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::AtEOF()
{
  return (mIter == end()) ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBInMemRowset::Sort (const std::wstring &arSortOrder) 
{
  // local variables 

  SetError(ERROR_INVALID_FUNCTION, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::Sort");
  mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  mLogger->LogVarArgs (LOG_ERROR,  "Sorting not supported on in-mem rowsets.") ;

  return FALSE;
}

BOOL DBInMemRowset::Filter (const std::wstring &arFilterCriteria) 
{
  // local variables 

  SetError(ERROR_INVALID_FUNCTION, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::Filter");
  mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  mLogger->LogVarArgs (LOG_ERROR,  "Filtering not supported on in-mem rowsets.") ;

  return FALSE;
}

BOOL DBInMemRowset::Refresh () 
{
  // local variables 

  SetError(ERROR_INVALID_FUNCTION, ERROR_MODULE, ERROR_LINE, "DBInMemRowset::Refresh");
  mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  mLogger->LogVarArgs (LOG_ERROR,  "Refresh not supported on in-mem rowsets.") ;

  return FALSE;
}



