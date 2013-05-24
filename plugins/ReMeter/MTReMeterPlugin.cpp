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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

//#include <iostream>
//using namespace std;

#include <metralite.h>
#include <PlugInSkeleton.h>
#include <stdio.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <mtcomerr.h>
#include <vector>

#include <XMLset.h>
#include <mtsdk.h>
#include <errobj.h>
#include <MTDec.h>
#include <ServicesCollection.h>
#include <stdutils.h>

#define I_WANT_WONDERFUL_STATIC_LIST_OF_GREAT_RESERVED_PROPS
#include <reservedproperties.h>

#import <MTServerAccess.tlb>
#import <COMMeter.tlb>

#define MAX __max



//////////////////////////////////////////////////////////////////////////////////////
// global constants
//////////////////////////////////////////////////////////////////////////////////////

const _bstr_t aStrType("string");
const _bstr_t aIntType("int32");
const _bstr_t aBigIntType("int64");
const _bstr_t aDoubleType("double");
const _bstr_t aTimeStampType("timestamp");
const _bstr_t aDecimalType("decimal");
const _bstr_t aEnumType("enum");
const _bstr_t aBoolType("bool");

//////////////////////////////////////////////////////////////////////////////////////
// ServiceItem class
//////////////////////////////////////////////////////////////////////////////////////

class ServiceItem {
public:

	ServiceItem() : bEncrypted(false),bOptional(false) {}
  _bstr_t mServiceTag;
  _bstr_t mSessionProp;
	MTPipelineLib::MTSessionPropType mServiceItemType;
	bool bEncrypted;
	bool bOptional;
	_bstr_t mEnumType;
	_bstr_t mEnumSpace;
};

bool operator==(ServiceItem a,ServiceItem b) { ASSERT(false); return false; }

typedef vector<ServiceItem> ServiceItemList;
typedef vector<long> PropIdsList;

// generate using uuidgen
//CLSID __declspec(uuid("242ffb20-2738-11d3-a5a4-00c04f579c39")) CLSID_MTReMeterPlugin

//////////////////////////////////////////////////////////////////////////////////////
// MTRemterPlugin class
//////////////////////////////////////////////////////////////////////////////////////

CLSID CLSID_MTReMeterPlugin = { /* 242ffb20-2738-11d3-a5a4-00c04f579c39 */
    0x242ffb20,
    0x2738,
    0x11d3,
    {0xa5, 0xa4, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE MTReMeterPlugin 
	: public MTPipelinePlugIn<MTReMeterPlugin, &CLSID_MTReMeterPlugin>
{
public:
  MTReMeterPlugin::MTReMeterPlugin() : mHttpMeter(NULL),mMeter(mHttpMeter), mSecure(false), mTransactional(false) {}

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
	virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);
	HRESULT LookupOptionalProperties();
	HRESULT ExportTransaction(MTPipelineLib::IMTSessionSetPtr aPipelineSessionSet,
													  MTMeterSessionSet* aRemeterSessionSet);


protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IEnumConfigPtr mEnumConfig;
	MTPipelineLib::IMTNameIDPtr mNameID;
	MTPipelineLib::IMTWhereaboutsManagerPtr mWhereaboutsMgr;

  _bstr_t aServiceName,mListenerStr;
  ServiceItemList mList;
	ServiceItemList mRemeterList;
  PropIdsList mPropIdsList,mFeedBackPropIdsList;
  bool mSecure,mbFeedbackRequested;
  _bstr_t mUserName;
  _bstr_t mUserPassword;

  MTMeterHTTPConfig mHttpMeter;
  MTMeter mMeter;

  long mRemeterProcessSession;
	_bstr_t mServerAccessEntry;

	bool mTransactional; //if true, target stage participates in transaction of originating stage
	int mRetries;

  // True if atleast one of the sessions in the set failed.
  bool mbSessionsFailed;
};

PLUGIN_INFO(CLSID_MTReMeterPlugin, MTReMeterPlugin,
						"MetraPipeline.MTReMeterPlugin.1", "MetraPipeline.MTReMeterPlugin", "Free")

//////////////////////////////////////////////////////////////////////////////////////
//MTServicePropMap
//////////////////////////////////////////////////////////////////////////////////////

class MTServicePropMap : public MTXMLSetRepeat {
public:

  MTServicePropMap(ServiceItemList& aList) : mList(aList),bError(false) {}
  void Iterate(MTXmlSet_Item aSet[]);
	bool GetError() { return bError; }
	_bstr_t& ErrorStr() { return aErrorStr; }

protected:
  ServiceItemList& mList;
	bool bError;
	_bstr_t aErrorStr;

};


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTServicePropMap::Iterate
// Description	    : 
// Return type		: void 
// Argument         : MTXmlSet_Item aSet[]
/////////////////////////////////////////////////////////////////////////////

void MTServicePropMap::Iterate(MTXmlSet_Item aSet[])
{
	// stop processing if we have allready encountered an error
	if(bError) {
		return;
	}

  ServiceItem aServiceItem;

  aServiceItem.mServiceTag = *aSet[0].mType.aBSTR;
  aServiceItem.mSessionProp = *aSet[1].mType.aBSTR;
	_bstr_t aTemp = *aSet[2].mType.aBSTR;

	// put it in the appropriate bucket
	if(aTemp == aStrType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_STRING;
	}
	else if(aTemp == aIntType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_LONG;
	}
	else if(aTemp == aBigIntType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_LONGLONG;
	}
	else if(aTemp == aDoubleType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_DOUBLE;
	}
	else if(aTemp == aTimeStampType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_DATE;
	}
	else if(aTemp == aDecimalType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_DECIMAL;
	}
	else if(aTemp == aEnumType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_ENUM;

		// check the attribset for the 
		//enumspace="metratech.com/audioconfconnection" enumtype="CallType"
		if(aSet[2].aAttribsSet == NULL) {
			bError = true;
			aErrorStr = "enumspace and enumtype attributes required for <type>enum</type> for property ";
			aErrorStr += aServiceItem.mSessionProp;
			return;
		}
		BSTR bstrTemp;
		if(FAILED(aSet[2].aAttribsSet->get_AttrValue(_bstr_t("enumspace"),&bstrTemp))) {
			bError = true;
			aErrorStr = "enumspace attribute not found on element <type>enum</type> for property ";
			aErrorStr += aServiceItem.mSessionProp;
			return;
		}
		else {
			aServiceItem.mEnumSpace = _bstr_t(bstrTemp,false);
		}
		if(FAILED(aSet[2].aAttribsSet->get_AttrValue(_bstr_t("enumtype"),&bstrTemp))) {
			bError = true;
			aErrorStr = "enumtype attribute not found on element <type>enum</type> for property ";
			aErrorStr += aServiceItem.mSessionProp;
			return;
		}
		else {
			aServiceItem.mEnumType = _bstr_t(bstrTemp,false);
		}
	}
	else if(aTemp == aBoolType) {
		aServiceItem.mServiceItemType = MTPipelineLib::SESS_PROP_TYPE_BOOL;
	}
	else {
		bError = true;
		aErrorStr = aTemp;
		aErrorStr += " is not a valid type";
		return;
	}

	// check if trailing underscore
	const char* pbuff = aServiceItem.mSessionProp;
	if(pbuff[aServiceItem.mSessionProp.length() -1] == '_') {
		aServiceItem.bEncrypted = true;
	}

  mList.push_back(aServiceItem);
}

HRESULT MTReMeterPlugin::LookupOptionalProperties()
{
	// step 1: create service collection
	CServicesCollection aServiceCol;
	if(!aServiceCol.Initialize()) {
		if(aServiceCol.GetLastError()) {
			return Error(aServiceCol.GetLastError()->GetProgrammerDetail().c_str());
		}
		else {
			return Error("Failed to initialize service collection");
		}
	}

	// step 2: lookup service def
	CMSIXDefinition* pDef;
	wstring aWideServiceName = aServiceName;
	if(!aServiceCol.FindService(aWideServiceName.c_str(),pDef)) {
			_bstr_t aTempStr = "WARNING *** failed to find service definition ";
			aTempStr += aServiceName;
			aTempStr += " ***  Remeter plugin may not work with optional properties";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,aTempStr);
			return S_OK;
	}
	
	// step 3: iterate through service def
  for(unsigned int i=0;i<mList.size();i++) {
		CMSIXProperties* pProperty;
		if(pDef->FindProperty((const wchar_t*)mList[i].mServiceTag,pProperty)) {
			// step 4: check if the property is optional and it has no default (i.e. the default is empty)
			if(!pProperty->GetIsRequired() && 
				pProperty->GetDefault().length() == 0) {
				mList[i].bOptional = true;
			}
		}
		else {
			// check the "special properties" list.  The is a list of properties
			// that can be attached to any service definition.  This include stuff like
			// _transactioncookie
			bool bFound = false;

			for(int j=0;ListOfSpecialProps[j][0] != '\0';j++) {
				if(stricmp(ListOfSpecialProps[j],mList[i].mServiceTag) == 0) {
					bFound = true;
					break;
				}
			}
			if(!bFound) {
				_bstr_t aTempStr = "Property ";
				aTempStr += mList[i].mServiceTag;
        aTempStr += " Does not exist in ";
        aTempStr += aWideServiceName.c_str();
        aTempStr += " Service Definition ";
				return Error((const char*)aTempStr);
			}
		}
	}

	return S_OK;
}

// Exports transaction from the pipeline's session set to the target server
// and sets the transactionID of the RemeterSessionSet
HRESULT MTReMeterPlugin::ExportTransaction(MTPipelineLib::IMTSessionSetPtr aPipelineSessionSet,
																					 MTMeterSessionSet* aRemeterSessionSet)
{
	HRESULT hr = S_OK;

	// step1: get transaction from the pipeline session set
  // (get in from the first session in lack of a GetTransaction method on the sessionSet)
	MTPipelineLib::IMTTransactionPtr transaction;
		
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	hr = it.Init(aPipelineSessionSet);
	if (FAILED(hr))
		return hr;
	
	MTPipelineLib::IMTSessionPtr firstSession = it.GetNext();
	if (firstSession == NULL)
		return Error("no session in set");

	transaction = firstSession->GetTransaction(VARIANT_TRUE);

	// step2: get whereabouts of target server
	_bstr_t whereabouts;
	
	// construct mWhereaboutsMgr first time needed
	if (mWhereaboutsMgr == NULL)
	{	hr = mWhereaboutsMgr.CreateInstance(MTPROGID_WHEREABOUTS_MANAGER);
		if(FAILED(hr))
			return hr;
	}

	// currently WhereAboutsMgr only supports ServerAccessEntries
	if(mServerAccessEntry.length() == 0)
		return Error("Transactional remetering requires ServerAccessEntry");

	_bstr_t msg = "Getting Whereabouts for server: " + mServerAccessEntry;
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);
		
	whereabouts = mWhereaboutsMgr->GetWhereaboutsForServer(mServerAccessEntry);
	
	//_bstr_t msg = "Whereabouts= " + whereabouts;
	//mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);


	// step 3: export the txn based on the whereabouts
	_bstr_t cookie = transaction->Export(whereabouts);

	msg = "Exported transaction. Cookie: " + cookie;
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);

	// step 4: set session set's transaction ID
	aRemeterSessionSet->SetTransactionID(cookie);

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTReMeterPlugin ::PlugInConfigure" 
HRESULT MTReMeterPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;
	mNameID = aNameID;
  HRESULT hr(S_OK);

  _bstr_t aRemeterServiceTagStr,aSessionPropStr,aServiceTypeStr;
  _bstr_t bstrProcessSession;
	long aAlternatePort = 0;
	mRetries = 10;

  // step 1: create definitions for the expected format of the XML

  MTServicePropMap aServiceProps(mList);
	MTServicePropMap aRemeterServiceProps(mRemeterList);

  DEFINE_XML_SET(ServiceSet)
    DEFINE_XML_STRING("ReMeterServiceTag",aRemeterServiceTagStr)
    DEFINE_XML_STRING("SessionProp",aSessionPropStr)
    DEFINE_XML_STRING("Type",aServiceTypeStr)
  END_XML_SET()

  DEFINE_XML_SET(XmlSet)
    DEFINE_XML_STRING("ServerAccessEntry",mServerAccessEntry)
    DEFINE_XML_STRING("Listener",mListenerStr)
    DEFINE_XML_BOOL("Secure",mSecure)
		DEFINE_XML_INT("AlternatePort",aAlternatePort)
    DEFINE_XML_STRING("MeterUserName",mUserName)
    DEFINE_XML_STRING("MeterUserPassword",mUserPassword)
		DEFINE_XML_BOOL("RequestFeedback",mbFeedbackRequested)
		DEFINE_XML_BOOL("Transactional",mTransactional)
		DEFINE_XML_OPTIONAL_INT("Retries",mRetries)
    DEFINE_XML_STRING("ServiceName",aServiceName)
    DEFINE_XML_STRING("RemeterProcessSession", bstrProcessSession)
    DEFINE_XML_REPEATING_SUBSET("ServiceProperties",ServiceSet,&aServiceProps)
    DEFINE_XML_OPTIONAL_REPEATING_SUBSET("FeedBackProperties",ServiceSet,&aRemeterServiceProps)
  END_XML_SET()

  // step 2: read service information
  MTLoadXmlSet(XmlSet,(IMTConfigPropSet*)aPropSet.GetInterfacePtr());

	// step : check for errors
	if(aServiceProps.GetError()) {
		return Error((const char*)aServiceProps.ErrorStr());
	}

	if(aRemeterServiceProps.GetError()) {
		return Error((const char*)aRemeterServiceProps.ErrorStr());
	}

	// step: verify Transactional requires ServerAccessEntry
	// (since WhereAboutsMgr only supports ServerAccessEntries)
	if(mTransactional && mServerAccessEntry.length() == 0)
		return Error("Transactional remetering requires ServerAccessEntry");

  // step 3: read the expected values from the session to populate the 
  // remetered session
  for(unsigned int i=0;i<mList.size();i++) {
    long aProp = aNameID->GetNameID(mList[i].mSessionProp);
    mPropIdsList.push_back(aProp);
  }
	// step 4: get the property Ids for the feed back
	for(i=0;i<mRemeterList.size();i++) {
		mFeedBackPropIdsList.push_back(aNameID->GetNameID(mRemeterList[i].mSessionProp));
	}

	// step 5: get the property that specifies if we are processing the session or not
  mRemeterProcessSession = aNameID->GetNameID(bstrProcessSession);

	// step 6: get the server access entry if one is specified
	if(mServerAccessEntry.length() > 0) {
		MTSERVERACCESSLib::IMTServerAccessDataSetPtr aServerAccess(MTPROGID_SERVERACCESS);
		aServerAccess->Initialize();
		try {
			MTSERVERACCESSLib::IMTServerAccessDataPtr aAccessSet = aServerAccess->FindAndReturnObject(mServerAccessEntry);
			mListenerStr = aAccessSet->GetServerName();
			mSecure = aAccessSet->GetSecure() == TRUE ? true : false;
			aAlternatePort = aAccessSet->GetPortNumber();
			mUserName = aAccessSet->GetUserName();
			mUserPassword = aAccessSet->GetPassword();
		}
		catch(_com_error&) {
			_bstr_t aTemp = "Failed to lookup serveraccess entry \"";
			aTemp += mServerAccessEntry;
			aTemp += "\"";
			aTemp += "; failing over to information specified in plugin configuration file";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,aTemp);
		}
	}

	// step 7: initialize the SDK
	
	if(SUCCEEDED(hr)) {
		if(!mMeter.Startup()) {
			hr =  Error("Failed to Initialize Meter object");
		}
		else {

			mHttpMeter.AddServer(0,					              // priority (highest)
				mListenerStr,				                    // hostname
				aAlternatePort == 0 ? 
					(mSecure ? MTMeterHTTPConfig::DEFAULT_HTTPS_PORT : MTMeterHTTPConfig::DEFAULT_HTTP_PORT) : aAlternatePort,
				mSecure,                                 // secure? (no)
				mUserName,		                          // username
				mUserPassword);	                        // password
		}
	}

	// step 8: cache an instance of the EnumConfig object
	mEnumConfig = aSysContext;

	// step 9: lookup optional properties in service def
	hr = LookupOptionalProperties();
  return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSessions
/////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTReMeterPlugin::PlugInProcessSessions"
HRESULT MTReMeterPlugin::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet) 
{
	HRESULT hr(S_OK);
  mbSessionsFailed = false;
  char buffer[1024];

  _bstr_t aStringVal;
  int aIntVal;
  __int64 aInt64Val;
  double aDoubleVal;
  time_t aTimeVal;
	MTDecimal aDecimal;
	BOOL aBooleanVal;
  MTPipelineLib::IMTSessionContextPtr ctx = NULL; 

  BOOL bPropsetSucceed(true);

  
	// gets an iterator for the set of sessions
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	hr = it.Init(aSet);
	if (FAILED(hr))
		return hr; 

  //get session context from original session set and propagate it to secondary session set
  //get the first session from the set, get sessioncontext off of it and reset iterator

 	MTPipelineLib::IMTSessionPtr session = it.GetNext();
  
  if(session != NULL)
    ctx = session->GetSessionContext();
  hr = it.Init(aSet);
	if (FAILED(hr))
		return hr; 
  
	//__int64 currentFetchTicks = mTotalFetchTicks;
	//LARGE_INTEGER freq;
	//LARGE_INTEGER tick;
	//LARGE_INTEGER tock;
	//::QueryPerformanceFrequency(&freq);
	
	// iterates through the session set
	//::QueryPerformanceCounter(&tick);
	int totalRecords = 0;
	vector<MTMeterSession*> sessionsInSet; 
  vector<MTPipelineLib::IMTSessionPtr> RemeteredSessionsInSet; 
	
	// Declare the session pointer and instantiate the sessionset
	// We will capture the incoming set of sessions, construct a new session set with the desired info,
	// then close the new session set to remeter in batch style
	MTMeterSessionSet * remeter_sessionset = mMeter.CreateSessionSet();
	MTMeterSession * remeter_session;
	
	
	// This is the beginning of the loop. We have to change it so:
	// 1-Sessions are created on a SessionSet
	// 2-All sessions on an input session are written to the new session
	// 3-The SessionSet is closed instead of the session
	// 4-In the end, we free the session set (or make it a smart pointer in the first place)
	while ((session = it.GetNext()) != NULL)  
	{
		//MTPipelineLib::IMTSessionPtr session = it.GetNext();
		// is this the last session in the set?
		//if (aSession == NULL) 
		//	break;
		
		totalRecords++;
		
		if (session->PropertyExists(mRemeterProcessSession,
																MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
		{
			bPropsetSucceed =
				session->GetBoolProperty(mRemeterProcessSession) == VARIANT_TRUE ? true : false;
    
		}
		else if (session->PropertyExists(mRemeterProcessSession,
																		 MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
		{
			bPropsetSucceed =
				session->GetLongProperty(mRemeterProcessSession) == 1 ? true : false;
		}
		else
			return Error("Failed to get RemeterProcessSession property!");

   if(bPropsetSucceed)
      sprintf(buffer, "Session %d in session set will be remetered", totalRecords);
   else
      sprintf(buffer, "Session %d in session set will not be remetered", totalRecords);
   mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

		
		if (!bPropsetSucceed)
		{
			// caller doesn't want this session metered. skip
			continue;
		}
		
		// step 1: create a session in SessionSet
		remeter_session = remeter_sessionset->CreateSession(aServiceName);
		// step 1a: Store this session for future use
		sessionsInSet.push_back(remeter_session);
    if (mbFeedbackRequested)
      RemeteredSessionsInSet.push_back(session);
		
		// step 2: read the properties from the session
		for(unsigned int i = 0; i < mList.size() && bPropsetSucceed; i++) {
			
			_bstr_t aDebugStr = mList[i].mServiceTag;
			// if the property is optional and not found in the session, continue
			if(mList[i].bOptional && 
				 session->PropertyExists(mPropIdsList[i],mList[i].mServiceItemType) != VARIANT_TRUE)
			{
				continue;
			}
			
			switch(mList[i].mServiceItemType) {
			case MTPipelineLib::SESS_PROP_TYPE_STRING:
				if(mList[i].bEncrypted) {
					aStringVal = session->DecryptEncryptedProp(mPropIdsList[i]);
				}
				else {
					aStringVal = session->GetStringProperty(mPropIdsList[i]);
				}
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,(const wchar_t *)aStringVal);
				break;
			case MTPipelineLib::SESS_PROP_TYPE_LONG:
			{
				aIntVal = session->GetLongProperty(mPropIdsList[i]);
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,aIntVal);
			}
      break;
			case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
			{
				aInt64Val = session->GetLongLongProperty(mPropIdsList[i]);
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,aInt64Val,MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
			}
      break;
			case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
			{
				aDoubleVal = session->GetDoubleProperty(mPropIdsList[i]);
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,aDoubleVal);
			}
      break;
			case MTPipelineLib::SESS_PROP_TYPE_DATE:
			{
				aTimeVal = session->GetDateTimeProperty(mPropIdsList[i]);
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,aTimeVal,MTMeterSession::SDK_PROPTYPE_DATETIME);
			}
			break;
			case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
			{
				aDecimal = session->GetDecimalProperty(mPropIdsList[i]);
				MTDecimalValue aTempDecimalVal;
				aTempDecimalVal.SetValue(aDecimal.Format().c_str());
				remeter_session->InitProperty(mList[i].mServiceTag,&aTempDecimalVal);
			}
			break;
			case MTPipelineLib::SESS_PROP_TYPE_ENUM:
			{
				aStringVal = mEnumConfig->GetEnumeratorByID(session->GetEnumProperty(mPropIdsList[i]));
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,(const wchar_t *)aStringVal);
			}
			break;
			case MTPipelineLib::SESS_PROP_TYPE_BOOL:
				// get the value from the session as a boolean.  Convert it to a string of Y or N.
			{
				aBooleanVal = session->GetBoolProperty(mPropIdsList[i]);
				bPropsetSucceed = remeter_session->InitProperty(mList[i].mServiceTag,aBooleanVal,MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			}
				break;
			default:
				// really shouldn't get here... this should fail in Configure
				_bstr_t aTemp = "Unknown type of session property requested";
				ASSERT(!(const char*)aTemp);
				delete remeter_sessionset;
				return Error((const char*)aTemp);
			} // end switch

			if(!bPropsetSucceed)
			{
        std::auto_ptr<MTMeterError> err(remeter_session->GetLastErrorObject());

        char buffer[1024] = "";
      	int size = sizeof(buffer);
				err->GetErrorMessageEx(buffer, size);
		
				// this error handling could be better
				// now we're quitting all.
				delete remeter_sessionset;
				return Error(buffer);
			}

		} // end for
		
		// step 3: set the feedback (synchronous metering) property
		remeter_session->SetRequestResponse(mbFeedbackRequested);

	} // Close while loop
	

	//check for empty result set
	if (sessionsInSet.size() == 0)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "no sessions to meter");
		hr = S_OK;
	}
	else
	{
		// if remetering transactionally,
		// export transaction to the target server and set sessionset's transaction ID
		if (mTransactional)
      hr = ExportTransaction(aSet, remeter_sessionset);
		else
			hr = S_OK;

		if (SUCCEEDED(hr))
		{
			//set original session context on the set
      //of session context
      if (ctx != NULL)
        remeter_sessionset->SetSessionContext((char*)ctx->ToXML());

			hr = S_OK;
			int retry;
			for (retry = 0; retry < mRetries; retry++)
			{
				// send the sessionset to the server
				if (!remeter_sessionset->Close())
				{
          std::auto_ptr<MTMeterError> err(remeter_sessionset->GetLastErrorObject());
          hr = HRESULT_FROM_WIN32(err->GetErrorCode());
					if (err->GetErrorCode() == MT_ERR_SYN_TIMEOUT)
					{
						sprintf(buffer, "Timeout waiting for response on attempt %d... retrying", retry + 1);
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buffer);
					}
					else if (err->GetErrorCode() == MT_ERR_SERVER_BUSY)
					{
						sprintf(buffer, "Server busy on attempt %d... retrying", retry + 1);
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buffer);
					}
	        else
          {
		        char buffer[1024] = "";
            int size = sizeof(buffer);
						err->GetErrorMessageEx(buffer, size);

					  if(strcmp(buffer, "") == 0)
  					  sprintf(buffer, PROCEDURE ": session->Close() failed with error %x", err->GetErrorCode());
            else
              sprintf(buffer, "%s, error %x", buffer, err->GetErrorCode());

            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buffer);
            hr = S_OK;  // Check for partial session set failure.
            break;
					}
				}
				else
				{
					hr = S_OK;
					break;
				}
			}

			if (FAILED(hr) && retry == mRetries)
			{
				buffer[0] = 0;
				sprintf(buffer, PROCEDURE ": timeout after %d attempts", mRetries);
				hr = Error(buffer, IID_IMTPipelinePlugIn, hr);
			}

			// For now, all sessions in a session set are either synchronous or asynchronous
			// If feedback is requested, read properties and dump into session
			if (SUCCEEDED(hr) && mbFeedbackRequested)
			{
				for (unsigned long set_index = 0; set_index < RemeteredSessionsInSet.size(); set_index++)
				{
					remeter_session = sessionsInSet[set_index];
          session = RemeteredSessionsInSet[set_index];

          // Check for error.
          std::auto_ptr<MTMeterError> err(remeter_session->GetLastErrorObject());
          HRESULT returnCode = err.get() ? HRESULT_FROM_WIN32(err->GetErrorCode()) : S_OK;

          // Mark session with error code as appropriate.
					if (FAILED(returnCode))
          {
            // All sessions in set that didn't fail get marked with PIPE_ERR_CANNOT_AUTO_RESUBMIT.
             if (err->GetErrorCode() != PIPE_ERR_CANNOT_AUTO_RESUBMIT)
             {
              // Partial session failue.
              mbSessionsFailed = true;

		          char buffer[1024] = "";
              int size = sizeof(buffer);
						  err->GetErrorMessageEx(buffer, size);

						  if (strcmp(buffer, "") == 0)
              {
                sprintf(buffer, "Session %d failed with error %x", session->GetSessionID(), returnCode);
                mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
              }
              else
              {
                char buffer2[1024] = "";
                sprintf(buffer2, "Session %d failed with error: \"%s\"", session->GetSessionID(), buffer);
                mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer2);
              }

              session->MarkAsFailed(buffer, returnCode);
              mbSessionsFailed = true;
             }

            continue;
          }
          else  // success case
          {
            // Get success results.
            MTMeterSession* results = remeter_session->GetSessionResults();
					  if(results == NULL)
					  {
              ASSERT(0);
						  delete remeter_sessionset;
						  return Error("no results");
					  }

					  // Iterate through properties, pull them out and dump them into the session
            BOOL bRes = FALSE;
					  for (unsigned int i = 0; i < mRemeterList.size() && bPropsetSucceed; i++)
					  {
              char errorbuf[1024];
              sprintf(errorbuf, "Failed to get session property '%s'", (char*)mRemeterList[i].mServiceTag);
						  switch(mRemeterList[i].mServiceItemType) 
						  {
							  case MTPipelineLib::SESS_PROP_TYPE_STRING:
							  {
								  const wchar_t* pTemp;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,&pTemp);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
								  session->SetStringProperty(mFeedBackPropIdsList[i],pTemp);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_LONG:
							  {
							    int aTemp;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,aTemp,MTMeterSession::SDK_PROPTYPE_INTEGER);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
								  session->SetLongProperty(mFeedBackPropIdsList[i],aTemp);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
							  {
							    __int64 aTemp;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,aTemp,MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
								  session->SetLongLongProperty(mFeedBackPropIdsList[i],aTemp);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
							  {
								  double aTemp;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,aTemp);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
								  session->SetDoubleProperty(mFeedBackPropIdsList[i],aTemp);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_DATE:
							  {
								  time_t aTime;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,aTime,MTMeterSession::SDK_PROPTYPE_DATETIME);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
                  DATE dt;
                  ::OleDateFromTimet(&dt, aTime);
								  session->SetOLEDateProperty(mFeedBackPropIdsList[i],dt);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
							  {
								  const MTDecimalValue * pTempValue;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag, &pTempValue);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
								  // have to call the constructor to set the value from MTDecimalVal.
								  MTDecimal aDecimal(*pTempValue);
								  _variant_t aTempVar((DECIMAL)aDecimal);
								  session->SetDecimalProperty(mFeedBackPropIdsList[i],aTempVar);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_ENUM:
							  {
							    const wchar_t* pTemp;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,&pTemp);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
 								  long aEnumID  = mEnumConfig->GetID(mRemeterList[i].mEnumSpace,mRemeterList[i].mEnumType,pTemp);
								  session->SetEnumProperty(mFeedBackPropIdsList[i],aEnumID);
							  }
							  break;
							  case MTPipelineLib::SESS_PROP_TYPE_BOOL:
							  {
								  BOOL aTempBool;
								  bRes = results->GetProperty(mRemeterList[i].mServiceTag,aTempBool,MTMeterSession::SDK_PROPTYPE_BOOLEAN);
                  if(bRes == false)
                    MT_THROW_COM_ERROR(errorbuf);
                  VARIANT_BOOL varbool = aTempBool ? VARIANT_TRUE : VARIANT_FALSE;
								  session->SetBoolProperty(mFeedBackPropIdsList[i],varbool);
							  }
							  break;
							  default:
							  {
								  // really shouldn't get here... should catch these during configure
								  _bstr_t aTemp = "Unknown type found during while processing results from synchronous metering";
								  ASSERT(!(const char*)aTemp);
								  return Error((const char*)aTemp);
							  }
						  }
					  }
          }
        }
			}
		}
	}

	// Deallocate the session set. Internally it will dealocate all sessions
	delete remeter_sessionset;
  return (mbSessionsFailed) ? PIPE_ERR_SUBSET_OF_BATCH_FAILED : hr;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
 
#pragma warning (disable : 4800)

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTReMeterPlugin::PlugInProcessSession"
HRESULT MTReMeterPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	return E_NOTIMPL;
}

#pragma warning (default : 4800)
