// Meter.cpp : Implementation of CMeter
#include "StdAfx.h"
#include "COMMeter.h"
#include "Meter.h"
#include "mtsdk.h"
#include "mtdefs.h"
#include "Session.h"
#include "SessionSet.h"
#include "Batch.h"
#include "mtlocalmode.h"

/////////////////////////////////////////////////////////////////////////////
// CMeter

#define Debugger() __asm { __asm int 3 }

// Initialize statics
FILE *	CMeter::m_LogFile = NULL;
bstr_t  CMeter::m_LogFilePath = "";
long	CMeter::m_LogLevel = (long)MT_LOG_NONE;

CMeter::CMeter()
{
	// My Stuff
	m_Config = NULL;
	m_Meter = NULL;
	m_ProxyName = NULL;

	m_NumServers = 0;

	m_Retries = -1;
	m_Timeout = -1;
	m_Protocol = (long)MSIX_PROTOCOL;
}

CMeter::~CMeter()
{
	// Free possibly allocated BSTRs
	SysFreeString(m_ProxyName);

	// Close log file if it was opened
	if (m_LogFile)
		fclose(m_LogFile);
}

HRESULT CMeter::FinalConstruct()
{
	// Instantiate Configuration Object
	// NOTE: This will be destroyed and reinstantiated if someone sets a proxy host
	m_Config = new MTMeterFileConfig();

	// Make sure we have it
	if (! m_Config) {
		Error("Unable to create instance of MTMeterFileConfig object");
		return E_FAIL;
	}

	// Populate locals with defaults
	m_Retries = m_Config->GetConnectRetries();
	m_Timeout = m_Config->GetConnectTimeout();

	// Generated Code
	return S_OK ;
}

void CMeter::FinalRelease()
{
  if (m_Config) {
    delete(m_Config);
    m_Config = NULL;
  }

  if (m_Meter) {
    delete(m_Meter);
    m_Meter = NULL;
  }
}


// Generated Code
STDMETHODIMP CMeter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = { &IID_IMeter };
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Description: Initialize the meter object.  Must be called before any sessions are
//              created.  Must be matched with a call to Shutdown.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::Startup()
{
	// Create METER
  if (!m_Meter) 
	{
		m_Meter = new MTMeter(*m_Config);
		if (! m_Meter) 
		{
			Error("Unable to create instance of MTMeter object");
			return E_FAIL;
		}
	}

	// Start METER
	if (!m_Meter->Startup()) {
		return HandleMeterError();
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Free resources used by the meter object.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::Shutdown()
{
	if (!m_Meter)
	{
		// Meter not initialized -- no problem
		return S_OK;
	}

	// Shutdown METER
	if (!m_Meter->Shutdown()) {
		return HandleMeterError();
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Create a new, empty session that can then be metered.
// Arguments: ServiceName - service name for new session
// Return Value: new Session object
// ----------------------------------------------------------------
STDMETHODIMP CMeter::CreateSession(BSTR ServiceName, ISession **pNewSession)
{
	HRESULT retval = S_OK;
	ISession * newCOMSession = NULL;
	CComObject<CSession> * newSession;
	MTMeterSession * newSDKSession;
	bstr_t sn;

	if (!m_Meter)
	{
		Error("SDK has not been initialized");
		return E_FAIL;
	}
	
	// Create new instance
	sn = ServiceName;

	if (sn == (_bstr_t)"")
	{
		Error("Service name may not be blank");
		return E_INVALIDARG;
	}

	retval = CComObject<CSession>::CreateInstance(&newSession);
	if (FAILED(retval)) return retval;

	// Query Interface to increment reference count
	HRESULT hr = newSession->QueryInterface(IID_ISession, (void **)&newCOMSession);

	if (!SUCCEEDED(hr)) {
		Error("Could not get session interface");
		retval = E_NOINTERFACE;
	}

	//
	// CreateSDK Session and assign to new COM Session
	//
	newSDKSession = m_Meter->CreateSession((const char *)sn);

	// Make sure session was Created
	if (!newSDKSession) 
	  {
	    Error("Unable to create SDK Session");
	    return HandleMeterError();
	  }

	// Set IUnknown pointer and assign SDK object to new Interface
	newSession->SetSDKSession(newSDKSession);
	newSession->SetSessionName(ServiceName);
	*pNewSession = newCOMSession;

	return S_OK;
}

STDMETHODIMP CMeter::CreateSessionSet(ISessionSet **pNewSessionSet)
{
 
  HRESULT retval;
  ISessionSet * newCOMSessionSet = NULL;
  CComObject<CSessionSet> * newSessionSet;
  MTMeterSessionSet * sdk_sessionset;

  if (!m_Meter)
	{
		Error("SDK has not been initialized");
		return E_FAIL;
	}
  
  sdk_sessionset = m_Meter->CreateSessionSet();

  if (!sdk_sessionset)
    return E_FAIL;

  retval = CComObject<CSessionSet>::CreateInstance(&newSessionSet);

  if (FAILED(retval)) 
    return retval;

  newSessionSet->SetSDKSessionSet(sdk_sessionset);

  retval =  newSessionSet->QueryInterface(IID_ISessionSet, (void **)&newCOMSessionSet);

  if (!SUCCEEDED(retval)) 
    {
      Error("Could not get SessionSet interface");
      retval = E_NOINTERFACE;
    }

  *pNewSessionSet = newCOMSessionSet;
  
  // Here we will need to create a new ISessionSet object and return a pointer to it.
  return S_OK;
}

STDMETHODIMP CMeter::PlaybackLocal()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMeter::get_LogFilePath(BSTR *pVal)
{
	*pVal = ::SysAllocString(m_LogFilePath);

	return S_OK;
}

STDMETHODIMP CMeter::put_LogFilePath(BSTR newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMeter::get_LogLevel(DebugLogLevel *pVal)
{
	// Function is not in library so I'm disabling this
	*pVal = MTC_LOG_NONE;
	return S_OK;

#if 0
	*pVal = (DebugLogLevel)m_LogLevel;
	return S_OK;
#endif
}

STDMETHODIMP CMeter::put_LogLevel(DebugLogLevel newVal)
{
	return E_NOTIMPL;
}

/*
** Local Mode Function - Not Yet Implemented
*/
STDMETHODIMP CMeter::get_LocalCount(long *pVal)
{
	*pVal = 0;
	return S_OK;
}

/*
** Local Mode Function - Not Yet Implemented
*/
STDMETHODIMP CMeter::get_LocalModePath(BSTR *pVal)
{
	*pVal = NULL;
	return S_OK;
}

/*
** Local Mode Function
*/
STDMETHODIMP CMeter::put_LocalModePath(BSTR newVal)
{
	_bstr_t Temp = newVal;
	char * szTemp = Temp;

	m_Config->SetMeterFile (szTemp);
	return S_OK;
}

/*
** Local Mode Function - Not Yet Implemented
*/
STDMETHODIMP CMeter::get_LocalModeType(LocalMode *pVal)
{
	*pVal = MTC_LOCAL_MODE_NEVER;
	return S_OK;
}

/*
** Local Mode Function - Not Yet Implemented
*/
STDMETHODIMP CMeter::put_LocalModeType(LocalMode newVal)
{
	return E_NOTIMPL;
}

/*
** Local Mode Function - Not Yet Implemented
*/

STDMETHODIMP CMeter::get_CompressionPath(BSTR *pVal)
{
	*pVal = NULL;
	return S_OK;
}

/*
** Local Mode Function - Not Yet Implemented
*/
STDMETHODIMP CMeter::put_CompressionPath(BSTR newVal)
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Description: Return the timeout in seconds used when sending messages to the server.
// Return Value: HTTP timeout in seconds
// ----------------------------------------------------------------
STDMETHODIMP CMeter::get_HTTPTimeout(long *pVal)
{
	*pVal = m_Timeout;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the timeout in seconds used when sending messages to the server.
// Arguments: newVal - new HTTP timeout in seconds
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_HTTPTimeout(long newVal)
{
	m_Timeout = newVal;
	m_Config->SetConnectTimeout(m_Timeout);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the number of retries used when sending messages to the server.
// Return Value: Number of retries
// ----------------------------------------------------------------
STDMETHODIMP CMeter::get_HTTPRetries(long *pVal)
{
	*pVal = m_Retries;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the number of retries used when sending messages to the server.
// Arguments: newVal - new number of retries
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_HTTPRetries(long newVal)
{
	m_Retries = newVal;
	m_Config->SetConnectRetries(m_Retries);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the name of the proxy server used for sending HTTP transactions.
// Return Value: HTTP proxy server host name
// ----------------------------------------------------------------
STDMETHODIMP CMeter::get_HTTPProxyHostname(BSTR *pVal)
{
	*pVal = ::SysAllocString(m_ProxyName);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the name of the proxy server used for sending HTTP transactions.
// Arguments: newVal - new HTTP proxy server host name
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_HTTPProxyHostname(BSTR newVal)
{
	// Free existing string
	SysFreeString(m_ProxyName);

	// Allocate new string
	m_ProxyName = SysAllocString(newVal);

	// Recreate Config
	RecreateConfig();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Gets the protocol used to communicate to the server.
// Return Value: current metering protocol
// ----------------------------------------------------------------
STDMETHODIMP CMeter::get_MeterProtocol(Protocol *pVal)
{
	*pVal = (Protocol)m_Protocol;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the protocol used to communicate to the server.
//              It is not required to set this property.  Currently only MSIX_PROTOCOL is
//              supported.
// Arguments: newVal - new metering protocol.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_MeterProtocol(Protocol newVal)
{
	m_Protocol = (long)newVal;

	// Need to recreate Config object!!!
	RecreateConfig();

	return S_OK;
}


// ----------------------------------------------------------------
// Description: Add a new server to the list of server used for metering sessions.
//              Connections to the servers are made in order of priority.
// Arguments: priority - Priority of the server.  The server with the highest
//                       value as this argument will be used first.
//            hostname - Hostname of the server.
//            port - Port number on the server.  Usually port 80 when not using SSL
//                   and 443 when using SSL.  A value from the PortNumbers enumeration
//                   can be used for this argument.
//            Secure -  If true, use SSL to encrypt all communications.  If false,
//                      don't use encryption when sending data.
//            username - Username used for HTTP authentication on the server.
//            password - Password used for HTTP authentication on the server.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::AddServer(long priority, BSTR serverName, PortNumber Port,
															 BOOL Secure, VARIANT username, VARIANT password)
{
	// Local variables to extract strings from variants
	// NOTE: Only reason variants are used is to allow default arguments from VB 

	// Store VARIANTS

	// Add to local array
	if (m_NumServers < MT_MAX_SERVERS)
  {
		m_Servers[m_NumServers].Priority = priority;
		m_Servers[m_NumServers].serverName = serverName;
		m_Servers[m_NumServers].PortNumber = (long)Port;
		m_Servers[m_NumServers].Secure = Secure;
		m_Servers[m_NumServers].UserName = username;
		m_Servers[m_NumServers].Password = password;
	}
	else
	{
		// Change to another Error message?
		Error("Exceeded maximum number of allowed servers");
		return E_FAIL;
	}

	// Add Server to Meter Object
	if (! m_Config)
	{
		Error("Missing m_Config");
		return E_FAIL;
	}

	// Extract _bstr_t from _variant_t fields
	_bstr_t lUserName = m_Servers[m_NumServers].UserName;
	_bstr_t lPassword = m_Servers[m_NumServers].Password;
	_bstr_t lServer = m_Servers[m_NumServers].serverName;

	// Get char * from bstr_t
	const char * un = lUserName;
	const char * p = lPassword;
	const char * ls = lServer;

	// Make SDK Call

	if (!m_Config->AddServer(m_Servers[m_NumServers].Priority,			
													 ls,
													 m_Servers[m_NumServers].PortNumber,
													 m_Servers[m_NumServers].Secure,
													 un,
													 p))
	{
		return HandleConfigError();
	}
	
	// Increment Server Count
	m_NumServers++;

	return S_OK;
}


// ----------------------------------------------------------------
// Description: Sets the full path and file name for local mode recording of 
//              sessions.
// Arguments: FileName - filename to use for local mode recording.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::MeterFile(BSTR FileName)
{
	_bstr_t Temp = FileName;
	char *szTemp = Temp;

	if (m_Meter->MeterFile(szTemp)) {
	  return S_OK;
	} else {
	  return HandleMeterError();
	}
}

// ----------------------------------------------------------------
// Description: Sets the full path and file name for the meterstore. If specified
//              the session keys are recorded to prevent duplicate processing
//              WARNING: This is deprecated.  Use put_MeterStore instead.
//
// Arguments: FileName - filename to use for meterstore.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_MeterJournal(BSTR newVal)
{
  return put_MeterStore(newVal);
}

// ----------------------------------------------------------------
// Description: Sets the full path and file name for the meterstore. If specified
//              the session keys are recorded to prevent duplicate processing
// Arguments: FileName - filename to use for meterstore.
// ----------------------------------------------------------------
STDMETHODIMP CMeter::put_MeterStore(BSTR newVal)
{
	_bstr_t Temp = newVal;
	char * szTemp = Temp;

	m_Config->SetMeterStore(szTemp);
	return S_OK;
}


// ----------------------------------------------------------------
// Description: Creates a new batch object on the server, and object with properties to the client
// Arguments: Name of batch, Namespace of batch
// ----------------------------------------------------------------
STDMETHODIMP CMeter::CreateBatch(IBatch ** pNewBatch)
{
  HRESULT retval;
  IBatch * newCOMBatch = NULL;
  CComObject<CBatch> * newBatch;
	MTMeterBatch * newSDKBatch;

	if (!m_Meter)
	{
		Error("SDK has not been initialized");
		return E_FAIL;
	}

  retval = CComObject<CBatch>::CreateInstance(&newBatch);
  if (FAILED(retval)) 
    return retval;

  retval =  newBatch->QueryInterface(IID_IBatch, (void **)&newCOMBatch);
  if (!SUCCEEDED(retval)) 
  {
		Error("Could not get Batch interface");
		retval = E_NOINTERFACE;
	}

	newSDKBatch = m_Meter->CreateBatch();

	// Make sure session was Created
	if (!newSDKBatch) 
	{
		Error("Unable to create SDK Batch");
	  return HandleMeterError();
	}

	newBatch->SetSDKBatch(newSDKBatch);
  *pNewBatch = newCOMBatch;
  
  return S_OK;
}

// ----------------------------------------------------------------
// Description: Retrieves the batch information from the server and returns an object with it
// Arguments: Batch UID
// ----------------------------------------------------------------
STDMETHODIMP CMeter::OpenBatchByUID(BSTR UID, IBatch ** pNewBatch)
{
  HRESULT retval;
  IBatch * newCOMBatch = NULL;
  CComObject<CBatch> * newBatch;
	MTMeterBatch * newSDKBatch;

	if (!m_Meter)
	{
		Error("SDK has not been initialized");
		return E_FAIL;
	}

  retval = CComObject<CBatch>::CreateInstance(&newBatch);
  if (FAILED(retval)) 
    return retval;

  retval =  newBatch->QueryInterface(IID_IBatch, (void **)&newCOMBatch);
  if (!SUCCEEDED(retval)) 
    {
      Error("Could not get Batch interface");
      retval = E_NOINTERFACE;
    }

	// Create an SDK batch with namespace, name and expected record count
	_bstr_t tmp_id = UID;
	newSDKBatch = m_Meter->LoadBatchByUID((const char *) tmp_id);

	// Make sure batch was Created
	if (!newSDKBatch) 
	{
	  return HandleMeterError();
	}

	newBatch->SetSDKBatch(newSDKBatch);
  *pNewBatch = newCOMBatch;
  
  return S_OK;
}

// ----------------------------------------------------------------
// Description: Retrieves the batch information from the server and returns an object with it
// Arguments: Name and Namespace of the batch
// ----------------------------------------------------------------
STDMETHODIMP CMeter::OpenBatchByName(BSTR Name, 
																		 BSTR NameSpace, 
																		 BSTR SequenceNumber, 
																		 IBatch ** pNewBatch)
{
  HRESULT retval;
  IBatch * newCOMBatch = NULL;
  CComObject<CBatch> * newBatch;
	MTMeterBatch * newSDKBatch;

	if (!m_Meter)
	{
		Error("SDK has not been initialized");
		return E_FAIL;
	}

  retval = CComObject<CBatch>::CreateInstance(&newBatch);
  if (FAILED(retval)) 
    return retval;

  retval =  newBatch->QueryInterface(IID_IBatch, (void **)&newCOMBatch);

  if (!SUCCEEDED(retval)) 
    {
      Error("Could not get Batch interface");
      retval = E_NOINTERFACE;
    }

	// Create an SDK batch with namespace, name and expected record count
	_bstr_t tmpname = Name;
	_bstr_t tmpnmspace = NameSpace;
	_bstr_t tmpseqnum = SequenceNumber;
	newSDKBatch = m_Meter->LoadBatchByName((const char *) tmpname, 
																				 (const char *) tmpnmspace,
																				 (const char *) tmpseqnum);

	// Make sure batch was Created
	if (!newSDKBatch) 
	{
	  return HandleMeterError();
	}

	newBatch->SetSDKBatch(newSDKBatch);
  *pNewBatch = newCOMBatch;
  
  return S_OK;
}


HRESULT CMeter::RecreateConfig()
{

	char mbProxyString[MAX_HOST_LEN];

	// This function is used to destroy the existing m_Config object and
	// recreate it from the local copies of information.

	// Delete Existing Config
	if (m_Config)
		delete(m_Config);

	// Convert our Wide Proxy Name to MB
	wcstombs(mbProxyString, m_ProxyName, sizeof(mbProxyString));

	// Recreate
	m_Config = new MTMeterFileConfig();

	if (!m_Config) {
		Error("Unable to create instance of MTMeterFileConfig object");
		return E_FAIL;
	}

  m_Config->SetProxyData(mbProxyString);
	m_Config->SetConnectRetries(m_Retries);
	m_Config->SetConnectTimeout(m_Timeout);	
	
	// Re-add servers to config object
	for (int curServer = 0; curServer < m_NumServers; curServer++)
	{
		// Extract _bstr_t from _variant_t fields
		bstr_t lUserName = (_bstr_t)m_Servers[curServer].UserName;
		bstr_t lPassword = (_bstr_t)m_Servers[curServer].Password;
		bstr_t lServer = (_bstr_t)m_Servers[curServer].serverName;

		// Get char * from bstr_t
		const char *un = lUserName;
		const char *p = lPassword;
		const char *s = lServer;

		// Make SDK Call
		if (!m_Config->AddServer(m_Servers[curServer].Priority,			
														 s,
														 m_Servers[curServer].PortNumber,
														 m_Servers[curServer].Secure,
														 un,
														 p))
		{
			return HandleConfigError();
		}
	}

	// TODO: Eventually copy compression and local mode information also!!!!

	return S_OK;
}


//
// Called only on error -- converts and returns an HRESULT
//
HRESULT CMeter::HandleMeterError()
{
	HRESULT result = E_FAIL;

	MTMeterError *err = m_Meter->GetLastErrorObject();

	if (err)
	{
	  // Create buffer to store error message in
	  TCHAR errorBuf[ERROR_BUFFER_LEN];
	  int errorBufSize = sizeof(errorBuf);
	  
	  // Get Error Info from SDK
	  err->GetErrorMessageEx(errorBuf, errorBufSize);
	  if (wcslen(errorBuf) == 0)
	    {
	      errorBufSize = sizeof(errorBuf);
	      err->GetErrorMessage(errorBuf, errorBufSize);
	    }
	  
	  Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
	  result = HRESULT_FROM_WIN32(err->GetErrorCode());
	  delete err;
	}

	return result;
}

//
// Called only on error -- converts and returns an HRESULT
//
HRESULT CMeter::HandleConfigError()
{
	HRESULT result = E_FAIL;

	MTMeterError *err = m_Config->GetLastErrorObject();

	if (err)
	{
	  // Create buffer to store error message in
	  TCHAR errorBuf[ERROR_BUFFER_LEN];
	  int errorBufSize = sizeof(errorBuf);
	  
	  // Get Error Info from SDK
	  err->GetErrorMessageEx(errorBuf, errorBufSize);
	  if (wcslen(errorBuf) == 0)
	    {
	      errorBufSize = sizeof(errorBuf);
	      err->GetErrorMessage(errorBuf, errorBufSize);
	    }
	  
	  Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
	  result = HRESULT_FROM_WIN32(err->GetErrorCode());
	  delete err;
	}

	return result;
}

HRESULT CMeter::GenerateNewUID(BSTR* newVal)
{
	ASSERT(newVal);
	if(!newVal) return E_POINTER;

	char* pNewUID = m_Meter->GenerateNewSessionUID();
	_bstr_t aRetVal(pNewUID);
	*newVal = aRetVal.copy();
	delete[] pNewUID;
	return S_OK;
}


