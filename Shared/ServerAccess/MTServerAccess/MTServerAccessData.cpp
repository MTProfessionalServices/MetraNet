// MTServerAccessData.cpp : Implementation of CMTServerAccessData
#include "StdAfx.h"
#include "MTServerAccess.h"
#include "MTServerAccessData.h"

/////////////////////////////////////////////////////////////////////////////
// CMTServerAccessData

STDMETHODIMP CMTServerAccessData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTServerAccessData
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTServerAccessData::get_ServerType(BSTR *pVal)
{
    *pVal = mServerType.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_ServerType(BSTR newVal)
{
	mServerType = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_ServerName(BSTR *pVal)
{
    *pVal = mServerName.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_ServerName(BSTR newVal)
{
	mServerName = newVal;
	return S_OK;
}


STDMETHODIMP CMTServerAccessData::get_Timeout(long *pVal)
{
    *pVal = mTimeout;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_Timeout(long newVal)
{
	mTimeout = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_NumRetries(long *pVal)
{
    *pVal = mNumRetries;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_NumRetries(long newVal)
{
	mNumRetries = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_Priority(long *pVal)
{
    *pVal = mPriority;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_Priority(long newVal)
{
	mPriority = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_Secure(long *pVal)
{
    *pVal = mSecure;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_Secure(long newVal)
{
	mSecure = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_PortNumber(long *pVal)
{
    *pVal = mPortNumber;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_PortNumber(long newVal)
{
	mPortNumber = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_UserName(BSTR *pVal)
{
    *pVal = mUserName.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_UserName(BSTR newVal)
{
	mUserName = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_Password(BSTR *pVal)
{
    *pVal = mPassword.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_Password(BSTR newVal)
{
	mPassword = newVal;
	return S_OK;
}


STDMETHODIMP CMTServerAccessData::get_DTCenabled(long *pVal)
{
    *pVal = mDTCenabled;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_DTCenabled(long newVal)
{
	mDTCenabled = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_DatabaseName(BSTR *pVal)
{
	*pVal = mDatabaseName.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_DatabaseName(BSTR newVal)
{
	mDatabaseName = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_DatabaseType(BSTR *pVal)
{
	if (mDatabaseType.length() == 0 &&
		  mDatabaseDriver.length() > 0)
	{
		if (strfind(mDatabaseDriver, "Oracle") != string::npos)
			mDatabaseType = "{Oracle}";
		else
			mDatabaseType = "{SQL Server}";
	}

  *pVal = mDatabaseType.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_DatabaseType(BSTR newVal)
{
	mDatabaseType = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_DataSource(BSTR *pVal)
{
	*pVal = mDataSource.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_DataSource(BSTR newVal)
{
	mDataSource = newVal;
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::get_DatabaseDriver(BSTR *pVal)
{
	if (mDatabaseDriver.length() == 0 &&
		  mDatabaseType.length() > 0)
	{
		if (_wcsicmp((wchar_t*)mDatabaseType, L"{Oracle}") == 0)
		{	
			mDatabaseDriver = "{Oracle in OraDb10g_home1}";
		}
		else if (_wcsicmp((wchar_t*)mDatabaseType, L"{SQL Server}") == 0)
		{
			mDatabaseDriver = "{SQL Server}";
		}
	}

  *pVal = mDatabaseDriver.copy();
	return S_OK;
}

STDMETHODIMP CMTServerAccessData::put_DatabaseDriver(BSTR newVal)
{
	mDatabaseDriver = newVal;
	return S_OK;
}
