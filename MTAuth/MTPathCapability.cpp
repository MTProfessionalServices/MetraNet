/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* Created by: Boris Partensky
* 
***************************************************************************/

// MTPathCapability.cpp : Implementation of CMTPathCapability
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTPathCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPathCapability

STDMETHODIMP CMTPathCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTPathCapability,
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

STDMETHODIMP CMTPathCapability::Implies(IMTAtomicCapability *aDemandedCap, VARIANT_BOOL *apResult)
{
	//1. call Implies on the base class
	//base does simple check if the passed in object is of the same
	//type
	try
	{
		MTAUTHLib::IMTAtomicCapabilityPtr demandedCap = aDemandedCap;
		MTAUTHLib::IMTPathCapabilityPtr thatPtr;
		HRESULT hr = demandedCap.QueryInterface(IID_IMTPathCapability, (void**)&thatPtr);
		if(FAILED(hr))
		{
			(*apResult) = VARIANT_FALSE;
			return S_OK;
		}
		MTAUTHLib::IMTPathCapabilityPtr thisPtr = this;
		//2. If base check succeeded, every concrete atomic does it's own thing
		MTAUTHLib::IMTPathParameterPtr thisParam = thisPtr->GetParameter();
		MTAUTHLib::IMTPathParameterPtr thatParam = thatPtr->GetParameter();

		//if that param is NULL, then always imply it
		//TODO: is this correct? should we return error? should we not imply it? dunno...
		if(thatParam == NULL)
		{
			(*apResult) = VARIANT_TRUE;
			return S_OK;
		}
			
		//if this parameter is null, then initialize it before calling implies
		if(thisParam == NULL)
			thisPtr->InitParams();
		

		CMTPathRegEx demandedPath(GetFullPath((IMTPathParameter*)thatParam.GetInterfacePtr()));
		CMTPathRegEx myPath(GetFullPath((IMTPathParameter *)thisPtr->GetParameter().GetInterfacePtr()));
		(*apResult) = myPath.Implies(demandedPath) == TRUE;
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTPathCapability::Save(IMTPrincipalPolicy* aPolicy)
{
	//1. call Base class's Save, get id back
	try
	{
		
		MTAUTHEXECLib::IMTPathCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTPathCapabilityWriter));
		MTAUTHLib::IMTPathCapabilityPtr thisPtr = this;

		mAC->Save(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy);

		//2. Every concrete atomic saves it's parameters
		
		//may be lazy loading of parameters isn't such a good idea
		//another way to do it is initializa all parameters when policy is fetched
			
		if(thisPtr->GetParameter()->Path.length() == 0)
		{
			MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_PARAMETER_NOT_SPECIFIED, 
                        thisPtr->CapabilityType->Name);
		}
		writer->CreateOrUpdate(thisPtr->ID, GetFullPath((IMTPathParameter*)mPathParameter.GetInterfacePtr()));
		
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	
	return S_OK;
}

STDMETHODIMP CMTPathCapability::Remove(IMTPrincipalPolicy* aPolicy)
{
	//Remove order is opposite to Save::
	//first every concrete atomic cleans it's parameters
	//and then calls Remove on the base class

	//this method is only called from composite writer executant
	//in order to make it transactional

	try
	{
		MTAUTHEXECLib::IMTPathCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTPathCapabilityWriter));
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

STDMETHODIMP CMTPathCapability::InitParams()
{
	HRESULT hr(S_OK);
 _variant_t vParam = "";
  MTHierarchyPathWildCard eOp = SINGLE;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		MTAUTHLib::IMTPathCapabilityPtr thisPtr = this;

		rowset->SetQueryTag("__GET_PARAMETER__");
		rowset->AddParam("%%TABLE_NAME%%", "t_path_capability");
		rowset->AddParam("%%ID%%", thisPtr->ID);
		rowset->Execute();

		if(rowset->GetRowsetEOF().boolVal == FALSE)
		{
			CMTPathRegEx regex((_bstr_t)rowset->GetValue("param_value"));
      vParam = regex.GetCPath();
      eOp = (MTHierarchyPathWildCard)regex.GetPathWildCard();
			
		}

    thisPtr->SetParameter((_bstr_t)vParam, 
				(MTAUTHLib::MTHierarchyPathWildCard)eOp);

			
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}


STDMETHODIMP CMTPathCapability::SetParameter(BSTR aPath, MTHierarchyPathWildCard aWildCard)
{
	HRESULT hr(S_OK);
	if (mPathParameter == NULL)
	{
		hr = mPathParameter.CreateInstance(__uuidof(MTAUTHLib::MTPathParameter));
		if(FAILED(hr))
			return hr;
	}
	mPathParameter->Path = aPath;
	mPathParameter->WildCard = (MTAUTHLib::MTHierarchyPathWildCard)aWildCard;

	return S_OK;
}

STDMETHODIMP CMTPathCapability::GetParameter(IMTPathParameter **pVal)
{
	if(pVal == NULL)
		return E_POINTER;
	(*pVal) = NULL;
	
	MTAUTHLib::IMTPathCapabilityPtr thisPtr = this;
		//if this parameter is null, then initialize it before calling implies
	if(mPathParameter == NULL)
		thisPtr->InitParams();

	MTAUTHLib::IMTPathParameterPtr outPtr = mPathParameter;
	(*pVal) = (IMTPathParameter*)outPtr.Detach();

	return S_OK;
}

_bstr_t CMTPathCapability::GetFullPath(IMTPathParameter* aParam)
{
	MTAUTHLib::IMTPathParameterPtr paramPtr = aParam;
	std::wstring strPath = (wchar_t*)paramPtr->Path;
  if(strPath.length() > 3098) /*db max is 4000 chars*/
    MT_THROW_COM_ERROR(MTAUTH_PATH_TOO_LONG);
  wchar_t firstChar = (strPath[0] == L'/') ? L'' : L'/';
  wchar_t lastChar = (strPath[strPath.length() - 1] == L'/') ? L'' : L'/';
  wchar_t wildCardChar = L'';

	switch((MTHierarchyPathWildCard)paramPtr->WildCard)
	{
		case DIRECT_DESCENDENTS:
			wildCardChar = L'*';
			break;
		case RECURSIVE:
			wildCardChar = L'-';
			break;
		case SINGLE:
			break;
		default:
			ASSERT(0);
	}
  _bstr_t outStr;
  wchar_t buf[4096];
  wsprintf(buf, L"%c%s%c%c", firstChar, strPath.c_str(), 
    (lastChar == 0 ? wildCardChar : lastChar), 
    (lastChar == 0 ? 0 : wildCardChar));
  outStr = (buf[0] == L'') ? (buf+1) : buf;
	
	return outStr.copy();
}

STDMETHODIMP CMTPathCapability::ToString(BSTR* apString)
{
	try
  {
   	MTAUTHLib::IMTPathCapabilityPtr thisPtr = this;
    _bstr_t bstrOut = GetFullPath((IMTPathParameter*)thisPtr->GetParameter().GetInterfacePtr());
    (*apString) = bstrOut.copy();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}