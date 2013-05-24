/**************************************************************************
 * @doc PropGenProcessor
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/
	
// PropGenProcessor.h : Declaration of the CPropGenProcessor

#ifndef __PROPGENPROCESSOR_H_
#define __PROPGENPROCESSOR_H_

#include "resource.h"       // main symbols

#include "PropGenerator.h"

/////////////////////////////////////////////////////////////////////////////
// CPropGenProcessor
class ATL_NO_VTABLE CPropGenProcessor : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPropGenProcessor, &CLSID_PropGenProcessor>,
	public ISupportErrorInfo,
  public ::IMTPipelinePlugIn
{
public:
	CPropGenProcessor()
	{
		m_pUnkMarshaler = NULL;
		mpPropGenerator = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PROPGENPROCESSOR)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CPropGenProcessor)
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
		if (mpPropGenerator)
		{
			delete mpPropGenerator;
			mpPropGenerator = NULL;
		}
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IPropGenProcessor
public:

	// --------------------------------------------------------------------------
	// Description: Initialize the processor, looking up any necessary property IDs.
	// The processor can also be used at this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	// --------------------------------------------------------------------------
	STDMETHOD(Configure)(/* [in] */ IUnknown * systemContext,
												/*[in]*/::IMTConfigPropSet * propSet);

	// --------------------------------------------------------------------------
	// Description: Shutdown the processor.  The processor can release any 
	//							resources it no longer needs.
	// --------------------------------------------------------------------------
	STDMETHOD(Shutdown)();

	// --------------------------------------------------------------------------
	// Description:	Return information about this processor.
	// combination of 
	//					MTPROC_FREETHREADED
	//					MTPROC_PASSIVE
	//					MTPROC_STAGECHANGER
	// --------------------------------------------------------------------------
	STDMETHOD(get_ProcessorInfo)(/* [out] */ long * info);

	// --------------------------------------------------------------------------
	// Description: process session object and set new properties into session 
	//							object
	// --------------------------------------------------------------------------
	STDMETHOD(ProcessSessions)(/*[in]*/::IMTSessionSet *apSessionSet);

private:
	long mPropIDSession;

	PropGenerator *mpPropGenerator;

};

#endif //__PROPGENPROCESSOR_H_
