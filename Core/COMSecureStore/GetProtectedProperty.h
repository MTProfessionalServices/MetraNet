// GetProtectedProperty.h : Declaration of the CGetProtectedProperty

#ifndef __GETPROTECTEDPROPERTY_H_
#define __GETPROTECTEDPROPERTY_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include "mtcryptoapi.h"

/////////////////////////////////////////////////////////////////////////////
// CGetProtectedProperty
class ATL_NO_VTABLE CGetProtectedProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CGetProtectedProperty, &CLSID_GetProtectedProperty>,
	public IDispatchImpl<IGetProtectedProperty, &IID_IGetProtectedProperty, &LIBID_COMSECURESTORELib>
{
public:
	CGetProtectedProperty()
	{
		mbstrEntity=L"";
		mbstrFilename=L"";
		mbstrName=L"";
		mbstrValue=L"";
    aCrypto = NULL;

    m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_GETPROTECTEDPROPERTY)

DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CGetProtectedProperty)
	COM_INTERFACE_ENTRY(IGetProtectedProperty)
	COM_INTERFACE_ENTRY(IDispatch)
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

// IGetProtectedProperty
public:
  //
  // This method initializes the cryptographic service and reads the property
  // from file. sEntity is a system resource using encryption. For example,
  // since the TicketAgent runs within the context of IIS, this value is listener.
  // sFilename is the name of the configuration file. The format of this parameter
  // is a pathname relative to the MetraTech config directory. For example,
  // ServerAccess\protectedpropertylist.xml. sName is the property to retrieve.
  //
	STDMETHOD(Initialize)(BSTR sEntity, BSTR sFilename, BSTR sName);
	STDMETHOD(InitializeWithContainer)(BSTR sContainer, BSTR sEntity, BSTR sFilename, BSTR sName);

  //
  // This method retrieves and decrypts the data from file and returns the
  // plaintext to the caller.
  //
	STDMETHOD(GetValue)(BSTR *pValue);

	STDMETHOD(EncryptString)(BSTR src,BSTR* pVal);
	STDMETHOD(DecryptString)(BSTR src,BSTR* pVal);

private:
  int SafeInitCrypto();

private:
	_bstr_t mbstrEntity;
	_bstr_t mbstrFilename;
	_bstr_t mbstrName;
	_bstr_t mbstrValue;

  CMTCryptoAPI *aCrypto;
};

#endif //__GETPROTECTEDPROPERTY_H_
