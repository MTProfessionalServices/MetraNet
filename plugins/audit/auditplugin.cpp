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
#include <ComPlusSkeleton.h>
#import <GenericCollection.tlb>
#import <MTAuditEvents.tlb>

// generate using uuidgen
CLSID CLSID_MTAUDITPLUGIN = { /*c86fef70-123f-44cb-9de4-fd6a2ef7effd */
    0xc86fef70,
    0x123f,
    0x44cb,
    {0x96, 0xe4, 0xfd, 0x6a, 0x2e, 0xf7, 0xef, 0xfd}
  };



class ATL_NO_VTABLE MTAuditPlugin
	: public MTComPlusExecutantSkeleton<MTAuditPlugin, &CLSID_MTAUDITPLUGIN>
{
protected:
  STDMETHOD(PlugInConfigure)(MTPipelineLib::IMTLogPtr aLogger,
						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
						MTPipelineLib::IMTNameIDPtr aNameID,
						MTPipelineLib::IMTSystemContextPtr aSysContext,
            VARIANT* configState);

	STDMETHOD(PlugInProcessSession)(MTPipelineLib::IMTSessionPtr aSession,VARIANT ConfigState);
};

//----- This object is replace by the batch version
PLUGIN_INFO(CLSID_MTAUDITPLUGIN, MTAuditPlugin,
			"XXX_depricated_MetraPipeline.MTAuditPluginWriter.1", "XXX_depricated_MetraPipeline.MTAuditPluginWriter", "both")

STDMETHODIMP MTAuditPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
						MTPipelineLib::IMTNameIDPtr aNameID,
						MTPipelineLib::IMTSystemContextPtr aSysContext,
            VARIANT* configState)
{
  try {
    const char* pFuncName = "MTAuditPlugin::PlugInConfigure";
  
    long auditEventID,auditEntityTypeID,auditEntityID,AuditDetailsID;

    DECLARE_PROPNAME_MAP(inputs)
      DECLARE_PROPNAME("AuditEventID",&auditEventID)
      DECLARE_PROPNAME("AuditEntityTypeId",&auditEntityTypeID)
      DECLARE_PROPNAME("AuditEntityId",&auditEntityID)
      DECLARE_PROPNAME("AuditDetails",&AuditDetailsID)
    END_PROPNAME_MAP

    HRESULT hr = ProcessProperties(inputs, aPropSet, aNameID, aLogger,pFuncName);
    if(FAILED(hr)) {
      return hr;
    }

    // create a collection for all of the properties
  
    GENERICCOLLECTIONLib::IMTCollectionPtr aCol(__uuidof(GENERICCOLLECTIONLib::MTCollection));
  
    // the first thing in the collection is a pointer to the auditing object
    IDispatchPtr pDisp = MTAUDITEVENTSLib::IAuditorPtr(__uuidof(MTAUDITEVENTSLib::Auditor));

    aCol->Add(_variant_t(pDisp,true));
    aCol->Add(auditEventID);
    aCol->Add(auditEntityTypeID);
    aCol->Add(auditEntityID);
    aCol->Add(AuditDetailsID);

    IDispatchPtr colDisp = aCol;
    _variant_t pDispVt(colDisp,true);
	  ::VariantInit(configState);
	  ::VariantCopy(configState, &pDispVt);
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}

STDMETHODIMP MTAuditPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession,VARIANT ConfigState)
{
  try {
    GENERICCOLLECTIONLib::IMTCollectionPtr aCol = IDispatchPtr(_variant_t(ConfigState));

    long index = 1;
    MTAUDITEVENTSLib::IAuditorPtr tempAudit = IDispatchPtr(aCol->GetItem(index++));

    long eventID = aSession->GetLongProperty(aCol->GetItem(index++));
		MTPipelineLib::IMTSessionContextPtr ctx = aSession->GetSessionContext();
    long AccountID = ctx->GetAccountID();
    long EntityTypeID = aSession->GetLongProperty(aCol->GetItem(index++));
    long EntityID = aSession->GetLongProperty(aCol->GetItem(index++));
    _bstr_t details = aSession->GetStringProperty(aCol->GetItem(index++));

    tempAudit->FireEvent(eventID,AccountID,EntityTypeID,EntityID,details);
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}



