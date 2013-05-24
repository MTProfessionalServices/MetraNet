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


#ifndef __MTRULESETWRITER_H_
#define __MTRULESETWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <MTProductCatalog.tlb> rename("EOF", "RowsetEOF") no_function_mapping
#import <MTEnumConfigLib.tlb>

#include <vector>

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetWriter
class ATL_NO_VTABLE CMTRuleSetWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRuleSetWriter, &CLSID_MTRuleSetWriter>,
	public IObjectControl,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRuleSetWriter, &IID_IMTRuleSetWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRuleSetWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRULESETWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRuleSetWriter)

BEGIN_COM_MAP(CMTRuleSetWriter)
	COM_INTERFACE_ENTRY(IMTRuleSetWriter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

public:
// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTRuleSetWriter
public:
	STDMETHOD(UpdateWithID)(/*[in]*/ IMTSessionContext* apCtxt, long aRSID, IMTParamTableDefinition * apParamTable, IMTRuleSet * apRules);
	STDMETHOD(CreateWithID)(/*[in]*/ IMTSessionContext* apCtxt, long aRSID, IMTParamTableDefinition * apParamTable, IMTRuleSet * apRules);

private:
	void CleanUpRuleset(MTPRODUCTCATALOGLib::IMTRuleSetPtr aRules);

	void FormatConditions(std::wstring & arValues,
												MTPRODUCTCATALOGLib::IMTConditionSetPtr aConditions,
												const std::vector<std::wstring> & arConditionNameOrder,
												const std::vector<bool> & arRowLevelOp,
												MTENUMCONFIGLib::IEnumConfigPtr,
												BOOL aIsOracle);

	void FormatActions(std::wstring & arValues,
										 MTPRODUCTCATALOGLib::IMTActionSetPtr aAction,
										 const std::vector<std::wstring> & arActionNameOrder,
										 MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
										 BOOL aIsOracle);
};

#endif //__MTRULESETWRITER_H_
