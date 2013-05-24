/**************************************************************************
 *
 * Copyright 2002 by MetraTech Corporation
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
 ***************************************************************************/


#include <metra.h>
#include <propids.h>
#include <PlugInSkeleton.h>
#include <reservedproperties.h>
#include <vector>

// generate using uuidgen
CLSID CLSID_PROPAGATEPROPERTIES = { /* 11ce899a-b85a-45e1-a6c7-cd23b575a9df */
    0x11ce899a,
    0xb85a,
    0x45e1,
    {0xa6, 0xc7, 0xcd, 0x23, 0xb5, 0x75, 0xa9, 0xdf}
  };



class ATL_NO_VTABLE MTPropagateProperties
	: public MTPipelinePlugIn<MTPropagateProperties, &CLSID_PROPAGATEPROPERTIES>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected:
  HRESULT Recurse(MTPipelineLib::IMTSessionPtr aSession, bool bIsRoot);
	void GetParentProperties(MTPipelineLib::IMTSessionPtr aSession);
	void SetChildProperties(MTPipelineLib::IMTSessionPtr aSession);
	
private:
  class Instruction {
  public:
    long PropID;
    bool NullIndicator;
    MTPipelineLib::MTSessionPropType Type;
    union
    {
      long LongValue;
      long EnumValue;
      VARIANT_BOOL BoolValue;
      __int64 LongLongValue;
      double DoubleValue;
      DECIMAL DecimalValue;
    } Value;

    Instruction(long propid, MTPipelineLib::MTSessionPropType ty)
      :
      PropID(propid),
      Type(ty),
      NullIndicator(true)
    {
    }
  };
  
	typedef std::vector<Instruction *> Instructions;
	Instructions mInstructions;
};

PLUGIN_INFO(CLSID_PROPAGATEPROPERTIES, MTPropagateProperties,
						"MetraPipeline.PropagateProperties.1", "MetraPipeline.PropagateProperties", "Free")


HRESULT MTPropagateProperties::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  const char* pFuncName = "MTPropagateProperties::PlugInConfigure";

	try 
	{
		MTPipelineLib::IMTConfigPropSetPtr propertiesSet = aPropSet->NextSetWithName(L"Properties");
		if (propertiesSet)
		{
			MTPipelineLib::IMTConfigPropSetPtr propertySet = propertiesSet->NextSetWithName(L"Property");
			while (propertySet)
			{
				long propID = aNameID->GetNameID(propertySet->NextStringWithName(L"Name"));

				// TODO: support other data types
				std::string dataType = propertySet->NextStringWithName(L"Type");
				if (dataType == "int32")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_LONG));
        }
				else if (dataType == "enum")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_ENUM));
        }
				else if (dataType == "bool")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_BOOL));
        }
				else if (dataType == "double")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_DOUBLE));
        }
				else if (dataType == "int64")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_LONGLONG));
        }
				else if (dataType == "decimal")
        {
          mInstructions.push_back(new Instruction(propID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL));
        }
        else
        {
					return Error("Only properties of type int32, enum, bool, double and int64 are currently supported!");
        }
				
				propertySet = propertiesSet->NextSetWithName(L"Property");
			}
		}
	}
  catch(_com_error& err) 
	{
    return ReturnComError(err);
	}
  return S_OK;
}

HRESULT MTPropagateProperties::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr;

  try {
		
		// only processes parents
		if (aSession->GetIsParent() == VARIANT_FALSE) 
			return S_OK;

		GetParentProperties(aSession);
		hr = Recurse(aSession, true);
	}
  catch(_com_error& err) {
    hr = ReturnComError(err);
  }
  return hr;
}

HRESULT MTPropagateProperties::Recurse(MTPipelineLib::IMTSessionPtr aSession, bool bIsRoot)
{
  if (!bIsRoot)
	{
    SetChildProperties(aSession);
		
		// base case: session is not a parent
		if (aSession->GetIsParent() == VARIANT_FALSE)
			return S_OK;
  }

  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSession->SessionChildren());
	if (FAILED(hr))
		return hr;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

    hr = Recurse(session, false);
		if (FAILED(hr))
			return hr;
  }

  return S_OK;
}

void MTPropagateProperties::GetParentProperties(MTPipelineLib::IMTSessionPtr aSession)
{
	for (Instructions::iterator it = mInstructions.begin();
			 it != mInstructions.end(); it++)
	{
    if(aSession->PropertyExists((*it)->PropID, (*it)->Type) == VARIANT_TRUE)
    {
      (*it)->NullIndicator = false;      
      switch((*it)->Type)
      {
      case MTPipelineLib::SESS_PROP_TYPE_LONG:
        (*it)->Value.LongValue = aSession->GetLongProperty((*it)->PropID);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
        (*it)->Value.EnumValue = aSession->GetEnumProperty((*it)->PropID);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_BOOL:
        (*it)->Value.BoolValue = aSession->GetBoolProperty((*it)->PropID);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
        (*it)->Value.DoubleValue = aSession->GetDoubleProperty((*it)->PropID);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
        (*it)->Value.LongLongValue = aSession->GetLongLongProperty((*it)->PropID);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
      {
        _variant_t varDec = aSession->GetDecimalProperty((*it)->PropID);
        (*it)->Value.DecimalValue = (DECIMAL) varDec;
        break;
      }
      }
    }
    else
    {
      (*it)->NullIndicator = true;
    }
	}
}

void MTPropagateProperties::SetChildProperties(MTPipelineLib::IMTSessionPtr aSession)
{
	for (Instructions::iterator it = mInstructions.begin();
			 it != mInstructions.end(); it++)
  {
    if ((*it)->NullIndicator == false)
    {
      switch((*it)->Type)
      {
      case MTPipelineLib::SESS_PROP_TYPE_LONG:
        aSession->SetLongProperty((*it)->PropID, (*it)->Value.LongValue);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
        aSession->SetEnumProperty((*it)->PropID, (*it)->Value.EnumValue);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_BOOL:
        aSession->SetBoolProperty((*it)->PropID, (*it)->Value.BoolValue);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
        aSession->SetDoubleProperty((*it)->PropID, (*it)->Value.DoubleValue);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
        aSession->SetLongLongProperty((*it)->PropID, (*it)->Value.LongLongValue);
        break;
      case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
      {
        _variant_t decVal((*it)->Value.DecimalValue);
        aSession->SetDecimalProperty((*it)->PropID, decVal);
        break;
      }
      }
    }
  }
}

HRESULT MTPropagateProperties::PlugInShutdown()
{
	for (Instructions::iterator it = mInstructions.begin();
			 it != mInstructions.end(); it++)
  {
    delete (*it);
  }
  mInstructions.clear();
  return S_OK;
}
