/**************************************************************************
* Copyright 2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalog.h"
#include "MTGroupSubscription.h"
#include <metra.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <optionalvariant.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <MTObjectCollection.h>

/////////////////////////////////////////////////////////////////////////////
// CMTGroupSubscription

CMTGroupSubscription::~CMTGroupSubscription()
{
	for(std::map<long, TemporalProperty*>::iterator it = mRecurringChargeAccount.begin(); it!=mRecurringChargeAccount.end(); it++)
	{
		delete it->second;
	}
}

STDMETHODIMP CMTGroupSubscription::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGroupSubscription,
    &IID_IMTSubscriptionBase,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTGroupSubscription::FinalConstruct()
{
	try {
		LoadPropertiesMetaData(PCENTITY_TYPE_GROUPSUBSCRIPTION);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err) { 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}


STDMETHODIMP CMTGroupSubscription::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTGroupSubscription::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_CorporateAccount(long *pVal)
{
	return GetPropertyValue("CorporateAccount",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_CorporateAccount(long newVal)
{
	return PutPropertyValue("CorporateAccount",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_ProportionalDistribution(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ProportionalDistribution",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_ProportionalDistribution(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ProportionalDistribution",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_DistributionAccount(long *pVal)
{
	return GetPropertyValue("DistributionAccount",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_DistributionAccount(long newVal)
{
	return PutPropertyValue("DistributionAccount",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_GroupID(long *pVal)
{
	return GetPropertyValue("id_group",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_GroupID(long newVal)
{
	return PutPropertyValue("id_group",newVal);
}

STDMETHODIMP CMTGroupSubscription::put_SupportGroupOps(VARIANT_BOOL newVal)
{
	return PutPropertyValue("supportgroupops",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_SupportGroupOps(VARIANT_BOOL* pVal)
{
	return GetPropertyValue("supportgroupops",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_HasRecurringCharges(VARIANT_BOOL newVal)
{
	return PutPropertyValue("hasrecurringcharges",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_HasRecurringCharges(VARIANT_BOOL* pVal)
{
	return GetPropertyValue("hasrecurringcharges",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_HasDiscounts(VARIANT_BOOL newVal)
{
	return PutPropertyValue("hasdiscounts",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_HasDiscounts(VARIANT_BOOL* pVal)
{
	return GetPropertyValue("hasdiscounts",pVal);
}

STDMETHODIMP CMTGroupSubscription::put_HasPersonalRates(VARIANT_BOOL newVal)
{
	return PutPropertyValue("haspersonalrates",newVal);
}

STDMETHODIMP CMTGroupSubscription::get_HasPersonalRates(VARIANT_BOOL* pVal)
{
	return GetPropertyValue("haspersonalrates",pVal);
}


STDMETHODIMP CMTGroupSubscription::MemberShipAtDate(DATE RefDate,IMTGroupSubSlice** ppSlice)
{
	ASSERT(ppSlice);
	if(!ppSlice) return E_POINTER;

	MTPRODUCTCATALOGLib::IMTGroupSubSlicePtr aNewSubSlice(__uuidof(MTPRODUCTCATALOGLib::MTGroupSubSlice));
	_variant_t empty;

	long groupID;
	get_GroupID(&groupID);
	aNewSubSlice->Initialize(RefDate,groupID,empty);
	*ppSlice = reinterpret_cast<IMTGroupSubSlice*>(aNewSubSlice.Detach());
	return S_OK;
}

STDMETHODIMP CMTGroupSubscription::MembershipNow(IMTGroupSubSlice **ppSlice)
{
	ASSERT(ppSlice);
	if(!ppSlice) return E_POINTER;

	MTPRODUCTCATALOGLib::IMTGroupSubSlicePtr aNewSubSlice(__uuidof(MTPRODUCTCATALOGLib::MTGroupSubSlice));
	_variant_t empty;

	long groupID;
	get_GroupID(&groupID);
	aNewSubSlice->Initialize(GetMTOLETime(),groupID,empty);
	*ppSlice = reinterpret_cast<IMTGroupSubSlice*>(aNewSubSlice.Detach());
	return S_OK;
}

STDMETHODIMP CMTGroupSubscription::MembershipAtSystemDate(DATE RefDate,DATE SystemDate, IMTGroupSubSlice **ppSlice)
{
	ASSERT(ppSlice);
	if(!ppSlice) return E_POINTER;

	MTPRODUCTCATALOGLib::IMTGroupSubSlicePtr aNewSubSlice(__uuidof(MTPRODUCTCATALOGLib::MTGroupSubSlice));
	_variant_t empty;

	long groupID;
	get_GroupID(&groupID);
	aNewSubSlice->Initialize(RefDate,groupID,SystemDate);
	*ppSlice = reinterpret_cast<IMTGroupSubSlice*>(aNewSubSlice.Detach());
	return S_OK;
}


STDMETHODIMP CMTGroupSubscription::Membership(IMTGroupSubSlice **ppSlice)
{
	try {
		MTPRODUCTCATALOGLib::IMTGroupSubSlicePtr aNewSubSlice(__uuidof(MTPRODUCTCATALOGLib::MTGroupSubSlice));

		long groupID;
		get_GroupID(&groupID);
		aNewSubSlice->InitializeAllMembers(groupID);
		*ppSlice = reinterpret_cast<IMTGroupSubSlice*>(aNewSubSlice.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}
	return S_OK;
}


STDMETHODIMP CMTGroupSubscription::AddAccount(IMTGSubMember* pSubMember,VARIANT_BOOL* pDateModified)
{
	ASSERT(pSubMember);
	if(!pSubMember) return E_POINTER;

	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_ADD_DENIED;
    CheckAddToGroupSub();

    MTPRODUCTCATALOGLib::IMTGSubMemberPtr member(pSubMember);
    // validate that all of the required properties are present
    member->Validate();

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		*pDateModified = SubWriter->AddAccountToGroupSub(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGSubMember*>(member.GetInterfacePtr()));
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), err);
	}
	return S_OK;
}

STDMETHODIMP CMTGroupSubscription::AddAccountBatch(IMTCollection *pCol,
																									 IMTProgress* pProgress,
                                                   VARIANT_BOOL* pDateModified,
                                                   VARIANT pTransaction,
																									 IMTRowSet **ppRowset)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_ADD_DENIED;
    CheckAddToGroupSub();

    GUID subGUID = __uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter);

    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(pTransaction,VT_UNKNOWN,trans)) {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else {
      SubWriter.CreateInstance(subGUID);
    }

    // It seems to be important to create the error rowset in the COM
    // object outside of the transaction context.  If it is created in the
    // writer then it picks up a transaction context that is aborted in the
    // case of a failure.  For some reason we only see this wierd behavior
    // in PCImportExport.
    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));
    
 		SubWriter->AddAccountToGroupSubBatch2(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection*>(pCol),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress),pDateModified,
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));
    ROWSETLib::IMTRowSetPtr tempRs = errorRs; // QI
		*ppRowset = reinterpret_cast<IMTRowSet*>(tempRs.Detach());
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:   Save  	
// Arguments:  none   
//                
// Return Value:  
// Errors Raised: 
// Description:   Saves the current subscription.  If the ID does not exist,
// assume the subscription does not exist yet in persitent storage.
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::Save(VARIANT_BOOL* pDateModified)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long groupID = 0;

  try {
		ValidateProperties();

		// step 1: create instance of subscription writer executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));


		get_GroupID(&groupID);
		if(groupID != 0) {
      // check for the capability to update the group subscription
			deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_UPDATE_DENIED;
      CHECKCAP(UPDATE_GROUPSUB_CAP);
  
			*pDateModified = SubWriter->UpdateGroupSub(GetSessionContextPtr(),reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this));
		}
		else {
      // check for the capability to create a new group subscription.  We also do this check
      // when the user attempts to create a group subscription.
			deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_CREATE_DENIED;
      CHECKCAP(CREATE_GROUPSUB_CAP);
      
      *pDateModified = SubWriter->SaveNewGroupSub(GetSessionContextPtr(),reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this));
		}
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
											groupID);

		return LogAndReturnComError(PCCache::GetLogger(), err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::ModifyMembership(IMTGSubMember *pSubMember,
                                                    VARIANT_BOOL* pDateModified)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UPDATE_DENIED;
    CheckUpdateGroupSubMembership();

    // validate that all of the required properties are present
    MTPRODUCTCATALOGLib::IMTGSubMemberPtr(pSubMember)->Validate();

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		*pDateModified = SubWriter->ModifyMembership(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGSubMember *>(pSubMember));
	}
	catch(_com_error& error) {
    AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::ModifyMembershipBatch(IMTCollection *pCol,
																												 IMTProgress* pProgress,
                                                         VARIANT_BOOL* pDateModified,
																												 IMTRowSet **ppRowset)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UPDATE_DENIED;
    CheckUpdateGroupSubMembership();

    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		ROWSETLib::IMTRowSetPtr rs = SubWriter->ModifyMembershipBatch(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection *>(pCol),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress),pDateModified);
		*ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::DeleteMember(long aAccountID, VARIANT subStartDate)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE_DENIED;
    CheckUpdateGroupSubMembership();

    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		SubWriter->DeleteMember(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			aAccountID,
      subStartDate);
	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											aAccountID);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::DeleteMemberBatch(IMTCollection *pCol, 
																										 IMTProgress* pProgress,
																										 IMTRowSet **ppRowset)
{
	try {
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		ROWSETLib::IMTRowSetPtr rs = SubWriter->DeleteMemberBatch(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection *>(pCol),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress));
		*ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::FindMember(long aAccountID,DATE RefDate,IMTGSubMember** ppMember)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr thisPtr = this;

		*ppMember = (IMTGSubMember *)subReader->FindMember(GetSessionContextPtr(),
			aAccountID,thisPtr->GetGroupID(),RefDate).Detach();
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

void CMTGroupSubscription::CheckAddToGroupSub()
{
   CHECKCAP(ADD_GSUBMEMBER_CAP);
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

void CMTGroupSubscription::CheckUpdateGroupSubMembership()
{
   CHECKCAP(MODIFY_GSUBMEMBER_CAP);
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::GetChargeAccount(long aPrcItemInstanceID, DATE aEffDate, long *apAccountID)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
// 		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE_DENIED;
//     CheckUpdateGroupSubMembership();
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr thisPtr = this;

		*apAccountID = subReader->GetChargeAccount(GetSessionContextPtr(),
																							 thisPtr->GetGroupID(),
																							 aPrcItemInstanceID,
																							 aEffDate);

	}
	catch(_com_error& error) {
// 		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
// 											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
// 											aAccountID);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::SetChargeAccount(long aPrcItemInstanceID, long aAccountID, DATE aStartDate, DATE aEndDate)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long groupID=0;
	try {
		get_GroupID(&groupID);
		if(groupID != 0)
		{
			// check for the capability to update the group subscription
			deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_UPDATE_DENIED;
			CHECKCAP(UPDATE_GROUPSUB_CAP);
			MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
			subWriter->SetChargeAccount(GetSessionContextPtr(),
																	reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
																	aPrcItemInstanceID,
																	aAccountID,
																	aStartDate,
																	aEndDate);

		}
		else
		{
			// Just store the values in memory and write them out later.
			if(mRecurringChargeAccount.find(aPrcItemInstanceID) == mRecurringChargeAccount.end())
			{
				mRecurringChargeAccount[aPrcItemInstanceID] = new TemporalProperty();
			}
			mRecurringChargeAccount[aPrcItemInstanceID]->Upsert(_variant_t(aAccountID, VT_I4), aStartDate, aEndDate);
		}
	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
											groupID);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::GetRecurringChargeAccounts(DATE aEffDate, IMTSQLRowset* *apAccounts)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTGroupSubscriptionPtr thisPtr = this;

		if(thisPtr->GetGroupID() != 0)
		{
			*apAccounts = reinterpret_cast<IMTSQLRowset*>(subReader->GetRecurringChargeAccountsAsRowset(GetSessionContextPtr(),
																																																	thisPtr->GetGroupID(),
																																																	aEffDate).Detach());
		}
		else
		{
			*apAccounts = reinterpret_cast<IMTSQLRowset*>(subReader->GetPerSubscriptionChargesAsRowset(GetSessionContextPtr(),
																																																 thisPtr->ProductOfferingID).Detach());
		}
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::GetRecurringChargeAccountsFromMemory(IMTRowSet* *apAccounts)
{
	try {
		// Create an in-memory rowset from the values we have in memory.
		ROWSETLib::IMTInMemRowsetPtr rowset(MTPROGID_INMEMROWSET);
		rowset->Init();
		rowset->AddColumnDefinition(L"id_prop", DB_INTEGER_TYPE);
		rowset->AddColumnDefinition(L"id_group", DB_INTEGER_TYPE);
		rowset->AddColumnDefinition(L"id_acc", DB_INTEGER_TYPE);
		rowset->AddColumnDefinition(L"vt_start", DB_DATE_TYPE);
		rowset->AddColumnDefinition(L"vt_end", DB_DATE_TYPE);

		for(std::map<long, TemporalProperty*>::iterator it1 = mRecurringChargeAccount.begin(); it1 != mRecurringChargeAccount.end(); it1++)
		{
			for(std::list<TemporalProperty::Slice>::iterator it2 = it1->second->begin(); it2 != it1->second->end(); it2++)
			{
				rowset->AddRow();
				rowset->AddColumnData(L"id_prop", it1->first);
				rowset->AddColumnData(L"id_group", -1L);
				rowset->AddColumnData(L"id_acc", it2->value);
				rowset->AddColumnData(L"vt_start", _variant_t(it2->begin, VT_DATE));
				rowset->AddColumnData(L"vt_end", _variant_t(it2->end, VT_DATE));
			}
		}

		*apAccounts = reinterpret_cast<IMTRowSet*>(rowset.Detach());
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::SetRecurringChargeAccounts(long aAccountID, DATE aStartDate, DATE aEndDate)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long groupID=0;
	try {
		get_GroupID(&groupID);
		// check for the capability to update the group subscription
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_UPDATE_DENIED;
		CHECKCAP(UPDATE_GROUPSUB_CAP);

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));

		subWriter->SetRecurringChargeAccounts(GetSessionContextPtr(),
																					reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
																					aAccountID,
																					aStartDate,
																					aEndDate);


	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
											groupID);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::UnsubscribeMemberBatch(IMTCollection *pCol, 
                                                          IMTProgress* pProgress,
                                                          IMTRowSet **ppRowset)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UNSUBSCRIBE_DENIED;
    CheckUpdateGroupSubMembership();

    static DATE second=1.0/(24.0*60.0*60.0);
    MTPRODUCTCATALOGLib::IMTCollectionPtr col(pCol);
    long size = col->GetCount();
    for(long i = 1; i<=size; i++)
    {
      MTPRODUCTCATALOGLib::IMTGSubMemberPtr member = col->GetItem(i);
      member->StartDate = member->EndDate + second;
      member->EndDate = GetMaxMTOLETime();
    }

    // It seems to be important to create the error rowset in the COM
    // object outside of the transaction context.  If it is created in the
    // writer then it picks up a transaction context that is aborted in the
    // case of a failure.  For some reason we only see this wierd behavior
    // in PCImportExport.
    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));
    
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
 		SubWriter->UnsubscribeMemberBatch(GetSessionContextPtr(),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(this),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection*>(pCol),
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress),
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));
    ROWSETLib::IMTRowSetPtr tempRs = errorRs; // QI
		*ppRowset = reinterpret_cast<IMTRowSet*>(tempRs.Detach());
	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubscription::UnsubscribeMember(IMTGSubMember* pSubMember)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
    // Add the member to a  singleton collection and call the batch method.
    deniedEvent = AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UNSUBSCRIBE_DENIED;
    MTObjectCollection<IMTGSubMember> col;
    col.Add(pSubMember);

    MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr This(this);
		ROWSETLib::IMTRowSetPtr rs = This->UnsubscribeMemberBatch(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCollection *>(*(&col)), NULL);

    // There should either be 0 or 1 row in the rowset.
    // If there are 0, then we have success otherwise we have a failure.
    // Throw if there is an error.
    if(rs->GetRecordCount() > 0)
    {
      //bug fix for 13329 , the error rowset has 3 columns (id_acc, accountname and description,description seems useful)
      throw _com_error(rs->GetValue(L"description"));
    }
	}
	catch(_com_error& error) {
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}
	return S_OK;
}

STDMETHODIMP CMTGroupSubscription::WarnOnEBCRMemberStartDateChange(/*[in]*/ IMTGSubMember* pSubMember,
																																	 /*[out, retval]*/ VARIANT_BOOL *pVal)
{
  try
  {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);
    MTPRODUCTCATALOGLib::IMTGSubMemberPtr member(pSubMember);
		
		*pVal = subReader->WarnOnEBCRMemberStartDateChange(base->GetID(), member->GetAccountID()); 
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

