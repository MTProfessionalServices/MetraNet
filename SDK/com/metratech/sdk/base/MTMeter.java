package com.metratech.sdk.base;
	
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;

/**
 *		The MTMeter object controls the rest of the metering library.  Each
 *		application using the library should have a MTMeter object that is
 *		used to generate MTMeterSession objects.
 */
public interface MTMeter
{	
	/**
	 * Initializes the SDK.
	 * @param None
	 * @return None.
	 * @exception MTException if unsuccessful 	 
	 */
	public void startup() throws MTException;
	
	/**
	 * Terminates the SDK.
	 * @param None
	 * @return None.
	 * @exception MTException if unsuccessful 	 
	 */
	public void shutdown() throws MTException;
	
	/**
	 *	Creates the named metered session to hold property values that are
	 *	used to describe a metered event.
	 * @param service The name of the service.
	 * @return the newly created MTMeterSession object.
	 * @exception MTException if unsuccessful.
	 */
	public MTMeterSession createSession (// The name of the service.  
										 // Must match the name of a service defined on
										 // the metering server.
										 String name) throws MTException;
	
	/**
	 *	Creates a session set.
	 *
	 * 
	 * @return the newly created MTMeterSessionSet object.
	 * @exception MTException if unsuccessful.
	 */
	public MTMeterSessionSet createSessionSet () throws MTException;	

	/**
	 *	Creates a batch.
	 *
	 * 
	 * @return the newly created MTMeterBatch object.
	 * @exception MTException if unsuccessful.
	 */
	public MTMeterBatch createBatch () throws MTException;	
		
	/**
	 *	Loads a batch using the batch UID.
	 *
	 * @param UID The UID of the batch.
	 * @return the newly created MTMeterBatch object.
	 * @exception MTException if unsuccessful.
	 */
	public MTMeterBatch openBatchByUID (String UID) throws MTException;	
		
	/**
	 *	Loads a batch using the name/namespace combination.
	 *
	 * @param name The name of the batch.
	 * @param namespace The namespace of the batch.
	 * @return the newly created MTMeterBatch object.
	 * @exception MTException if unsuccessful.
	 */
	public MTMeterBatch openBatchByName (String name, String namespace, String sequenceNumber) throws MTException;	
		
	/**
	 *	Meter from an input stream.
	 * 
	 *  @param stream The InputStream object containing MSIX sessions.
	 *  @return None
	 *  @exception MTException if unsuccessful.
	 */
	public void meterStream (// Input stream containing sessions in metered format.
							 InputStream stream) throws MTException;

	/**
	 *	Add a server entry to the pool of available server entries. 
	 * 
	 *  @param connection The MTServerEntry object representing a specific 
	 *  Server configuration.
	 *  @return None.
	 *  @exception MTException if unsuccessful.
	 */
	public void addServer (// The MTServerEntry object that represents
												 // the configuration of the metering server.
							   MTServerEntry serverEntry) throws MTException;

	/**
	 * Get a list of serverentries in the pool.
	 *
	 * @return An Enumeration object which contains all of the active
	 *		   Metering server entries.
	 * .
	 */
	public Enumeration serverEntries();
	
	/**
	 * Set the logging level.
	 * @param logLevel The new logging level
	 * @return None.
	 * ; 
	 */
	public void setLoggingLevel (// The new logging level
														   int logLevel);
	
	/**
	 * Get the logging level.
	 * 
	 * @param None.
	 * @return The current logging level.
	 * .
	 */
	public int getLoggingLevel ();
	
	
	/**
	 * Sets the current logging stream.
	 * 
	 * @param OutputStream The new logging stream.
	 * @return None.
	 * .
	 */
	public void setLoggingStream (// The logging stream
															OutputStream logStream);
	
	
	/**
	 * Obtains the current logging stream.
	 * 
	 * @param None
	 * @return The current logging output stream
	 * .
	 */
	public OutputStream getLogginStream ();
	
	/**
	 * Gets the current journal file name.
	 * 
	 * @param None
	 * @return Journal file name
	 * .
	 */	
	public String getJournal();
    
    /**
	 * flushes the journal to a file.
	 * 
	 * @param None
	 * @return Journal file name
	 * .
	 */	
	public void flushJournal();
	
    /**
	 * Sets the current journal file
	 * 
	 * @param String filename
	 * @return none
	 * .
	*/
    public void setJournal(String strJournal) throws MTException;	

    /**
	 * Retrieve the timeout value for each connection, in milliseconds
	 * 
	 * @param none
	 * @return int msecTimeout
	 * .
	 */
    public int getTimeoutValue();

    /**
	 * Retrieve the number of retries for each connection
	 * 
	 * @param none
	 * @return int Timeout 
	 * .
	 */
    public int getNumberofRetries();

    /**
	 * Sets the timeout value for each connection
	 * 
	 * @param int msecTimeout
	 * @return none
	 * .
	 */
    public void setTimeoutValue(int msecTimeout);

    /**
	 * Sets the number of retries for each connection
	 * 
	 * @param int mRetries
	 * @return none
	 * .
	 */
    public void setNumberofRetries(int mRetries);


	public static final int LOG_LEVEL_NONE = 0;
	public static final int LOG_LEVEL_DEBUG = 1;
}
