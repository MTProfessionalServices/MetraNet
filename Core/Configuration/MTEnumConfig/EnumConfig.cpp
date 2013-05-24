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


// EnumConfig.cpp : Implementation of CEnumConfig
#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "EnumConfig.h"
#include <mtprogids.h>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <vector>
#include <stdutils.h>
#include <mtglobal_msg.h>


/////////////////////////////////////////////////////////////////////////////
// CEnumConfig
using namespace MTConfigLib;

STDMETHODIMP CEnumConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IEnumConfig,
	};

	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// BEGIN CEnumerator member functions, INTERNAL USE ONLY
// ----------------------------------------------------------------

CEnumerator::CEnumerator(CEnumeratorFQN fqn, string enum_name, string& desc, EnumValueList list)
{
	mFQN = fqn;
	mFQNString = fqn.fqn();
	mEnumName = enum_name;
	mDescription = desc;
	mValueList = list;
}

CEnumerator::CEnumerator(_bstr_t enum_space, _bstr_t enum_type,  _bstr_t enum_name)
{
	mEnumSpace = enum_space;
	mEnumType = enum_type;
	mEnumName = enum_name;
	mValueList = EnumValueList();
	mFQN = CEnumeratorFQN(mEnumSpace+"/"+mEnumType+"/"+mEnumName);
}

CEnumerator::CEnumerator()
{
	CEnumerator(L"", L"", L"");
	mValueList = EnumValueList();
}

EnumValueList* CEnumerator::GetValues() {return &mValueList;}

string CEnumerator::Enumerator(){return mEnumName;}
string CEnumerator::GetFQNString(){return mFQNString;}

void CEnumerator::SetValues(EnumValueList& values){mValueList = values;}

void CEnumerator::SetEnumSpace(_bstr_t& enum_space){mEnumSpace = enum_space;}

void CEnumerator::SetEnumType(_bstr_t& enum_type){mEnumType = enum_type;}

void CEnumerator::SetEnumName(_bstr_t& enum_name)
{
	mEnumName = enum_name;
	//set FQN
	string fqn = mEnumSpace + "/" + mEnumType + "/" + mEnumName;
	mFQN = CEnumeratorFQN(fqn);
	mFQNString = fqn;

}

_bstr_t CEnumerator::GetEnumSpace()
{
	_bstr_t val = mEnumSpace.c_str();
	return val;
}

_bstr_t CEnumerator::GetEnumType()
{
	_bstr_t val = mEnumType.c_str();
	return val;
}

_bstr_t CEnumerator::GetEnumName()
{
	_bstr_t val = mEnumName.c_str();
	return val;
}

_bstr_t CEnumerator::ValueAt(int idx)
{
	return _bstr_t(mValueList.at(idx).c_str());
}

int CEnumerator::NumValues()
{
	return mValueList.size();
}



void CEnumerator::AddValue(_bstr_t& val)
{
	string sVal = (char*) val;
	AddValue(sVal);
}

void CEnumerator::AddValue(string& val)
{
	if (val.empty()) return;
	
	vector<string>::iterator it;
	
	//check if value's already there
	
	for (it = mValueList.begin(); it != mValueList.end(); it++)
	{
		string sFetchedValue = (char*)(*it).c_str();
		if (_stricmp(sFetchedValue.c_str(), val.c_str()) == 0)
		{
			//trying to insert duplicate
			return;
		}
	}
	
	mValueList.push_back(val);
}

void CEnumerator::RemoveValue(_bstr_t& val)
{
	vector<string>::iterator it;
	string sVal = _strlwr((char*)val);

	if (sVal.empty()) return;
	
	for (it = mValueList.begin(); it != mValueList.end(); it++)
	{
		if (_stricmp((*it).c_str(), sVal.c_str()) == 0)
		{
			mValueList.erase(it);
			return;
		}
	}
}

void CEnumerator::Clear()
{
	mValueList.clear();
}
// ----------------------------------------------------------------
// END CEnumerator member functions, INTERNAL USE ONLY
// ----------------------------------------------------------------

HRESULT CEnumConfig::FinalConstruct()
{
	HRESULT hr(S_OK);
	char* buffer;
	
	hr = mNameIDPtr.CreateInstance("MetraPipeline.MTNameID.1");
	
	if (FAILED(hr))
	{
		buffer = "Unable to create name ID object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}
	
	hr = mEnumerator.CreateInstance(MTPROGID_ENUMERATOR);
	if (FAILED(hr))
	{
		buffer = "Unable to create MTEnumerator object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}
	
	hr = mEnumType.CreateInstance(MTPROGID_ENUM_TYPE);

	if (FAILED(hr))
	{
		buffer = "Unable to create MTEnumType object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}

	hr = mEnumSpace.CreateInstance(MTPROGID_ENUMSPACE);

	if (FAILED(hr))
	{
		buffer = "Unable to create MTEnumSpace object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}
	
	hr = mEnumSpaceCollection.CreateInstance(MTPROGID_ENUMSPACE_COLLECTION);

	
	if (FAILED(hr))
	{
		buffer = "Unable to create MTEnumSpaceCollection object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}

	hr = mRCD.CreateInstance(MTPROGID_RCD);
	if(FAILED(hr)) {
		buffer = "Unable to create RCD object";
			mLogger.LogThis (LOG_ERROR, buffer);
		return Error(buffer, IID_IEnumConfig, hr);
	}

	hr = mConfig.CreateInstance(MTPROGID_CONFIG);

	if (!mObserver.StartThread())
	{
		return Error("Could not start config change thread");
	}
	try
	{
		hr = mEnumeratorFactory.Init(L"Metratech.MTEnumerator.1");
		if (FAILED(hr))
			return hr;

		hr = InternalBuildCol();
		if (FAILED(hr))
			return hr;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	
	return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
}

// ----------------------------------------------------------------
// build internal list of enum information
// ----------------------------------------------------------------

HRESULT CEnumConfig::InternalBuildCol()
{
	AutoCriticalSection alock(&mLock);

	//Initialize enum type list
	int num_files;
	HRESULT hr;

	//First CLear and recreate internal collections
	ClearAndDeleteInternalCollections();
	if(!mpEnumTypeMap)
		mpEnumTypeMap = new EnumTypeMap();
	if(!mpEnumSpaceMap)
		mpEnumSpaceMap = new EnumSpaceMap();


	std::string aExtensionsDir;
	GetExtensionsDir(aExtensionsDir);
	mExtensionDir = aExtensionsDir;
	
	mLogger.LogVarArgs(LOG_DEBUG, "Initializing EnumTypes");
	EnumFileList fileList;
	
	hr = GetEnumFileList(fileList);
	
	if (!SUCCEEDED(hr))
	{
		mLogger.LogVarArgs(LOG_ERROR, "Failed getting enum files list from RCD");
		return hr;
	}
	num_files = fileList.size();
	mLogger.LogVarArgs(LOG_DEBUG, "Got %i files from RCD", num_files);
	EnumFileList::iterator it;

	//read all files
	for(it=fileList.begin(); it != fileList.end();)
	{
		MTPropAndFile aProp = *it++;
		aProp.mSet->Reset();
		
		//mLogger.LogVarArgs(LOG_DEBUG, "Processing %s ...",(const char*)fname);
		
		hr = ReadWithSet(aProp.mSet,aProp.mFile);
		if (!SUCCEEDED(hr))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Failed reading enum file <%s>", (const char*)aProp.mFile);
			return hr;
		}
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     	CEnumConfig
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   CEnumConfig Co class constructor, INTERNAL USE ONLY
// ----------------------------------------------------------------

CEnumConfig::CEnumConfig()
: mHost(L""), mRelativePath(L""), mbInitWithName(FALSE)
	
{
  LoggerConfigReader cfgRdr;
  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("EnumTypes"), ENUM_LOG_TAG);
	//initialize collections
	mpEnumTypeMap = new EnumTypeMap();
	mpEnumSpaceMap = new EnumSpaceMap();

	mObserver.Init();
	mObserver.AddObserver(*this);

	
}

// ----------------------------------------------------------------
// Name:     	~CEnumConfig
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   CEnumConfig Co class destructor, INTERNAL USE ONLY
// ----------------------------------------------------------------

CEnumConfig::~CEnumConfig()
{
	mObserver.StopThread(INFINITE);
	ClearAndDeleteInternalCollections();
}


// ----------------------------------------------------------------
// Name:     	ConfigurationHasChanged
// Arguments:     
// Return Value:  void
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

//Got refresh event, reinitialize
void CEnumConfig::ConfigurationHasChanged()
{
	mLogger.LogThis(LOG_DEBUG, "Refresh event received, reinitializing...");
	// we don't check the error code because we can't do anything
	InternalBuildCol();
}


// ----------------------------------------------------------------
// Name:     	ClearAndDeleteInternalCollections
// Arguments:     
// Return Value:  void
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

void CEnumConfig::ClearAndDeleteInternalCollections()
{
	AutoCriticalSection alock(&mLock);

	EnumMapIterator map_it;
	vector<CEnumerator*> pVector;
	CEnumerator* pEnum;
	CEnumSpace* pEnumSpace;
	BOOL found = FALSE;

	//Release COM ptr and recreate it
	mEnumSpaceCollection = NULL;
	HRESULT hr = mEnumSpaceCollection.CreateInstance(MTPROGID_ENUMSPACE_COLLECTION);
	ASSERT(SUCCEEDED(hr));

	// delete Enum types map contents
	if (mpEnumTypeMap)
	{
		for (map_it=mpEnumTypeMap->begin();;map_it++)
		{
			if  (map_it == mpEnumTypeMap->end()) break;
			pEnum = (*map_it).second;

			/* Multiple map keys may hold pointer to the same enumerator
			*	object as their value; Push deleted pointers on vector and look them up
			*	so that we don't call delete operator multiple times on same object
			*/
			for (unsigned int i = 0; i < pVector.size(); ++i)
			{
				if (pEnum == pVector.at(i))
				{
					found = TRUE;
					break;
				}
			}
			if (!found)
			{
				pVector.push_back(pEnum);
				delete pEnum;
				pEnum = NULL;
			}
			found = FALSE;
		}
		delete mpEnumTypeMap;
		mpEnumTypeMap = NULL;
	}
	// delete Enum spaces map contents
	if (mpEnumSpaceMap)
	{
		EnumSpaceMap::iterator it;
		for (it=mpEnumSpaceMap->begin(); it != mpEnumSpaceMap->end(); )
		{
			pEnumSpace = (*it++).second;
			delete pEnumSpace;
			pEnumSpace = NULL;
		}

		delete mpEnumSpaceMap;
		mpEnumSpaceMap = NULL;
	}

}

// ----------------------------------------------------------------
// Name:     				Initialize
// Arguments:				VARIANT config_root - directory under which EnumType/EnumFileList.xml
//																			master file will be found
// Return Value:		S_OK for success or appropriate error code
// Errors Raised: 
// Description:			If config_root is empty, Create internal map and COM collections
//									on running system config tree (pointed to in MTConfigDir registry value);
//									Read Only mode, all writing functionality will be disabled.
//									Otherwise set config directory to config_root\EnumType
//
// ----------------------------------------------------------------


STDMETHODIMP CEnumConfig::Initialize(/*[in, optional, defaultvalue("")*/VARIANT Extension)
{
	mLogger.LogVarArgs(LOG_DEBUG, 
			"CEnumConfig::Initialize([in, optional, defaultvalue("") VARIANT Extension) method has beed deprecated, please remove it from your code");
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetEnumWithValue
// Arguments:     BSTR enumSpace - name for enum space
//                BSTR enumName - name for enum type
//                BSTR value - value metered in
// Return Value:  enumerator name or empty string if not found
// Errors Raised: 
// Description:   Look up an enumerator for given enum space, enum type and value metered in.
//								For example, country name enum type in Global enumspace defined in Global.xml:
//
//								<mt_config>
//									<enum_spaces>
//									<enum_space  name="Global">
//									<description>Global namespace</description>			
//										<enums>
//											<enum name="CountryName">
//											<description>Country list enumeration</description>
//												<entries>
//													<entry name="Afghanistan">
//													<value>2</value>
//													</entry>
//													<entry name="Albania">
//													<value>3</value>
//													</entry>
//															.......
//
//								For given Global as enum space. CountryName as enum type and 3 as value
//								"Albania" will be returned
// ----------------------------------------------------------------

//TODO: add null enum logic
STDMETHODIMP CEnumConfig::GetEnumWithValue(BSTR enumSpace, BSTR enumName, BSTR value, BSTR *name)
{
	EnumMapIterator map_it;
	HRESULT nRetVal = S_OK;
	_bstr_t sp = enumSpace;
	_bstr_t nm = enumName;
	_bstr_t val = value;
	string enum_space = _strlwr((char*)sp);
	string enum_name =	_strlwr((char*)nm);
	string enum_value = _strlwr((char*)val);
	
	//create key
	string key = enum_space+"/"+enum_name+"/"+enum_value;

	AutoCriticalSection alock(&mLock);

	if (mpEnumTypeMap->size() > 0)
	{
		map_it = mpEnumTypeMap->find(key);
		if (map_it != mpEnumTypeMap->end() )
		{
			string nm = ((*map_it).second)->Enumerator();
			CComBSTR   bStrRet(nm.c_str());
			*name = bStrRet.Detach();
			return nRetVal;
		}
		else
		{
			nRetVal = S_FALSE;
			//TODO:: throw error
			*name = ::SysAllocString(L"");
			return nRetVal;
		}
			
	}
	else
	{
		nRetVal = MTENUMCONFIG_ENUM_TYPE_COLLECTION_EMPTY;
		mLogger.LogThis(LOG_ERROR, "Enum types map is empty");
		return nRetVal;
	}
	
	return nRetVal;
}


// ----------------------------------------------------------------
// Name:     			GetFQN
// Arguments:     BSTR enumSpace - name for enum space
//                BSTR enumName - name for enum type
//                BSTR value - value metered in
// Return Value:  enumerator fully qualified name or empty string if not found
// Errors Raised: 
// Description:   Look up an enumerator for given enum space, enum type and value metered in.
//								For example, country name enum type in Global enumspace defined in Global.xml:
//
//								<mt_config>
//									<enum_spaces>
//									<enum_space  name="Global">
//									<description>Global namespace</description>			
//										<enums>
//											<enum name="CountryName">
//											<description>Country list enumeration</description>
//												<entries>
//													<entry name="Afghanistan">
//													<value>2</value>
//													</entry>
//													<entry name="Albania">
//													<value>3</value>
//													</entry>
//															.......
//
//								For given Global as enum space. CountryName as enum type and 3 as value
//								"Global/CountryName/Albania" will be returned
// ----------------------------------------------------------------

//TODO: add null enum logic
STDMETHODIMP CEnumConfig::GetFQN(BSTR enumSpace, BSTR enumName, BSTR value, BSTR *name)
{
	EnumMapIterator map_it;
	HRESULT nRetVal = S_OK;
	_bstr_t sp = enumSpace;
	_bstr_t nm = enumName;
	_bstr_t val = value;
	string enum_space = _strlwr((char*)sp);
	string enum_name =	_strlwr((char*)nm);
	string enum_value = _strlwr((char*)val);
	
	//create key
	string key = enum_space+"/"+enum_name+"/"+enum_value;
		
	AutoCriticalSection alock(&mLock);

	if (mpEnumTypeMap->size() > 0)
	{
		map_it = mpEnumTypeMap->find(key);
		
		if (map_it != mpEnumTypeMap->end() )
		{
			string nm = ((*map_it).second)->GetFQNString();
			CComBSTR   bStrRet(nm.c_str());
			*name = bStrRet.Detach();
			return nRetVal;
		}
		else
		{
			char buf[1024];
      sprintf(buf, "<%s> does not correspond to a valid enumerator!", key.c_str());
			mLogger.LogThis (LOG_ERROR, buf);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_NOT_A_VALID_ENUMERATOR);
		}
			
	}
	else
	{
		nRetVal = MTENUMCONFIG_ENUM_TYPE_COLLECTION_EMPTY;
		mLogger.LogThis(LOG_ERROR, "Enum types map is empty");
		return nRetVal;
	}
	return nRetVal;
}

//TODO: add null enum logic
STDMETHODIMP CEnumConfig::GetID(BSTR enumSpace, BSTR enumType, BSTR value, long* description_id)
{
	EnumMapIterator map_it;
	char buf[512];
	HRESULT nRetVal = S_OK;
	_bstr_t sp = enumSpace;
	_bstr_t nm = enumType;
	_bstr_t val = value;
	string enum_space = _strlwr((char*)sp);
	string enum_name =	_strlwr((char*)nm);
	string enum_value = _strlwr((char*)val);
	
	//create key
	string key = enum_space+"/"+enum_name+"/"+enum_value;

	AutoCriticalSection alock(&mLock);

	if (mpEnumTypeMap->size() > 0)
	{
		map_it = mpEnumTypeMap->find(key);
		
		if (map_it == mpEnumTypeMap->end() )
		{
			sprintf(buf, "<%s> does not correspond to a valid enumerator!", key.c_str());
			mLogger.LogThis (LOG_ERROR, buf);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_NOT_A_VALID_ENUMERATOR);
		}
		else
		{
			_bstr_t fqn = (*map_it).second->GetFQNString().c_str();
			(*description_id) = mNameIDPtr->GetNameID(fqn);
		}
	}
	else
	{
		sprintf(buf, "Enum type collection is empty!");
		mLogger.LogThis (LOG_ERROR, buf);
		return Error(buf, IID_IEnumConfig, MTENUMCONFIG_ENUM_TYPE_COLLECTION_EMPTY);
	}

	return nRetVal;
}
// ----------------------------------------------------------------
// Name:     			Read
// Arguments:     BSTR val - name for the file to process
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY 
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::Read(BSTR val)
{
	HRESULT nRetVal;
	try {
		MTConfigLib::IMTConfigPropSetPtr confSet = NULL;

		nRetVal = ReadConfiguration(&confSet, val);

		if (FAILED(nRetVal))
			return Error("Failed to Read configuration set!", IID_IEnumConfig, nRetVal);
		else {
			return ReadWithSet(confSet,_bstr_t(val));
		}

	}
	catch (_com_error e)
	{
		return ReturnComError(e);
	}

	// shouldn't get here
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			ReadWithSet
// Arguments:     IMTConfigPropSetPtr& confSet	-	reference to IMTConfigPropSetPtr
//																								which will be filled from file
//								_bstr_t& file									-		file name
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

HRESULT CEnumConfig::ReadWithSet(MTConfigLib::IMTConfigPropSetPtr& confSet,_bstr_t& file)
{
	HRESULT nRetVal = S_OK;
	
	std::string rwenum_space;
	std::string rwenum_space_desc;
	std::string rwenum_name;
	std::string rwenum_name_desc;
	std::string rwenum_entry_name;
	
	string enum_space;
	string enum_space_desc;
	string enum_name;
	string enum_name_desc;
	string enum_entry_name;

	string enum_fqn;

	CEnumSpace* pEnumSpace;
	CEnumerator*	pEnumType;

	try
	{
		//should never happen
		if (confSet == NULL)
		{
			nRetVal = E_FAIL;
			mLogger.LogThis(LOG_ERROR,"MTEnumConfig::ReadConfig - No confset read." );
			return nRetVal;
		}
		// get the config data ...
		IMTConfigPropSetPtr set;
		IMTConfigPropSetPtr subset;
		IMTConfigPropSetPtr enums_set;
		IMTConfigPropSetPtr enum_set;
		IMTConfigPropSetPtr enum_entries_set;
		IMTConfigPropSetPtr enum_entry_set;
		IMTConfigPropPtr enum_entry_prop;
		IMTConfigPropPtr value_entry_prop;
		MTConfigLib::IMTConfigAttribSetPtr attribSet;

		// read in the xml config file ...
		set = confSet->NextSetWithName(ENUM_SPACES_TAG_NAME);
		
		//iterate through enum spaces
		while((subset = set->NextSetWithName(ENUM_SPACE_TAG_NAME)) != NULL)
		{	
			
			mEnumSpace = NULL;
			mEnumSpace = MTENUMCONFIGLib::IMTEnumSpacePtr(MTPROGID_ENUMSPACE);
			mEnumSpace->PutLocation(file);
			
			attribSet = subset->GetAttribSet();

			if (attribSet == NULL)
			{
				mLogger.LogThis (LOG_ERROR,
					"Unable to get attrib set for enum_space tag");
				return Error ("Unable to get attrib set for enum_space tag!",
											IID_IEnumConfig, nRetVal);
			}

			rwenum_space = attribSet->GetAttrValue(ATTRIB_TAG_NAME);
			rwenum_space_desc = subset->NextStringWithName(DESC_TAG_NAME);
			
			enum_space = (char*)rwenum_space.c_str();
			enum_space_desc = (char*)rwenum_space_desc.c_str();

			mEnumSpace->Putname(enum_space.c_str());
			mEnumSpace->PutDescription(enum_space_desc.c_str());
			
			pEnumSpace = new CEnumSpace(enum_space, enum_space_desc);
		
			
			//check for empty enum_space and terminate if found
			try
			{
				enums_set = subset->NextSetWithName("enums");
			}
			catch(_com_error err)
			{
				char buf[255];
				sprintf(buf, "Enum space has to contain at least one enum type! (\"%s\")",
					enum_space.c_str());
				mLogger.LogThis(LOG_ERROR, buf);
				return Error(buf, IID_IEnumConfig, MTENUMCONFIG_MALFORMED_XML_SET);
			}
			
			//iterate through enum types
			while((enum_set = enums_set->NextSetWithName(ENUM_TAG_NAME)) != NULL)
			{

//Check for value collisions in IMTEnumType object now
#if 0				
				//create temporary set to hold all enumerator values
				// to make sure they don't collide
				std::set <std::string> ValueSet;
				std::set <std::string>::iterator ValueSetIterator;
#endif

				mEnumType = MTENUMCONFIGLib::IMTEnumTypePtr(MTPROGID_ENUM_TYPE);
				attribSet = enum_set->GetAttribSet();
				rwenum_name = attribSet->GetAttrValue(ATTRIB_TAG_NAME);
				rwenum_name_desc = enum_set->NextStringWithName(DESC_TAG_NAME);

				enum_name = rwenum_name.c_str();
				enum_name_desc = rwenum_name_desc.c_str();

				//check for empty enum_type and terminate if found
				try
				{
					enum_entries_set = enum_set->NextSetWithName("entries");
				}
				catch(_com_error&)
				{
					char buf[255];
					sprintf(buf, "Enum type has to contain at least one enumerator! (\"%s\")",
						enum_name.c_str());
					mLogger.LogThis(LOG_ERROR, buf);
					return Error(buf, IID_IEnumConfig, MTENUMCONFIG_MALFORMED_XML_SET);
				}
			
				//iterate through enumerators
				// just use NextWithName, because enumerator may not have any values
				while (enum_entry_prop = enum_entries_set->NextWithName("entry"))
				{
					mEnumerator = mEnumeratorFactory.CreateInstance();
					pEnumType = NULL;
					EnumValueList values;
					
					//if property is a  set - get all values
					if(enum_entry_prop->GetPropType() == MTConfigLib::PROP_TYPE_SET)
					{
						enum_entry_set = enum_entry_prop->GetPropValue();
						attribSet = enum_entry_set->GetAttribSet();
						rwenum_entry_name = attribSet->GetAttrValue(ATTRIB_TAG_NAME);
						enum_entry_name = rwenum_entry_name.c_str();

						while(value_entry_prop = enum_entry_set->NextWithName("value"))
						{
							try
							{
								string value = value_entry_prop->GetValueAsString();
								values.push_back(value);
								mEnumerator->AddValue(_bstr_t(value.c_str()));
							}
							catch(_com_error e)
							{
								break;
							}
						}
					}
					else
					{
						attribSet = enum_entry_prop->GetAttribSet();
						rwenum_entry_name = attribSet->GetAttrValue(ATTRIB_TAG_NAME);
						enum_entry_name = rwenum_entry_name.c_str();
					}
					
					
					
					string enumerator = (char*)enum_entry_name.c_str();
					//create FQN string without conversion to lower case 
					string sFQN = enum_space + "/" + enum_name + "/" + enumerator;

					pEnumType = new CEnumerator(CEnumeratorFQN(sFQN), enumerator, enum_name_desc, values);
					
					mEnumerator->PutEnumspace(_bstr_t(enum_space.c_str()));
					mEnumerator->PutEnumType(_bstr_t(enum_name.c_str()));
					mEnumerator->Putname(_bstr_t(enumerator.c_str()));

			
					mEnumType->PutEnumTypeName(_bstr_t(enum_name.c_str()));
					mEnumType->PutEnumTypeDescription(_bstr_t(enum_name_desc.c_str()));
					mEnumType->PutEnumspace(_bstr_t(enum_space.c_str()));
					mEnumType->PutEnumSpaceDescription(_bstr_t(enum_space_desc.c_str()));
			
					mEnumType->Add(mEnumerator);
			
					//create map key
					// store it only in lower case

					string key_enum_space = enum_space.c_str();
					string key_enum_name = enum_name.c_str();

					enum_fqn.erase();
					enum_fqn = _strlwr((char*)key_enum_space.c_str());
					enum_fqn+="/";
					enum_fqn+=_strlwr((char*)key_enum_name.c_str());
					enum_fqn+="/";


					string name_enum_fqn=enum_fqn+_strlwr((char*)enumerator.c_str());
					
					//create enumerator object...

					
					mpEnumTypeMap->insert(EnumTypeMap::value_type(name_enum_fqn, pEnumType));
					
					//for every value add an entry to the map, and give same object pointer
					for (unsigned int i=0;i<values.size();)
					{
						string val = enum_fqn + _strlwr((char*)values.at(i++).c_str());
						mpEnumTypeMap->insert(EnumTypeMap::value_type(val, pEnumType));
					}
					values.clear();
				}//enumerators while
				
				mEnumSpace->Add(mEnumType);
			
				//add enum type name to EnumSpace object for validation API
				pEnumSpace->AddEnumTypeName(enum_name);
				//clear enum type value set
				//ValueSet.clear();

			}//enum types while
			
			
			//see if there are duplicate enum_spaces
			//if there are - log error and terminate
			EnumSpaceMap::iterator it;
			string lwrEnumSpace = _strlwr( (char*) enum_space.c_str());

			it = mpEnumSpaceMap->find(lwrEnumSpace);

			if(it != mpEnumSpaceMap->end())
			{
				char buf[255];
				sprintf(buf, "Enum Space \"%s\" already exists!",
								lwrEnumSpace.c_str());
								mLogger.LogThis(LOG_ERROR, buf);
				return Error(buf, IID_IEnumConfig, MTENUMCONFIG_DUPLICATE_ENUMSPACE);
			}

			//insert item into enum space map 
			mpEnumSpaceMap->insert(EnumSpaceMap::value_type(lwrEnumSpace, pEnumSpace));

			mEnumSpaceCollection->Add(mEnumSpace);
		}//enum spaces while
	
	}//try
	catch (_com_error& e)
	{
		nRetVal = e.Error();
		mLogger.LogVarArgs (LOG_ERROR,
			"Unable to read file. Error = <%x>", nRetVal);
		return ReturnComError(e);
	}
	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     			GetEnumFileList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

HRESULT CEnumConfig::GetEnumFileList(EnumFileList& aList)
{
	HRESULT nRetVal = S_OK;
	
	try
	{
		// step 1: Create an instance of MTConfig
		VARIANT_BOOL bChecksum;
		// step 2: create an Instance of the RCD
		// step 3: run a query for through the RCD
		//if(mrwConfigDir)

		RCDLib::IMTRcdFileListPtr aFileList;
		const _bstr_t aQuery("config\\enumtype\\*.xml");
		
		aFileList = mRCD->RunQuery(aQuery,VARIANT_TRUE);
		// step 4: iterate through the list, reading the XML
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

		if(aFileList->GetCount() == 0) {
			const char* szLogMsg = "no enumerated type configuration found";
			mLogger.LogThis(LOG_ERROR,szLogMsg);
			nRetVal = Error (szLogMsg);
		}
		else {
	
			nRetVal = it.Init(aFileList);
			if(FAILED(nRetVal)) 
				return nRetVal;
			
			while (TRUE)
			{
				_variant_t aVariant= it.GetNext();
				_bstr_t afile = aVariant;
				if(afile.length() == 0) break;

				// step 5: populate MTPropAndFile
				MTConfigLib::IMTConfigPropSetPtr confSet = mConfig->ReadConfiguration(afile,&bChecksum);
				MTPropAndFile aPair(confSet,afile);
				aList.push_back(aPair);
			}
		}

	}
	catch (_com_error& e)
	{
		char buf[1024];
		nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to initialize enum files list. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}

	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     			GetEnumSpaces
// Arguments:     
// Return Value:  IMTEnumSpaceCollection** pEnumSpaceCollection -	enum space collection
// Raised Errors:
// Description:		Returnes an internal EnumSpaceCollection object - all enum space objects
//								defined in enumtype xml files
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::GetEnumSpaces(VARIANT extension,IMTEnumSpaceCollection ** pEnumSpaceCollection)
{
	try
	{

		if (pEnumSpaceCollection == NULL)
			return E_POINTER;

		_variant_t OptionalExtension(extension);
	
		if	(extension.vt == VT_ERROR || 
				 (_bstr_t(OptionalExtension) == _bstr_t(""))) {

			mEnumSpaceCollection->QueryInterface(IID_IMTEnumSpaceCollection, 
																					 reinterpret_cast<void**>(pEnumSpaceCollection));
		}
		else {
			_bstr_t aSpecifiedExtension = OptionalExtension;
			// step 1: create a new collection object
			MTENUMCONFIGLib::IMTEnumSpaceCollectionPtr aNewCol(MTPROGID_ENUMSPACE_COLLECTION);
			// step 2: iterate through the cached collection, picking out the ones that match the 
			// the specified extension name
			SetIterator<MTENUMCONFIGLib::IMTEnumSpaceCollectionPtr, MTENUMCONFIGLib::IMTEnumSpacePtr> it;

			if(FAILED(it.Init(mEnumSpaceCollection))) return FALSE;

			AutoCriticalSection alock(&mLock);

			while(true) {
				MTENUMCONFIGLib::IMTEnumSpacePtr aEnumSpace = it.GetNext();
				if(aEnumSpace == NULL) break;

				// step 3: add to new collection
				if(stricmp(aSpecifiedExtension,aEnumSpace->GetExtension()) == 0) {
					aNewCol->Add(aEnumSpace);
				}
			}

			// step 4: verify that that at least one enumspace exists!
			if(aNewCol->GetSize() == 0) {
				_bstr_t aError("Failed to find any enumspaces for extension ");
				aError += aSpecifiedExtension;
				return Error((const char*)aError);
			}
			// step 5: set the pointer
			*pEnumSpaceCollection = (IMTEnumSpaceCollection *)aNewCol.Detach();
		}

	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to get enum spaces. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetEnumSpace
// Arguments:     BSTR name - enum space name to be looked up
// Return Value:  IMTEnumSpace** pEnumSpace -	out parameter
// Raised Errors:
// Description:		Look up an enumspace in internal EnumSpaceCollection object by name
//								and return it
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::GetEnumSpace(BSTR name, IMTEnumSpace **pEnumSpace)
{
	HRESULT nRet = S_OK;
	_bstr_t bstrCrit = name;
	string crit = _strlwr((char*)bstrCrit);

	MTENUMCONFIGLib::IMTEnumSpacePtr p;
	
	CComVariant varEnum;
	varEnum.vt = VT_DISPATCH;

	{
		AutoCriticalSection alock(&mLock);
		
		for(int i=0;i < mEnumSpaceCollection->GetSize() ;)
		{
			
			nRet = mEnumSpaceCollection->get_Item(++i, &varEnum);
			if(!SUCCEEDED(nRet))
				return nRet;

			nRet = varEnum.pdispVal->QueryInterface(IID_IMTEnumSpace, (void**)&p);
			varEnum.Clear();
			
			if(!SUCCEEDED(nRet))
				return nRet;
			_bstr_t name = p->Getname();
			string nm = _strlwr((char*)name);
			if(crit.compare(nm) == 0)
			{
				*pEnumSpace = (IMTEnumSpace *)p.Detach();
				return nRet;
			}

			p.Release();
			
		}
	}


	mLogger.LogVarArgs(LOG_ERROR, "Enum Space %s not found in the collection!", 
									(const char*)bstrCrit);

	(*pEnumSpace) = (IMTEnumSpace *)p.Detach();
	return nRet;

}

// ----------------------------------------------------------------
// Name:     			WriteNewEnumSpaceWithFileName
// Arguments:     BSTR file	- file name for the enum space to be written to
//								IMTEnumSpace	-	enumspace object to be written to the file
// Return Value:  
// Raised Errors:
// Description:		Write an MTEnumSpace object to the given file
//								TODO:	Check if this enumspace already exists in this file,
//											right now writes a duplicate one	
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::WriteNewEnumSpaceWithFileName(BSTR file, IMTEnumSpace *pEnumSpace)
{
	try
	{
		HRESULT nRet = S_OK;
	
		BOOL bFileExists = FALSE;
		_bstr_t bstrRelativePath = file;
	
		MTConfigLib::IMTConfigPropSet* pSet = NULL;
		MTConfigLib::IMTConfigPropSetPtr confSet;
		MTConfigLib::IMTConfigPropSetPtr EnumConfigSet;
		MTConfigLib::IMTConfigPropSetPtr EnumSpacesSet;
		MTENUMCONFIGLib::IMTEnumSpacePtr pEnumSpacePtr(pEnumSpace);
		mLogger.LogVarArgs(LOG_DEBUG, "Preparing to write new enum space to %s", (const char*)bstrRelativePath);

		if (pEnumSpace == NULL)
		{
			nRet = E_POINTER;
			mLogger.LogThis(LOG_ERROR, "EnumSpace pointer is null");
			return Error ("EnumType pointer is null",
										IID_IEnumConfig, nRet);
		}

		AutoCriticalSection alock(&mLock);
	
		nRet = ReadConfigurationInternal(confSet, bstrRelativePath);
		
		if (FAILED(nRet))
		{
			mLogger.LogVarArgs(LOG_DEBUG, "File %s does not exist, creating new one.", (const char*)bstrRelativePath);
			confSet = NULL;
		}
	
		if (confSet != NULL) bFileExists = TRUE;
	
		_bstr_t bstrenum_space = pEnumSpacePtr->Getname();

		if(bstrenum_space.length() == 0)
		{
			mLogger.LogThis(LOG_ERROR, "Enum space name not set");
			return Error ("EnumType pointer is null",
										IID_IEnumConfig, MTENUMCONFIG_ATTRIBUTE_MISSING);
		}

		string enum_space = (const char*)bstrenum_space;


		if(!bFileExists)
		{
			confSet = mConfig->NewConfiguration(CONFIG_TAG_NAME);
			EnumSpacesSet = confSet->InsertSet(ENUM_SPACES_TAG_NAME);
			try
			{
				nRet = pEnumSpacePtr->WriteSet
					((MTENUMCONFIGLib::IMTConfigPropSet *)EnumSpacesSet.GetInterfacePtr());
			}
			catch(_com_error& e)
			{
				return (ReturnComError(e));
			}
		
		}
		else
		{
			EnumSpacesSet = confSet->NextSetWithName(ENUM_SPACES_TAG_NAME);
			try
			{
				pEnumSpacePtr->WriteSet
					((MTENUMCONFIGLib::IMTConfigPropSet *)EnumSpacesSet.GetInterfacePtr());
			}
			catch(_com_error& err)
			{
				return (ReturnComError(err));
			}
		}

		try {
			nRet = confSet->Write(bstrRelativePath);
		}
		catch(_com_error& e) {
			return ReturnComError(e);
		}
		//refresh internal collections
		ConfigurationHasChanged();
		return nRet;
	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to write enum space. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}
}

// ----------------------------------------------------------------
// Name:     			UpdateEnumSpace
// Arguments:     IMTEnumSpace	-	enumspace object to be written to the file
// Return Value:  
// Raised Errors:
// Description:		Finds and updates an existing enum space
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::UpdateEnumSpace(IMTEnumSpace *pEnumSpace)
{
	try
	{
		MTENUMCONFIGLib::IMTEnumSpacePtr pEnumSpacePtr(pEnumSpace);
		HRESULT nRet = S_OK;
		MTConfigLib::IMTConfigPropSet* pSet = NULL;
		MTConfigLib::IMTConfigPropSetPtr ConfSet;
		MTConfigLib::IMTConfigPropSetPtr NewConfSet;
		MTConfigLib::IMTConfigPropSetPtr EnumSpacesSet;
		MTConfigLib::IMTConfigPropSetPtr NewEnumSpacesSet;
		MTConfigLib::IMTConfigPropSetPtr NewEnumSpaceSet;
		MTConfigLib::IMTConfigPropSetPtr EnumSpaceSet;
	
		MTConfigLib::IMTConfigAttribSetPtr attribSet;
	
		_bstr_t name = pEnumSpacePtr->Getname();
		int res;
		ValidEnumSpace(name, &res);

		if(!res)
		{
			char buf[255];
			sprintf("Enum space <%s> does not exist, can not update", (const char*)name);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_NOT_A_VALID_ENUMSPACE);
		}

		//relative to config dir path
		_bstr_t confFile = pEnumSpacePtr->GetLocation();
	
		string	sName = _strlwr((char*)_bstr_t(name));

		AutoCriticalSection alock(&mLock);

		nRet = ReadConfigurationInternal(ConfSet, confFile);
	
		if (FAILED(nRet)) {
			PassThroughComError();
			return nRet;
		}
		mLogger.LogVarArgs(LOG_DEBUG, "Updating enum space %s in %s", sName.c_str(), (char*)confFile);	

	
		EnumSpacesSet = ConfSet->NextSetWithName(ENUM_SPACES_TAG_NAME);
		//create new config set
		NewConfSet = mConfig->NewConfiguration(CONFIG_TAG_NAME);
		NewEnumSpacesSet = NewConfSet->InsertSet(ENUM_SPACES_TAG_NAME);
	
		while((EnumSpaceSet = EnumSpacesSet->NextSetWithName(ENUM_SPACE_TAG_NAME)) != NULL)
		{
		
			attribSet = EnumSpaceSet->GetAttribSet();
		
			if (attribSet == NULL)
			{
				return Error("Missing name attribute on enum_space tag!",
										 IID_IEnumConfig, MTENUMCONFIG_MALFORMED_XML_SET);
			}
		
			_bstr_t bstrEnumSpace = attribSet->GetAttrValue(ATTRIB_TAG_NAME);
			string enum_space = _strlwr((char*)bstrEnumSpace);
		
			if (sName.compare(enum_space) == 0)
			{
				MTConfigLib::IMTConfigPropSet* pSet = NULL;
				NewEnumSpacesSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pSet);
			
				try
				{
					pEnumSpace->WriteSet((::IMTConfigPropSet*)pSet);
				}
				catch(_com_error& e)
				{
					return ReturnComError(e);
				}
			}
			else
			{
				MTConfigLib::IMTConfigAttribSetPtr pAttrib(MTPROGID_CONFIG_ATTRIB_SET);
				pAttrib->Initialize();
				nRet = pAttrib->AddPair(ATTRIB_TAG_NAME, _bstr_t(enum_space.c_str()));
				NewEnumSpaceSet = NewEnumSpacesSet->InsertSet(ENUM_SPACE_TAG_NAME);
				nRet = NewEnumSpaceSet->put_AttribSet(pAttrib);
			
				if(FAILED(nRet))
					return nRet;
			
				NewEnumSpaceSet->AddSubSet(EnumSpaceSet);
			}
		}
	
		try
		{
			nRet = NewConfSet->Write(confFile);
		}
		catch(_com_error& err)
		{
			return(ReturnComError(err));
		}
		//refresh internal collections
		ConfigurationHasChanged();
		return nRet;
	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to update enum space. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}
}


// ----------------------------------------------------------------
// Name:     			WriteNewEnumSpace
// Arguments:     IMTEnumSpace	-	enumspace object to be written to the file
// Return Value:  
// Raised Errors:
// Description:		Create file name as MT_CONFIG_DIR\\enum_space_name\enum_space_name.xml
//								and call WriteNewEnumSpaceWithFileName(relativeFilePath, pEnumSpace)
//								TODO:	Check if this enumspace already exists in this file,
//											right now writes a duplicate one	
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::WriteNewEnumSpace(IMTEnumSpace *pEnumSpace, BSTR aExtension)
{
	try
	{
		_bstr_t sExtension = aExtension;
		MTENUMCONFIGLib::IMTEnumSpacePtr EnumSpacePtr(pEnumSpace);
		_bstr_t name = EnumSpacePtr->Getname();

		_bstr_t fullFilePath = _bstr_t(mExtensionDir.c_str()) + L"\\" + sExtension;
		fullFilePath += "\\config\\enumtype\\";
		fullFilePath += GetFileName(name, fullFilePath);
		int res;
		ValidEnumSpace(name, &res);
		if(res)
		{
			char buf[512];
			sprintf(buf, "EnumSpace <%s> already exists, call UpdateEnumSpace", (const char*)name);
			mLogger.LogThis (LOG_ERROR, buf);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_DUPLICATE_ENUMSPACE);
		}
	
		mLogger.LogVarArgs(LOG_DEBUG, "Writing new enum space to %s", (const char*)fullFilePath);
		return WriteNewEnumSpaceWithFileName(fullFilePath, pEnumSpace);
	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to write new enum space. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}
}

// ----------------------------------------------------------------
// Name:     			GetFileName
// Arguments:     BSTR name_space	- name for enumspace based on which the file name will be constructed
// Return Value:  _bstr_t					- constucted file name
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

_bstr_t CEnumConfig::GetFileName(BSTR name_space,_bstr_t& aExtensionDir)
{
	_bstr_t name = name_space;
	
	wchar_t *pFile;
  wchar_t FileBuf[256];
  int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);
  
	wchar_t seps[] = L"\\, /";
	
	_bstr_t parsedDir;
	_bstr_t parsedFileName;
	
	wcsncpy( FileBuf, (wchar_t *)name,  FileBufLen);
	
	//cut off first token and make it subdirectory
	pFile = wcstok( FileBuf, seps);
	parsedDir = pFile;
	
	//create this subdirectory
	::CreateDirectory(aExtensionDir + parsedDir.copy(), NULL);
	
	//convert '/' and '\' to '_' and compose a file name
	while( pFile != NULL)
	{
		parsedFileName += _bstr_t(pFile);
		pFile = wcstok( NULL, seps);
		if (pFile)
			parsedFileName += L"_";
	}
	return (parsedDir + L"\\" + parsedFileName + L".xml");
}

_bstr_t CEnumConfig::GetSubDir(BSTR file)
{
	_bstr_t name = file;
	
	wchar_t *pFile;
  wchar_t FileBuf[256];
  int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);
  
	wchar_t seps[] = L"\\, /";
	
	_bstr_t parsedDir;
	
	wcsncpy( FileBuf, (wchar_t *)name,  FileBufLen);
	
	//cut off first token and make it subdirectory
	pFile = wcstok( FileBuf, seps);
	parsedDir = pFile;
	
	return (parsedDir + L"\\");
}


// ----------------------------------------------------------------
// Name:     			GetSubDirs
// Arguments:     BSTR file	- file path eith file name
// Return Value:  _bstr_t		- path for this file without file name
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

_bstr_t CEnumConfig::GetSubDirs(BSTR file)
{
	_bstr_t name = file;
	wchar_t seps[] = L"\\, /";
	wchar_t *pFile;
	wchar_t FileBuf[256];
	std::vector<wchar_t*> tokens;
	_bstr_t subdirs;
	int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);

	wcsncpy( FileBuf, (wchar_t *)name,  FileBufLen);
  
	pFile = wcstok( FileBuf, seps);

	while( pFile != NULL )   
	{
		
		tokens.push_back(pFile);
		pFile = wcstok( NULL, seps );
	}

	for (unsigned int i  = 0; i < tokens.size()-1; i++ )
	{
		subdirs += _bstr_t(tokens.at(i)) + "/";
	}

	return subdirs;
      
}

// ----------------------------------------------------------------
// Name:     			IsFullPath
// Arguments:     BSTR file	- file path to evaluate
// Return Value:  BOOL			- TRUE if full path, FALSE if relative
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

BOOL CEnumConfig::IsFullPath(BSTR file)
{
	_bstr_t name = file;
	
	wchar_t *pFile;
  wchar_t FileBuf[512];
  int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);
  
	wchar_t device[] = L":";

	wcsncpy( FileBuf, (wchar_t *)name,  FileBufLen);

	pFile = wcstok( FileBuf, device);

	DWORD ret = ::GetFileAttributes(name);

	if (wcslen(pFile) == name.length() || ret == FILE_ATTRIBUTE_DIRECTORY)
		return FALSE;
	else
		return TRUE;

}


// ----------------------------------------------------------------
// Name:     			UpdateMasterFile
// Arguments:     BSTR name_space	- new entry to be added to master file
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------
HRESULT CEnumConfig::UpdateMasterFile(_bstr_t new_entry)
{
	HRESULT hr = S_OK;	
	mLogger.LogThis(LOG_DEBUG, "Method CEnumConfig::UpdateMasterFile has been deprecated");
	
	return hr;
}


// ----------------------------------------------------------------
// Name:     			ValidEnumSpace
// Arguments:     BSTR name	- name for enumspace
// Return Value:  int*			-	return code
// Raised Errors:
// Description:		Returns 1 if enum space exists in the internal collection,
//								0 if doesn't
//
//								TODO:		Replace interger with boolean VARIANT
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::ValidEnumSpace(BSTR name, int *ret)
{
	//convert name to lower case
	string sName = _strlwr(_bstr_t(name));

	AutoCriticalSection alock(&mLock);

	EnumSpaceMap::iterator it = mpEnumSpaceMap->find(sName);
	(*ret) = (it == mpEnumSpaceMap->end()) ? 0 : 1;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			ValidEnumType
// Arguments:     BSTR enum_space	- name for enumspace
//								BSTR enum_type	- name for enumtype
// Return Value:  int*			-	return code
// Raised Errors:
// Description:		Returns 1 if enum type exists in given enum space
//								0 if doesn't
//									
//								TODO:		Replace interger with boolean VARIANT
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::ValidEnumType(BSTR enum_space, BSTR enum_type, int *ret)
{
	string sEnumSpace = _strlwr(_bstr_t(enum_space));
	string sEnumType = _strlwr(_bstr_t(enum_type));
	
	
	AutoCriticalSection alock(&mLock);

	EnumSpaceMap::iterator it = mpEnumSpaceMap->find(sEnumSpace);
	
	if (it != mpEnumSpaceMap->end() )
	{
		CEnumSpace* p  = (*it).second;
		(*ret) = (p->IsValidEnumType(sEnumType)) ? 1 : 0;
	}
	else (*ret) = 0;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			GetEnumType
// Arguments:     BSTR enum_space	- name for enumspace
//								BSTR enum_type	- name for enumtype
// Return Value:  IMTEnumType			- enumtype object
// Raised Errors:
// Description:		Return MTEnumType object given enumspace name and enum type name
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::GetEnumType(BSTR enum_space, BSTR enum_type, IMTEnumType **pType)
{
	HRESULT hr = S_OK;

	try
	{
		MTENUMCONFIGLib::IMTEnumSpacePtr pEnumSpace = NULL;
		MTENUMCONFIGLib::IMTEnumTypePtr pEnumType = NULL;
		MTENUMCONFIGLib::IEnumConfigPtr pEnumConfig(this);

		pEnumSpace = pEnumConfig->GetEnumSpace(enum_space);
		if(pEnumSpace == NULL) return S_FALSE;
	
		AutoCriticalSection alock(&mLock);

		pEnumType = pEnumSpace->GetEnumType(enum_type);
		if (pEnumType == NULL) return S_FALSE;

		(*pType) = (IMTEnumType *) pEnumType.Detach();
	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to get enumtype. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}
	
	return hr;
}

// ----------------------------------------------------------------
// Name:     			GetEnumerators
// Arguments:     BSTR enum_space							- name for enumspace
//								BSTR enum_type							- name for enumtype
// Return Value:  IMTEnumeratorCollection			- enumerator collection object
// Raised Errors:
// Description:		Return MTEnumeratorCollection given enumspace name and enum type name
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::GetEnumerators(BSTR enum_space, BSTR enum_type, IMTEnumeratorCollection ** pEnum)
{
	HRESULT hr = S_OK;
	try
	{
		MTENUMCONFIGLib::IMTEnumTypePtr pEnumType = NULL;
		MTENUMCONFIGLib::IMTEnumeratorCollectionPtr pEnumeratorColl = NULL;

		this->GetEnumType(enum_space, enum_type, (IMTEnumType **) &pEnumType);

		if (pEnumType == NULL) return S_FALSE;

		AutoCriticalSection alock(&mLock);

		pEnumeratorColl = pEnumType->GetEnumerators();
		if(pEnumeratorColl == NULL)
			return S_FALSE;

		(*pEnum) = (IMTEnumeratorCollection *) pEnumeratorColl.Detach();
	}
	catch (_com_error& e)
	{
		char buf[1024];
		HRESULT nRetVal = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to get enumtype. Error = <%x>, Description = <%s>", nRetVal, (const char*)desc);
		mLogger.LogVarArgs (LOG_ERROR,buf);
		return ReturnComError(e);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     			InitializeFromHost
// Arguments:     BSTR host	- host name
//								BSTR relative_path	- host's virtual directory
// Return Value: 
// Raised Errors:
// Description:		Initializes internal collections remotely
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::InitializeFromHost(BSTR host, BSTR relative_path_including_extension)
{
	mHost = host;
	mRelativePath = relative_path_including_extension + _bstr_t(ENUM_TYPE_SUBDIR);
	return Initialize(_variant_t(mRelativePath));
}



// ----------------------------------------------------------------
// Name:     			ReadConfiguration
// Arguments:     IMTConfigPropSet**	- propset to be filled from file
//								BSTR file	- file path to fill propset from
// Return Value: 
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

/*
Figure out if need to read configuration from host or not
and read configuration
File should be a relative path excluding EnumType subdir
if file is NULL, then  read master file
*/
HRESULT CEnumConfig::ReadConfiguration(MTConfigLib::IMTConfigPropSet**	pSet, BSTR file)
{
	return E_NOTIMPL;
}

HRESULT CEnumConfig::ReadConfigurationInternal(MTConfigLib::IMTConfigPropSetPtr& aSet,_bstr_t& file)
{

	// read the first file and hand it back
	try {
		VARIANT_BOOL vUnused;
		aSet = mConfig->ReadConfiguration(file,&vUnused);
	}
	catch(_com_error& e) {
		return ReturnComError(e);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			WriteConfiguration
// Arguments:     IMTConfigPropSet**	- propset to be written to file
//								BSTR file	- file path to write propset to
// Return Value: 
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------


HRESULT CEnumConfig::WriteConfiguration(MTConfigLib::IMTConfigPropSet**	pSet, BSTR file)
{
	ASSERT(false);
	return E_NOTIMPL;

	/*
	HRESULT ret = S_OK;
	VARIANT_BOOL secure = VARIANT_FALSE;
	_bstr_t bstrFile = file;
	_bstr_t bstrFullPath = L"";

		//If host variable is set, then set full path to relative dir + file
		if(mHost != _bstr_t(L""))
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Writing remotely to %s", (const char*)mHost );
			bstrFullPath = mRelativePath + file;
			
			//if file == NULL, then write to master file
			if (file == NULL || (_bstr_t(file).length() == 0) )
			{
				if (mbInitWithName)
					bstrFullPath = mMasterFileName;
				else
					bstrFullPath = mRelativePath + mMasterFileName;
				

				mLogger.LogVarArgs(LOG_DEBUG, "Writing master file \"%s\" to %s",
													(const char*)bstrFullPath, (const char*)mHost );
			}
			else
			{
				
				
				bstrFile = file;
				bstrFullPath = mRelativePath + file;
				mLogger.LogVarArgs(LOG_DEBUG, "Writing file \"%s\" to %s",
													(const char*)bstrFullPath, (const char*)mHost );
			}

			try
			{

				ret = (*pSet)->WriteToHost(mHost, bstrFullPath, L"", L"", secure, VARIANT_TRUE);
				return ret;
			}
			catch(_com_error err)
			{
				mLogger.LogVarArgs(LOG_ERROR, "Failed to write Configuration Set to host \"%s\", file \"%s\", error <%s>", 
														(const char*)mHost, (const char*)bstrFullPath, (const char*)err.Description());
				return ReturnComError(err);
			}
		}
		else
		{
			//if file == NULL, then write to master file
			if (file == NULL || (_bstr_t(file).length() == 0) )
			{
				
				if(IsFullPath(mMasterFileName))
					bstrFullPath = mMasterFileName;
				else {
					bstrFullPath = mrwConfigDir.c_str() + mMasterFileName;
				}

				mLogger.LogVarArgs(LOG_DEBUG, "Writing master file \"%s\" locally",
													(const char*)bstrFullPath);
			}
			else
			{
				//Quick hack to be able to read full path
				if (!IsFullPath(bstrFile))
					bstrFullPath = mrwConfigDir.c_str() + bstrFile;
				else
					bstrFullPath = bstrFile;
				mLogger.LogVarArgs(LOG_DEBUG, "Writing file \"%s\" locally",
													(const char*)bstrFullPath);
			}
			try
			{
				ret = (*pSet)->Write(bstrFullPath);
				return ret;
			}
			catch(_com_error err)
			{
				mLogger.LogVarArgs(LOG_ERROR, "Failed to write Configuration Set to file \"%s\", error <%s>", 
														(const char*)bstrFullPath, (const char*)err.Description());
				return ReturnComError(err);
			}
		}
		*/
}

// ----------------------------------------------------------------
// Name:     			LoadEnumeration
// Arguments:     BSTR file_path	- file where enumeration is defined
// Return Value: 
// Raised Errors:
// Description:		Adds and enumeration read from file to internal collection
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::LoadEnumeration(BSTR from_file_path)
{
		return Read(from_file_path);
}


// ----------------------------------------------------------------
// Name:     			InitializeWithFileName
// Arguments:     BSTR 	master_file - full path to master file
//								BSTR	host_name		-	optional host name
// Return Value: 
// Raised Errors:
// Description:		INitializes internal collections give master file name and/or host name
// ----------------------------------------------------------------

/*
This method is provided to initialize the object by given master file full path and name
*/
STDMETHODIMP CEnumConfig::InitializeWithFileName(BSTR master_file_full_path, VARIANT host_name)
{
	ASSERT(false);
	return E_NOTIMPL;
	/*
	HRESULT hr = S_OK;
	EnumFileList fileList;
	_variant_t varHost = host_name;
	_bstr_t bstrFullPath = master_file_full_path;

	
	if	(host_name.vt != VT_ERROR)
	{
		mHost = _bstr_t(varHost);
	}

	else if(!IsFullPath(bstrFullPath))
	{
		char buf[512];
		sprintf(buf, "Not a full path ot file does not exist: <%s>", (const char*)bstrFullPath);
		mLogger.LogVarArgs(LOG_ERROR, buf);
		return Error(buf, IID_IEnumConfig, E_FAIL);
	}
	
	mbInitWithName = TRUE;
	mMasterFileName = bstrFullPath;
	mRelativePath = GetSubDirs(master_file_full_path);
	mrwConfigDir = mRelativePath;
	
	return Initialize(_variant_t(mMasterFileName));
	*/
}

// ----------------------------------------------------------------
// Name:     			EnumerateFQN
// Arguments:     
// Return Value: 
// Raised Errors:
// Description:		Sets internal iterator to collection begin
// ----------------------------------------------------------------


STDMETHODIMP CEnumConfig::EnumerateFQN()
{
	AutoCriticalSection alock(&mLock);

	mIterator = mpEnumTypeMap->begin();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			NextFQN
// Arguments:			
// Return Value:	BSTR*				- Return Next FQN in the collection	   
// Raised Errors:
// Description:		Return Next FQN in the collection
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::NextFQN(BSTR *fqn)
{
	
	AutoCriticalSection alock(&mLock);

	if (mIterator != mpEnumTypeMap->end())
	{
		string nm = ((*mIterator).second)->GetFQNString();
		_bstr_t bStrRet(nm.c_str());
		*fqn = bStrRet.copy();
		mIterator++;
		return S_OK;
	}
	else
	{
		//should never get here
		mLogger.LogThis(LOG_ERROR, "Iterator passed collection end!");
		return E_FAIL;
	}
}

// ----------------------------------------------------------------
// Name:     			FQNCollectionEnd
// Arguments:			
// Return Value:	int*	-		return code
// Raised Errors:
// Description:		Did internal iterator hit collections end?
// ----------------------------------------------------------------

STDMETHODIMP CEnumConfig::FQNCollectionEnd(int *pVal)
{
	if(!mpEnumTypeMap)
		return E_FAIL;
	
	AutoCriticalSection alock(&mLock);

	(*pVal) = (mIterator == mpEnumTypeMap->end());
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			FQNCount
// Arguments:			
// Return Value:	int*				- number of elements in the collection
// Raised Errors:
// Description:		number of elements in the collection
// ----------------------------------------------------------------
STDMETHODIMP CEnumConfig::FQNCount(int *pVal)
{
	if(!mpEnumTypeMap)
		return E_FAIL;
	
	AutoCriticalSection alock(&mLock);
	
	(*pVal) = mpEnumTypeMap->size();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetEnumeratorByID
// Arguments:			long				-		value from t_enum_data table
// Return Value:	BSTR*				- Enumerator string
// Raised Errors:
// Description:		Looks up an fqn using NameId object and then gets enumerator part from it
// ----------------------------------------------------------------
STDMETHODIMP CEnumConfig::GetEnumeratorByID(long aID, BSTR* aEnum)
{
	HRESULT hr(S_OK);

	try {

		//checks to see if it is the null enum id and returns a blank string
		//this represents a non-required enum that was not metered
		if (aID == 0) 
		{
			*aEnum = _bstr_t("").copy(); // a blank string is returned
			return hr;
		}

		char buf[255];
		string name;
		EnumTypeMap::iterator it;
		_bstr_t fqn = _wcslwr(mNameIDPtr->GetName(aID));
		
		AutoCriticalSection alock(&mLock);
		
		it = mpEnumTypeMap->find((const char*)fqn);
		
		
		if (it == mpEnumTypeMap->end())
		{
			sprintf(buf, "<%s> is not a valid enumerator!", (const char*)fqn);
			mLogger.LogThis (LOG_ERROR, buf);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_NOT_A_VALID_ENUMERATOR);
		}
		else
		{
			name = ((*it).second)->GetEnumName();
			(*aEnum) = _bstr_t(name.c_str()).copy();
		}
	}
	catch (_com_error& e)
	{
		char buf[1024];
		hr = e.Error();
		_bstr_t desc = e.Description();
		sprintf(buf, "Unable to look up enumerator by ID! Error = <%x>, Description = <%s>", hr, (const char*)desc);
		mLogger.LogVarArgs(LOG_ERROR, buf);
		return Error(buf, IID_IEnumConfig, hr);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     			GetEnumeratorValueByID
// Arguments:			long				-		value from t_enum_data table
// Return Value:	BSTR*				- Enumerator string
// Raised Errors:
// Description:		Looks up an fqn using NameId object and then gets enumerator part from it
// ----------------------------------------------------------------
STDMETHODIMP CEnumConfig::GetEnumeratorValueByID(long aID, BSTR* aValue)
{
	HRESULT hr(S_OK);
	char buf[255];
	string value;
	EnumTypeMap::iterator it;
	CEnumerator* obj;
	_bstr_t fqn;

	//TODO: add null enum logic
	
	try
	{
		fqn = _wcslwr(mNameIDPtr->GetName(aID));
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	AutoCriticalSection alock(&mLock);

	it = mpEnumTypeMap->find((const char*)fqn);
	if (it == mpEnumTypeMap->end())
	{
		sprintf(buf, "<%s> is not a valid enumerator!", (const char*)fqn);
			mLogger.LogThis (LOG_ERROR, buf);
		return Error(buf, IID_IEnumConfig, MTENUMCONFIG_NOT_A_VALID_ENUMERATOR);
	}
	else
	{
		obj = (*it).second;
		if (!obj->NumValues())
		{
			sprintf(buf, "<%s> enumerator has no values!", (const char*)fqn);
			mLogger.LogThis (LOG_ERROR, buf);
			return Error(buf, IID_IEnumConfig, MTENUMCONFIG_ENUMERATOR_HAS_NO_VALUES);
		}
		
		value = obj->ValueAt(0);
		(*aValue) = _bstr_t(value.c_str()).copy();
	}

	return hr;
}


