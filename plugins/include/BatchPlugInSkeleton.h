/**************************************************************************
 * @doc BATCHPLUGINSKELETON
 *
 * @module |
 *
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
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | BATCHPLUGINSKELETON
 ***************************************************************************/

#ifndef _BATCHPLUGINSKELETON_H
#define _BATCHPLUGINSKELETON_H

#include <PlugInSkeleton.h>
#include <mtcomerr.h>
#include <transact.h>						// for ITransaction

_COM_SMARTPTR_TYPEDEF(ITransaction, __uuidof(ITransaction));

template <class T, const CLSID* pclsid,	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTBatchPipelinePlugIn : 
  public MTPipelinePlugIn<T, pclsid, ThreadModel>
{
public:
	MTBatchPipelinePlugIn() :
		mDatabaseInitialized(FALSE),
		mIsRetrySafe(FALSE),
		mIsOracle(FALSE)
	{ }

protected:
	MTPipelineLib::IMTLogPtr mLogger;

private:
	BOOL mDatabaseInitialized;
	BOOL mIsRetrySafe;
	BOOL mIsOracle;

private:
	HRESULT ReinitializeDatabase();

protected:
	// if a plug-in is read-only, then it is safe to retry
	// if a plug-in is write/read then it probably isn't safe
	void AllowRetryOnDatabaseFailure(BOOL aAllow) 
	{ mIsRetrySafe = aAllow; }

	BOOL IsOracle()
	{ return mIsOracle; }


protected:

	// Configures the plugin in this order:
	//  1. calls BatchPlugInConfigure
	//  2. calls BatchPlugInInitializeDatabase
	//  3. sets mDatabaseInitialized to TRUE
	// NOTE: all ODBC exceptions are caught and logged
	HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
													MTPipelineLib::IMTConfigPropSetPtr aPropSet,
													MTPipelineLib::IMTNameIDPtr aNameID,
													MTPipelineLib::IMTSystemContextPtr aSysContext);


	// Processes the session set in this order:
	//  1. if the database is not initialized, attempts the following:
	//       a. calls BatchPlugInShutdownDatabase
	//       b. calls BatchPlugInInitializeDatabase
	//       c. sets mDatabaseInitialized to TRUE
	//       d. on failure, attempts the following up to two times:
	//            i. goto step a.
	//       e. on final failure:
	//            i.  sets mDatabaseInitialized to FALSE
	//            ii. fails the session set
	//  2. calls BatchPlugInProcessSessions
	//  3. on failure, attempts the following up to three times (if it is safe to retry):
	//       a. calls BatchPlugInShutdownDatabase
	//       b. calls BatchPlugInInitializeDatabase
	//       c. sets mDatabaseInitialized to TRUE
	//       d. goto step 2.
	//  4. on final failure:
	//       a. sets mDatabaseInitialized to FALSE
	//       b. fails the session set
	HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);


	// Shuts down the plugin in this order:
	//  1. calls BatchPlugInShutdown
	//  2. calls BatchPlugInShutdownDatabase
	//  3. sets mDatabaseInitialized to FALSE
	// NOTE: all ODBC exceptions are caught and logged
  HRESULT PlugInShutdown();

	// not used with batch plugins
  HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
	{
		ASSERT(0);
		return E_NOTIMPL;
	}


protected:

	// general plugin configuration
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			 MTPipelineLib::IMTNameIDPtr aNameID,
																			 MTPipelineLib::IMTSystemContextPtr aSysContext) = 0;

	// database specific configuration
	// i.e., opening connections, preparing statements, etc... 
	virtual HRESULT BatchPlugInInitializeDatabase() = 0;

	// processes the session set
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet) = 0;

	// general plugin shutdown
	virtual HRESULT BatchPlugInShutdown()	{ return S_OK; }

	// cleans up database specific state
	// NOTE: statements should be released before connections
	virtual HRESULT BatchPlugInShutdownDatabase() = 0;

public:
	_bstr_t GetTagName(MTPipelineLib::IMTSystemContextPtr aSysContext) const;

	// return the transaction object of the pipeline if
	//  - a transaction has already been started
	//  - a transaction will be started (transaction ID is set)
	virtual MTPipelineLib::IMTTransactionPtr GetTransaction(MTPipelineLib::IMTSessionPtr aSession);
};


template <class T, const CLSID* pclsid,	class ThreadModel>
HRESULT MTBatchPipelinePlugIn<T, pclsid, ThreadModel>
::ReinitializeDatabase()
{
	HRESULT hr;

	mDatabaseInitialized = FALSE;
	
	hr = BatchPlugInShutdownDatabase();
	if (FAILED(hr))
		return hr;
	
	hr = BatchPlugInInitializeDatabase();
	if (FAILED(hr))
		return hr;

	mDatabaseInitialized = TRUE;

	return S_OK;
}


template <class T, const CLSID* pclsid,	class ThreadModel>
HRESULT MTBatchPipelinePlugIn<T, pclsid, ThreadModel>
::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
									MTPipelineLib::IMTConfigPropSetPtr aPropSet,
									MTPipelineLib::IMTNameIDPtr aNameID,
									MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	// keeps a logger around
	mLogger = aLogger;
	
	// are we running oracle?
	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

	mDatabaseInitialized = FALSE;
	
	try 
	{
		HRESULT hr = BatchPlugInConfigure(aLogger, aPropSet, aNameID, aSysContext);
		if (FAILED(hr))
			return hr;
		
		hr = BatchPlugInInitializeDatabase();
		if (FAILED(hr))
			return hr;
	} 
	catch (COdbcException & e) 
	{
		HRESULT hr = e.getErrorCode();
		
		// error should have a FAILED error code
		if (SUCCEEDED(hr))
		{
			ASSERT(0); 
			hr = E_FAIL;
		}
		
		_bstr_t buffer = "ODBC exception caught in PlugInConfigure: ";
		buffer += e.toString().c_str();
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
		
		return hr;
	}

	mDatabaseInitialized = TRUE;

	return S_OK;
}

template <class T, const CLSID* pclsid,	class ThreadModel>
HRESULT MTBatchPipelinePlugIn<T, pclsid, ThreadModel>
::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	HRESULT hr;
		
	// the database may have been marked as needing re-initialization
	// from a previously failed PlugInProcessSessions
	if (!mDatabaseInitialized)
	{
		// try twice
		for (int i = 1; i <= 2; i++) 
		{
			try 
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Re-initializing database");
				ReinitializeDatabase();
				// TODO: should HRESULT also be checked?

				break;
			}
			catch(COdbcException & e)
			{
				hr = e.getErrorCode();
					
				// error should have a FAILED error code
				if (SUCCEEDED(hr))
				{
					ASSERT(0); 
					hr = E_FAIL;
				}
					
				// returns failed HRESULT if this is the second (last) attempt
				if (i == 2)
				{
					_bstr_t buffer = "ODBC exception caught in PlugInProcessSessions: ";
					buffer += e.toString().c_str();
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Could not re-initialize database!");
					return hr;
				}
				else
				{
					// otherwise, logs the exception and tries again
					_bstr_t buffer = "ODBC exception caught in PlugInProcessSessions: ";
					buffer += e.toString().c_str();
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buffer);
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "Could not re-initialize database, trying again!");
				}
			}
		}
	}
		

	// executes the main BatchPlugInProcessSessions method.
	// if an ODBCException is thrown, catch it and mark the
	// database uninitialized. Attempt this three times. If
	// the third time fails, then fail the set. 
	for (int i = 1; i <= 3; i++) 
	{
		try
		{
			if (!mDatabaseInitialized)
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Re-initializing database");
				ReinitializeDatabase();
				// TODO: should HRESULT also be checked?
			}

			hr = BatchPlugInProcessSessions(aSet);
			return hr;
		}
		catch(COdbcException & e)
		{
			hr = e.getErrorCode();
				
			// error should have a FAILED error code
			if (SUCCEEDED(hr))
			{
				ASSERT(0);
				hr = E_FAIL;
			}

			// marks the database as needing to be re-initialized next time
			mDatabaseInitialized = FALSE;

			// don't retry if its not safe to (i.e., in plug-ins which write to the db)
			if (!mIsRetrySafe)
			{
				_bstr_t buffer = "ODBC exception caught in PlugInProcessSessions: ";
				buffer += e.toString().c_str();
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);

				return Error((const wchar_t *) buffer, IID_IMTPipelinePlugIn, hr);
			}

			// returns failed HRESULT if this is the third (last) attempt
			if (i == 3)
			{
				_bstr_t buffer = "ODBC exception caught in PlugInProcessSessions: ";
				buffer += e.toString().c_str();
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
													 "Three attempts to process have failed, failing session set!");
				return Error((const wchar_t *) buffer, IID_IMTPipelinePlugIn, hr);
			}
				
			// the exception is interpreted as a potential database connectivity issue
			_bstr_t buffer = "ODBC exception caught in PlugInProcessSessions: ";
			buffer += e.toString().c_str();
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buffer);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "Attempting to process session set again");
		}
	}

	// should never get here!
	ASSERT(0);
	return S_OK;
}

template <class T, const CLSID* pclsid,	class ThreadModel>
HRESULT MTBatchPipelinePlugIn<T, pclsid, ThreadModel>
::PlugInShutdown()
{
	HRESULT hr;
	try 
	{
		hr = BatchPlugInShutdown();
		if (FAILED(hr))
			return hr;

		hr = BatchPlugInShutdownDatabase();
		if (FAILED(hr))
			return hr;

		mDatabaseInitialized = FALSE;

		return S_OK; 
	} 
	catch (COdbcException & e) 
	{
		HRESULT hr = e.getErrorCode();

		// error should have a FAILED error code
		if (SUCCEEDED(hr))
		{
			ASSERT(0); 
			hr = E_FAIL;
		}

		_bstr_t buffer = "ODBC exception caught in PlugInShutdown: ";
		buffer += e.toString().c_str();
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);

		return hr;
	}
}

template <class T, const CLSID* pclsid,	class ThreadModel>
_bstr_t MTBatchPipelinePlugIn<T, pclsid, ThreadModel>::GetTagName(
	MTPipelineLib::IMTSystemContextPtr aSysContext) const
{
	//MTPipelineLib::IMTConfigFilePtr configFile = aSysContext->GetEffectiveConfig();
	//string configFilename = configFile->GetConfigFilename();

	//// the config filename will look something like this:
	//// r:\extensions\pcsample\config\pipeline\PITest\pcratelookup.xml

	//int lastDot = configFilename.rfind('.');
	//if (lastDot == string::npos)
	//	MT_THROW_COM_ERROR("Invalid config filename");

	//int lastSlash = configFilename.rfind('\\', lastDot - 1);
	//if (lastSlash == string::npos)
	//	MT_THROW_COM_ERROR("Invalid config filename");

	//int secondLastSlash = configFilename.rfind('\\', lastSlash - 1);
	//if (secondLastSlash == string::npos)
	//	MT_THROW_COM_ERROR("Invalid config filename");

	//string stage = configFilename.substr(secondLastSlash + 1, (lastSlash - 1) - (secondLastSlash + 1) + 1);
	//string plugin = configFilename.substr(lastSlash + 1, (lastDot - 1) - (lastSlash + 1) + 1);

	wchar_t compNameBuffer[100];
	DWORD compNameLength = sizeof(compNameBuffer) / sizeof(compNameBuffer[0]);
	if (!::GetComputerName(compNameBuffer, &compNameLength))
		MT_THROW_COM_ERROR("Unable to get computer name");

	// according to the doc:
	//   The standard character set includes letters, numbers,
	//   and the following symbols: ! @ # $ % ^ & ' ) ( . - _ { } ~ 

	for (int i = 0; compNameBuffer[i] != L'\0'; i++)
	{
		switch (compNameBuffer[i])
		{
		case L'!':
		case L'@':
		case L'#':
		case L'$':
		case L'%':
		case L'^':
		case L'&':
		case L'\'':
		case L')':
		case L'(':
		case L'.':
		case L'-':
		case L'_':
		case L'{':
		case L'}':
		case L'~':
			compNameBuffer[i] = '_';
			break;
		}
	}

  MTPipelineLib::IMTLogPtr logger(aSysContext);
  string s_pluginTag = logger->ApplicationTag;

  s_pluginTag.erase(s_pluginTag.begin());
  s_pluginTag.erase(s_pluginTag.end() - 1);

	_bstr_t compName = compNameBuffer;
	_bstr_t tag = (s_pluginTag + "_").c_str()  + compName;
	return tag;
}

template <class T, const CLSID* pclsid,	class ThreadModel>
MTPipelineLib::IMTTransactionPtr
MTBatchPipelinePlugIn<T, pclsid, ThreadModel>::GetTransaction(MTPipelineLib::IMTSessionPtr aSession)
{
	MTPipelineLib::IMTTransactionPtr tran = NULL;

	// has a transaction already been started?
	tran = aSession->GetTransaction(VARIANT_FALSE);

	if (tran != NULL)
	{
		// yes
		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// is the transaction ID set in the session?  If so we're working on
	// an external transaction
	_bstr_t txnID = aSession->GetTransactionID();
	if (txnID.length() > 0)
	{
		// join the transaction
		tran = aSession->GetTransaction(VARIANT_TRUE);

		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// no transaction
	return NULL;
}



#endif /* _BATCHPLUGINSKELETON_H */


