// MTXMLRowset.cpp : Implementation of MTXMLRowset
#include "StdAfx.h"
#include "Rowset.h"
#include "MTXMLRowset.h"
#include <DBSQLRowset.h>
#include <mtcomerr.h>



/////////////////////////////////////////////////////////////////////////////
// MTXMLRowset

STDMETHODIMP MTXMLRowset::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTXMLRowset,
    &IID_IMTRowSetExecute,
    &IID_IMTRowSet
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

MTXMLRowset::~MTXMLRowset()
{
}


STDMETHODIMP MTXMLRowset::get_HostName(BSTR* pHostName)
{
	ASSERT(pHostName);
	if(!pHostName) return E_POINTER;
	*pHostName = mHostname.copy();
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_HostName(BSTR HostName)
{
	ASSERT(HostName);
	if(!HostName) return E_POINTER;
	mHostname = HostName;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_UserName(BSTR* pUserName)
{
	ASSERT(pUserName);
	if(!pUserName) return E_POINTER;
	*pUserName = mUserName.copy();
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_UserName(BSTR UserName)
{
	ASSERT(UserName);
	if(!UserName) return E_POINTER;
	mUserName = UserName;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_Password(BSTR* pPassword)
{
	ASSERT(pPassword);
	if(!pPassword) return E_POINTER;
	*pPassword = mPassword.copy();
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_Password(BSTR Password)
{
	ASSERT(Password);
	if(!Password) return E_POINTER;
	mPassword = Password;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_ConnectionType(XMLRowSet_ConnectionEnum* aType)
{	
	ASSERT(aType);
	if(!aType) return E_POINTER;
	*aType = mConnectionType;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_ConnectionType(XMLRowSet_ConnectionEnum aType)
{
	// XXX should we error check here??
	mConnectionType = aType;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_PortNumber(long* pPort)
{
	ASSERT(pPort);
	if(!pPort) return E_POINTER;
	*pPort = mPortNum;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_PortNumber(long aPort)
{
	ASSERT(aPort > 0);
	if(aPort < 0) return E_INVALIDARG;
	mPortNum = aPort;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_Timeout(long* pTimeout)
{
	ASSERT(pTimeout);
	if(!pTimeout) return E_POINTER;
	*pTimeout = mTimeout;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_Timeout(long aTimeout)
{
  //-1 means wait indefinitely
  // > 0 means wait for aTimeout seconds
	ASSERT(aTimeout > 0 || aTimeout == -1);
	if(aTimeout < 1 && aTimeout != -1) return E_INVALIDARG;
	mTimeout = aTimeout;
	return S_OK;
}

STDMETHODIMP MTXMLRowset::get_OverRideConnectionString(BSTR* pOverRide)
{
	ASSERT(pOverRide);
	if(!pOverRide) return E_POINTER;
	*pOverRide = mOverRideString.copy();
	return S_OK;
}

STDMETHODIMP MTXMLRowset::put_OverRideConnectionString(BSTR OverRide)
{
	ASSERT(OverRide);
	if(!OverRide) return E_POINTER;
	mOverRideString = OverRide;
	return S_OK;
}


STDMETHODIMP MTXMLRowset::Execute()
{
	static const char* pmethodName = "MTXMLRowset::Execute";
	// step : make sure we have required arguments
	if(mHostname.length() == 0) {
		return Error("Must specify the hostname");
	}

	try {
		// step 1: create the XMLHTTP object
    // There is a bug in WinHTTPRequest 5.0 that is used by serverXMLHTTP4.0
    // that causes the "Error in DLL" error to occur.  To avoid that, explicitly
    // use WinHTTPRequest 5.1, which comes with Win2k sp3.
		//MSXML2::IServerXMLHTTPRequestPtr aHttpRequest("Msxml2.ServerXMLHTTP.4.0");
    WinHttp::IWinHttpRequestPtr aHttpRequest("WinHTTP.WINHTTPRequest.5.1");

		// step 2: build the string to the open call
		_bstr_t aRequestString;

		// check if we are using an override command
		if(mOverRideString.length() == 0) {
			// check the connection type 
			switch(mConnectionType) {
			case HTTP:
				aRequestString += "http://";
				break;
			case HTTPS:
				aRequestString += "https://";
				break;
			default:
				ASSERT(false);
				return Error("Connection type is an invalid type");
			}
			aRequestString += mHostname;
			if(mPortNum > 0) {
				aRequestString += "/";
				char buff[100];
				aRequestString += itoa(mPortNum,buff,10);
			}

			aRequestString += HTTP_DIR_SEP;
			// add in query
			string query = (const char *) mpQueryAdapter->GetQuery();
			size_t first = query.find_first_not_of(" \n\r\t");
			size_t last = query.find_last_not_of(" \n\r\t");

			if (first == string::npos || last == string::npos)
				return Error("Invalid URL");

			query = query.substr(first, last - first + 1);
			aRequestString += query.c_str();

		}
		else {
			aRequestString = mOverRideString;
		}

		// step 3: open the connection
		mLogger->LogVarArgs(LOG_DEBUG,"Requesting page: %s",(const char*)aRequestString);

    //aHttpRequest->open(L"GET", aRequestString, VARIANT_TRUE, mUserName, mPassword);
    aHttpRequest->Open("GET", aRequestString, VARIANT_TRUE);
    
    //Set the credentials -- Part of WinHTTP 5.0 fix
    // 0 -- Use credentials for server
    // 1 -- Use credentials for proxy
    aHttpRequest->SetCredentials(mUserName, mPassword, 0);

		// step 4: send the connection
		aHttpRequest->Send();

    VARIANT_BOOL vbResponse = aHttpRequest->WaitForResponse(mTimeout);

    if(vbResponse != VARIANT_TRUE) {
      aHttpRequest->Abort();

      //mLogger->LogThis(LOG_ERROR, "ServerXMLHTTPRequest timed out.");
      mLogger->LogThis(LOG_ERROR, "WinHTTPRequest timed out.");
      return E_FAIL;
    }

		// step 5: get the results back and dump them in the ADO record set
		//
		// XXX The following code does not work reliably due to what looks like an eror
		// in XMLHTTP Object when it builds a DOM object.  The most reliable implementation
		// seems to be creating a DOM object from scratch and initializing with the raw XML
		//
		//variant_t aVtDispatch = aHttpRequest->GetresponseXML().GetInterfacePtr();
		//
		//
		MSXML2::IXMLDOMDocumentPtr aDomDoc("MSXML2.DOMDocument.4.0");
		aDomDoc->load(aHttpRequest->GetResponseBody());

		// verify that the XML is intact
		MSXML2::IXMLDOMParseErrorPtr aError = aDomDoc->GetparseError();
		if(aError->GeterrorCode() != 0) {
			_bstr_t aTempErrStr = "Error: ";
			aTempErrStr += aError->Getreason();
			aTempErrStr += " on line ";
			char buffer[20];
			ltoa(aError->Getline(),buffer,10);
			aTempErrStr += buffer;
			mLogger->LogThis(LOG_ERROR,(const char*)aTempErrStr);
			// also log the bad XML in DEBUG mode
			mLogger->LogThis(LOG_DEBUG,(const char*)aHttpRequest->GetResponseText());
			return Error((const char*)aTempErrStr);

		}

		_variant_t aVariantDoc = aDomDoc.GetInterfacePtr();

		_RecordsetPtr aRecordSet;
		aRecordSet.CreateInstance("ADODB.Recordset");

		aRecordSet->Open(
			aVariantDoc,												// the XML value
			vtMissing,											// empty connection information,
			adOpenUnspecified,							// defaults
			adLockUnspecified,							// defaults
			adCmdFile);
		mpRowset->PutRecordSet(aRecordSet);
	}
	catch(_com_error& e) {
		_bstr_t aBuff("Failure in ");
		aBuff += pmethodName;
		aBuff += ": ";
		aBuff += e.Description().length() == 0 ? "no detail available" : e.Description();
		mLogger->LogThis(LOG_ERROR,(const char*)aBuff);
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP MTXMLRowset::HydrateFromString(BSTR xmlStr)
{
  try {
    MSXML2::IXMLDOMDocumentPtr aDomDoc("MSXML2.DOMDocument.4.0");
    aDomDoc->loadXML(xmlStr);
    HydrateFromXMLInternal(aDomDoc);
  }
  catch(_com_error& e) {
		return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP MTXMLRowset::HydrateFromFile(BSTR filename)
{
  try {
    MSXML2::IXMLDOMDocumentPtr aDomDoc("MSXML2.DOMDocument.4.0");
    aDomDoc->load(filename);
    HydrateFromXMLInternal(aDomDoc);
  }
  catch(_com_error& e) {
		return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP MTXMLRowset::HydrateFromXML(IDispatch* pDisp)
{
  try {
    IDispatchPtr pDispPtr = pDisp;
    MSXML2::IXMLDOMDocumentPtr domPtr = pDispPtr; // QI
    HydrateFromXMLInternal(domPtr);
  }
  catch(_com_error& e) {
		return ReturnComError(e);
  }
  return S_OK;
}

void MTXMLRowset::HydrateFromXMLInternal(MSXML2::IXMLDOMDocumentPtr doc)
{
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }

  mpRowset = new DBSQLRowset ;
  _RecordsetPtr rs(__uuidof(Recordset));
  mpRowset->PutRecordSet(rs);

  IDispatchPtr tempDisp = doc;
  _variant_t vtDoc((IDispatch*)tempDisp);
  rs->Open(vtDoc, vtMissing, adOpenUnspecified,adLockUnspecified,-1);
}

