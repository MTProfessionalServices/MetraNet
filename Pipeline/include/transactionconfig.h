/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Jiang Chen
 * $Header$
 * 
 * 	TransactionConfig.h : 
 *	--------------
 *	This is the header file of the TransactionConfig class.
 *
 ***************************************************************************/

#ifndef _TRANSACTIONCONFIG_H_
#define _TRANSACTIONCONFIG_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )

// some of control paths as no return;
#endif //  WIN32

//	All the includes


#include <mtsdk.h>
#include <comdef.h>

#include "MTSingleton.h"

#include "NTLogger.h"

#include <map>
#include <string>

using namespace std;

#include <mtprogids.h>
#include <mtparamnames.h>


// TODO: remove undefs
#if defined(TRANS_CONFIG_DEF)
#define TRANS_CONFIG_EXPORT __declspec(dllexport)
#else
#define TRANS_CONFIG_EXPORT __declspec(dllimport)
#endif


// Need to change this to _declspec every member rather than the whole
// class



class CTransactionConfig:
	public virtual ObjectWithError,
	private MTSingleton<CTransactionConfig>
{
public:
	// CR: check whether need it or not 
	TRANS_CONFIG_EXPORT static CTransactionConfig * GetInstance();
	TRANS_CONFIG_EXPORT static void ReleaseInstance();
  
  // @cmember Initialize the CTransactionConfig object
	BOOL Init();
  
	// CTransactionConfig (const CTransactionConfig & C);	
  
  // Assignment operator
	TRANS_CONFIG_EXPORT const CTransactionConfig & CTransactionConfig::operator=(const CTransactionConfig & rhs);

//	string GetEncodedWhereAbouts(string stagename);

	TRANS_CONFIG_EXPORT BOOL GetEncodedWhereAbouts(const string & stagename, string & whereabouts);

	TRANS_CONFIG_EXPORT CTransactionConfig() : mMeter(mHttpConfig){}; //default destructor should do as little as possible

	TRANS_CONFIG_EXPORT virtual ~CTransactionConfig();

private:
		// method to build the associations between the IDs and values
	BOOL SetWhereAbouts(string);


	typedef map<string, string> WhereAboutsMap;

	typedef WhereAboutsMap::iterator WhereAboutsMapIterator;

	WhereAboutsMap mWhereAboutsMap;

	WhereAboutsMapIterator mWhereAboutsMapIterator;


	NTLogger mLogger;


	MTMeterHTTPConfig mHttpConfig;
	MTMeter mMeter;

};

#endif //_TRANSACTIONCONFIG_H_

