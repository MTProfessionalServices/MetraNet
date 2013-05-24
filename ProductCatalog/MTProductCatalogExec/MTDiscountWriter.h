/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

// MTDiscountWriter.h : Declaration of the CMTDiscountWriter

#ifndef __MTDISCOUNTWRITER_H_
#define __MTDISCOUNTWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <comdef.h>

// TODO: break CMTPCCycleWriter out into its own file
class CMTPCCycleWriter
{
public:
	static void SaveCycleToRowset(IMTPCCycle* piCycle, IMTSQLRowset *piRowset);
	static _bstr_t GetUpdateString(IMTPCCycle* piCycle);

	// persists cycles of EBCR-aware pribable items
	static void SaveCycleToRowsetEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																	ROWSETLib::IMTSQLRowsetPtr rowset);
	static _bstr_t GetUpdateStringEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle);

private:
  // encodes the given cycle into a persistable representation (EBCR-aware)
	static void CMTPCCycleWriter::EncodeCycle(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																						_variant_t & cycleId,
																						_variant_t & cycleTypeID,
																						_variant_t & cycleMode);
};

/////////////////////////////////////////////////////////////////////////////
// CMTDiscountWriter
class ATL_NO_VTABLE CMTDiscountWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTDiscountWriter, &CLSID_MTDiscountWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTDiscountWriter, &IID_IMTDiscountWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTDiscountWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDISCOUNTWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTDiscountWriter)

BEGIN_COM_MAP(CMTDiscountWriter)
	COM_INTERFACE_ENTRY(IMTDiscountWriter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTDiscountWriter
public:
	STDMETHOD(RemoveDiscountProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
	STDMETHOD(UpdateDiscountProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTDiscount *apDiscount);
	STDMETHOD(CreateDiscountProperties)(/*[in]*/ IMTSessionContext* apCtxt, IMTDiscount *apDiscount);
	STDMETHOD(RemoveCounterMap)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aDiscountDBID, /*[in]*/long aCounterDBID, /*[in]*/ BSTR aDescriptor);
	STDMETHOD(AddCounterMap)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aDiscountDBID, /*[in]*/long aCounterDBID, /*[in]*/ BSTR aDescriptor);
private:
	void SaveCounterAndMapping(IMTSessionContext* apCtxt, IMTDiscount* apDiscount, long lCPDID);
	HRESULT RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTDiscount* apDiscount, LPCSTR lpQueryName);
	void SaveCounters(IMTSessionContext* apCtxt, IMTDiscount *piDiscount);
	void RemoveCounters(IMTSessionContext* apCtxt, long aDiscountID);
};

#endif //__MTDISCOUNTWRITER_H_
