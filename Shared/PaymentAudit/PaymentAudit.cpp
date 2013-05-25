// PaymentAudit.cpp: implementation of the PaymentAudit class.
//
//////////////////////////////////////////////////////////////////////

#include <comdef.h>
#include <adoutil.h>

#include <loggerconfig.h>
#include <mtglobal_msg.h>

#include "PaymentAudit.h"

#include <MTUtil.h>

// import the config loader tlb
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

PaymentAudit::PaymentAudit() :
		mInitialized(FALSE)
{
  LoggerConfigReader configReader;
  mLogger.Init (configReader.ReadConfiguration("Core"), "[PaymentAudit]");
}


//////////////////////////////////////////////////////////////////////
PaymentAudit::~PaymentAudit()
{
  mInitialized = FALSE ;
}


///////////////////////////////////////////////////////////////////
BOOL PaymentAudit::Initialize()
{
  // set the initialized flag ...
  mInitialized = TRUE ;
  
	return TRUE;
}


////////////////////////////////////////////////////////////////////////
BOOL PaymentAudit::Insert(ROWSETLib::IMTSQLRowsetPtr   aRowset,
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
							            const char                 * aNotes)
{
  const char* procName = "PaymentAudit::Insert";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, 
      "PaymentAudit::Insert: Object not initialized."); 

    mLogger.LogThis(LOG_WARNING,
						"Database initialization needs to be called first");
    return (FALSE) ;
  }

  // local variables
  wstring wstrAction;
  wstring wstrRoutingNumber;
  wstring wstrLast4Digits;
	wstring wstrAccountType;
  wstring wstrBankName;
  wstring wstrExpDate;
  wstring wstrSubscriberID;
  wstring wstrPhoneNumber;
	wstring wstrCSRIP;
	wstring wstrCSRID;
  wstring wstrNotes;

	ASCIIToWide(wstrAction, aAction);
	ASCIIToWide(wstrRoutingNumber, aRoutingNumber);
	ASCIIToWide(wstrLast4Digits, aLast4Digits);
	ASCIIToWide(wstrAccountType,	aAccountType);
	ASCIIToWide(wstrBankName, aBankName);
	ASCIIToWide(wstrExpDate, aExpDate);
	ASCIIToWide(wstrSubscriberID, aSubscriberID);
	ASCIIToWide(wstrPhoneNumber, aPhoneNumber);
	ASCIIToWide(wstrCSRIP, aCSRIP);
	ASCIIToWide(wstrCSRID, aCSRID);
	ASCIIToWide(wstrNotes, aNotes);

  wstring langRequest;
  
  // build the query
  CreateInsertQuery (aRowset,
                     aAccountID, 
										 wstrAction,
										 wstrRoutingNumber,
										 wstrLast4Digits,
										 wstrAccountType,
										 wstrBankName,
										 wstrExpDate,
										 aExpDateFormat,
										 wstrSubscriberID,
										 wstrPhoneNumber,
										 wstrCSRIP,
										 wstrCSRID,
										 wstrNotes,
										 langRequest);
  
  // execute the language request
  if (S_OK != aRowset->Execute())
  {
    mLogger.LogThis(LOG_ERROR, "Database execution failed for User Config");
    return (FALSE);
  }
  
	return TRUE;
}


////////////////////////////////////////////////////////////////////////
//	@mfunc CreateInitQuery
//	@parm  pLoginName
//	@parm  pName_Space
//	@rdesc Builds the query required for initializing the kiosk gate using
//	the provider ID.
void
PaymentAudit::CreateInsertQuery (ROWSETLib::IMTSQLRowsetPtr   aRowset,
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
                                 wstring                  & langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  
  try
  {
    aRowset->ClearQuery();
    queryTag = "__INSERT_TO_PAYMENT_AUDIT__";
    aRowset->SetQueryTag(queryTag);
    
    vtParam = (long)aAccountID;
    aRowset->AddParam(MTPARAM_ACCOUNTID, vtParam);

    vtParam = aAction.c_str();
    aRowset->AddParam(MTPARAM_ACTIONNAME, vtParam);

    vtParam = aRoutingNumber.c_str();
    aRowset->AddParam(L"%%ROUTING_NUMBER%%", vtParam);
    
    vtParam = aLast4Digits.c_str();
    aRowset->AddParam(MTPARAM_LASTFOURDIGITS, vtParam);
    
    vtParam = aAccountType.c_str();
    aRowset->AddParam(L"%%ACCOUNT_TYPE%%", vtParam);
    
    vtParam = aBankName.c_str();
    aRowset->AddParam(L"%%BANK_NAME%%", vtParam);

    vtParam = aExpDate.c_str();
    aRowset->AddParam(MTPARAM_EXPDATE, vtParam);

    vtParam = (long)aExpDateFormat;
    aRowset->AddParam(MTPARAM_EXPDATEFORMAT, vtParam);

    vtParam = aSubscriberID.c_str();
    aRowset->AddParam(MTPARAM_SUBSCRIBERIP, vtParam);

    vtParam = aPhoneNumber.c_str();
    aRowset->AddParam(MTPARAM_PHONENUNBER, vtParam);
    
    vtParam = aCSRIP.c_str();
    aRowset->AddParam(MTPARAM_CSRIP, vtParam);
    
    vtParam = aCSRID.c_str();
    aRowset->AddParam(MTPARAM_CSRID, vtParam);

    vtParam = aNotes.c_str();
    aRowset->AddParam(MTPARAM_NOTES, vtParam);
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "PaymentAudit::CreateInitQuery()", 
      "Unable to get __INSERT_TO_PAYMENT_AUDIT__ query") ;
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  
  return;
}
