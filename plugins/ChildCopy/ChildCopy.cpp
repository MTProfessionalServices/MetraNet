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

#include <map>
#include <vector>


// generate using uuidgen
//CLSID __declspec(uuid("1e01e610-13ab-11d3-a5a2-00c04f579c39")) CLSID_ChildCopyPlugin

CLSID CLSID_ChildCopyPlugin = { /* 5a5b375e-9055-457c-a789-d0c3d85d62fc */
    0x5a5b375e,
    0x905,
    0x457c,
    {0xa7, 0x89, 0xd0, 0xc3, 0xd8, 0x5d, 0x62, 0xfc}
  };

class ATL_NO_VTABLE ChildCopyPlugin 
	: public MTPipelinePlugIn<ChildCopyPlugin, &CLSID_ChildCopyPlugin>
{
public:
  ~ChildCopyPlugin();
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

  class Instruction {
  public:
    long ParentID;
    long ChildID;
    MTPipelineLib::MTSessionPropType Type;
  };

  // The instructions indexed by service def of the child.
  std::map<long, std::vector<Instruction>* > mInstructions;
  // For use at runtime to record if we've processed a service def.
  std::map<long, bool> mExecuted;
};


PLUGIN_INFO(CLSID_ChildCopyPlugin, ChildCopyPlugin,
						"MetraPipeline.ChildCopy.1", "MetraPipeline.ChildCopy", "Free")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ChildCopyPlugin ::PlugInConfigure"
HRESULT ChildCopyPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;
  mNameID = aNameID;

  
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
      // Index the instructions by service type.
      long serviceDefID = mNameID->GetNameID(prop->NextStringWithName("ServiceDefValue"));
      std::map<long, std::vector<Instruction>* >::const_iterator mapIt = mInstructions.find(serviceDefID);
      if(mInstructions.end() == mapIt)
      {
        mInstructions[serviceDefID] = new std::vector<Instruction>();
        mExecuted[serviceDefID] = false;
      }
      mInstructions[serviceDefID]->push_back(inst);
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
#define PROCEDURE "ChildCopyPlugin ::PlugInProcessSession"
HRESULT ChildCopyPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  // Mark all service defs to be processed.
  int serviceDefCount=0;
  for(std::map<long, bool>::iterator mapIt = mExecuted.begin();
      mExecuted.end() != mapIt;
      mapIt++)
  {
    serviceDefCount += 1;
    mapIt->second = false;
  }
  
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSession->SessionChildren());
	if (FAILED(hr))
		return hr;

	while (TRUE && serviceDefCount > 0)
	{
		MTPipelineLib::IMTSessionPtr child = it.GetNext();
		if (child == NULL)
			break;

    long childServiceID = child->ServiceID;
    std::map<long, bool>::iterator mapIt = mExecuted.find(childServiceID);
    if (mapIt == mExecuted.end() || mapIt->second == true)
    {
      continue;
    }

    // Got a service def to process.
    mapIt->second = true;
    serviceDefCount -= 1;

    std::vector<Instruction> * inst = mInstructions[childServiceID];
    for(std::vector<Instruction>::const_iterator vecIt = inst->begin();
        vecIt != inst->end();
        vecIt++)
    {
      char buf[256];
      switch(vecIt->Type)
      {
      case MTPipelineLib::SESS_PROP_TYPE_LONG:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
          aSession->SetLongProperty(vecIt->ParentID,child->GetLongProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, " Long Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;

        break;
      case MTPipelineLib::SESS_PROP_TYPE_STRING:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
          aSession->SetBSTRProperty(vecIt->ParentID,child->GetBSTRProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "String Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DATE:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
          aSession->SetOLEDateProperty(vecIt->ParentID,child->GetOLEDateProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "Date Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_TRUE)
          aSession->SetDecimalProperty(vecIt->ParentID,child->GetDecimalProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "Decimal Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_TRUE)
          aSession->SetDoubleProperty(vecIt->ParentID,child->GetDoubleProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "Double Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_LONGLONG) == VARIANT_TRUE)
          aSession->SetLongLongProperty(vecIt->ParentID,child->GetLongLongProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "LongLong Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
          aSession->SetEnumProperty(vecIt->ParentID,child->GetEnumProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "Enum Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      case MTPipelineLib::SESS_PROP_TYPE_BOOL:
        if(child->PropertyExists(vecIt->ChildID, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
          aSession->SetBoolProperty(vecIt->ParentID,child->GetBoolProperty(vecIt->ChildID));
        else
        {
          sprintf(buf, "Bool Property '%s' not found in session", (char*)mNameID->GetName(vecIt->ChildID));
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf); 
        }
        break;
      default:
       {
          sprintf(buf, "Unsupported property type: '%d'", vecIt->Type);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf); break;
        }
      }
    }
  }

  return S_OK;
}


ChildCopyPlugin::~ChildCopyPlugin()
{
  for(std::map<long, std::vector<Instruction>* >::iterator it = mInstructions.begin();
      it != mInstructions.end();
      it++)
  {
    delete it->second;
  }
}
