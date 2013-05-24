/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#include "StdAfx.h"
#include "MTAuth.h"
#include "MTEnumTypeCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCapability

STDMETHODIMP CMTEnumTypeCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTEnumTypeCapability,
    &IID_IMTAtomicCapability,
    &IID_IMTCapability
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTEnumTypeCapability::InitParams()
{
	HRESULT hr(S_OK);
  _variant_t vParam;
  
	try
	{
		MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;
    if(thisPtr->ID > 0)
    {
      
      if(mEnumConfig == NULL)
      {
        hr = mEnumConfig.CreateInstance("Metratech.MTEnumConfig");
        if(FAILED(hr))
          return hr;
      }
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init(CONFIG_DIR);
      
      
      rowset->SetQueryTag("__GET_PARAMETER__");
      rowset->AddParam("%%TABLE_NAME%%", "t_enum_capability");
      rowset->AddParam("%%ID%%", thisPtr->ID);
      rowset->Execute();
      
      if(rowset->GetRowsetEOF().boolVal == FALSE)
      {
        vParam = mEnumConfig->GetEnumeratorValueByID(rowset->GetValue("param_value"));
      }
    }
    thisPtr->SetParameter(vParam);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::SetParameter(VARIANT aParam)
{
  HRESULT hr(S_OK);
  //expect the value or enumerator as string
  try
  {
    if (mEnumConfig == NULL)
      hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
    if(FAILED(hr))
      return hr;
    
    if(mParam == NULL)
    {
      hr = mParam.CreateInstance(MTPROGID_SIMPLECOND);
      if(FAILED(hr))
        return hr;
    }
    _variant_t val = aParam;
   
    MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;
    _bstr_t bstrVal = thisPtr->CapabilityType->ParameterName;
    if(bstrVal.length() == 0)
      MT_THROW_COM_ERROR(MTAUTH_ENUM_CAPABILITY_PARAMETER_NAME_NOT_INITIALIZED);
    std::wstring strFullValue((wchar_t*)bstrVal);
    int pos = strFullValue.find_last_of(L"/");
    if(pos < 0)
      MT_THROW_COM_ERROR(MTAUTH_INVALID_ENUM_CAPABILITY_PARAMETER_NAME, (char*)bstrVal);
    
    std::wstring strEnumSpace = strFullValue.substr(0, pos);
    std::wstring strEnumType = strFullValue.substr(pos+1);
    mParam->EnumSpace = strEnumSpace.c_str();
    mParam->EnumType = strEnumType.c_str();

    switch(V_VT(&val))
    {
    case VT_I4:
    case VT_I2:
    case VT_I8:
	  case VT_DECIMAL:
    {
      mParam->Value = mEnumConfig->GetEnumeratorValueByID(val);
      break;
    }
    default:
    {
      //work with both enumerators and enumerator values
      _bstr_t bstrVal = (_bstr_t)val;
      if(bstrVal.length() > 0)
      {
        long id = mEnumConfig->GetID(mParam->EnumSpace, mParam->EnumType, bstrVal);
        mParam->Value = mEnumConfig->GetEnumeratorValueByID(id);
      }
      break;
    }
    ASSERT(0);
    }
   
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::GetParameter(IMTSimpleCondition** apParam)
{
	MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;
		//if this parameter is null, then initialize it before calling implies
	if(mParam == NULL)
		thisPtr->InitParams();
	MTAUTHLib::IMTSimpleConditionPtr outPtr = mParam;
	(*apParam) = (IMTSimpleCondition*)outPtr.Detach();
	return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::Remove(IMTPrincipalPolicy* aPolicy)
{
	//Remove order is opposite to Save::
	//first every concrete atomic cleans it's parameters
	//and then calls Remove on the base class

	//this method is only called from composite writer executant
	//in order to make it transactional

	try
	{
		MTAUTHEXECLib::IMTEnumTypeCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTEnumTypeCapabilityWriter));
		MTAUTHLib::IMTAtomicCapabilityPtr thisPtr = this;
		//remove parameters
		writer->Remove(thisPtr->ID);
		mAC->Remove(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::Implies(IMTAtomicCapability *aDemandedCap, VARIANT_BOOL *apResult)
{
  try
  {
    MTAUTHLib::IMTAtomicCapabilityPtr demandedCap = aDemandedCap;
    MTAUTHLib::IMTEnumTypeCapabilityPtr thatPtr = demandedCap;
    if(thatPtr == NULL)
    {
      (*apResult) = VARIANT_FALSE;
      return S_OK;
    }
    
    MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;
    MTAUTHLib::IMTSimpleConditionPtr thatParam = thatPtr->GetParameter();
    
    //if that param is NULL, then always imply it
    //TODO: is this correct? should we return error? should we not imply it? dunno...
    if(    thatParam == NULL 
      || V_VT(&thatParam->Value) == VT_EMPTY 
      || V_VT(&thatParam->Value) == VT_NULL
      || ((_bstr_t)thatParam->Value).length() == 0)
    {
      (*apResult) = VARIANT_TRUE;
      return S_OK;
    }
    
    MTAUTHLib::IMTSimpleConditionPtr thisParam = thisPtr->GetParameter();
    //if this parameter is null, then initialize it before calling implies
    if(thisParam == NULL)
      thisPtr->InitParams();
    
    
    
    
    //compare values
    _bstr_t demandedValue = (_bstr_t)thatPtr->GetParameter()->Value;
    _bstr_t myValue = (_bstr_t)thisPtr->GetParameter()->Value;
    
    //special case access level enum type to achieve "write implies read" behaviour.
    _bstr_t bstrParamName = thatPtr->CapabilityType->ParameterName;
    if(stricmp((char*)bstrParamName, "Global/AccessLevel") == 0)
    {
      if(stricmp((char*)myValue, "WRITE") == 0)
      {
        (*apResult) = VARIANT_TRUE;
        return S_OK;
      }
    }
    
    (*apResult) = (_wcsicmp((wchar_t*)demandedValue, (wchar_t*)myValue) == 0) ? VARIANT_TRUE : VARIANT_FALSE;
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

	return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::Save(IMTPrincipalPolicy *aPolicy)
{
	//1. call Base class's Save, get id back
	HRESULT hr(S_OK);
	try
	{
		
		MTAUTHEXECLib::IMTEnumTypeCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTEnumTypeCapabilityWriter));
		MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;

		MTAUTHLib::IMTSimpleConditionPtr thisParam = thisPtr->GetParameter();

		if(	V_VT(&thisParam->Value) == VT_EMPTY ||
				V_VT(&thisParam->Value) == VT_NULL)
		{
			MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_PARAMETER_NOT_SPECIFIED, 
                        (char*)thisPtr->CapabilityType->Name);
		}

		mAC->Save(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy);

		//2. Every concrete atomic saves it's parameters
		if(mEnumConfig == NULL)
		{
			hr = mEnumConfig.CreateInstance("Metratech.MTEnumConfig");
			if(FAILED(hr))
				return hr;
		}
		//we have parameter name property on the type, parse out
		//enumspace and aneum type from it
		_bstr_t param = thisPtr->CapabilityType->ParameterName;
		_bstr_t enumSpace;
		_bstr_t enumType;
		std::wstring strParam = (wchar_t*)param;
		int pos = strParam.find_last_of(L"/");
		if (pos == -1)
			MT_THROW_COM_ERROR(MTAUTH_INVALID_ENUM_CAPABILITY_PARAMETER_NAME, (char*)param);

		enumSpace = strParam.substr(0, pos).c_str();
		enumType = strParam.substr(pos+1, strParam.length()).c_str();
		_variant_t id = mEnumConfig->GetID(enumSpace, enumType, (_bstr_t)thisParam->Value);
		writer->CreateOrUpdate(thisPtr->ID, id);
		
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTEnumTypeCapability::ToString(BSTR* apString)
{
	try
  {
   	MTAUTHLib::IMTEnumTypeCapabilityPtr thisPtr = this;
    _bstr_t bstrOut = (_bstr_t)thisPtr->GetParameter()->Value;
    (*apString) = bstrOut.copy();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}