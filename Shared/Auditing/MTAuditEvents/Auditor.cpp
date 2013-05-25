// Auditor.cpp : Implementation of CAuditor
#include "StdAfx.h"
#include "MTAuditEvents.h"
#include "Auditor.h"

#import "MTAuditEvents.tlb"

/////////////////////////////////////////////////////////////////////////////
// CAuditor

HRESULT CAuditor::FinalConstruct()
{

	GetMTConfigDir(mConfigFile);
	mConfigFile += string("Audit\\AuditConfig.xml");
	HRESULT hr = mConfig.CreateInstance(MTPROGID_CONFIG);

	if(FAILED(hr))
		return hr;

  hr=Load();

 	if(FAILED(hr))
		return hr;

	mObserver.Init();
	mObserver.AddObserver(*this);
	
	if (!mObserver.StartThread())
	{
		return Error("Could not start config change thread");
	}

  return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
}

STDMETHODIMP CAuditor::FireEventLocal(long EventId, long UserId, long EntityTypeId, long EntityId, BSTR Details, BSTR LoggedInAs, BSTR ApplicationName, VARIANT_BOOL Success)
{
	try
	{
		if (mAuditingEnabled)
		{
			MTAUDITEVENTSLib::IAuditEventPtr pAuditEvent(__uuidof(AuditEvent));
			MTAUDITEVENTSLib::IAuditEventHandlerPtr pAuditEventHandler(__uuidof(AuditEventHandler));

			pAuditEvent->PutEventId(EventId);
			pAuditEvent->PutUserId(UserId);
			pAuditEvent->PutEntityTypeId(EntityTypeId);
			pAuditEvent->PutEntityId(EntityId);
			pAuditEvent->PutDetails(Details);
			pAuditEvent->PutSuccess(Success);

			if (LoggedInAs != NULL)
			{
					pAuditEvent->PutLoggedInAs(LoggedInAs);
			}

			if (ApplicationName != NULL)
			{
				pAuditEvent->PutApplicationName(ApplicationName);
			}

			pAuditEventHandler->HandleEvent(pAuditEvent);

			return S_OK;
		}
        else
        {
			return S_OK;
        }

	}
	catch (_com_error & err)
	{ 
		return ReturnComError(err); 
	}
}

STDMETHODIMP CAuditor::FireEvent(long EventId, long UserId, long EntityTypeId, long EntityId, BSTR Details)
{
	return FireEventWithAdditionalData(EventId, UserId, EntityTypeId, EntityId, Details, NULL, NULL);
}

STDMETHODIMP CAuditor::FireEventWithAdditionalData(long EventId, long UserId, long EntityTypeId, long EntityId, BSTR Details, BSTR LoggedInAs, BSTR ApplicationName)
{
	FireEventLocal(EventId, UserId, EntityTypeId, EntityId, Details, LoggedInAs, ApplicationName, VARIANT_TRUE);

	return S_OK;
}

STDMETHODIMP CAuditor::FireFailureEvent(long EventId, long UserId, long EntityTypeId, long EntityId, BSTR Details)
{
	return FireFailureEventWithAdditionalData(EventId, UserId, EntityTypeId, EntityId, Details, NULL, NULL);
}

STDMETHODIMP CAuditor::FireFailureEventWithAdditionalData(long EventId, long UserId, long EntityTypeId, long EntityId, BSTR Details, BSTR LoggedInAs, BSTR ApplicationName)
	{
	FireEventLocal(EventId, UserId, EntityTypeId, EntityId, Details, LoggedInAs, ApplicationName, VARIANT_FALSE);

	return S_OK;
}

STDMETHODIMP CAuditor::dummy(/*[in]*/ MTAuditEvent event,  MTAuditEntityType entity)
{
	// this method is here only to force a dependency on MTAuditEvent.  Otherwise
	// the enum is ignored when using #import on the tlb
	return E_NOTIMPL;
}

HRESULT CAuditor::Load()
{

	MTConfigLib::IMTConfigPropSetPtr confSet;
	VARIANT_BOOL bChecksum;

	try
	{
		AutoCriticalSection alock(&mLock);
		confSet = mConfig->ReadConfiguration(mConfigFile.c_str(),&bChecksum);

		// Get config value for Auditing Enabled
		mAuditingEnabled = confSet->NextBoolWithName("AuditingEnabled");
		return S_OK;
	}
	catch(_com_error& e)
	{
		return e.Error();
	}
}

//Got refresh event, reinitialize
void CAuditor::ConfigurationHasChanged()
{
  Load();
  return;
}
