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

// MTStringCollectionCapability.cpp : Implementation of CMTStringCollectionCapability
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTStringCollectionCapability.h"
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcMetadata.h>
#include <OdbcStatement.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcResourceManager.h>

#include <boost/shared_ptr.hpp>
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Auth.Capabilities.tlb> inject_statement("using namespace mscorlib;")
#include <GenericCollection.h>

/////////////////////////////////////////////////////////////////////////////
// CMTStringCollectionCapability

STDMETHODIMP CMTStringCollectionCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTStringCollectionCapability,
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

STDMETHODIMP CMTStringCollectionCapability::Implies(IMTAtomicCapability *aDemandedCap, VARIANT_BOOL *apResult)
{
	//1. call Implies on the base class
	//base does simple check if the passed in object is of the same
	//type
	try
	{
		MTAUTHLib::IMTAtomicCapabilityPtr demandedCap = aDemandedCap;
		MTAUTHLib::IMTStringCollectionCapabilityPtr thatPtr;
		HRESULT hr = demandedCap.QueryInterface(IID_IMTStringCollectionCapability, (void**)&thatPtr);
		if(FAILED(hr))
		{
			(*apResult) = VARIANT_FALSE;
			return S_OK;
		}
		MTAUTHLib::IMTStringCollectionCapabilityPtr thisPtr = this;
		//2. If base check succeeded, every concrete atomic does it's own thing
		MTAUTHLib::IMTCollectionPtr thisParam = thisPtr->GetParameter();
		MTAUTHLib::IMTCollectionPtr thatParam = thatPtr->GetParameter();

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
		

		long thatCount = thatParam->Count;
		long thisCount = thisParam->Count;
		CComVariant thisVal, thatVal;
		string thisStr, thatStr;
//		char *thisStr, *thatStr;
		(*apResult) = VARIANT_TRUE;
		bool matchedString = false;
		for (int i=1; i<=thatCount; ++i)
		{
			thatVal = thatParam->GetItem(i);
			thatVal.ChangeType(VT_BSTR);
			thatStr = (const char*)_bstr_t(thatVal.bstrVal);
			matchedString = false;
			for (int j=1; j<=thisCount; ++j)
			{	
				thisVal = thisParam->GetItem(j);
				thisVal.ChangeType(VT_BSTR);
				thisStr = (const char*)_bstr_t(thisVal.bstrVal);

				if (thisStr.compare(thatStr) == 0){
					matchedString = true;
					break;
				}
			}
			if (!matchedString){
				(*apResult) = VARIANT_FALSE;
				break;
			}
		}
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTStringCollectionCapability::Save(IMTPrincipalPolicy* aPolicy)
{
	//1. call Base class's Save, get id back
	try
	{
		
		MetraTech_Auth_Capabilities::IMTStringCollectionCapabilityWriterPtr writer
			(__uuidof(MetraTech_Auth_Capabilities::MTStringCollectionCapabilityWriter));
		MTAUTHLib::IMTStringCollectionCapabilityPtr thisPtr = this;

		mAC->Save(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy);
		MTAUTHLib::IMTCollectionPtr thisParam = thisPtr->GetParameter();
		if(thisParam->Count == 0)
		{
			MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_PARAMETER_NOT_SPECIFIED, 
                        thisPtr->CapabilityType->Name);
		}
		writer->CreateOrUpdate(thisPtr->ID, thisParam);
		
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	
	return S_OK;
}

STDMETHODIMP CMTStringCollectionCapability::Remove(IMTPrincipalPolicy* aPolicy)
{
	//Remove order is opposite to Save::
	//first every concrete atomic cleans it's parameters
	//and then calls Remove on the base class

	//this method is only called from composite writer executant
	//in order to make it transactional

	try
	{
		MetraTech_Auth_Capabilities::IMTStringCollectionCapabilityWriterPtr writer
			(__uuidof(MetraTech_Auth_Capabilities::MTStringCollectionCapabilityWriter));
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

STDMETHODIMP CMTStringCollectionCapability::InitParams()
{
	HRESULT hr(S_OK);

	try
	{
		MTAUTHLib::IMTStringCollectionCapabilityPtr thisPtr = this;

		boost::shared_ptr<COdbcConnection>conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
		conn->SetAutoCommit(true);
		MTAUTHLib::IMTCollectionPtr paramCollection("Metratech.MTCollection.1");
		boost::shared_ptr<COdbcPreparedArrayStatement> reader (conn ->PrepareStatementFromFile("Queries\\Auth","__GET_STRING_PARAM__"));
		reader->SetInteger(1, thisPtr->ID);
		boost::shared_ptr<COdbcPreparedResultSet> rs (reader->ExecuteQuery()); 
		while (rs->Next())
		{
			wstring tempStr = rs->GetWideString(1);
			_variant_t tempVar = new _variant_t(tempStr.c_str());
			paramCollection->Add(tempVar);
		}
		rs->Close();
		thisPtr->SetParameter(paramCollection);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}


STDMETHODIMP CMTStringCollectionCapability::SetParameter(IMTCollection *strings)
{
	HRESULT hr(S_OK);
	if (mParameter == NULL)
	{
		hr = mParameter.CreateInstance(__uuidof(MTCollection));
		if(FAILED(hr))
			return hr;
	}
	mParameter = strings;
	return S_OK;
}

STDMETHODIMP CMTStringCollectionCapability::GetParameter(IMTCollection* *apParam)
{
	MTAUTHLib::IMTStringCollectionCapabilityPtr thisPtr = this;

		//if this parameter is null, then create a new empty one
	HRESULT hr(S_OK);
	if (mParameter == NULL)
	{
		hr = mParameter.CreateInstance(__uuidof(MTCollection));
		if(FAILED(hr))
			return hr;
	}

	MTAUTHLib::IMTCollectionPtr outPtr = mParameter;
	(*apParam) = (IMTCollection*)outPtr.Detach();

	return S_OK;
}


STDMETHODIMP CMTStringCollectionCapability::ToString(BSTR* apString)
{
	try
  {
//    (*apString) = (_bstr_t)(mParameter->getItem(0)) ;
    (*apString) = (_bstr_t)("test") ;
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;
}