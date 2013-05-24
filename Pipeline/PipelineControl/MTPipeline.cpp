// MTPipeline.cpp : Implementation of CMTPipeline
#include "StdAfx.h"
#include "PipelineControl.h"
#include "MTPipeline.h"

#include <mtglobal_msg.h>

#include <loggerconfig.h>

#include <pipeconfigutils.h>
#include <mtprogids.h>

#include "controlutils.h"

#include <mtcomerr.h>

#include <propids.h>
#include <SetIterate.h>

#include <stdutils.h>

#include <ConfigDir.h>
#include <multiinstance.h>
#include <makeunique.h>
#include <MTDec.h>
#include <set>

#include <audit.h>
#include <errutils.h>
#include <autocritical.h>

#import <GenericCollection.tlb>
#import <MTServerAccess.tlb>


using namespace MTConfigLib;


/////////////////////////////////////////////////////////////////////////////
// CMTPipeline

STDMETHODIMP CMTPipeline::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPipeline,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPipeline::FinalConstruct()
{
	return Init();
}

CMTPipeline::CMTPipeline()
	: mLoggerInitialized(FALSE),
		mGeneratorInitialized(FALSE),
		mConfigurationRead(FALSE),
		mUtilsInitialized(FALSE),
		mParserInitialized(FALSE),
		mRoutingQueuesInitialized(FALSE)
{ }

HRESULT CMTPipeline::Init()
{
	mLoggerInitialized = FALSE;
	mGeneratorInitialized = FALSE;
	mConfigurationRead = FALSE;
	mUtilsInitialized = FALSE;

	return S_OK;
}


/******************************************** public methods ***/

STDMETHODIMP CMTPipeline::get_SessionFailures(IMTSessionFailures * * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Return an initialized session server object.
// Return Value:  the intialized session server.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::get_SessionServer(IMTSessionServer * * server)
{
	try
	{

		HRESULT hr = InitializeLogger();
		if (FAILED(hr))
			return hr;

		if (!mGeneratorInitialized)
		{
			hr = InitializeGenerator();
			if (FAILED(hr))
				return hr;
		}

		*server = (IMTSessionServer *) (MTPipelineLib::IMTSessionServer *) mSessionServer;
		(*server)->AddRef();
	}
	catch (_com_error err)
	{ return ReturnComError(err); }

	return S_OK;
}


// ----------------------------------------------------------------
// Description:   Parse a session out of its XML representation.
//                Return the session as a session object.
// Arguments:     xml - the XML representation of the session
// Return Value:  full MSIX message
// Errors Raised: PIPE_ERR_INVALID_SESSION, if session ID cannot be found.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::ExamineSession(BSTR xml,
																				 /*[out, retval]*/ IMTSession * * session)
{
	try
	{
		MTPipelineLib::IMTSessionSetPtr sessionSet;
		HRESULT hr = ExamineSessions(xml, (::IMTSessionSet * *) &sessionSet);
		if (FAILED(hr))
			return hr;

		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> sessionit;
		hr = sessionit.Init(sessionSet);
		if (FAILED(hr))
			return hr;
	
		MTPipelineLib::IMTSessionPtr parentSessionObj = sessionit.GetNext();

		if (parentSessionObj == NULL)
		{
			// shouldn't happen because ExamineSessions should fail in this case
			ASSERT(0);
			return Error("No parent sessions found");
		}

		*session = (IMTSession *) parentSessionObj.GetInterfacePtr();
		(*session)->AddRef();
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;

}


// ----------------------------------------------------------------
// Description:   Parse a session out of its XML representation.
//                Return the session as a session object.
// Arguments:     xml - the XML representation of the session
// Return Value:  full MSIX message
// Errors Raised: PIPE_ERR_INVALID_SESSION, if session ID cannot be found.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::ExamineSessions(BSTR xml,
																				 /*[out, retval]*/ IMTSessionSet * * apSessionSet)
{
	try
	{
		HRESULT hr = InitializeLogger();
		if (FAILED(hr))
			return hr;

		hr = ReadConfiguration();
		if (FAILED(hr))
			return hr;

		//
		// parse the session
		//
		if (!mGeneratorInitialized)
		{
			hr = InitializeGenerator();
			if (FAILED(hr))
				return hr;
		}

		// parse the session(s)
		_bstr_t message(xml);
		SessionObjectVector sessions;
		unsigned char uid[16];
		int count;

		// generates sessions but ignores defaults, non-required props, and transactions 
		ValidationData validationData;
		if (!mGenerator.ParseAndGenerate(message,message.length(), sessions, NULL, uid, &count, validationData, TRUE, TRUE))
		{
			const ErrorObject * err = mGenerator.GetLastError();
			mLogger.LogErrorObject(LOG_ERROR, err);
			return err->GetCode();
		}

		MTPipelineLib::IMTSessionSetPtr sessionSet = mSessionServer->CreateSessionSet();

		string asciiMessageUID(validationData.mMessageID);
		unsigned char messageUID[16];
		MSIXUidGenerator::Decode(messageUID, asciiMessageUID);

		sessionSet->SetUID(messageUID);

		// find the parent sessions
		int parents = 0;
		for (int i = 0; i < (int) sessions.size(); i++)
		{
			MTPipelineLib::IMTSessionPtr sessionObj = sessions[i];

			if (sessionObj->GetParentID() == -1)
			{
				sessionSet->AddSession(sessionObj->GetSessionID(), sessionObj->GetServiceID());
				parents++;
			}
		}

		if (parents == 0)
			return Error("No parent sessions found");

		// set up the session context if necessary

		// the object owner ID is encoded.  If it's negative, it's a "temporary"
		// object owner that's owned by the session itself.  This is used in
		// cases where we need to generate a session outside of the context of
		// the pipeline.  We still need an object owner but the session has to clean
		// it up

		MTPipelineLib::IMTObjectOwnerPtr owner = NULL;
		if (validationData.mContextUsername[0] != '\0'
				&& validationData.mContextPassword[0] != '\0'
				&& validationData.mContextNamespace[0] != '\0')
		{
			owner = mSessionServer->CreateObjectOwner();

			// TODO: set username, password, namespace in object owner
			owner->PutSessionContextUserName(validationData.mContextUsername);
			owner->PutSessionContextPassword(validationData.mContextPassword);
			owner->PutSessionContextNamespace(validationData.mContextNamespace);
		}

		if (validationData.mpSessionContext)
		{
			owner = mSessionServer->CreateObjectOwner();

			// TODO: set username, password, namespace in object owner
			owner->PutSerializedSessionContext(validationData.mpSessionContext);
		}

		if (owner != NULL)
		{
			// this is a harmless way to initialize the object
			owner->InitForNotifyStage(0, 0);
			// set the (encoded) ID
			// 0->-2, 1->-3

			long encodedID = (- owner->Getid()) - 2;



			SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> sessionit;
			hr = sessionit.Init(sessionSet);
			if (FAILED(hr))
				return hr;
	
			while (TRUE)
			{
				MTPipelineLib::IMTSessionPtr session = sessionit.GetNext();
				if (session == NULL)
					break;

				session->PutObjectOwnerID(encodedID);

				// the session now references "owner"
				owner->IncreaseSharedRefCount();
			}

			owner = NULL;
		}

		*apSessionSet = (IMTSessionSet *) sessionSet.GetInterfacePtr();
		(*apSessionSet)->AddRef();
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;

}



// ----------------------------------------------------------------
// Description:   return the original MSIX message from routing queue
//                journal for a session, given the session ID.
// Arguments:     sessionID - base64 encoded session UID.  Must be the ID of the
//                            root session if a compound.
// Return Value:  full MSIX message.
// Errors Raised: PIPE_ERR_INVALID_SESSION, if session ID cannot be found.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::GetLostMessage(BSTR messageID,
																				 /*[out, retval]*/ BSTR * message)
{
	try
	{
		HRESULT hr = InitializeLogger();
		if (FAILED(hr))
			return hr;

		hr = ReadConfiguration();
		if (FAILED(hr))
			return hr;

		std::string messageBuffer;
		hr = GetMeteredMessageInternal(messageID, messageBuffer);
		if (FAILED(hr))
			return hr;

		// NOTE: we have to construct the BSTR manually.  if we rely
		// on the _bstr_t constructor and pass in a large string the
		// program will crash with a stach exception.
		// See CMTConfigPropSet::WriteToBuffer for more info
		USES_CONVERSION;
		BSTR rawBSTRBuffer = A2BSTR(messageBuffer.c_str());
		// attach to it so it will get cleanup up even on an exception
		_bstr_t bstrBuffer(rawBSTRBuffer, false);

		*message = bstrBuffer.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   calculate the list of "lost" sessions, returning a collection
//                of UIDs.
// Return Value:  collection of UID strings.  These messages are in the
//                routing queue journal but not the audit queue
// ----------------------------------------------------------------

STDMETHODIMP CMTPipeline::GetLostSessions(
	/*[out, retval]*/ IMTCollection * * sessions)
{
	try
	{
		GENERICCOLLECTIONLib::IMTCollectionPtr coll(MTPROGID_MTCOLLECTION);

		MTAuditor auditor;

		auditor.Init(TRUE);
		std::list<std::string> uids;
		if (!auditor.FindLostSessions(uids, 1000))
		{
			string buffer;
			StringFromError(buffer, "Auditing failed", auditor.GetLastError());
			return Error(buffer.c_str());
		}

		std::list<std::string>::iterator it;
		for (it = uids.begin(); it != uids.end(); it++)
		{
			_bstr_t uid(it->c_str());
			_variant_t varUid(uid);
			coll->Add(varUid);
		}

		*sessions = (IMTCollection *) coll.Detach();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Generate an autosdk format file from any session object.
//                This method can be used to edit and resubmit failed sessions.
// Arguments:     session - Session object.
// Return Value:  contents of autosdk file.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::ExportSession(/*[in]*/ IMTSession * apSession,
																				/*[out, retval]*/ BSTR * buffer)
{
	try
	{
		HRESULT hr = InitializeLogger();
		if (FAILED(hr))
			return hr;
		hr = ReadConfiguration();
		if (FAILED(hr))
			return hr;

		IMTConfigPtr config(MTPROGID_CONFIG);
		IMTConfigPropSetPtr topSet = config->NewConfiguration("xmlconfig");

		MTPipelineLib::IMTSessionPtr session(apSession);


		hr = ExportSessionToPropSet(topSet, session);
		if (FAILED(hr))
			return hr;

		topSet->raw_WriteToBuffer(buffer);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Returns the fully qualified configuration directory.
//                This method takes into account multi-instance configurations.
// Return Value:  fully qualified configuration directory.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::get_ConfigurationDirectory(/*[out, retval]*/ BSTR * dir)
{
	std::string configDir;
	if (!GetMTConfigDir(configDir))
		return Error("Configuration directory not specified!");

	_bstr_t bstr(configDir.c_str());
	*dir = bstr.copy();

	return S_OK;
}


// ----------------------------------------------------------------
// Description:   Returns true if the running system is setup as a multi-instance
//                configuration.
// Return Value:  true if the machine is in multi-instance mode.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::get_IsMultiInstance(/*[out, retval]*/ VARIANT_BOOL * multi)
{
	BOOL isMulti = IsMultiInstance();

	*multi = isMulti ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Add an additional mapping between port number and instance
//                name in the registry.  Used for multi-instance mode.
// Arguments:     port - TCP/IP port number
//                instance - unique instance/customer name
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::AddPortMapping(/*[in]*/ int port, BSTR instance)
{
	PortMappings mappings;

	// we ignore the error here in case the key didn't exist already
	(void) ReadPortMappings(mappings);

	_bstr_t str(instance);
	string instanceName((const char *) str);
	mappings[port] = instanceName;

	if (!WritePortMappings(mappings))
		return Error("Unable to write mappings");

	return S_OK;
}


// ----------------------------------------------------------------
// Description:   Start using the instance name associated with the
//                given port number. This changes the value returned from
//                the ConfigurationDirectory property.
// Arguments:     port - TCP/IP port number being used.  An associated
//                       instance name must be found in the registry.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::MultiInstanceSetup(/*[in]*/ int port)
{
	if (!IsMultiInstance())
		// not
		return S_FALSE;

	// if multi-instance, map the port number to the name

	// the mapping between port and unique login name is stored in the registry.
	PortMappings mappings;
	if (!ReadPortMappings(mappings))
		return Error("Unable to read port mappings");

	string name = mappings[port];
	if (name.length() == 0)
	{
		char buffer[256];
		sprintf(buffer, "Instance mapping not found for port %d", port);
		return Error(buffer);
	}

	// set the prefix used to make global names unique.
	std::string appName = name.c_str();

	SetUniquePrefix(appName.c_str());
	SetNameSpace(appName);

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Return the original MSIX representation of a single session out of
//                a session set message, given the session set ID and session ID.
// Arguments:     session set ID - ID of session set that contains the given session
//                session ID - ID of the session contained in the session set
//                newUID - on return holds the new unique ID assigned to the
//                         message.
// Return Value:  XML representation of only the given session from the session set
// ----------------------------------------------------------------

STDMETHODIMP CMTPipeline::GetSessionSetMessage(BSTR aSessionSetID, BSTR aSessionID,
																							 /*[out]*/ BSTR * apNewUID,
																							 /*[out, retval]*/ BSTR * message)
{
	try
	{
		HRESULT hr = InitializeLogger();
		if (FAILED(hr))
			return hr;
		hr = ReadConfiguration();
		if (FAILED(hr))
			return hr;

		IMTConfigPtr config(MTPROGID_CONFIG);

		// <msix>
		//   <timestamp>2001-11-14T22:01:38Z</timestamp>
		//   <version>1.1</version>
		//   <uid>wKgBZCAjcO/PyrXRrdy3dw==</uid>
		//   <entity>192.168.1.100</entity>

		if (mLastSessionSetID != _bstr_t(aSessionSetID))
		{
			std::string oldBuffer;
			hr = GetMeteredMessageInternal(aSessionSetID, oldBuffer);
			if (FAILED(hr))
				return hr;


			// NOTE: we have to construct the BSTR manually.  if we rely
			// on the _bstr_t constructor and pass in a large string the
			// program will crash with a stach exception.
			// See CMTConfigPropSet::WriteToBuffer for more info
			USES_CONVERSION;
			BSTR rawBSTRBuffer = A2BSTR(oldBuffer.c_str());
			// attach to it so it will get cleanup up even on an exception
			_bstr_t bstrBuffer(rawBSTRBuffer, false);

			VARIANT_BOOL checksumMatch;
			mLastSessionSetMessage =
				config->ReadConfigurationFromString(bstrBuffer, &checksumMatch);

			mLastSessionSetID = aSessionSetID;
		}

		IMTConfigPropSetPtr oldMessage = mLastSessionSetMessage;
		// it may have been used previously (if it was cached) so
		// reset it
		oldMessage->Reset();

		IMTConfigPropSetPtr newMessage = config->NewConfiguration("msix");
		//newMessage->InsertProp("timestamp", PROP_TYPE_DATETIME);

		// copy the header
		// NOTE: this is a string, not a date/time
		newMessage->InsertProp("timestamp", MTConfigLib::PROP_TYPE_STRING,
													 oldMessage->NextStringWithName("timestamp"));

		newMessage->InsertProp("version", MTConfigLib::PROP_TYPE_STRING,
													 oldMessage->NextStringWithName("version"));

		std::string generatedUidBuffer;
		MSIXUidGenerator::Generate(generatedUidBuffer);
		_bstr_t newUid(generatedUidBuffer.c_str());
		newMessage->InsertProp("uid", MTConfigLib::PROP_TYPE_STRING, newUid);

		// return a copy to the caller
		*apNewUID = newUid.copy();


		newMessage->InsertProp("entity", MTConfigLib::PROP_TYPE_STRING,
													 oldMessage->NextStringWithName("entity"));

		// attach the session context, if it existed in the original message
		std::wstring contextUsername, contextPassword, contextNamespace;
		std::wstring serializedContext;
		if (oldMessage->NextMatches(L"sessioncontextusername", MTConfigLib::PROP_TYPE_STRING))
			contextUsername = oldMessage->NextStringWithName(L"sessioncontextusername");
		if (oldMessage->NextMatches(L"sessioncontextpassword", MTConfigLib::PROP_TYPE_STRING))
			contextPassword = oldMessage->NextStringWithName(L"sessioncontextpassword");
		if (oldMessage->NextMatches(L"sessioncontextnamespace", MTConfigLib::PROP_TYPE_STRING))
			contextNamespace = oldMessage->NextStringWithName(L"sessioncontextnamespace");

		if (oldMessage->NextMatches(L"sessioncontext", MTConfigLib::PROP_TYPE_STRING))
			serializedContext = oldMessage->NextStringWithName(L"sessioncontext");

		if (contextUsername.length() > 0)
			newMessage->InsertProp("sessioncontextusername",
														 MTConfigLib::PROP_TYPE_STRING, contextUsername.c_str());
		if (contextPassword.length() > 0)
			newMessage->InsertProp("sessioncontextpassword",
														 MTConfigLib::PROP_TYPE_STRING, contextPassword.c_str());
		if (contextNamespace.length() > 0)
			newMessage->InsertProp("sessioncontextnamespace",
														 MTConfigLib::PROP_TYPE_STRING, contextNamespace.c_str());

		if (serializedContext.length() > 0)
			newMessage->InsertProp("sessioncontext",
														 MTConfigLib::PROP_TYPE_STRING, serializedContext.c_str());

		// look for all session with the UID that matches what we're given,
		// including child sessions
		IMTConfigPropSetPtr session;
		_bstr_t sessionID(aSessionID);

		// the UIDs we're watching for.  As children come in, their
		// UIDs are added to the set.  This way we can retrieve the whole tree
		std::set<std::wstring> uidSet;
		std::wstring uidBuffer(sessionID);
		uidSet.insert(uidBuffer);
		while (TRUE)
		{
			session = oldMessage->NextSetWithName("beginsession");
			if (session == NULL)
				break;

			//  <beginsession>
			//    <dn>metratech.com/HostedExchange</dn>
			//    <uid>wKgBZCAjcO9NrnPbo9y3dw==</uid>
			//    <parentid>wKgBZLCuQOWoyNy67t3/pw==</parentid> <!-- optional -->

			_bstr_t uid = session->NextStringWithName("uid");
			std::wstring uidTest(uid);
			bool insertSession = false;
			if (uidSet.find(uidTest) != uidSet.end())
			{
				// a match
				insertSession = true;
			}
			else
			{
				if (session->NextMatches("parentid", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
				{
					_bstr_t parentID = session->NextStringWithName("parentid");
					std::wstring childTest = parentID;
					if (uidSet.find(childTest) != uidSet.end())
					{
						// add this session's ID to the set of parents we're looking for
						uidSet.insert(uidTest);	// the parent
						insertSession = true;
					}
				}
			}

			if (insertSession)
			{
				IMTConfigPropSetPtr beginSession = newMessage->InsertSet("beginsession");
				session->Reset();
				beginSession->AddSubSet(session);
			}
		}

		_bstr_t newMessageStr = newMessage->WriteToBuffer();
		*message = newMessageStr.copy();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

// ----------------------------------------------------------------
// Description:   submit a message onto the resubmit queue.
// Arguments:     message - XML message to be resubmitted
//                txn - optional MTTransaction object.  If an MTTransaction
//                      object is passed in this method will be transactional.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::SubmitMessage(
	BSTR aMessage,
	/*[in, optional]*/ VARIANT txn)
{
	try
	{
		if (!mConfigurationRead)
		{
			HRESULT hr = ReadConfiguration();
			if (FAILED(hr))
				return hr;
		}

		ASSERT(mConfigurationRead);

		_bstr_t message(aMessage);

		ErrorObject error;

		const wchar_t * machine;
		if (mPipelineInfo.GetResubmitQueueMachine().length() == 0)
			machine = NULL;
		else
			machine = mPipelineInfo.GetResubmitQueueMachine().c_str();

		mLogger.LogVarArgs(LOG_DEBUG, "Submitting to queue: %s:%s",
											 ascii(machine ? machine : L"").c_str(),
											 ascii(mPipelineInfo.GetResubmitQueueName().c_str()).c_str());

		MessageQueue resubmitQueue;
		if (!resubmitQueue.Init(mPipelineInfo.GetResubmitQueueName().c_str(),
														mPipelineInfo.UsePrivateQueues(), machine)
				|| !resubmitQueue.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to open resubmit queue to submit message");
			return HRESULT_FROM_WIN32(resubmitQueue.GetLastError()->GetCode());
		}

		//
		// we have to extract the batch ID from the XML in the message.
		// the label of the message holds the session ID.
		//
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
		VARIANT_BOOL checksumMatches = VARIANT_FALSE;
		MTConfigLib::IMTConfigPropSetPtr parsedMessage =
			config->ReadConfigurationFromString(message, &checksumMatches);
		_bstr_t sessionSetID = parsedMessage->NextStringWithName(L"uid");

		// TODO: the property count structure is not used
		PropertyCount propCount;
		propCount.total = 0;
		propCount.smallStr = 0;
		propCount.mediumStr = 0;
		propCount.largeStr = 0;

		PIPELINECONTROLLib::IMTTransactionPtr mttran;
		if (_variant_t(txn) != vtMissing)
		{
			if (V_VT(&txn) == (VT_VARIANT | VT_BYREF))
				// dereference (this is how VBScript would pass it)
				mttran = _variant_t(txn.pvarVal);
			else if (V_VT(&txn) == (VT_DISPATCH | VT_BYREF))
				// dereference (this is how VB would pass it)
				mttran = _variant_t(*(txn.ppdispVal));
			else
				mttran = _variant_t(txn);

			if (mttran == NULL)
				return Error("Invalid transaction object");
		}
		else
			mttran = NULL;

		HRESULT hr = SpoolMessage(resubmitQueue, message, message.length(),
															sessionSetID, FALSE, propCount, mttran);
		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description:   Login to provide security credentials for some operations
// Arguments:     login - username to login as
//                login_namespace - namespace of the user
//                password - password of the user
// ----------------------------------------------------------------

STDMETHODIMP CMTPipeline::Login(BSTR login, BSTR login_namespace,
																BSTR password)
{
	try
	{
		MTPipelineLibExt::IMTLoginContextPtr loginObj(MTPROGID_MTLOGINCONTEXT);
		mSessionContext = loginObj->Login(login, login_namespace, password);
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description:   Pass in a session context that has already been created by a login call.
// Arguments:     session_context - a session context object previously
//                retrieved by a Login call.
// ----------------------------------------------------------------
STDMETHODIMP CMTPipeline::put_SessionContext(
	IMTSessionContext * apSessionContext)
{
	try
	{
		mSessionContext = apSessionContext;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTPipeline::RequiresEncryption(
	BSTR message,
	/*[out, retval]*/ VARIANT_BOOL * encrypt)
{
	try
	{
		// TODO: the parser is currently not threadsafe
		AutoCriticalSection lock(&mParserLock);

		if (!mParserInitialized)
		{
			HRESULT hr = InitializeParser();
			if (FAILED(hr))
				return hr;
		}

		// this must be done every time
		if (!mParser.SetupParser())
		{
			const ErrorObject * err = mParser.GetLastError();
			mLogger.LogErrorObject(LOG_ERROR, err);
			return err->GetCode();
		}

		_bstr_t bstrBuffer(message);

		//std::vector<const MSIXParserServiceDef *> serviceDefs;
		ValidationData validationData;

		ISessionProduct** results = NULL;
		if (!mParser.Validate(bstrBuffer, bstrBuffer.length(), results, validationData))
		{
			const ErrorObject * err = mParser.GetLastError();
			mLogger.LogErrorObject(LOG_ERROR, err);
			return err->GetCode();
		}

		// check to see if any sessions within this stream have a service
		// def that requires encryption
		if (validationData.mHasServiceDefWithEncryptedProp)
			*encrypt = VARIANT_TRUE;
		else
			*encrypt = VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


/******************************************* private methods ***/

HRESULT CMTPipeline::ExportSessionToPropSet(IMTConfigPropSetPtr aTopSet,
																						MTPipelineLib::IMTSessionPtr aSession)
{
	ASSERT(mLoggerInitialized);

	long serviceID = aSession->GetServiceID();

	MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
	_bstr_t serviceName = nameid->GetName(serviceID);
	std::wstring serviceNameString(serviceName);
	StrToLower(serviceNameString);

	if (aSession->GetHoldsSessionContext() == VARIANT_TRUE)
	{
		//
		// regenerate the session context that went along with this session
		//

		// retrieve the account ID of the original context
		MTPipelineLibExt::IMTSessionContextPtr originalContext =
			aSession->GetSessionContext();

		long accountID = originalContext->GetAccountID();

		// must have credentials to do this
		if (mSessionContext == NULL)
			return Error(L"Caller must login to export a session context",
									 IID_IMTPipeline, MTAUTH_ACCESS_DENIED);

		// impersonate the account ID of the original session
		MTPipelineLibExt::IMTLoginContextPtr loginObj(MTPROGID_MTLOGINCONTEXT);

		MTPipelineLibExt::IMTSessionContextPtr recreatedContext =
			loginObj->LoginAsAccount(mSessionContext, accountID);

		// serialize the context
		_bstr_t serialized = recreatedContext->ToXML();

		// add it to the auto SDK file
		aTopSet->InsertProp("AuthContext", MTConfigLib::PROP_TYPE_STRING, serialized);
	}

	IMTConfigPropSetPtr sessionSet = aTopSet->InsertSet("session");

	sessionSet->InsertProp("ServiceName", MTConfigLib::PROP_TYPE_STRING, serviceNameString.c_str());
	sessionSet->InsertProp("SessionID", MTConfigLib::PROP_TYPE_STRING, aSession->GetUIDAsString());

	IMTConfigPropSetPtr inputsSet = sessionSet->InsertSet("inputs");

	SetIterator<MTPipelineLib::IMTSessionPtr, MTPipelineLib::IMTSessionPropPtr> it;
	HRESULT hr = it.Init(aSession);
	if (FAILED(hr))
		return hr;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPropPtr prop = it.GetNext();
		if (prop == NULL)
			break;

		_bstr_t bstrName = prop->GetName();

		std::wstring name = bstrName;
		StrToLower(name);

		MTPipelineLib::MTSessionPropType type = prop->Gettype();
		long nameid = prop->GetNameID();

		time_t timeVal;
		long longVal;
		__int64 int64Val;
		_bstr_t stringVal;
		double doubleVal;
		MTDecimal decimalVal;
		bool booleanVal;

		switch (type)
		{
		case MTPipelineLib::SESS_PROP_TYPE_DATE:
			timeVal = aSession->GetDateTimeProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_DATETIME, (long) timeVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_STRING:
			stringVal = aSession->GetStringProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_STRING, stringVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONG:
			longVal = aSession->GetLongProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_INTEGER, longVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
			int64Val = aSession->GetLongLongProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_BIGINTEGER, int64Val);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
			doubleVal = aSession->GetDoubleProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_DOUBLE, doubleVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
			decimalVal = aSession->GetDecimalProperty(nameid);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_DECIMAL, decimalVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_BOOL:
			booleanVal = (aSession->GetBoolProperty(nameid) == VARIANT_TRUE);
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_BOOLEAN, booleanVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_ENUM:
		{
			// TODO: it would be nice to get the string, not the number here,
			// but the string will work fine for now.  Also, have to watch the overhead
			// of the enum config object
			MTPipelineLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			_bstr_t value =
				enumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(nameid));
			inputsSet->InsertProp((const wchar_t *) name.c_str(), MTConfigLib::PROP_TYPE_STRING, value);

			break;
		}

		case MTPipelineLib::SESS_PROP_TYPE_TIME:
		default:
			ASSERT(0);
			return Error("Unhandled property type in CMTPipeline::ExportSessionToPropSet",
									 IID_IMTPipeline, PIPE_ERR_INTERNAL_ERROR);

		}
	}

	if (aSession->GetIsParent())
	{
		// need the session server for this
		if (!mGeneratorInitialized)
		{
			hr = InitializeGenerator();
			if (FAILED(hr))
				return hr;
		}

		// could be a parent.  mark children as complete
		MTPipelineLib::IMTSessionSetPtr set = aSession->SessionChildren();

		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> sessionit;
		hr = sessionit.Init(set);
		if (FAILED(hr))
			return hr;
	
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr child = sessionit.GetNext();
			if (child == NULL)
				break;

			hr = ExportSessionToPropSet(sessionSet, child);
		}
	}

	return hr;
}

HRESULT CMTPipeline::GetMeteredMessageInternal(BSTR sessionID, std::string & arMessage)
{
	ASSERT(mLoggerInitialized);
	ASSERT(mConfigurationRead);

	// this searches the audit queue (journal of the routing queue)
	// to find the message
	mLogger.LogThis(LOG_DEBUG, "Enumerating all routing queues");

	if (!mRoutingQueuesInitialized)
	{
		ErrorObject error;
		if (!GetAllRoutingQueues(mRoutingQueues, error))
			return error.GetCode();
		mRoutingQueuesInitialized = TRUE;
		mLogger.LogVarArgs(LOG_DEBUG, "%d routing queues found", mRoutingQueues.size());
	}

	_bstr_t bstrID(sessionID);

	HRESULT hr = S_OK;

	RoutingQueueList::const_iterator it;
	for (it = mRoutingQueues.begin(); it != mRoutingQueues.end(); it++)
	{
		RoutingQueueInfo info = *it;

		mLogger.LogVarArgs(LOG_DEBUG, "Searching queue: %s:%s for session %s",
											 ascii(info.GetMachineName()).c_str(),
											 ascii(info.GetQueueName()).c_str(),
											 (const char *) bstrID);

		MessageQueue auditQueue;

		const wchar_t * machine;
		if (info.GetMachineName().length() == 0)
			machine = NULL;
		else
			machine = info.GetMachineName().c_str();

		// use the journal, not the routing queue itself
		if (!auditQueue.InitJournal(info.GetQueueName().c_str(),
																mPipelineInfo.UsePrivateQueues(), machine)
				|| !auditQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
			return HRESULT_FROM_WIN32(auditQueue.GetLastError()->GetCode());

		int appSpecific;						// ignored!
		PropertyCount propCount;		// ignored!
		unsigned char * body;
		int bodyLength;
		hr = GetMessageBodyFromQueue(auditQueue, bstrID, &body, &bodyLength,
																 appSpecific, propCount);

		if (SUCCEEDED(hr))
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Session read from queue: %s:%s",
											 ascii(info.GetMachineName()).c_str(),
											 ascii(info.GetQueueName()).c_str());

			hr = InitializeMessageUtils();
			if (FAILED(hr))
				return hr;

			std::string buffer;

			hr = DecryptMessage(body, bodyLength, buffer, mMessageUtils);

			delete [] body;
			if (FAILED(hr))
			{
				mLogger.LogThis(LOG_DEBUG, "Unable to decrypt message");
				return hr;
			}
			arMessage = buffer.c_str();

			// no need to look anymore
			break;
		}
		else
			mLogger.LogVarArgs(LOG_DEBUG, "Session not in queue: %X", hr);
	}

	if (SUCCEEDED(hr) && arMessage.length() == 0)
		return PIPE_ERR_INVALID_SESSION;

	if (hr == PIPE_ERR_INVALID_SESSION)
	{
		_bstr_t buffer("Invalid session ID ");
		buffer += bstrID;
		return Error((const wchar_t *) buffer, IID_IMTPipeline, hr);
	}
	return hr;
}

HRESULT CMTPipeline::ReadConfiguration()
{
	if (mConfigurationRead)
		return S_OK;

	try
	{
		PipelinePropIDs::Init();

		std::string configPath;
		if (!GetMTConfigDir(configPath))
			return CORE_ERR_BAD_CONFIG_DIRECTORY;

		// read the pipeline configuration
		PipelineInfoReader pipelineReader;
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
		if (!pipelineReader.ReadConfiguration(config, configPath.c_str(), mPipelineInfo))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Unable to read pipeline config file");
			const ErrorObject * obj = pipelineReader.GetLastError();
			ASSERT(obj);
			mLogger.LogErrorObject(LOG_ERROR, obj);
			return obj->GetCode();
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	mConfigurationRead = TRUE;
	return S_OK;
}

HRESULT CMTPipeline::InitializeGenerator()
{
	ASSERT(!mGeneratorInitialized);

	try
	{
		if (!mConfigurationRead)
		{
			HRESULT hr = ReadConfiguration();
			if (FAILED(hr))
				return hr;
		}

		ASSERT(mConfigurationRead);

		// initialize the session server
		HRESULT hr = mSessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
		if (FAILED(hr))
			return hr;

		mSessionServer->Init((const char *) mPipelineInfo.GetSharedSessionFile().c_str(),
												(const char *) mPipelineInfo.GetShareName().c_str(),
												mPipelineInfo.GetSharedFileSize());

		// initialize the session generator
		if (!mGenerator.Init(mPipelineInfo, mSessionServer))
		{
			const ErrorObject * err = mGenerator.GetLastError();
			mLogger.LogErrorObject(LOG_ERROR, err);
			return err->GetCode();
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	mGeneratorInitialized = TRUE;
	return S_OK;
}

HRESULT CMTPipeline::InitializeLogger()
{
	if (mLoggerInitialized)
		return S_OK;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[PipelineControl]");
	mLoggerInitialized = TRUE;
	return S_OK;
}


HRESULT CMTPipeline::InitializeMessageUtils()
{
	if (mUtilsInitialized)
		return S_OK;

	HRESULT hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
	if (FAILED(hr))
		return hr;

	mUtilsInitialized = TRUE;
	return S_OK;
}

HRESULT CMTPipeline::InitializeParser()
{
	if (mParserInitialized)
		return S_OK;

	mParser.SetValidateOnly(TRUE);
	if (!mParser.InitForValidate())
	{
		const ErrorObject * err = mParser.GetLastError();
		mLogger.LogErrorObject(LOG_ERROR, err);
		return err->GetCode();
	}

	mParserInitialized = TRUE;
	return S_OK;
}

