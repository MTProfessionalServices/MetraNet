/**************************************************************************
 * @doc
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <stdio.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <sessioniterate.h>


//shouldn't need it anymore: Syscontext object aggregates IEnumConfig interface
//#import <MTEnumConfig.tlb>

#define MAX __max


// generate using uuidgen
//CLSID __declspec(uuid("a5123e30-0d34-11d3-a59d-00c04f579c39")) CLSID_MTServiceLevelPlugin;

CLSID CLSID_MTLeaderPlugin = { /* a5123e30-0d34-11d3-a59d-00c04f579c39 */
    0xa5123e30,
    0x0d34,
    0x11d3,
    {0xa5, 0x9d, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE MTLeaderPlugin 
	: public MTPipelinePlugIn<MTLeaderPlugin, &CLSID_MTLeaderPlugin>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
  long mUserNameID,mUserRoleID,mLeaderNameID;

	long mChildServiceID;

	MTPipelineLib::IMTNameIDPtr mNameID;

  _bstr_t mChairStr;

	_bstr_t mChairStrFQN;

	MTPipelineLib::IEnumConfigPtr mEnumConfig;

};


PLUGIN_INFO(CLSID_MTLeaderPlugin, MTLeaderPlugin,
						"MetraPipeline.MTLeaderPlugin.1", "MetraPipeline.MTLeaderPlugin", "Free")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTLeaderPlugin ::PlugInConfigure"
HRESULT MTLeaderPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("UserName",&mUserNameID)
    DECLARE_PROPNAME("UserRole",&mUserRoleID)
    DECLARE_PROPNAME("LeaderName",&mLeaderNameID)
  END_PROPNAME_MAP

  HRESULT hr = ProcessProperties(inputs,aPropSet,aNameID,mLogger,PROCEDURE);

  if(SUCCEEDED(hr))
    mChairStr = aPropSet->NextStringWithName("chair");

//Get the full qualified name of chair;

	char buffer[1024];

	try
	{
		mEnumConfig = aSysContext->GetEnumConfig();
	}
	catch(_com_error e)
	{
		sprintf(buffer, "MTLeader plugin: unable to get IEnumConfig pointer from IMTSystemContext");
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
		return ReturnComError(e);
	}

	if (aPropSet->NextMatches("ServiceID", MTPipelineLib::PROP_TYPE_INTEGER))
		mChildServiceID = aPropSet->NextLongWithName("ServiceID");
	else
		mChildServiceID = -1;

	mNameID = aNameID;
  return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTLeaderPlugin ::PlugInProcessSession"
HRESULT MTLeaderPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  // LeaderName = username of child session whose UserRole = Chair

  MTPipelineLib::IMTSessionSetPtr aChildSet = aSession->SessionChildren();
  _bstr_t aLeaderStr("");

	SessionIterator it;
	// passing in the service ID to the iterator will filter out sessions that don't match
	// the service ID.  If mInputServiceId is -1, then all sessions are returned.
  if(FAILED(it.Init(aChildSet, mChildServiceID)))
    return Error("Failed to initialize Childset iterator");

	_bstr_t enum_space;
	_bstr_t enum_name;

  while (TRUE)
  {
    MTPipelineLib::IMTSessionPtr aChildSession = it.GetNext();
		if (aChildSession == NULL)
			break;

		long id = aChildSession->GetServiceID();

		long enumUserRole = aChildSession->GetLongProperty(mUserRoleID);

		_bstr_t aUserRoleStr = mNameID->GetName(enumUserRole);

		enum_space = mNameID->GetName(id);
		enum_name = mNameID->GetName(mUserRoleID);
		mChairStrFQN = mEnumConfig->GetFQN(enum_space, enum_name, mChairStr);
		
    if(!stricmp((const char *)aUserRoleStr, (const char *)mChairStrFQN)) {
      aLeaderStr =  aChildSession->GetBSTRProperty(mUserNameID);
      break;
    }
  }

	// allow an empty leader name -- dyoung
  //if(aLeaderStr == _bstr_t(""))
  //  return Error("No leader found in children");

  aSession->SetBSTRProperty(mLeaderNameID,aLeaderStr);

  return S_OK;
}


