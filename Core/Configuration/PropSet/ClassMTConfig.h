	
// MTConfig.h : Declaration of the CMTConfig

#ifndef __MTCONFIG_H_
#define __MTCONFIG_H_

#include <comdef.h>
#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTConfig
class ATL_NO_VTABLE CMTConfig : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfig, &CLSID_MTConfig>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfig, &IID_IMTConfig, &LIBID_MTConfigPROPSETLib>
{
public:
	CMTConfig();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIG)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfig)
	COM_INTERFACE_ENTRY(IMTConfig)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfig
public:

	STDMETHOD(ReadConfiguration)(BSTR aFilename, 
														/*[out]*/VARIANT_BOOL* apChecksumMatch, 
														/*[out,retval]*/ IMTConfigPropSet * * apSet);

	STDMETHOD(ReadConfigurationFromHost)(BSTR aHostname,
																			 BSTR aRelativePath,
																			 VARIANT_BOOL aSecure,
																			 /*[out]*/VARIANT_BOOL* apChecksumMatch, 
																			 /*[out,retval]*/ IMTConfigPropSet * * apSet);


	STDMETHOD(ReadConfigurationFromURL)(BSTR aURL,
																			/*[out]*/ VARIANT_BOOL* apChecksumMatch, 
																			/*[out,retval]*/ IMTConfigPropSet * * apSet);

	STDMETHOD(ReadConfigurationFromString)(BSTR aConfigBuffer,
																			/*[out]*/ VARIANT_BOOL* apChecksumMatch, 
																			/*[out,retval]*/ IMTConfigPropSet * * apSet);


	STDMETHOD(NewConfiguration)(BSTR aName, /*[out,retval]*/ IMTConfigPropSet * * apSet);

	STDMETHOD(get_ChecksumSwitch)(/*[out, retval]*/ VARIANT_BOOL *apVal);

	STDMETHOD(put_ChecksumSwitch)(/*[in]*/ VARIANT_BOOL aNewVal);

	STDMETHOD(put_AutoEnumConversion)(/*[in]*/ VARIANT_BOOL aConvert);
	STDMETHOD(get_AutoEnumConversion)(/*[out, retval]*/ VARIANT_BOOL * apConvert);

	STDMETHOD(put_Username)(/*[in]*/ BSTR aUsername);
	STDMETHOD(get_Username)(/*[out, retval]*/ BSTR *apUsername);

	STDMETHOD(put_Password)(/*[in]*/ BSTR aPassword);
	STDMETHOD(get_Password)(/*[out, retval]*/ BSTR *apPassword);

	STDMETHOD(put_SecureFlag)(/*[in]*/ VARIANT_BOOL aSecureFlag);
	STDMETHOD(get_SecureFlag)(/*[out, retval]*/ VARIANT_BOOL *apSecureFlag);

	STDMETHOD(put_Port)(/*[in]*/ int aPort);
	STDMETHOD(get_Port)(/*[out, retval]*/ int * apPort);

private:
	HRESULT ReadFromURLInternal(const char * apURL,
															VARIANT_BOOL * apChecksumMatch,
															IMTConfigPropSet * * apSet);

private:
	BOOL mChecksumSwitch;
	BOOL mAutoEnumConversion;

public:
	// authentication info
	static VARIANT_BOOL mSecureFlag;
	static _bstr_t mUsername;
	static _bstr_t mPassword;
	static int mPort;
};

#endif //__MTCONFIG_H_
