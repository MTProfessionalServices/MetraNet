	
// MTServicesDef.h : Declaration of the CMTServicesDef

#ifndef __MTSERVICESDEF_H_
#define __MTSERVICESDEF_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <MSIXDefinition.h>

#import <MTConfigLib.tlb>
using namespace MTConfigLib;

// this stores the msix definition
typedef list<CMSIXDefinition> DefinitionList;

/////////////////////////////////////////////////////////////////////////////
// CMTServicesDef
class ATL_NO_VTABLE CMTServicesDef : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTServicesDef, &CLSID_MTServicesDef>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTServicesDef, &IID_IMTServicesDef, &LIBID_MTSERVICESLib>,
	public CMSIXDefinition
{
public:
    // default constructor
	CMTServicesDef()
	{
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(SERVICE_STR), 
					 SERVICES_TAG);
	}

    // destructor
    virtual ~CMTServicesDef()
	{
	    mDefinitionList.clearAndDestroy();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSERVICESDEF)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTServicesDef)
	COM_INTERFACE_ENTRY(IMTServicesDef)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTServicesDef
public:
	STDMETHOD(WriteSet)(::IMTConfigPropSet* apPropSet);
    STDMETHOD(AddProperty)(/*[in]*/ BSTR dn, BSTR type, long length, BSTR required, BSTR defaultVal);
	STDMETHOD(Initialize)();
	STDMETHOD(get_defaultVal)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_defaultVal)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_required)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_required)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_length)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_length)(/*[in]*/ long newVal);
	STDMETHOD(get_type)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_type)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_dn)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_dn)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_majorversion)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_majorversion)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_minorversion)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_minorversion)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_tablename)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_tablename)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)();

private:

	_bstr_t mDefaultValue;
	_bstr_t mIsRequired;
	long mLength;
	_bstr_t mType;
	_bstr_t mDN;
	_bstr_t mName;
	_bstr_t mMajorVersion;
	_bstr_t mMinorVersion;
	_bstr_t mTableName;
    
    NTLogger mLogger;

    DefinitionList mDefinitionList;

protected:
  
};

#endif //__MTSERVICESDEF_H_
