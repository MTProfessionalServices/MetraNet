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
* Created by: Raju Matta 
* $Header$
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// COMVendorKiosk.cpp : Implementation of CCOMVendorKiosk
// ---------------------------------------------------------------------------
#include "StdAfx.h"

#include "COMKiosk.h"
#include "COMAccount.h"
#include "COMVendorKiosk.h"
#include <mtglobal_msg.h>
#include <KioskDefs.h>
#include <mtprogids.h>
#include <multiinstance.h>
#include <makeunique.h>
#include <ConfigDir.h>

// import the config loader library
#include <loggerconfig.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CCOMVendorKiosk

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMVendorKiosk::CCOMVendorKiosk() : 
  mpKioskAuth(0), 
  mpAccountMapper(0), 
  mIsInitialized(FALSE), 
  mpAccount(0)
{	
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMVendorKiosk::~CCOMVendorKiosk() 
{
  TearDown();
}

STDMETHODIMP CCOMVendorKiosk::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMVendorKiosk,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

void CCOMVendorKiosk::TearDown()
{
  mIsInitialized = FALSE;
  
  // release all the pointer instances
  if (mpKioskAuth != NULL)
 {
    mpKioskAuth->Release();
    mpKioskAuth = 0;
  }
  if (mpAccountMapper != NULL)
  {
    mpAccountMapper->Release();
    mpAccountMapper = 0;
  }
  if (mpAccount != 0)
  {
    mpAccount.Release();
	mpAccount = 0;
  }
}

// ---------------------------------------------------------------------------
// Description:   This method initializes the C++ vendor kiosk object.  Each
//                provider gets a unique vendor kiosk object.  The
//                COMAccount, COMKioskAuth and COMAccountMapper objects are
//                all initialized.  Each account mapper gets initialized
//                separately based on the prog ID.  Same is the case with
//                the authenticator object i.e. the COMKioskAuth.
// Arguments:     Provider Name - account type indicating Bill-To or Ship-To 
//                Port - Unique port number
// Errors Raised: 0x80020009 - E_FAIL 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
//                0xE140018 - KIOSK_ERR_ACCOUNT_ALREADY_EXISTS 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::Initialize(BSTR providerName, int port)
{
  // local variables ...
  HRESULT hOK = S_OK;  
  string buffer;
  mExtensionName = providerName;
  // tear down the previously initialized stuff ...
  TearDown();
  
	if (port > 0 && IsMultiInstance())
	{
		// the mapping between port and unique login name is stored in the registry.
		PortMappings mappings;
		if (!ReadPortMappings(mappings))
			// TODO: log to event log
			return E_FAIL;

		string name = mappings[port];
		if (name.length() == 0)
			// no mapping found
			// TODO: log to event log
			return Error("Unable to initialize ComVendorKiosk");

			// set the prefix used to make global names unique.
		string appName = name.c_str();

		SetUniquePrefix(appName.c_str());
		SetNameSpace(appName);
	}

  // initialize the VendorKiosk server ...
  if (!mVendorKiosk.Initialize (providerName))
  {
    mIsInitialized = FALSE;
    
    hOK = VENDOR_KIOSK_INITIALIZATION_FAILED;
    buffer = "Vendor Kiosk object cannot be initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
    //	--------------------- Account stuff -------------------------
	// create the COMAccount object
  hOK = CoCreateInstance (CLSID_COMAccount, // CLSID_COMAccountMapper
    0,					  
    CLSCTX_INPROC_SERVER, 
    IID_ICOMAccount, 
    (void**)&mpAccount);
  if (!SUCCEEDED(hOK))
  {
    buffer = "Unable to create instance of Account object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  // initialize the COM account mapper object
  hOK = mpAccount->Initialize();
  if (!SUCCEEDED(hOK))
  {
    TearDown();    
    buffer = "Unable to initialize Account Mapper object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  //	--------------------- Account Mapper stuff -------------------------
  // Get the prog id (which is the tx_acc_mapper member in the C++
  // vendor kiosk class
  _bstr_t bstrAccProgID;
  CLSID cAccClassID;
  
  bstrAccProgID = mVendorKiosk.GetAccMapper().c_str();
  
  // get class id from prog id
  hOK = CLSIDFromProgID (bstrAccProgID, &cAccClassID);
  if (!SUCCEEDED(hOK))
  {
    buffer = "Unable to derive class ID from Prog ID <" + 
	  bstrAccProgID + ">"; 
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  //	Do the CoCreateInstance of the Acc Mapper object here
  //	It takes 5 parameters:
  //	1)	Class ID of the object to be created
  //	2)	Pointer to whether object is or is not part of 
  //		of an aggregate.  0 --> not part of aggregate,
  //		If not null, then pointer to the IUnknown object
  //	3)	Context in which the newly created object will run
  //	4)	Reference to the identifier of the interface
  //	5)	Address of the pointer variable that receives the interface
  //		pointer
  hOK = CoCreateInstance (cAccClassID, // CLSID_COMAccountMapper
    0,					  
    CLSCTX_INPROC_SERVER, 
    IID_ICOMAccountMapper, 
    (void**)&mpAccountMapper);
  
  
  if (!SUCCEEDED(hOK))
  {
    buffer = "Unable to create instance of Account Mapper object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  // initialize the COM account mapper object
  hOK = mpAccountMapper->Initialize();
  if (!SUCCEEDED(hOK))
  {
    TearDown();    
    buffer = "Unable to initialize Account Mapper object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  
  //	----------------------- Kiosk Auth stuff ---------------------------
  
  // Get the prog id (which is the tx_auth_method member in the C++
  // vendor kiosk class
  wstring wstrAuthProgID;
  CLSID cAuthClassID;
  
  wstrAuthProgID = mVendorKiosk.GetAuthMethod();
  
  // get class id from prog id
  hOK = CLSIDFromProgID (wstrAuthProgID.c_str(), &cAuthClassID);
  if (!SUCCEEDED(hOK))
  {
    TearDown();
	buffer = "Unable to derive class ID from Prog ID <" + _bstr_t(wstrAuthProgID.c_str()) + ">";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  //	Do the CoCreateInstance of the KioskAuth object here
  //	It takes 5 parameters:
  //	1)	Class ID of the object to be created
  //	2)	Pointer to whether object is or is not part of 
  //		of an aggregate.  0 --> not part of aggregate,
  //		If not null, then pointer to the IUnknown object
  //	3)	Context in which the newly created object will run
  //	4)	Reference to the identifier of the interface
  //	5)	Address of the pointer variable that receives the interface
  //		pointer
  mpKioskAuth = 0;
  hOK = CoCreateInstance (cAuthClassID, // CLSID_COMKioskAuth
    0,					  
    CLSCTX_INPROC_SERVER, 
    IID_ICOMKioskAuth, 
    (void**)&mpKioskAuth);
  
  
  if (!SUCCEEDED(hOK))
  {
    TearDown();
	buffer = "Unable to create instance of Kiosk Authenticator object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  
  // get the instance of the COM kiosk auth object
  hOK = mpKioskAuth->Initialize();
  if (!SUCCEEDED(hOK))
  {
    TearDown();    
	buffer = "Unable to initialize Kiosk Authenticator object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  mIsInitialized = TRUE;  
  
  return (hOK);
}


// ---------------------------------------------------------------------------
// Description:   This method will get the user config object for a set of
//                credentials.  The credentials are authenticated first.
//                The MPS calls this method to get back user specific
//                information from the database.  The COM user config object
//                is created here and GetConfigInfo is called on it to
//                populate the in memory map.  
// Arguments:     LPDISPATCH - COM credentials object 
// Return Value:  LPDISPATCH - COM user ocnfig object 
// Errors Raised: 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::GetUserConfig(LPDISPATCH pCredentials,
                                            LPDISPATCH* pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  string buffer;
  VARIANT_BOOL bAuthValue;
  BSTR login=NULL;
  BSTR nameSpace=NULL;
  
  if (mIsInitialized == FALSE)
  {
    hOK = VENDOR_KIOSK_INITIALIZATION_FAILED;
	buffer = "Unable to get user config. Not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  //	----------------------- Credentials stuff --------------------------
  // either import the tlb that contains this class or just do typedef
  // ICOMCredentialsPtr comcred(pCredentials);
  // cach for _com_error errors
  ICOMCredentials *pCOMCred = NULL;
  
  // get the interface for the com credentials ...
  hOK = pCredentials->QueryInterface (IID_ICOMCredentials, (void **) &pCOMCred);
  if (!SUCCEEDED(hOK))
  {
	buffer = "Unable to get user credentials interface";
    mLogger->LogThis (LOG_ERROR, buffer.c_str()); 
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }

  //	----------------------- Credentials stuff --------------------------

  //	----------------------- Kiosk Auth stuff ---------------------------
  
  // Get the auth value
  hOK = mpKioskAuth->IsAuthentic(pCredentials, &bAuthValue);
  if (!SUCCEEDED(hOK))
  {
	pCOMCred->get_LoginID(&login);
	_bstr_t bstrLogin (login,false);

    buffer = "Unable to authenticate credentials of user <" + _bstr_t (bstrLogin) + ">";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());

		// release on failure
		if(pCOMCred) pCOMCred->Release();
    return hOK;
  }

  // get the login and namespace ...
  pCOMCred->get_LoginID(&login);
  pCOMCred->get_Name_Space(&nameSpace);

  // copy the parameters ... dont need to do a SysFreeString ... the 
  // _bstr_t will do one when it's destructed ...
  _bstr_t bstrLogin (login,false);
  _bstr_t bstrNamespace (nameSpace,false);

  // release the ref to the credentials ...
  pCOMCred->Release();

  if (VARIANT_TRUE == bAuthValue)
  {
    //	Do the CoCreateInstance here
    //	It takes 5 parameters:
    //	1)	Class ID of the object to be created
    //	2)	Pointer to whether object is or is not part of 
    //		of an aggregate.  0 --> not part of aggregate,
    //		If not null, then pointer to the IUnknown object
    //	3)	Context in which the newly created object will run
    //	4)	Reference to the identifier of the interface
    //	5)	Address of the pointer variable that receives the interface
    //		pointer
    hOK = CoCreateInstance (CLSID_COMUserConfig,
      0,					  
      CLSCTX_INPROC_SERVER, 
      IID_ICOMUserConfig, 
      (void**)pInterface);
    
    if (!SUCCEEDED(hOK))
    {
      pInterface = 0;
      buffer = "Unable to create user config object";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
    
    // Call QueryInterface to receive a pointer to the objects IDispatch 
    // interface pdisp
    ICOMUserConfig *pUserConfig=NULL;
    hOK = (*pInterface)->QueryInterface (IID_ICOMUserConfig, 
      (void**)&pUserConfig);
    
    if (!SUCCEEDED(hOK))
    {
      (*pInterface)->Release();
      pInterface = 0;      
	  buffer = "Unable to get user config interface";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
    
    hOK = pUserConfig->Initialize();
    if (!SUCCEEDED(hOK))
    {
      // release the ref to the user config ...
      pUserConfig->Release();
      (*pInterface)->Release();
      pInterface = 0;      
	  buffer = "Unable to initialize user config object"; 
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }

    hOK = pUserConfig->LoadDefaultUserConfiguration(mExtensionName);
    if (!SUCCEEDED(hOK))
    {
      // release the ref to the user config ...
      pUserConfig->Release();
      (*pInterface)->Release();
      pInterface = 0;      
	  buffer = "Unable to load default user configuration"; 
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
    
    hOK = pUserConfig->GetConfigInfo(bstrLogin, bstrNamespace);
    if (!SUCCEEDED(hOK))
    {
      // release the ref to the user config ...
      pUserConfig->Release();
      (*pInterface)->Release();
      pInterface = 0;
	  buffer = "Unable to get user config info for <" + bstrLogin + ">";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
    // release the ref to the user config ...
    pUserConfig->Release();
  }
  else
  {
    hOK = KIOSK_ERR_INVALID_USER_CREDENTIALS;
	buffer = "Unable to authenticate credentials of user <" +
	  bstrLogin + "> and namespace <" + 
	  bstrNamespace + ">";
    mLogger->LogThis (LOG_WARNING, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  return (hOK);
}
  
// ---------------------------------------------------------------------------
// Description:   This method will get back the site configuration
//                information for a specific language and for a specific
//                provider.  This will include the profile information for a
//                site from the database.
// Arguments:     Language Code - Namespace value to get to a specific site
//                configuration file
// Return Value:  LPDISPATCH - A COM site config object
// Errors Raised: 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::GetSiteConfig(BSTR languageCode,
                                            LPDISPATCH * pInterface)
{
  HRESULT hOK = S_OK;
  string buffer;
  
  //	----------------------- Site Config stuff ---------------------------
  //	Do the CoCreateInstance here
  //	It takes 5 parameters:
  //	1)	Class ID of the object to be created
  //	2)	Pointer to whether object is or is not part of 
  //		of an aggregate.  0 --> not part of aggregate,
  //		If not null, then pointer to the IUnknown object
  //	3)	Context in which the newly created object will run
  //	4)	Reference to the identifier of the interface
  //	5)	Address of the pointer variable that receives the interface
  //		pointer
  hOK = CoCreateInstance (CLSID_COMSiteConfig,  
    0,					  
    CLSCTX_INPROC_SERVER, 
    IID_ICOMSiteConfig, 
    (void**)pInterface);
  
  if (!SUCCEEDED(hOK))
  {
    pInterface = NULL;
	buffer = "Unable to create site config object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  // Call QueryInterface to receive a pointer to the objects IDispatch 
  // interface pdisp
  ICOMSiteConfig *pSiteConfig=NULL;
  hOK = (*pInterface)->QueryInterface (IID_ICOMSiteConfig, 
    (void**)&pSiteConfig);
  
  if (!SUCCEEDED(hOK))
  {
    (*pInterface)->Release();
    pInterface = 0;
	buffer = "Unable to get site config interface";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  _bstr_t nameSpace = mVendorKiosk.GetProviderName().c_str();

  hOK = pSiteConfig->GetConfigInfo(nameSpace, languageCode);
  if (!SUCCEEDED(hOK))
  {
    // release the reference to the site config ...
    pSiteConfig->Release();
    (*pInterface)->Release();
    pInterface = 0;
	buffer = "Unable to get site config info for namespace <" +
       _bstr_t(nameSpace) + "> + language <" + _bstr_t(languageCode) + ">"; 
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  // release the reference to the site config ...
  pSiteConfig->Release();

  return (hOK);
  
}

STDMETHODIMP CCOMVendorKiosk::get_AuthMethod(BSTR * pVal)
{
  HRESULT hOK = S_OK;
  string buffer;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mVendorKiosk.GetAuthMethod().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
	buffer = "Unable to get authentication method. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  return (hOK);
}

#if 0
// ---------------------------------------------------------------------------
// Description:   This method will get all the colors
// Return Value:  LPDISPATCH - A InMemRowset which contains enumeration
//                methods and all the color values 
// Errors Raised: 0xE1400013 - KIOSK_ERR_GET_COLORS_FAILED 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::GetColors(LPDISPATCH * pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  ROWSETLib::IMTInMemRowsetPtr pRowSet;
  string buffer;
  pRowSet = 0;
  
  if (mIsInitialized == TRUE)
  {
    pRowSet = mVendorKiosk.GetColors();
    
    if (pRowSet == 0)
    {
      hOK = KIOSK_ERR_GET_COLORS_FAILED;
	  buffer = "Unable to get colors collection";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
	  return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    buffer = "Unable to get colors collection. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
		
  *pInterface = pRowSet.Detach();
  
  return (hOK);
}
#endif
// ---------------------------------------------------------------------------
// Description:   This method will get all the languages for a specific
//                namespace.  These values come from the site.xml file which
//                resides under <config>\Presserver\<provider>\ folder.
// Arguments:     Namespace - Namespace value to get to a specific site
//                configuration file
// Return Value:  LPDISPATCH - A InMemRowset which contains enumeration
//                methods and all the color values 
// Errors Raised: 0xE1400013 - KIOSK_ERR_GET_LANGUAGE_COLLECTION_FAILED 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::GetLanguageCollection(BSTR aLangCode, LPDISPATCH * pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  ROWSETLib::IMTSQLRowsetPtr pRowSet;
  string buffer;
  pRowSet = 0;
  
  if (mIsInitialized == TRUE)
  {
    pRowSet = mVendorKiosk.GetLanguageCollection(aLangCode);
    
    if (pRowSet == 0)
    {
      hOK = KIOSK_ERR_GET_LANGUAGE_COLLECTION_FAILED;
	  buffer = "Unable to get language collection";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    buffer = "Unable to get language collection. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
		
  *pInterface = pRowSet.Detach();
  
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method will get all the timezones for a specific
//                language.  These timezones are currently stored in an XML
//                file
// Arguments:     LanguageCode - Language code to get that language specific
//                timezones 
// Return Value:  LPDISPATCH - A InMemRowset which contains enumeration
//                methods 
// Errors Raised: 0xE1400014 - KIOSK_ERR_GET_TIMEZONE_FAILED 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::GetTimezone(BSTR langCode, LPDISPATCH * pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  ROWSETLib::IMTInMemRowsetPtr pRowSet;
  string buffer;
  pRowSet = 0;
  
  if (mIsInitialized == TRUE)
  {
    pRowSet = mVendorKiosk.GetTimezone(langCode);
    
    if (pRowSet == 0)
    {
      hOK = KIOSK_ERR_GET_TIMEZONE_FAILED;
	  buffer = "Unable to get timezone collection";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    buffer = "Unable to get timezone collection. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  *pInterface = pRowSet.Detach();
  
  return (hOK);
}




// ---------------------------------------------------------------------------
// Description:   This method will authenticate the credentials
// Arguments:     LPDISPATCH - Credentials object that needs authentication 
// Return Value:  VARIANT_BOOL - True or false 
// Errors Raised: 0xE1400003 - KIOSK_ERR_INVALID_PARAMETER 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::IsAuthentic (	LPDISPATCH pCredentials, 
                                           VARIANT_BOOL* bIsValid)
{
  HRESULT hOK = S_OK;
  string buffer;
  
  // Check for a valid object
  if (pCredentials == 0)
  {
    hOK = KIOSK_ERR_INVALID_PARAMETER;
    buffer = "Unable to check for authenticity";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  // Get the auth value
  hOK = mpKioskAuth->IsAuthentic(pCredentials, bIsValid);
  if (!SUCCEEDED(hOK))
  {
    *bIsValid = VARIANT_FALSE;
    hOK = KIOSK_ERR_IS_AUTHENTIC;
	buffer = "Check for authenticity failed";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method will add an entry to the MPS tables.  This
//                method is the only one exposed to the user through either
//                the CSR app or the pipeline.  MPS or the pipeline
//                instantiates this object and calls this method by passing
//                in the account specific information.  The Add calls are
//                made to the COM account, COM account mapper, COM kiosk
//                auth, and the COM user config objects.
// Arguments:     Credentials - A COM credentials object that contains the
//                login, password and namespace combination
//                Language - Language associated with the user 
//                AccountType - Where Bill-To or Ship-To 
//                TariffID - Unique identifier to be used for rating
//                Geocode - A Long value dependent on city/state/zip and
//                used for rating
//                TaxExemptFlag - Y or N flag for tax exempt purposes
//                TimezoneID - timezone ID unique to the user
//                TimezoneOffset - timezone offset corresponding to the 
//                timezone ID 
//                PaymentMethod - 1 --> None, 2 --> Credit Card 
//                pRowset - A rowset object that manages transactions
// Return Value:  LPDISPATCH - A user config object that gets created
// Errors Raised: 0xE140000B - VENDOR_KIOSK_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::AddUser (LPDISPATCH pCredentials, 
																			 long AccountStatus,
																			 BSTR aLanguage,
																			 long TimezoneID,
																			 LPDISPATCH pRowset, LPDISPATCH* pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  long lAcctID;
  string buffer;
  
  if (mIsInitialized == FALSE)
  {
    hOK = VENDOR_KIOSK_INITIALIZATION_FAILED;
	buffer = "Unable to add user. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }

  //	----------------------- Credentials stuff --------------------------
  ICOMCredentials *pCOMCred;
  
  BSTR login;
  BSTR pwd;
  BSTR name_space;
  
  // get the interface for the credentials object ... 
  hOK = pCredentials->QueryInterface (IID_ICOMCredentials, (void **) &pCOMCred);
  if (!SUCCEEDED(hOK))
  {
	buffer = "Unable to get interface for credentials";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  // get the info from the credentials ...
  pCOMCred->get_LoginID(&login);
  pCOMCred->get_Pwd(&pwd);
  pCOMCred->get_Name_Space(&name_space);

  // copy the parameters ... dont need to do a SysFreeString ... the 
  // _bstr_t will do one when it's destructed ...
  _bstr_t bstrLogin (login,false);
  _bstr_t bstrPwd (pwd,false);
  _bstr_t bstrNamespace (name_space,false);

  // release the ref ...
  pCOMCred->Release();
  
  //	----------------------- Credentials stuff --------------------------

  //	------------------------- Account stuff ----------------------------
  lAcctID = mpAccount->Add(AccountStatus, pRowset);
  if (!SUCCEEDED(hOK))
  {
	buffer = "Unable to add account through account object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    pInterface = NULL;
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
	//	------------------------- Account stuff ----------------------------
  
  //	--------------------- Account Mapper stuff -------------------------
  hOK = mpAccountMapper->Add(bstrLogin, bstrNamespace, lAcctID, pRowset);
  if (!SUCCEEDED(hOK))
  {
    string buffer;
    if (hOK == KIOSK_ERR_ACCOUNT_ALREADY_EXISTS)
    {
      buffer = "Account already exists for " + bstrLogin + " and namespace " + bstrNamespace;
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      pInterface = NULL;
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
    else
    {
      buffer = "Unable to add " + bstrLogin + " and " + bstrNamespace + " via account mapper";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      pInterface = NULL;
      return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
    }
  }
  //	--------------------- Account Mapper stuff -------------------------

  //	----------------------- Kiosk Auth stuff ---------------------------
  hOK = mpKioskAuth->AddUser(bstrLogin, bstrPwd, bstrNamespace, pRowset);
  if (!SUCCEEDED(hOK))
  {
	buffer = "Unable to add account through authenticator object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }

  //	----------------------- Kiosk Auth stuff ---------------------------
  
  //	----------------------- User Config stuff ---------------------------
  //	Do the CoCreateInstance here
  //	It takes 5 parameters:
  //	1)	Class ID of the object to be created
  //	2)	Pointer to whether object is or is not part of 
  //		of an aggregate.  0 --> not part of aggregate,
  //		If not null, then pointer to the IUnknown object
  //	3)	Context in which the newly created object will run
  //	4)	Reference to the identifier of the interface
  //	5)	Address of the pointer variable that receives the interface
  //		pointer
  hOK = CoCreateInstance (CLSID_COMUserConfig,  
    0,					  
    CLSCTX_INPROC_SERVER, 
    IID_ICOMUserConfig, 
    (void**)pInterface);
  if (!SUCCEEDED(hOK))
  {
    buffer = "Unable to create user config object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    pInterface = NULL;
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  // get the interface for the com user config ...
  ICOMUserConfig *pCOMUserConfig;
  
  hOK = (*pInterface)->QueryInterface (IID_ICOMUserConfig, (void **) &pCOMUserConfig);
  if (!SUCCEEDED(hOK))
  {
    buffer = "Unable to get user config interface";
    (*pInterface)->Release();
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }

  // initialize the user config object ...
  hOK = pCOMUserConfig->Initialize();
  if (!SUCCEEDED(hOK))
  {
    pCOMUserConfig->Release();
    (*pInterface)->Release();
	buffer = "Unable to initialize user config object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }

  // add the user ...
  string strLogin = (const char*) _bstr_t(login);
  string strNameSpace = (const char*) _bstr_t(name_space);
  hOK = pCOMUserConfig->Add(login, name_space, aLanguage, lAcctID, TimezoneID, pRowset);
  if (!SUCCEEDED(hOK))
  {
    pCOMUserConfig->Release();
    (*pInterface)->Release();
    return Error ("Unable to add user config info", IID_ICOMVendorKiosk, hOK);
  }
  // release the ref 
  pCOMUserConfig->Release();

  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method will add only a logon to the MetraTech account
//                table.  The Add methods are called on the COM kiosk auth,
//                COM user config and COM user config objects.  A rowset
//                object is created in this mathod for maintaining
//                transactional integrity.
// Arguments:     Login - User name or login ID
//                Name_space - Namespace uniquely identifying the account
//                Password - Password to be stored for authentication
//                Language - Language to be associated with the account
//                AccountID - MetraTech generated account ID
// Errors Raised: 0xE140000B - VENDOR_KIOSK_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMVendorKiosk::AddPresServerLogon (BSTR Logon, 
												  BSTR Name_Space, 
												  BSTR Password, 
												  BSTR Language, 
												  long AccountID)
{
	Error("Deprecated; use MTAccountUtils.MTCreateAcount.1 object");
	return E_NOTIMPL;
}

STDMETHODIMP CCOMVendorKiosk::GetDefaultAuthenticationNamespace(BSTR *pVal)
{
  HRESULT hOK = S_OK;
  string buffer;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mVendorKiosk.GetAuthNamespace().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
	  buffer = "Unable to get authentication namespace. Object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMVendorKiosk, hOK);
  }
  
  return (hOK);
}
