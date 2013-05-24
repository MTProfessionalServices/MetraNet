/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: 
* $Header$
* 
***************************************************************************/
	
// Logger.h : Declaration of the CLogger

#ifndef __LOGGER_H_
#define __LOGGER_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>

/////////////////////////////////////////////////////////////////////////////
// CLogger
class ATL_NO_VTABLE CLogger : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CLogger, &CLSID_Logger>,
	public ISupportErrorInfo,
	public IDispatchImpl<ILogger, &IID_ILogger, &LIBID_COMLOGGERLib>
{
public:
	CLogger() ;
  ~CLogger() ;
  
DECLARE_REGISTRY_RESOURCEID(IDR_LOGGER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CLogger)
	COM_INTERFACE_ENTRY(ILogger)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ILogger
public:
// The LogEvent method logs the message to the Windows NT Event log.
	STDMETHOD(LogEvent)(/*[in]*/ BSTR apData);
// The LogThis method logs the message at the appropriate log level to the MetraTech log.
	STDMETHOD(LogThis)(/*[in]*/ MTLogLevel aLogLevel, /*[in]*/ BSTR apData);
// The Init method initializes the Logger with the relative configuration path passed.
	STDMETHOD(Init)(/*[in]*/ BSTR apConfigPath, /*[in]*/ BSTR apAppTag);
private:
  NTLogger  mLogger ;
};

#endif //__LOGGER_H_
