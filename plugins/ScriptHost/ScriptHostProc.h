	/**************************************************************************
 * @doc ScriptedFrame
 *
 * Copyright 1998 by MetraTech Corporation
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
 *
 * Modification History:
 *		Chen He - September 10, 1998 : Initial version
 *
 * $Header$
 ***************************************************************************/
// ScriptHostProc.h : Declaration of the CScriptHostProc

#ifndef __SCRIPTHOSTPROC_H_
#define __SCRIPTHOSTPROC_H_

#include "resource.h"       // main symbols
#include "ScriptHosting.h"
#include <NTThreadLock.h>

/////////////////////////////////////////////////////////////////////////////
// CScriptHostProc
class ATL_NO_VTABLE CScriptHostProc : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CScriptHostProc, &CLSID_ScriptHostProc>,
	public ISupportErrorInfo,
	public IMTPipelinePlugIn
{
public:
	CScriptHostProc()
	{
		m_pUnkMarshaler = NULL;
		mpScriptHosting = NULL;
		mScriptHostProcSessionSet = false;  // default is to process one session a time
	}

DECLARE_REGISTRY_RESOURCEID(IDR_SCRIPTHOSTPROC)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CScriptHostProc)
	COM_INTERFACE_ENTRY(IMTPipelinePlugIn)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();

		// clean up the memory allocation
		if (mpScriptHosting)
		{
			// clean up the memory allocation
			mpScriptHosting->Shutdown();

			delete mpScriptHosting;
			mpScriptHosting = NULL;
		}
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IScriptHostProc
public:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	STDMETHOD(Configure)(/* [in] */ IUnknown * systemContext,
												/*[in]*/::IMTConfigPropSet * propSet);

	STDMETHOD(ConfigureInternal)(IUnknown * systemContext,
															::IMTConfigPropSet * propSet);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	STDMETHOD(Shutdown)();

	// Return information about this processor.
	// combination of
	//    MTPROC_FREETHREADED
	//    MTPROC_PASSIVE
	//    MTPROC_STAGECHANGER
	STDMETHOD(get_ProcessorInfo)(/* [out] */ long * info);

	STDMETHOD(ProcessSessions)(/*[in]*/::IMTSessionSet *apSessionSet);

private:
	long						mPropIDSession;
	CScriptHosting	*mpScriptHosting;
	BOOL						mScriptHostProcSessionSet;

	MTPipelineLib::IMTSystemContextPtr mSysContext;
	MTPipelineLib::IMTConfigPropSetPtr mPropSet;

	NTThreadLock mLock;
};

#endif //__SCRIPTHOSTPROC_H_
