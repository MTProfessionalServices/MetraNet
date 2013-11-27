package com.metratech.sdk.base;

import java.util.Vector;
import java.util.Enumeration;
import java.util.HashMap;

/**
 *		MTMeterSessionSet is the abstract base class which provides a protocol
 *		independent represenation of a set of metered sessions. It provides default
 *		implementations for the protocol independent accessor and mutator methods.
 *
 *		The MTMeterSessionSet object holds MTMeterSessions.  Objects of this type are created
 *		by MTMeter.CreateSessionSet . This object will accumulate MTMeterSession objects via
 *		the CreateSession method. Calling close() will submit the all sessions as a batch to
 *		the metering server.
 *
 *
 */

public abstract class MTMeterSessionSet
{
  public MTMeterSessionSet()
  {
  }

  /**
   * Creates a session within this session set.
   * When a sessionset is submited, all sessions within it are streamed inside a msix message.
   * Sessions that have children will be send normally, first the parent, then the children, and
   * then the remaining sessions in the set.
   *
   * @param name The service name
   * @return meterSession Returns the newly created session
   * @exception MTException if unsuccessful
   */
  public abstract MTMeterSession createSession (// Service name of child session.
    String name) throws MTException;

  /**
   *	Close will send all sessions on this set to the metering server.
   *
   *  @return none
   *  @exception MTException if unsuccessful.
   */
  public abstract void close() throws MTException;

  /**
   * 	Get a session set identifier that uniquely identifies a session on
   *	the Metering Server.
   *
   * @return The Unique session set ID
   * @exception MTException if unsuccessful
   */
  // TODO: Resolve the BatchID issue
  public String getSessionSetID() throws MTException
  {
    //return sessionsetID;
    return "";
  }

  /**
   *  Returns the result session from a session that was closed
   *	with the sychronous flag set.
   *
   *	@return	ResultSession The result session.
   */
  public abstract MTMeterSessionSet getResultSessionSet ();


  /**
   *  Obtains the session's synchronous flag.
   *
   *	@return	The session's synchronous flag.
   */
  public abstract boolean getSynchronous ();

  /**
   *  Marks this session as synchronous. When the session is closed, it will wait
   *	for a result session generated on the metering server as processed by the pipeline.
   *	Since this operation may take a long time to process, it should be used sparingly.
   *
   *  @param Synchronous Is this session marked as synchronous.
   */
  public abstract void setSynchronous (// Wait for a result session.
    boolean callSynchronous);

  /**
   *  Sets the Session Context in this SessionSet
   *
   *
   *	@return	void
   */
  public abstract void setSessionContext(String SessionContext);

  /**
   *  Gets the Session Context from this SessionSet
   *
   *
   *	@return	void
   */
  public abstract String getSessionContext();

  /**
   *  Sets the Session Context Username in this SessionSet
   *
   *
   *	@return	void
   */
  public abstract void setSessionContextUsername(String Username);

  /**
   *  Gets the Session Context Username from this SessionSet
   *
   *
   *	@return	void
   */
  public abstract String getSessionContextUsername();

  /**
   *  Sets the Session Context Password in this SessionSet
   *
   *
   *	@return	void
   */
  public abstract void setSessionContextPassword(String Password);

  /**
   *  Gets the Session Context Password from this SessionSet
   *
   *
   *	@return	void
   */
  public abstract String getSessionContextPassword();

  /**
   *  Sets the Session Context Namespace in this SessionSet
   *
   *
   *	@return	void
   */
  public abstract void setSessionContextNamespace(String Namespace);

  /**
   *  Gets the Session Context Namespace from this SessionSet
   *
   *
   *	@return	void
   */
  public abstract String getSessionContextNamespace();

  public Vector getSessions()
  {
    return mSet;
  }

  protected synchronized void setOwner (MTMeter owner)
  {
    mMeter = owner;
  }

	protected synchronized MTMeterBatch getBatch ()
	{
		return mBatch;
	}

	protected synchronized void setBatch (MTMeterBatch batch)
	{
		mBatch = batch;
	}

  // The MTMeter object that created me
  protected MTMeter mMeter;

	// reference to the batch
	protected MTMeterBatch mBatch;

  protected Vector mSet;

  // The MSIX PROTOCOL
  public static final int SESSION_PROTOCOL_MSIX = 0;
}
