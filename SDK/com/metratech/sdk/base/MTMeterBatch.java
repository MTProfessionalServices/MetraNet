package com.metratech.sdk.base;

import java.util.*;
import java.text.*;
import java.io.*;

/**
 * MTMeterBatch is the abstract base class which provides a protocol 
 * independent represenation of a set of metered sessions. It provides default 
 * implementations for the protocol independent accessor and mutator methods.
 */
public abstract class MTMeterBatch
{
  public MTMeterBatch()
  {
  }
	
	/**
   * Gets the ID of the batch
   * @return long
	 */
  public abstract long getID();  

	/**
   * Sets the ID of the batch
   * @return void
	 */
  //private void setID(long ID);  

  /**
   * Gets the UID of the batch
   * @return String
	 */
  public abstract String getUID();  

	/**
   * Sets the UID of the batch
   * @return void
	 */
  //private abstract void setUID(String UID);  

	/**
   * Sets the Name of the Batch
	 * @param Name The name of the batch 
   * @return void
	 */
  public abstract void setName(String Name);

  /**
   * Gets the name of the batch
   * @return String
	 */
  public abstract String getName();  

	/**
   * Sets the Namespace of the batch
	 * @param Namespace The namespace of the batch 
   * @return void
	 */
  public abstract void setNamespace(String Namespace);

  /**
   * Gets the namespace of the batch
   * @return String
	 */
  public abstract String getNamespace();  

  /**
   * Gets the status of the batch
   * @return String
	 */
  public abstract String getStatus();  

  /**
   * Gets the creation date of the batch
   * @return Date
	 */
  public abstract Date getCreationDate();  

  /**
   * Gets the completion date of the batch
   * @return Date
	 */
  public abstract Date getCompletionDate();  

	/**
   * Sets the Source of the Batch
	 * @param Source The source of the batch 
   * @return void
	 */
  public abstract void setSource(String Source);

  /**
   * Gets the source of the batch
   * @return Date
	 */
  public abstract String getSource();  

	/**
   * Sets the Source Creation Date of the Batch
	 * @param SourceCreationDate The source creation date of the batch 
   * @return void
	 */
  public abstract void setSourceCreationDate(Date SourceCreationDate);

  /**
   * Gets the Source Creation Date of the batch
   * @return Date
	 */
  public abstract Date getSourceCreationDate();  

  /**
   * Gets the Completed Count of the batch
   * @return CompletedCount
	 */
  public abstract long getCompletedCount();  

	/**
   * Sets the Sequence Number of the batch
	 * @param SequenceNumber The sequence number of the batch 
   * @return void
	 */
  public abstract void setSequenceNumber(String SequenceNumber);

  /**
   * Gets the sequence number of the batch
   * @return String
	 */
  public abstract String getSequenceNumber();  

	/**
   * Sets the Expected Count of the batch
	 * @param ExpectedCount The expected count of the batch 
   * @return void
	 */
  public abstract void setExpectedCount(long ExpectedCount);

  /**
   * Gets the expected count of the batch
   * @return long
	 */
  public abstract long getExpectedCount();  

  /**
   * Gets the failure count of the batch
   * @return long
	 */
  public abstract long getFailureCount();  

	/**
   * Sets the Metered Count of the batch
	 * @param MeteredCount The metered count of the batch 
   * @return void
	 */
  public abstract void setMeteredCount(long MeteredCount);

  /**
   * Gets the metered count of the batch
   * @return long
	 */
  public abstract long getMeteredCount();  

  /**
   * MarkAsFailed will mark the batch as failed in the database
   * @exception MTException if unsuccessful
   */
  public abstract void markAsFailed (String comment) throws MTException;

  /**
   * MarkAsDismissed will mark the batch as dismissed in the database
   * @exception MTException if unsuccessful
   */
  public abstract void markAsDismissed (String comment) throws MTException;

  /**
   * MarkAsCompleted will mark the batch as completed in the database
   * @exception MTException if unsuccessful
   */
  public abstract void markAsCompleted (String comment) throws MTException;

  /**
   * MarkAsBackout will mark the batch as backout-able in the database
   * @exception MTException if unsuccessful
   */
  public abstract void markAsBackout (String comment) throws MTException;

  /**
   * UpdateMeteredCount will mark the batch as completed in the database
   * @exception MTException if unsuccessful
   */
  public abstract void updateMeteredCount (long count) throws MTException;
  
  /**
   * When a sessionset is submited, all sessions within it are streamed inside a 
	 * msix message. Sessions that have children will be send normally, first the 
	 * parent, then the children, and then the remaining sessions in the set.
   *
   * @param name The service name
   * @return meterSession Returns the newly created session
   * @exception MTException if unsuccessful
   */
  public abstract MTMeterMSIXSession createSession (// Service name of child session.
    String name) throws MTException;

  /**
   * Create a session set
   * @param name The service name
   * @return meterSession Returns the newly created session
   * @exception MTException if unsuccessful
   */
  public abstract MTMeterMSIXSessionSet createSessionSet () throws MTException;

  /**
   * Refresh itself
   * @exception MTException if unsuccessful
   */
  public abstract void refresh () throws MTException;

  /**
   * Save will store the batch details in the database
   * @exception MTException if unsuccessful
   */
  public abstract void save () throws MTException;
	
	protected synchronized void setOwner (MTMeter owner)
	{
		mMeter = owner;
	}

	// SetSDKBatch

  // The object to self
  protected MTMeterBatch mBatch = null;

  // The MTMeter object that created me
  protected MTMeter mMeter = null;
	
}
