// MTExecutionInfo.h : Declaration of the CMTExecutionInfo

#ifndef __MTEXECUTIONINFO_H_
#define __MTEXECUTIONINFO_H_

#include "resource.h"       // main symbols

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

/////////////////////////////////////////////////////////////////////////////
// CMTExecutionInfo
class ATL_NO_VTABLE CMTExecutionInfo : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTExecutionInfo, &CLSID_MTExecutionInfo>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTExecutionInfo, &IID_IMTExecutionInfo, &LIBID_EXECUTIONINFOLib>
{
public:
	CMTExecutionInfo()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTEXECUTIONINFO)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTExecutionInfo)
	COM_INTERFACE_ENTRY(IMTExecutionInfo)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTExecutionInfo
public:
	STDMETHOD(get_PlugInName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PlugInName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_StageName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_StageName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_SessionSet)(/*[out, retval]*/ IMTSessionSet * * pVal);
	STDMETHOD(put_SessionSet)(/*[in]*/ IMTSessionSet * newVal);
private:
	_bstr_t mPlugInName;
	_bstr_t mStageName;

	MTPipelineLib::IMTSessionSetPtr mSet;
};

#endif //__MTEXECUTIONINFO_H_
