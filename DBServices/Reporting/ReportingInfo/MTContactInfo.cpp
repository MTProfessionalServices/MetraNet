// MTContactInfo.cpp : Implementation of CMTContactInfo
#include "StdAfx.h"
#include "ReportingInfo.h"
#include "MTContactInfo.h"
#include <mtprogids.h>
#include <loggerconfig.h>
#include "ReportingDefs.h"
#include <DBConstants.h>
#include <mtparamnames.h>
#include <SetIterate.h>
#include <DBMiscUtils.h>
#include <DataAccessDefs.h>

// TODO : remove this ...
const char * const CONTACT_COMPANY = "company" ;
#define MTPARAM_COMPANY L"%%COMPANY%%"

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib  ;
#import <MTLDAPLib.tlb> no_namespace

/////////////////////////////////////////////////////////////////////////////
// CMTContactInfo
CMTContactInfo::CMTContactInfo()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), DBSVCS_TAG) ;
}

CMTContactInfo::~CMTContactInfo()
{
}

STDMETHODIMP CMTContactInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTContactInfo
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTContactInfo::Add()
{
  _variant_t vtEOF, vtValue, vtIndex ;
  _variant_t vtParam ;
  long nAcctID ;
  BOOL bRetCode = TRUE ;

  try
  {
    Remove() ;
  }
  catch (...)
  {
  }
	try
  {
    // create the rowset to get all the accounts ...
    IMTSQLRowsetPtr acctRowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    acctRowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__GET_ALL_ACCOUNTS__" ;
    acctRowset->SetQueryTag (queryTag) ;

    // execute the query ...
    acctRowset->Execute() ;

    // if we do not have any accounts ....
    if ((acctRowset->GetRecordCount()) == 0)
    {
      mLogger.LogVarArgs (LOG_ERROR,
        "Unable to get the account list") ;
      return Error ("Unable to get the account list", 
        IID_IMTReportingView, E_FAIL) ;
    }

    // create the rowset to insert the contact info with ...
    IMTSQLRowsetPtr insertRowset(MTPROGID_SQLROWSET);
    
    // initialize the rowset ...
    configPath =  REPORTING_CONFIGDIR ;
    insertRowset->Init(configPath) ;
    
    // set the query tag ...
    queryTag = "__INSERT_CONTACT_INFO__" ;

    // iterate thru the accounts ...
    acctRowset->get_RowsetEOF(&vtEOF) ;
    while ((vtEOF.boolVal != VARIANT_TRUE))
    {
      // get the tablesuffix ...
      vtIndex = DB_ACCOUNT_ID;
      acctRowset->get_Value (vtIndex, &vtValue) ;
      nAcctID = vtValue.lVal ;

      // call GetContactInfo to get the name, addr1, addr2, addr3, 
      // city, state, zip and country ... info is passed thru data members to not
      // incur the overhead of passing things on the stack ...
      bRetCode = GetContactInfo (nAcctID) ;
      if (bRetCode == FALSE)
      {
        mLogger.LogVarArgs (LOG_WARNING,
          "Unable to get contact info for Account with id = %d", nAcctID) ;
      }
      // we got the contact info ... insert it to the database ...
      else
      {
        try
        {
          // clear the insert rowset ...
          insertRowset->Clear() ;
          
          // set the query tag ...
          insertRowset->SetQueryTag (queryTag) ;
          
          // add the parameters ...
          vtParam = (long) nAcctID ;
          insertRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
          vtParam = mName ;
          insertRowset->AddParam (MTPARAM_NAME, vtParam) ;
          vtParam = mAddr1 ;
          insertRowset->AddParam (MTPARAM_ADDR1, vtParam) ;
          vtParam = mAddr2 ;
          insertRowset->AddParam (MTPARAM_ADDR2, vtParam) ;
          vtParam = mAddr3 ;
          insertRowset->AddParam (MTPARAM_ADDR3, vtParam) ;
          vtParam = mCity ;
          insertRowset->AddParam (MTPARAM_CITY, vtParam) ;
          vtParam = mState ;
          insertRowset->AddParam (MTPARAM_STATE, vtParam) ;
          vtParam = mZip ;
          insertRowset->AddParam (MTPARAM_ZIP, vtParam) ;
          vtParam = mCountry ;
          insertRowset->AddParam (MTPARAM_COUNTRY, vtParam) ;
          vtParam = mCompany ;
          insertRowset->AddParam (MTPARAM_COMPANY, vtParam) ;
          
          // execute the query ...
          insertRowset->Execute() ;
        }
        catch (_com_error e)
        {
          mLogger.LogVarArgs (LOG_ERROR, 
            "Unable to insert contact information to database. Error = %x.", e.Error()) ;
          mLogger.LogVarArgs (LOG_ERROR, 
            "Add() failed. Error Description = %s", (char*)e.Description()) ;
          return Error ("Unable to insert contact information to database", 
            IID_IMTContactInfo, e.Error()) ;
        }
      }

      // move to the next record ...
      acctRowset->MoveNext() ;
      acctRowset->get_RowsetEOF(&vtEOF) ;
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to add contact information to database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Add() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to add contact information to database", 
      IID_IMTContactInfo, e.Error()) ;
  }  

	return S_OK;
}

STDMETHODIMP CMTContactInfo::Remove()
{
	// start the try ...
  try
  {
    // create the rowset ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__REMOVE_CONTACT_INFO__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to remove contact information from database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to remove contact information from database", 
      IID_IMTContactInfo, e.Error()) ;
  }

	return S_OK;
}

BOOL CMTContactInfo::GetContactInfo (const long &arAcctID)
{
  HRESULT nRetVal = S_OK ;
  long numContacts=0 ;
  string strFirstName, strMiddle, strLastName ;
  string strAddr1, strAddr2, strAddr3 ;
  string strCity, strState, strZip, strCountry ;
  string strAcctType, strCompany ;
  BOOL bGotBillTo=FALSE ;

  try 
  {
    // create and initialize the ldap object ...
    IMTLDAPImplPtr ldapServer (MTPROGID_LDAP_IMPL);
    nRetVal = ldapServer->Initialize() ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to initialize account server. Error = %x", nRetVal) ;
      return FALSE ;
    }
        
    // retrieve the contact info ...
    nRetVal = ldapServer->RetrieveContact(arAcctID);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to retrieve contact information. Error = %x", nRetVal) ;
      return FALSE;
    }

    // get the number of contact info data sets ...
    numContacts = ldapServer->GetCount();
    if (numContacts == 0)
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get account info. No contact information.") ;
      return FALSE ;
    }
    // we have contact info ... iterate thru it
    else
    {
      // initialize the iterator ....
      SetIterator<IMTLDAPImplPtr, IMTLDAPDataSetPtr> dsIter;
      nRetVal = dsIter.Init(ldapServer);
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR, 
          "Unable to initialize contact data set iterator. Error = %x", nRetVal) ;
        return FALSE ;
      }
      // iterate thru the data set(s) ...      
      while (TRUE)
      {
        IMTLDAPDataSetPtr dataSet = dsIter.GetNext();

        // if we do not have anymore datasets ... exit ...
        if ((dataSet == NULL) || (bGotBillTo == TRUE))
        {
          break;
        }
        
        // get the distinguished name ...
        _bstr_t DN;
        DN = dataSet->GetDN();
        
        // initialize the iterator for the data set elements
        SetIterator<IMTLDAPDataSetPtr, IMTLDAPDataPtr> dseIter;
        HRESULT hr = dseIter.Init(dataSet);
        if (!SUCCEEDED(nRetVal))
        {
          mLogger.LogVarArgs (LOG_ERROR, 
            "Unable to initialize contact data set element iterator. Error = %x", nRetVal) ;
          return FALSE ;
        }
        
        while (TRUE)
        {
          IMTLDAPDataPtr dataElement = dseIter.GetNext();
          
          // if we do not have anymore data elements ... exit ...
          if (dataElement == NULL)
          {
            break;
          }

          // get the attribute ...
          string attribute;
          attribute = dataElement->GetAttribute();

          // if the attribute is the account type ...
          if (stricmp(attribute.c_str(), CONTACT_ACCOUNT_TYPE) == 0)
          {
            strAcctType = dataElement->GetValue();
            // if this is the bill to info set flag ...
            if (stricmp(strAcctType.c_str(), CONTACT_BILL_TO) == 0)
            {
              bGotBillTo = TRUE ;
            }
            else
            {
              if (bGotBillTo == FALSE)
              {
                strFirstName = "" ;
                strMiddle = "" ;
                strLastName = "" ;
                strAddr1 = "" ;
                strAddr2 = "" ;
                strAddr3 = "" ;
                strCity = "" ;
                strState = "" ;
                strZip = "" ;
                strCountry = "" ;
              }
              // break out ... 
            }
          }
          // if the attribute is the first name ...
          else if (stricmp(attribute.c_str(), CONTACT_FIRST_NAME) == 0)
          {
            strFirstName = dataElement->GetValue();
          }
          // else if the attribute is the middle initial ...
          else if (stricmp(attribute.c_str(), CONTACT_MIDDLE_INIT) == 0)
          {
            strMiddle = dataElement->GetValue(); 
          }
          // else if the attribute is the last name ...
          else if (stricmp(attribute.c_str(), CONTACT_LAST_NAME) == 0)
          {
            strLastName = dataElement->GetValue();
          }
          // else if the attribute is the address1 ... 
          else if (stricmp(attribute.c_str(), CONTACT_ADDR1) == 0)
          {
            strAddr1 = dataElement->GetValue();
          }
          // else if the attribute is the address2 ...
          else if (stricmp(attribute.c_str(), CONTACT_ADDR2) == 0)
          {
            strAddr2 = dataElement->GetValue();
          }
          // else if the attribute is the address3 ...
          else if (stricmp(attribute.c_str(), CONTACT_ADDR3) == 0)
          {
            strAddr3 = dataElement->GetValue();
          }
          // else if the attribute is the city ...
          else if (stricmp(attribute.c_str(), CONTACT_CITY) == 0)
          {
            strCity = dataElement->GetValue();
          }
          // else if the attribute is the state ...
          else if (stricmp(attribute.c_str(), CONTACT_STATE) == 0)
          {
            strState = dataElement->GetValue();
          }
          // else if the attribute is the zip ...
          else if (stricmp(attribute.c_str(), CONTACT_ZIP) == 0)
          {
            strZip = dataElement->GetValue();
          }
          // else if the attribute is the country ...
          else if (stricmp(attribute.c_str(), CONTACT_COUNTRY) == 0)
          {
            strCountry = dataElement->GetValue();
          }
          // else if the attribute is the company ...
          else if (stricmp(attribute.c_str(), CONTACT_COMPANY) == 0)
          {
            strCompany = dataElement->GetValue();
          }

        }
        // if we got the bill to info ... create the strName, strStreet, strCityState ...
        if (bGotBillTo == TRUE)
        {
          // assign the data members ...
          string strName = strFirstName + " " + strMiddle + " " + strLastName ;
          mName = strName.c_str() ;
          mAddr1 = strAddr1.c_str() ;
          mAddr2 = strAddr2.c_str() ;
          mAddr3 = strAddr3.c_str() ;
          mCity = strCity.c_str() ;
          mState = strState.c_str() ;
          mZip = strZip.c_str() ;
          mCountry = strCountry.c_str() ;
          mCompany = strCompany.c_str() ;
        }
      }
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get contact information. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR,
      "GetContactInfo() failed. Error Description = %s", (char*)e.Description()) ;
    return FALSE ;
  }

  return TRUE;
}

STDMETHODIMP CMTContactInfo::Create()
{
  try
  {
    Drop() ;
  }
  catch(...)
  {
  }
	// start the try ...
  try
  {
    // create the rowset ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    // initialize the rowset ...
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__CREATE_CONTACT_INFO_TABLE__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create contact information table in database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create query. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to create contact information table in database", 
      IID_IMTContactInfo, e.Error()) ;
  }

  return S_OK;
}

STDMETHODIMP CMTContactInfo::Drop()
{
  IMTSQLRowsetPtr rowset;

  // start the try
  try
  {
    // initialize the rowset ...    
    HRESULT nRetVal = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the contact info. Rowset Create() failed.Error = %x", nRetVal) ;
      return Error ("Unable to drop the contact info. Rowset Create() failed.", 
        IID_IMTContactInfo, E_FAIL) ;
    }
    _bstr_t configPath =  REPORTING_CONFIGDIR ;
    rowset->Init(configPath) ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to drop the contact info. Rowset Init() failed.Error = %x", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Remove() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop the contact info. Rowset Init() failed.", 
          IID_IMTContactInfo, E_FAIL) ;
  }

  // get the dbtype ...
  wstring wstrDBType = rowset->GetDBType() ;

  // if the dbtype is Oracle do not delete the views ...
  if (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0)
  {
    try
    {
      // set the query tag
      _bstr_t queryTag = "__FIND_TABLE__" ;
      rowset->SetQueryTag (queryTag) ;

      // add the parameter
      _variant_t vtParam ;
      vtParam = L"T_CONTACT_INFO" ;
      rowset->AddParam (MTPARAM_TABLENAME, vtParam) ;

      // execute the query ...
      rowset->Execute() ;

      _variant_t vtEOF = rowset->GetRowsetEOF() ;
      if (vtEOF.boolVal == VARIANT_FALSE)
      {
        // get the table name ...
        _variant_t vtValue = rowset->GetValue (((_variant_t) L"TableName")) ;
        
        // if the value != param then continue
        if (vtValue != vtParam)
        {
          return S_OK ;
        }
      }
      else
      {
        return S_OK ;
      }
    }
    catch (_com_error e)
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to find the contact info.Error = %x", e.Error()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        "Remove() failed. Error Description = %s", (char*)e.Description()) ;
      return Error ("Unable to find the contact info. Rowset Init() failed.", 
        IID_IMTContactInfo, E_FAIL) ;
    }
  }

	// start the try ...
  try
  {
    // set the query tag ...
    _bstr_t queryTag = "__DROP_CONTACT_INFO_TABLE__" ;
    rowset->SetQueryTag (queryTag) ;

    // execute the query ...
    rowset->Execute() ;
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to drop contact information table in database. Error = %x.", e.Error()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create query. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to drop contact information table in database", 
      IID_IMTContactInfo, e.Error()) ;
  }

  return S_OK;
}

