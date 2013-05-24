#include "myobj.h"
#include "ashhelloworld.h"

#define CLSID_MYOBJ_TYPEINFO CLSID_myObject

CMyObject::CMyObject() :
m_cRefCount(0),
m_pTypeInfo(0)
{
	FetchTypeInfo(0x0,CLSID_MYOBJ_TYPEINFO);
}

CMyObject::~CMyObject()
{
   if (m_pTypeInfo != NULL){
      m_pTypeInfo->Release();
      m_pTypeInfo = NULL;
   }

}


STDMETHODIMP CMyObject::QueryInterface(REFIID riid, void**ppvObj)
{
	HRESULT hr = S_OK;

	if (riid == IID_IUnknown)
		*ppvObj = static_cast<IUnknown*>(this);
	else if (riid == IID_IDispatch)
		*ppvObj = static_cast<IDispatch*>(this);
	else
	{
		*ppvObj = 0;
		hr = E_NOINTERFACE;

	}

	if(SUCCEEDED(hr))
	   static_cast<IUnknown*>(*ppvObj)->AddRef();

	return hr;

}

STDMETHODIMP_(ULONG) CMyObject::AddRef()
{
	return InterlockedIncrement(&m_cRefCount);
}

STDMETHODIMP_(ULONG) CMyObject::Release()
{
	ULONG lRefCount = InterlockedDecrement(&m_cRefCount);

	if(lRefCount == 0)
		delete this;

	return lRefCount;
}


STDMETHODIMP CMyObject::GetTypeInfoCount(UINT* iTInfo)
{
	*iTInfo = 1;
	return S_OK;
}


STDMETHODIMP CMyObject::GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo)
{
	HRESULT hr = S_OK;

    if(iTInfo != 0)        
		hr = ResultFromScode(DISP_E_BADINDEX);
	else
	{

		hr = FetchTypeInfo(lcid, CLSID_MYOBJ_TYPEINFO);
		
		if(SUCCEEDED(hr))
		{
			*ppTInfo = m_pTypeInfo;
			m_pTypeInfo->AddRef();
		}
	}

	return hr;
}

STDMETHODIMP CMyObject::GetIDsOfNames(	
						REFIID riid, 
						OLECHAR** rgszNames,
						UINT cNames, LCID lcid, 
						DISPID* rgDispId)
{
   HRESULT hr;

   //Validate arguments
   if (riid != IID_NULL)
      return E_INVALIDARG;

   //this API call gets the DISPID's from the type information
   hr = m_pTypeInfo->GetIDsOfNames(rgszNames, cNames, rgDispId);

   //DispGetIDsOfNames may have failed, so pass back its return value.
   return hr;

}

STDMETHODIMP CMyObject::Invoke(
						DISPID dispIdMember, 
						REFIID riid, 
						LCID lcid,  
						WORD wFlags, 
						DISPPARAMS* pDispParams,  
						VARIANT* pVarResult, 
						EXCEPINFO* pExcepInfo,  
						UINT* puArgErr)
{
   if ((riid != IID_NULL) || !(wFlags & DISPATCH_METHOD))
      return E_INVALIDARG;

   HRESULT hr = S_OK;
   LPDISPATCH pDisp = 0;

   switch(dispIdMember){
   case 0x1:
      HelloBongo();
      break;
   case 0x2:
		if(pDispParams->rgvarg[0].vt != VT_BSTR)
		   hr = DISP_E_BADVARTYPE;
		else
		{
		  hr = CreateObject(pDispParams->rgvarg[0].bstrVal, &pDisp);
		  if(SUCCEEDED(hr) && (pVarResult != 0))
		  {
			pVarResult->vt = VT_DISPATCH;
			pVarResult->pdispVal = pDisp;
		  }
		}
		break;
   default:
      hr = E_FAIL;
      break;
   }

   return hr;

}


void CMyObject::HelloBongo(void)
{
	  MessageBox(NULL, "From script: Hello, BONGO!", "Script Message", MB_OK);
}

HRESULT CMyObject::CreateObject(BSTR bstrProgId, LPDISPATCH *pDisp)
{
	CLSID theCLSID;
	HRESULT hr = S_OK;

	hr = CLSIDFromProgID(bstrProgId, &theCLSID);

	if(SUCCEEDED(hr))
		hr = CoCreateInstance(theCLSID, 0, CLSCTX_INPROC_SERVER, IID_IDispatch, (void **)pDisp);

	return hr;
}

// Utility function

HRESULT CMyObject::FetchTypeInfo(LCID lcid, REFCLSID clsid)
{
	HRESULT hr = S_OK;

	if(m_pTypeInfo == 0)
	{
		LPTYPELIB ptlib = NULL;

		// First try to load the type info from a registered type library
	   hr = LoadRegTypeLib(LIBID_ashHelloWorld, 1, 0, lcid, &ptlib);
	   if (S_OK != hr){
		  //if the libary is not registered, try loading from a file
		  hr = LoadTypeLib(L"ashHelloWorld.tlb", &ptlib);
		  if (S_OK != hr){
			 //can't get the type information
			 return hr;
		  }
	   }

		// Get type information for interface of the object.
		hr = ptlib->GetTypeInfoOfGuid(clsid, &m_pTypeInfo);

		ptlib->Release();
	}

	return hr;
}
