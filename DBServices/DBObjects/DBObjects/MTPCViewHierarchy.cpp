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

#include <metra.h>
#include <DBViewHierarchy.h>

#include <DBInMemRowset.h>
#include <MTUtil.h>

#include <mtprogids.h>
#include <DBSummaryView.h>
#include <DBProductView.h>
#include <DBDiscountView.h>
#include <DBDataAnalysisView.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <mtglobal_msg.h>
#include <LanguageList.h>

#include <loggerconfig.h>
#include <DBUsageCycle.h>
#include <mtcomerr.h>
#include <SetIterate.h>
#include <vector>
#include <stdutils.h>
#include <MTDec.h>

#include <ConfigDir.h>

#include <SetIterate.h>
#include <set>

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace
#import <NameID.tlb>

class MTProductOfferingView : public DBView
{
public:
	MTProductOfferingView();
	virtual ~MTProductOfferingView();
	 
	BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
		const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID) 
		{
			return GetDisplayItems(arAcctID,arIntervalID,arLangCode,L"",arpRowset,instanceID);
		}
  
 BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
  const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID) ;
  
 BOOL Summarize(const int &arAcctID, const int &arIntervalID,
  DBSQLRowset * & arpRowset)
	{
		return Summarize(arAcctID,arIntervalID,arpRowset,L"");
	}
  
 BOOL Summarize(const int &arAcctID, const int &arIntervalID,
  DBSQLRowset * & arpRowset, const std::wstring &arExtension);

 BOOL AddRowsetAndComputeValues(ROWSETLib::IMTSQLRowsetPtr aRowset);

protected:
	MTDecimal mPO_amount;
	MTDecimal mPO_amountwithTax;
	_bstr_t mAggrateRate;
	DBSQLRowset mRowset;
	MTAutoSingleton<DBUsageCycleCollection> mUsageCycleCol;
	_variant_t mVtCurrency;
};

MTProductOfferingView::MTProductOfferingView() : mAggrateRate("N")
{
}

MTProductOfferingView::~MTProductOfferingView()
{

}

BOOL MTProductOfferingView::AddRowsetAndComputeValues(ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	_RecordsetPtr aTempRecordSet = aRowset->GetPopulatedRecordSet();
	mRowset.PutRecordSet(aTempRecordSet->Clone(adLockUnspecified ));

	try {
		mRowset.MoveFirst();
		_bstr_t TrueValue("Y");
		// get the first row's currency
		mRowset.GetValue("Currency",mVtCurrency);
		for(long i=0;i<mRowset.GetRecordCount();i++) {
			_variant_t vtParentID;
			BOOL bRetVal = mRowset.GetValue("pv_parentID",vtParentID);
			ASSERT(bRetVal);
			if(vtParentID.vt != VT_NULL && (long)vtParentID == mID) {
				// XXX error checking
				_variant_t amount,amountwithtax,parent;
					mRowset.GetValue("Amount",amount);
					mRowset.GetValue("AmountWithTax",amountwithtax);
					mRowset.GetValue("id_template_parent",parent);
				// we only care abouts parents at this level
				if(parent.vt == VT_NULL || parent.vt == VT_EMPTY) {
					if(amount.vt != VT_NULL) mPO_amount += amount;
					if(amountwithtax.vt != VT_NULL) mPO_amountwithTax += amountwithtax;
				}

				_bstr_t aRowsetAggFlagStr;
				_variant_t aTempValue;
				mRowset.GetValue("AggRate",aTempValue);
				aRowsetAggFlagStr = aTempValue;
				// only check the aggRate value if it is not already set
				if(aRowsetAggFlagStr == TrueValue) {
					mAggrateRate = TrueValue;
				}
			}
			mRowset.MoveNext();
		}
		// reset
		mRowset.MoveFirst();
	}
	catch(_com_error&) {
		ASSERT(!"Why is this failing?");
		return FALSE;
	}
	return TRUE;
}



BOOL MTProductOfferingView::GetDisplayItems(const int &arAcctID, const int &arIntervalID,
  const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID)
{
	DBSQLRowset* pDbSQLRowset = new DBSQLRowset;
	mRowset.MoveFirst();

	// XXX Replace with inmem rowset
	_RecordsetPtr aNewRecordSet = _RecordsetPtr(mRowset.GetRecordsetPtr())->Clone(adLockUnspecified );
	char buff[256];
	sprintf(buff,"id_template_parent = NULL AND pv_parentID = %d",mID);
	aNewRecordSet->PutFilter(buff);
	pDbSQLRowset->PutRecordSet(aNewRecordSet);
	arpRowset = pDbSQLRowset;
	return TRUE;
}

BOOL MTProductOfferingView::Summarize(const int &arAcctID, const int &arIntervalID,
  DBSQLRowset * & arpRowset, const std::wstring &arExtension)
{
	BOOL bRetCode = TRUE;

	try {

		DATE start,end;
		if(!mUsageCycleCol->GetIntervalStartAndEndDate(arIntervalID,start,end)) {
			// XXX is this all we need here
			return FALSE;
		}

		arpRowset = new DBSQLRowset;
		if(!InitializeInMemRowset(arpRowset)) {
			// XXX would only fail in catastrophic circumstances (I hope)
			mLogger->LogThis(LOG_ERROR,"Failed to initialize in memory rowset");
			return FALSE;
		}
		arpRowset->AddRow();
		arpRowset->AddColumnData(DB_VIEW_ID,(long)mID);
		arpRowset->AddColumnData(DB_VIEW_NAME,(const wchar_t*)mName.c_str());
		arpRowset->AddColumnData(DB_DESCRIPTION_ID,(long)mDescriptionID);
		arpRowset->AddColumnData(DB_VIEW_TYPE,(const wchar_t*)mType.c_str());
		arpRowset->AddColumnData(DB_AMOUNT,mPO_amount);
		arpRowset->AddColumnData(DB_CURRENCY,mVtCurrency);
		arpRowset->AddColumnData(DB_COUNT,1l);
		arpRowset->AddColumnData(DB_TAX_AMOUNT,mPO_amountwithTax-mPO_amount);
		arpRowset->AddColumnData(DB_AMOUNT_WITH_TAX,mPO_amountwithTax);
		arpRowset->AddColumnData(DB_ACCOUNT_ID,(long)arAcctID);
		arpRowset->AddColumnData(DB_INTERVAL_ID,(long)arIntervalID);
		arpRowset->AddColumnData(DB_INTERVAL_START,_variant_t(start,VT_DATE));
		arpRowset->AddColumnData(DB_INTERVAL_END,_variant_t(end,VT_DATE));
		arpRowset->AddColumnData(DB_AGG_RATE,mAggrateRate);
	}
	catch(_com_error& e) {
		ErrorObject* pError = CreateErrorFromComError(e);
		mLogger->LogErrorObject(LOG_ERROR,pError);
		bRetCode = FALSE;
		delete pError;
	}
	return bRetCode;
}


MTPCViewHierarchy::~MTPCViewHierarchy()
{
	PCAccountViewMap::iterator it;
	for (it = mAccountViewCol.begin(); it != mAccountViewCol.end();	it++)
		delete it->second;

	mAccountViewCol.clear();
}

BOOL MTPCViewHierarchy::FindView(const int aViewID, DBView * & arpView)
{
	// NOTE: don't ever make this autosingleton a member variable!
	// It will create a circular dependency between MTPCHierarchyColl and
	// MTPCViewHierarchy in which both will be leaked!
	MTAutoSingleton<MTPCHierarchyColl> viewHierarchyCol;

	long RealViewID = aViewID;
	if(RealViewID < 0 && !viewHierarchyCol->TranslateID(RealViewID,RealViewID)) {
		// error if we can not translate the priceable item instance ID to 
		// the product view ID.
		return FALSE;
	}


	PCAccountViewMap::iterator it = mAccountViewCol.find(RealViewID);
	if(it != mAccountViewCol.end()) {
		arpView = (*it).second;
		return TRUE;
	}
	else {

		// try the old style XML view hierarchy
		try {
			MTAutoSingleton<DBViewHierarchy> mXmlVHInstance;
			if(!mXmlVHInstance->FindView(RealViewID,arpView)) {
				SetError(mXmlVHInstance->GetLastError());
				return FALSE;
			}
		}
		catch(ErrorObject& err) {
			SetError(&err);
			return FALSE;
		}
	}
	return TRUE;
}


BOOL MTPCViewHierarchy::Initialize(const long lAccountID,const long aIntervalID,const wchar_t* aLanguageCode)
{

	// instance of XML view hierarchy
	MTAutoSingleton<DBViewHierarchy> mXmlVHInstance;
	MTAutoSingleton<MTPCHierarchyColl> PCViewHierarchy;

	mAccountID = lAccountID;
	mIntervalID = aIntervalID;

	long nLangCode = 840 ; // default to english 

	// lookup the language code ID
	// get the language id.  more inefficient string operations.  Yummy!
	std::wstring aTempStr(aLanguageCode);
	_wcslwr((wchar_t *)aTempStr.c_str());
	_bstr_t langkey = aTempStr.c_str();

	MTAutoSingleton<CLanguageList> langList;
	const ReverseLanguageList& alist = langList->GetReverseLanguageList();
	ReverseLanguageListIterator iter = alist.find(langkey);
	if(iter == alist.end()) {
    mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
			(const char*)langkey);
		return FALSE;
	}
	nLangCode = (*iter).second;


	try {

		ROWSETLib::IMTSQLRowsetPtr aRowset(MTPROGID_SQLROWSET);
		aRowset->Init("Queries\\PresServer");
		aRowset->SetQueryTag("__GET_PCVIEWHIERARCHY__");
		aRowset->AddParam("%%ID_ACC%%",lAccountID);
		aRowset->AddParam("%%INTERVAL%%",aIntervalID);
		aRowset->AddParam("%%LANG_ID%%",nLangCode);
		aRowset->Execute();
		/*
		aRowset->InitializeForStoredProc("GetPCViewHierarchy");
		aRowset->AddInputParameterToStoredProc (	"id_acc", MTTYPE_INTEGER, INPUT_PARAM,lAccountID);
		aRowset->AddInputParameterToStoredProc (	"id_interval", MTTYPE_INTEGER, INPUT_PARAM,aIntervalID);
		aRowset->AddInputParameterToStoredProc (	"@id_lang_code", MTTYPE_INTEGER, INPUT_PARAM,aLanguageCodeID);
		aRowset->ExecuteStoredProc();
		*/

		std::set<std::string> po_set;
		int currentPO = 0;

		// create instance of nameID

		NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);
		int aRootViewID = aNameID->GetNameID("Root");

		// add the standard summary item to the collection
    // <id_view ptype="ENUM">Root</id_view>
    // <id_parent_view ptype="INTEGER">-99</id_parent_view>
    // <nm_view_type>Summary</nm_view_type>
		DBSummaryView* pDBSummaryView = new DBSummaryView ;
		if(!pDBSummaryView->Init(L"Summary", aRootViewID, 
			L"Summary", 
			aRootViewID)) {
			ASSERT(!"This should never break; fix me");
		}
		mAccountViewCol[pDBSummaryView->GetViewID()] = pDBSummaryView;
		pDBSummaryView->AddParentViewID(-99);

		// get the summary view from the XML hierarchy
		DBView* pXmlSummary;
		if(!mXmlVHInstance->FindView(aRootViewID,pXmlSummary)) {
			// this should never fail
			ASSERT(0);
		}

		for(DBViewIDCollIter Iter = pXmlSummary->mChildViewList.begin(); 
				Iter != pXmlSummary->mChildViewList.end();
				Iter++) {
				pDBSummaryView->AddChildViewID(*Iter);
		}


		// step : iterate through each row, populating the dbview object
		for(long i=0;i<aRowset->GetRecordCount();i++) {

			// add a mapping for the instance ID to the view ID
			PCViewHierarchy->AddInstanceIdMapping(aRowset->GetValue("viewID"),aRowset->GetValue("realPVID"));

			po_set.insert((const char*)_bstr_t(aRowset->GetValue("po_nm_name")));

			// TODO: fix me! (part 1)
			// MTautoptr<DBProductView> pDBProductView = new DBProductView;
			CMSIXDefinition *pProductView ;
			MTProductOfferingView* pPOView;

			_bstr_t pvName = aRowset->GetValue("pv_child");
			_variant_t POid = aRowset->GetValue("id_po");
			long aTempPO = POid.vt == VT_NULL ? -1 : (long)POid;
			if(currentPO != aTempPO && aTempPO > 0) {
				currentPO = aTempPO,
				// create a new product offering level object
				pPOView = new MTProductOfferingView;
				pPOView->Init(L"POSummary",currentPO,(const wchar_t*)_bstr_t(aRowset->GetValue("po_nm_name")),currentPO);
				mAccountViewCol[pPOView->GetViewID()] = pPOView;
				pPOView->AddParentViewID(aRootViewID);
				pDBSummaryView->AddChildViewID(pPOView->GetViewID());
				pPOView->AddRowsetAndComputeValues(aRowset);

			}

			if(mXmlVHInstance->GetPVColl().FindProductView ((const wchar_t*)pvName, pProductView)) {

				// if the parent ID is not NULL, find the product view and add it to the POSummary collection
				_variant_t aParentVariant = aRowset->GetValue("pv_parentID");
				if(aParentVariant.vt != VT_NULL && (long)aParentVariant == currentPO) {
					// TODO: fix me! (part 2)
					// pPOView->AddChildViewID(pDBProductView->GetViewID());
				}
				else {
					mPoSummaryRows = true;

				}
			}
			else {
				mLogger->LogThis(LOG_ERROR,"MTPCViewHierarchy: failed to find product view");
				return FALSE;
			}
			aRowset->MoveNext();

			/*


				// if the parent ID is NULL, simply record the fact so that we can snarf the rowset later
				// for viewing at the summary level


				long pvid = aRowset->GetValue("pv_childID");
				_variant_t aParentVariant = aRowset->GetValue("pv_parentID");
				long parentID;
				if(aParentVariant.vt == VT_NULL) {
					parentID = aRootViewID;
				}
				else {
					parentID = (long)aParentVariant;
				}
				if(pDBProductView->Init(
					L"Product", // type of view
					pvid, // id 
					(const wchar_t*)_bstr_t(aRowset->GetValue("ViewName")),
					pvid, // id
					pProductView)) {
						mAccountViewCol[pDBProductView->GetViewID()] = pDBProductView;
						pDBProductView->AddParentViewID(parentID);
						if(parentID != currentPO) {
							// find parent and add this child
							PCAccountViewMap::iterator it = mAccountViewCol.find(parentID);
							if(it == mAccountViewCol.end()) {
								ASSERT(0);
							}
							(*it).second->AddChildViewID(pvid);
						}
					}
				else {
					mLogger->LogThis(LOG_ERROR,"MTPCViewHierarchy: failed to initialize product view");
					delete pDBProductView;
					return FALSE;
				}
				
				// add the priceable item to the product offerings view as a child 
				// if it is the parent
				if(parentID == currentPO) {
					pPOView->AddChildViewID(pDBProductView->GetViewID());
				}
			}
			else {
				mLogger->LogThis(LOG_ERROR,"MTPCViewHierarchy: failed to find product view");
				delete pDBProductView;
				return FALSE;
			}
			aRowset->MoveNext();
			*/
		}
		// hold onto our recordset for later
		if(mPoSummaryRows) {
			mNoPoSummaryRowset = aRowset;
		}

	}
	catch(_com_error& e) {
		//ASSERT(!"Unhandled error");
		ErrorObject* pError = CreateErrorFromComError(e);
		mLogger->LogErrorObject(LOG_ERROR,pError);
		delete pError;
		return FALSE;
	}
	catch(ErrorObject&) {
		mLogger->LogThis(LOG_ERROR,"caught error attempting to access the XML view hierarchy singleton.  perhaps an XML file is invalid?");
		return FALSE;
	}
	return TRUE;
}



BOOL MTPCViewHierarchy::PopulateInMemRowset(DBSQLRowset& arRowset)
{
	// step 1: only populate the in memory recordset if we have non product offering summary rowsets
	try {
		if(mPoSummaryRows) {

			mNoPoSummaryRowset->MoveFirst();
			// step 2: iterate through the rowset
			for(int i=0;i<mNoPoSummaryRowset->GetRecordCount();i++) {
				// step 3: only add a record if the parent ID is NULL.
				// XXX does this break compounds that are not part of a product offering?

				if(mNoPoSummaryRowset->GetValue("pv_parentID").vt == VT_NULL) {
					DBView::InsertCurrentRowIntoInMemRowset(mIntervalID,mAccountID,arRowset,mNoPoSummaryRowset);
				}
				mNoPoSummaryRowset->MoveNext();
			}
		}
	}
	catch(_com_error& e) {
		mLogger->LogVarArgs(LOG_ERROR,"error populating inmemrowset with product catalog non product offering summarization data,error %s",
			e.Description().length() == 0 ? "no detailed error" : (const char*)e.Description());
		return FALSE;
	}
	return TRUE;
}



