#ifndef __SUMADAPTERSKELETON_H__
#define __SUMADAPTERSKELETON_H__
#pragma once

#include <MTSummaryAdapter.h>
#include <MTSummaryAdapter_i.c>
#include <ComSkeleton.h>
#include <comdef.h>
#include <ServicesCollection.h>


template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTSumAdapterSkeleton : 
  public MTImplementedInterface<T,IMTSummaryAdapter,pclsid,&IID_IMTSummaryAdapter,ThreadModel>
{
public:
	MTSumAdapterSkeleton() : mNumProps(0), mCurrentProp(0), mpServiceDef(NULL) {}
	STDMETHOD(Init)(BSTR pService,::IMTConfigPropSet* pPropSet);

protected: // methods
	const wchar_t* GetNextServiceDn();
	void ResetPropCount() { mCurrentProp = 0; }
	unsigned long NumProps() { return mNumProps; }
protected: // data
	CMSIXDefinition* mpServiceDef;
	unsigned long mNumProps;
	unsigned long mCurrentProp;
	CServicesCollection aServicesCollection;
	_bstr_t aServiceName;
};

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSumAdapterSkeleton<T,pclsid,ThreadModel>::Init
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR pService
// Argument         : ::IMTConfigPropSet* pPropSet
/////////////////////////////////////////////////////////////////////////////

template <class T, const CLSID* pclsid, class ThreadModel>
	STDMETHODIMP MTSumAdapterSkeleton<T,pclsid,ThreadModel>::Init(BSTR pService,::IMTConfigPropSet* pPropSet)
{
	HRESULT hr = S_OK;
	aServiceName = pService;

	if(aServicesCollection.Initialize()) {
		 aServicesCollection.FindService(std::wstring(pService),mpServiceDef);
		 mNumProps = mpServiceDef->GetMSIXPropertiesList().size();
	}
	else {
		hr = E_FAIL;
	}

	return hr;
}

template <class T, const CLSID* pclsid, class ThreadModel>
const wchar_t* MTSumAdapterSkeleton<T,pclsid,ThreadModel>::GetNextServiceDn()
{
	if(mCurrentProp >= mNumProps) {
		return NULL;
	}
	return (const wchar_t*)(mpServiceDef->GetMSIXPropertiesList()[mCurrentProp++]->GetDN());
}

#endif //__SUMADAPTERSKELETON_H__
