	
// MTConfigPropSet.h : Declaration of the CMTConfigPropSet

#ifndef __MTCONFIGPROPSET_H_
#define __MTCONFIGPROPSET_H_

#include "resource.h"       // main symbols

#include <xmlconfig.h>

#include <string.h>

/////////////////////////////////////////////////////////////////////////////
// CMTConfigPropSet
class ATL_NO_VTABLE CMTConfigPropSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigPropSet, &CLSID_MTConfigPropSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigPropSet, &IID_IMTConfigPropSet, &LIBID_MTConfigPROPSETLib>
{
public:
	CMTConfigPropSet();
	~CMTConfigPropSet();


DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGPROPSET)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfigPropSet)
	COM_INTERFACE_ENTRY(IMTConfigPropSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigPropSet
public:

	//resets the propset iteration (so a call to next will return the first prop)
	STDMETHOD(Reset)();

	//returns the previous property
	STDMETHOD(Previous)(/*[out,retval]*/ IMTConfigProp * * apProp);
	
	//returns the next property
	STDMETHOD(Next)(/*[out,retval]*/ IMTConfigProp * * apProp);

public:

	//gets the DTD ???
	STDMETHOD(get_DTD)(/*[out, retval]*/ BSTR *pVal);
	
	//sets the DTD ???
	STDMETHOD(put_DTD)(/*[in]*/ BSTR newVal);
	
	//inserts a property into the propset
	STDMETHOD(InsertConfigProp)(/*[in]*/ IMTConfigProp* pProp);

	//gets the next date property with the given name
	STDMETHOD(NextDateWithName)(BSTR aName, /*[out,retval]*/ DATE* pDate);

	//gets the next date property with the given name
	STDMETHOD(NextWithName)(BSTR aName, /*[out,retval]*/ IMTConfigProp * * apProp);

	//gets the next long property with the given name
	STDMETHOD(NextLongWithName)(BSTR aName, /*[out,retval]*/ long * apVal);

	//gets the next string property with the given name
	STDMETHOD(NextStringWithName)(BSTR aName, /*[out,retval]*/ BSTR * apVal);

	//gets the next boolean property with the given name
	STDMETHOD(NextBoolWithName)(BSTR aName, /*[out,retval]*/ VARIANT_BOOL * apVal);

	//gets the next variant property with the given name
	STDMETHOD(NextVariantWithName)(/*[in]*/BSTR aName, /*[out]*/PropValType * apType, /*[out,retval]*/ VARIANT * apVal);

	//gets the next dobule property with the given name
	STDMETHOD(NextDoubleWithName)(BSTR aName, /*[out,retval]*/ double * apVal);

	//gets the next decimal property with the given name
	STDMETHOD(NextDecimalWithName)(BSTR aName, /*[out,retval]*/ VARIANT * apVal);

	//gets the next long property with the given name
	STDMETHOD(NextLongLongWithName)(BSTR aName, /*[out,retval]*/ __int64 * apVal);
		
	//gets the next property set with the given name
	STDMETHOD(NextSetWithName)(BSTR aName, /*[out,retval]*/ IMTConfigPropSet * * apSet);

	//???
	STDMETHOD(InsertSet)(BSTR aName, /*[out,retval]*/ IMTConfigPropSet * * apNewSet);

	//creates and inserts a property into the propset
	STDMETHOD(InsertProp)(BSTR aName, PropValType aType, VARIANT aVal);
	
	//adds an existing propset to a new propset
	STDMETHOD(AddSubSet)(/* [in] */ IMTConfigPropSet* apNewSet);

	//???
	STDMETHOD(Write)(BSTR aFilename);

	//???
	STDMETHOD(WriteWithChecksum)(BSTR aFilename);

	//???
	STDMETHOD(WriteToHost)(BSTR aHostName, BSTR aRelativePath,
									       BSTR aUsername, BSTR aPassword,
									       VARIANT_BOOL aSecure, VARIANT_BOOL aChecksum);

	//checks ahead to see if a property in the propset matches the name and type
	STDMETHOD(NextMatches)(/*[in]*/ BSTR aPropName, /*[in]*/ PropValType aType,
												 /*[out, retval]*/ VARIANT_BOOL * apMatch);

	//???													
	STDMETHOD(WriteToBuffer)(/*[out,retval]*/BSTR * apVal);
	
	//gets the name of the propset ???
	STDMETHOD(get_Name)(BSTR* bName);

	//???
	STDMETHOD(get_AttribSet)(/* [out, retval] */ IMTConfigAttribSet** ppSet);
	
	//???
	STDMETHOD(put_AttribSet)(/* [in] */ IMTConfigAttribSet* pSet);
	
	//???
	STDMETHOD(get_Checksum)(/*[out, retval]*/ BSTR* pChecksum);

	//???
	STDMETHOD(ChecksumRefresh)();
	
	//???
	void SetPropSet(XMLConfigPropSet * apSet, BOOL aSetOwner);

	//???
	void SetChecksum(std::string aChecksum)
	{
		mChecksum = aChecksum;
		mChecksumSwitch = TRUE;
	}

private:

	//???
	static HRESULT SetPropObj(XMLObject * apObject, IMTConfigProp * * apProp);

	// set to iterate through
	XMLConfigPropSet * mpPropSet;

	// set to TRUE if we're the owner of the set.
	// if TRUE, the set is deleted at when this object is deleted
	BOOL mSetOwner;
	// iterator
	XMLConfigPropSet::XMLConfigObjectIterator mBeginIterator;
	XMLConfigPropSet::XMLConfigObjectIterator mIterator;
	XMLConfigPropSet::XMLConfigObjectIterator mEndIterator;

	BOOL			mChecksumSwitch;

	string mChecksum;
};

#endif //__MTCONFIGPROPSET_H_
