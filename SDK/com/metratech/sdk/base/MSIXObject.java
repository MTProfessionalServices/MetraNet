package com.metratech.sdk.base;


import java.io.*;

/**
 * This is the interface that all MSIX objects must implement. It provides an
 * abstraction for parsing and serialization of MSIX data.
 */
interface MSIXObject
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
   * @return MSIXObject representing the aggregate or null
   * @exception MTException if unable to create the aggregate.
   */
  public MSIXObject create (String type) throws MTException;
	

  /**
   * A subobject or the object itself is complete as its 
   * closing tag has been processed.
   * 
   * @param obj The sub object that is now complete.
   * @return No return value.
   * @exception MTException if unable to handle the aggregate.
   */
  public void complete (MSIXObject obj) throws MTException;
	

  /**
   * serialize the object to an msix stream.
   * 
   * @param stream The stream for writing the serialized object.
   * @return None.
   * @exception IOException as report by OutputStream.
   */
  public void toStream (OutputStream stream) throws IOException;
	
  // These are the MSIX tag names
  public static final String MSIX_TAG_MESSAGE = "msix";
  public static final String MSIX_TAG_VERSION = "version";
  public static final String MSIX_TAG_UID = "uid";
  public static final String MSIX_TAG_ENTITY = "entity";
  public static final String MSIX_TAG_BEGINSESSION = "beginsession";
  public static final String MSIX_TAG_DISTINGUISEDNAME = "dn";
  public static final String MSIX_TAG_TIMESTAMP = "timestamp";
  public static final String MSIX_TAG_COMMIT = "commit";	
  public static final String MSIX_TAG_INSERT = "insert";	
  public static final String MSIX_TAG_VALUE = "value";
  public static final String MSIX_TAG_STATUS = "status";
  public static final String MSIX_TAG_STATUSMESSAGE = "message";
  public static final String MSIX_TAG_SESSIONSTATUS = "sessionstatus";
  public static final String MSIX_TAG_CODE = "code";
  public static final String MSIX_TAG_FEEDBACK = "feedback";
  public static final String MSIX_TAG_PROPERTIES = "properties";
  public static final String MSIX_TAG_PROPERTY = "property";
  public static final String MSIX_TAG_PARENTID = "parentid";
  public static final String MSIX_TAG_SESSIONCONTEXT = "sessioncontext";
  public static final String MSIX_TAG_SESSIONCONTEXTUSERNAME = "sessioncontextusername";
  public static final String MSIX_TAG_SESSIONCONTEXTPASSWORD = "sessioncontextpassword";
  public static final String MSIX_TAG_SESSIONCONTEXTNAMESPACE = "sessioncontextnamespace";

  // These tags create xml based streams
  public static final String MSIX_OPENINGTAG_PREFIX = "<";
  public static final String MSIX_OPENINGTAG_SUFFIX = ">";
  public static final String MSIX_CLOSINGTAG_PREFIX = "</";
  public static final String MSIX_CLOSINGTAG_SUFFIX = ">";
	
  // The current SDK version
  public static final String MSIX_CURRENT_VERSION = "2.0";
	
}
