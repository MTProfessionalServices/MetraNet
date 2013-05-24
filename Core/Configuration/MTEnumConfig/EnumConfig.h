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

// EnumConfig.h : Declaration of the CEnumConfig

#ifndef __ENUMCONFIG_H_
#define __ENUMCONFIG_H_

#pragma warning(disable:4786)

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <ConfigDir.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <classobject.h>
#include <ConfigChange.h>


#include <comsingleton.h>
#include <autocritical.h>

//#include <MTEnumConfig_i.c>

//STL includes
# include <map>
# include <set>
# include <iostream>
# include <string>
# include <vector>
# include <algorithm>


#define ENUM_TYPE_SUBDIR	L"\\EnumType\\"
#define ENUMTYPE_MASTER_FILE       L"EnumTypeList.xml"
#define ENUMTYPE_MASTER_FILE_NAME       L"EnumTypeList.xml"

#define ENUM_LOG_TAG	"[IMTEnumConfig]"
#define ENUM_COLLECTION_LOG_TAG "[IEnumeratorCollection]"
#define ENUM_TYPE_LOG_TAG	"[IMTEnumType]"
#define ENUMERATOR_LOG_TAG	"[IMTEnumerator]"
#define ENUM_SPACE_LOG_TAG	"[IMTEnumSpace]"
#define ENUM_SPACE_COLLECTION_LOG_TAG "[IMTEnumSpaceColection]"


#define ENUM_FILE_TAG L"file"
#define CONFIG_TAG_NAME L"mt_enum_config"
#define ATTRIB_TAG_NAME L"name"
#define ATTRIB_TAG_STATUS L"status"
#define DESC_TAG_NAME L"description"
#define ENUM_TYPES_TAG_NAME L"enums"
#define ENUM_TAG_NAME L"enum"
#define ENUM_ENTRIES_TAG_NAME L"entries"
#define ENUM_ENTRY_TAG_NAME L"entry"
#define ENUM_VALUE_TAG_NAME L"value"
#define ENUM_SPACE_TAG_NAME L"enum_space"

#define ENUM_SPACES_TAG_NAME L"enum_spaces"


#define ENUM_TYPE_STATUS_ADDED L"Added"
#define ENUM_TYPE_STATUS_UPDATED L"Updated"
#define ENUM_TYPE_STATUS_DELETED L"Deleted" // for future support

class CEnumSpace;
class CEnumerator;
class CEnumeratorFQN;

using namespace std;

typedef map<string, CEnumerator*> EnumTypeMap;
typedef EnumTypeMap::iterator EnumMapIterator;

typedef map<string, CEnumSpace*> EnumSpaceMap;





#import <MTConfigLib.tlb>
#import <MTEnumConfigLib.tlb>
//only needed in GetEnumeratorByID method
#import <MTNameIDLib.tlb>
#import <RCD.tlb>



//#import <IMTEnumConfig.tlb>


class MTPropAndFile {

public:
	MTPropAndFile(MTConfigLib::IMTConfigPropSetPtr& aSet,_bstr_t& aFile) : mSet(aSet), mFile(aFile) {}

	MTConfigLib::IMTConfigPropSetPtr mSet;
	_bstr_t mFile;

};

typedef vector<MTPropAndFile> EnumFileList;
typedef vector<string> EnumValueList;



/////////////////////////////////////////////////////////////////////////////
// CEnumConfig
class ATL_NO_VTABLE CEnumConfig : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public ISupportErrorInfo,
	public CComCoClass<CEnumConfig, &CLSID_EnumConfig>,
	public IDispatchImpl<IEnumConfig, &IID_IEnumConfig, &LIBID_MTENUMCONFIGLib>,
	public ObjectWithError,
	public ConfigChangeObserver

	
{
public:
	CEnumConfig();
	~CEnumConfig();

DECLARE_REGISTRY_RESOURCEID(IDR_ENUMCONFIG)
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CEnumConfig>)

BEGIN_COM_MAP(CEnumConfig)
	COM_INTERFACE_ENTRY(IEnumConfig)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

HRESULT FinalConstruct();

void FinalRelease()
{
	m_pUnkMarshaler.Release();
}

CComPtr<IUnknown> m_pUnkMarshaler;


// IEnumConfig
public:
	//Returns number of FQNs in internal collection
	STDMETHOD(FQNCount)(/*[out, retval]*/ int* pVal);
	//Reached collection end?
	STDMETHOD(FQNCollectionEnd)(/*[put, retval]*/ int* ret);
	//jumps to and returns next FQN in collection
	STDMETHOD(NextFQN)(/*[out, retval]*/ BSTR* fqn);
	//sets iterator to collection begin
	STDMETHOD(EnumerateFQN)();
	//sets iterator to collection begin
	STDMETHOD(GetEnumeratorByID)(/*[in]*/long aID,/*[out, retval]*/ BSTR* aEnum);
	STDMETHOD(GetEnumeratorValueByID)(/*[in]*/long aID,/*[out, retval]*/ BSTR* aEnum);
	
	//initialize internal enum collections given master file name and host (or "" if local)
	STDMETHOD(InitializeWithFileName)(/*[in]*/BSTR master_file_full_path, VARIANT host);
	//adds an enumeration from given file to internal collection
	STDMETHOD(LoadEnumeration)(/*[in]*/ BSTR from_file_path);
	//initialize internal enum collections given host name and relative path
	STDMETHOD(InitializeFromHost)(BSTR host, BSTR relative_path);
	//Returns enumerator collection for given enumspace and enumtype
	STDMETHOD(GetEnumerators)(/*[in]*/ BSTR enum_space, /*[in]*/ BSTR enum_type, /*[out, retval]*/ IMTEnumeratorCollection**);
	//Returns enumtype for given enumspace
	STDMETHOD(GetEnumType)(/*[in]*/ BSTR enum_space, /*[in]*/ BSTR enum_type, /*[out, retval]*/ IMTEnumType** pEnumType);
	//Does this enum type exist?
	STDMETHOD(ValidEnumType)(/*[in]*/ BSTR, /*[in]*/ BSTR, /*[out, retval]*/ int* ret);
	//Does this enum space exist?
	STDMETHOD(ValidEnumSpace)(/*[in]*/ BSTR name, /*[out, retval]*/ int* ret);
	//writes new enum space to file
	STDMETHOD(WriteNewEnumSpace)(/*[in]*/ IMTEnumSpace*, /*[in]*/BSTR aExtension);
	//updates existing enum space
	STDMETHOD(UpdateEnumSpace)(IMTEnumSpace*);
	//returns FQN string
	STDMETHOD(GetFQN)(BSTR enum_space, BSTR enum_name, BSTR enum_value, BSTR* fqn);
	//writes new enum space to given file
	STDMETHOD(WriteNewEnumSpaceWithFileName)(BSTR file, IMTEnumSpace*);
	//Returns MTEnumSpace object given the name
	STDMETHOD(GetEnumSpace)(BSTR name, /*[out, retval]*/IMTEnumSpace** pEnumSpace);
	//Returns all enum spaces
	STDMETHOD(GetEnumSpaces)(VARIANT extension,IMTEnumSpaceCollection** pEnumSpaceColl);
	//returns enumerator name
	STDMETHOD(GetEnumWithValue)(BSTR enum_space, BSTR enum_name, BSTR value, BSTR* name);
	//initialize internal enum collections from runtime config tree (READ ONLY mode)
	STDMETHOD(Initialize)(/*[in, optional, defaultvalue("")*/VARIANT config_tree_root);
	//Internal use only
	STDMETHOD	(Read)(/*[in]*/BSTR file);
	//returns FQN string
	STDMETHOD(GetID)(BSTR enum_space, BSTR enum_name, BSTR enum_value, long* fqn);
	
	virtual void ConfigurationHasChanged() ;

private:
	HRESULT GetEnumFileList(EnumFileList&);
	HRESULT UpdateMasterFile(_bstr_t);
	HRESULT ReadConfigurationInternal(MTConfigLib::IMTConfigPropSetPtr&,_bstr_t&);
	HRESULT ReadConfiguration(MTConfigLib::IMTConfigPropSet** ptr, BSTR file = NULL);
	HRESULT WriteConfiguration(MTConfigLib::IMTConfigPropSet** ptr, BSTR file = NULL);

	void ClearAndDeleteInternalCollections();
	_bstr_t	GetFileName(BSTR file,_bstr_t& aExtensionDir);
	_bstr_t	GetSubDir(BSTR file);
	_bstr_t	GetSubDirs(BSTR file);
	BOOL	IsFullPath(BSTR file);

	HRESULT ReadWithSet(MTConfigLib::IMTConfigPropSetPtr&,_bstr_t&);
	HRESULT InternalBuildCol();

private: // data


	NTLogger	mLogger;
	
	EnumTypeMap*	mpEnumTypeMap;
	EnumMapIterator mIterator;

	EnumSpaceMap*	mpEnumSpaceMap;
	

	BOOL mbInitWithName;

	_bstr_t mHost;
	_bstr_t mRelativePath;
	std::string mExtensionDir;

	MTENUMCONFIGLib::IMTEnumeratorPtr mEnumerator;
	MTENUMCONFIGLib::IMTEnumTypePtr	mEnumType;
	MTENUMCONFIGLib::IMTEnumSpacePtr mEnumSpace;
	MTENUMCONFIGLib::IMTEnumSpaceCollectionPtr mEnumSpaceCollection;
	MTNAMEIDLib::IMTNameIDPtr mNameIDPtr;
	RCDLib::IMTRcdPtr mRCD;
	MTConfigLib::IMTConfigPtr mConfig;

	// used for config change events
	ConfigChangeObservable mObserver;
	NTThreadLock mLock;


	ClassObject<MTENUMCONFIGLib::IMTEnumeratorPtr> mEnumeratorFactory;
};


//BEGIN INTERNAL USE ONLY

class CEnumSpace
{

public:
	CEnumSpace(string name, string desc)
	{
		mName = name;
		mDescription = desc;
	}
	
	string name() {return mName;}
	string description() {return mDescription;}
	void SetName(string& name){mName = name;}
	void SetDescription(string& desc){mDescription = desc;}
	string GetName(){return mName;}
	string GetDescription(){return mDescription;}

	void AddEnumTypeName(string name)
	{
		mEnumTypeSet.insert(set<string>::value_type( _strlwr( (char*) name.c_str()) ));
	}

	BOOL IsValidEnumType(string name)
	{
		set<string>::iterator it;
		string nm = _strlwr( (char*) name.c_str());
		it = mEnumTypeSet.find(nm);
		return (it != mEnumTypeSet.end());
	}
private:
	set<string> mEnumTypeSet;
	string mName, mDescription;
};

class CEnumeratorFQN
{
public:
	CEnumeratorFQN(){}
	CEnumeratorFQN(const string& fqn){mFQN = fqn;}
	string Enumspace();
	string Name();
	string fqn(){return mFQN;}
private:
	string mFQN;
};

class CEnumerator
{


public:
CEnumerator(CEnumeratorFQN fqn, string enum_name, string& desc, EnumValueList list);
CEnumerator(_bstr_t enum_space, _bstr_t enum_type,  _bstr_t enum_name);
CEnumerator();
EnumValueList* GetValues();
string Enumerator();
string GetFQNString();

void SetValues(EnumValueList& values);


void SetEnumSpace(_bstr_t& enum_space);
void SetEnumType(_bstr_t& enum_type);
void SetEnumName(_bstr_t& enum_name);

_bstr_t GetEnumSpace();
_bstr_t GetEnumType();
_bstr_t GetEnumName();
_bstr_t ValueAt(int idx);
int NumValues();

void AddValue(_bstr_t& val);
void AddValue(string& val);
void RemoveValue(_bstr_t& val);
void Clear();

private:
	CEnumeratorFQN mFQN;/*enum fully qualified name*/
	string mFQNString;
	string mDescription;
	string mEnumSpace;
	string mEnumType;
	string mEnumName;
	EnumValueList mValueList;
};

//END INTERNAL USE ONLY

#endif //__ENUMCONFIG_H_
