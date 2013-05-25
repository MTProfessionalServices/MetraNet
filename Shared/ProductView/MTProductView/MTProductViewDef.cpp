// MTProductViewDef.cpp : Implementation of CMTProductViewDef
#include "StdAfx.h"
#include "MTProductView.h"
#include "MTProductViewDef.h"

#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <fstream>

using std::ofstream;

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewDef

// @mfunc CMTProductViewDef default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// CMTProductViewDef class
CMTProductViewDef::CMTProductViewDef()
{	
	mpProdViewDef = 0;
	//mpProductView = 0;
	mIsInitialized = TRUE;

	// initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("Service"), CORE_TAG);
}

// @mfunc CMTProductViewDef default constructor
// @parm 
// @rdesc This implementations is for the destructor of the MTProductViewDef class
CMTProductViewDef::~CMTProductViewDef() 
{
    delete mpProdViewDef;
	mpProdViewDef = 0;
}

STDMETHODIMP CMTProductViewDef::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductViewDef,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTProductViewDef::AddProperty(BSTR dn, BSTR type, BSTR length, BSTR required, BSTR defaultVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::Initialize()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::Save()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::get_name(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::put_name(BSTR newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::get_majorversion(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::put_majorversion(BSTR newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::put_minorversion(BSTR newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::get_minorversion(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::get_tablename(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::put_tablename(BSTR newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::get_exttablename(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTProductViewDef::put_exttablename(BSTR newVal)
{
	return E_NOTIMPL;
}

/*

STDMETHODIMP CMTProductViewDef::AddProperty(BSTR dn, BSTR type, BSTR length, BSTR required, BSTR defaultVal)
{
    mpProdViewDef->AddProperty(dn, type, length, required, defaultVal);
	return S_OK;
}

STDMETHODIMP CMTProductViewDef::Initialize()
{
	// local variables ...
	HRESULT hOK = S_OK;  
	mIsInitialized = TRUE;  

	mpProdViewDef = new CMSIXDefinition;

	return HRESULT_FROM_WIN32(hOK);	
}

STDMETHODIMP CMTProductViewDef::Save()
{	
    // TODO: Add your implementation code here
    _bstr_t bstr("yyy.txt");
    ofstream out(bstr);
	if (out.fail())
	  return E_FAIL;

	out << *mpProdViewDef;

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::get_name(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::put_name(BSTR newVal)
{
    HRESULT hOK = S_OK;

	// check for the initialized flag
	if (mIsInitialized == TRUE)
	{
	    mpProdViewDef->SetName(newVal);
	}
	else
	{
	    hOK = CORE_ERR_NOT_INITIALIZED;
		mLogger.LogVarArgs (LOG_ERROR,
							"MTProductView object is not initialized. Error = <%d>", hOK);
	}

	return HRESULT_FROM_WIN32(hOK); 
}

STDMETHODIMP CMTProductViewDef::get_majorversion(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::put_majorversion(BSTR newVal)
{    
    HRESULT hOK = S_OK;

	// check for the initialized flag
	if (mIsInitialized == TRUE)
	{
	    mpProdViewDef->SetMajorVersion(newVal);
	}
	else
	{
	    hOK = CORE_ERR_NOT_INITIALIZED;
		mLogger.LogVarArgs (LOG_ERROR,
							"MTProductView object is not initialized. Error = <%d>", hOK);
	}

	return HRESULT_FROM_WIN32(hOK); 
}

STDMETHODIMP CMTProductViewDef::get_minorversion(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::put_minorversion(BSTR newVal)
{
    HRESULT hOK = S_OK;

	// check for the initialized flag
	if (mIsInitialized == TRUE)
	{
	    mpProdViewDef->SetMajorVersion(newVal);
	}
	else
	{
	    hOK = CORE_ERR_NOT_INITIALIZED;
		mLogger.LogVarArgs (LOG_ERROR,
							"MTProductView object is not initialized. Error = <%d>", hOK);
	}

	return HRESULT_FROM_WIN32(hOK); 
}

STDMETHODIMP CMTProductViewDef::get_tablename(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::put_tablename(BSTR newVal)
{
    HRESULT hOK = S_OK;

	// check for the initialized flag
	if (mIsInitialized == TRUE)
	{
	    mpProdViewDef->SetMajorVersion(newVal);
	}
	else
	{
	    hOK = CORE_ERR_NOT_INITIALIZED;
		mLogger.LogVarArgs (LOG_ERROR,
							"MTProductView object is not initialized. Error = <%d>", hOK);
	}

	return HRESULT_FROM_WIN32(hOK); 
}

STDMETHODIMP CMTProductViewDef::get_exttablename(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTProductViewDef::put_exttablename(BSTR newVal)
{
    HRESULT hOK = S_OK;

	// check for the initialized flag
	if (mIsInitialized == TRUE)
	{
	    mpProdViewDef->SetMajorVersion(newVal);
	}
	else
	{
	    hOK = CORE_ERR_NOT_INITIALIZED;
		mLogger.LogVarArgs (LOG_ERROR,
							"MTProductView object is not initialized. Error = <%d>", hOK);
	}

	return HRESULT_FROM_WIN32(hOK); 
}
*/
