	
// ARPropagationConfigState.h : Declaration of the CARPropagationConfigState

#ifndef __ARPROPAGATIONCONFIGSTATE_H_
#define __ARPROPAGATIONCONFIGSTATE_H_

#include "resource.h"       // main symbols
#include "ARDocument.h"
#import <MTLocaleConfig.tlb>


/////////////////////////////////////////////////////////////////////////////
// CARPropagationConfigState
class ATL_NO_VTABLE CARPropagationConfigState : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CARPropagationConfigState, &CLSID_ARPropagationConfigState>,
	public ISupportErrorInfo,
	public IDispatchImpl<IARPropagationConfigState, &IID_IARPropagationConfigState, &LIBID_ARPROPAGATIONEXECLib>
{
public:
  CARPropagationConfigState();

DECLARE_REGISTRY_RESOURCEID(IDR_ARPROPAGATIONCONFIGSTATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CARPropagationConfigState)
	COM_INTERFACE_ENTRY(IARPropagationConfigState)
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

// IARPropagationConfigState
public:
	STDMETHOD(SessionsToXmlDoc)(/*[in]*/ IMTSessionSet * aSessions, /*[out, retval]*/ BSTR* aXmlDoc);
	STDMETHOD(SessionsToExternalARXmlDoc)(/*[in]*/ IMTSessionSet * aSessions,/*[in]*/ BSTR aExternalNamespace, /*[out, retval]*/ BSTR* aXmlDoc);
	STDMETHOD(Configure)(IDispatch * aSystemContext, IMTConfigPropSet * aPropSet);
	STDMETHOD(get_ARConfigState)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_ARConfigState)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_Method)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Method)(/*[in]*/ long newVal);

//data
private:
  class Property
  {
  public:
    long propertyNameID;
    string nodeName;
    MTDataTypeLib::DataType type;
    bool localizeValue;

    Property() : propertyNameID(0), type(MTDataTypeLib::MTC_DT_UNKNOWN), localizeValue(false) {}
  };

  long mMethod;
  variant_t mARConfigState;
  ARDocument mTemplateDoc;
  string mLanguageCode;

  MTPipelineLib::IEnumConfigPtr mEnumConfig;
  MTPipelineLib::IMTNameIDPtr mNameID;
  MTLOCALECONFIGLib::ILocaleConfigPtr mLocalConfig;

  std::vector<Property> mProperties;
};

#endif //__ARPROPAGATIONCONFIGSTATE_H_
