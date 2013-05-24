/**************************************************************************
 * @doc SIMPLE
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

#include <vector>


// generate using uuidgen
//CLSID __declspec(uuid("1e01e610-13ab-11d3-a5a2-00c04f579c39")) CLSID_ParentCopyPlugin

CLSID CLSID_ParentCopyPlugin = { /* 1e01e610-13ab-11d3-a5a2-00c04f579c39 */
    0x1e01e610,
    0x13ab,
    0x11d3,
    {0xa5, 0xa2, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE ParentCopyPlugin 
	: public MTPipelinePlugIn<ParentCopyPlugin, &CLSID_ParentCopyPlugin>
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
  MTPipelineLib::IMTSessionServerPtr mSessionServer;
  MTPipelineLib::IMTNameIDPtr mNameID;
	
	BOOL mIsOkayToLogDebug;

  class Instruction {
  public:
    long ParentID;
    long ChildID;
    MTPipelineLib::MTSessionPropType Type;
  };

  std::vector<Instruction> mInstructions;
};


PLUGIN_INFO(CLSID_ParentCopyPlugin, ParentCopyPlugin,
						"MetraPipeline.ParentCopy.1", "MetraPipeline.ParentCopy", "Free")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ParentCopyPlugin ::PlugInConfigure"
HRESULT ParentCopyPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;
  mNameID = aNameID;

	mIsOkayToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

  
  MTPipelineLib::IMTConfigPropSetPtr props = aPropSet->NextSetWithName("PropertiesToCopy");
	try {
		while (props->NextMatches(L"Property", MTPipelineLib::PROP_TYPE_SET) == VARIANT_TRUE)
		{
      MTPipelineLib::IMTConfigPropSetPtr prop = props->NextSetWithName("Property");
			ASSERT (prop != NULL);
      _bstr_t parent = prop->NextStringWithName("ParentProp");
      _bstr_t type = prop->NextStringWithName("PropType");
      _bstr_t child = prop->NextStringWithName("ChildProp");
      Instruction inst;
      inst.ParentID = aNameID->GetNameID(parent);
      inst.ChildID = aNameID->GetNameID(child);
      if(_wcsicmp((wchar_t*)type, L"int32") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_LONG;
      }
      else if(_wcsicmp((wchar_t*)type, L"string") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_STRING;
      }
      else if(_wcsicmp((wchar_t*)type, L"timestamp") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_DATE;
      }
      else if(_wcsicmp((wchar_t*)type, L"decimal") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_DECIMAL;
      }
      else if(_wcsicmp((wchar_t*)type, L"double") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_DOUBLE;
      }
      else if(_wcsicmp((wchar_t*)type, L"int64") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_LONGLONG;
      }
      else if(_wcsicmp((wchar_t*)type, L"enum") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_ENUM;
      }
      else if(_wcsicmp((wchar_t*)type, L"bool") == 0)
      {
        inst.Type = MTPipelineLib::SESS_PROP_TYPE_BOOL;
      }
      else
      {
        char msg[512];
        sprintf(msg, "Unknown property type: '%s'", (char*)type);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, msg);
        return E_FAIL;
      }
      mInstructions.push_back(inst);
    }
	} catch(std::exception& stlException) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(stlException.what()));
		return E_FAIL;		
	}
  
  mSessionServer = MTPipelineLib::IMTSessionServerPtr(MTPROGID_SESSION_SERVER);
  if(mSessionServer == NULL)
    return Error("Failed to create session server object");

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ParentCopyPlugin ::PlugInProcessSession"
HRESULT ParentCopyPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  // Fetch the parent session
  long parentId = aSession->GetParentID();
  MTPipelineLib::IMTSessionPtr parent = mSessionServer->GetSession(parentId);

  if (parent != NULL)
  {
    for(std::vector<Instruction>::iterator it = mInstructions.begin();
        it != mInstructions.end();
        it++)
    {
      char buf[256];
      switch(it->Type)
      {
      case MTPipelineLib::SESS_PROP_TYPE_LONG:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
          aSession->SetLongProperty(it->ChildID,parent->GetLongProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, " Long Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;

        break;
      case MTPipelineLib::SESS_PROP_TYPE_STRING:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
          aSession->SetBSTRProperty(it->ChildID,parent->GetBSTRProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "String Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DATE:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
          aSession->SetOLEDateProperty(it->ChildID,parent->GetOLEDateProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "Date Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_TRUE)
          aSession->SetDecimalProperty(it->ChildID,parent->GetDecimalProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "Decimal Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_TRUE)
          aSession->SetDoubleProperty(it->ChildID,parent->GetDoubleProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "Double Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_LONGLONG) == VARIANT_TRUE)
          aSession->SetLongLongProperty(it->ChildID,parent->GetLongLongProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "LongLong Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
          aSession->SetEnumProperty(it->ChildID,parent->GetEnumProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "Enum Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_BOOL:
        if(parent->PropertyExists(it->ParentID, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
          aSession->SetBoolProperty(it->ChildID,parent->GetBoolProperty(it->ParentID));
        else if (mIsOkayToLogDebug)
        {
          sprintf(buf, "Bool Property '%s' not found in session", (char*)mNameID->GetName(it->ParentID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      default:
       {
          sprintf(buf, "Unsupported property type: '%d'", it->Type);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf); break;
        }
      }
    }
  }

  return S_OK;
}



