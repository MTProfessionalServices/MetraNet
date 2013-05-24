// PhoneNumberParser.h : Declaration of the CPhoneNumberParser

#ifndef __PHONENUMBERPARSER_H_
#define __PHONENUMBERPARSER_H_

#include "comdef.h"
#include "resource.h"       // main symbols
#include "NTLogger.h"

const	int		LargestCountryCode = 1000;  // 3 digit country codes
const	int		LargestRegionCode = 1000000;  // 4 digit region codes
const	int		LargestExchangeCode = 1000; // 3 digit exchanges 
const	int		MaxCountryDigits = 3;
const	int		MaxRegionDigits = 6;
const	int		MaxExchangeDigits = 3;

const	std::string	cstrControlChars (", ()-");

/////////////////////////////////////////////////////////////////////////////
// CPhoneNumberParser
class ATL_NO_VTABLE CPhoneNumberParser : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPhoneNumberParser, &CLSID_PhoneNumberParser>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPhoneNumberParser, &IID_IPhoneNumberParser, &LIBID_PHONELOOKUPLib>
{
private:
	typedef struct RegionCodeHashTable 
	{
		IMTRegion * Regions[LargestRegionCode];
	};

public:
	CPhoneNumberParser();
	virtual ~CPhoneNumberParser();

DECLARE_REGISTRY_RESOURCEID(IDR_PHONENUMBERPARSER)

BEGIN_COM_MAP(CPhoneNumberParser)
	COM_INTERFACE_ENTRY(IPhoneNumberParser)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IPhoneNumberParser
public:
	STDMETHOD(get_LocalityCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(SetEffectiveDevice)(/*[in]*/ BSTR bstrDeviceName);
	STDMETHOD(get_TollFree)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(get_International)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(Write)();
	STDMETHOD(Read)(/*[in]*/ BSTR bstrHostName, /*[in[*/ BSTR bstrPath, /*[in]*/ BSTR bstrFileName);
	STDMETHOD(GetRegionsByCountryName)(/*[in]*/BSTR bstrCountryName, /*[out,retval]*/LPDISPATCH * pRegions);
	STDMETHOD(get_Countries)(/*[out, retval]*/ LPDISPATCH *pVal);
	STDMETHOD(put_Countries)(/*[in]*/ LPDISPATCH newVal);
	STDMETHOD(get_Bridges)(/*[out, retval]*/ IDispatch * *pVal);
	STDMETHOD(put_Bridges)(/*[in]*/ IDispatch * newVal);
	STDMETHOD(Initialize)(/*[in]*/ BSTR bstrDeviceFile, /*[in]*/ BSTR bstrCountryFile);
	STDMETHOD(get_Proximity)(/*[out, retval]*/ Proximity *pVal);
	STDMETHOD(get_CanonicalFormat)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_LocalityDescription)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_RegionDescription)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_CountryName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_LocalNumber)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_NationalCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_CountryCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_DialedNumber)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DialedNumber)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_OriginatorNationalCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_OriginatorNationalCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_OriginatorLineAccessCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_OriginatorLineAccessCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_OriginatorCountryName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_OriginatorCountryName)(/*[in]*/ BSTR newVal);
private:
	STDMETHODIMP	ParseNumber();
	STDMETHODIMP	BuildCountryHashTable(IMTEnumCountries * pCountries);
	STDMETHODIMP	BuildRegionHashTable(IMTEnumRegions * pRegions, RegionCodeHashTable * pTable);
	STDMETHODIMP	BuildExchangeHashTable(IMTEnumExchanges * pExchanges);
	void			RemoveControlChars(std::string & theString);
	STDMETHODIMP	GetExchangesForRegion(IMTRegion * pRegion, LPDISPATCH * pExchanges);
	STDMETHODIMP	ClearRegionsHashTable(RegionCodeHashTable * pTable);
	STDMETHODIMP	ClearExchangesHashTable();
	HRESULT			PostProcess();
	IMTRegion *		GetCountryRegion (char * szCountryCode, char * szRegionCode);

private:
	// required properties for parsing a number
	_bstr_t mOriginatorCountryName;
	_bstr_t mOriginatorCountryCode;
	_bstr_t mOriginatorLineAccessCode;
	_bstr_t mOriginatorInternationalAccessCode;
	_bstr_t mOriginatorNationalAccessCode;
	_bstr_t mOriginatorNationalCode;


	// the number to parse
	_bstr_t		mDialedNumber;

	// output properties
	_bstr_t		mCountryCode;
	_bstr_t		mNationalCode;
	_bstr_t		mNationalNumber;
	_bstr_t		mLocalNumber;
	_bstr_t		mCountryName;
	_bstr_t		mRegionDescription;
	_bstr_t		mLocalityDescription;
	_bstr_t		mLocalityCode;
	Proximity	mProximity;
	BOOL		mInternational;
	BOOL		mTollFree;

	// internal used members
	_bstr_t					mDeviceName;
	IMTEnumPhoneDevices *	mpDeviceTable;
	IMTEnumCountries	*	mpCountriesTable;

	IMTCountry *			mpCountryCodeHashTable[LargestCountryCode];
	RegionCodeHashTable *	mpRegionCodeHashTable[LargestCountryCode];
	IMTExchange *			mpExchangeCodeHashTable[LargestExchangeCode];
	_bstr_t					mHostName;
	_bstr_t					mPath;	
	NTLogger				mLogger;
	BOOL					mPrimaryCountry;

  BOOL					mLoadFromDatabase;
};

#endif //__PHONENUMBERPARSER_H_
