	
// MTSystemContext.h : Declaration of the CMTSystemContext

#ifndef __MTSYSTEMCONTEXT_H_
#define __MTSYSTEMCONTEXT_H_

#include "resource.h"       // main symbols

#include "MTLog.h"
//#include "ClassMTNameID.h"
#include "comsingleton.h"
#include <mtcryptoapi.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
//#import <MTEnumConfigLib.tlb>

//extern CLSID CLSID_MTEnumType;

/////////////////////////////////////////////////////////////////////////////
// CMTSystemContext
class ATL_NO_VTABLE CMTSystemContext : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSystemContext, &CLSID_MTSystemContext>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSystemContext, &IID_IMTSystemContext, &LIBID_SYSCONTEXTLib>
{
public:
	CMTSystemContext();

DECLARE_REGISTRY_RESOURCEID(IDR_MTSYSTEMCONTEXT)
DECLARE_GET_CONTROLLING_UNKNOWN()

// NOTE: don't use DECLARE_CLASSFACTORY_SINGLETON in DLLs!
//DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTSystemContext>)

BEGIN_COM_MAP(CMTSystemContext)
	COM_INTERFACE_ENTRY(IMTSystemContext)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMTLog, mpLog)
	COM_INTERFACE_ENTRY_AGGREGATE(__uuidof(MTPipelineLib::IMTNameID), mpNameID)
	COM_INTERFACE_ENTRY_AGGREGATE(__uuidof(MTPipelineLib::IEnumConfig), mpEnum)
END_COM_MAP()


/*
Add an IUnknown pointer to your class object and initialize it to NULL in the constructor. 
Override FinalConstruct to create the aggregate. 
Use the IUnknown pointer you defined as the parameter to the COM_INTERFACE_ENTRY_AGGREGATE macros.
Override FinalRelease to release the IUnknown pointer.
*/

	HRESULT FinalConstruct();
	void FinalRelease();

	// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTLog
public:
	STDMETHOD(GetLog)(/*[out, retval]*/ IMTLog * * log);
	STDMETHOD(GetNameID)(/*[out, retval]*/ IMTNameID * * nameid);
	STDMETHOD(GetEnumConfig)(/*[out, retval]*/ IEnumConfig * * enum_config);
	STDMETHOD(get_EffectiveConfig)(/*[out, retval]*/ IMTConfigFile ** apEffectiveConfig);
	STDMETHOD(put_EffectiveConfig)(/*[out, retval]*/ IMTConfigFile * apEffectiveConfig);
	STDMETHOD(get_ExtensionName)(BSTR* pExtensionName);
	STDMETHOD(put_ExtensionName)(BSTR aExtensionName);
	STDMETHOD(get_StageDirectory)(BSTR* pStageDir);
	STDMETHOD(put_StageDirectory)(BSTR aStageDir);
	STDMETHOD(Decrypt)(BSTR aEncryptedStr,BSTR* pvalue);
  STDMETHOD(Encrypt)(BSTR aStringToEncrypt,BSTR* pvalue);


private:
	// aggregated interface
	//CComPtr<IUnknown> mpLog;
	IUnknown * mpLog;

	// aggregated interface
	//CComPtr<IUnknown> mpNameID;
	IUnknown * mpNameID;

	// aggregated interface

	IMTConfigFile* mpEffectiveFileConfig;
	_bstr_t mExtensionName;
	_bstr_t mStageFolder;
	CMTCryptoAPI mCrypto;


public:
	// aggregated interface
	// NOTE: must be public to support COM_INTERFACE_ENTRY_AUTOAGGREGATE
	IUnknown * mpEnum;
	//CComPtr<IUnknown> mpEnum;
};

#endif //__MTSYSTEMCONTEXT_H_
