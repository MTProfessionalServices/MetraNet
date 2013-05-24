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
#include "MTDecimalCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTDecimalCapability



STDMETHODIMP CMTDecimalCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDecimalCapability,
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
STDMETHODIMP CMTDecimalCapability::InitParams()
{
	HRESULT hr(S_OK);
  _variant_t vParam;
  MTOperatorType eOp = OPERATOR_TYPE_EQUAL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		MTAUTHLib::IMTDecimalCapabilityPtr thisPtr = this;

		rowset->SetQueryTag("__GET_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_decimal_capability");
		rowset->AddParam("%%ID%%", thisPtr->ID);
		rowset->Execute();

		if(rowset->GetRowsetEOF().boolVal == FALSE)
		{
      vParam = rowset->GetValue("param_value");
      eOp = StringToOp((_bstr_t)rowset->GetValue("tx_op"));
		}
    
    thisPtr->SetParameter(vParam, (MTAUTHLib::MTOperatorType)eOp);

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTDecimalCapability::SetParameter(VARIANT aParam, MTOperatorType aOp)
{
	//expect the value or enumerator as string
	if(mParam == NULL)
	{
		HRESULT hr = mParam.CreateInstance(MTPROGID_SIMPLECOND);
		if(FAILED(hr))
			return hr;
	}
	_variant_t val = aParam;
	DECIMAL decval = val;
	mParam->Value = decval;
	mParam->Test = OpToString(aOp);
	return S_OK;
}

STDMETHODIMP CMTDecimalCapability::GetParameter(IMTSimpleCondition** apParam)
{
	MTAUTHLib::IMTDecimalCapabilityPtr thisPtr = this;
		//if this parameter is null, then initialize it before calling implies
	if(mParam == NULL)
		thisPtr->InitParams();
	MTAUTHLib::IMTSimpleConditionPtr outPtr = mParam;
	(*apParam) = (IMTSimpleCondition*)outPtr.Detach();
	return S_OK;
}

STDMETHODIMP CMTDecimalCapability::Remove(IMTPrincipalPolicy* aPolicy)
{
	//Remove order is opposite to Save::
	//first every concrete atomic cleans it's parameters
	//and then calls Remove on the base class

	//this method is only called from composite writer executant
	//in order to make it transactional

	try
	{
		MTAUTHEXECLib::IMTDecimalCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTDecimalCapabilityWriter));
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

STDMETHODIMP CMTDecimalCapability::Implies(IMTAtomicCapability *aDemandedCap, VARIANT_BOOL *apResult)
{
	try
	{
		MTAUTHLib::IMTAtomicCapabilityPtr demandedCap = aDemandedCap;
		MTAUTHLib::IMTDecimalCapabilityPtr thatPtr;
		HRESULT hr = demandedCap.QueryInterface(IID_IMTDecimalCapability, (void**)&thatPtr);
		if(FAILED(hr))
		{
			(*apResult) = VARIANT_FALSE;
			return S_OK;
		}
		MTAUTHLib::IMTDecimalCapabilityPtr thisPtr = this;

		MTAUTHLib::IMTSimpleConditionPtr thatParam = thatPtr->GetParameter();

		//if that param is NULL, then always imply it
		//TODO: is this correct? should we return error? should we not imply it? dunno...
		if(thatParam == NULL)
		{
			(*apResult) = VARIANT_TRUE;
			return S_OK;
		}
		
		MTAUTHLib::IMTSimpleConditionPtr thisParam = thisPtr->GetParameter();
		//if this parameter is null, then initialize it before calling implies
		if(thisParam == NULL)
			thisPtr->InitParams();
		
		MTOperatorType op = StringToOp(thisPtr->GetParameter()->Test);
		MTDecimal demandedValue(thatParam->Value);
		MTDecimal myValue(thisPtr->GetParameter()->Value);
		//compare values
		//assume that operator on demanded capability is EQUAL_TO
		switch(op)
		{
		case OPERATOR_TYPE_LESS:
			(*apResult) = (demandedValue < myValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case OPERATOR_TYPE_LESS_EQUAL:
			(*apResult) = (demandedValue <= myValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case OPERATOR_TYPE_EQUAL:
			(*apResult) = (myValue == demandedValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case OPERATOR_TYPE_GREATER_EQUAL:
			(*apResult) = (demandedValue >= myValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case OPERATOR_TYPE_GREATER:
			(*apResult) = (demandedValue > myValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case OPERATOR_TYPE_NOT_EQUAL:
			(*apResult) = (myValue != demandedValue) ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		default:
			(*apResult) = VARIANT_FALSE;
			break;
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CMTDecimalCapability::Save(IMTPrincipalPolicy *aPolicy)
{
	//1. call Base class's Save, get id back
	HRESULT hr(S_OK);
	try
	{
		
		MTAUTHEXECLib::IMTDecimalCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTDecimalCapabilityWriter));
		MTAUTHLib::IMTDecimalCapabilityPtr thisPtr = this;
		MTAUTHLib::IMTSimpleConditionPtr thisParam = thisPtr->GetParameter();

		if(	V_VT(&thisParam->Value) == VT_EMPTY ||
				V_VT(&thisParam->Value) == VT_NULL)
		{
			MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_PARAMETER_NOT_SPECIFIED, 
                        (char*)thisPtr->CapabilityType->Name);
		}

		mAC->Save(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy);

		writer->CreateOrUpdate(thisPtr->ID, (MTAUTHEXECLib::IMTSimpleCondition*)thisParam.GetInterfacePtr());
		
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTDecimalCapability::ToString(BSTR* apString)
{
	try
  {
   	MTAUTHLib::IMTDecimalCapabilityPtr thisPtr = this;
    _bstr_t bstrOut = (_bstr_t)thisPtr->GetParameter()->Value;
    (*apString) = bstrOut.copy();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}