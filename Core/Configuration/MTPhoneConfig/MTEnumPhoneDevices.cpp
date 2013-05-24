// MTEnumPhoneDevices.cpp : Implementation of CMTEnumPhoneDevices
#include "StdAfx.h"
#include <time.h>
#import	<MTConfigLib.tlb> 
using namespace MTConfigLib;

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

#include "PhoneLookup.h"
#include "MTPhoneDevice.h"
#include "MTEnumPhoneDevices.h"




/////////////////////////////////////////////////////////////////////////////
// CMTEnumPhoneDevices

STDMETHODIMP CMTEnumPhoneDevices::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = E_NOTIMPL;

	return hr;
}

STDMETHODIMP CMTEnumPhoneDevices::Add(IMTPhoneDevice * pDev)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;	

	// append data

	CComPtr<IMTPhoneDevice> p = pDev;
	mDeviceList.push_back(p);
	mCount++;

	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mCount;

	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::get_Item(long aIndex, LPDISPATCH * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	if ((aIndex < 1) || (aIndex > mCount))
		return E_INVALIDARG;

	*pVal = mDeviceList[aIndex - 1];
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::Read(BSTR bstrHostName, BSTR bstrFileName)
{
	IMTConfigPtr pConfig;
	IMTConfigPropSetPtr pProp;

	VARIANT_BOOL bCheckSum = false;
	VARIANT_BOOL bSecure = false;
	HRESULT hr;
	_bstr_t RelativePath;


	mFileName = bstrFileName;
	mHostName = bstrHostName;

	RelativePath = bstrFileName;
	pConfig.CreateInstance("MetraTech.MTConfig.1", NULL, CLSCTX_INPROC_SERVER);
	
	if (mHostName != (_bstr_t)"")
		pProp = pConfig->ReadConfigurationFromHost (bstrHostName, RelativePath, bSecure, &bCheckSum);
	else
		pProp = pConfig->ReadConfiguration (RelativePath, &bCheckSum);

	IDispatch * pDispatch;
	hr = pProp->QueryInterface(IID_IDispatch, (void**)&pDispatch);
	if (FAILED(hr))
	{
		return hr;
	}

	hr = InitFromPropSet (pDispatch);
	pDispatch->Release();

	return hr;
}

STDMETHODIMP CMTEnumPhoneDevices::ReadFromDatabase()
{
 
	IMTPhoneDevice * pDevice;

  ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
	rowset->Init("queries\\PhoneCrack");
	rowset->SetQueryTag("__READ_DEVICES__");
	//rowset->AddParam("%%COUNTRY%%", bstrCountry);
  rowset->Execute();

	for(int i=0;i<rowset->GetRecordCount();i++)
  {
    	pDevice = NULL;
			HRESULT hRes = CoCreateInstance(CLSID_MTPhoneDevice, NULL,CLSCTX_SERVER, IID_IMTPhoneDevice, (void **)&pDevice);
			if (FAILED(hRes))
				return hRes;

			_bstr_t aString = rowset->GetValue("name");
			pDevice->put_Name (aString);
			aString = rowset->GetValue("description");
			pDevice->put_Description (aString);
			aString = rowset->GetValue("lineaccess");
			pDevice->put_LineAccessCode (aString);
			aString = rowset->GetValue("countryname");
			pDevice->put_CountryName (aString);
			aString = rowset->GetValue("nationalcode");
			pDevice->put_NationalDestinationCode (aString);

      Add (pDevice);
			pDevice->Release();

      rowset->MoveNext();
	}
	
  return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::InitFromPropSet(IDispatch * pSet)
{
	IMTConfigPropSetPtr pPropSet(pSet);
	IMTPhoneDevice * pDevice;

	IMTConfigPropSetPtr device = pPropSet->NextSetWithName(OLESTR("devices"));
	while ((bool) device)
		{
			pDevice = NULL;
			HRESULT hRes = CoCreateInstance(CLSID_MTPhoneDevice, NULL,CLSCTX_SERVER, IID_IMTPhoneDevice, (void **)&pDevice);
			if (FAILED(hRes))
				return hRes;

			_bstr_t aString = device->NextStringWithName("name");
			pDevice->put_Name (aString);
			aString = device->NextStringWithName("description");
			pDevice->put_Description (aString);
			aString = device->NextStringWithName("lineaccess");
			pDevice->put_LineAccessCode (aString);
			aString = device->NextStringWithName("countryname");
			pDevice->put_CountryName (aString);
			aString = device->NextStringWithName("nationalcode");
			pDevice->put_NationalDestinationCode (aString);
			Add (pDevice);
			pDevice->Release();
			device = pPropSet->NextSetWithName(OLESTR("devices"));
		}

	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::Write()
{
	// Save the device list to a file 

    IMTConfigPtr config("MetraTech.MTConfig.1");
    IMTConfigPropSetPtr PropSet;
    
    // TODO: should this always be xmlconfig?
    PropSet = config->NewConfiguration("xmlconfig");

	// insert header information: effective date, timeout value etc.
	IMTConfigPropSetPtr header = PropSet->InsertSet("mtsysconfigdata");

	for (int i=1; i <= mCount; i++)
	{
		HRESULT hr;
		IMTConfigPropSetPtr mtDevice = PropSet->InsertSet("devices");
		CComPtr<IMTPhoneDevice> pDev(mDeviceList[i-1]);	
		BSTR aString;
		hr = pDev->get_Name (&aString);
		mtDevice->InsertProp("name", MTConfigLib::PROP_TYPE_STRING, aString);
		hr = pDev->get_Description (&aString);
		mtDevice->InsertProp("description", MTConfigLib::PROP_TYPE_STRING, aString);
		hr = pDev->get_LineAccessCode (&aString);
		mtDevice->InsertProp("lineaccess", MTConfigLib::PROP_TYPE_STRING, aString);
		hr = pDev->get_CountryName (&aString);
		mtDevice->InsertProp("countryname", MTConfigLib::PROP_TYPE_STRING, aString);
		hr = pDev->get_NationalDestinationCode (&aString);
		mtDevice->InsertProp("nationalcode", MTConfigLib::PROP_TYPE_STRING, aString);
	}

	_bstr_t RelativePath;
	VARIANT_BOOL bSecure = VARIANT_FALSE;

	RelativePath = mFileName;
	char * c1 = mHostName;
	char * c2 = RelativePath;

    if (mHostName != (_bstr_t)"")
		PropSet->WriteToHost(mHostName, RelativePath, L"", L"",
									bSecure, VARIANT_TRUE);
	else
		PropSet->Write(RelativePath);
		
	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::Remove(long aIndex)
{

	if ((aIndex < 1) || (aIndex > mCount))
		return E_INVALIDARG;

	mDeviceList.erase(mDeviceList.begin() + aIndex - 1);
	mCount--;
	return S_OK;
}

STDMETHODIMP CMTEnumPhoneDevices::FindDeviceByName(BSTR bstrName, LPDISPATCH *lpDev)
{
	if(lpDev == NULL)
    return E_POINTER;
  (*lpDev) = NULL;
  
  _bstr_t name = bstrName;
	
	
  PHONELOOKUPLib::IMTPhoneDevicePtr outPtr;

  vector<CComPtr<IMTPhoneDevice> >::const_iterator it;
	
  //BP: TODO: iterate for now, reimplement as map if
  //it hurts performance too much
	for (it = mDeviceList.begin();  it != mDeviceList.end(); it++)
	{
		outPtr = (IMTPhoneDevice *) (*it);
    if(wcsicmp((wchar_t*)name, (wchar_t*)outPtr->Name) == 0)
    {
      (*lpDev) = outPtr.Detach();
      return S_OK;
    }
	}
	return E_FAIL;
}
