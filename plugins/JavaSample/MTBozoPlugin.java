/**************************************************************************
 * @doc MTBozoPlugin.java
 *
 * Copyright 2000 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Alan Blount
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

/**
 * This is a sample Java plugin.  Note that it extends then
 * MTPipelineJavaPlugin class.  Do the same in your plugin.
 */

import mtpipelinelib.*; /* these classes generated from MTPipelineLib by jactivex */

/**
 * Sample Plugin: MTBozoPlugin
 */
public class MTBozoPlugin extends MTPipelineJavaPlugin {

    private int mDisconnectTimeID;
    private int mConnectTimeID;
    private int mDurationID;
    private int mCostID;

    private String mAccountName;
    private String mDescription;

    private IMTLog mLogger;

    public void Configure(Object aSystemContext,
			  IMTConfigPropSet aPropSet) {

	// Get a logger by casting SystemContext argument to IMTLog.
	// Love that Java.
	mLogger = (IMTLog)aSystemContext;
	mLogger.LogString(1, "MTBozoPlugin: in Configure wonko");

	// Load configuration values.
	mAccountName = aPropSet.NextStringWithName("AccountName");
	mDescription = aPropSet.NextStringWithName("Description");
	
	// IDs of session attributes are in SystemContext argument.
	// Pull them out to be used later in ProcessSession
	mDisconnectTimeID = ((IMTNameID)aSystemContext).GetNameID("DisconnectTime");
	mConnectTimeID = ((IMTNameID)aSystemContext).GetNameID("ConnectTime");
	mDurationID = ((IMTNameID)aSystemContext).GetNameID("CallDuration");
	mCostID = ((IMTNameID)aSystemContext).GetNameID("CallCost");

	// Sanity check
	SleepLog("I can drink about 16 Heinekins");
	SleepLog("IDs: " + mDisconnectTimeID + " " + mConnectTimeID + " " + mDurationID);
    }

    public void ProcessSession(IMTSession aSession) {

	SleepLog("Processing Session");
	double disconnectTime = aSession.GetDoubleProperty(mDisconnectTimeID);
	double connectTime = aSession.GetDoubleProperty(mConnectTimeID);
	double duration = aSession.GetDoubleProperty(mDurationID);

	// Stoopid-easy rating
	double cost = duration * 0.05;

	SleepLog("Set cost: " + cost);
	aSession.SetDoubleProperty(mCostID, cost);

	SleepLog("Done Processing session");
    }

    // Hack: log flushing is busted.  This helps the logs get out
    // before crash.
    public void SleepLog(String msg) {
	try {
	    Thread.sleep(500);
	} catch(Exception e) { }
	mLogger.LogString(2, msg);
    }


    public int getProcessorInfo() {
	return 0;
    }


    public void Shutdown() {
	return;
    }
}
