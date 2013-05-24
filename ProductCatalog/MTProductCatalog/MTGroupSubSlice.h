/**************************************************************************
* Copyright 2002 by MetraTech
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

#ifndef __MTGROUPSUBSLICE_H_
#define __MTGROUPSUBSLICE_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"

#import <GenericCollection.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTGroupSubSlice
class ATL_NO_VTABLE CMTGroupSubSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTGroupSubSlice, &CLSID_MTGroupSubSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTGroupSubSlice, &IID_IMTGroupSubSlice, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase

{
public:
	CMTGroupSubSlice() : bCollectionPopulated(false)
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGROUPSUBSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DEFINE_MT_PCBASE_METHODS


BEGIN_COM_MAP(CMTGroupSubSlice)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IMTGroupSubSlice)
	COM_INTERFACE_ENTRY(IDispatch)
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
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTGroupSubSlice
public:
	STDMETHOD(InitializeAllMembers)(/*[in]*/ long GroupSubID);
	STDMETHOD(get_GroupMembersAsRowset)(/*[out, retval]*/ ::IMTSQLRowset* *pVal);
	STDMETHOD(Initialize)(/*[in]*/DATE RefDate,long GroupSubID,/*[in,optional]*/ VARIANT SystemDate);
	STDMETHOD(get_GroupMembers)(/*[out, retval]*/ IMTCollection* *pVal);

protected: // methods
	bool PopulateCollection();


protected: // data
	MTPRODUCTCATALOGLib::IMTSQLRowsetPtr mRowset;
	bool bCollectionPopulated;
	GENERICCOLLECTIONLib::IMTCollectionPtr mCollection;
};

#endif //__MTGROUPSUBSLICE_H_
