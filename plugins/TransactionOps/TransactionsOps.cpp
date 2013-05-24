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
#include <mtprogids.h>
#include <XMLset.h>
#include <vector>
#include <SetIterate.h>

#define MAX __max


struct ExportItem {
public:
	_bstr_t aServer;
	_bstr_t aCookie;
	long aServerID;
	long aCookieID;
};

typedef std::vector<ExportItem> ExportItemList;
typedef ExportItemList::iterator ExportItemListIter;

/////////////////////////////////////////////////////////////////////////////
//class MTServicePropMap
/////////////////////////////////////////////////////////////////////////////

class MTExportItem : public MTXMLSetRepeat {
public:

  MTExportItem(ExportItemList& aList) : mList(aList) {}
  void Iterate(MTXmlSet_Item aSet[]);

protected:
  ExportItemList& mList;
};


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTServicePropMap::Iterate
// Description	    : 
// Return type		: void 
// Argument         : MTXmlSet_Item aSet[]
/////////////////////////////////////////////////////////////////////////////

void MTExportItem::Iterate(MTXmlSet_Item aSet[])
{
  ExportItem aItem;

  aItem.aServer = *aSet[0].mType.aBSTR;
  aItem.aCookie = *aSet[1].mType.aBSTR;
	mList.push_back(aItem);
}


// generate using uuidgen

CLSID CLSID_MTTransactionOps = { /* aea35680-a5f1-11d4-a656-00c04f579c39 */
    0xaea35680,
    0xa5f1,
    0x11d4,
    {0xa6, 0x56, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };

class ATL_NO_VTABLE MTTransactionOps
	: public MTPipelinePlugIn<MTTransactionOps, &CLSID_MTTransactionOps>
{
protected:

	MTTransactionOps() : mTransactionType(transactionenum_guard), mJoinCookieID(-1) {}

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

	enum TransactionTypesEnum {
		transactionenum_guard = -1,
		transactionenum_begin = 0,
		transactionenum_begindistributed = 1,
		transactionenum_joindistributed = 2,
		transactionenum_commit = 3,
		transactionenum_end = 4
	};

  MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTWhereaboutsManagerPtr mWhereaboutsMgr;
	TransactionTypesEnum mTransactionType;
	ExportItemList mExportList;
	MTPipelineLib::IMTEnumeratorCollectionPtr mEnumIter;
	long mJoinCookieID,mTransactionObjectID,mSessionCookie;
	_bstr_t mQueryPath;
};

PLUGIN_INFO(CLSID_MTTransactionOps, MTTransactionOps,
						"MetraPipeline.TransactionOps.1", "MetraPipeline.TransactionOps", "both")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTRoundPlugin ::PlugInConfigure"
HRESULT MTTransactionOps::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

	// these are the actions
	//
	// BeginLocal (deprecated):
	//   NOOP
	//   Beginning a transactions is now implicit when transaction or rowset is requested from session.
	// BeginDistributed (deprecated):
	//   NOOP
	//   Beginning a transactions is now implicit when transaction or rowset is requested from session.
	// JoinDistributed  (deprecated):
	//   Not supported. Use the SessionSet's "TransactionId" or Session's "_TransactionCookie" instead
	// Commit:
	//	 Commits the transaction and starts a new one the next time a transaction (or rowset)
	//   is requested from the session.
	//    Note: If transaction is not owned by the session set, an error is created
	// Export:
	//   Exports transaction for a given server.
	//   Export can be called multiple times if necessary.

	// step 1: define the XML layout
	MTExportItem aExportItem(mExportList);
	_bstr_t aServerNameTemp,aCookieTemp,aJoinCookieTemp;
	long mTransactionTemp;

  DEFINE_XML_SET(ExportSet)
    DEFINE_XML_STRING("servername",aServerNameTemp)
    DEFINE_XML_STRING("cookie",aCookieTemp)
  END_XML_SET()

	DEFINE_XML_SET(TransactionSet)
    DEFINE_XML_INT("TransactionType",mTransactionTemp)
		DEFINE_XML_STRING("JoinCookie",aJoinCookieTemp)
		DEFINE_XML_STRING("QueryPath",mQueryPath)
    DEFINE_XML_OPTIONAL_REPEATING_SUBSET("ExportSet",ExportSet,&aExportItem)
  END_XML_SET()

	mTransactionObjectID = aNameID->GetNameID("_TransactionObject");
	mSessionCookie = aNameID->GetNameID("_transactioncookie");

  // step 2: read service information
  MTLoadXmlSet(TransactionSet,(IMTConfigPropSet*)aPropSet.GetInterfacePtr());

	// step 3: look up the enumerated value for the TransactionType
	MTPipelineLib::IEnumConfigPtr aEnumConfig = aSysContext;
	_bstr_t aTransactionTemp = aEnumConfig->GetEnumeratorValueByID(mTransactionTemp);
	mTransactionType = (TransactionTypesEnum)atoi(aTransactionTemp);

	// step 4: make sure the transaction type is valid
	if(mTransactionType <= transactionenum_guard || mTransactionType >= transactionenum_end) {
		return Error("Invalid transaction type");
	}

	// step 4a: warn for deprecated transaction types
	if(mTransactionType == transactionenum_begin ||
		 mTransactionType == transactionenum_begindistributed)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,
			"BeginLocal and BeginDistributed have been deprecated and will be ignored. Beginning a transactions is now implicit.");
	}

	// step 4b: JoinDistributed not supported
	if (mTransactionType == transactionenum_joindistributed)
	{
		return Error(	"JoinDistributed not supported. Use the SessionSet's TransactionId instead.");
	}

	// step 5: get the nameID on the cookie property if it is required
	if(aJoinCookieTemp.length() > 0) {
		mJoinCookieID = aNameID->GetNameID(aJoinCookieTemp);
	}

	// step 6: get the property IDs
	ExportItemListIter it = mExportList.begin();
	while(it != mExportList.end()) {
		(*it).aServerID = aNameID->GetNameID((*it).aServer);
		(*it).aCookieID = aNameID->GetNameID((*it).aCookie);
		it++;
	}

	// step 7: if the query path is empty, default it
	if(mQueryPath.length() == 0) {
		mQueryPath = "Queries\\transactionops";
	}

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTRoundPlugin::PlugInProcessSession"
HRESULT MTTransactionOps::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr(S_OK);

	// step 1: get the transaction pointer (creating transaction if neccesssary)
	MTPipelineLib::IMTTransactionPtr aTransaction = aSession->GetTransaction(VARIANT_TRUE);

	// step 3: do the transaction operation
	switch(mTransactionType)
	{
		case transactionenum_begin:
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,
					"Ignoring explicit BeginLocal. Beginning a transactions is now implicit.");
				hr = S_OK;
			break;
		case transactionenum_begindistributed:
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,
					"Ignoring explicit BeginDistributed. Beginning a transactions is now implicit.");
				hr = S_OK;
			break;
		case transactionenum_commit:
			if( aTransaction->IsOwner() )
			{
				aSession->CommitPendingTransaction();
			}
			else
			{
				// error if we are committing a non-owned (distributed) transaction
				return Error("Cannot commit transaction. Distributed transaction is not owned.");
			}
			break;

		default:
			ASSERT("invalid transaction type");
	}

	// step 4: evaluate any exports that are required
	ExportItemListIter it = mExportList.begin();
	_bstr_t aTempCookieStr,atempServerName;
	while(it != mExportList.end())
	{
		atempServerName = aSession->GetStringProperty((*it).aServerID);

		// construct mWhereaboutsMgr first time needed
		if (mWhereaboutsMgr == NULL)
		{	hr = mWhereaboutsMgr.CreateInstance(MTPROGID_WHEREABOUTS_MANAGER);
			if(FAILED(hr))
				return hr;
		}
	
		_bstr_t whereabouts = mWhereaboutsMgr->GetWhereaboutsForServer(atempServerName);


		// step 5: get the cookie for the server from the transaction object
		aTempCookieStr = aTransaction->Export(whereabouts);
		// step 6: set the cookie property
		aSession->SetStringProperty((*it).aCookieID,aTempCookieStr);
		it++;
	}

  return hr;
}


