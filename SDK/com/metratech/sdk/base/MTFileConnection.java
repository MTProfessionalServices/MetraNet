package com.metratech.sdk.base;


import java.io.*;
import java.net.*;

/**  *   The MTFileConnection class wraps the OutputStream class and 
 *   implements the MeterConnection interface. This class is used 
 *   to represent a connection to a metering sever as a flat file.
 */
public class MTFileConnection 
    implements MTMeterConnection
{
    public MTFileConnection (String name, String file) // throws IOException
    { 
        mFile = file;
        setName(file);

        // this.mOutputStream = new FileOutputStream (file);
    }

    //    public MTFileConnection (OutputStream oStream) throws IOException
    //    { 
    //  this.mOutputStream = oStream;
    //    }

    protected MTFileConnection () 
    { 
    }

    /**          *      Obtains the Connection's name.
     *  
     *  @param none.
     *  @return The connection's name.
     *  . 
     */
    public String getName ()
    {
        return this.mName;
    }
        
    /**          *      Sets the connection's unique name.
     *  @param Name The unique connection name.                 
     *  @return None.
     *  .       
     */
    public synchronized void setName (// Name of the connection
                                      String name) 
    {
        this.mName = name;
    }   


    /**          *      Gets the priority of the connection.
     *  
     *  @param None.
     *  @return The connection priority. 
     *  .
     */ 
    public int getPriority ()   
    {
        return this.mPriority;
    }

    /** 
     * Sets the priority of the connection.
     * @param priority the new priority  
     * @return None.
     * 
     */ 
    public synchronized void setPriority (// Priority of this connection
                                          int priority)
    {
        this.mPriority = priority;
    }

    /**
     * Gets the connection's InputStream.
     * @param None
     * @return InputStream The connection's InputStream.
     * @exception IOException as propagated.
     */
    public InputStream getInputStream () throws IOException
    {
        return null;
    }

    /**
     * Gets the connection's OutputStream.
     * @param None
     * @return OutputStream The connection's OutputStream.
     * @exception IOException as propagated.
     */                 
    public OutputStream getOutputStream () throws IOException
    {
        // Return a new outputstream
        return new FileOutputStream(mFile, true);
    }

    public boolean equals (Object obj)
    {
        return (this.mName == ((MTMeterConnection)obj).getName()); 
    }
    
    public URL getMTConnectionURL()
    {
        return null;    
    }

    public HttpURLConnection getConnection()
    {
        return null;    
    }

    private String mName;               // the connection's name
    private String mFile;               // the connection's filename
    private int mPriority;              // its priority
}
