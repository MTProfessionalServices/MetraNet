// Source File Name:   MTJournal.java
// Author: Murthy Kuchibhotla, 06/26/2001

package com.metratech.sdk.base;

import java.io.*;
import java.util.Enumeration;
import java.util.Hashtable;

public class MTJournal
{

    public MTJournal() throws MTException
    {
        m_strFileName = null;
        m_bLoaded = false;
        m_htInternal = null;
        setMeterStore("sdkjournal.dat");
    }

    public MTJournal(String s) throws MTException
    {
        m_strFileName = null;
        m_bLoaded = false;
        m_htInternal = null;
        setMeterStore(s);
    }

    public boolean addItem(String s) throws MTException
    {
        if(m_htInternal == null)
        {
            return false;
        } else
        {
			addItem(s, STATUS_NOTSENT);
            return true;
        }
    }

    public boolean addItem(String p_strUID, Integer p_nStatus) throws MTException
    {
        if(m_htInternal == null)
            return false;

		m_htInternal.put(p_strUID, p_nStatus);
		
		if ( p_nStatus.intValue() == MTJournal.STATUS_INPROGRESS.intValue() )
			return true;
		
		try
		{
			String strTemp = p_strUID + "|" + p_nStatus.intValue() + "|";
			m_bwWrite.write(strTemp, 0, strTemp.length());
			m_bwWrite.newLine();
			m_bwWrite.flush();
			return true;
		}
		catch(Exception e)
		{
			throw new MTException(e.getMessage());
		}            
    }

    public String getFileName()
    {
        return m_strFileName;
    }

    public boolean hasSent(String s)
    {
        if(m_htInternal == null)
            return false;
        Integer integer = (Integer)m_htInternal.get(s);
        if(integer == null)
            return false;
        return integer.intValue() == STATUS_SENT.intValue() || integer.intValue() == STATUS_INPROGRESS.intValue();
    }

    public Enumeration keys()
    {
        if(m_htInternal == null)
            return null;
        else
            return m_htInternal.keys();
    }

    public boolean loadJournal()
    {
        if(m_bLoaded)
            return true;
		
		BufferedReader br = null;
		
        try
        {
			// Read the file into hashtable
			br = new BufferedReader(new FileReader(m_strFileName));
			
			String	strTemp = "";
			String	strTempUID = "";
			Integer	nTempStatus = STATUS_NOTSENT;
			int		nIndex = -1;
				
			while ( (strTemp = br.readLine()) != null ) 
			{
				//System.out.println("(Murthy) -- The line read is ...: " + strTemp);				
				strTemp = strTemp.trim();				
				if ( strTemp.length() <= 0 )
					continue;
				try
				{
					nIndex = strTemp.indexOf('|');
					strTempUID = strTemp.substring(0, nIndex);				
					if ( strTemp == null )
						continue;
					
					strTemp = strTemp.substring(nIndex+1);
					nIndex = strTemp.indexOf('|');
					nTempStatus = new Integer(strTemp.substring(0,nIndex));
	
					//System.out.println("(Murthy) -- Before Adding ...: " + strTempUID + " the value " + nTempStatus.intValue());	
					m_htInternal.put(strTempUID, nTempStatus);
				}
				catch(Exception ex)
				{
					System.out.println("Warning: Detected invalid format in journal. Skipping the line..");
					continue;
				}
			}
			
			br.close();
            m_bLoaded = true;
			
			//System.out.println("(Murthy) -- The number of keys in the hashtable ..: " + m_htInternal.size());
            return true;
        }
        catch(FileNotFoundException _ex)
        {
            System.out.println("Warning: Journal file <" + m_strFileName + "> doesn't exist. It will be created by SDK.");
            m_bLoaded = true;
            return true;
        }
        catch(Exception exception)
        {
			try
			{
				br.close();
			}
			catch(IOException e)
			{
				System.out.println("Fatal Error");
			}
            System.out.println("Exception occurred while loading from file <" + m_strFileName + ">. " + exception.getMessage());
        }
		
        return false;
    }

    public void setMeterStore(String s) throws MTException
    {
        m_strFileName = s;
        m_htInternal = new Hashtable(3000, 0.75F);
        boolean flag = loadJournal();
		
		try
		{
			// Open the same journal file and obtain exclusive lock on that file.
			m_bwWrite = new BufferedWriter(new FileWriter(m_strFileName, true));
		}
		catch(IOException e)
		{
			throw new MTException("Cannot obtain exclusive lock on file <" + m_strFileName + ">. " + e.getMessage());
		}
    }

	// closes the file pointer.
    public boolean writeJournal()
    {
		try
		{
			m_bwWrite.close();
			return true;
		}
		catch(Exception e)
		{
			System.out.println("Warning: Cannot close the Journal File <" + m_strFileName + ">.");
			return false;
		}
    }

    private String m_strFileName;
    private boolean m_bLoaded;
    private Hashtable m_htInternal;
	
	private BufferedWriter m_bwWrite;
	
    public static final Integer STATUS_SENT = new Integer(0);
    public static final Integer STATUS_NOTSENT = new Integer(1);
    public static final Integer STATUS_INPROGRESS = new Integer(2);
	
	 /*/driver to test the journal file 
	public static void main(String argv[])
	{
		try
		{
			MTJournal mtj = new MTJournal("sdkjournal.dat");
			
			for(int i = 0; i < 10; ++i )
				mtj.addItem("TestItem " + i);
			
			Enumeration e = mtj.keys();
			
			
			while ( e.hasMoreElements() )
			{
				String strTemp = (String)e.nextElement();
				System.out.println("The value for key <" + strTemp + "> and the value is...: " + mtj.hasSent( strTemp ) );
			}
		}
		catch(Exception e)
		{
			System.out.println("Exception occurred " + e.getMessage());
		}
	}
	*/
}
