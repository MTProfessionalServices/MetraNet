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


#include <metra.h>
#include <mtprogids.h>
#include <string>
#include <vector>
#include <Enums.h>
#include <mtglobal_msg.h>
#include <DBAccess.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <loggerconfig.h>
#include <MTDate.h>
#include <mtsdk.h>
#include <MTDec.h>
#include <SetIterate.h>
#include <stdutils.h>
#include <MTUtil.h>

#define GET_ACH_DEBIT_RECORDS_TAG											L"__GET_ACH_DEBIT_RECORDS__"
#define GET_ACH_CREDIT_RECORDS_TAG										L"__GET_ACH_CREDIT_RECORDS__"
#define GET_ACH_PRENOTE_RECORDS_TAG										L"__GET_ACH_PRENOTE_RECORDS__"

#define GET_ACH_DEBIT_RECORD_TAG											L"__GET_ACH_DEBIT_RECORD__"
#define GET_ACH_CREDIT_RECORD_TAG											L"__GET_ACH_CREDIT_RECORD__"
#define GET_ACH_PRENOTE_RECORD_TAG											L"__GET_ACH_PRENOTE_RECORD__"

#define UPDATE_ACH_CREDIT_RECORD_TAG									L"__UPDATE_ACH_CREDIT_RECORD__"
#define UPDATE_ACH_DEBIT_RECORD_TAG										L"__UPDATE_ACH_DEBIT_RECORD__"
#define UPDATE_ACH_PRENOTE_RECORD_TAG									L"__UPDATE_ACH_PRENOTE_RECORD__"
#define UPDATE_PAYMENT_SCHEDULER_RECORD_TAG						L"__UPDATE_SCHEDULED_PAYMENT_RECORD__"
	
#define PAYMENT_SERVER_ENUM_SPACE							L"metratech.com/PaymentServer"
#define PAYMENT_STATUS_ENUM_TYPE							L"PaymentStatus"

#define CURRENT_STATUS_COLUMN									L"c_currentstatus"
#define PAYMENT_SERVER_TRANSACTION_ID_COLUMN	L"c_paymentservicetransactionid"

#define	RELATIVE_PATH_TO_QUERIES							L"\\paymentsvr\\config\\PaymentServer"

#define ACH_INQUIRY_SERVICE										"metratech.com/ps_ach_inquiry"

#define LOG_TAG "[RetrieveTransactionStatus]"

//#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

#import <MTEnumConfigLib.tlb>
// import the serveraccess tlb file
#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;

#define SERVER_ACCESS_RELATIVE_PATH L"\\PaymentSvr\\Config\\ServerAccess"

using namespace std;
using namespace PaymentServer;

class ACHRecord;

class TransacationIDAndStatus;

typedef vector<ACHRecord*> ACHRecordList;

typedef enum
{
	ACH_DEBIT,
	ACH_CREDIT, 
	ACH_PRENOTE
}	TransactionType;

class ACHRecord
{
	public:
		wstring GetResponseString()
		{
			return msResponseString;
		}
		long GetResponseCode()
		{
			return mlResponseCode;
		}
		wstring GetPSTransactionID()
		{
			return msPSTransactionID;
		}
		PaymentServer::PaymentStatus GetOldStatus()
		{
			return meOldStatus;
		}
		PaymentServer::PaymentStatus GetNewStatus()
		{
			return meNewStatus;
		}
		TransactionType GetTransactionType()
		{
			return meTransactionType;
		}
		long GetBankAccountType()
		{
			return meBankAccountType;
		}
		wstring GetLastFourDigits()
		{
			return msLastFourDigits;	
		}
		wstring GetEmailAddress()
		{
			return msEmailAddress;
		}

		void SetPSTransactionID(const wstring& aParam)
		{
			msPSTransactionID = aParam;
		}

		void SetOldStatus(const PaymentServer::PaymentStatus& aParam)
		{
			meOldStatus = aParam;
		}
		void SetNewStatus(const PaymentServer::PaymentStatus& aParam)
		{
			meNewStatus = aParam;
		}
		void SetTransactionType(const TransactionType& aParam)
		{
			meTransactionType = aParam;
		}
		void SetBankAccountType(const long& aParam)
		{
			meBankAccountType = aParam;	
		}
		void SetLastFourDigits(const wstring& aParam)
		{
			msLastFourDigits = aParam;	
		}
		void SetEmailAddress(const wstring& aParam)
		{
			msEmailAddress = aParam;	
		}
		void SetResponseString(const wstring& aParam)
		{
			msResponseString = aParam;
		}
		void SetResponseCode(const long& aParam)
		{
			mlResponseCode = aParam;
		}
	


	private:
		wstring msPSTransactionID;
		PaymentServer::PaymentStatus meOldStatus, meNewStatus;
		TransactionType meTransactionType;
		long meBankAccountType;
		wstring msLastFourDigits;
		wstring	msEmailAddress;

		//repsonse stuff
		wstring msResponseString;
		long		mlResponseCode;
};

BOOL ConvertToLong(const wstring& arValue, long * apConverted)
{
	wchar_t * end;
	*apConverted = wcstol(arValue.c_str(), &end, 10);
	if (end != arValue.c_str() + arValue.length())
		return FALSE;
	return TRUE;
}

PaymentServer::PaymentStatus ConvertStatusStringToEnum(const wstring& aStatus)
{
	if(_wcsicmp(aStatus.c_str(), L"P01") == 0)
		return PS_SETTLED;
	if(_wcsicmp(aStatus.c_str(), L"P02") == 0)
		return PS_SENT;
	if(_wcsicmp(aStatus.c_str(), L"P03") == 0)
		return PS_OPEN;
	if(_wcsicmp(aStatus.c_str(), L"P15") == 0)
		return PS_FAILED;
	return PS_FAILED;
}
