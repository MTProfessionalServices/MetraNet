// MTExecutionInfo.cpp : Implementation of CMTExecutionInfo
#include "StdAfx.h"
#include "ExecutionInfo.h"
#include "MTExecutionInfoDef.h"

/////////////////////////////////////////////////////////////////////////////
// CMTExecutionInfo

STDMETHODIMP CMTExecutionInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTExecutionInfo
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTExecutionInfo::get_SessionSet(IMTSessionSet * * pVal)
{
	if (!pVal)
		return E_POINTER;

	MTPipelineLib::IMTSessionSet * set = mSet;

	*pVal = (IMTSessionSet *) set;
	(*pVal)->AddRef();

	return S_OK;
}

STDMETHODIMP CMTExecutionInfo::put_SessionSet(IMTSessionSet * newVal)
{
	if (!newVal)
		return E_POINTER;

	// assignment does an AddRef
	mSet = newVal;

	return S_OK;
}

STDMETHODIMP CMTExecutionInfo::get_StageName(BSTR *pVal)
{
	*pVal = mStageName.copy();

	return S_OK;
}

STDMETHODIMP CMTExecutionInfo::put_StageName(BSTR newVal)
{
	mStageName = newVal;

	return S_OK;
}

STDMETHODIMP CMTExecutionInfo::get_PlugInName(BSTR *pVal)
{
	*pVal = mPlugInName.copy();

	return S_OK;
}

STDMETHODIMP CMTExecutionInfo::put_PlugInName(BSTR newVal)
{
	mPlugInName = newVal;

	return S_OK;
}
