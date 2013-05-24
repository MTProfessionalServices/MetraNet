/**************************************************************************
* Copyright 1998, 1999 by MetraTech Corporation
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech Corporation MAKES NO
* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech Corporation,
* and USER agrees to preserve the same.
*
***************************************************************************/
	
// Meter.h : Declaration of the CMeter

#ifndef __METER_H_
#define __METER_H_

#include "resource.h"       // main symbols
#include "mtdefs.h"			// #defines etc...
#include <comdef.h>			// for _variant_t datatypes

// Forward Declarations
class MTMeter;
//class MTMeterHTTPConfig;
class MTMeterFileConfig;

// Structure to hold server list
typedef struct _metratech_server_entry {
    int		Priority;
	_bstr_t	serverName;
	int		PortNumber;
	BOOL	Secure;
	_bstr_t	UserName;
	_bstr_t	Password;
} MT_SERVER_ENTRY;

/////////////////////////////////////////////////////////////////////////////
// CMeter
class ATL_NO_VTABLE CMeter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMeter, &CLSID_Meter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMeter, &IID_IMeter, &LIBID_COMMeterLib>
{
public:
	CMeter();
	~CMeter();

DECLARE_REGISTRY_RESOURCEID(IDR_METER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMeter)
	COM_INTERFACE_ENTRY(IMeter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct();
	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMeter
public:
	STDMETHOD(AddServer)(/*[in]*/ long priority, /*[in]*/ BSTR serverName, /*[in]*/ PortNumber Port, BOOL Secure, /*[in, optional, defaultvalue(NULL)]*/ VARIANT username, /*[in, optional, defaultvalue(NULL)]*/ VARIANT password);
	STDMETHOD(get_MeterProtocol)(/*[out, retval]*/ Protocol *pVal);
	STDMETHOD(put_MeterProtocol)(/*[in]*/ Protocol newVal);
	STDMETHOD(get_HTTPProxyHostname)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_HTTPProxyHostname)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_HTTPRetries)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_HTTPRetries)(/*[in]*/ long newVal);
	STDMETHOD(get_HTTPTimeout)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_HTTPTimeout)(/*[in]*/ long newVal);
	STDMETHOD(get_CompressionPath)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CompressionPath)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LocalModeType)(/*[out, retval]*/ LocalMode *pVal);
	STDMETHOD(put_LocalModeType)(/*[in]*/ LocalMode newVal);
	STDMETHOD(get_LocalModePath)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LocalModePath)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LocalCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_LogLevel)(/*[out, retval]*/ DebugLogLevel *pVal);
	STDMETHOD(put_LogLevel)(/*[in]*/ DebugLogLevel newVal);
	STDMETHOD(get_LogFilePath)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LogFilePath)(/*[in]*/ BSTR newVal);
	STDMETHOD(PlaybackLocal)();
	STDMETHOD(CreateSession)(/*[in]*/ BSTR ServiceName, /*[out, retval]*/ ISession ** pNewSession);
	STDMETHOD(Shutdown)();
	STDMETHOD(Startup)();
	STDMETHOD(MeterFile)(/*[in]*/ BSTR FileName);
	STDMETHOD(put_MeterJournal)(/*[in]*/ BSTR newVal);
	STDMETHOD(put_MeterStore)(/*[in]*/ BSTR newVal);
	STDMETHOD(GenerateNewUID)(/*[out,retval] */ BSTR* newVal);
	STDMETHOD(CreateSessionSet) (/*[out]*/ ISessionSet **pNewSessionSet);
	STDMETHOD(CreateBatch)(/*[out, retval]*/ IBatch ** pNewBatch);
	STDMETHOD(OpenBatchByUID)(/*[in]*/ BSTR BatchUID, /*[out, retval]*/ IBatch ** pNewBatch);
	STDMETHOD(OpenBatchByName)(/*[in]*/ BSTR Name, /*[in]*/ BSTR NameSpace, /*[in]*/ BSTR SequenceNumber, /*[out, retval]*/ IBatch ** pNewBatch);

private:
	HRESULT RecreateConfig();				// Used to recreate the Config object after it has been created
	HRESULT HandleMeterError();		// Deals with error on m_Meter object
	HRESULT HandleConfigError();		// Deals with error on m_Config object

										// and the user wants to change configuration information
	MTMeter				*	m_Meter;	// Pointer to Meter object in SDK
	MTMeterFileConfig	*	m_Config;	// Pointer to Configuration Object
	BSTR		m_ProxyName;			// Local storage for ProxyName
	long		m_Protocol;				// Local Protocol
	long		m_Retries;				// HTTP Retries
	long		m_Timeout;				// HTTP Timeout
	
	// Only one log for the whole class since SDK function is static
	static bstr_t	m_LogFilePath;			// Local Logfile Path
	static FILE	*	m_LogFile;				// Logfile handle
	static long		m_LogLevel;				// Logfile level

	// Server List Storage
  int			m_NumServers; 
  MT_SERVER_ENTRY m_Servers[MT_MAX_SERVERS];

	// Critical Section For Logging
	CComAutoCriticalSection m_LoggingLock;

};

#endif //__METER_H_
