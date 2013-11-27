package com.metratech.sdk.base;

import java.util.Date;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.math.BigDecimal;

/**
 *		MTMeterSession is the abstract base class which provides a protocol
 *		independent represenation of a metered session. It provides default implementations
 *		for the protocol independent accessor and mutator methods.
 *
 *		The MTMeterSession object holds the property values for a metered
 *		session.  Objects of this type are created by MTMeter.CreateSession.
 *		MTMeterSession.InitProperty should be called for each property value before
 *		MTMeterSession.Save or MTMeterSession.Close is called to send the properties to the
 *		server. MTMeterSession.GetProperty can be used to retrieve property values
 *		from the session.
 *
 */

public abstract class MTMeterSession
{
  public MTMeterSession()
  {
    this.mPropertyList = new Hashtable();
    mStatusCode = 0;
    mStatusMessage = null;
  }
  /**
   *	Creates a child session of the current session.
   *	Any number of children can be created for a parent session.
   *	Once MTMeterSession.Close has been called on a session, no more
   *	children can be created. Sessions that have been saved can still
   *	have more children added to them. When the child is deleted, it is
   *	removed from the parent. When a parent session is deleted, it deletes
   *	any children still connected to it.
   *
   * @param name The service name
   * @return meterSession Returns the newly created session
   * @exception MTException if unsuccessful
   */
  public abstract MTMeterSession createChildSession (// Service name of child session.
    String name) throws MTException;
  /**
   *	After each property has been initialized to the correct value,
   *	Close sends the session and its parents and children, when
   *	appropriate, to the metering server.
   *
   *  @return none
   *  @exception MTException if unsuccessful.
   */
  public abstract void close() throws MTException;


  /**
   *  Gets the name of the session.
   *
   *	@return the Session name.
   *  @exception MTException if unsuccessful
   */
  public String getName() throws MTException
  {
    return mName;
  };

  /**
   * 	Get a session identifier that uniquely identifies a session on
   *	the Metering Server.
   *
   * @return The Unique session ID
   * @exception MTException if unsuccessful
   */
  public String getSessionID() throws MTException
  {
    return sessionID;
  }

  /**
   *  Returns the result session from a session that was closed
   *	with the sychronous flag set.
   *
   *	@return	ResultSession The result session.
   */
  public abstract MTMeterSession getResultSession ();


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
   *	Sets a session's string property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its string value
   *  @return None
   */
  public void setProperty (//Property name.  The name must match the property name in the
    //service definition.
    String name,
    //The property's value.  The property must match the
    //type specified in the service definition.
    String value)
  {
    setProperty(name, (Object)value);
  }

  /**
   *	Sets a session's int property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its integer value
   *  @return None
   */
  public void setProperty (String name, int value)
  {
    mPropertyList.put(name.toLowerCase(), new MTMeterProperty (name, new Integer(value)));
  }

  /**
   *	Sets a session's float property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its float value
   *  @return None
   */
  public void setProperty (String name, float value)
  {
    mPropertyList.put(name.toLowerCase(), new MTMeterProperty (name, new Double(value)));
  }

  /**
   *	Sets a session's double property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its double value
   *  @return None
   */
  public void setProperty (String name, double value)
  {
    mPropertyList.put(name.toLowerCase(), new MTMeterProperty (name, new Double(value)));
  }

  /**
   *	Sets a session's BigDecimal property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its BigDecimal value
   *  @return None
   */
  public void setProperty (String name, BigDecimal value)
  {
    setProperty(name, (Object)value);
  }

  /**
   *	Sets a session's boolean property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its boolenan value
   *  @return None
   */
  public void setProperty (String name, boolean value)
  {
    mPropertyList.put(name.toLowerCase(), new MTMeterProperty (name, new Boolean(value)));
  }


  /**
   *	Sets a session's Date property value.  SetProperty may not
   *	be called after MTMeterSession.close has been called.
   *
   *  @param name The property name
   *  @param value Its Date value
   *  @return None
   */
  public void setProperty (String name, Date value)
  {
    setProperty(name, (Object)value);
  }

  /**
   *	Obtains a session's property value.
   *
   *  @param name The property name
   *  @return Value of the property
   */
  public Object getProperty (String name)
  {
    MTMeterProperty prop = (MTMeterProperty) mPropertyList.get(name.toLowerCase());
    if (prop != null)
      return prop.getValue();
    else
      return null;
  }

  public Enumeration properties ()
  {
    return mPropertyList.elements();
  }

  protected void setProperty (String name, Object val)
  {
//	    if (val == null) {
//	    	throw new NullPointerException("Attempting to set a null property value for property: " + name);
//	    }
    mPropertyList.put(name.toLowerCase(), new MTMeterProperty(name, val));
  }


  /**
   *	Removes a property from a session
   *
   *  @param name The property name
   *  @return name The property's value
   */
  public Object unsetProperty(String name) {
    return mPropertyList.remove(name.toLowerCase());
  }

  protected synchronized void setName (String name)
  {
    this.mName = name;
  }

  protected synchronized void setOwner (MTMeter owner)
  {
    mMeter = owner;
  }

  protected synchronized void setParent (MTMeterSession parent)
  {
    mParent = parent;
    if (mBatch != null)
      setBatch(parent.getBatch());
  }

  protected synchronized MTMeterBatch getBatch ()
  {
    return mBatch;
  }

  protected synchronized void setBatch (MTMeterBatch batch)
  {
    mBatch = batch;
    setProperty ("_collectionID", batch.getUID());
  }

  /**
   *	Obtains the status code for the response session, indicating any errors that might have occurred while metering this session
   *
   *  @return Value of the property
   */
  public long getStatusCode()
  {
    return mStatusCode;
  }

  /**
   *	Obtains the corresponding status message for the status code.
   *
   *  @param name The property name
   *  @return Value of the property
   */
  public String getStatusMessage()
  {
    return mStatusMessage;
  }

  public void setStatusCode(long statuscode)
  {
    this.mStatusCode = statuscode;
  }

  public void setStatusMessage(String statusmsg)
  {
    this.mStatusMessage = statusmsg;
  }

  public Vector getChildSessions()
  {
    return mChildren;
  }

  // The name of the session
  protected String mName;

  // The reference ID
  protected String referenceID;

  // The session ID
  protected String sessionID;

  // Error Code and Message, if applicable
  protected long mStatusCode;
  protected String mStatusMessage;

  // The MTMeter object that created me
  protected MTMeter mMeter;

  protected Vector mChildren;

  protected MTMeterSession mParent;

  // reference to the batch
  protected MTMeterBatch mBatch;

  // Keep a list of the session properties in a hash table
  protected Hashtable mPropertyList;

  // The MSIX PROTOCOL
  public static final int SESSION_PROTOCOL_MSIX = 0;
}
