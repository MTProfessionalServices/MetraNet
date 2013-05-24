// ARPropagationConfigState.cpp : Implementation of CARPropagationConfigState
#include "StdAfx.h"
#include "ARPropagationExec.h"
#include "ARPropagationConfigState.h"
#include "ARInterfaceMethod.h"

#import <RCD.tlb>

#define AR_INTERFACE_DIR "\\AR\\config\\AR\\MTARInterface\\";


MTDataTypeLib::DataType StringToDataType(string str)
{
  MTDataTypeLib::DataType type;
  if (str == "int32")
    type = MTDataTypeLib::MTC_DT_INT;
  else if (str == "int64")
    type = MTDataTypeLib::MTC_DT_BIGINT;
  else if (str == "double")
    type = MTDataTypeLib::MTC_DT_DOUBLE;
  else if (str == "string")
    type = MTDataTypeLib::MTC_DT_WCHAR;
  else if (str == "datetime")
    type = MTDataTypeLib::MTC_DT_TIMESTAMP;
  else if (str == "time")
    type = MTDataTypeLib::MTC_DT_TIME;
  else if (str == "boolean")
    type = MTDataTypeLib::MTC_DT_BOOL;
  else if (str == "enum")
    type = MTDataTypeLib::MTC_DT_ENUM;
  else if (str == "decimal")
    type = MTDataTypeLib::MTC_DT_DECIMAL;
  else
    MT_THROW_COM_ERROR("invalid data type");

  return type;
}

MTPipelineLib::MTSessionPropType DataTypeToSessionPropType(MTDataTypeLib::DataType dataType)
{
  switch(dataType)
  {
    case MTDataTypeLib::MTC_DT_WCHAR:
    case MTDataTypeLib::MTC_DT_CHAR:
      return MTPipelineLib::SESS_PROP_TYPE_STRING;
    
    case MTDataTypeLib::MTC_DT_INT:
      return MTPipelineLib::SESS_PROP_TYPE_LONG;
    
    case MTDataTypeLib::MTC_DT_BIGINT:
      return MTPipelineLib::SESS_PROP_TYPE_LONGLONG;
    
    case MTDataTypeLib::MTC_DT_FLOAT:
    case MTDataTypeLib::MTC_DT_DOUBLE:
      return MTPipelineLib::SESS_PROP_TYPE_DOUBLE;
    
    case MTDataTypeLib::MTC_DT_TIME:
      return MTPipelineLib::SESS_PROP_TYPE_TIME;

    case MTDataTypeLib::MTC_DT_TIMESTAMP:
      return MTPipelineLib::SESS_PROP_TYPE_DATE;
    
    case MTDataTypeLib::MTC_DT_BOOL:
      return MTPipelineLib::SESS_PROP_TYPE_BOOL;

    case MTDataTypeLib::MTC_DT_DECIMAL:
      return MTPipelineLib::SESS_PROP_TYPE_DECIMAL;

    case MTDataTypeLib::MTC_DT_ENUM:
      return MTPipelineLib::SESS_PROP_TYPE_ENUM;

    default:
      MT_THROW_COM_ERROR("invalid data type");
  }
}

/////////////////////////////////////////////////////////////////////////////
// CARPropagationConfigState

STDMETHODIMP CARPropagationConfigState::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IARPropagationConfigState
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

CARPropagationConfigState::CARPropagationConfigState() :
  mMethod(0)
{
    m_pUnkMarshaler = NULL;
}


STDMETHODIMP CARPropagationConfigState::get_Method(long *pVal)
{
  *pVal = mMethod;
  return S_OK;
}

STDMETHODIMP CARPropagationConfigState::put_Method(long newVal)
{
  mMethod = newVal;
  return S_OK;
}

STDMETHODIMP CARPropagationConfigState::get_ARConfigState(VARIANT *pVal)
{
  if (!pVal)
    return E_POINTER;

  ::VariantInit(pVal);
  ::VariantCopy(pVal, &mARConfigState);

  return S_OK;
}

STDMETHODIMP CARPropagationConfigState::put_ARConfigState(VARIANT newVal)
{
  mARConfigState = newVal;
  return S_OK;
}


STDMETHODIMP CARPropagationConfigState::Configure(IDispatch *aSystemContext, IMTConfigPropSet *aPropSet)
{
  try
  {
    mNameID = aSystemContext;
    MTPipelineLib::IMTLogPtr logger = aSystemContext;
    MTPipelineLib::IMTConfigPropSetPtr propSet = aPropSet;
    mEnumConfig = new MTPipelineLib::IEnumConfigPtr(MTPROGID_ENUM_CONFIG);

    //get method
    string method = propSet->NextStringWithName(L"Method");
    mMethod = StringToARInterfaceMethod(method);

    //load template doc from AR interface directory
    string ARDocument = propSet->NextStringWithName(L"ARDocument");

    RCDLib::IMTRcdPtr rcd(MTPROGID_RCD);
    rcd->Init();
  
    _bstr_t path = rcd->ExtensionDir;
    path += AR_INTERFACE_DIR;
    path += ARDocument.c_str();
    
    MSXML2::IXMLDOMDocumentPtr templateDoc("MSXML2.DOMDocument.4.0");
    VARIANT_BOOL success = templateDoc->load(path);
    if (!success)
        MT_THROW_COM_ERROR("cannot load file %s", (const char*)path);
    mTemplateDoc = templateDoc;

    //load localconfig based on language code ("" means do not use localization)
    if (propSet->NextMatches(L"LanguageCode", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      mLanguageCode = propSet->NextStringWithName(L"LanguageCode");
    }

    if (!mLanguageCode.empty())
    {
      string msg = "Loading LocalConfig for language '" + mLanguageCode + "'";
      logger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg.c_str());

      mLocalConfig = new MTLOCALECONFIGLib::ILocaleConfigPtr(MTPROGID_LOCALE_CONFIG);
      mLocalConfig->LoadLanguage(mLanguageCode.c_str());
    }

    //load properties
    MTPipelineLib::IMTConfigPropSetPtr propertiesSet = propSet->NextSetWithName(L"Properties");
    if (propertiesSet)
    {
      MTPipelineLib::IMTConfigPropSetPtr propertySet = propertiesSet->NextSetWithName(L"Property");
      while (propertySet)
      {
        Property prop;

        prop.propertyNameID = mNameID->GetNameID(propertySet->NextStringWithName(L"PropertyName"));
        prop.nodeName = propertySet->NextStringWithName(L"NodeName");
        string strType= propertySet->NextStringWithName(L"Type");
        prop.type = StringToDataType(strType);

        prop.localizeValue = false;
        if (propertySet->NextMatches(L"LocalizeValue", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
        {
          VARIANT_BOOL localizeValue = propertySet->NextBoolWithName(L"LocalizeValue");
          
          if (localizeValue)
          { //need Language code in order to LocalizeValue
            if( mLanguageCode.empty())
              MT_THROW_COM_ERROR( "if <LocalizeValue> is true, <LanguageCode> must be set" ); 
           
            prop.localizeValue = true;
          }
        }

        mProperties.push_back(prop);
      
        propertySet = propertiesSet->NextSetWithName(L"Property");
      }
    }
  
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}

STDMETHODIMP CARPropagationConfigState::SessionsToXmlDoc(IMTSessionSet *aSessions, BSTR* aXmlDoc)
{
  bstr_t bstrExternalNamespace = "";
  return SessionsToExternalARXmlDoc(aSessions, bstrExternalNamespace , aXmlDoc);
}

STDMETHODIMP CARPropagationConfigState::SessionsToExternalARXmlDoc(IMTSessionSet *aSessions, BSTR aExternalNamespace, BSTR* aXmlDoc)
{
  if (!aXmlDoc)
    return E_POINTER;

  try
  {
    //construct wrapping compound doc
    bstr_t sDocumentsTag = L"<ARDocuments ExtNamespace='";
    sDocumentsTag += aExternalNamespace;
    sDocumentsTag += "'/>";
    ARDocument compoundDoc(sDocumentsTag);

    //for all sessions
    SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
    HRESULT hr = it.Init(aSessions);
    if (FAILED(hr))
      return hr;

    while (TRUE)
    {
      MTPipelineLib::IMTSessionPtr session = it.GetNext();
      if (session == NULL)
        break;

      // create empty AR doc from template
      ARDocument simpleDoc;
      simpleDoc = mTemplateDoc;
  
      //for all properties
      for( std::vector<Property>::iterator it = mProperties.begin();
           it != mProperties.end();
           it++)
      {
        Property& prop = *it;

        // set nodes in XML doc if property exists
        long nameID = prop.propertyNameID;
        bstr_t nodeName = prop.nodeName.c_str();

        MTPipelineLib::MTSessionPropType sessionPropType;
        sessionPropType = DataTypeToSessionPropType(prop.type);

        if (session->PropertyExists(nameID, sessionPropType))
        {
          switch(prop.type)
          {
            case MTDataTypeLib::MTC_DT_WCHAR:
              { _bstr_t value = session->GetStringProperty(nameID);
                simpleDoc.SetStringProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_INT:
              { long value = session->GetLongProperty(nameID);
                simpleDoc.SetLongProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_BIGINT:
              { __int64 value = session->GetLongLongProperty(nameID);
                simpleDoc.SetLongLongProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_DOUBLE:
              { double value = session->GetDoubleProperty(nameID);
                simpleDoc.SetDoubleProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_TIMESTAMP:
              { time_t value = session->GetDateTimeProperty(nameID);
                simpleDoc.SetDateTimeProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_BOOL:
              { VARIANT_BOOL value = session->GetBoolProperty(nameID);
                simpleDoc.SetBoolProperty(nodeName, (value == VARIANT_TRUE));
                break;
              }
            case MTDataTypeLib::MTC_DT_ENUM:
              {
                int enumID = session->GetEnumProperty(nameID);
                _bstr_t value;

                if (prop.localizeValue)
                {
                  //localize value according to plug-in wide language code.
                  ASSERT(!mLanguageCode.empty());                 
                  _bstr_t name = mNameID->GetName(enumID);
                  value = mLocalConfig->GetLocalizedString(name, mLanguageCode.c_str());
                }
                else
                {
                  //localization not required, use enumerator value
                  value = mEnumConfig->GetEnumeratorByID(enumID);
                }
                
                simpleDoc.SetStringProperty(nodeName, value);
                break;
              }
            case MTDataTypeLib::MTC_DT_DECIMAL:
              { _variant_t value = session->GetDecimalProperty(nameID);
                simpleDoc.SetDecimalProperty(nodeName, value);
              }
              break;

            case MTDataTypeLib::MTC_DT_TIME:
            default: 
              MT_THROW_COM_ERROR("unsupported enum type %i in CARPropagationConfigState::SessionsToXmlDoc", prop.type);
          }
        }
      }

      //add content of simpleDoc to compoundDoc, simpleDoc will be empty after this
      compoundDoc.AddChild(simpleDoc);
    }

    _bstr_t xmlDoc = compoundDoc.GetAsString();
  
    *aXmlDoc = xmlDoc.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}
