// MTAccTemplateWriter.h : Declaration of the CMTAccTemplateWriter

#ifndef __MTACCTEMPLATEWRITER_H_
#define __MTACCTEMPLATEWRITER_H_

#include "StdAfx.h"
#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccTemplateWriter
class ATL_NO_VTABLE CMTAccTemplateWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccTemplateWriter, &CLSID_MTAccTemplateWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAccTemplateWriter, &IID_IMTAccTemplateWriter, &LIBID_MTYAACEXECLib>
{
public:
	CMTAccTemplateWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCTEMPLATEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAccTemplateWriter)

BEGIN_COM_MAP(CMTAccTemplateWriter)
	COM_INTERFACE_ENTRY(IMTAccTemplateWriter)
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

// IMTAccTemplateWriter
public:
	STDMETHOD(CopyTemplate)(/*[in]*/ long aNewFolder, /*in*/ long aAccountTypeID, /*[in]*/ VARIANT aParentFolder);
	STDMETHOD(SaveSubscriptions)(/*[in]*/ long aTemplateID,/*[in]*/ IMTAccountTemplateSubscriptions* pSubs);
	STDMETHOD(SaveTemplateProperties)(long aTemplateID,/*[in]*/ IMTCollectionReadOnly* pCol);
	STDMETHOD(DeleteTemplate)(/*[in]*/ long aTemplateID);
};

#endif //__MTACCTEMPLATEWRITER_H_
