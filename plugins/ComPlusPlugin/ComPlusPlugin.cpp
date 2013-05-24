/**************************************************************************
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
 * Created by: Ralf Boeck
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
/////////////////////////////////////////////////////////////////////////////
// Description:
// This plugin allows creation of COM+ objects ("Executants") within the
// pipeline's transaction. 
// Executants are only constructed for the duration of a transaction. 
// Typically, COM+ starts a transaction when the root executant gets created
// and passes on the transaction to any nested executants created within the
// root executant. The ComPlusPlugin allows creation of a user defined root
// executant that will be constructed and enlisted in the pipeline's transaction
// for the duration of the processing of one session set. 
//
// The executants cannot keep state since they are destroyed after each method call.
// However. the ComPlusPlugin calls a configure method on the executant from which
// the executant can return a configState object (of type Variant).The ComPlusPlugin 
// holds on to that configState and passes it into every ProcessSessions call.
//
// An executant must implement the IMTPipelineExecutant interface
// (see the VBSubscribeExec for an example)
//
// Configuration Example:
//   <configdata>
//     <ExecutantProgid>VBSubscribeExec.Writer</ExecutantProgid>
//     <ExecutantConfigdata>
//       <!-- Executant specific configuration data here-->
//     </ExecutantConfigdata>
//   </configdata>
/////////////////////////////////////////////////////////////////////////////

#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <XMLset.h>
#include <vector>
#include <SetIterate.h>

#pragma warning (disable : 4192)
#import <ComSvcs.dll> exclude("IAppDomainHelper") rename("GetObject", "GetObjectCS")
#pragma warning (default : 4192)


// generate using uuidgen
CLSID CLSID_MTComPlusPlugin = // {791522CA-6AD8-4545-81A7-B2AC3E0DE47D}
  { 0x791522ca, 0x6ad8, 0x4545, { 0x81, 0xa7, 0xb2, 0xac, 0x3e, 0xd, 0xe4, 0x7d } };

class ATL_NO_VTABLE MTComPlusPlugin
  : public MTPipelinePlugIn<MTComPlusPlugin, &CLSID_MTComPlusPlugin>
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


  virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
  virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession) {return E_NOTIMPL;}

protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
  MTPipelineLib::IMTSystemContextPtr mSysContext;
  CLSID mExecutantCLSID;
  variant_t mConfigState;
};

PLUGIN_INFO(CLSID_MTComPlusPlugin, MTComPlusPlugin,
            "MetraPipeline.ComPlusPlugin.1", "MetraPipeline.ComPlusPlugin", "both")


/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT MTComPlusPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                        MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                        MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  try
  {
    mLogger = aLogger;
    mSysContext = aSysContext;

    std::string executantProgID = aPropSet->NextStringWithName(L"ExecutantProgid");
    std::string msg = "Configuring Executant: " + executantProgID;
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg.c_str());

    // get the executant's CLSID and store it for use in ProcessSesssions
    HRESULT hr = CLSIDFromProgID((bstr_t)executantProgID.c_str(), &mExecutantCLSID);
    if(FAILED(hr))
      return hr;

    // construct the executant, get it's config state, and release it
    // the config state will be passed into any future ProcessSessions
    MTPipelineLib::IMTPipelineExecutantPtr  exec(mExecutantCLSID);
    MTPipelineLib::IMTConfigPropSetPtr execPropSet;
    execPropSet = aPropSet->NextSetWithName("ExecutantConfigdata");
    mConfigState = exec->Configure(aSysContext, execPropSet);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////


HRESULT MTComPlusPlugin::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  try
  {
    // get the transaction pointer from the first session (creating transaction if neccesssary)
    SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
    HRESULT hr = it.Init(aSet);
    if (FAILED(hr))
        return hr;

    MTPipelineLib::IMTSessionPtr session = it.GetNext();
    if (session == NULL)
      return S_OK;

    MTPipelineLib::IMTTransactionPtr mtTxn = session->GetTransaction(VARIANT_TRUE);
    COMSVCSLib::ITransactionPtr txn = mtTxn->GetTransaction();
    
    // create the BYOT object
    COMSVCSLib::ICreateWithTransactionExPtr createWithTransaction("Byot.ByotServerEx");

    //create executant in current transaction context
    GUID interfaceGUID = __uuidof(MTPipelineLib::IMTPipelineExecutant);
    MTPipelineLib::IMTPipelineExecutantPtr exec;
    void* pVoid = createWithTransaction->CreateInstance(txn, &mExecutantCLSID,&interfaceGUID);
    exec = reinterpret_cast<MTPipelineLib::IMTPipelineExecutant*>(pVoid);
    
    //call process sessions on the executant
    exec->ProcessSessions(aSet.GetInterfacePtr(), mSysContext, mConfigState);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}

