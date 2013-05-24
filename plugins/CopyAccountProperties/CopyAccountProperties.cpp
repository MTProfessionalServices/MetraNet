/**************************************************************************
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

/***************************************************************************
 * CopyAccountProperties.cpp                                               *
 * Implementation of plugin for copying properties from one account or     *
 * template to another account.                                            *
 ***************************************************************************/

#include "CopyAccountProperties.h"
 

/***************************************************************************
 * PlugInConfigure                                                         *
 ***************************************************************************/
HRESULT CMTCopyAccountPropertiesPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                                        MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                                        MTPipelineLib::IMTNameIDPtr aNameID,
                                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  try {
    //Members
    mNameID = aNameID;
	  mLogger = aLogger;
	  mSysContext = aSysContext;
    _bstr_t strTemp;

    mQueryInitPath = "queries\\AccountCreation";

    //Get data source
    if(aPropSet->NextMatches(L"SourceAccountID", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
      mlngSourcePropID = aNameID->GetNameID(aPropSet->NextStringWithName(L"SourceAccountID"));

    if(aPropSet->NextMatches(L"DestinationAccountID", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
      mlngDestinationPropID = aNameID->GetNameID(aPropSet->NextStringWithName(L"DestinationAccountID"));


    //Now get the properties to copy
    MTPipelineLib::IMTConfigPropSetPtr spPropertiesSet = aPropSet->NextSetWithName(L"Properties");
    
    if(spPropertiesSet != NULL) {
      MTPipelineLib::IMTConfigPropSetPtr spPropertySet;
      MTPipelineLib::IMTConfigPropPtr spProp;
      MTCopyProperty *pCopyProp;
      MTExtensionNameMap::iterator iIterator;

      spPropertySet = spPropertiesSet->NextSetWithName(L"Property");
      
      while(spPropertySet != NULL)
      {
        pCopyProp = new MTCopyProperty;

        //Get the type
        strTemp = spPropertySet->NextStringWithName(L"Type");

        if(stricmp(strTemp, "Session") == 0)
          pCopyProp->PropType = COPY_PROP_TYPE_SESSION;
        else if(stricmp(strTemp, "Extension") == 0)
          pCopyProp->PropType = COPY_PROP_TYPE_EXTENSION;
        else if(stricmp(strTemp, "Template") == 0)
          pCopyProp->PropType = COPY_PROP_TYPE_TEMPLATE;
        else {
          char buffer[1024];
          sprintf(buffer, "An unknown type [%s] was specified for a property.", strTemp);
          return Error(buffer);
        }

        //Default property to be not required
        pCopyProp->Required = false;

        //If gettting session properties, check if the properties are required or not
        if(pCopyProp->PropType == COPY_PROP_TYPE_SESSION)
          if(spPropertySet->NextMatches(L"Required", MTPipelineLib::PROP_TYPE_BOOLEAN))
            if(spPropertySet->NextBoolWithName(L"Required") == VARIANT_TRUE)
              pCopyProp->Required = true;

        //Get the source property name
        pCopyProp->SourceProperty = spPropertySet->NextStringWithName(L"SourceProperty");

        //If getting values from extension, get the source extension
        if(pCopyProp->PropType == COPY_PROP_TYPE_EXTENSION)
          pCopyProp->SourceExtension = spPropertySet->NextStringWithName(L"SourceExtension");

        if(spPropertySet->NextMatches(L"DestinationProperty", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE) {
          pCopyProp->DestinationProperty = spPropertySet->NextStringWithName(L"DestinationProperty");
        } else {
          //If template or session, destination property and extension must be specified
          if(pCopyProp->PropType != COPY_PROP_TYPE_EXTENSION) {
            char buffer[1024];
            sprintf(buffer, "The destination property is required when copying session or template properties.");
            return Error(buffer);
          } else {
            pCopyProp->DestinationProperty = pCopyProp->SourceProperty;
          }
        }

        if(spPropertySet->NextMatches(L"DestinationExtension", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
          pCopyProp->DestinationExtension = spPropertySet->NextStringWithName(L"DestinationExtension");
        else {
          //If template or session, destination property and extension must be specified
          if(pCopyProp->PropType != COPY_PROP_TYPE_EXTENSION) {
            char buffer[1024];
            sprintf(buffer, "The destination extension is required when copying session or template properties.");
            return Error(buffer);
          } else {
            pCopyProp->DestinationExtension = pCopyProp->SourceExtension;
          }
        }
         
        //Part of key
        if(spPropertySet->NextMatches(L"PartOfKey", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
          if(spPropertySet->NextBoolWithName(L"PartOfKey") == VARIANT_TRUE)
            pCopyProp->PartOfKey = true;
          else
            pCopyProp->PartOfKey = false;
        else
          pCopyProp->PartOfKey = false;

        //Add the property to the vector
        mCopyProperties.push_back(pCopyProp);

        //See if the extension needs to be added to the map
        iIterator = mDestExtensions.find(pCopyProp->DestinationExtension);

        if(iIterator == mDestExtensions.end()) {
          mDestExtensions.insert(MTExtensionNameMap::value_type(pCopyProp->DestinationExtension, pCopyProp->DestinationExtension));
        }

        char buffer[1024];
        sprintf(buffer, "Adding property to copy:  %s [%s] --> %s [%s].", (const char *)pCopyProp->SourceProperty, (const char *)pCopyProp->SourceExtension, (const char *)pCopyProp->DestinationProperty, (const char *)pCopyProp->DestinationExtension);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

        spPropertySet = spPropertiesSet->NextSetWithName(L"Property");
      }
    } else {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "[CopyAccountProperties] -- No properties specified for copying.");
    }

  } catch(_com_error & e) {
	  char buffer[1024];
		sprintf(buffer, "An exception was thrown while parsing the config file: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
  }
  return S_OK;
}
/***************************************************************************
 * PlugInProcessSession                                                    *
 ***************************************************************************/
HRESULT CMTCopyAccountPropertiesPlugin::PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                                            MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  try {
    //Account Adapter
    MTACCOUNTLib::IMTAccountAdapterPtr spAccountAdapter(MTPROGID_MTACCOUNTSERVER);
    
    //Property collection to update
    MTACCOUNTLib::IMTAccountPropertyCollectionPtr spNewProperties;
   
    //Property collection of existing values
    MTACCOUNTLib::IMTAccountPropertyCollectionPtr spProperties;
    MTACCOUNTLib::IMTAccountPropertyPtr spProperty;

    //Properties that are part of key
    MTACCOUNTLib::IMTAccountPropertyCollectionPtr spKeyProperties;

    //Property Type
    MTPipelineLib::MTSessionPropType eSessPropType;
    
    //Map and vector iterators
    MTExtensionNameMap::iterator iNameIterator;
    MTPropertyNameVector::iterator iPropertyIterator;
    MTSessionPropTypeMap::iterator iSessPropTypesMapIterator;
    
    MTCopyProperty *pCopyProp;
    
    _bstr_t strExtension;
    
    //Account ID of source
    long lngSrcAccountID;
    long lngDestAccountID;
    
    long lngPropID;
    
    _variant_t vVal;

    bool bAdd = false;
    bool bNonKeyPropFound = false;
    bool bNoKeyPropsFound = true;

    HRESULT hr;


    //Popluate MAP of session property types
    SetIterator<MTPipelineLib::IMTSessionPtr, MTPipelineLib::IMTSessionPropPtr> iSessionPropIterator;

    if(FAILED(hr = iSessionPropIterator.Init(aSession))) {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unable to get types of session properties.");
      return hr;
    }

		mSessionPropTypes.clear();

		while (TRUE) {
      MTPipelineLib::IMTSessionPropPtr spSessionProp = iSessionPropIterator.GetNext();

      if (spSessionProp == NULL)
        break;

      char buffer[1024];
      sprintf(buffer, "Found property [%s, %d] in the session.", (const char *)spSessionProp->Name, spSessionProp->type);
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
      mSessionPropTypes.insert(MTSessionPropTypeMap::value_type(_strupr(_bstr_t(spSessionProp->Name)), spSessionProp->type));
    }


    //Get the data
    lngDestAccountID = aSession->GetLongProperty(mlngDestinationPropID);

    for(iNameIterator = mDestExtensions.begin(); iNameIterator != mDestExtensions.end(); ++iNameIterator) {
      bNoKeyPropsFound = true;

      strExtension = iNameIterator->second;
      
      char buffer[1024];
      sprintf(buffer, "Preparing to update extension [%s].", (const char *)strExtension);
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

      spAccountAdapter->Initialize(strExtension);        

      if(FAILED(hr = spNewProperties.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION))) {
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Unable to create properties collection.");
        return hr;
      }
      
      if(FAILED(hr = spKeyProperties.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION))) {
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Unable to create key properties collection.");
        return hr;
      }

      //Reset the part of key check
      bNonKeyPropFound = false;

      for(iPropertyIterator = mCopyProperties.begin(); iPropertyIterator != mCopyProperties.end(); ++iPropertyIterator) {
        pCopyProp = *iPropertyIterator;

        //Check if the destination extension is the one to be modified this time around
        if(_wcsicmp((wchar_t *)strExtension, (wchar_t *)pCopyProp->DestinationExtension) == 0) {     

          if(pCopyProp->PropType == COPY_PROP_TYPE_SESSION) {
            //Check if the property exists
            lngPropID = mNameID->GetNameID(pCopyProp->SourceProperty);

            /*if(aSession->PropertyExists(lngPropID, pCopyProp->SessPropType) != VARIANT_TRUE)
            {
              char buffer[1024];
              sprintf(buffer, "Unable to find property [%s] in the session.", (const char *)pCopyProp->SourceProperty);
              return Error(buffer);
            } */

            //New Check...see if in Map
            _bstr_t strTemp = _strupr(pCopyProp->SourceProperty);
            iSessPropTypesMapIterator = mSessionPropTypes.find(strTemp);

            if(iSessPropTypesMapIterator == mSessionPropTypes.end()) {
              if(pCopyProp->Required) {
                char buffer[1024];
                sprintf(buffer, "Unable to find property [%s] in the session.", (const char *)pCopyProp->SourceProperty);
                return Error(buffer);
              }
            } else {

              //Check if this property is not part of the key, this is needed so that an UPDATE is not called
              //with only key properties because an account adapter barf will result.
              if(!pCopyProp->PartOfKey)
                bNonKeyPropFound = true;

              eSessPropType = iSessPropTypesMapIterator->second;

              //Get the property's value
              if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_STRING)
                vVal = aSession->GetStringProperty(lngPropID);
            
              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_TIME)
                vVal = aSession->GetTimeProperty(lngPropID);
            
              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_DATE)
                vVal = aSession->GetOLEDateProperty(lngPropID);
                
              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_LONG)
                vVal = aSession->GetLongProperty(lngPropID);

              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_LONGLONG)
                vVal = aSession->GetLongLongProperty(lngPropID);

              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_DOUBLE)
                vVal = aSession->GetDoubleProperty(lngPropID);

              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_BOOL)
                vVal = (VARIANT_TRUE == aSession->GetBoolProperty(lngPropID)) ? "1" : "0";

              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_ENUM)
                vVal = aSession->GetEnumProperty(lngPropID);

              else if(eSessPropType == MTPipelineLib::SESS_PROP_TYPE_DECIMAL)
                vVal = aSession->GetDecimalProperty(lngPropID);
              else
              {
                char buffer[1024];
                sprintf(buffer, "An unsupported or unknown proptype was found: %d.", eSessPropType);
                return Error(buffer);
              }

              //Add the property
              char buffer[1024];
              sprintf(buffer, "Adding property [%s] to temp collection.", (const char *)pCopyProp->DestinationProperty);
              mLogger->LogString(MTPipelineLib:: PLUGIN_LOG_DEBUG, buffer);

              spNewProperties->Add(pCopyProp->DestinationProperty, vVal);

              //If the property is part of the key, add it to the key properties
              if(pCopyProp->PartOfKey) {
                char buffer[1024];
                sprintf(buffer, "Adding property [%s] to key collection.", (const char *)pCopyProp->DestinationProperty);
                spKeyProperties->Add(_bstr_t("c_") + pCopyProp->DestinationProperty, vVal);
                bNoKeyPropsFound = false;
                mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
              }
            }
          } else if(pCopyProp->PropType == COPY_PROP_TYPE_EXTENSION) {
            //Make sure property for source ID was specified
            lngSrcAccountID = aSession->GetLongProperty(mlngSourcePropID);

            //Check for the source extension
            hr = spAccountAdapter->raw_GetData(pCopyProp->SourceExtension, 
											   lngSrcAccountID, 
											   _variant_t(aTransactionRS.GetInterfacePtr()), 
											   &spProperties);

            if(hr == ACCOUNT_NOT_FOUND) {
              char buffer[1024];
              sprintf(buffer, "Unable to get source properties to copy.  Source Account ID = %d.", lngSrcAccountID);
              return Error(buffer);
            }

            spProperty = spProperties->GetItem(pCopyProp->SourceProperty);

            spNewProperties->Add(pCopyProp->DestinationProperty, spProperty->Value);

          } else if(pCopyProp->PropType == COPY_PROP_TYPE_TEMPLATE) {
            lngSrcAccountID = aSession->GetLongProperty(mlngSourcePropID);
            char buffer[1024];
              sprintf(buffer, "Getting source properties from TEMPLATE is not yet supported.  Source Account ID = %d.", lngSrcAccountID);
              return Error(buffer);
          
          } else {
            char buffer[1024];
            sprintf(buffer, "An unknown type was specified for a property.");
            return Error(buffer);
          }
        }
      }

      //If no nonkey properties have been found
      if(!bNonKeyPropFound) {
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Not updating properties for this extension because no NonKey properties were found.");
      } else {

        //Add the account ID property
        spNewProperties->Add(L"id_acc", lngDestAccountID);
                
        //All properties are there...now update/add
        MTACCOUNTLib::IMTSearchResultCollectionPtr spSearchResults;

        if(bNoKeyPropsFound)
		{
			 hr = spAccountAdapter->raw_GetData(strExtension, 
											   lngDestAccountID, 
											   _variant_t(aTransactionRS.GetInterfacePtr()),
											   &spProperties); 

				//hr = ACCOUNT_NOT_FOUND;
        }
		else
		{
			spKeyProperties->Add(L"id_acc", lngDestAccountID);
			hr = spAccountAdapter->raw_SearchData(strExtension, spKeyProperties,
												  _variant_t(aTransactionRS.GetInterfacePtr()),
												  &spSearchResults);
        }


        if(hr == ACCOUNT_NOT_FOUND) {
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Adding properties to view.");
          spAccountAdapter->AddData(strExtension, spNewProperties, aTransactionRS.GetInterfacePtr());
        } else if(!FAILED(hr)) {
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Updating view properties.");
          if(bNonKeyPropFound)
            spAccountAdapter->UpdateData(strExtension, spNewProperties, aTransactionRS.GetInterfacePtr());
          else
            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Not updating properties for this extension because no NonKey properties were found.");

        //An error occurred while loading the extension
        } else {
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "An error occurred getting the destination extension.");
          return hr;
        }
      }
    }
  } catch(_com_error & e){
    char buffer[1024];
    sprintf(buffer, "An exception was thrown while copying account properties: %x, %s",
            e.Error(), (const char *) _bstr_t(e.Description()));
    return Error(buffer);
  }

  return S_OK;
}
/***************************************************************************
 * PlugInShutdown                                                          *
 ***************************************************************************/
HRESULT CMTCopyAccountPropertiesPlugin::PlugInShutdown()
{
  // Delete the objects in the Copy Properties vector
	MTCopyProperty *pCopyProp;
  for (unsigned int i = 0; i < mCopyProperties.size(); ++i)
	{
		pCopyProp = mCopyProperties.at(i);
		delete pCopyProp;
		pCopyProp = NULL;
	}

  return S_OK;
}
