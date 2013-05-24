#ifndef __MTXMLIOIMPL_H__
#define __MTXMLIOIMPL_H__
#pragma once

#import <MTConfigLib.tlb>
#include <mtprogids.h>


template<class T, const IID* piid,bool bUseConfigLoader=false,const GUID* plibid = &CComModule::m_libid>
class MTXmlIOImpl : public IDispatchImpl<T,piid,plibid>
{
public:
	MTXmlIOImpl() : pTopConfigTag(L"xmlconfig"), pConfigLoaderTag(L"mtconfigdata") {}
	STDMETHOD(ReadFromFile)(BSTR pFileName);
	STDMETHOD(WriteToFile)(BSTR pFileName);
	STDMETHOD(ReadFromHost)(BSTR aHost,BSTR aUser,BSTR aPassword,BSTR pFileName,VARIANT_BOOL pSecure);
	STDMETHOD(WriteToHost)(BSTR aHost,BSTR aUser,BSTR aPassword,BSTR pFileName,VARIANT_BOOL pSecure);
	STDMETHOD(Read)(IMTConfigPropSet* pPropSet)  { return E_NOTIMPL; }
	STDMETHOD(Write)(IMTConfigPropSet* pPropSet) { return E_NOTIMPL; }

protected:

	HRESULT ReadFrom(BSTR pFileName,BSTR pHost = NULL,BSTR pUser = NULL,BSTR pPassword = NULL,VARIANT_BOOL aSecure = VARIANT_FALSE);
	HRESULT WriteTo(BSTR pFileName,BSTR pHost = NULL,BSTR pUser = NULL,BSTR pPassword = NULL,VARIANT_BOOL aSecure = VARIANT_FALSE);

	const wchar_t* pTopConfigTag;
	const wchar_t* pConfigLoaderTag;
};

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::ReadFrom
// Description	    : 
// Return type		: HRESULT 
// Argument         : BSTR pFileName
// Argument         : BSTR pHost = NULL
/////////////////////////////////////////////////////////////////////////////

HRESULT MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::ReadFrom(BSTR pFileName,
																															BSTR pHost,
																															BSTR pUser,
																															BSTR pPassword,
																															VARIANT_BOOL aSecure)
{
	MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);
	
	VARIANT_BOOL checksumMatch;
	MTConfigLib::IMTConfigPropSetPtr aPropset;
	HRESULT hr = E_FAIL;

	do {

		if(!pHost) {
			// do local propset
			aPropset = aConfig->ReadConfiguration(pFileName,&checksumMatch);
		}
		else {
			ASSERT(pHost && pUser && pPassword);
			if(!(pHost && pUser && pPassword)) break;


			aConfig->PutUsername(pUser);
			aConfig->PutPassword(pPassword);
			aConfig->PutSecureFlag(aSecure);
			aPropset = aConfig->ReadConfigurationFromHost(pHost,pFileName,aSecure,&checksumMatch);
		}

		if(bUseConfigLoader) {
			MTConfigLib::IMTConfigPropSetPtr aConfigLoaderSet = aPropset->NextSetWithName(pConfigLoaderTag);
			hr = Read((::IMTConfigPropSet*)aConfigLoaderSet.GetInterfacePtr());
		}
		else {
			hr = Read((::IMTConfigPropSet*)aPropset.GetInterfacePtr());
		}
	} while(false);

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::WriteTo
// Description	    : 
// Return type		: HRESULT 
// Argument         : BSTR pFileName
// Argument         : BSTR pHost = NULL
/////////////////////////////////////////////////////////////////////////////

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>
HRESULT MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::WriteTo(BSTR pFileName,
																														 BSTR pHost,
																														 BSTR pUser,
																														 BSTR pPassword,
																														 VARIANT_BOOL aSecure)
{
	MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

	MTConfigLib::IMTConfigPropSetPtr aPropset = aConfig->NewConfiguration(pTopConfigTag);

	HRESULT hr;

	if(bUseConfigLoader) {
		MTConfigLib::IMTConfigPropSetPtr aConfigLoaderSet = aPropset->InsertSet(pConfigLoaderTag);
		hr = Write((::IMTConfigPropSet*)aConfigLoaderSet.GetInterfacePtr());
	}
	else {
		 hr= Write((::IMTConfigPropSet*)aPropset.GetInterfacePtr());
	}
	
	if(SUCCEEDED(hr)) {
		if(!pHost) {
			hr = aPropset->Write(pFileName);
		}
		else {
			ASSERT(pUser && pPassword);
			if(pUser && pPassword) {
				hr = aPropset->WriteToHost(pHost,pFileName,pUser,pPassword,aSecure,VARIANT_FALSE);
			}
			else {
				hr = E_POINTER;
			}
		}

	}
	return hr;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::ReadFromFile
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR pFileName
/////////////////////////////////////////////////////////////////////////////

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>
STDMETHODIMP MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::ReadFromFile(BSTR pFileName)
{
	return ReadFrom(pFileName);
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::WriteToFile
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR pFileName
/////////////////////////////////////////////////////////////////////////////

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>
STDMETHODIMP MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::WriteToFile(BSTR pFileName)
{
	return WriteTo(pFileName);
}

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>
STDMETHODIMP MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::ReadFromHost(BSTR aHost,
																																				BSTR aUser,
																																				BSTR aPassword,
																																				BSTR pFileName,
																																				VARIANT_BOOL pSecure)
{
	return ReadFrom(pFileName,aHost,aUser,aPassword,pSecure);
}

template<class T, const IID* piid, bool bUseConfigLoader,const GUID* plibid>
STDMETHODIMP MTXmlIOImpl<T,piid,bUseConfigLoader,plibid>::WriteToHost(BSTR aHost,
																																			BSTR aUser,
																																			BSTR aPassword,
																																			BSTR pFileName,
																																			VARIANT_BOOL pSecure)
{
	return WriteTo(pFileName,aHost,aUser,aPassword,pSecure);
}

#endif //__MTXMLIOIMPL_H__
