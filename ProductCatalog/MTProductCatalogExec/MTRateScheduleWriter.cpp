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

// MTRateScheduleWriter.cpp : Implementation of CMTRateScheduleWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTRateScheduleWriter.h"

#include <mtautocontext.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <formatdbvalue.h>

using MTPRODUCTCATALOGLib::IMTPriceListPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTRateScheduleWriter

/******************************************* error interface ***/
STDMETHODIMP CMTRateScheduleWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRateScheduleWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRateScheduleWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRateScheduleWriter::CanBePooled()
{
	return FALSE;
} 

void CMTRateScheduleWriter::Deactivate()
{
	mpObjectContext.Release();
} 

void CMTRateScheduleWriter::CheckExisting(IMTRateSchedule *apSchedule,long ExistingID)
{
	IMTRateSchedulePtr schedule(apSchedule);
	IMTPCTimeSpanPtr newTimeSpan = schedule->GetEffectiveDate();

	// normalize the effective date before running the check!
	newTimeSpan->Normalize();

	long paramTableID = schedule->GetParameterTableID();
	long pricelistID = schedule->GetPriceListID();
	long prcItemTemplateID = schedule->GetTemplateID();

	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);

	rowset->SetQueryTag("__DETECT_DUPLICATE_RSCHED__");
	rowset->AddParam("%%BEGINTYPE%%",(long)newTimeSpan->GetStartDateType());
	if(newTimeSpan->IsStartDateNull() == VARIANT_TRUE) {
		rowset->AddParam("%%DATE_OPBEGIN%%","is");
		rowset->AddParam("%%DTSTART%%","NULL",VARIANT_FALSE);
	}
	else {
		rowset->AddParam("%%DATE_OPBEGIN%%","=");
		std::wstring aTemp;
		_variant_t startDate(newTimeSpan->GetStartDate(),VT_DATE);
		FormatValueForDB(startDate,FALSE,aTemp);
		rowset->AddParam("%%DTSTART%%",aTemp.c_str(),VARIANT_TRUE);
	}
	rowset->AddParam("%%BEGINOFFSET%%",newTimeSpan->GetStartOffset());
	rowset->AddParam("%%ENDTYPE%%",(long)newTimeSpan->GetEndDateType());
	if(newTimeSpan->IsEndDateNull() == VARIANT_TRUE) {
		rowset->AddParam("%%DATE_OPEND%%","is");
		rowset->AddParam("%%DTEND%%","NULL",VARIANT_FALSE);
	}	
	else {
		rowset->AddParam("%%DATE_OPEND%%","=");
		std::wstring aTemp;
		_variant_t endDate(newTimeSpan->GetEndDate(),VT_DATE);
		FormatValueForDB(endDate,FALSE,aTemp);
		rowset->AddParam("%%DTEND%%",aTemp.c_str(),VARIANT_TRUE);
	}
	rowset->AddParam("%%ENDOFFSET%%",newTimeSpan->GetEndOffset());
	rowset->AddParam("%%PARAMTABLE%%",paramTableID);
	rowset->AddParam("%%PRICELIST%%",pricelistID);
	rowset->AddParam("%%PITEMPLATE%%",prcItemTemplateID);
	// if this is an update, make sure we don't count the existing rate schedule when we do the comparision
	rowset->AddParam("%%ID_EXISTING_SCHED%%",ExistingID);
	rowset->Execute();
	if(rowset->GetRecordCount() > 0) {
		// duplicate rate schedule detected
		MT_THROW_COM_ERROR(MTPCUSER_DUPLICATE_RATE_SCHEDULE);
	}
}

void CMTRateScheduleWriter::CheckGroupSubscriptionRules(IMTRateSchedulePtr schedule)
{
}

STDMETHODIMP CMTRateScheduleWriter::Create(IMTSessionContext* apCtxt, 
																					 IMTRateSchedule *apSchedule,
																						VARIANT_BOOL aSaveRules,
																						long *id)
{
	MTAutoContext context(mpObjectContext);
	try
	{
		// we don't have an existing rate schedule ID so pass in -1
		CheckExisting(apSchedule,-1);

		IMTRateSchedulePtr schedule(apSchedule);

		long paramTableID = schedule->GetParameterTableID();
		long pricelistID = schedule->GetPriceListID();
		long prcItemTemplateID = schedule->GetTemplateID();

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

    CheckGroupSubscriptionRules(schedule);

		//create timespan
		MTPRODUCTCATALOGEXECLib::IMTPCTimeSpanWriterPtr
			timeSpanWriter(__uuidof(MTPCTimeSpanWriter));
		long effectiveDateID =
			timeSpanWriter->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
														(MTPRODUCTCATALOGEXECLib::IMTPCTimeSpan *)
														 schedule->GetEffectiveDate().GetInterfacePtr());

		schedule->GetEffectiveDate()->PutID(effectiveDateID);

		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long rschedId = baseWriter->Create( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
																				(long)PCENTITY_TYPE_RATE_SCHEDULE,
																				"",
																				schedule->GetDescription());
	

		rowset->SetQueryTag("__ADD_RSCHED__");
		rowset->AddParam("%%ID_SCHED%%", rschedId);
		rowset->AddParam("%%ID_PT%%", paramTableID);
		rowset->AddParam("%%ID_EFFDATE%%", effectiveDateID);
		rowset->AddParam("%%ID_PL%%", pricelistID);
		rowset->AddParam("%%ID_TMPL%%", prcItemTemplateID);


		rowset->Execute();

		if (aSaveRules == VARIANT_TRUE)
		{	
			MTPRODUCTCATALOGEXECLib::IMTRuleSetWriterPtr
				rulesetWriter(__uuidof(MTRuleSetWriter));

			IMTParamTableDefinitionPtr def = schedule->GetParameterTable();
			if (def == NULL)
				// TODO:
				return Error("Parameter table not set");


			rulesetWriter->CreateWithID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
																	rschedId,
																	(MTPRODUCTCATALOGEXECLib::IMTParamTableDefinition *)
																	def.GetInterfacePtr(),
																	(MTPRODUCTCATALOGEXECLib::IMTRuleSet *)
																	schedule->GetRuleSet().GetInterfacePtr());
		}

    //audit
    MTPRODUCTCATALOGLib::MTPriceListMappingType mapType = schedule->GetScheduleType();
    AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
    switch(mapType)
    { 
      case MTPRODUCTCATALOGLib::MAPPING_NORMAL:
        event = AuditEventsLib::AUDITEVENT_RS_CREATE;
        break;
      case MTPRODUCTCATALOGLib::MAPPING_ICB_SUBSCRIPTION:
        event = AuditEventsLib::AUDITEVENT_ICB_CREATE;
        break;
      case MTPRODUCTCATALOGLib::MAPPING_ICB_GROUP_SUBSCRIPTION:
        event = AuditEventsLib::AUDITEVENT_GROUP_ICB_CREATE;
        break;
      default:
        ASSERT(0);
        break;
    }

    char buffer[1024];
    sprintf(buffer,"Price List: %s, Price List Id: %d, ParamTable: %s, Rate Schedule Id: %d", (char *) schedule->GetPriceList()->GetName(), pricelistID, (char *) schedule->GetParameterTable()->GetName(),rschedId);
    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
    PCCache::GetAuditor()->FireEvent(event,pContext->AccountID,AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,rschedId,buffer);

		*id = rschedId;

  }
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRateScheduleWriter::Update(IMTSessionContext* apCtxt, 
																					 IMTRateSchedule *apSchedule,
																						VARIANT_BOOL aSaveRateSchedule,
																						VARIANT_BOOL aSaveRules)
{
	MTAutoContext context(mpObjectContext);
	try
	{
		// check if the changed rate shedule conflicts with an existing rate schedule

		IMTRateSchedulePtr schedule(apSchedule);
		long rschedID = schedule->GetID();
		CheckExisting(apSchedule,rschedID);

    CheckGroupSubscriptionRules(schedule);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		if (aSaveRateSchedule == VARIANT_TRUE)
		{
			//
			// update timespan
			//
			MTPRODUCTCATALOGEXECLib::IMTPCTimeSpanWriterPtr
				timeSpanWriter(__uuidof(MTPCTimeSpanWriter));

			timeSpanWriter->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
														(MTPRODUCTCATALOGEXECLib::IMTPCTimeSpan *)
														 schedule->GetEffectiveDate().GetInterfacePtr());

			//
			// update base props
			//
			MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
			baseWriter->Update(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
												 L"", schedule->GetDescription(), rschedID);

			//
			// update rate schedule
			//
			long paramTableID = schedule->GetParameterTableID();

			long pricelistID = schedule->GetPriceListID();

			long effectiveDateID = schedule->GetEffectiveDate()->GetID();

			long prcItemTemplateID = schedule->GetTemplateID();

			rowset->SetQueryTag("__UPDATE_RSCHED__");
			rowset->AddParam("%%ID_SCHED%%", rschedID);
			rowset->AddParam("%%ID_PT%%", paramTableID);
			rowset->AddParam("%%ID_EFFDATE%%", effectiveDateID);
			rowset->AddParam("%%ID_PL%%", pricelistID);
			rowset->AddParam("%%ID_TMPL%%", prcItemTemplateID);

			rowset->Execute();

      //audit
      MTPRODUCTCATALOGLib::MTPriceListMappingType mapType = schedule->GetScheduleType();
      AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
      switch(mapType)
      { 
        case MTPRODUCTCATALOGLib::MAPPING_NORMAL:
          event = AuditEventsLib::AUDITEVENT_RS_UPDATE;
          break;
        case MTPRODUCTCATALOGLib::MAPPING_ICB_SUBSCRIPTION:
          event = AuditEventsLib::AUDITEVENT_ICB_UPDATE;
          break;
        case MTPRODUCTCATALOGLib::MAPPING_ICB_GROUP_SUBSCRIPTION:
          event = AuditEventsLib::AUDITEVENT_GROUP_ICB_UPDATE;
          break;
        default:
          ASSERT(0);
          break;
      }
      char buffer[1024];
      sprintf(buffer,"Price List Id: %d, ParamTable: %s, Rate Schedule Id: %d", pricelistID, (char *) schedule->GetParameterTable()->GetName(),rschedID);
      MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      PCCache::GetAuditor()->FireEvent(event,pContext->AccountID,AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,rschedID,buffer);
		}

		if (aSaveRules == VARIANT_TRUE) 
		{
      //
      // update rules
      //
      MTPRODUCTCATALOGEXECLib::IMTRuleSetWriterPtr
	      rulesetWriter(__uuidof(MTRuleSetWriter));

      IMTParamTableDefinitionPtr def = schedule->GetParameterTable();
      if (def == NULL)
	      // TODO:
	      return Error("Parameter table not set");


      rulesetWriter->UpdateWithID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
														      rschedID,
														      (MTPRODUCTCATALOGEXECLib::IMTParamTableDefinition *)
														      def.GetInterfacePtr(),
														      (MTPRODUCTCATALOGEXECLib::IMTRuleSet *)
														      schedule->GetRuleSet().GetInterfacePtr());

      // Auditing
      /*long pricelistID = schedule->GetPriceListID();
      char buffer[512];
      sprintf(buffer,"ParamTable: %s, Rate Schedule Id: %d", (char *) schedule->GetParameterTable()->GetName(),rschedID);
      MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_RS_RULE_UPDATE,pContext->AccountID,AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,rschedID,buffer);
      */
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTRateScheduleWriter::Remove(IMTSessionContext* apCtxt, long aRateScheduleID)
{
	// Todo: check for existence before deleting?
	MTAutoContext context(mpObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		// Attempt to delete rate schedule - the stored proc will figure out the rate table to
		// delete rules from
		rowset->InitializeForStoredProc("sp_DeleteRateSchedule");
		rowset->AddInputParameterToStoredProc("a_rsID", MTTYPE_INTEGER, INPUT_PARAM, aRateScheduleID);
		rowset->ExecuteStoredProc();
    
    AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
    event = AuditEventsLib::AUDITEVENT_RS_DELETE;
    char buffer[512];
    sprintf(buffer,"Rate Schedule Id: %d", aRateScheduleID);
    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);

		/* TODO: Fix 4th argument, used to be a pricelist id, does it make sense here?  */
    PCCache::GetAuditor()->FireEvent(event,pContext->AccountID,AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,-1,buffer);
	}
	catch (_com_error & err)
	{ 
		return ReturnComError(err); 
	}

	context.Complete();
	return S_OK;
}

