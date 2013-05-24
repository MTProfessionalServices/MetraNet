/**************************************************************************
 * @doc GENERATE
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
 * Created by: Derek Young
 *
 * $Date: 10/11/2002 5:53:29 PM$
 * $Author: Derek Young$
 * $Revision: 65$
 ***************************************************************************/
 
#include <metra.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF")
#import "MTConfigLib.tlb"
#include <MSIX.h>
#include <generate.h>
#include <mtprogids.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <propids.h>
#include <reservedproperties.h>
#include <mtcomerr.h>
#include <pipemessages.h>

#include <MTMSIXUnicodeConversion.h>
#include <stdutils.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

// uncomment this line to cause the generate to always generate a unique
// session ID (useful for performance/unit testing)
//#define GENERATE_UNIQUE_UID

/*********************************** PipelineObjectGenerator ***/

PipelineObjectGenerator::PipelineObjectGenerator()
{ }

PipelineObjectGenerator::~PipelineObjectGenerator()
{ }


BOOL PipelineObjectGenerator::Init(const PipelineInfo & arPipelineInfo,
																	 MTPipelineLib::IMTSessionServerPtr aSessionServer)
{
	const char * functionName = "PipelineObjectGenerator::Init";

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);

	mSessionServer = aSessionServer;

	HRESULT hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		// TODO: better error here
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (!mServices.Initialize())
	{
		// TODO: make sure mServices returns a good error in all cases
		const ErrorObject * err = mServices.GetLastError();
		ASSERT(err);
		if (err)
			SetError(err);
		else
			SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);	
	if(FAILED(hr))
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	
	if (!mParser.InitForParse(arPipelineInfo))
	{
		SetError(mParser);
		return FALSE;
	}

	//
	// initialize the crypto functions
	//
	try
	{
		HRESULT hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_DEBUG,
											"Unable to create MetraTech.Pipeline.Messages.MessageUtils");
			SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		/// TODO: remove mCrypto
    int result = mCrypto.CreateKeys("metratechpipeline", true, "pipeline");
    if (result == 0)
      result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", TRUE, "pipeline");
		if (result != 0)
		{
			mLogger.LogVarArgs(LOG_ERROR,
												 "Unable to initialize crypto functions: %x: %s",
												 result,
												 mCrypto.GetCryptoApiErrorString());

			// NOTE: this "result" code is not very useful so override it
			// with the crypto specific code
			SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
    }
	}
	catch (_com_error & e)
	{
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		mLogger.LogThis(LOG_ERROR, "Unable to initialize crypto functions");
		mLogger.LogErrorObject(LOG_ERROR, err);
		delete err;
		return FALSE;
	}

	return TRUE;
}

BOOL PipelineObjectGenerator::ParseAndGenerate(const char * apMessage,
																							 unsigned long aMessageSize,
																							 SessionObjectVector & arSessionObjects,
																							 PipelineFlowControl * apFlowControl,
																							 unsigned char * apBatchUID,
																							 int * apSessionCount,
																							 ValidationData & arParsedData,
																							 BOOL aIgnoreDefaults /* = FALSE */,
																							 BOOL aIgnoreOptionals /* = FALSE */)
{
	if (apSessionCount)
		*apSessionCount = 1;
	// straight XML message
	return ParseAndGenerateMSIXMessage(apMessage, aMessageSize,
																		 arSessionObjects, apFlowControl,
																		 apBatchUID, arParsedData,
																		 aIgnoreDefaults, aIgnoreOptionals);
}

BOOL PipelineObjectGenerator::ParseAndGenerateMSIXMessage(
	const char * apMSIXStream,
	int aLen,
	SessionObjectVector & arSessionObjects,
	PipelineFlowControl * apFlowControl,
	unsigned char * apUID,
	ValidationData & arParsedData,
	BOOL aIgnoreDefaults,
	BOOL aIgnoreOptionals)
{
	const char * functionName = "PipelineObjectGenerator::ParseAndGenerateMSIXMessage";

	// possibly stop the flow of sessions into the pipeline
	if (apFlowControl && !apFlowControl->ReevaluateFlow())
	{
		SetError(*apFlowControl);
		mLogger.LogThis(LOG_ERROR, "Unable to reevaluate flow control!");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		SetError(*apFlowControl);
		return FALSE;
	}

	if (!mParser.SetupParser())
	{
		SetError(mParser);
		return FALSE;
	}

	// NOTE: enable this line to see the entire message in the log
	///mLogger.LogThis(LOG_DEBUG, apMSIXStream);

	// this will be the index of the first session parsed
	// (there will be more than one if this is a compound session)

	MTMSIXUnicodeConversion ConversionObj(apMSIXStream,aLen,true);
	const char * message = ConversionObj.ConvertToASCII();
	int messageLength = ConversionObj.GetBufferSize();

	_bstr_t decodedMessage;
	// TODO: this has to construct a BSTR.  this isn't very efficient if the
	// message is not encoded.  We construct it explicitly so we can avoid
	// constructing it twice.
	_bstr_t originalMessage(message);
	if (mMessageUtils->IsEncoded(originalMessage))
	{
		_bstr_t uid;
		_bstr_t messageUid;
		decodedMessage = mMessageUtils->DecodeMessage(originalMessage,
																									uid.GetAddress(),
																									messageUid.GetAddress());
		message = (const char *) decodedMessage;
		messageLength = decodedMessage.length();
	}

	int first = arSessionObjects.size();
	arParsedData.mAddDefaultValues = !aIgnoreOptionals;

	SharedMemorySessionProduct * results = NULL;
	if (!mParser.Parse(message, messageLength, (ISessionProduct**) &results, arParsedData))
	{
		SetError(mParser);
		return FALSE;
	}
	results->GetSessions(arSessionObjects);
	delete results;

	std::wstring wideIPAddress;
	ASCIIToWide(wideIPAddress, arParsedData.mIPAddress);

	//
	// add some initial properties to the session
	//
	if (!aIgnoreDefaults)
	{
		for (int i = first; i < (int) arSessionObjects.size(); i++)
		{
			MTPipelineLib::IMTSessionPtr sessionObj = arSessionObjects[i];
			if (!AddInitialProperties(arParsedData.mMeteredTime,
																wideIPAddress.c_str(), sessionObj))
				return FALSE;
		}
	}

	// pass back the message's ID
	if (apUID)
		MSIXUidGenerator::Decode(apUID, arParsedData.mMessageID);
 	
	return TRUE;
}


BOOL PipelineObjectGenerator::AddSessionProperties(MSIXTimestamp aTimestamp,
																									 const wchar_t * apIPAddress,
																									 MTPipelineLib::IMTSessionPtr aSession,
																									 CMSIXDefinition * apService,
																									 MSIXSession * apMSIXSession,
																									 BOOL aIgnoreDefaults,
																									 BOOL aIgnoreOptionals)
{
	const char * functionName = "PipelineObjectGenerator::AddSessionProperties";

	ASSERT(apMSIXSession);

	if (!aIgnoreDefaults)
	{
		//
		// set initial/default properties
		//

		if (!AddInitialProperties(aTimestamp.GetTime(),
															apIPAddress,
															aSession))
			return FALSE;
	}

		//gets a nonconst session object
	MSIXSession * nonconstSession = const_cast<MSIXSession *>(apMSIXSession); 
	
	std::map<PropMapKey, MSIXPropertyValue *>::const_iterator iter;//is the current property in the session?

	MSIXSession::PropMap & sessionPropMap = nonconstSession->GetProperties();
	std::wstring blank(L"");

	//temporary storage variables for the values being set
	int intVal;
  __int64 int64Val;
	double doubleVal;
	time_t timeVal;
	const MSIXString * uniString = NULL;
	BOOL boolVal;
	_bstr_t enumSpace, enumType, enumValue, FQN;
	std::wstring wideEnumSpace;
	std::wstring wideEnumEnumeration;

	//iterates over the service definition

	//gets the list of all properties in the service definition
	MSIXPropertiesList & definitionPropList = apService->GetMSIXPropertiesList();

	MSIXPropertiesList::iterator it;
	for (it = definitionPropList.begin(); it != definitionPropList.end(); ++it)
	{
		//grabs the next property
		CMSIXProperties * defProp = *it;
		std::wstring wideName;
		wideName = defProp->GetDN();
		std::string asciiName;
		asciiName = ascii(wideName);
	
    //determines whether the current property is in the session
		const PropMapKey key(asciiName.c_str());

		iter = sessionPropMap.find(key);  //compile warning
		//if the property is not in session and not required and
		//has a default then adds it to the current session
		if (iter == sessionPropMap.end())
		{
			if (defProp->GetIsRequired())
			{
				// property was required but isn't in the session.
				mLogger.LogVarArgs(LOG_ERROR, "Required property %s not found",
									(const char*) asciiName.c_str());
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}

			// if the caller doesn't want optional properties filled in, leave them out.
			if (!aIgnoreOptionals && defProp->GetDefault() != blank)
			{
				MSIXString defaultVal(defProp->GetDefault().c_str());
				nonconstSession->AddUnknownProperty(asciiName.c_str(), defaultVal);
			}
			else
			{
				//if the property is not being used and doesn't have a default then
				//inspect the next propety
				continue;
			}
		}

		mLogger.LogVarArgs(LOG_DEBUG, "Adding property %s", (const char *) asciiName.c_str());
		
		//grabs the properties name ID
		long id = mNameID->GetNameID((const wchar_t *) defProp->GetDN().c_str());
		
		// the service type is one of the VARIANT types
		CMSIXProperties::PropertyType type = defProp->GetPropertyType();

		switch (type) {
		case CMSIXProperties::TYPE_INT32:
			if (!nonconstSession->GetProperty(asciiName.c_str(), intVal)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetLongProperty(id, (long) intVal);
			break;
			
		case CMSIXProperties::TYPE_INT64:
			if (!nonconstSession->GetInt64Property(asciiName.c_str(), int64Val)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetLongLongProperty(id, int64Val);
			break;
			
		case CMSIXProperties::TYPE_FLOAT:
		case CMSIXProperties::TYPE_DOUBLE:
			if (!nonconstSession->GetProperty(asciiName.c_str(), doubleVal)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetDoubleProperty(id, doubleVal);
			break;

		case CMSIXProperties::TYPE_BOOLEAN:
			if (!nonconstSession->GetBooleanProperty(asciiName.c_str(), boolVal)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetBoolProperty(id, boolVal ? VARIANT_TRUE : VARIANT_FALSE);
			break;
			
		case CMSIXProperties::TYPE_TIMESTAMP:
    {
			if (!nonconstSession->GetTimestampProperty(asciiName.c_str(), timeVal)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
      DATE dt;
      ::OleDateFromTimet(&dt, timeVal);
			aSession->SetOLEDateProperty(id, dt);
			break;
    }
			
		case CMSIXProperties::TYPE_STRING:
		case CMSIXProperties::TYPE_WIDESTRING:
			if (!nonconstSession->GetProperty(asciiName.c_str(), &uniString)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetStringProperty(id, (const wchar_t *) uniString->data());
			break;

		case CMSIXProperties::TYPE_DECIMAL:
			// TODO: do real conversion here!
			if (!nonconstSession->GetProperty(asciiName.c_str(), &uniString)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}

			{
				DECIMAL decValue;
				HRESULT hr = ::VarDecFromStr((wchar_t *)uniString->data(),
																		 -1, LOCALE_NOUSEROVERRIDE,
																		 &decValue);
				if (FAILED(hr))
				{
					SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
					return FALSE;
				}
				aSession->SetDecimalProperty(id, decValue);
			}
			break;

		case CMSIXProperties::TYPE_ENUM:

			wideEnumSpace = defProp->GetEnumNamespace();
			enumSpace = _bstr_t(wideEnumSpace.c_str());

			wideEnumEnumeration = defProp->GetEnumEnumeration();
			enumType = _bstr_t(wideEnumEnumeration.c_str());
			if (!nonconstSession->GetProperty(asciiName.c_str(), &uniString)) {
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			
			enumValue = uniString->data();
			FQN = mEnumConfig->GetFQN(enumSpace, enumType, enumValue);
			
			if(FQN.length() == 0)
			{
				mLogger.LogVarArgs(LOG_ERROR, "Enumeration %s/%s/%s not found in enum collection, quitting",
									(const char*)enumSpace, (const char*)enumType, (const char*)enumValue);
				SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}
			aSession->SetEnumProperty(id, mNameID->GetNameID((const wchar_t *)FQN));
			break;
			
		default:
			SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}
	}
	

	// *** NOTE ***
	//When adding special properties below, make sure to update
  //the corresponding property counting mechanism in handler.cpp.
	//Without the corresponding change, the effectiveness of
	//"gracefully handle large sessions" is degraded.

	//handles special properties 
	//(properties which work across all service definitions)

	// _ProfileStage can have the value Y for TRUE, or N for false
	// if true, each stage will generate profiling information
	if (nonconstSession->GetProperty(MT_PROFILESTAGE_PROP_A, &uniString)) {
				
		if (*uniString == L"Y") {
			mLogger.LogVarArgs(LOG_DEBUG,
			"Enabling stage profiling for stage for session");
			aSession->SetBoolProperty(mNameID->GetNameID(MT_PROFILESTAGE_PROP_A),
									  VARIANT_TRUE);
		}
	}

	// _NewParentID will have a string value - the UID of the parent session
	if (nonconstSession->GetProperty(MT_NEWPARENTID_PROP_A, &uniString)) {
		aSession->SetStringProperty(mNameID->GetNameID(MT_NEWPARENTID_PROP_A),
								    (const wchar_t *) uniString->data());
	}

	// _NewParentInternalID will have an integer value - the database
	// ID of the parent session
	if (nonconstSession->GetProperty(MT_NEWPARENTINTERNALID_PROP_A, intVal)) {
		aSession->SetLongProperty(mNameID->GetNameID(MT_NEWPARENTINTERNALID_PROP_A),
								  (long) intVal);
	}

	// _CollectionID will have a string value - a UID that identifies a
	// grouping of sessions. 
	//
	if (nonconstSession->GetProperty(MT_COLLECTIONID_PROP_A, &uniString)) {
		aSession->SetStringProperty(mNameID->GetNameID(MT_COLLECTIONID_PROP_A),
			                        (const wchar_t *) uniString->data());
	}

	// _TransactionCookie will have a string value - an opaque string
	// used to join into distributed transactions.
 	if (nonconstSession->GetProperty(MT_TRANSACTIONCOOKIE_PROP_A, &uniString)) {
		aSession->SetStringProperty(mNameID->GetNameID(MT_TRANSACTIONCOOKIE_PROP_A),
							        (const wchar_t *) uniString->data());
	}

	// _IntervalID will have an integer value
	if (nonconstSession->GetProperty(MT_INTERVALID_PROP_A, intVal)) {
		aSession->SetLongProperty(mNameID->GetNameID(MT_INTERVALID_PROP_A),
								  (long) intVal);
	}

	// *** NOTE ***
	//When adding special properties above, make sure to update
  //the corresponding property counting mechanism in handler.cpp.
	//Without the corresponding change, the effectiveness of
	//"gracefully handle large sessions" is degraded.


	return TRUE;
}

BOOL PipelineObjectGenerator::AddInitialProperties(time_t aMeteredTime,
																									 const wchar_t * apIPAddress,
																									 MTPipelineLib::IMTSessionPtr aSession)
{
	const char * functionName = "PipelineObjectGenerator::AddInitialProperties";

	//
	// set initial/default properties
	//
		
	// time the message was generated
	// this property can be overridden in the pipeline
	// it's only set if it wasn't metered in.
  DATE dtMeteredTime;
  ::OleDateFromTimet(&dtMeteredTime, aMeteredTime);

	if (aSession->PropertyExists(PipelinePropIDs::TimestampCode(), MTPipelineLib::SESS_PROP_TYPE_DATE)
			== VARIANT_FALSE)
		aSession->SetOLEDateProperty(PipelinePropIDs::TimestampCode(),
                                 dtMeteredTime);

	// time the message was generated
	// this is a second copy of the time that shouldn't be overridden by the pipeline
	aSession->SetOLEDateProperty(PipelinePropIDs::MeteredTimestampCode(),
                               dtMeteredTime);

	// service ID
	long serviceId = aSession->GetServiceID();
	aSession->SetLongProperty(PipelinePropIDs::ServiceIDCode(), serviceId);

	// default the product view ID and product ID to the service ID since they
	// commonly have the same names and therefore the same IDs.
	aSession->SetLongProperty(PipelinePropIDs::ProductViewIDCode(), serviceId);
	aSession->SetLongProperty(PipelinePropIDs::ProductIDCode(), serviceId);

	// IP address
	aSession->SetBSTRProperty(PipelinePropIDs::IPAddressCode(), apIPAddress);

	// TODO: could set other properties here...
	// if new properties are added here, handler.cpp will need to be modified to relfect
	// the change in property counts
	return TRUE;
}


BOOL PipelineObjectGenerator::GetService(MSIXSession * apSess,
																				 CMSIXDefinition * & apService)
{
	const char * functionName = "PipelineObjectGenerator::GetService";

	std::wstring svcName;
	ASCIIToWide(svcName, apSess->GetName().c_str(), apSess->GetName().length());

	apService = NULL;
	if (!mServices.FindService(svcName, apService))
	{
		std::string buffer("Service name ");
		buffer += apSess->GetName().c_str();
		buffer += " not found";
		SetError(MT_ERR_UNKNOWN_SERVICE, ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
		return FALSE;
	}

	ASSERT(apService);
	return TRUE;
}
