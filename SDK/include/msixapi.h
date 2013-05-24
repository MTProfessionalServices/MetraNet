/**************************************************************************
 * @Doc MSIXAPI
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header: msixapi.h, 35, 11/8/2002 4:37:08 PM, Raju Matta$
 *
 * @index | MSIXAPI
 ***************************************************************************/


#ifndef _MSIXAPI_H
#define _MSIXAPI_H

#include <sdkcon.h>
#include <xmlconfig.h>

#ifdef WIN32
#include <win32net.h>
#endif

#ifdef UNIX
#include <unixnet.h>
#endif

#include <stack>
#include <MTUtil.h>

// START SOAP specific stuff - likely to be part of a soap object should we ever decide to support it
#define XML_HEADER "<?xml version=\"1.0\" encoding=\"utf-8\" ?>"
#define SOAP_ENVELOPE_HEADER "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">"
#define SOAP_BODY_HEADER "<soap:Body>"
#define SOAP_BATCH_LISTENER_HEADER "<batchobject>"
#define SOAP_BATCH_LISTENER_TRAILER "</batchobject>"
#define SOAP_BODY_TRAILER "</soap:Body>"
#define SOAP_ENVELOPE_TRAILER "</soap:Envelope>"

// List of methods that ae available as web services via the Batch SOAP 
// interface
#define SOAP_CREATE_METHOD "<Create xmlns=\"http://metratech.com/webservices\">"
#define SOAP_CREATE_METHOD_TRAILER "</Create>"

// LoadByName and LoadByUID are different - they do not submit an object, 
// just properties
// -------------------------------------------------------------------
// -- LoadByName stuff ---
#define SOAP_LOADBYNAME_METHOD_HEADER		"<LoadByName xmlns=\"http://metratech.com/webservices\">"
#define SOAP_LOADBYNAME_METHOD_TRAILER	"</LoadByName>"
// -- LoadByUID stuff ---
#define SOAP_LOADBYUID_METHOD_HEADER			"<LoadByUID xmlns=\"http://metratech.com/webservices\">"
#define SOAP_LOADBYUID_METHOD_TRAILER		"</LoadByUID>"
// -------------------------------------------------------------------
#define SOAP_MARKASFAILED_METHOD_HEADER			"<MarkAsFailed xmlns=\"http://metratech.com/webservices\">"
#define SOAP_MARKASFAILED_METHOD_TRAILER		"</MarkAsFailed>"

#define SOAP_MARKASDISMISSED_METHOD_HEADER			"<MarkAsDismissed xmlns=\"http://metratech.com/webservices\">"
#define SOAP_MARKASDISMISSED_METHOD_TRAILER		"</MarkAsDismissed>"

#define SOAP_MARKASCOMPLETED_METHOD_HEADER			"<MarkAsCompleted xmlns=\"http://metratech.com/webservices\">"
#define SOAP_MARKASCOMPLETED_METHOD_TRAILER		"</MarkAsCompleted>"

#define SOAP_MARKASACTIVE_METHOD_HEADER			"<MarkAsActive xmlns=\"http://metratech.com/webservices\">"
#define SOAP_MARKASACTIVE_METHOD_TRAILER		"</MarkAsActive>"

#define SOAP_MARKASBACKOUT_METHOD_HEADER			"<MarkAsBackout xmlns=\"http://metratech.com/webservices\">"
#define SOAP_MARKASBACKOUT_METHOD_TRAILER		"</MarkAsBackout>"

#define SOAP_UPDATEMETEREDCOUNT_METHOD_HEADER			"<UpdateMeteredCount xmlns=\"http://metratech.com/webservices\">"
#define SOAP_UPDATEMETEREDCOUNT_METHOD_TRAILER		"</UpdateMeteredCount>"

// Return properties that can come with the response for batch creation/load
#define CREATE_RESULT_TAG "CreateResult"
#define LOADBYNAME_RESULT_TAG "LoadByNameResult"
#define LOADBYUID_RESULT_TAG "LoadByUIDResult"
#define MARKASFAILED_RESULT_TAG "MarkAsFailedResult"
#define MARKASDISMISSED_RESULT_TAG "MarkAsDismissedResult"
#define MARKASCOMPLETED_RESULT_TAG "MarkAsCompletedResult"
#define MARKASACTIVE_RESULT_TAG "MarkAsActiveResult"
#define MARKASBACKOUT_RESULT_TAG "MarkAsBackoutResult"

#define MARKASFAILED_RESPONSE_TAG "MarkAsFailedResponse"
#define MARKASDISMISSED_RESPONSE_TAG "MarkAsDismissedResponse"
#define MARKASCOMPLETED_RESPONSE_TAG "MarkAsCompletedResponse"
#define MARKASACTIVE_RESPONSE_TAG "MarkAsActiveResponse"
#define MARKASBACKOUT_RESPONSE_TAG "MarkAsBackoutResponse"
#define UPDATEMETEREDCOUNT_RESPONSE_TAG "UpdateMeteredCountResponse"

#define UPDATEMETEREDCOUNT_RESULT_TAG "UpdateMeteredCountResult"
#define BATCH_ID_TAG "ID"
#define BATCH_NAME_TAG "Name"
#define BATCH_NAMESPACE_TAG "Namespace"
#define BATCH_STATUS_TAG "Status"
#define BATCH_SOURCE_TAG "Source"
#define BATCH_COMPLETEDCOUNT_TAG "CompletedCount"
#define BATCH_EXPECTEDCOUNT_TAG "ExpectedCount"
#define BATCH_FAILURECOUNT_TAG "FailureCount"
#define BATCH_SEQUENCENUMBER_TAG "SequenceNumber"
#define BATCH_SOURCECREATIONDATE_TAG "SourceCreationDate"
#define BATCH_CREATIONDATE_TAG "CreationDate"
#define BATCH_UID_TAG "UID"
#define SOAP_FAULT_TAG "soap:Fault"
#define SOAP_FAULTCODE_TAG "faultcode"
#define SOAP_FAULTSTRING_TAG "faultstring"

// END SOAP

class MSIXMeteringSessionImp : public MeteringSessionImp
{
public:
	MSIXMeteringSessionImp(NetMeterAPI * apAPI);
	virtual ~MSIXMeteringSessionImp();

	MeteringServer * GetLastRecipient() const;

	void SetLastRecipient(MeteringServer * apServer);

private:
	MeteringServer * mpLastSentTo;
};

/*
 * @class
 * This class knows how to stream MSIX objects into
 * XML and how to send them and receive them across the network.
 * @devnote
 * All SDK object share a pointer to a common MSIXNetMeterAPI,
 * so all its methods must be threadsafe!
 * The easiest way to do that is to be extremely careful with
 * accessing any member functions and make sure the class
 * only uses other threadsafe classes and functions.
 */

class MSIXNetMeterAPI : public NetMeterAPI
{
public:
	/*
	 * generic NetMeter API interface
	 */

	MSIXNetMeterAPI(NetStream * apNetStream, const char * apProxyName = NULL);
	virtual ~MSIXNetMeterAPI();

	//virtual BOOL Init(); - These are both on the base class now. Functions are virtual so they can be overriden
	//virtual BOOL Close(); - These are both on the base class now. Functions are virtual so they can be overriden

	virtual BOOL CommitSessionSet(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId);

	virtual BOOL ToXML(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId,
		std::string & arBuffer);

	virtual MeteringSessionImp * CreateSession(const char * apName, BOOL IsChild = FALSE);
	virtual MeteringSessionSetImp * CreateSessionSet();

	virtual BOOL MeterFile (char * FileName);

public:

protected:
	virtual MSIXMessage *SendRequest(MSIXParser & arParser,
												MeteringServer & arServer,
												const MSIXMessage & arMessage);

   virtual MSIXMessage *SendRequest(MSIXParser & arParser,
									         MeteringServer & arServer,
									         string arMessage);

	static BOOL StreamObject(string & arBuffer, const MSIXObject & arObj);

	BOOL GetStatusFromMessage(MSIXMessage * apMessage,
														MSIXSessionStatusMap & arStatusMap,
														ErrorObject::ErrorCode & arCode,
														string & arMessage);

	string SendSoapRequest(MeteringServer & arServer, const char * arMessage);

   


private:
	MSIXMessage * CreateMessageWrapper(MSIXObject * apBody,
																		 const char * apUpdateId,
																		 const char * apTransactionID,
																		 const char * apListenerTransactionID,
																		 const char * apSessionContext,
																		 const char * apUserName,
																		 const char * apPassword,
																		 const char * apNamespace);

	BOOL CompressSessionSet(list<MSIXMessage *> & arMessages,
										 unsigned char * * apBatchBuffer,
										 int & arBatchLen);

protected:
	MSIXMessage * ParseResults(MSIXParser & arParser, const char * apResult,
														 unsigned int aLen);

private:
	bool mUseCompression;

};

/*
 * @class
 * This class knows how to stream MSIX objects into
 * XML and how to send them and receive them across the network.
 * @devnote
 * All SDK object share a pointer to a common MSIXNetMeterAPI,
 * so all its methods must be threadsafe!
 * The easiest way to do that is to be extremely careful with
 * accessing any member functions and make sure the class
 * only uses other threadsafe classes and functions.
 */

class SOAPNetMeterAPI : public NetMeterAPI
{
public:
	/*
	 * generic NetMeter API interface
	 */

	SOAPNetMeterAPI(NetStream * apNetStream, const char * apProxyName = NULL);
	virtual ~SOAPNetMeterAPI();

	virtual BOOL CommitBatch(
		MeteringBatchImp & arBatch,
		int aAction);

	// TODO : WORK ON THIS
	//virtual BOOL ToXML(
	//	const MeteringBatchImp & arSessionSet,
	//	MSIXTimestamp aTimestamp,
	//	const char * apUpdateId,
	//	std::string & arBuffer);

	virtual MeteringBatchImp * CreateBatch(NetMeterAPI* apMsixAPI);

	virtual MeteringBatchImp * Refresh(const char * apUID, NetMeterAPI* apMsixAPI);
	virtual MeteringBatchImp * LoadBatchByName(const char * apName, const char * apNameSpace, const char* apSequenceNumber, NetMeterAPI* apMsixAPI);
	virtual MeteringBatchImp * LoadBatchByUID(const char * apUID, NetMeterAPI* apMsixAPI);

	virtual BOOL MarkAsFailed(const char * apUID, const char* apComment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsDismissed(const char * apUID, const char* apComment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsCompleted(const char * apUID, const char* apComment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsActive(const char * apUID, const char* apComment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsBackout(const char * apUID, const char* apComment, NetMeterAPI* apMsixAPI);
	virtual BOOL UpdateMeteredCount(const char * apUID, int aMeteredCount, NetMeterAPI* apMsixAPI);

	virtual MeteringSessionImp * CreateSession(const char * apName, BOOL IsChild = FALSE);
	
	virtual MeteringSessionSetImp * CreateSessionSet();

	virtual BOOL Close();

protected:

	virtual BOOL StreamObject(string & arBuffer, const MeteringBatchImp & arObj);
	virtual string SendRequest(MeteringServer & arServer, const char * arMessage, int aAction);
	virtual BOOL UpdateBatchWithResponse(MeteringBatchImp & arBatch, XMLObject * apResponse, int aAction);
	virtual BOOL GeneratePropertyStream(string & arBuffer, const MeteringBatchImp & arObj, int arMethodType);

	string StripSOAPException(string aStrSOAPException);
	long ExtractMTErrorCode(string aStrStrippedException);
};

#endif /* _MSIXAPI_H */
