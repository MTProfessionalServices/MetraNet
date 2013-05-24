/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* 
***************************************************************************/

#include <StdAfx.h>
#include <PST.h>

#define	ACCOUNT_ID_COLUMN											L"id_acc"
#define	CURRENCY_COLUMN												L"am_currency"
#define	AMOUNT_COLUMN													L"amount"
#define	SESSION_ID_COLUMN											L"id_sess"
#define	ORIGINAL_ACCOUNT_ID_COLUMN						L"c_originalaccountid"
#define PAYMENT_TYPE_COLUMN										L"c_paymenttype"
#define SCHEDULED_PAYMENT_DATE_COLUMN					L"c_scheduledpayment"
#define LAST_STATUS_UPDATE_COLUMN							L"c_laststatusupdate"
#define CURRENT_STATUS_COLUMN									L"c_currentstatus"
#define	LAST_FOUR_DIGITS_COLUMN								L"c_lastfourdigits"
#define	ROUTING_NUMBER_COLUMN									L"c_routingnumber"
#define	BANK_ACCOUNT_TYPE_COLUMN							L"c_bankaccounttype"
#define	CREDIT_CARD_TYPE_COLUMN								L"c_creditcardtype"
#define	PAYMENT_PROVIDER_STATUS_COLUMN				L"c_paymentproviderstatus"
#define	PAYMENT_PROVIDER_CODE_COLUMN					L"c_paymentprovidercode"
#define	PAYMENT_NACHA_CODE_COLUMN							L"c_nachacode"
#define MAX_RETRIES_COLUMN										L"c_maxretries"
#define RETRY_ON_FAILURE_COLUMN								L"c_retryonfailure"
#define NUM_RETRIES_COLUMN										L"c_numberretries"
#define CONFIRM_REQUESTED_COLUMN							L"c_confirmationrequested"
#define CONFIRM_RECEIVED_COLUMN								L"c_confirmationreceived"
#define EMAIL_COLUMN													L"c_email"
#define PAYMENT_SERVER_TRANSACTION_ID_COLUMN	L"c_paymentservicetransactionid"
#define	USAGE_CYCLE_TYPE_COLUMN								L"c_UsageCycleType"
#define	INTERVAL_ID_COLUMN										L"c_originalintervalid"
#define	TAX_AMOUNT_COLUMN											L"c_taxamount"
#define	DESCRIPTION_COLUMN										L"c_description"
#define AUTH_RECEIVED_FLAG_COLUMN							L"nm_authreceived"
#define PRENOTE_VALIDATED_FLAG_COLUMN					L"nm_validated"


#define GET_ALL_SCHEDULED_PAYMENTS_TAG				L"__GET_SCHEDULED_PAYMENTS__"
#define GET_SCHEDULED_PAYMENT_TAG							L"__GET_SCHEDULED_PAYMENT__"
#define UPDATE_PAYMENT_SCHEDULER_RECORD_TAG		L"__UPDATE_SCHEDULED_PAYMENT_RECORD_BY_SESSION_ID__"
#define	RELATIVE_PATH_TO_QUERIES							L"\\paymentsvr\\config\\PaymentServer"

#define ACH_DEBIT_SERVICE											L"metratech.com/ps_ach_debit"
#define ACH_CREDIT_SERVICE										L"metratech.com/ps_ach_credit"
#define CC_DEBIT_SERVICE											L"metratech.com/ps_cc_debit"
#define CC_CREDIT_SERVICE											L"metratech.com/ps_cc_credit"

#define PAYMENT_SERVER_ENUM_SPACE							L"metratech.com/PaymentServer"
#define PAYMENT_STATUS_ENUM_TYPE							L"PaymentStatus"


PaymentTransaction::PaymentTransaction() :	msPaymentProviderStatus(L""),
																						msPaymentServiceTransactionID(L""),
																						msLastFourDigits(L""),
																						msRoutingNumber(L"")
{
	// initialize the logger ...
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("PeriodicallySubmitTransactions"), LOG_TAG);
}


BOOL PaymentTransaction::Submit(PaymentTransactionResult& aPtr, MTMeter* apMeterServer)
{
	BOOL ret(FALSE);
	_bstr_t service;

	switch(mePaymentType)
	{
		case PS_ACH:
		{
			service = (mDecAmount<0) ? ACH_CREDIT_SERVICE : ACH_DEBIT_SERVICE;
			break;
		}

		case PS_CREDIT_CARD:
		{
			service = (mDecAmount<0) ? CC_CREDIT_SERVICE : CC_DEBIT_SERVICE;
			break;
		}
		default:
		{
			mLogger.LogThis(LOG_ERROR, "PaymentTransaction::Submit(): Invalid Payment Type");
			return FALSE;
		}
	}

	MTMeterSession* session = apMeterServer->CreateSession(service);
	
	//amounts always metered positive
	mDecAmount = (mDecAmount > 0) ? mDecAmount	:	-mDecAmount;
	mDecTaxAmount = (mDecTaxAmount > 0) ? mDecTaxAmount	:	-mDecTaxAmount;

	MTDecimalValue amount;
	MTDecimalValue taxamount;

	amount.SetValue(mDecAmount.Format().c_str());
	taxamount.SetValue(mDecTaxAmount.Format().c_str());
	//temp
	//TODO: Change to use SDK's decimal support
	//double amount, taxamount;
	
	//::VarR8FromDec(&mDecAmount, &amount);
	//::VarR8FromDec(&mDecTaxAmount, &taxamount);
	//amount = (amount)	? amount	: -amount;


	switch(mePaymentType)
	{
		case PS_ACH:
		{
			  if (!session->InitProperty("_AccountID", (int)mlOriginalAccountID) || 
						!session->InitProperty("routingnumber", (const char*)_bstr_t(msRoutingNumber.c_str()) )		|| 
						!session->InitProperty("lastfourdigits", (const char*)_bstr_t(msLastFourDigits.c_str()) )	|| 
						!session->InitProperty("BankAccountType",		(int)meBankAccountType)	|| 
						!session->InitProperty("_Amount", &amount) || 
						!session->InitProperty("_Currency", (const char*)_bstr_t(msCurrency.c_str()) ) || 
						!session->InitProperty("transactionid", (const char*)_bstr_t(msPaymentServiceTransactionID.c_str()) )	||
						!session->InitProperty("taxamount", &taxamount)	||
						!session->InitProperty("pssessid", (int)mlSessionID)	||
						!session->InitProperty("testsession", "0")
						)
				{
					int size = 255;
					char*	buf = new char[size];
					MTMeterError * err = session->GetLastErrorObject();
					mLogger.LogThis(LOG_ERROR, "Could not initialize the session property");
					err->GetErrorMessage(buf, size);
					delete session;
					SetError(	err->GetErrorCode(), 
										ERROR_MODULE, ERROR_LINE, 
										"PaymentTransaction::Submit", 
										buf);
					delete[] buf;
					return FALSE;
				}
			
			break;
		}

		case PS_CREDIT_CARD:
		{
			 if (	!session->InitProperty("_AccountID", (int)mlOriginalAccountID) || 
						!session->InitProperty("creditcardtype", meCreditCardType )		|| 
						!session->InitProperty("lastfourdigits", (const char*)_bstr_t(msLastFourDigits.c_str()) )	|| 
						!session->InitProperty("_Amount", &amount) || 
						!session->InitProperty("_Currency", (const char*)_bstr_t(msCurrency.c_str()) ) || 
						!session->InitProperty("taxamount", &taxamount)	||
						!session->InitProperty("pssessid", (int)mlSessionID)	||
						!session->InitProperty("testsession", "0")
					)
				{
					int size = 255;
					char*	buf = new char[size];
					MTMeterError * err = session->GetLastErrorObject();
					err->GetErrorMessage(buf, size);
					mLogger.LogVarArgs(LOG_ERROR, "Could not initialize the session property <%s>", buf);
		
					delete session;
					SetError(	err->GetErrorCode(), 
										ERROR_MODULE, ERROR_LINE, 
										"PaymentTransaction::Submit", 
										buf);
					delete[] buf;
					return FALSE;
				}
			
			break;
		}
		
	}
	// set mode to synchronous
  session->SetResultRequestFlag();
  
  // send the session to the server
  if (!session->Close())
  {
		int size = 255;
		char*	buf = new char[size];
		MTMeterError * err = session->GetLastErrorObject();
		err->GetErrorMessage(buf, size);
		mLogger.LogVarArgs(LOG_ERROR, "Could not send session to server: <%s>", buf);
		
		delete session;
		SetError(	err->GetErrorCode(), 
			ERROR_MODULE, ERROR_LINE, 
			"PaymentTransaction::Submit", 
			buf);
		delete[] buf;
    //CR 9888 fix: One session failed... so what?
    //Try and process the rest of them
    //Set status to failed and all the Verisign strings to "Not Available"
    std::wstring msg = L"Not available";
		aPtr.SetPaymentProviderStatus(msg);
	  aPtr.SetPaymentProviderCode(-1);
	  aPtr.SetPaymentServiceTransactionID(msg);
 		aPtr.SetPaymentStatus(PS_FAILED);
    return TRUE;
	}
	
	// get the results back -- this will contain the responsestring and authcode 
	MTMeterSession* results = session->GetSessionResults();
	ASSERT(results);
	int RetCode;
	wstring respstring, pstrid;
	
	const wchar_t* respbuf = respstring.c_str();
	const wchar_t* pstridbuf = pstrid.c_str();
	results->GetProperty("respstring", &respbuf);
	results->GetProperty("retcode", RetCode);
	
	aPtr.SetPaymentProviderStatus(respbuf);
	aPtr.SetPaymentProviderCode(RetCode);
	results->GetProperty("paymentservicetransactionid", &pstridbuf);
	aPtr.SetPaymentServiceTransactionID(pstridbuf);
	
	if(RetCode == CREDITCARDACCOUNT_SUCCESS)
	{
		switch(mePaymentType)
		{
			case PS_ACH:
			{
				aPtr.SetPaymentStatus(PS_SENT);
				break;
			}
			case PS_CREDIT_CARD:
			{
				aPtr.SetPaymentStatus(PS_SETTLED);
				break;
			}
		}
	}
	else
	{
		aPtr.SetPaymentProviderStatus(respstring);
		aPtr.SetPaymentStatus(PS_FAILED);
	}

	delete session;
	return TRUE;

}

BOOL PaymentTransaction::UpdateStatus(	const PaymentTransactionResult& aResult, 
																				SchedulerEvaluator& aEval	)
{
	BOOL ret(FALSE);
	return aEval.UpdateTransactionInfo(this, (PaymentTransactionResult*)&aResult);

}

BOOL SchedulerEvaluator::SetEnumConfig(const MTENUMCONFIGLib::IEnumConfig* aPtr)
{
	char buf[255];

	try
	{
		mEnumConfig = (IUnknown*)aPtr;
	}
	catch(_com_error& e)
	{
		sprintf(buf, "Failed in SchedulerEvaluator::SetEnumConfig,  <%s>", (const char*)e.Description());
		mLogger.LogThis(LOG_ERROR, buf);
		return FALSE;
	}
	return TRUE;

}

BOOL SchedulerEvaluator::Init(BSTR aExtensionDir, const MTENUMCONFIGLib::IEnumConfig* aEnum)
{
	mExtensionsDir = aExtensionDir;
	char buf[255];

	// initialize the logger ...
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("PeriodicallySubmitTransactions"), LOG_TAG);

	
	HRESULT hr = mpRowset.CreateInstance(MTPROGID_SQLROWSET);
	if(FAILED(hr))
	{
		sprintf(buf, "Failed to create MTPROGID_SQLROWSET instance, error <%x>", hr);
		mLogger.LogThis(LOG_ERROR, buf);
		return FALSE;
	}

	try
	{
		mpRowset->Init(mExtensionsDir + RELATIVE_PATH_TO_QUERIES);
	}
	catch(_com_error& e)
	{
		sprintf(buf, "Failed to initialize MTPROGID_SQLROWSET instance,  <%s>", (const char*)e.Description());
		mLogger.LogThis(LOG_ERROR, buf);
		return FALSE;
	}

	
	return SetEnumConfig(aEnum);

}
BOOL SchedulerEvaluator::UpdateTransactionInfo(PaymentTransaction* apRecord, PaymentTransactionResult* apResult)
{
	long lPaymentStatusDescValue;
	_bstr_t bstrEnumValue;
	int numRetries;
	wchar_t value[128];
	wchar_t set_clause[1024];
	PaymentServer::PaymentStatus oldStatus, newStatus;
	_bstr_t pstrid = L" ";
	
	//if PSTRID is missing on the result object, then set it equal to the one on the record object
	//this is rarely the case, only when this record was not submitted (if not validated etc.)
	if(apResult->GetPaymentServiceTransactionID().empty())
		pstrid = apRecord->GetPaymentServiceTransactionID().c_str();
	else
		pstrid = apResult->GetPaymentServiceTransactionID().c_str();

	oldStatus = apRecord->GetPaymentStatus();
	//if transaction was never submitted, then result object
	//won't have a status set, set newstatus = old status
	newStatus = apResult->GetPaymentStatus() ? apResult->GetPaymentStatus() : oldStatus;
	numRetries = apRecord->GetNumRetries();

	//increment number of retries if transaction failed again
	if((oldStatus == PS_FAILED) && (newStatus == oldStatus))
		numRetries++;

	//convert enum value into description id
	bstrEnumValue = _ltow((long)newStatus, value, 10);
	try
	{
		lPaymentStatusDescValue = mEnumConfig->GetID(PAYMENT_SERVER_ENUM_SPACE, PAYMENT_STATUS_ENUM_TYPE, bstrEnumValue);
	}
	catch(_com_error& e)
	{
		
		return ReturnComError(e);
	}

	//Construct SET_CLAUSE
	swprintf(set_clause, L"c_currentstatus = %d, c_paymentproviderstatus = '%s',c_paymentprovidercode = %d, c_numberretries = %d,c_paymentservicetransactionid='%s'",
												lPaymentStatusDescValue,
												EscapeSQLString(apResult->GetPaymentProviderStatus()).c_str(),
												apResult->GetPaymentProviderCode(),
												numRetries,
												(const wchar_t*)pstrid);
	try
	{
		mpRowset->Clear();
		mpRowset->SetQueryTag(UPDATE_PAYMENT_SCHEDULER_RECORD_TAG);
		mpRowset->AddParam(L"%%SET_CLAUSE%%", _variant_t(set_clause), VARIANT_TRUE); //don't escape the single quotes
		mpRowset->AddParam(L"%%ID_SESS%%", _variant_t(apRecord->GetSessionID()));
		mpRowset->Execute();
	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Exception caught in SchedulerEvaluator::UpdateTransactionInfo: %s",
				(const char*)e.Description());
		return FALSE;
	}
	return TRUE;
}

BOOL SchedulerEvaluator::GetTransaction(const wstring aTransactionID, PaymentTransaction& aPT)
{
	BOOL ret(FALSE);
	long	lCurrentStatus;
	long enumVal;
	PaymentServer::PaymentStatus ePaymentStatus;
	
	ASSERT(mEnumConfig != NULL);
	
	try
	{
		mpRowset->Clear();
		mpRowset->SetQueryTag(GET_SCHEDULED_PAYMENT_TAG);
		mpRowset->AddParam(MTPARAM_PS_TRANSACTION_ID, _variant_t(aTransactionID.c_str()));
		mpRowset->Execute();
		
		if (mpRowset->GetRecordCount() == 0)
		{
			mLogger.LogVarArgs(LOG_ERROR, "Payment with given id <%s> was not found", (const char*)_bstr_t(aTransactionID.c_str()));
			return FALSE;
		}

		if (mpRowset->GetRecordCount() > 1)
		{
			mLogger.LogVarArgs(LOG_ERROR, "More then one payment with given id <%s> was found", (const char*)_bstr_t(aTransactionID.c_str()));
			return FALSE;
		}
		
			
		lCurrentStatus = (long)mpRowset->GetValue(_variant_t(CURRENT_STATUS_COLUMN));
		long lSessionID = (long)mpRowset->GetValue(_variant_t(SESSION_ID_COLUMN));
			
		wstring value = mEnumConfig->GetEnumeratorValueByID(lCurrentStatus);
		_bstr_t enumerator = mEnumConfig->GetEnumeratorByID(lCurrentStatus);
		ret = ConvertToLong(value, &enumVal);
		ASSERT(ret);
		ePaymentStatus = (PaymentServer::PaymentStatus) enumVal;
			
		switch(ePaymentStatus)
		{
			//only costruct an object if status one of the three below
			case PS_PENDING:
			case PS_RETRY:
			case PS_FAILED:
			{
				aPT.SetPaymentStatus(ePaymentStatus);
				return PopulatePaymentTransaction(&aPT, mpRowset);
			}
			default:
			{
				mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> will not be processed now because payment "
						"status is <%s>", lSessionID, (const char*)enumerator);
			}
		}
	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Exception caught in SchedulerEvaluator::GetTransaction: %s",
				(const char*)e.Description());
		return FALSE;
	}
	return TRUE;
}

BOOL SchedulerEvaluator::GetTransactionList(TransactionsToSubmit& aList)
{
	BOOL ret(FALSE);
	PaymentTransaction* ptr;
	long	lCurrentStatus;
	long enumVal;
	PaymentServer::PaymentStatus ePaymentStatus;
	
	ASSERT(mEnumConfig != NULL);
	//step 1: clear passed in vector
	aList.clear();
	//step 2: initialize Rowset with the query and execute it
	try
	{
		mpRowset->Clear();
		mpRowset->SetQueryTag(GET_ALL_SCHEDULED_PAYMENTS_TAG);
		mpRowset->Execute();
		
		//step 3: Iterate through Rowset, determine which transactions need to
		//submit now and populate vector
		
		while (mpRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			//get the fields that decide whether payment should be processed now
			/*
			The criteria for determining which transactions to submit are:
			
				(status==pending && date==today && if confirm is requested then it has been received) ||
				
					(status==retry) ||
					
						(status==failed && (retryonfailure==true && not exceeded the retry threshold))
						
							
			*/
			
			lCurrentStatus = (long)mpRowset->GetValue(_variant_t(CURRENT_STATUS_COLUMN));

			long lSessionID = (long)mpRowset->GetValue(_variant_t(SESSION_ID_COLUMN));
			
			
			wstring value = mEnumConfig->GetEnumeratorValueByID(lCurrentStatus);
			_bstr_t enumerator = mEnumConfig->GetEnumeratorByID(lCurrentStatus);
			ret = ConvertToLong(value, &enumVal);
			ASSERT(ret);
			ePaymentStatus = (PaymentServer::PaymentStatus) enumVal;
			
			switch(ePaymentStatus)
			{
				//only costruct an object if status one of the four below
				case PS_PENDING:
				case PS_RETRY:
				case PS_FAILED:
				case PS_INCOMPLETE_ACCOUNT_INFO:
				{
					ptr = new PaymentTransaction;
					ptr->SetPaymentStatus(ePaymentStatus);
					if (PopulatePaymentTransaction(ptr, mpRowset))
					{
						ASSERT(ptr);
						aList.push_back(ptr);
						mLogger.LogVarArgs(LOG_INFO, 
							"Scheduled record with session id of <%d> is qualified to be processed now", ptr->GetSessionID());
					}
					//else return FALSE;
					break;
				}
				default:
				{
					mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> will not be processed now because payment "
						"status is <%s>", lSessionID, (const char*)enumerator);
				}
		
			}
			mpRowset->MoveNext();
		}
		
	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Exception caught in SchedulerEvaluator::GetTransactionList: %s",
				(const char*)e.Description());
		return FALSE;
	}
	return TRUE;
}
	
	
BOOL SchedulerEvaluator::PopulatePaymentTransaction(PaymentTransaction* aPtr, const ROWSETLib::IMTSQLRowset* aRowSet)
{
	ASSERT(aPtr);
	long enumVal;
	MTDate today(MTDate::TODAY);
	MTDecimal dv;
	_variant_t vValue;
	BOOL res;
	
	try
	{
		vValue = mpRowset->GetValue(_variant_t(SCHEDULED_PAYMENT_DATE_COLUMN));
			
		MTDate date(vValue.date);
			
		vValue = mpRowset->GetValue(_variant_t(RETRY_ON_FAILURE_COLUMN));
		aPtr->SetRetryOnFailure((const wchar_t*)MTMiscUtil::GetString(vValue));
				
		vValue = mpRowset->GetValue(_variant_t(NUM_RETRIES_COLUMN));
		aPtr->SetNumRetries(vValue.lVal);
				
		vValue = mpRowset->GetValue(_variant_t(MAX_RETRIES_COLUMN));
		aPtr->SetMaxRetries(vValue.lVal);

		aPtr->SetScheduledPaymentDate(date);
				
		vValue = mpRowset->GetValue(_variant_t(CONFIRM_REQUESTED_COLUMN));
		aPtr->SetConfirmationRequested((const wchar_t*)MTMiscUtil::GetString(vValue));
				
		vValue = mpRowset->GetValue(_variant_t(CONFIRM_RECEIVED_COLUMN));
		aPtr->SetConfirmationReceived((const wchar_t*)MTMiscUtil::GetString(vValue));

		vValue = mpRowset->GetValue(_variant_t(SESSION_ID_COLUMN));
		aPtr->SetSessionID(vValue.lVal);
		
		
		//first evaluate secondary conditions that  apply to PENDING and FAILED status
		switch (aPtr->GetPaymentStatus())
		{

			case PS_PENDING:
			{
				if (aPtr->GetConfirmationRequested())
				{
					if(!aPtr->GetConfirmationReceived())
					{
						mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> will not be processed now because status is PENDING, confirmation "
						"was requested but not received", aPtr->GetSessionID());
						return FALSE;
					}
				}
				else if (date > today)
				{
					mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> has a date that is past midnight today and will not be processed now",
									   aPtr->GetSessionID());
					return FALSE;
				}
				
				break;
			}
						
			case PS_FAILED:
			{
				//If Retry on failure not set jst return
				if (!aPtr->GetRetryOnFailure())
				{
					mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> will not be processed now because status is FAILED and RetryOnFailure "
						"flag is not set", aPtr->GetSessionID());
					return FALSE;
				}
				
				//If Number of retries exceeededs or equal to max Retries just return
				if(aPtr->GetMaxRetries() <= aPtr->GetNumRetries())
				{
					mLogger.LogVarArgs(LOG_DEBUG, "Record with session id <%d> will not be processed now because status is FAILED and NumRetries "
						"is more then MaxRetries (%d > %d)", aPtr->GetSessionID(), aPtr->GetNumRetries(), aPtr->GetMaxRetries());
					return FALSE;
				}
				break;
			}
		}
		
		//If got to this point then this transaction is qualified to be submitted now
		//Set the rest of the properties on the object
		
		vValue = mpRowset->GetValue(_variant_t(ACCOUNT_ID_COLUMN));
		aPtr->SetAccountID(vValue.lVal);

		vValue = mpRowset->GetValue(_variant_t(AMOUNT_COLUMN));
		dv  = vValue.decVal;
		aPtr->SetAmount(dv);

		vValue = mpRowset->GetValue(_variant_t(CURRENCY_COLUMN));
		aPtr->SetCurrency((const wchar_t*)MTMiscUtil::GetString(vValue));

		vValue = mpRowset->GetValue(_variant_t(ORIGINAL_ACCOUNT_ID_COLUMN));
		aPtr->SetOriginalAccountID(vValue.lVal);
		
		vValue = mpRowset->GetValue(_variant_t(PAYMENT_TYPE_COLUMN));
		wstring value = mEnumConfig->GetEnumeratorValueByID(vValue.lVal);
		res = ConvertToLong(value, &enumVal);
		ASSERT(res);
		aPtr->SetPaymentType((PaymentServer::PaymentType) enumVal);
		
		vValue = mpRowset->GetValue(_variant_t(SCHEDULED_PAYMENT_DATE_COLUMN));
		aPtr->SetScheduledPaymentDate(MTDate(vValue.date));
		
		vValue = mpRowset->GetValue(_variant_t(LAST_STATUS_UPDATE_COLUMN));
		aPtr->SetLastStatusUpdateDate(MTDate(vValue.date));
		
		
		if(aPtr->GetPaymentType() == PS_ACH)
		{
			vValue = mpRowset->GetValue(_variant_t(BANK_ACCOUNT_TYPE_COLUMN));
			if(vValue.vt == VT_NULL)
			{
				mLogger.LogThis(LOG_ERROR,"Payment Type is ACH, but BankAccountType field is missing in database!");
				return FALSE;
			}

			value = mEnumConfig->GetEnumeratorValueByID(vValue.lVal);
			res = ConvertToLong(value, &enumVal);
			ASSERT(res);
			aPtr->SetBankAccountType((PaymentServer::BankAccountType) enumVal);

			vValue = mpRowset->GetValue(_variant_t(ROUTING_NUMBER_COLUMN));
			aPtr->SetRoutingNumber((const wchar_t*)MTMiscUtil::GetString(vValue));
		}
		else if(aPtr->GetPaymentType() == PS_CREDIT_CARD)
		{
			vValue = mpRowset->GetValue(_variant_t(CREDIT_CARD_TYPE_COLUMN));
			if(vValue.vt == VT_NULL)
			{
				mLogger.LogThis(LOG_ERROR,"Payment Type is CreditCard, but CreditCardType field is missing in database!");
				return FALSE;
			}
			value = mEnumConfig->GetEnumeratorValueByID(vValue.lVal);
			res = ConvertToLong(value, &enumVal);
			ASSERT(res);
			aPtr->SetCreditCardType((PaymentServer::CreditCardType) enumVal);

		}

		vValue = mpRowset->GetValue(_variant_t(LAST_FOUR_DIGITS_COLUMN));
		aPtr->SetLastFourDigits((const wchar_t*)MTMiscUtil::GetString(vValue));
	
		vValue = mpRowset->GetValue(_variant_t(PAYMENT_PROVIDER_STATUS_COLUMN));
		aPtr->SetPaymentProviderStatus((const wchar_t*)MTMiscUtil::GetString(vValue));
		
		vValue = mpRowset->GetValue(_variant_t(PAYMENT_PROVIDER_CODE_COLUMN));
		aPtr->SetPaymentProviderCode(vValue.lVal);
		
		vValue = mpRowset->GetValue(_variant_t(PAYMENT_NACHA_CODE_COLUMN));
		aPtr->SetNachaCode((const wchar_t*)MTMiscUtil::GetString(vValue));
		
		vValue = mpRowset->GetValue(_variant_t(EMAIL_COLUMN));
		aPtr->SetEmail((const wchar_t*)MTMiscUtil::GetString(vValue));
		
		vValue = mpRowset->GetValue(_variant_t(PAYMENT_SERVER_TRANSACTION_ID_COLUMN));
		_bstr_t trid = (const wchar_t*)MTMiscUtil::GetString(vValue);
		aPtr->SetPaymentServiceTransactionID((const wchar_t*)trid);
		
		vValue = mpRowset->GetValue(_variant_t(INTERVAL_ID_COLUMN));
		aPtr->SetIntervalID(vValue.lVal);

		vValue = mpRowset->GetValue(_variant_t(AUTH_RECEIVED_FLAG_COLUMN));
		aPtr->SetAuthReceived((const wchar_t*)MTMiscUtil::GetString(vValue));

		vValue = mpRowset->GetValue(_variant_t(PRENOTE_VALIDATED_FLAG_COLUMN));
		aPtr->SetPrenoteValidated((const wchar_t*)MTMiscUtil::GetString(vValue));
	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Exception caught in SchedulerEvaluator::PopulatePaymentTransaction: %s",
			(const char*)e.Description());
		return FALSE;
	}
	return TRUE;
}

std::wstring SchedulerEvaluator::EscapeSQLString(const std::wstring & str)
{
	// only escape single quotes if necessary
  if (str.find('\'') == std::wstring::npos)
		return str;

	// double up and single quotes
  std::wstring escapedStr;
  for (unsigned int i = 0; i < str.length(); i++)
  {
    if (str[i] == '\'')
      escapedStr += L"''";
    else
      escapedStr += str[i];
  }
	
  return escapedStr;
}

















