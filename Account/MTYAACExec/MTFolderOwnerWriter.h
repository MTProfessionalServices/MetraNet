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

#ifndef __MTFOLDEROWNERWRITER_H_
#define __MTFOLDEROWNERWRITER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTFolderOwnerWriter
class ATL_NO_VTABLE CMTFolderOwnerWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTFolderOwnerWriter, &CLSID_MTFolderOwnerWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTFolderOwnerWriter, &IID_IMTFolderOwnerWriter, &LIBID_MTYAACEXECLib>
{
public:
	CMTFolderOwnerWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTFOLDEROWNERWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTFolderOwnerWriter)

BEGIN_COM_MAP(CMTFolderOwnerWriter)
	COM_INTERFACE_ENTRY(IMTFolderOwnerWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
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

// IMTFolderOwnerWriter
public:
	STDMETHOD(UpdateFolderOwner)(/*[in]*/ long aFolder,/*[in]*/ long aNewOwner);
	STDMETHOD(AddOwnedFoldersBatch)(long aOwner,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[out,retval]*/ IMTRowSet** ppErrors);
	STDMETHOD(AddOwnedFolder)(/*[in]*/ long aFolder,/*[in]*/ long aOwner,long* pCurrentOwner);
};

#endif //__MTFOLDEROWNERWRITER_H_
