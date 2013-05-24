// MTAccountServer.cpp : Implementation of CMTAccountServer
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTAccountServer.h"
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <mtprogids.h>

#import <RCD.tlb>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <stdutils.h>


/////////////////////////////////////////////////////////////////////////////
// CMTAccountServer

STDMETHODIMP CMTAccountServer::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountAdapter,
		&IID_IMTAccountAdapter2
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ------------------------------------------------------------------------------
// Initialize
STDMETHODIMP CMTAccountServer::Initialize(BSTR AdapterName)
{
    HRESULT hr = S_OK;
	_bstr_t name;
	string buffer;
	bool bDone = false;

	VARIANT_BOOL aCheckSumMatch;
	const char* procName = "CMTAccountServer::Initialize";
	
	_bstr_t bstrAdapterName(AdapterName);
	
	// handle case where adapter name is blank or does not exist
	if(bstrAdapterName.length() == 0) {
		buffer = "Blank adapter name argument";
		mLogger->LogThis(LOG_ERROR,buffer.c_str());
		return Error(buffer.c_str());
	}

	try
	{
		// run the Query 
		MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\AccountType\\*.xml",VARIANT_TRUE);

		if(aFileList->GetCount() == 0) {
			// log error that we can't find any configuration
			const char* pErrorMsg = "CMTAccountServer::Initialize: can not find any configuration files";
			mLogger->LogThis(LOG_ERROR,pErrorMsg);
			return Error(pErrorMsg);
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) return E_FAIL;

		while(!bDone) {

			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) {
				bDone = true;
				break;
			}

			MTConfigLib::IMTConfigPropSetPtr aPropSet = aConfig->ReadConfiguration(afile,&aCheckSumMatch);
      MTConfigLib::IMTConfigPropSetPtr aTypeSet = aPropSet->NextSetWithName("AccountType");
      MTConfigLib::IMTConfigPropSetPtr aViewSet = aTypeSet->NextSetWithName("AccountViews");
      MTConfigLib::IMTConfigPropSetPtr aAdapterSet = aViewSet->NextSetWithName("AdapterSet");

			//MTConfigLib::IMTConfigPropSetPtr aAdapterSet = aPropSet->NextSetWithName(ADAPTER_SET_TAG);
			while (aAdapterSet != NULL)
			{
					name = aAdapterSet->NextStringWithName(NAME_TAG);
				
				if (0 == _wcsicmp(name, bstrAdapterName))
				{
					mName = name;
					mProgID = aAdapterSet->NextStringWithName(PROGID_TAG);
					mConfigFile = aAdapterSet->NextStringWithName(CONFIGFILE_TAG);
					bDone = true;
					break;
				}

				aAdapterSet = aViewSet->NextSetWithName("AdapterSet");
			}
		}
	}
	catch(_com_error& e) 
	{
		_bstr_t bstrError = e.Description();
		if(bstrError.length() == 0) 
		  bstrError = "No detailed information"; 

		mLogger->LogVarArgs(LOG_ERROR, "%s : failed with error \"%s\"", procName, 
						   (const char*)bstrError);
		return ReturnComError(e);
	}


	// handle case where requested adapter does not exist
	if(mProgID.length() == 0) {
		_bstr_t aBuff(procName);
		aBuff += ": failed to find configuration for adapter <";
		aBuff += (const char*) bstrAdapterName;
		aBuff += ">";
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return Error((const char*)aBuff);
	}
	

	// create the account adapter object
  try
  {
    hr = mpAccountAdapter.CreateInstance((char*)mProgID);
    if (!SUCCEEDED(hr))
    {
	    	buffer = "ERROR: Unable to create instance of " + mName + "object";
        mLogger->LogThis(LOG_ERROR, buffer.c_str());
        return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
    }
    
    // let adapter do initialization using config file.
    mpAccountAdapter->Initialize(mConfigFile);
  }
  catch (_com_error& e)
  {
    return ReturnComError(e);
  }
  
	return S_OK;
}

STDMETHODIMP CMTAccountServer::Install()
{
	HRESULT hr = S_OK;

	try
	{
		mpAccountAdapter->Install();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTAccountServer::Uninstall()
{
	HRESULT hr = S_OK;

	try
	{
		mpAccountAdapter->Uninstall();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}


	return S_OK;
}

STDMETHODIMP CMTAccountServer::AddData(BSTR AdapterName,
								       ::IMTAccountPropertyCollection* mtptr,
				                       VARIANT apRowset)
{
	try
	{
		mpAccountAdapter->AddData(mConfigFile, 
								  (MTACCOUNTLib::IMTAccountPropertyCollection*)mtptr, 
								  apRowset);
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountServer::UpdateData(BSTR AdapterName,
									      ::IMTAccountPropertyCollection* mtptr, 
										  VARIANT apRowset)
{	
	try
	{
		// Call the update on the object
    mpAccountAdapter->UpdateData(mConfigFile,
									      (MTACCOUNTLib::IMTAccountPropertyCollection*)mtptr,
                        apRowset);
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountServer::GetData(BSTR AdapterName,
								       long arAccountID,
									   VARIANT apRowset,
								       ::IMTAccountPropertyCollection** mtptr)
{
	try
	{
    MTACCOUNTLib::IMTAccountPropertyCollectionPtr propcollptr = 
		  mpAccountAdapter->GetData(mConfigFile, arAccountID, apRowset);
		
		*mtptr = (::IMTAccountPropertyCollection*)(propcollptr.Detach());
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}



STDMETHODIMP CMTAccountServer::SearchData(BSTR AdapeterName,
										  ::IMTAccountPropertyCollection* apAPC,
										  VARIANT apRowset,
										  ::IMTSearchResultCollection** apSRC)
{
	HRESULT hr = S_OK;

	try
	{
		MTACCOUNTLib::IMTSearchResultCollectionPtr AccPropColl = mpAccountAdapter->SearchData(mConfigFile, 
										(MTACCOUNTLib::IMTAccountPropertyCollection*)apAPC, apRowset);
		
		*apSRC = (::IMTSearchResultCollection*)(AccPropColl.Detach());
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;	
		
}
HRESULT CMTAccountServer::SearchDataWithUpdLock(BSTR AdapterName,
							  ::IMTAccountPropertyCollection* mtptr,
							  BOOL wUpdLock,
							  VARIANT apRowset,							  
							  ::IMTSearchResultCollection** mtp)
{
	HRESULT hr = S_OK;

	try
	{
		MTACCOUNTLib::IMTSearchResultCollectionPtr AccPropColl = mpAccountAdapter->SearchDataWithUpdLock(mConfigFile, 
										(MTACCOUNTLib::IMTAccountPropertyCollection*)mtptr, wUpdLock, apRowset);
		
		*mtp = (::IMTSearchResultCollection*)(AccPropColl.Detach());
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;	
		
}

STDMETHODIMP CMTAccountServer::GetPropertyMetaData(BSTR aPropertyName,
												   ::IMTPropertyMetaData** apMetaData)
{
	try
	{
		MTACCOUNTLib::IMTPropertyMetaDataPtr pPropertyMetaData = mpAccountAdapter->GetPropertyMetaData(aPropertyName);
		*apMetaData = (::IMTPropertyMetaData*)pPropertyMetaData.Detach();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;	
}


