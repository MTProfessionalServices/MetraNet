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


#include <TransactionPlugInSkeleton.h>
#include <stdio.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <mtcomerr.h>

#include <vector>
#include <map>

#include <MTSQLInterpreter.h>
#include <MTSQLInterpreterSessionInterface.h>
#include <MTSQLSelectCommand.h>

#import <MTProductCatalog.tlb> rename("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//MTService Endpoint Extended Property structure
//(Keep your mind out of the gutter!)
struct MTSEExProp {
  AccessPtr Access;                             //Session address (MTSQL wrapper of NameID
  _bstr_t Name;                                 //Extended prop name
  MTPipelineLib::PropValType PType;       //Type of the extended property
  VARIANT_BOOL Required;                        //Indicates whether this property must be specified for all updates
};

typedef vector<MTSEExProp *> MTExtendedPropVector;

class UpdateStatement
{
private:
  std::wstring mSetClause;
  std::wstring mWhereClause;
  std::wstring mTableName;
  std::vector<MTSEExProp*> mParameters;
  int mNumParams;
public:
  UpdateStatement(const std::wstring & tableName)
    :
    mTableName (tableName),
    mNumParams(0)
  {
  }

  ~UpdateStatement()
  {
  }

  std::wstring GetQueryString() const
  {
    return L"UPDATE " + mTableName + L" SET " + mSetClause + L" WHERE " + mWhereClause;
  }

  int GetNumParameters() const
  {
    return (int) mParameters.size();
  }
  
  MTSEExProp * GetParameter(int i) 
  {
    return mParameters[i];
  }

  void AddSet(const std::wstring& colName, MTSEExProp * exProp)
  {
    if(mSetClause.size() > 0) mSetClause += L", ";
    mSetClause += colName;
    mSetClause += L" = ";
    wchar_t buf [32];
    wsprintf(buf, exProp->PType == MTPipelineLib::PROP_TYPE_STRING ? L"N'%%%%%d%%%%'" : L"%%%%%d%%%%", mNumParams++);
    mSetClause += buf;
    mParameters.push_back(exProp);
    
  }
  void AddWhere(const std::wstring& colName, MTSEExProp * exProp)
  {
    if(mWhereClause.size() > 0) mWhereClause += L" AND ";
    mWhereClause += colName;
    mWhereClause += L" = ";
    wchar_t buf [32];
    wsprintf(buf, exProp->PType == MTPipelineLib::PROP_TYPE_STRING ? L"N'%%%%%d%%%%'" : L"%%%%%d%%%%", mNumParams++);
    mWhereClause += buf;
    mParameters.push_back(exProp);
  }
};


// generate using uuidgen
//CLSID __declspec(uuid("93028f28-c41a-450d-9d33-dfab56cf362d")) CLSID_ExtendedPropertyUpdatePlugin

CLSID CLSID_ExtendedPropertyUpdatePlugin = { /* 93028f28-c41a-450d-9d33-dfab56cf362d */
    0x93028f28,
    0xc41a,
    0x450d,
    {0x9d, 0x33, 0xdf, 0xab, 0x56, 0xcf, 0x36, 0x2d}
  };

class ATL_NO_VTABLE ExtendedPropertyUpdatePlugin 
	: public MTTransactionPlugIn<ExtendedPropertyUpdatePlugin, &CLSID_ExtendedPropertyUpdatePlugin>
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

  virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                      MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);

  // Read extended properties portion of the configuration file
  HRESULT ProcessExtendedProperties(MTPipelineLib::IMTConfigPropSetPtr aPropSet);

protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
  MTPipelineLib::IMTNameIDPtr mNameID;
	
	BOOL mIsOkayToLogDebug;

  //Vector of extended properties for update
  MTExtendedPropVector mExPropVector;
  //This describes the id_prop parameter for the where clause
  MTSEExProp mEntityProp;
  //PCEntityType
  long mEntityType;

  MTSQLSessionFrame * mFrame;
  std::map<std::wstring, UpdateStatement *> mStatements;

public:
  ExtendedPropertyUpdatePlugin();
  ~ExtendedPropertyUpdatePlugin();
};


PLUGIN_INFO(CLSID_ExtendedPropertyUpdatePlugin, ExtendedPropertyUpdatePlugin,
						"MetraPipeline.ExtendedPropertyUpdate.1", "MetraPipeline.ExtendedPropertyUpdate", "Free")

ExtendedPropertyUpdatePlugin::ExtendedPropertyUpdatePlugin()
  :
  mFrame (NULL)
{
  mQueryInitPath = L"Queries\\AccountCreation";
}

ExtendedPropertyUpdatePlugin::~ExtendedPropertyUpdatePlugin()
{
  delete mFrame;
  for(unsigned int i = 0; i<mExPropVector.size(); i++)
  {
    delete mExPropVector[i];
  }
  for(std::map<std::wstring, UpdateStatement *> ::iterator it = mStatements.begin();
      it != mStatements.end();
      it++)
  {
    delete it->second;
  }
}

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ExtendedPropertyUpdatePlugin ::PlugInConfigure"
HRESULT ExtendedPropertyUpdatePlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr(S_OK);
  mLogger = aLogger;
  mNameID = aNameID;

  mFrame = new MTSQLSessionFrame(aNameID);

	mIsOkayToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

  
  try {
    
    mEntityType = aPropSet->NextLongWithName("EntityType");
    _bstr_t entityID = aPropSet->NextStringWithName("EntityID");

    // Set up session access to the PC Entity identifier (id_prop in the database).
    _bstr_t tmp = _bstr_t(L"@") + entityID;
    mEntityProp.Access = mFrame->allocateVariable((const char *) tmp, RuntimeValue::TYPE_INTEGER);
    mEntityProp.PType =  MTPipelineLib::PROP_TYPE_INTEGER;

    //Process properties for extended properties
    MTPipelineLib::IMTConfigPropSetPtr spTempSet = aPropSet->NextSetWithName("extended_properties");
    if(FAILED(hr = ProcessExtendedProperties(spTempSet)))
    MT_THROW_COM_ERROR("An error occurred in ProcessExtendedProperties(...).  Error was [%x].", hr);

    // Having read the configuration file, load the product catalog metadata and generate appropriate
    // queries (there may be several if the properties are in different tables).
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData((MTPRODUCTCATALOGLib::MTPCEntityType) mEntityType);
    for (MTExtendedPropVector::iterator it = mExPropVector.begin();
         it != mExPropVector.end();
         it++)
    {
      // Get the PC metadata
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr prop = metaData->Item[_variant_t((*it)->Name)];
      // Check the underlying table
      if (mStatements.find((const wchar_t *) prop->DBTableName) == mStatements.end())
      {
        mStatements[(const wchar_t *) prop->DBTableName] = new UpdateStatement((const wchar_t *) prop->DBTableName);
      }
      mStatements.find((const wchar_t *) prop->DBTableName)->second->AddSet((const wchar_t *) prop->DBColumnName, *it);
    }

    // For each update statement, construct a where clause id_prop=@EntityID
    for(std::map<std::wstring, UpdateStatement*>::iterator it = mStatements.begin();
        it != mStatements.end();
        it++)
    {
      it->second->AddWhere(L"id_prop", &mEntityProp);
    }
  
	} catch(std::exception& stlException) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(stlException.what()));
		return E_FAIL;		
	} catch(_com_error & err) {
    _bstr_t message = err.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return err.Error();
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
HRESULT ExtendedPropertyUpdatePlugin::ProcessExtendedProperties(MTPipelineLib::IMTConfigPropSetPtr aPropSet)
{
  try {
    //Build the map of extended properties and name ids
    if(aPropSet != NULL) {
      MTPipelineLib::IMTConfigPropSetPtr spPropertySet;
      MTPipelineLib::IMTConfigPropPtr spProp;
      MTSEExProp *pExProp;
      _bstr_t strTemp;
      _bstr_t strType;
      
      spPropertySet = aPropSet->NextSetWithName(L"property");

      while(spPropertySet != NULL) {
        pExProp = new MTSEExProp;
        
        //Get the service property
        // TODO: Do type mapping to MTSQL type.  Right now the session frame doesn't check what we pass in
        // so we can cheat.
        if(spPropertySet->NextMatches(L"service_prop", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
           pExProp->Access= mFrame->allocateVariable ((const char *)(_bstr_t(L"@") + spPropertySet->NextStringWithName(L"service_prop")), RuntimeValue::TYPE_INTEGER);
        else
          MT_THROW_COM_ERROR("The property [service_prop] was not found in the correct location in the plug-in configuration file.");

        //Get the extended property
        if(spPropertySet->NextMatches(L"extended_prop", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
          pExProp->Name = spPropertySet->NextStringWithName(L"extended_prop");
        else
          MT_THROW_COM_ERROR("The property [extended_prop] was not found in the correct location in the plug-in configuration file.");
        
        //Get the required flag
        if(spPropertySet->NextMatches(L"required", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
          pExProp->Required = spPropertySet->NextBoolWithName(L"required");
        else
          MT_THROW_COM_ERROR("The property [required] was not found in the correct location in the plug-in configuration file.");


        //Get the property type
        if(spPropertySet->NextMatches(L"prop_type", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
          strType = spPropertySet->NextStringWithName(L"prop_type");
        else
          MT_THROW_COM_ERROR("The property [prop_type] was not found in the correct location in the plug-in configuration file.");


        //Set the PType based on the text, which is the service_prop_type
        if(_wcsicmp((wchar_t *)strType, L"STRING") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_STRING;
        
        else if(_wcsicmp((wchar_t *)strType, L"UNISTRING") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_STRING;
        
        else if(_wcsicmp((wchar_t *)strType, L"INT32") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_INTEGER;
        
        else if(_wcsicmp((wchar_t *)strType, L"INT64") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_BIGINTEGER;
        
        else if(_wcsicmp((wchar_t *)strType, L"TIMESTAMP") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_DATETIME;

        else if(_wcsicmp((wchar_t *)strType, L"FLOAT") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_DOUBLE;

        else if(_wcsicmp((wchar_t *)strType, L"DOUBLE") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_DOUBLE;

        else if(_wcsicmp((wchar_t *)strType, L"DECIMAL") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_DECIMAL;

        else if(_wcsicmp((wchar_t *)strType, L"ENUM") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_ENUM;

        else if(_wcsicmp((wchar_t *)strType, L"BOOLEAN") == 0)
          pExProp->PType = MTPipelineLib::PROP_TYPE_BOOLEAN;

        else
          MT_THROW_COM_ERROR("The property type [%s] is not supported.", (const char *)strType);
                
        //Add the property to the vector
        mExPropVector.push_back(pExProp);

        //Get the next property
        spPropertySet = aPropSet->NextSetWithName(L"property");
      
      } //end while
    }   //end if
  } catch(_com_error &e) {
    return ReturnComError(e);
  }

  return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "ExtendedPropertyUpdatePlugin ::PlugInProcessSession"
HRESULT ExtendedPropertyUpdatePlugin::PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                                          MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  MTSQLSessionActivationRecord ar(aSession);
  MTSQLSelectCommand cmd(aTransactionRS);
  // For each table to update
  for(std::map<std::wstring, UpdateStatement *>::iterator it = mStatements.begin();
      it != mStatements.end();
      it++)
  {
    RuntimeValue val;
    cmd.setQueryString(it->second->GetQueryString());
    // For each binding to the update query, set param
    for(int i = 0; i<it->second->GetNumParameters(); i++)
    {
      MTSEExProp * prop = it->second->GetParameter(i);
      
      switch(prop->PType)
      {
      case MTPipelineLib::PROP_TYPE_INTEGER:
      {
        ar.getLongValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      {
        ar.getLongLongValue(prop->Access.get(), &val);
        break;
      }        
      case MTPipelineLib::PROP_TYPE_DATETIME:
      {
        ar.getDatetimeValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_DOUBLE:
      {
        ar.getDoubleValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_DECIMAL:
      {
        ar.getDecimalValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_ENUM:
      {
        ar.getEnumValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_BOOLEAN:
      {
        ar.getBooleanValue(prop->Access.get(), &val);
        break;
      }
      case MTPipelineLib::PROP_TYPE_STRING:
      {
        ar.getWStringValue(prop->Access.get(), &val);
        break;
      }
      }
      cmd.setParam(i, val);
    }

    cmd.execute();
  }
  
  return S_OK;
}



