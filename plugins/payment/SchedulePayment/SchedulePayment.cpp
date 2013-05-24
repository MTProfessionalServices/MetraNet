/**************************************************************************
 * @doc SchedulePayment
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
 * documentation shall at all times remain with MetraTech Co:poration,
 * and USER agrees to preserve the same.
 *
 * Created by: Roman Krichevsky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <ConfigDir.h>
#include <MTDate.h>

#include <string>

using namespace std;


CLSID CLSID_SchedulePayment = { /* 2976db10-b517-11d4-91d5-00b0d02b5777 */
    0x2976db10,
    0xb517,
    0x11d4,
    {0x91, 0xd5, 0x00, 0xb0, 0xd0, 0x2b, 0x57, 0x77}
};

const wchar_t RELATIVE_PATH_TO_QUERIES[] = L"\\paymentsvr\\config\\PaymentServer";

// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
using namespace ROWSETLib;


class ATL_NO_VTABLE SchedulePayment : 
	public MTPipelinePlugIn<SchedulePayment, &CLSID_SchedulePayment>
{
protected:
   
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
									MTPipelineLib::IMTConfigPropSetPtr aPropSet,
									MTPipelineLib::IMTNameIDPtr aNameID,
									MTPipelineLib::IMTSystemContextPtr aSysContext);
   virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
   virtual HRESULT PlugInShutdown();
   virtual HRESULT InitRowset();

private: 
	
	MTPipelineLib::IMTLogPtr mLogger;			// logger object
	IMTSQLRowsetPtr mpRowset;
	_bstr_t mExtensionsDir;

	long mDelay;
	long mBillEarly;
	long mScheduledPayment;
	long mAccountID;

};

PLUGIN_INFO(CLSID_SchedulePayment, SchedulePayment, 
			"MetraPipeline.SchedulePayment.1", "MetraPipeline.SchedulePayment", "Free")


/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT SchedulePayment::PlugInConfigure
(
	MTPipelineLib::IMTLogPtr aLogger,
	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
	MTPipelineLib::IMTNameIDPtr aNameID,
	MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	HRESULT hr = S_OK;

	string aExtDir;
	GetExtensionsDir(aExtDir);

	mExtensionsDir = aExtDir.c_str();

	try
	{
		mLogger = aLogger;
	
		DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("_AccountID",&mAccountID)
		DECLARE_PROPNAME("scheduledpayment", &mScheduledPayment)
		DECLARE_PROPNAME("delay", &mDelay)
		DECLARE_PROPNAME("billearly", &mBillEarly)
		END_PROPNAME_MAP

		hr = ProcessProperties(inputs, aPropSet, aNameID, mLogger,/*PROCEDURE*/NULL);
		if (FAILED(hr))
			return hr;

	}
	catch (_com_error & err)
	{
		hr = ReturnComError(err);
	}


	return InitRowset();
}


HRESULT SchedulePayment::InitRowset()
{
	HRESULT hr(S_OK);
	char buf[255];

	hr = mpRowset.CreateInstance(MTPROGID_SQLROWSET);
	
	if(FAILED(hr))
	{
		 mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
							"Failed to create Rowset object");
		return hr;
	}

	try
	{
		mpRowset->Init(mExtensionsDir + RELATIVE_PATH_TO_QUERIES);
	}
	catch(_com_error& e)
	{
		sprintf(buf, "Failed to initialize Rowset object <%s>", (const char*)e.Description());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
		return ReturnComError(e);
	}
	return hr;
}




/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT SchedulePayment::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr = S_OK;

	try
	{
		MTDate paymentDate(MTDate::TODAY);
		
		long lDelay  = aSession->GetLongProperty(mDelay);
		if (lDelay > 0)
			paymentDate.AddDay(lDelay);
		
		_bstr_t bstrBillEarly = aSession->GetStringProperty(mBillEarly);
		bool bBillEarly  = (bstrBillEarly == _bstr_t("1")) ? true : false;
		
		if (bBillEarly)
		{
			int day = paymentDate.GetWeekday();
			
			if (day == MTDate::SATURDAY)
				paymentDate.SubtractDay(1);
			else if (day == MTDate::SUNDAY)
				paymentDate.SubtractDay(2);
		}

		DATE paymentOLEDate;
		paymentDate.GetOLEDate(&paymentOLEDate);
		
		aSession->SetOLEDateProperty(mScheduledPayment, paymentOLEDate); 
  
		long acc_id = aSession->GetLongProperty(mAccountID);	
		
		mpRowset->Clear();
		mpRowset->SetQueryTag(L"__UPDATE_SCHEDULED_PAYMENT_STATUS_WITH_ARCHIVE__");
		mpRowset->AddParam(MTPARAM_ACCOUNTID, _variant_t(acc_id));
		mpRowset->Execute();		
	}
	catch (_com_error & err)
	{
		hr = ReturnComError(err);
	}

	return hr;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT SchedulePayment::PlugInShutdown()
{
	return S_OK;
}

