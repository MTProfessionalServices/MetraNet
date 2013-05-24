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
#include "MTGroupSubSlice.h"
#include "AccHierarchiesShared.h"
#include <mtprogids.h>
#include <mtcomerr.h>
#include <optionalvariant.h>
#include <formatdbvalue.h>
#include <MTObjectCollection.h>



/////////////////////////////////////////////////////////////////////////////
// CMTGroupSubSlice

STDMETHODIMP CMTGroupSubSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTGroupSubSlice,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:  get_GroupMembers   	
// Arguments:  output collection
//                
// Description: 
// ----------------------------------------------------------------



STDMETHODIMP CMTGroupSubSlice::get_GroupMembers(IMTCollection **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	try {
		if(PopulateCollection()) {
			*pVal = reinterpret_cast<IMTCollection*>(mCollection.GetInterfacePtr()); // get the interface ptr
			(*pVal)->AddRef(); // addref for output parameter
		}
		else {
			// XXX fix error code
			return Error("Unable to populate group subscription membership collection");
		}
	}
	catch(_com_error& err) {
		PCCache::GetLogger().LogThis(LOG_ERROR,"Error attempting to populate or get the subscription membership collection");
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

	return S_OK;
}


bool CMTGroupSubSlice::PopulateCollection()
{
	if(mRowset->GetRecordCount() == 0) {
		return false;
	}

	if(mCollection == NULL) {
		MTObjectCollection<IMTGSubMember> coll;
		int index;

		// XXX probably should have a lock here!

		// step : reinitialize the rowset.  Note: the rowset
		// could be a shared resource so we might be potentially
		// conflicting with another user of the rowset.
		mRowset->MoveFirst();
		
		// step : interate through the rowset
		for(index = 0;index < mRowset->GetRecordCount();index++) {

			// step : create the new member

			MTPRODUCTCATALOGLib::IMTGSubMemberPtr aMember(__uuidof(MTPRODUCTCATALOGLib::MTGSubMember));
			aMember->PutAccountID(mRowset->GetValue("id_acc"));
			aMember->PutStartDate(mRowset->GetValue("vt_start"));
			aMember->PutEndDate(mRowset->GetValue("vt_end"));
			aMember->PutAccountName(_bstr_t(mRowset->GetValue("acc_name")));

			coll.Add(reinterpret_cast<IMTGSubMember*>(aMember.GetInterfacePtr()));

			mRowset->MoveNext();
		}

		// step : reset the rowset
		mRowset->MoveFirst();
		coll.CopyTo((IMTCollection**)&mCollection);
	}
	return true;
}

// ----------------------------------------------------------------
// Name:  Initialize   	
// Arguments:  nothing
//                
// Return Value:  S_OK,E_FAIL
// Description: In
// Errors Raised: 
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubSlice::Initialize(DATE RefDate, long GroupSubID,VARIANT SystemDate)
{
	try {
		_variant_t vtRefDate(RefDate,VT_DATE);
		_variant_t vtSystemDate;
	
		mRowset.CreateInstance(MTPROGID_SQLROWSET);
		mRowset->Init(ACC_HIERARCHIES_QUERIES);


		if(OptionalVariantConversion(SystemDate,VT_DATE,vtSystemDate)) {
			// looks like they want bitemporal data.  we don't have it yet
			return Error("Bitemporal support not implemented yet");
		}
		else {
			mRowset->SetQueryTag("__FIND_GSUB_MEMBERS_AT_DATE__");
			mRowset->AddParam("%%ID_GROUP%%",GroupSubID);

			wstring aValue;
			FormatValueForDB(vtRefDate,FALSE,aValue);

			mRowset->AddParam("%%REFDATE%%",aValue.c_str(),VARIANT_TRUE);
			mRowset->Execute();
		}
	}
	catch(_com_error& err) {
		/// XXX better logging?
		PCCache::GetLogger().LogThis(LOG_ERROR,"Failed to get group subscription slice data");
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  get_GroupMembersAsRowset   	
// Arguments:  nothing
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: error if product offering does not exist
// Description:   returns the full product offering definition based
// on what is stored in the subscription
// ----------------------------------------------------------------

STDMETHODIMP CMTGroupSubSlice::get_GroupMembersAsRowset(IMTSQLRowset **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	if(mRowset == NULL) {
		return Error("No data found.  Did you call Initialize?");
	}
	else {
		*pVal = reinterpret_cast<IMTSQLRowset*>(mRowset.GetInterfacePtr());
		(*pVal)->AddRef();
	}
	return S_OK;
}




STDMETHODIMP CMTGroupSubSlice::InitializeAllMembers(long GroupSubID)
{
	try {
		mRowset.CreateInstance(MTPROGID_SQLROWSET);
		mRowset->Init(ACC_HIERARCHIES_QUERIES);
		mRowset->SetQueryTag("__FIND_GSUB_MEMBERS_NO_DATE_");
		mRowset->AddParam("%%ID_GROUP%%",GroupSubID);
		mRowset->Execute();

	}
	catch(_com_error& err) {
		PCCache::GetLogger().LogThis(LOG_ERROR,"Failed to find members of group subscription");
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}
