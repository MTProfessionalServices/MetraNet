#include <StdAfx.h>
#include <PlugInSkeleton.h>
#include <MTPipelineLib.h>
#include <stdio.h>
#include <AdapterLogging.h>
#include <ConfigDir.h>
#include <mtprogids.h>
#include <MTDec.h>

//{C38DC830-EFCB-11d3-9597-00B0D025B121}
#define CONFIG_FILE_PATH L"Pipeline\\AccountCreditRequest\\Config.xml"

#import "MTConfigLib.tlb"
#import <AccountCredit.tlb>
//using namespace ACCOUNTCREDITLib;

CLSID CLSID_AccountCreditRequestPlugin = {  
	0xC38DC830,
		0xEFCB,
		0x11d3,
	{ 0x95, 0x97, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};
//
class ATL_NO_VTABLE AccountCreditRequestPlugin
: public MTPipelinePlugIn<AccountCreditRequestPlugin, &CLSID_AccountCreditRequestPlugin >
//	public ObjectWithError
{
public:
		AccountCreditRequestPlugin();
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
		MTPipelineLib::IMTConfigPropSetPtr aPropSet,
		MTPipelineLib::IMTNameIDPtr aNameID,
		MTPipelineLib::IMTSystemContextPtr aSysContext);
	// process the session
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
protected: // data
	NTLogger mLogger;
	MTPipelineLib::IMTLogPtr mLoggerPtr;
	long	m_AccountID, m_Amount, m_Currency, 
				m_Reason, m_Status, m_Other, m_Description, mCreditAmount, mSubscriberAccountID, mMaxAmount;
	_bstr_t  mConfigFile;


	BOOL bInitialized;
	ACCOUNTCREDITLib::IMTAccountCreditPtr mCredit;
	
	BOOL IsValidStatus(_bstr_t status);
	
	HRESULT ReportError(const char*, HRESULT);
	
};
// this macro provides information to the plug-in skeleton on how the COM
// object should be registered, its CLSID, and its threading model.  If you are
// familiar with ATL COM objects, this macro basically provides all of the information
// to ATL so this class can act as a COM object
PLUGIN_INFO(CLSID_AccountCreditRequestPlugin, AccountCreditRequestPlugin,
						"MetraPipeline.AccountCreditRequestPlugin.1",
						"MetraPipeline.AccountCreditRequestPlugin", "Free")
						/////////////////////////////////////////////////////////////////////////////
						//PlugInConfigure
						/////////////////////////////////////////////////////////////////////////////
HRESULT AccountCreditRequestPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
						MTPipelineLib::IMTNameIDPtr aNameID,
						MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	// grab an instance of the logger so we can use it in process sessions if
	// we need to 
	HRESULT nRetVal = S_OK;
	mLoggerPtr = aLogger;
	// Declare the list of properties we will read from the XML configuration
	// When ProcessProperties is called, it loads the property Ids into the
	// variable that was passed 

	//Create AutoCredit object
	nRetVal = mCredit.CreateInstance ("AccountCredit.MTAccountCredit.1") ;
  
	if (!SUCCEEDED(nRetVal))
  {
	  return ReportError("Failed to create AccountCredit.MTAccountCredit.1 object", nRetVal);
  }
	mLogger.LogThis(LOG_DEBUG, "Initializing AccountCredit.MTAccountCredit.1...");
	nRetVal = mCredit->Initialize();
	
	if (!SUCCEEDED(nRetVal))
  {
		return ReportError("Failed to initialize AccountCredit.MTAccountCredit.1 object", nRetVal);
  }

	
	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("_AccountID",&m_AccountID)
		DECLARE_PROPNAME("_Amount",&m_Amount)
		DECLARE_PROPNAME("_Currency",&m_Currency)
		DECLARE_PROPNAME("Reason",&m_Reason)
		DECLARE_PROPNAME("Other",&m_Other)
		DECLARE_PROPNAME("Status",&m_Status)
		DECLARE_PROPNAME("Description",&m_Description)
		DECLARE_PROPNAME("CreditAmount",&mCreditAmount)
		DECLARE_PROPNAME("SubscriberAccountID",&mSubscriberAccountID)
	END_PROPNAME_MAP

	
		nRetVal = ProcessProperties(inputs,aPropSet,aNameID,mLoggerPtr,/*PROCEDURE*/NULL);

		if(SUCCEEDED(nRetVal))
		{
			aPropSet->Reset();

			bInitialized = TRUE;
		}

		return nRetVal;
}



// Constructor
// initialize the logger ...
#ifdef DECIMAL_PLUGINS
AccountCreditRequestPlugin::AccountCreditRequestPlugin() : mConfigFile(""), bInitialized(FALSE)
#else
AccountCreditRequestPlugin::AccountCreditRequestPlugin() : mConfigFile(""), bInitialized(FALSE)
#endif
{
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("AccountCreditRequestPlugin"), "[AccountCreditRequestPlugin]");
	

}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT AccountCreditRequestPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT nRetVal(S_OK);
  try
  {
	  long lID=aSession->GetLongProperty(m_AccountID);
  #ifdef DECIMAL_PLUGINS
	  MTDecimal nAmount = aSession->GetDecimalProperty(m_Amount);
  #else
	  double nAmount = aSession->GetDoubleProperty(m_Amount);
  #endif
  	
	  nAmount = (nAmount>0) ? (-nAmount) : nAmount;
	  _bstr_t bstrOther;
	  _bstr_t bstrCurrency = aSession->GetStringProperty(m_Currency);
	  _bstr_t bstrDescription;
	  long lReason = aSession->GetEnumProperty(m_Reason);

	  if(aSession->PropertyExists(m_Other, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
		  bstrOther = aSession->GetStringProperty(m_Other);
  	
	  if(aSession->PropertyExists(m_Description, MTPipelineLib::SESS_PROP_TYPE_STRING))
		bstrDescription = aSession->GetStringProperty(m_Description);

	  _bstr_t status = aSession->GetStringProperty(m_Status);

	  _bstr_t buffer;
	  if(!bInitialized)
	  {
		  nRetVal = E_FAIL;
		  buffer = "Configuration could not be read, exiting!";
		  mLogger.LogThis(LOG_ERROR, (char*)buffer);
		  return Error((char*)buffer, IID_IMTPipelinePlugIn, nRetVal);
	  }

	  if (IsValidStatus(status))
	  {
		  aSession->SetStringProperty(m_Status, status);
	  }
	  else
	  {
		  nRetVal = E_ABORT;
		  buffer = "Invalid Status field: " +status;
		  mLogger.LogThis(LOG_ERROR,(char*) buffer);
		  return Error((char*)buffer, IID_IMTPipelinePlugIn, nRetVal);
	  }
	}
	catch (_com_error err)
	{
      if (err.Error() == PIPE_ERR_INVALID_PROPERTY)
      {
		aSession->MarkAsFailed(err.Description(), PIPE_ERR_INVALID_PROPERTY);
		return PIPE_ERR_INVALID_PROPERTY;
      }
      else
      {
		aSession->MarkAsFailed(err.Description(), err.Error());
  		return ReturnComError(err);
      }
	}

	return nRetVal;
}

BOOL AccountCreditRequestPlugin::IsValidStatus(_bstr_t status)
{
	return	(status == _bstr_t("PENDING"));
}

HRESULT AccountCreditRequestPlugin::ReportError( const char* str_errmsg , HRESULT nRetVal)
{
	mLogger.LogThis (LOG_ERROR, str_errmsg);
	return Error (str_errmsg, IID_IMTPipelinePlugIn, nRetVal ) ;
}