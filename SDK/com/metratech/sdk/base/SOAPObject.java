package com.metratech.sdk.base;

import java.io.*;

/**
 * This is the interface that all SOAP objects must implement. It provides an
 * abstraction for parsing and serialization of SOAP data.
 */
interface SOAPObject
{	
  /**
   * Parse the object's data. 
   * 
   * @param data The data to parse.
   * @return No return value.
   * @exception MTException if unable to parse the data.
   */
  public void parse (String data) throws MTException;
	

  /**
   * Create the named sub object (aggregate).
   * 
   * @param type The name of the aggregate to create
   * @return SOAPObject representing the aggregate or null
   * @exception MTException if unable to create the aggregate.
   */
  public SOAPObject create (String type) throws MTException;
	
  /**
   * A subobject or the object itself is complete as its 
   * closing tag has been processed.
   * 
   * @param obj The sub object that is now complete.
   * @return No return value.
   * @exception MTException if unable to handle the aggregate.
   */
  public void complete (SOAPObject obj) throws MTException;

  /**
   * serialize the object to an SOAP stream.
   * 
   * @param stream The stream for writing the serialized object.
   * @return None.
   * @exception IOException as report by OutputStream.
   */
  public void toStream (OutputStream stream, int action) throws IOException;

	// all the constants start here
	public static final int NETMETER_PARSE_BUFFER_SIZE = 4096;

	public static final int SOAP_CALL_CREATE = 0;
	public static final int SOAP_CALL_LOADBYNAME = 1;
	public static final int SOAP_CALL_LOADBYID = 2;
	public static final int SOAP_CALL_LOADBYUID = 3;
	public static final int SOAP_CALL_MARKASACTIVE = 4;
	public static final int SOAP_CALL_MARKASBACKOUT = 5;
	public static final int SOAP_CALL_MARKASFAILED = 6;
	public static final int SOAP_CALL_MARKASDISMISSED = 7;
	public static final int SOAP_CALL_MARKASCOMPLETED = 8;
	public static final int SOAP_CALL_UPDATEMETEREDCOUNT = 9;
	
  // START SOAP specific stuff - likely to be part of a soap object should we ever decide to support it
  public static final String XML_HEADER = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>";
	public static final String SOAP_ENVELOPE_HEADER = "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">";
	public static final String SOAP_BODY_HEADER = "<soap:Body>";
	public static final String SOAP_BATCH_LISTENER_HEADER = "<batchobject>";
	public static final String SOAP_BATCH_LISTENER_TRAILER = "</batchobject>";
	public static final String SOAP_BODY_TRAILER = "</soap:Body>";
	public static final String SOAP_ENVELOPE_TRAILER = "</soap:Envelope>";

	public static final String SOAP_SDK_SCRIPT = "/Batch/Listener.asmx";
	public static final String METRATECH_SDK_USER_AGENT = "MetraTech Metering SDK 1.0.0a1-NT";

  // List of methods that available as web svcs via Batch SOAP 
  public static final String SOAP_CREATE_METHOD = "<Create xmlns=\"http://metratech.com/webservices\">";
  public static final String SOAP_CREATE_METHOD_TRAILER = "</Create>";

  public static final String SOAP_LOADBYNAME_METHOD_HEADER = "<LoadByName xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_LOADBYNAME_METHOD_TRAILER	= "</LoadByName>";
	
	public static final String SOAP_LOADBYUID_METHOD_HEADER	= "<LoadByUID xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_LOADBYUID_METHOD_TRAILER = "</LoadByUID>";

	public static final String SOAP_MARKASACTIVE_METHOD_HEADER = "<MarkAsActive xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_MARKASACTIVE_METHOD_TRAILER	= "</MarkAsActive>";

	public static final String SOAP_MARKASBACKOUT_METHOD_HEADER = "<MarkAsBackout xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_MARKASBACKOUT_METHOD_TRAILER	= "</MarkAsBackout>";

	public static final String SOAP_MARKASCOMPLETED_METHOD_HEADER = "<MarkAsCompleted xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_MARKASCOMPLETED_METHOD_TRAILER	= "</MarkAsCompleted>";
	
	public static final String SOAP_MARKASFAILED_METHOD_HEADER = "<MarkAsFailed xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_MARKASFAILED_METHOD_TRAILER	= "</MarkAsFailed>";
	
	public static final String SOAP_MARKASDISMISSED_METHOD_HEADER	= "<MarkAsDismissed xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_MARKASDISMISSED_METHOD_TRAILER = "</MarkAsDismissed>";
	
	public static final String SOAP_UPDATEMETEREDCOUNT_METHOD_HEADER = "<UpdateMeteredCount xmlns=\"http://metratech.com/webservices\">";
	public static final String SOAP_UPDATEMETEREDCOUNT_METHOD_TRAILER	= "</UpdateMeteredCount>";
	
	// Return properties that can come with the response for batch creation/load
	public static final String CREATE_RESULT_TAG = "CreateResult";
	public static final String LOADBYNAME_RESULT_TAG = "LoadByNameResult";
	public static final String LOADBYUID_RESULT_TAG = "LoadByUIDResult";

	public static final String MARKASACTIVE_RESULT_TAG = "MarkAsActiveResult";
	public static final String MARKASBACKOUT_RESULT_TAG = "MarkAsBackoutResult";
	public static final String MARKASFAILED_RESULT_TAG = "MarkAsFailedResult";
	public static final String MARKASCOMPLETED_RESULT_TAG = "MarkAsCompletedResult";
	public static final String MARKASDISMISSED_RESULT_TAG = "MarkAsDismissedResult";
	
	public static final String MARKASACTIVE_RESPONSE_TAG = "MarkAsActiveResponse";
	public static final String MARKASBACKOUT_RESPONSE_TAG = "MarkAsBackoutResponse";
	public static final String MARKASFAILED_RESPONSE_TAG = "MarkAsFailedResponse";
	public static final String MARKASCOMPLETED_RESPONSE_TAG = "MarkAsCompletedResponse";
	public static final String MARKASDISMISSED_RESPONSE_TAG = "MarkAsDismissedResponse";

	public static final String UPDATEMETEREDCOUNT_RESULT_TAG = "UpdateMeteredCountResult";
	public static final String UPDATEMETEREDCOUNT_RESPONSE_TAG = "UpdateMeteredCountResponse";
	
	// Batch object related tags
	public static final String BATCH_ID_TAG = "ID";
	public static final String BATCH_UID_TAG = "UID";
	public static final String BATCH_NAME_TAG = "Name";
	public static final String BATCH_NAMESPACE_TAG = "Namespace";
	public static final String BATCH_STATUS_TAG = "Status";
	public static final String BATCH_CREATIONDATE_TAG = "CreationDate";
	public static final String BATCH_SOURCE_TAG = "Source";
	public static final String BATCH_COMPLETEDCOUNT_TAG = "CompletedCount";
	public static final String BATCH_EXPECTEDCOUNT_TAG = "ExpectedCount";
	public static final String BATCH_FAILURECOUNT_TAG = "FailureCount";
	public static final String BATCH_SEQUENCENUMBER_TAG = "SequenceNumber";
	public static final String BATCH_ACTION_TAG = "Action";
	public static final String BATCH_OPERATOR_TAG = "Operator";
	public static final String BATCH_COMMENT_TAG = "Comment";
	public static final String BATCH_SOURCECREATIONDATE_TAG = "SourceCreationDate";
	public static final String BATCH_COMPLETIONDATE_TAG = "CompletionDate";
	public static final String BATCH_METEREDCOUNT_TAG = "MeteredCount";
	public static final String SOAP_FAULT_TAG = "soap:Fault";
	public static final String SOAP_FAULTCODE_TAG = "faultcode";
	public static final String SOAP_FAULTSTRING_TAG = "faultstring";

  // These tags create xml based streams
  public static final String SOAP_OPENINGTAG_PREFIX = "<";
  public static final String SOAP_OPENINGTAG_SUFFIX = ">";
  public static final String SOAP_CLOSINGTAG_PREFIX = "</";
  public static final String SOAP_CLOSINGTAG_SUFFIX = ">";
	
  // The current SDK version
  public static final String SOAP_CURRENT_VERSION = "2.0";
}
