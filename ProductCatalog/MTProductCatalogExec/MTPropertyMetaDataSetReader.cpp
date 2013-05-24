/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

// MTPropertyMetaDataSetReader.cpp : Implementation of CMTPropertyMetaDataSetReader
#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPropertyMetaDataSetReader.h"
#include "pcexecincludes.h"

#include <ExtendedProp.h>
#include <SetIterate.h>
#include <DefaultToVariant.h>


using MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr;
using MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr;
using MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr;
using MTPRODUCTCATALOGLib::IMTAttributeMetaDataPtr;
using MTPRODUCTCATALOGLib::IMTAttributesPtr;
using MTPRODUCTCATALOGLib::IMTAttributePtr;

#define FIND_EP_TABLE_BY_TYPE L"__FIND_EP_TABLE_BY_TYPE__"

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaDataSetReader

/******************************************* error interface ***/
STDMETHODIMP CMTPropertyMetaDataSetReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPropertyMetaDataSetReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

HRESULT CMTPropertyMetaDataSetReader::Activate()
{
  HRESULT hr = GetObjectContext(&m_spObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTPropertyMetaDataSetReader::CanBePooled()
{
  return TRUE;
} 

void CMTPropertyMetaDataSetReader::Deactivate()
{
  m_spObjectContext.Release();
} 


STDMETHODIMP CMTPropertyMetaDataSetReader::GetAll(IMTPropertyMetaDataSet **pVal)
{
  
  try
  {
    ExtendedPropCollection propColl; 

    if (!propColl.Init())
    {
      ASSERT(0);
      return Error("Unable to read extended properties");
    }

    // iterate over all msixdefs in the msixdefcollection, creating MTPropertyMetaData from MSIXProperties
    
    ASSERT(0); //TODO: implement or remove method


  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }


  return S_OK;
}


static MTPRODUCTCATALOGLib::PropValType
PropertyTypeToPropValType(CMSIXProperties::PropertyType aType)
{
  switch(aType)
  {
  case CMSIXProperties::TYPE_STRING:
  case CMSIXProperties::TYPE_WIDESTRING:
    return MTPRODUCTCATALOGLib::PROP_TYPE_STRING;

  case CMSIXProperties::TYPE_INT32:
    return MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER;

  case CMSIXProperties::TYPE_INT64:
    return MTPRODUCTCATALOGLib::PROP_TYPE_BIGINTEGER;

  case CMSIXProperties::TYPE_TIMESTAMP:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME;

  case CMSIXProperties::TYPE_FLOAT:
  case CMSIXProperties::TYPE_DOUBLE:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DOUBLE;

  case CMSIXProperties::TYPE_NUMERIC:
  case CMSIXProperties::TYPE_DECIMAL:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL;

  case CMSIXProperties::TYPE_ENUM:
    return MTPRODUCTCATALOGLib::PROP_TYPE_ENUM;

  case CMSIXProperties::TYPE_BOOLEAN:
    return MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN;

  default:
    // TOOD:
    ASSERT(0);
    return MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN;
  }
}


// if aReturnErrors is TRUE, any encountered error will stop processing, and the error will be returned
// if aReturnErrors is FALSE, encountered meta data errors will be logged only and processing continues
STDMETHODIMP CMTPropertyMetaDataSetReader::Find(MTPCEntityType aType, 
                                                IMTAttributeMetaDataSet* apSet,
                                                VARIANT_BOOL aReturnErrors,
                                                IMTPropertyMetaDataSet ** pVal)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    // create instance of the Set class
    DefaultConversion aConversionObj;
    IMTPropertyMetaDataSetPtr propMetaDataSet(__uuidof(MTPropertyMetaDataSet));

    ExtendedPropCollection propColl;      // MSIXDefCollection containting MSIXDefinition 
    if (!propColl.Init())
    {
        DWORD errorCode = propColl.GetLastErrorCode();

        if (errorCode == CORE_ERR_NOMSIXFILEFILES_FOUND)
        { //no files found, return an empty propMetaDataSet
          *pVal = reinterpret_cast<IMTPropertyMetaDataSet *>(propMetaDataSet.Detach());
          return S_OK;
        }
        else
        { const ErrorObject* error = propColl.GetLastError();
          MT_THROW_COM_ERROR( "Error reading extended properties: %s",
                              error ? error->GetProgrammerDetail().c_str() : "unkown error" );
        }
    }

    // iterate over MSIX definitions, looking for the right kind
    MSIXDefCollection::MSIXDefinitionList& lst = propColl.GetDefList();
    list <CMSIXDefinition *>::iterator it;
    for ( it = lst.begin(); it != lst.end(); it++ )
    {
      CMSIXDefinition * msixDef = *it;
      
      // determine if the kind matches passed in type
      int kind = 0;

      const XMLNameValueMapDictionary * pdefattrs = msixDef->GetAttributes();
      if (pdefattrs)
      {
        const XMLNameValueMapDictionary & defattrs = *pdefattrs;
        
        XMLNameValueMapDictionary::const_iterator findit = defattrs.find(L"kind");

        if (findit != defattrs.end())
        {
          _bstr_t value = (findit->second).c_str();
          kind = atoi((const char*)value);
        }
      }
      
      if (kind != static_cast<int>(aType))
        continue;


      MSIXPropertiesList msixProps = msixDef->GetMSIXPropertiesList();
      MSIXPropertiesList::iterator itr;
      for (itr = msixProps.begin(); itr != msixProps.end(); ++itr)
      {
        CMSIXProperties * prop = *itr;
        
        _bstr_t propName = prop->GetDN().c_str();

        IMTPropertyMetaDataPtr propMetaData = propMetaDataSet->CreateMetaData(propName);
        
        propMetaData->DBColumnName = _bstr_t(prop->GetColumnName().c_str());
        propMetaData->Required = prop->GetIsRequired();
        propMetaData->Extended = VARIANT_TRUE;
        propMetaData->DBTableName = _bstr_t(msixDef->GetTableName().c_str());
        
        _bstr_t aDefaultStr = prop->GetDefault().c_str();
        // make it the string
        _variant_t vtDefault; // vt_empty
        if(aDefaultStr.length() != 0) {
          if(!aConversionObj.ConvertDefaultStrToVariant(*prop,vtDefault))
          {
            Message message(MTPC_INVALID_PROPERTY_DEFAULT_VALUE);
            string errString;
            message.FormatErrorMessage(errString, TRUE, (const char*)propName, (const char*) aDefaultStr);

            if (aReturnErrors)
              MT_THROW_COM_ERROR(errString.c_str());
            else
              PCCache::GetLogger().LogThis(LOG_ERROR, errString.c_str());
          }
        }
        // init default
        propMetaData->InitDefault(PropertyTypeToPropValType(prop->GetPropertyType()),vtDefault);
        MTPRODUCTCATALOGLib::PropValType type =
              PropertyTypeToPropValType(prop->GetPropertyType());

        if (type == MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN)
        {
          ASSERT(0);
          Message message(MTPC_INVALID_PROPERTY_TYPE);
          string errString;
          message.FormatErrorMessage(errString, TRUE, (const char*)propName);

          if (aReturnErrors)
            MT_THROW_COM_ERROR(errString.c_str());
          else
            PCCache::GetLogger().LogThis(LOG_ERROR, errString.c_str());
        }

        propMetaData->DataType = type;
        //CR 5986 fix
        propMetaData->Length = prop->GetLength();


        propMetaData->EnumSpace = prop->GetEnumNamespace().c_str();
        propMetaData->EnumType = prop->GetEnumEnumeration().c_str();

        // for each atttribute meta in attribute meta data set, add it to propMetaData.Attributes
        
        IMTAttributesPtr pAttributes = propMetaData->Attributes;
        
        SetIterator<IMTAttributeMetaDataSetPtr, IMTAttributeMetaDataPtr> it;
        HRESULT hr = it.Init(apSet);
        if(FAILED(hr)) return E_FAIL;

        while (TRUE)
        {
          IMTAttributeMetaDataPtr pAttMetaData = it.GetNext();
          if(pAttMetaData == NULL) break; 
          
          IMTAttributePtr pAttr = pAttributes->Add(pAttMetaData);
        }
      
        const XMLNameValueMapDictionary * pattributes = prop->GetAttributes();
        
        //CR 5985 fix: do not require attributes

        /*
        if (!pattributes)
        {
          // TODO:
          ASSERT(0);
          return Error("property should have at least display_name attribute");
        } 
        */
            
        // iterate over attributes, creting AttrMetaData objects and adding them to attributes

        XMLNameValueMapDictionary::const_iterator iter;
        if(pattributes)
        {
          for (iter = pattributes->begin(); iter != pattributes->end(); iter++)
          {
            const std::wstring  name = iter->first;
            const std::wstring  value = iter->second;
            
            if (name == L"display_name")
              propMetaData->DisplayName = value.c_str();
            else
            {
              IMTAttributeMetaDataPtr attrMetaData(__uuidof(MTAttributeMetaData));
              
              attrMetaData->Name = name.c_str();
              attrMetaData->DefaultValue = value.c_str();
              
              IMTAttributePtr pAttr = pAttributes->Add(attrMetaData);
            }
          }
        }
      }
    }
    *pVal = reinterpret_cast<IMTPropertyMetaDataSet *>(propMetaDataSet.Detach());

  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPropertyMetaDataSetReader::LoadAttributeValues(IMTProductCatalogMetaData* apMetadata)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    MTPRODUCTCATALOGLib::IMTProductCatalogMetaDataPtr metadata = apMetadata;


    //use RCD to iterate over all extensions
    RCDLib::IMTRcdPtr rcd(MTPROGID_RCD);

    RCDLib::IMTRcdFileListPtr fileList = rcd->GetExtensionListWithPath();

    long count = fileList->Count;

    for(int i = 0; i < count; i++) //this collection is 0 based unlike other COM collections
    {
      _bstr_t extension = fileList->GetItem(i);
      _bstr_t file = extension + "\\config\\attributes\\attribute_values.xml";

      //try to load an xml doc
      MSXML2::IXMLDOMDocumentPtr domDoc("Microsoft.XMLDOM");
      domDoc->async = VARIANT_FALSE;
      VARIANT_BOOL loaded = domDoc->load(file);

      if (loaded == VARIANT_TRUE)
      {
        MSXML2::IXMLDOMNodeListPtr nodeList;
        nodeList = domDoc->documentElement->selectNodes("attribute_value");

        for( MSXML2::IXMLDOMNodePtr node = nodeList->nextNode();
             node != NULL;
             node = nodeList->nextNode())
        {
          //load up the node
          MSXML2::IXMLDOMNodePtr node2 = node->selectSingleNode("./@pcentitytype");
          if (node2 == NULL)
            MT_THROW_COM_ERROR("missing pcentitytype attribute in %s", (const char*)file);
          MTPRODUCTCATALOGLib::MTPCEntityType entityType;
          entityType = static_cast<MTPRODUCTCATALOGLib::MTPCEntityType>( atol(node2->text) );

          node2 = node->selectSingleNode("./property");
          if (node2 == NULL)
            MT_THROW_COM_ERROR("missing <property> tag in %s", (const char*)file);
          _bstr_t propertyName = node2->text;

          node2 = node->selectSingleNode("./attribute");
          if (node2 == NULL)
            MT_THROW_COM_ERROR("missing <attribute> tag in %s", (const char*)file);
          _bstr_t attributeName = node2->text;

          node2 = node->selectSingleNode("./value");
          if (node2 == NULL)
            MT_THROW_COM_ERROR("missing <value> tag in %s", (const char*)file);
          _bstr_t attributeValue = node2->text;

          //set the value
          metadata->SetAttributeValue(entityType, propertyName, attributeName, attributeValue);
        }
      }
      else
      {
        // check error code for reason of failure
        // warnings (such as ERROR_PATH_NOT_FOUND or INET_E_RESOURCE_NOT_FOUND) are OK
        
        HRESULT errorCode = domDoc->parseError->errorCode;
        if( (errorCode & ERROR_SEVERITY_ERROR) == ERROR_SEVERITY_ERROR ) //check if both severity bits are set
        {
          _bstr_t reason = domDoc->parseError->reason;
          MT_THROW_COM_ERROR("error loading %s.\n%x: %s", (const char*)file, errorCode, (const char*)reason );
        }
      }

    } 
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
