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

// MTDiscountReader.h : Declaration of the CMTDiscountReader

#ifndef __MTDISCOUNTREADER_H_
#define __MTDISCOUNTREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

// TODO: break CMTPCCycleReader out into its own file
class CMTPCCycleReader
{
public:
	static void LoadCycleFromRowset(IMTPCCycle* piCycle, IMTSQLRowset *piRowset);
	
	// loads cycles of EBCR-aware pribable items
	static void LoadCycleFromRowsetEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																		ROWSETLib::IMTSQLRowsetPtr rowset);

private:

  // decodes the persistable representation into a given cycle (EBCR-aware)
	static void DecodeCycle(_variant_t cycleID,      
													_variant_t cycleTypeID,  
													_variant_t cycleMode,
													MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle);

  // converts a tx_cycle_mode style string into an MTCycleMode enum
	static MTCycleMode ConverCycleModeStringToEnum(_bstr_t modeStr);
		
};

/////////////////////////////////////////////////////////////////////////////
// CMTDiscountReader
class ATL_NO_VTABLE CMTDiscountReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTDiscountReader, &CLSID_MTDiscountReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTDiscountReader, &IID_IMTDiscountReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTDiscountReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDISCOUNTREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTDiscountReader)

BEGIN_COM_MAP(CMTDiscountReader)
	COM_INTERFACE_ENTRY(IMTDiscountReader)
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
	
// IMTDiscountReader
public:
	STDMETHOD(PopulateDiscountProperties)(/*[in]*/ IMTSessionContext* apCtxt,
																				/*[in]*/ IMTDiscount* piDiscount);

	STDMETHOD(FindCountersAsRowset)(/*[in]*/ IMTSessionContext* apCtxt,
																	/*[in]*/long aDiscountDBID,
																	/*[out, retval]*/IMTSQLRowset** apRowset);

private:
	void LoadCounters(IMTSessionContext* apCtxt, IMTDiscount *piDiscount);

};

#endif //__MTDISCOUNTREADER_H_
