/**************************************************************************
	* @doc TRANSACTIONCONFIG
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
	* documentation shall at all times remain with MetraTech Corporation,
	* and USER agrees to preserve the same.
	*
	* Created by: Jiang Chen
	*
	* $Date$
	* $Author$
	* $Revision$
****************************************************************************/

#include <metralite.h>
#include <transactionconfig.h>
#include <loggerconfig.h>
#include <SetIterate.h>
#include <sdk_msg.h>
#include <stdutils.h>

#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;

TRANS_CONFIG_EXPORT CTransactionConfig * CTransactionConfig::GetInstance()
{
	return MTSingleton<CTransactionConfig>::GetInstance();
}

TRANS_CONFIG_EXPORT void CTransactionConfig::ReleaseInstance()
{
	MTSingleton<CTransactionConfig>::ReleaseInstance();
}

BOOL CTransactionConfig::Init()
{
// First to get the log object first
	BOOL bRetVal = TRUE;

	LoggerConfigReader cfgRdr;

	bRetVal = mLogger.Init(cfgRdr.ReadConfiguration("logging\\"), "[TransactionConfig]");

	return bRetVal;
}

TRANS_CONFIG_EXPORT const CTransactionConfig & CTransactionConfig::operator = (const CTransactionConfig & rhs)
{
	return (*this);
}

TRANS_CONFIG_EXPORT CTransactionConfig::~CTransactionConfig()
{
}

TRANS_CONFIG_EXPORT BOOL CTransactionConfig::GetEncodedWhereAbouts(const string & servername, string & whereabouts)
{

	if(mWhereAboutsMap.find(servername) == mWhereAboutsMap.end())
	{
		mLogger.LogVarArgs(LOG_DEBUG, "WhereAbouts for server '%s' not in cache. Querying server...", servername.c_str());
		
		if(!SetWhereAbouts(servername))
		{
			string buffer;
			buffer = "Unable the get the whereabouts in CTransactionConfig::GetEncodedWhereAbouts";
			mLogger.LogThis(LOG_ERROR, buffer.c_str());
			return FALSE;
		}
		if(mWhereAboutsMap.find(servername) == mWhereAboutsMap.end())
		{
			//should never happened.
			ASSERT(0);
			return FALSE;
		}
		else
		{
			whereabouts = mWhereAboutsMap[servername];
			return TRUE;
		}
	}
	else
	{
		whereabouts = mWhereAboutsMap[servername];
		return TRUE;
	}
}


BOOL CTransactionConfig::SetWhereAbouts(string aServerName)
{

	// For wherwabouts, it is complex, we do synchronous metering
	// to get the encodedwhereabouts;

	const char * procName = "CTransactionConfig::SetWhereAbouts";

	HRESULT hOK = S_OK;
	string buffer;
	// Initialize the mMeter object

	MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
	hOK = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");

	if(!SUCCEEDED(hOK))
	{
		buffer = "Unable to create instance of MTServerAccessDataSet object in CTransactionConfig::SetWhereAbouts";
		mLogger.LogThis(LOG_ERROR, buffer.c_str());
		return FALSE;
	}
	
	hOK = mtdataset->Initialize();
	if(!SUCCEEDED(hOK))
	{
		buffer = "Initialize method failed on MTServerAccessDataSet object in CTransactionConfig::SetWhereAbouts";
		mLogger.LogThis(LOG_ERROR, buffer.c_str());
		return FALSE;
	}

	long count = 0;
	mtdataset->get_Count(&count);

	if(count == 0)
	{
		buffer = "No record found in the MTServerAccessDataSet object in CTransactionConfig::SetWhereAbouts";
		mLogger.LogThis(LOG_ERROR, buffer.c_str());
	}

	SetIterator<MTSERVERACCESSLib::IMTServerAccessDataSetPtr, 
		MTSERVERACCESSLib::IMTServerAccessDataPtr> it;
	HRESULT hr = it.Init(mtdataset);

	if (FAILED(hr))
	{
		buffer = "Cannot initialize the MTServerAccessDataSetPtr iterator"; 
		mLogger.LogThis(LOG_ERROR, buffer.c_str());
		return FALSE;
	}
	
	string servertype;
	string servername;
	int portnumber;
	int secure;
	string username;
	string password;
	int DTCenabled;
	BOOL Found = FALSE;

	while(TRUE)
	{
		MTSERVERACCESSLib::IMTServerAccessDataPtr data = it.GetNext();
		if(data == NULL)
			break;
		servertype = (const char *) data->GetServerType();
		servername = (const char *) data->GetServerName();
		portnumber = data->GetPortNumber();
		secure = data->GetSecure();
		username = (const char *) data->GetUserName();
		password = (const char *) data->GetPassword();
		DTCenabled = data->GetDTCenabled();

		if(0 == strcasecmp<string>(servertype,aServerName))
		{
			Found = TRUE;
			if(!DTCenabled)
			{
				buffer = "DTC is not enabled in servers.xml for the given entry: " + aServerName;
				mLogger.LogThis(LOG_ERROR, buffer.c_str());
				return FALSE;
			}


			if(!mMeter.Startup())
			{
				buffer = "Could not initilize the SDK in CTransactionConfig:SetWhereAbouts";
				mLogger.LogThis(LOG_ERROR, buffer.c_str());
				return FALSE;
			}

			mHttpConfig.AddServer(
				0,                                // priority (highest)
				servername.c_str(),
				portnumber,
				(BOOLEAN) secure,
				username.c_str(),  
				password.c_str()  
				);

			MTMeterSession * session = mMeter.CreateSession("metratech.com/DTCGetWhereAbouts");
			
			if(!session->InitProperty("WhereAboutsCookie", ""))
			{
				mLogger.LogThis(LOG_ERROR, "Could not initialize the property on the session");
				delete session;
				mMeter.Shutdown();
				return FALSE;
			}
			
			// set mode to synchronous
			session->SetResultRequestFlag();

			// TODO: retry count should be configurable somewhere!
			int MAX_RETRIES = 20;
			for (int retry = 0; retry < MAX_RETRIES; retry++)
			{
				if(!session->Close())
				{
					MTMeterError * err = session->GetLastErrorObject();
					if (err->GetErrorCode() == MT_ERR_SYN_TIMEOUT)
						mLogger.LogVarArgs(LOG_ERROR, "Timeout waiting for response on attempt %d... retrying", retry + 1);
					else if (err->GetErrorCode() == MT_ERR_SERVER_BUSY)
						mLogger.LogVarArgs(LOG_ERROR, "Server busy on attempt %d... retrying", retry + 1);
					else
					{
						delete session;
						mLogger.LogThis(LOG_ERROR, "Could not meter/close the session");

						if (err)
						{
							int size = 0;
							err->GetErrorMessage((char *) NULL, size);
							char * msgbuf = new char[size + 1];
							err->GetErrorMessage(msgbuf, size);

							size = 0;
							err->GetErrorMessageEx((char *) NULL, size);
							char * msgexbuf = new char[size];
							err->GetErrorMessageEx(msgexbuf, size);
							mLogger.LogVarArgs(LOG_ERROR, "%s: %s", msgbuf, msgexbuf);

							delete [] msgbuf;
							delete [] msgexbuf;
							delete err;
						}
						return FALSE;
					}
				}
				else
					// success!
					break;
			}

			if (retry == MAX_RETRIES)
				return FALSE;

			MTMeterSession * results = session->GetSessionResults();
			ASSERT(results);
			
			// may there is a problem here. 
			const char *  wherestring;
			results->GetProperty("WhereAboutsCookie", &wherestring);

			mLogger.LogVarArgs(LOG_DEBUG, "WhereAboutsCookie retrieved (Find) = <%s>", wherestring);
			
			string whereabouts = wherestring;

			// put it into the whereabouts map
			mWhereAboutsMap.insert(WhereAboutsMap::value_type(aServerName, whereabouts));

			delete session;
			mMeter.Shutdown();
			return TRUE;
		}
	} 
	
	mLogger.LogVarArgs(LOG_ERROR, "Could not find server '%s' in servers.xml", aServerName.c_str());
	return Found;
}



