// ARPropagationWriter.cpp : Implementation of CARPropagationWriter

#include "StdAfx.h"
#include <map>
#include <string>

#include "ARPropagationExec.h"
#include "ARPropagationWriter.h"
#include "ARDocument.h"
#include "ARInterfaceMethod.h"

#import "ARPropagationExec.tlb"
#import "MetraTech.AR.tlb"
//#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
//#import "MetraTech.AR.tlb" inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CARPropagationWriter

/******************************************* error interface ***/
STDMETHODIMP CARPropagationWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &__uuidof(IMTPipelineExecutant)
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}


HRESULT CARPropagationWriter::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CARPropagationWriter::CanBePooled()
{
  return FALSE;
} 

void CARPropagationWriter::Deactivate()
{
  mpObjectContext.Release();
} 

STDMETHODIMP CARPropagationWriter::Configure(IDispatch *        aSystemContext,
                                             IMTConfigPropSet * aPropSet,
                                              VARIANT *         apConfigState)
{
  MTAutoContext context(mpObjectContext);

  if (apConfigState == NULL)
    return E_POINTER;

  try
  {
    // create a configState object to return
    ARPROPAGATIONEXECLib::IARPropagationConfigStatePtr myConfigState(__uuidof(ARPROPAGATIONEXECLib::ARPropagationConfigState));
    
    // let config state figure out and store the properties (to avoid making COM objects out of those)
    myConfigState->Configure(aSystemContext, reinterpret_cast<ARPROPAGATIONEXECLib::IMTConfigPropSet*>(aPropSet));

    // configure AR interface  
    MTARInterfaceLib::IMTARConfigPtr ARConfig(MTPROGID_MTARCONFIG);
    variant_t ARConfigState = ARConfig->Configure();

    // store ARConfigState in my configState
    myConfigState->ARConfigState = ARConfigState;

    // store (AddRef'ed) IDispatch in variant
    // (since we need to return a variant)
    variant_t varMyConfigState = myConfigState.GetInterfacePtr();

    // return state
    *apConfigState = varMyConfigState.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CARPropagationWriter::ProcessSessions(IMTSessionSet * aSessions,
                                                   IDispatch *     aSystemContext,
                                                   VARIANT         aConfigState)
{
  MTAutoContext context(mpObjectContext);

  try
  {
    // get the config state object from the variant
    variant_t varMyConfigState = aConfigState;
    ARPROPAGATIONEXECLib::IARPropagationConfigStatePtr myConfigState;
    myConfigState = varMyConfigState;
    MTPipelineLib::IMTLogPtr logger = aSystemContext;
    
    // Get the method id we are calling
    ARInterfaceMethod method = (ARInterfaceMethod) myConfigState->Method;

    // only process sessions in the configured AR namespace
    // create a set to hold the sessions to be exported
    MTPipelineLib::IMTSessionSetPtr filteredSessionSetPtr;
    MTPipelineLib::IMTSessionPtr session;

    HRESULT hr = S_OK;
    long nSessionsToProcess = 0;

    MetraTech_AR::IARConfigurationProxyPtr ARConfig;
    hr=ARConfig.CreateInstance("MetraTech.AR.ARConfigurationProxy");
    if (FAILED(hr))
    {
      logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unable to create AR configuration object");
      return hr;
    }
    _bstr_t bstrARExportNamespace;
    bstrARExportNamespace = ARConfig->GetAccountNameSpace();

    _bstr_t xmlDoc;

    // If we are creating or updating accounts, create a subset of
    // sessions that match the namespace configured in ARConfig.xml
    if ((method == ARMETHOD_CreateOrUpdateAccounts)
     && (bstrARExportNamespace.length() != 0))
    {
      // look up the property IDs of the props we need
      MTPipelineLib::IMTNameIDPtr idlookup(aSystemContext);
      long lNamespaceId = idlookup->GetNameID("ARExternalNameSpace");

      // Create a new session set for this batch
      // initialize our session server object
      MTPipelineLib::IMTSessionServerPtr SessionServer;
      hr = SessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
      if (FAILED(hr))
      {
        logger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unable to create session server object");
        return hr;
      }

      std::map<string, MTPipelineLib::IMTSessionSetPtr> mapSessionSets; // keys and values are strings
      _bstr_t bstrARExportNamespaces;
      bstrARExportNamespaces = ARConfig->GetAccountNameSpaces();

      string sARExportNamespaces = bstrARExportNamespaces;
      string delimeters = ";";
      string::size_type lastPos = 0;
      string::size_type pos     = sARExportNamespaces.find_first_of(delimeters, lastPos);

      while ((string::npos != pos)
          || (string::npos != lastPos))
      {
          string temp = sARExportNamespaces.substr(lastPos, pos - lastPos);
          filteredSessionSetPtr = SessionServer->CreateSessionSet();
          mapSessionSets.insert(std::map<string,MTPipelineLib::IMTSessionSetPtr>::value_type(temp, filteredSessionSetPtr));

          // Skip delimiters.  Note the "not_of"
          lastPos = sARExportNamespaces.find_first_not_of(delimeters, pos);
          // Find next "non-delimiter"
          pos = sARExportNamespaces.find_first_of(delimeters, lastPos);
      }

      //int iCount = oAccountNamespaces.Count;

      /*for (int i=0; i<mAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = mAccountNameSpaces[i].ToString();
      }
      */

      /*
      m[s1] = s2;   // associate key Cam with value Biff
      m["Barb"] = "Chas";
      m.insert( pair<string,string>("Jane", "Art") );
      m.insert( map<string,string>::value_type( "Dawn","Dan" ));
      */

      filteredSessionSetPtr = SessionServer->CreateSessionSet();
      // gets an iterator for the set of sessions
      SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
      hr = it.Init(aSessions);
      if (FAILED(hr))
        return hr;

      while ((session = it.GetNext()) != NULL)  
      {
        _bstr_t bstrNamespace;
        if (session->PropertyExists(lNamespaceId, MTPipelineLib::SESS_PROP_TYPE_STRING))
        {
          bstrNamespace = session->GetStringProperty(lNamespaceId);
        }
        
        if (mapSessionSets.count(string(bstrNamespace)) == 0)
        {
          string msg = "The AR external system namespace '" + string(bstrNamespace) + "' specified in the session has not been configured for AR export.";
          logger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg.c_str());
          //TODO: Generate pipleline error for this session
        }
        else if (bstrNamespace.length()!=0)
        {
          mapSessionSets[string(bstrNamespace)]->AddSession(session->GetSessionID(), session->GetServiceID());
        }

        /*if (_wcsicmp(bstrNamespace,bstrARExportNamespace)==0)
        {
          nSessionsToProcess++;
          // If we got here, there were no errors, so we will add this session to the set that will be processed by the helper plugin
          filteredSessionSetPtr->AddSession(session->GetSessionID(), session->GetServiceID());
        }
        */
      }

      //We have sorted the sessions, now send them
      std::map<string, MTPipelineLib::IMTSessionSetPtr>::iterator itSessionSet = mapSessionSets.begin();
      for( ; itSessionSet != mapSessionSets.end(); itSessionSet ++ )
      {
        int iCount = itSessionSet->second->GetCount();
        nSessionsToProcess += iCount;
        if (iCount == 0)
        {
          string msg = "There are no sessions for AR external system namespace '" + itSessionSet->first + "' in this session set to be exported to AR.";
          logger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg.c_str());
        }
        else
        {
          string msg = "Sending documents with AR external system namespace '" + itSessionSet->first + "' to external AR system.";
          xmlDoc = myConfigState->SessionsToExternalARXmlDoc(reinterpret_cast<ARPROPAGATIONEXECLib::IMTSessionSet*>(itSessionSet->second.GetInterfacePtr()), itSessionSet->first.c_str());
        }

      }

      /*
      if (nSessionsToProcess)
      {
        xmlDoc = myConfigState->SessionsToXmlDoc(reinterpret_cast<ARPROPAGATIONEXECLib::IMTSessionSet*>(filteredSessionSetPtr.GetInterfacePtr()));
      }
      else
      {
        string msg = "No sessions with with namespace '" + bstrARExportNamespace + "' to be exported to AR. Nothing to be done.";
        logger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg.c_str());
      }
      */
    }
    else
    {
      // process all sessions and convert them to an XMLDoc
      xmlDoc = myConfigState->SessionsToXmlDoc(reinterpret_cast<ARPROPAGATIONEXECLib::IMTSessionSet*>(aSessions));
      nSessionsToProcess = 1; //Set to 1 just to indicate that there is at least one session to process
    }
    
    if (nSessionsToProcess)
    {
      //get ARConfigState
      variant_t ARConfigState = myConfigState->ARConfigState;

      //construct an ARWriter for the duration of this method call
      MTARInterfaceLib::IMTARWriterPtr ARWriter(MTPROGID_MTARWRITER);
    
      //call method
      switch(method)
      { case ARMETHOD_CreateOrUpdateAccounts:
          ARWriter->CreateOrUpdateAccounts( xmlDoc, ARConfigState );
          break;
    
        case ARMETHOD_UpdateAccountStatus:
          ARWriter->UpdateAccountStatus( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_CreateOrUpdateTerritories:
          ARWriter->CreateOrUpdateTerritories( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_UpdateTerritoryManagers:
          ARWriter->UpdateTerritoryManagers( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_CreateOrUpdateSalesPersons:
          ARWriter->CreateOrUpdateSalesPersons( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_MoveBalances:
          ARWriter->MoveBalances( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_CreateInvoices:
          ARWriter->CreateInvoices( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_CreateAdjustments:
          ARWriter->CreateAdjustments( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_CreatePayments:
          ARWriter->CreatePayments( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_DeletePayments:
          ARWriter->DeletePayments( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_DeleteBatches:
          ARWriter->DeleteBatches( xmlDoc, ARConfigState );
          break;

        case ARMETHOD_ApplyCredits:
          ARWriter->ApplyCredits( ARConfigState );
          break;

        case ARMETHOD_RunAging:
          ARWriter->RunAging( xmlDoc, ARConfigState );
          break;

        default:
          MT_THROW_COM_ERROR("unsupported ARInterfaceMethod: %s",
                            ARInterfaceMethodToString(method).c_str());
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
