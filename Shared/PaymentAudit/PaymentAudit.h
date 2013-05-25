// PaymentAudit.h: interface for the PaymentAudit class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_PAYMENTAUDIT_H__B6609FC5_5FA8_11D3_A856_00C04F465BA9__INCLUDED_)
#define AFX_PAYMENTAUDIT_H__B6609FC5_5FA8_11D3_A856_00C04F465BA9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// import the row set tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib;

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

//	All the includes
#include <SharedDefs.h>
#include <errobj.h>
#include <NTLogger.h>
#include <NTLogMacros.h>
#include <DBConstants.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtparamnames.h>

#define PAYMENT_SERVER_CONFIG_PATH "\\PaymentServer"

class PaymentAudit   :
	public virtual ObjectWithError
{
public:
	PaymentAudit();
	virtual ~PaymentAudit();

	BOOL Initialize();

	BOOL Insert(ROWSETLib::IMTSQLRowsetPtr   aRowset,
              const long                   aAccountID,
							const char                 * aAction, 
							const char                 * aRoutingNumber,
							const char                 * aLast4Digits,
							const char                 * aAccountType,
              const char                 * aBankName,
							const char                 * aExpDate,
							const long                   aExpDateFormat,
							const char                 * aSubscriberID,
							const char                 * aPhoneNumber,
							const char                 * aCSRIP,
							const char                 * aCSRID,
							const char                 * aNotes);

private:

  // method to create query for init with provider id
  void CreateInsertQuery (ROWSETLib::IMTSQLRowsetPtr   aRowset,
                          const long                   aAccountID,
												  const wstring            & aAction,
												  const wstring            & aRoutingNumber,
												  const wstring            & aLast4Digits,
												  const wstring            & aAccountType,
												  const wstring            & aBankName,
												  const wstring            & aExpDate,
												  const long                   aExpDateFormat,
												  const wstring            & aSubscriberID,
												  const wstring            & aPhoneNumber,
												  const wstring            & aCSRIP,
												  const wstring            & aCSRID,
												  const wstring            & aNotes,
                          wstring                  & langRequest);

private:
  NTLogger mLogger;

  IMTQueryAdapter* mpQueryAdapter;

  BOOL mInitialized ;
};

#endif // !defined(AFX_PAYMENTAUDIT_H__B6609FC5_5FA8_11D3_A856_00C04F465BA9__INCLUDED_)
