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
#include <DBMiscUtils.h>
#include <MTUtil.h>

#define LOG_TAG "[PeriodicallySubmitTransactions]"

//#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

#import <MTEnumConfigLib.tlb>
// import the serveraccess tlb file
#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;

//#define SERVER_ACCESS_RELATIVE_PATH L"\\PaymentSvr\\Config\\ServerAccess"

using namespace std;


//forward decl
class PaymentTransaction;
class SchedulerEvaluator;

typedef vector<PaymentTransaction*> TransactionsToSubmit;

using namespace PaymentServer;
using namespace BillingCycle;


class PaymentTransactionResult
{
public:
	PaymentTransactionResult() :	msPaymentProviderStatus(L"No Status"),
									msPaymentServiceTransactionID(L"Not Available"),
									mlPaymentProviderCode(0),
									mePaymentStatus((PaymentStatus)NULL)
																
	{}
	void SetPaymentProviderStatus(const wstring& aParam)
	{
		if (aParam.length() > 0)
			msPaymentProviderStatus = aParam;
	}
	void SetPaymentProviderCode(const long& aParam)
	{
		mlPaymentProviderCode = aParam;
	}
	void SetPaymentServiceTransactionID(const wstring& aParam)
	{
		msPaymentServiceTransactionID = aParam;
	}
	void SetPaymentStatus(const PaymentStatus& aParam)
	{
		mePaymentStatus = aParam;
	}
	wstring GetPaymentProviderStatus()
	{
		return msPaymentProviderStatus;
	}
	long GetPaymentProviderCode()
	{
		return mlPaymentProviderCode;
	}
	wstring GetPaymentServiceTransactionID()
	{
		return msPaymentServiceTransactionID;
	}
	PaymentStatus GetPaymentStatus()
	{
		return mePaymentStatus;
	}
private:
	wstring msPaymentProviderStatus,msPaymentServiceTransactionID;
	long mlPaymentProviderCode;
	PaymentStatus mePaymentStatus;
};

class PaymentTransaction : public ObjectWithError
{
public:
	PaymentTransaction(); 
	virtual ~PaymentTransaction(){}
	BOOL Init();
	BOOL Submit(PaymentTransactionResult& aPtr, MTMeter* aMeterServer);
	BOOL UpdateStatus(const PaymentTransactionResult& aResult, SchedulerEvaluator& aEval);
	
	//MUTATORS:
	
	void SetOriginalAccountID(const long& aParam)
	{
		mlOriginalAccountID = aParam;
	}

	void SetAccountID(const long& aParam)
	{
		mlAccountID = aParam;
	}
	void SetPaymentType(const PaymentServer::PaymentType& aParam)
	{
		mePaymentType = aParam;
	}

	void SetLastFourDigits(const wstring& aParam)
	{
		msLastFourDigits = aParam;
	}

	void SetRoutingNumber(const wstring& aParam)
	{
		msRoutingNumber = aParam;
	}
	
	void SetBankAccountType(const PaymentServer::BankAccountType& aParam)
	{
		meBankAccountType = aParam;
	}
	
	void SetCreditCardType(const PaymentServer::CreditCardType& aParam)
	{
		meCreditCardType = aParam;
	}
	
	void SetScheduledPaymentDate(const MTDate& aParam)
	{
		mdScheduledPaymentDate = aParam;
	}
	
	void SetLastStatusUpdateDate(const MTDate& aParam)
	{
		mdLastStatusUpdateDate = aParam;
	}
	
	void SetPaymentStatus(const PaymentServer::PaymentStatus& aParam)
	{
		mePaymentStatus = aParam;
	}
	
	void SetPaymentProviderStatus(const wstring& aParam)
	{
		msPaymentProviderStatus = aParam;
	}
	
	void SetPaymentProviderCode(const long& aParam)
	{
		mlPaymentProviderCode = aParam;
	}

	void SetNachaCode(const wstring& aParam)
	{
		msNachaCode = aParam;
	}
	void SetMaxRetries(const long& aParam)
	{
		mlMaxRetries = aParam;
	}

	void SetRetryOnFailure(const BOOL& aParam)
	{
		mbRetryOnFailure = aParam;
	}

	void SetNumRetries(const long& aParam)
	{
		mlNumRetries = aParam;
	}



	void SetConfirmationRequested(const BOOL& aParam)
	{
		mbConfirmationRequested = aParam;
	}
	void SetConfirmationReceived(const BOOL& aParam)
	{
		mbConfirmationReceived = aParam;
	}
	void SetAuthReceived(const BOOL& aParam)
	{
		mbAuthReceived = aParam;
	}
	void SetPrenoteValidated(const BOOL& aParam)
	{
		mbPrenoteValidated = aParam;
	}
	//overloads until properties change to BOOLEAN in PV
	void SetRetryOnFailure(const _bstr_t& aParam)
	{
		_bstr_t temp = aParam;
		SetRetryOnFailure( ((_wcsicmp((wchar_t*)aParam, L"Y") == 0) ||
			(_wcsicmp((wchar_t*)aParam, L"T") == 0) ||
			(_wcsicmp((wchar_t*)aParam, L"1") == 0)) ? TRUE : FALSE);
	}
	void SetConfirmationRequested(const _bstr_t& aParam)
	{
		_bstr_t temp = aParam;
		SetConfirmationRequested(	((_wcsicmp((wchar_t*)aParam, L"Y") == 0) ||
									(_wcsicmp((wchar_t*)aParam, L"T") == 0) ||
									(_wcsicmp((wchar_t*)aParam, L"1") == 0)) ? TRUE : FALSE);
	}
	void SetConfirmationReceived(const _bstr_t& aParam)
	{
		_bstr_t temp = aParam;
		SetConfirmationReceived(	((_wcsicmp((wchar_t*)aParam, L"Y") == 0) ||
									(_wcsicmp((wchar_t*)aParam, L"T") == 0) ||
									(_wcsicmp((wchar_t*)aParam, L"1") == 0)) ? TRUE : FALSE);
	}

	void SetAuthReceived(const _bstr_t& aParam)
	{
		_bstr_t temp = aParam;
		SetAuthReceived(	((_wcsicmp((wchar_t*)aParam, L"Y") == 0) ||
							(_wcsicmp((wchar_t*)aParam, L"T") == 0) ||
							(_wcsicmp((wchar_t*)aParam, L"1") == 0)) ? TRUE : FALSE);
	
	}
	void SetPrenoteValidated(const _bstr_t& aParam)
	{
		_bstr_t temp = aParam;
		SetPrenoteValidated(	((_wcsicmp((wchar_t*)aParam, L"Y") == 0) ||
								(_wcsicmp((wchar_t*)aParam, L"T") == 0) ||
								(_wcsicmp((wchar_t*)aParam, L"1") == 0)) ? TRUE : FALSE);
	}
	
	void SetEmail(const wstring& aParam)
	{
		msEmail = aParam;
	}
	void SetPaymentServiceTransactionID(const wstring& aParam)
	{
		msPaymentServiceTransactionID = aParam;
	}
	void SetUsageCycleType(const BillingCycle::UsageCycleType& aParam)
	{
		meUsageCycleType = aParam;
	}
	void SetIntervalID(const long& aParam)
	{
		mlIntervalID = aParam;
	}
	void SetAmount(const DECIMAL& aParam)
	{
		mDecAmount = aParam;
	}
	//overload for future
	void SetTaxAmount(const DECIMAL& aParam)
	{
		mDecTaxAmount = aParam;
	}
	void SetDescription(const wstring& aParam)
	{
		msDescription = aParam;
	}
	void SetSessionID(const long& aParam)
	{
		mlSessionID = aParam;
	}

	void SetCurrency(const wstring& aParam)
	{
		msCurrency = aParam;
	}

	//ACCESSORS:
	
	long GetOriginalAccountID()
	{
		return mlOriginalAccountID;
	}

	long GetAccountID()
	{
		return mlAccountID;
	}

	PaymentServer::PaymentType GetPaymentType()
	{
		return mePaymentType;
	}
	wstring GetLastFourDigits()
	{
		return msLastFourDigits;
	}
	wstring GetRoutingNumber()
	{
		return msRoutingNumber;
	}
	
	PaymentServer::BankAccountType GetBankAccountType()
	{
		return meBankAccountType;
	}
	
	PaymentServer::CreditCardType GetCreditCardType()
	{
		return meCreditCardType;
	}
	
	MTDate GetScheduledPaymentDate()
	{
		return mdScheduledPaymentDate;
	}

	MTDate GetLastStatusUpdateDate()
	{
		return mdLastStatusUpdateDate;
	}
	
	PaymentServer::PaymentStatus GetPaymentStatus()
	{
		return mePaymentStatus;
	}
	
	wstring GetPaymentProviderStatus()
	{
		return msPaymentProviderStatus;
	}
	
	long GetPaymentProviderCode()
	{
		return mlPaymentProviderCode;
	}
	
	wstring GetNachaCode()
	{
		return msNachaCode;
	}
	
	long GetMaxRetries()
	{
		return mlMaxRetries;
	}
	
	BOOL GetRetryOnFailure()
	{
		return mbRetryOnFailure;
	}

	long GetNumRetries()
	{
		return mlNumRetries;
	}
	
	BOOL GetConfirmationRequested()
	{
		return mbConfirmationRequested;
	}
	
	BOOL GetConfirmationReceived()
	{
		return mbConfirmationReceived;
	}
	BOOL GetAuthReceived()
	{
		return mbAuthReceived;
	}
	BOOL GetPrenoteValidated()
	{
		return mbPrenoteValidated;
	}
	
	wstring GetEmail()
	{
		return msEmail;
	}
	
	wstring GetPaymentServiceTransactionID()
	{
		return msPaymentServiceTransactionID;
	}
	
	BillingCycle::UsageCycleType GetUsageCycleType()
	{
		return meUsageCycleType;
	}
	
	long GetIntervalID()
	{
		return mlIntervalID;
	}
	
	DECIMAL GetTaxAmount()
	{
		return (DECIMAL)(_variant_t)mDecTaxAmount;
	}

	DECIMAL GetAmount()
	{
		return (DECIMAL)(_variant_t)mDecAmount;
	}
	
	wstring GetDescription()
	{
		return msDescription;
	}
	long GetSessionID()
	{
		return mlSessionID;
	}
	wstring GetCurrency()
	{
		return msCurrency;
	}
		
private:
	BOOL mbAuthReceived;
	BOOL mbPrenoteValidated;
	
	//the one from scheduler PV
	long	mlOriginalAccountID;
	//the one from usage table (do we need it?)
	long	mlAccountID;
	PaymentType mePaymentType;
	wstring msLastFourDigits;
	wstring msRoutingNumber;
	//only ACH
	BankAccountType meBankAccountType;
	CreditCardType meCreditCardType;
	MTDate mdScheduledPaymentDate;
	MTDate mdLastStatusUpdateDate;
	PaymentStatus mePaymentStatus;
	
	wstring msPaymentProviderStatus;
	long mlPaymentProviderCode;
	wstring msNachaCode;
	
	long mlMaxRetries;
	long mlNumRetries;
	BOOL mbRetryOnFailure;
	BOOL mbConfirmationRequested;
	BOOL mbConfirmationReceived;
	wstring msEmail;
	wstring msPaymentServiceTransactionID;
	UsageCycleType meUsageCycleType;
	
	long mlIntervalID;
	MTDecimal mDecTaxAmount;
	MTDecimal mDecAmount;
	wstring msDescription;
	wstring msCurrency;
	
	//PV specific values. Need them there
	//to update status later
	//May become unneeded if Dave fixes UpdateStatus pipeline
	long	mlSessionID;
	
	NTLogger mLogger;

	};
	
	class SchedulerEvaluator
	{
	public:
		SchedulerEvaluator(){}
		~SchedulerEvaluator(){}
		BOOL	Init(BSTR aExtDir,const MTENUMCONFIGLib::IEnumConfig* aEnum);
		BOOL	GetTransactionList(TransactionsToSubmit& aList);
		BOOL	GetTransaction(const wstring aTransactionID, PaymentTransaction& aPT);
		BOOL	UpdateTransactionInfo(PaymentTransaction* aPT, PaymentTransactionResult* apResult);
		
		BOOL	ConvertToLong(const wstring& arValue, long * apConverted)
		{
			wchar_t * end;
			*apConverted = wcstol(arValue.c_str(), &end, 10);
			if (end != arValue.c_str() + arValue.length())
				return FALSE;
			return TRUE;
		}

		
		
	private:
    ROWSETLib::IMTSQLRowsetPtr mpRowset;
		_bstr_t mExtensionsDir;
		NTLogger mLogger;
		BOOL	PopulatePaymentTransaction(PaymentTransaction* aPT, const ROWSETLib::IMTSQLRowset* aRowSet);
		BOOL SetEnumConfig(const MTENUMCONFIGLib::IEnumConfig* aPtr);
		MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
    std::wstring EscapeSQLString(const std::wstring & str);
		
	};
