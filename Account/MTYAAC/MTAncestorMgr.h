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

#ifndef __MTANCESTORMGR_H_
#define __MTANCESTORMGR_H_

#include "resource.h" 			// main symbols
#include <AccHierarchiesShared.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAncestorMgr
class ATL_NO_VTABLE CMTAncestorMgr : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAncestorMgr, &CLSID_MTAncestorMgr>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAncestorMgr, &IID_IMTAncestorMgr, &LIBID_MTYAACLib>
{
public:
	CMTAncestorMgr()
	{
		m_pUnkMarshaler = NULL;
		bstrYes = "1";
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTANCESTORMGR)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAncestorMgr)
	COM_INTERFACE_ENTRY(IMTAncestorMgr)
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


// IMTAncestorMgr
public:
	STDMETHOD(AddToHierarchy)(/*[in]*/ long aAncestor,/*[in]*/ long aDescendent,/*[in]*/ DATE StartDate,/*[in]*/ DATE EndDate);
	STDMETHOD(MoveAccountBatch)(long aAncestor,IMTCollection* pCol,IMTProgress* pProgress,DATE StartDate,IMTRowSet** ppErrors);
	STDMETHOD(MoveAccount)(/*[in]*/ long aAncestor,/*[in]*/ long aDescendent,/*[in]*/ DATE NewDate);
	STDMETHOD(HierarchyRoot)(/*[in]*/ DATE RefDate,IMTAccountHierarchySlice** ppSlice);
	STDMETHOD(HierarchySliceNow)(/*[in]*/ long AncestorID,/*[out,retval]*/ IMTAccountHierarchySlice** ppSlice);
	STDMETHOD(HierarchySlice)(/*[in]*/ long AncestorID,/*[in]*/ DATE RefDate,/*[out, retval]*/ IMTAccountHierarchySlice** ppSlice);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX,IMTYAAC* pActorYAAC);
protected:
	HRESULT MoveAccountAuthChecks(long aAncestor, DATE aMoveDate,GENERICCOLLECTIONLib::IMTCollectionPtr pCol,IMTProgress* pProgress,IMTRowSet** ppErrors);

protected:
	MTYAACLib::IMTSessionContextPtr mCTX;
	MTYAACLib::IMTYAACPtr mActorYAAC;
  _bstr_t bstrYes;
};

#endif //__MTANCESTORMGR_H_
