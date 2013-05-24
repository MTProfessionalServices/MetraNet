/**************************************************************************
 * @doc MTPipelineJavaPlugin.java
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

import mtpipelinelib.*;  /* these classes generated from MTPipelineLib by jactivex */

import com.ms.com.Variant;
import com.ms.com.IEnumVariant;

/**
 * This class is a base class for all Java Plugins.  Derive yours from
 * it.
 */

public abstract class MTPipelineJavaPlugin implements IMTPipelinePlugIn2 {

    // To create a plugin, implement these abstract methods in your
    // derived class.  Waa-la.
    public abstract void Configure(Object aSystemContext, IMTConfigPropSet aPropSet);
    public abstract void ProcessSession(IMTSession aSession);
    public abstract int getProcessorInfo();
    public abstract void Shutdown();

    public void ProcessSessions(IMTSessionSet aSessions) {

	IEnumVariant iev = (IEnumVariant)(aSessions.get_NewEnum());
	Variant[] rgvar = new Variant[1];
	int[] nret = new int[1];

	// Process each session
	for (iev.Next(1, rgvar, nret); nret[0] != 0; iev.Next(1, rgvar, nret)) {
	    IMTSession session = (IMTSession) rgvar[0].toObject();
	    ProcessSession(session);
	}
    }

}
