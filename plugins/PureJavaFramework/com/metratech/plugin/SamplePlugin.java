package com.metratech.plugin;

import com.metratech.pipeline.*;
import java.util.*;


public class SamplePlugin implements IMTPipelinePlugIn2 {
	
	
	private IMTLog mLogger;
	private IMTNameID mNameID;
	private IEnumConfig mEnumConfig;
	private IMTSystemContext mSysContext;
	private int mDisconnectTimeID;
	private String fqn;
	private int serviceID;
	
	public void configure  (
							Object aSystemContext,
							IMTConfigPropSet propSet) throws java.io.IOException, com.linar.jintegra.AutomationException
															 
	{
		System.out.println("In Configure...");
		
		try{
			//HACK: remove later
			//com.linar.jintegra.AuthInfo.setDefault("METRATECH", "boris", "");
			
			mSysContext = new IMTSystemContextProxy (aSystemContext);
			System.out.println("SysContext test...");
			mEnumConfig = mSysContext.getEnumConfig();
			
			System.out.println("Testing EnumConfig inner...");
			System.out.println("Printing FQNs...");
			mEnumConfig.enumerateFQN();
			
			fqn  = mEnumConfig.nextFQN();
			System.out.println(fqn);
			System.out.println("Testing IMTLog inner...");
			mLogger = mSysContext.getLog();
			mLogger.logString(1, "Sample Pure Java Plugin: in Configure pure Java plugin");
			
			System.out.println("Testing IMTNameID inner ...");
			mNameID = mSysContext.getNameID();
			
			mDisconnectTimeID = mNameID.getNameID("DisconnectTime");
			
			System.out.println("mDisconnectTimeID ID: "+mDisconnectTimeID);
		}
		catch(Throwable ex)
		{ex.printStackTrace();}

	}

	public void shutdown  () throws java.io.IOException, com.linar.jintegra.AutomationException
	{
		System.out.println("In shutdown...");
		
		
	}

	public int getProcessorInfo  () throws java.io.IOException, com.linar.jintegra.AutomationException{ return -1;}

	public void processSessions  (
								  IMTSessionSet aSessions) throws java.io.IOException, com.linar.jintegra.AutomationException
	{
		try
		{
			System.out.println("In processSessions...");
			System.out.println(aSessions.getCount()+" sessions in set");
			
			
			Enumeration ss = aSessions.get_NewEnum();
			//System.out.println("Enum element of type: "+ss.nextElement().getClass().toString());
			
			IMTSession session = new IMTSessionProxy(ss.nextElement());
			
			System.out.println("Service ID: " + session.getServiceID());
			System.out.println("Service Name: " + mNameID.getName(session.getServiceID()));
			
			
			
			Enumeration props = session.get_NewEnum();
			
			IMTSessionProp prop;
			System.out.println("Property List:");
			try{
				for (; props.hasMoreElements() ;) 
				{
					prop = new IMTSessionPropProxy(props.nextElement());
					System.out.println(prop.getName());
					
					
				}
			}
			//suppress exception - off by one bug in JIntegra enumeration
			catch(NoSuchElementException ex){}
			
		}
		catch(Throwable ex)
		{ex.printStackTrace();}

			
 	}

}
