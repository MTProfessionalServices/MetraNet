/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <PropValType.h>
#include <vector>

//shouldn't need it anymore: Syscontext object aggregates IEnumConfig interface
//#import <MTEnumConfig.tlb>


// {58ABA600-0BB7-11d4-99EF-00C04F6DC482}
CLSID CLSID_MTEnumtl = { 0x58aba600, 0xbb7, 0x11d4, { 0x99, 0xef, 0x0, 0xc0, 0x4f, 0x6d, 0xc4, 0x82 } };



/////////////////////////////////////////////////////////////////////////////
// MTEnumtl
/////////////////////////////////////////////////////////////////////////////


class IDMAP
{
public:
	IDMAP(){};
	~IDMAP(){};
	IDMAP(_bstr_t tnamespace, _bstr_t tenum, _bstr_t t1, long t2) {
		mnamespace = tnamespace;
		menum = tenum;
		sID = t1;
		nID = t2;
	}
	long GetnID(){ return nID;}
	_bstr_t GetNamespaceID() { return mnamespace;}
	_bstr_t GetEnumID(){return menum;}
	_bstr_t GetsID() { return sID;}
	void SetsID(_bstr_t t) { sID = t;} 
	void SetnID( long t) { nID = t;}
	void SetNamespaceID(_bstr_t t) { mnamespace = t;} 
	void SetEnumID(_bstr_t t){menum = t;}
	long nID;
	_bstr_t mnamespace;
	_bstr_t menum;
	_bstr_t sID;

};


#if 0
class IDMAP
{
public:
	IDMAP(){};
	~IDMAP(){};
	IDMAP(_bstr_t t1, long t2) {
		sID = t1;
		nID = t2;
	}
	long GetnID(){ return nID;}
	_bstr_t GetsID() { return sID;}
	void SetnID( long t) { nID = t;}
	void SetsID(_bstr_t t) { sID = t;} 
	long nID;
	_bstr_t sID;
};
#endif


typedef std::vector<IDMAP> IDMAPVECTOR;


bool operator==(const IDMAP & x, const IDMAP & y)
{
	return x.nID == y.nID;
}

class ATL_NO_VTABLE MTEnumtl
	: public MTPipelinePlugIn<MTEnumtl, &CLSID_MTEnumtl>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: 

private: // data
	MTPipelineLib::IMTLogPtr mLogger;
	
	
	//IEnumConfig interface belongs to MTPipelineLib library
	//MTENUMCONFIGLib::IEnumConfigPtr enumType;
	MTPipelineLib::IEnumConfigPtr mEnumConfig;

	IDMAPVECTOR mIDMAPvector;
	MTPipelineLib::IMTNameIDPtr mNameID;

};


PLUGIN_INFO(CLSID_MTEnumtl, MTEnumtl,
						"MTPipeline.MTEnumtl.1", "MTPipeline.MTEnumtl", "Free")

/////////////////////////////////////////////////////////////////////////a////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSubStr::PlugInConfigure"
HRESULT MTEnumtl::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	
	mLogger = aLogger;
	//HRESULT hr;
	char buffer[1024];
	mNameID = aNameID;
	// Initialize enumtype object.

//Instead of creating an instance and initializing it here, get the interface pointer from syscontext argument
#if 0
	hr = enumType.CreateInstance("Metratech.MTEnumConfig.1");	
	if(!SUCCEEDED(hr))
	{
		sprintf(buffer, "Create the EnumType failed, Error code is %d", hr);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
		return Error(buffer);
	}
	hr = enumType->Initialize();
	if(!SUCCEEDED(hr))
	{
		sprintf(buffer, "ERROR: unable to initialize enum type, Error code is %d", hr);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
		return Error(buffer);
	}
#endif

	try
	{
		mEnumConfig = aSysContext->GetEnumConfig();
	}
	catch(_com_error e)
	{
		sprintf(buffer, "Enumtl plugin: unable to get IEnumConfig pointer from IMTSystemContext");
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
		return ReturnComError(e);
	}

	_bstr_t tag("enumitem");
	_bstr_t bstr_temp_namespace;
	_bstr_t bstr_temp_enum;
	_bstr_t bstr_temp;
	long long_temp;

	try 
	{
		MTPipelineLib::IMTConfigPropSetPtr aProp;
		aProp = aPropSet->NextSetWithName(tag);

		while(aProp!=NULL)
		{
			if(aProp->NextMatches("Namespace", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
				bstr_temp_namespace = aProp->NextStringWithName("Namespace");
			else
				bstr_temp_namespace = L"";

			if(aProp->NextMatches("Enum", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
				bstr_temp_enum = aProp->NextStringWithName("Enum");
			else
				bstr_temp_enum = L"";
			
			bstr_temp = aProp->NextStringWithName("Name");

			long_temp = aNameID->GetNameID(bstr_temp);

			mIDMAPvector.push_back(IDMAP(bstr_temp_namespace, bstr_temp_enum, bstr_temp, long_temp));				

			aProp = aPropSet->NextSetWithName(tag);
		}
	}
	catch (_com_error err)
	{
			const char *errmsg = "Fail to build the enum name list.";
			return Error(errmsg);
	}
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTEnumtl::PlugInProcessSession"
HRESULT MTEnumtl::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	long ServiceID = aSession->GetServiceID();
	_bstr_t enum_space; 
	_bstr_t enum_name;
	_bstr_t enum_value;
	_bstr_t FQN;
	long nVal;
	const char * temp;
	IDMAPVECTOR::iterator theIterator;
	for (theIterator = mIDMAPvector.begin(); theIterator != mIDMAPvector.end(); theIterator++)
	{

		temp = (const char * ) theIterator->GetNamespaceID();
		if(stricmp(temp, ""))
			enum_space = theIterator->GetNamespaceID();
		else
			enum_space = mNameID->GetName(ServiceID);

		temp = (const char *)  theIterator->GetEnumID();
		if(stricmp(temp, ""))
			enum_name = theIterator->GetEnumID();
		else
			enum_name = theIterator->GetsID();
			nVal = theIterator->GetnID();
		try
		{	
			temp = (const char *) enum_name;
			if(!stricmp(temp, "Servicelevel"))
				enum_value = aSession->GetLongProperty(nVal);
			else
				enum_value = aSession->GetStringProperty(nVal);
		} 
		catch (_com_error err)
		{
			_bstr_t errmsg = enum_name + " property is not in the session.";
			return Error((const char *)errmsg);
		}	

		try
		{
			FQN = mEnumConfig->GetFQN(enum_space, enum_name, enum_value);
			aSession->SetEnumProperty(nVal, mNameID->GetNameID(FQN));
		}
		catch (_com_error err)
		{
			_bstr_t errmsg = enum_name + "\\" + enum_value + " property isn't found in the EnumType xml file in the namespace " + enum_space + ".";
			return Error((const char *)errmsg);
		}
	}	
		temp = NULL;	
		return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTEnumtl::PlugInShutdown()
{
	
	return S_OK;
}
