/**************************************************************************
 * @doc DBSQLRowset
 * 
 * @module  Encapsulation for accessing the DBSQLRowset.
 * 
 * This class encapsulates accessing the DBSQLRowset, a rowset that was
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
 * $Header: c:\development35\Core\DataAccess\DBAccess\DBSQLRowset.cpp, 51, 7/26/2002 1:22:52 PM, David Blair$
 *
 * @index | DBSQLRowset
 ***************************************************************************/

#include <metra.h>
#include <DBSQLRowset.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <stdutils.h>
#include <mtcomerr.h>
#include <SharedDefs.h>

BOOL DBSQLRowset::mDBTypeIsOracle = FALSE ;

//
//	@mfunc
//	Initialize the data member.
//  @rdesc 
//  No return value.
//
DBSQLRowset::DBSQLRowset()
{
}


//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value.
//
DBSQLRowset::~DBSQLRowset()
{
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::Init() 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  TearDown() ;

  return bRetCode ;
}

BOOL DBSQLRowset::InitDisconnected()
{
	TearDown();
	
	_RecordsetPtr recordset;
	recordset.CreateInstance( __uuidof(Recordset));
	recordset->CursorLocation = adUseClient;
	recordset->CursorType = adOpenStatic;
	recordset->LockType = adLockBatchOptimistic;
	PutRecordSet(recordset);
	return TRUE;
}


BOOL DBSQLRowset::OpenDisconnected()
{
	mRowset->Open(vtMissing, vtMissing, adOpenStatic,adLockBatchOptimistic,-1);
	return TRUE;
}


void DBSQLRowset::TearDown()
{
  RowsetFieldMapByString::iterator stringIter ;
  for (stringIter = mFieldCollByString.begin(); stringIter != mFieldCollByString.end(); stringIter++)
  {
    ((*stringIter).second)->Release();
  }
  mFieldCollByString.clear() ;
    
  RowsetFieldMapByLong::iterator longIter ;
  for (longIter = mFieldCollByLong.begin(); longIter != mFieldCollByLong.end(); longIter++)
  {
    ((*longIter).second)->Release();
  }
  mFieldCollByLong.clear() ;
}

//
//	@mfunc
//	Get the recordset pointer
//  @rdesc 
//  Returns the recordset pointer
//
_RecordsetPtr & DBSQLRowset::GetRecordsetPtr() 
{
  Init() ;

  return mRowset ;
}

void DBSQLRowset::PutRecordSet(_RecordsetPtr& aRecordSet)
{
	Init();
	mRowset = aRecordSet;
}

_COM_SMARTPTR_TYPEDEF(IDispatch, __uuidof(IDispatch));

BOOL DBSQLRowset::PutRecordSetAsIDispatch(IDispatch* pDisp)
{
	Init();
	if(!pDisp) return FALSE;
	IDispatchPtr aDispatch(pDisp);
	// QI
	mRowset = aDispatch;
	return TRUE;
}


void DBSQLRowset::GetFieldPtr(const _variant_t &arIndex, FieldPtr &arFieldPtr)
{
  // if the index is by string ...
  if (arIndex.vt == VT_BSTR)
  {
    // try to find the value in the map ...
    RowsetFieldMapByString::iterator Iter ;
    std::wstring stringIndex = arIndex.bstrVal ;
    Iter = mFieldCollByString.find (stringIndex) ;
    if (Iter == mFieldCollByString.end())
    {
      // get the fields ptr ...
      arFieldPtr = mRowset->Fields->GetItem(arIndex) ;
      
      // insert it into the list ...
      RowsetFieldPairByString newEntry (stringIndex, arFieldPtr) ;
      
      mFieldCollByString.insert(newEntry) ;
    }
    else
    {
      // get the fields ptr ...
      arFieldPtr = (*Iter).second ;
    }
  }
  else if ((arIndex.vt == VT_I4) || (arIndex.vt == VT_I2))
  {
    // try to find the value in the map ...
    RowsetFieldMapByLong::iterator Iter ;
    long longIndex ;
    if (arIndex.vt == VT_I4)
    {
      longIndex = arIndex.lVal ;
    }
    else if (arIndex.vt == VT_I2)
    {
      longIndex = (long) arIndex.iVal ;
    }
    Iter = mFieldCollByLong.find (longIndex) ;
    if (Iter == mFieldCollByLong.end())
    {
      // get the fields ptr ...
      arFieldPtr = mRowset->Fields->GetItem(arIndex) ;
      
      // insert it into the list ...
      RowsetFieldPairByLong newEntry (longIndex, arFieldPtr) ;
      
      mFieldCollByLong.insert(newEntry) ;
    }
    else
    {
      // get the fields ptr ...
      arFieldPtr = (*Iter).second ;
    }
  }
  else
  {
    mLogger->LogVarArgs (LOG_ERROR, "Invalid index type = %x", arIndex.vt) ;
  }
}
//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetName (const _variant_t &arIndex, std::wstring &wstrName) 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    wstrName = fieldPtr->Name ;
  }
  catch (_com_error e)
  {
    wstrName= L"" ;
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetName");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetName() failed. Error Description = %s", 
      (char*)e.Description()) ;
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
BOOL DBSQLRowset::GetValue (const _variant_t &arIndex, _variant_t &aValue,bool bLog) 
{
	// local variables 
	BOOL bRetCode = TRUE;
	_variant_t vtValue;

  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr;
    GetFieldPtr(arIndex, fieldPtr);

    // get the value ...
    vtValue = fieldPtr->Value;
	if (vtValue.vt == VT_BSTR) 
    {
		// For Orcale confert MT empty string to a normal empty string.
		if (mDBTypeIsOracle == TRUE && MTEmptyString == (_bstr_t)vtValue.bstrVal)
			aValue = "";
		else
			aValue = vtValue.bstrVal;
    }

    //Handle Oracle integers. Since there is no native support for ints,
    //we convert the variant to I4 for number(10, 0). Otherwise casting to integer 
    //will fail in the code.
    else if (V_VT(&vtValue) == VT_DECIMAL && mDBTypeIsOracle == TRUE) 
    {
      int scale = fieldPtr->GetNumericScale();
      int precision = fieldPtr->GetPrecision();
      if(precision == 10 && scale == 0)
        vtValue.ChangeType(VT_I4);

	  aValue = vtValue;
    }
	else
	{
		aValue = vtValue;
	}
  }
  catch (_com_error e)
  {
    aValue.Clear() ;
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetValue");

		if(bLog) {
			mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
			mLogger->LogVarArgs (LOG_WARNING, "GetValue() failed. Error Description = %s", 
				(char*)e.Description()) ;
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
				mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)arIndex.lVal) ;
			}
			else
			{
				mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)arIndex.vt) ;
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
BOOL DBSQLRowset::GetIntValue (const _variant_t &arIndex, int &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    // get the value from the fields collection ...
    vtValue = fieldPtr->Value ;
    
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
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetIntValue");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

      mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;

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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetIntValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetIntValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetFloatValue (const _variant_t &arIndex, double &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    // get the value from the recordset ...
    vtValue = fieldPtr->Value ;
    
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
        "DBSQLRowset::GetFloatValue");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

      mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;

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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetFloatValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetFloatValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetDecimalValue (const _variant_t &arIndex, DECIMAL &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    // get the value from the recordset ...
    vtValue = fieldPtr->Value ;
    
    // if the value is a float value ... return it ...
    if (vtValue.vt == VT_DECIMAL)
    {
      aValue = vtValue.decVal ;
    }
    else
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
        "DBSQLRowset::GetDecimalValue");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

      mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;

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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetDecimalValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetDecimalValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetCharValue (const _variant_t &arIndex, std::string &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _bstr_t bstrValue ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    // get the value from the recordset ...
    vtValue = fieldPtr->Value ;
    
    // if the value is a float value ... return it ...
    if (vtValue.vt == VT_BSTR) 
    {
      bstrValue = vtValue.bstrVal ;

	  // For Orcale confert MT empty string to a normal empty string.
	  if (mDBTypeIsOracle == TRUE && MTEmptyString == bstrValue)
		  aValue = "";
	  else
	      aValue = (char *) bstrValue ;
    }
    else if (vtValue.vt == VT_NULL)
    {
      aValue = "" ;
    }
    else
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetCharValue");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

      mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;

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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetCharValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetCharValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetWCharValue (const _variant_t &arIndex, std::wstring &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr);

    // get the value from the recordset ...
    vtValue = fieldPtr->Value ;
    
    // if the value is a float value ... return it ...
    if (vtValue.vt == VT_BSTR) 
    {
	  // For Orcale confert MT empty string to a normal empty string.
	  if (mDBTypeIsOracle == TRUE && MTEmptyString == (_bstr_t)vtValue.bstrVal)
		 aValue = L"";
	  else
		 aValue = vtValue.bstrVal ;
    }
    else if (vtValue.vt == VT_NULL)
    {
      aValue = L"" ;
    }
    else
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
        "DBSQLRowset::GetWCharValue");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;

      mLogger->LogVarArgs (LOG_ERROR,  "Type of value requested = %x", 
          (int)vtValue.vt) ;

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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetWCharValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetWCharValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetType (const _variant_t &arIndex, std::wstring &wstrType) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  long type ;

  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    type = fieldPtr->Type ;
    switch (type)
    {
    case adDecimal:
    case adSmallInt:
    case adTinyInt:
    case adInteger:
    case adUnsignedInt:
    case adUnsignedSmallInt:
    case adUnsignedTinyInt:
      wstrType = MTPROP_TYPE_INTEGER ;
      break ;
      
    case adBigInt:
    case adUnsignedBigInt:
      wstrType = MTPROP_TYPE_BIGINTEGER ;
      break ;

    case adDouble:
    case adSingle:
    case adNumeric:
    case adVarNumeric:
      wstrType = MTPROP_TYPE_FLOAT ;
      break ;
      
    case adDate:
    case adDBTimeStamp:
      wstrType = MTPROP_TYPE_DATE ;
      break ;
      
    case adBSTR:
    case adWChar:
    case adVarWChar:
    case adLongVarWChar:
    case adLongVarChar:
      wstrType = MTPROP_TYPE_BSTR ;
      break ;
    
    case adChar:
      wstrType = MTPROP_TYPE_STRING ;
      break ;
      
    case adEmpty:
      wstrType = MTPROP_TYPE_EMPTY ;
      break ;
      
    case adVarChar:
      wstrType = MTPROP_TYPE_CHAR ;
      break ;

    case adVarBinary:
      wstrType = MTPROP_TYPE_VARBINARY;
      break ;
      
    default:
      wstrType = MTPROP_TYPE_UNKNOWN ;
      
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetType");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      // get the requested index ...
      if (arIndex.vt == VT_BSTR)
      {
        _bstr_t columnName = arIndex.bstrVal ;
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%d>. Value requested = %s", 
          type, (char*)columnName) ;
      }
      else if (arIndex.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%d>. Value requested = %d", 
          type, (int)arIndex.iVal) ;
      }
      else if (arIndex.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%d>.Value requested = %d", 
          type, (int)arIndex.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%d>.Unknown value requested = %d", 
          type, (int)arIndex.vt) ;
      }
      break ;
    }
  }
  catch (_com_error e)
  {
    wstrType = L"" ;
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetType");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetType() failed. Error Description = %s", 
      (char*)e.Description()) ;
    
    // get the requested index ...
    if (arIndex.vt == VT_BSTR)
    {
      _bstr_t columnName = arIndex.bstrVal ;
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>. Value requested = %s", 
        type, (char*)columnName) ;
    }
    else if (arIndex.vt == VT_I2)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>. Value requested = %x", 
        type, (int)arIndex.iVal) ;
    }
    else if (arIndex.vt == VT_I4)
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>.Value requested = %x", 
        type, (int)arIndex.iVal) ;
    }
    else
    {
      mLogger->LogVarArgs (LOG_ERROR,  "Unknown type detected. Type = <%x>.Unknown value requested = %x", 
        type, (int)arIndex.vt) ;
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
int DBSQLRowset::GetCount() 
{
  int nCount=0 ;
  try 
  {
    nCount = mRowset->Fields->GetCount() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetCount");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetCount() failed. Error Description = %s", 
      (char*)e.Description()) ;
    nCount = 0 ;
  }
  return nCount ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::MoveNext() 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    mRowset->MoveNext() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::MoveNext");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "MoveNext() failed. Error Description = %s", 
      (char*)e.Description()) ;
    bRetCode = FALSE ;
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
BOOL DBSQLRowset::MoveFirst() 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    mRowset->MoveFirst() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::MoveFirst");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "MoveFirst() failed. Error Description = %s", 
      (char*)e.Description()) ;
    bRetCode = FALSE ;
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
BOOL DBSQLRowset::MoveLast() 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    mRowset->MoveLast() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::MoveLast");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "MoveLast() failed. Error Description = %s", 
      (char*)e.Description()) ;
    bRetCode = FALSE ;
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
int DBSQLRowset::GetRecordCount() 
{
  int nCount ;

  try
  {
    nCount = mRowset->GetRecordCount() ;
    if (nCount == -1)
    {
      // This means that the rowset is "unable" to generate a count
      // because of optimizations in cursortype or cursor location
      // make sure we flag this as an error !
      // If you are getting -1 returns, you should not be using this call.
      // Use MoveNext instead.  We think that it should only be used in 
      // disconnected recordsets.
      //
      mLogger->LogVarArgs (LOG_ERROR, "GetRecordCount() failed. Returned -1."); 
      nCount = 0 ;
    }
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetRecordCount");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetRecordCount() failed. Error Description = %s", 
      (char*)e.Description()) ;
    nCount = 0 ;
  }
  return nCount ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBSQLRowset::GetPageSize() 
{
  int nSize ;

  try
  {
    nSize = mRowset->GetPageSize() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetPageSize");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetPageSize() failed. Error Description = %s", 
      (char*)e.Description()) ;
    nSize = 0 ;
  }
  return nSize ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
void DBSQLRowset::SetPageSize(int aPageSize) 
{
  try
  {
    mRowset->PutPageSize(aPageSize) ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::SetPageSize");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "SetPageSize() failed. Error Description = %s", 
      (char*)e.Description()) ;
  }
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
int DBSQLRowset::GetPageCount() 
{
  int nSize ;

  try
  {
    nSize = mRowset->GetPageCount() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetPageCount");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetPageCount() failed. Error Description = %s", 
      (char*)e.Description()) ;
    nSize = 0 ;
  }
  return nSize ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GoToPage(int nPageNum) 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    mRowset->PutAbsolutePage((PositionEnum)nPageNum) ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;

    if (nError != 0x800a0bcd)
    {
      
      SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GoToPage");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, "GoToPage() failed. Error Description = %s", 
        (char*)e.Description()) ;
      bRetCode = FALSE ;
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
int DBSQLRowset::GetPage() 
{
  int nPage ;

  try
  {
    nPage = mRowset->GetAbsolutePage() ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetPage");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "GetPage() failed. Error Description = %s", 
      (char*)e.Description()) ;
    nPage = 0 ;
  }
  return nPage ;
}

//
//	@mfunc
//	Check to see if the rowset is at the end
//  @rdesc 
//  Returns TRUE if the rowset is at the end. Otherwise, FALSE is returned.
//
BOOL DBSQLRowset::AtEOF()
{
  BOOL bRetCode=TRUE ;
  try
  {
    VARIANT_BOOL vtBOOL = mRowset->GetadoEOF() ;

    if (vtBOOL == VARIANT_FALSE)
    {
      bRetCode = FALSE ;
    }
    else
    {
      bRetCode = TRUE ;
    }

    return (bRetCode) ;
  }
  catch (_com_error e)
  {
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::AtEOF");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "AtEOF() failed. Error Description = %s", 
      (char*)e.Description()) ;

		// assert because this should be returned as an error but there's no way
		// to do that.  If you hit this assert it means something is wrong with
		// your code.
		ASSERT(0);

    return TRUE ;
  }
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::GetLongValue (const _variant_t &arIndex, long &aValue) 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

    // get the value from the recordset ...
    vtValue = fieldPtr->Value ;
    
    // if the value is a long value ... return it ...
    if (vtValue.vt == VT_I4) 
    {
      aValue = (long) vtValue.lVal ;
    }
    // else if its a short value ... return it ...
    else if (vtValue.vt == VT_I2)
    {
      aValue = (long) vtValue.iVal ;
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
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetLongValue");
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
        mLogger->LogVarArgs (LOG_ERROR,  "Unknown value requested. Type = %x", 
          (int)arIndex.vt) ;
      }
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::GetLongValue");
    mLogger->LogErrorObject(LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "GetLongValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm
//  @rdesc 
//  
//
BOOL DBSQLRowset::Sort (const std::wstring &arSortOrder) 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    // sort the rowset ...
    mRowset->PutSort (arSortOrder.c_str()) ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::Sort");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Sort() failed. Error Description = %s", 
      (char*)e.Description()) ;
    mLogger->LogVarArgs (LOG_ERROR,  L"Sort order specified = %s", arSortOrder.c_str()) ;
  }

  return bRetCode ;
}

BOOL DBSQLRowset::Filter (const std::wstring &arFilterCriteria) 
{
  // local variables 
  BOOL bRetCode=TRUE ;

  try
  {
    // sort the rowset ...
    mRowset->PutFilter(arFilterCriteria.c_str()) ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::Filter");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Filter() failed. Error Description = %s", 
      (char*)e.Description()) ;
    mLogger->LogVarArgs (LOG_ERROR,  L"Filter criteria specified = %s", arFilterCriteria.c_str()) ;
  }

  return bRetCode ;
}

BOOL DBSQLRowset::Refresh() 
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtFilter=(long)adFilterNone ;

  try
  {
    // sort the rowset ...
    mRowset->PutFilter(vtFilter) ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::Refresh");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Refresh() failed. Error Description = %s", 
      (char*)e.Description()) ;
  }

  return bRetCode ;
}

BOOL DBSQLRowset::PutValue (const _variant_t &arIndex, const _variant_t &aValue)
{
  // local variables 
  BOOL bRetCode=TRUE ;
 
  try
  {
    // get the fields ptr ...
    FieldPtr fieldPtr ;
    GetFieldPtr(arIndex, fieldPtr) ;

	// For Orcale confert empty string to an MT empty string.
	if (mDBTypeIsOracle == TRUE && aValue == _variant_t(""))
		fieldPtr->Value = MTEmptyString;
	else
		fieldPtr->Value = aValue ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    DWORD nError = e.Error() ;
    SetError(nError, ERROR_MODULE, ERROR_LINE, "DBSQLRowset::PutValue");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "PutValue() failed. Error Description = %s", 
      (char*)e.Description()) ;

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


// The AddRow method adds a row to the rowset.
inline void DBSQLRowset::AddRow()
{
	mRowset->AddNew();
}

// The AddColumnData adds the data in the specified column.
inline void DBSQLRowset::AddColumnData(const wchar_t * apName, _variant_t aValue)
{
	// For Orcale confert empty string to an MT empty string.
	if (mDBTypeIsOracle == TRUE && aValue == _variant_t(""))
		mRowset->GetFields()->GetItem(apName)->PutValue(MTEmptyString);
	else
		mRowset->GetFields()->GetItem(apName)->PutValue(aValue);
}

// The ModifyColumnData modifies the data in the specified column.
inline void DBSQLRowset::ModifyColumnData(const wchar_t * apName, _variant_t aValue)
{
	// For Orcale confert empty string to an MT empty string.
	if (mDBTypeIsOracle == TRUE && aValue == _variant_t(""))
		mRowset->GetFields()->GetItem(apName)->PutValue(MTEmptyString);
	else
		mRowset->GetFields()->GetItem(apName)->PutValue(aValue);
}

// The AddColumnDefinition method adds a new column to the rowset definition.
void DBSQLRowset::AddColumnDefinition(const wchar_t * apName, const wchar_t * apType,
																			int aLen)
{
//    With objRs.Fields
//        .Append "Name", adVarChar, 255, adFldUpdatable

	// TODO: are these types correct?
	DataTypeEnum type;
	if (0 == mtwcscasecmp(MTPROP_TYPE_INTEGER, apType))
		type = adInteger;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_BIGINTEGER, apType))
		type = adBigInt;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_DECIMAL, apType))   
		type = adDecimal;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_FLOAT, apType))
		type = adDouble;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_DATE, apType))
		type = adDate;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_BSTR, apType))
		type = adBSTR;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_STRING, apType))
		type = adChar;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_CHAR, apType))
		type = adVarChar;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_EMPTY, apType))
		type = adEmpty;
	else if (0 == mtwcscasecmp(MTPROP_TYPE_CHAR, apType))
		type = adVarChar;
	else
	{
		// TODO: fix me
		ASSERT(0);
		return;
	}

  // allow nulls
  mRowset->GetFields()->Append(apName, type, aLen, 
    FieldAttributeEnum(adFldUpdatable|adFldIsNullable));
}

void DBSQLRowset::AddColumnDefinition(const wchar_t * apName, DataTypeEnum aType,
																			int aLen)
{
	FieldsPtr fields = mRowset->GetFields();
	fields->Append(apName, aType, aLen, 
    FieldAttributeEnum(adFldUpdatable|adFldIsNullable));
	if(aType == adDecimal) {
			FieldPtr field = mRowset->GetFields()->GetItem(apName);
			field->PutNumericScale(METRANET_SCALE_MAX);
			field->PutPrecision(METRANET_PRECISION_MAX);
	}
}

void DBSQLRowset::SetDBTypeIsOracleFlag(BOOL aDBTypeIsOracle)
{
	mDBTypeIsOracle = aDBTypeIsOracle ;
}


BOOL DBSQLRowset::GetDBTypeIsOracleFlag()
{
	return mDBTypeIsOracle ;
}

BOOL DBSQLRowset::SetFilterString(const wchar_t* pFilter)
{
	try
	{
		if(mRowset == NULL) {
			return FALSE;
		}

		mRowset->PutFilter(_variant_t(pFilter));
	}
	catch (_com_error & e) {
		_bstr_t aError("Error occured while setting filter string \"");
		aError += pFilter;
		aError += "\", ";
		if(e.Description().length() == 0) {
			aError += "no error information available";	
		}
		else {
			aError += e.Description();
		}
		mLogger->LogThis(LOG_ERROR,(const char*)aError);
		return FALSE;
	}
	return TRUE;
}

void DBSQLRowset::ResetFilter()
{
	mRowset->PutFilter(L"");
}

void DBSQLRowset::RemoveRow()
{
  mRowset->Delete(adAffectCurrent);
}
