/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/
#ifndef __MTPROGRESSWRITER_H_
#define __MTPROGRESSWRITER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

#import <inetsrv\\asp.dll>

#include <autologger.h>

namespace {
	char pLogMsg[] = "MTProgress";
};


/////////////////////////////////////////////////////////////////////////////
// CMTProgressReader
class ATL_NO_VTABLE CMTProgressReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProgressReader, &CLSID_MTProgressReader>,
	public IObjectControl,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProgress, &IID_IMTProgress, &LIBID_MTPROGRESSEXECLib>
{
public:
	CMTProgressReader() : mResponse(NULL), mFailureCount(0)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROGRESSREADER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProgressReader)

BEGIN_COM_MAP(CMTProgressReader)
	COM_INTERFACE_ENTRY(IMTProgress)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTProgressReader
public:
  STDMETHOD(Reset)();
	STDMETHOD(SetProgress)(long aCurrentPos,long aMaxPos);
	STDMETHOD(put_ProgressString)(BSTR newVal);
	STDMETHOD(get_ProgressString)(BSTR *pVal);

protected:
	bool LoadResponseObject();

protected:
	ASPTypeLibrary::IResponsePtr mResponse;
	_bstr_t mProgressString;
	MTAutoInstance<MTAutoLoggerImpl<pLogMsg> >	mLogger;
	long mFailureCount;
};

#endif //__MTPROGRESSWRITER_H_
