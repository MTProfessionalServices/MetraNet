package com.metratech.sdk.base;
					
import java.util.*;
import java.net.*;
import java.io.*;
import com.metratech.sdk.utils.*;
			
/**
 * {internal}
 * Description:
 *		MTServerEntry class is derived from MTMeterBatch and is used for all Batch CRUD operations
 */
public class MTServerEntry
{
  public MTServerEntry () throws MTException
  {
    mPriority = -1;
    mServerName = "";
    mPortNumber = 80;
    mSecure = false;
    mUserName = "";
    mPassword = "";
  }

  public void setPriority (long priority)
  { this.mPriority = priority; } 
  public long getPriority ()
  { return mPriority; }

  public void setServerName (String servername)
  { this.mServerName = servername; } 
  public String getServerName ()
  { return mServerName; }

  public void setPortNumber (long portnumber)
  { this.mPortNumber = portnumber; } 
  public long getPortNumber ()
  { return mPortNumber; }

  public void setSecure (boolean secure)
  { this.mSecure = secure; } 
  public boolean getSecure ()
  { return mSecure; }

  public void setUserName (String username)
  { this.mUserName = username; } 
  public String getUserName ()
  { return mUserName; }

  public void setPassword (String password)
  { this.mPassword = password; } 
  public String getPassword ()
  { return mPassword; }

  private long mPriority;
  private String mServerName;
  private long mPortNumber;
  private boolean mSecure;
  private String mUserName;
  private String mPassword;
}
