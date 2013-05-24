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

#ifndef __MTACCOUNTHIERARCHYSLICE_H_
#define __MTACCOUNTHIERARCHYSLICE_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTAccountHierarchySlice
class ATL_NO_VTABLE CMTAccountHierarchySlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountHierarchySlice, &CLSID_MTAccountHierarchySlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountHierarchySlice, &IID_IMTAccountHierarchySlice, &LIBID_MTYAACLib>
{
public:
	CMTAccountHierarchySlice() : 
			mLoaded(false),
		  mAncestor(-1),
			mDescendent(-1),
      subAccount("SUB")
	{
   bstrNo = "0";
   bstrYes = "1";
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTHIERARCHYSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountHierarchySlice)
	COM_INTERFACE_ENTRY(IMTAccountHierarchySlice)
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

// IMTAccountHierarchySlice
public:
	STDMETHOD(GetChildListAsRowset)(/*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(get_CurrentNodeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Parent)(/*[out, retval]*/ long *pVal);
	STDMETHOD(GetAncestorList)(/*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetChildListXML)(/*[out, retval]*/ IXMLDOMNode** ppNode);
	STDMETHOD(Initialize)(IMTSessionContext* apCTX,/*[in]*/ long aDescendent,
  /*[in]*/ DATE RefDate,IMTYAAC* pActorYAAC);

protected:
	void LoadParent();
	void CheckAndLoadData();
	void LoadData();
protected:
	long mDescendent;
	long mAncestor;
	DATE mRefDate;
	DATE mSystemDate;
	MSXML2::IXMLDOMNodePtr mDomNode;
	ROWSETLib::IMTSQLRowsetPtr mRowset;
  ROWSETLib::IMTSQLRowsetPtr mSERowset;
  //ROWSETLib::IMTSQLRowsetPtr mSEUnconnectedRowset;
	bool mLoaded;
	MTYAACLib::IMTSessionContextPtr mCTX;
  MTYAACLib::IMTYAACPtr mActorYAAC;
private:
  _bstr_t bstrNo;
  _bstr_t bstrYes;
  _bstr_t subAccount;
};

#endif //__MTACCOUNTHIERARCHYSLICE_H_
