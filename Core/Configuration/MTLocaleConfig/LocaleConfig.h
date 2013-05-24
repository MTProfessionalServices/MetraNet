/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// LocaleConfig.h : Declaration of the CLocaleConfig
#pragma warning(disable:4786)

#ifndef __LOCALECONFIG_H_
#define __LOCALECONFIG_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <ConfigDir.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtcomerr.h>

//STL includes
# include <vector>
# include <map>
# include <set>
# include <string>
# include <algorithm>

using namespace std;

#import <RCD.tlb>


#define LOCALE_FILE_TAG	L"locale_file"
#define LOCALE_SUBDIR	L"Localization"
#define	LOCALE_MASTER_FILE       L"LocaleFileList.xml"
#define CONFIG_TAG_NAME L"mt_config"
#define LANGUAGE_TAG_NAME L"language_code"
#define NAMESPACE_TAG_NAME L"locale_space"
#define NAMESPACE_NAME_TAG_NAME L"name"
#define LOCALE_ENTRY_TAG_NAME L"locale_entry"
#define LOCALE_NAME_TAG_NAME L"Name"
#define LOCALE_VALUE_TAG_NAME L"Value"
#define	PTYPE_TAG_NAME L"ptype"
#define	PTYPE_VALUE_TAG_NAME	L"ID"
#define LOCALE_LOG_TAG	"[ILocaleConfig]"
#define LOCALE_COLLECTION_LOG_TAG	"[IMTLocaleCollection]"
#define LOCALE_ENTRY_LOG_TAG	"[IMTLocaleEntry]"

//#define	PERFORMANCE_DEBUG

#import <MTLocaleConfig.tlb>
#import <MTConfigLib.tlb>
// #import <NameID.tlb>


typedef vector<MTConfigLib::IMTConfigPropSetPtr> LocalFileList;


typedef map<wstring, MTConfigLib::IMTConfigPropSet*> PropSetColl;
typedef set<wstring> FileLookupSet;


/////////////////////////////////////////////////////////////////////////////
// CLocaleConfig
class ATL_NO_VTABLE CLocaleConfig : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CLocaleConfig, &CLSID_LocaleConfig>,
	public ISupportErrorInfo,
	public IDispatchImpl<ILocaleConfig, &IID_ILocaleConfig, &LIBID_MTLOCALECONFIGLib>
{
public:
	CLocaleConfig() : mHost(L""), 
										mbReadOnly(FALSE), 
										mbRCDInit(false),
										mrwExtension("")
	{
		LoggerConfigReader cfgRdr;
		// initialize the logger ...
		mLogger.Init (cfgRdr.ReadConfiguration("Localization"), LOCALE_LOG_TAG);
		mWriteLocalizedCollection.CreateInstance(MTPROGID_LOCALE_COLLECTION);
		mLookupLocalizedCollection.CreateInstance(MTPROGID_LOCALE_COLLECTION);

	}
	~CLocaleConfig()
	{
		//mPropSetColl.clear();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_LOCALECONFIG)

DECLARE_PROTECT_FINAL_CONSTRUCT()
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CLocaleConfig)
	COM_INTERFACE_ENTRY(ILocaleConfig)
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

// ILocaleConfig
public:
	//Returns MTLocalizedCollection
	STDMETHOD(get_LocalizedCollection)(/*[out, retval]*/ IMTLocalizedCollection* *pVal);
	//Sets master file name to initialize collection from
	STDMETHOD(InitializeWithFileName)(/*[in]*/ BSTR filename,/*[in]*/ BSTR host);
	//Creates internal collection for specified language
	STDMETHOD(LoadLanguage)(BSTR lang_code);
	//Sets config directory and host name to load collections from 
	STDMETHOD(Initialize)(/*[in, optional]*/VARIANT root_dir, /*[in, optional]*/VARIANT host_name);
	//Clears internal collection
	STDMETHOD(Clear)();
	//Changes localized string for existing MTLocalizedEntry object
	STDMETHOD(SetLocalizedString)(BSTR fqn, BSTR lang_code, BSTR newval);
	//Returns localized string for specifed FQN and language code
	STDMETHOD(GetLocalizedString)(BSTR fqn, BSTR lang_code, BSTR* str);
	//Creates internal collection for specified language and locale space
	STDMETHOD(Load)(BSTR name_space, BSTR lang_code);
	//writes internal collection to file
	STDMETHOD(Write)();
	//Creates new MTLocalizedEntry object
	STDMETHOD(Localize)(BSTR name_space, BSTR langAbbr, BSTR fqn, BSTR desc, VARIANT aExtension);
	//Number of elements in collection
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(ReadConfiguration)(BSTR file,::IMTConfigPropSet** ptr);
	//INTERNAL USE ONLY
	STDMETHOD(WriteConfiguration)(BSTR file,::IMTConfigPropSet** ptr);

protected:
	//INTERNAL USE ONLY
	HRESULT PopulateFileList(_bstr_t&,LocalFileList&,_bstr_t&,_bstr_t&);
	void InitRCD();
	RCDLib::IMTRcdFileListPtr RunQueryByExtension(_bstr_t& aExtension);
	void BuildLookupSet(FileLookupSet& aSet, RCDLib::IMTRcdFileListPtr& aFileList);


private:
	NTLogger mLogger;
	MTLOCALECONFIGLib::IMTLocalizedCollectionPtr mLookupLocalizedCollection;
	MTLOCALECONFIGLib::IMTLocalizedCollectionPtr mWriteLocalizedCollection;
	PropSetColl mPropSetColl;
	std::string mrwExtension;
	std::string mrwExtensionDir;
	_bstr_t mHost;
	BOOL mbReadOnly;
	
	_bstr_t GetFilePath(BSTR name_space, BSTR lang, BSTR aExtension);
	_bstr_t GetFileName(BSTR name_space, BSTR lang);
	_bstr_t GetSubDirs(BSTR file);
	BOOL FindKey(BSTR key);
	BOOL WriteCollection();
	HRESULT LoadCollectionFromFileVector(LocalFileList& files);
	
	RCDLib::IMTRcdPtr mRCD;
	bool mbRCDInit;
};

#endif //__LOCALECONFIG_H_
