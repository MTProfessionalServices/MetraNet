/**************************************************************************
 * Copyright 2004 by MetraTech Corporation
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
 ***************************************************************************/

/***************************************************************************
 * BatchCopyAccountProperties.h                                                 *
 * Header for BatchCopyAccountProperties.cpp -- Plugin for copying properties   *
 *                                         from one account or template    *
 *                                         to another account.             *
 ***************************************************************************/

#ifndef _BATCHCOPYACCOUNTPROPERTIES_H
#define _BATCHCOPYACCOUNTPROPERTIES_H

#include <BatchPlugInSkeleton.h>
#include <autoptr.h>
#include <mtprogids.h>
#include <vector>
#include <map>

#include <OdbcException.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcResourceManager.h>

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTAccount.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.DataAccess.tlb> //inject_statement("using namespace mscorlib;")

//----- Using string and maps.
using std::string;

/***************************************************************************
 *																		   *
 * BatchCopyAccountProperties UUID = D7095C82-1AA4-45eb-A3FB-EE6EE9F1F82C      *
 *																		   *
 ***************************************************************************/
CLSID CLSID_MTBATCHCOPYACCOUNTPROPERTIES = {
	0xd7095c82,
	0x1aa4,
	0x45eb,
	{ 0xa3, 0xfb, 0xee, 0x6e, 0xe9, 0xf1, 0xf8, 0x2c }
};

//----- Typedefs                                                                *
typedef enum
{
	COPY_PROP_TYPE_SESSION = 0,
	COPY_PROP_TYPE_EXTENSION = 1,
} CopyPropType;

typedef enum
{
	QT_INSERT = 0,
	QT_UPDATE = 1,
} SqlQueryType;
#define QT_ARRAY_SIZE 2

struct MTCopyProperty
{
	CopyPropType PropType;
	_bstr_t SourceProperty;
	_bstr_t SourceExtension;
	_bstr_t DestinationProperty;
	_bstr_t DestinationExtension;
	bool Required;
	bool PartOfKey;
};

typedef vector<MTCopyProperty *> MTPropertyNameVector;
typedef std::map<_bstr_t, _bstr_t> MTExtensionNameMap;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;


//----- Specify the default batch size to use for processing batch records.
#define DEFAULT_BCP_BATCH_SIZE	1000

//----- Plugin class
class ATL_NO_VTABLE CMTBatchCopyAccountPropertiesPlugin
	: public MTBatchPipelinePlugIn<CMTBatchCopyAccountPropertiesPlugin, &CLSID_MTBATCHCOPYACCOUNTPROPERTIES>
{
	public:
		CMTBatchCopyAccountPropertiesPlugin()
			:	mlngDestinationPropID(-1),
				mUseBcpFlag(false),
        mbSessionsFailed(false),
				mArraySize(0)
		{
			/* Do nothing here */
		}

	protected:

		//-----
		// BatchPlugInConfigure() is called when the plug-in is being loaded.
		// All COdbcExceptions are caught by the caller of this method.
		//-----
		virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
											 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
											 MTPipelineLib::IMTNameIDPtr aNameID,
											 MTPipelineLib::IMTSystemContextPtr aSysContext);

		//-----
		// BatchPlugInInitializeDatabase() is called after BatchPlugInConfigure() is called
		// when the plug-in is being loaded.  It may be called multiple times, especially
		// if the database connection is lost.  BatchPlugInShutdownDatabase() will always
		// be called before BatchPlugInInitializeDatabase() is called a second time.  
		// All COdbcExceptions are caught by the caller of this method.
		//-----
		virtual HRESULT BatchPlugInInitializeDatabase();

		//-----
		// BatchPlugInShutdownDatabase() is called after BatchPlugInShutdown() is called
		// when the plug-in is being shut down.  It is also called if a connection error
		// has occured in order to clean things up before attempting to reconnect.  It may
		// be called multiple times, especially if the database connection is lost.
		// BatchPlugInShutdownDatabase() will always be called after
		// BatchPlugInInitializeDatabase() has been called.  
		// All COdbcExceptions are caught by the caller of this method.
		//-----
		virtual HRESULT BatchPlugInShutdownDatabase();

		//----- All COdbcExceptions are caught by the caller of this method.
		virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr);

		//-----
		// BatchPlugInShutdown() is called when the plug-in is being shutdown.
		// All COdbcExceptions are caught by the caller of this method.
		//-----
		virtual HRESULT BatchPlugInShutdown();

	private:
		//----- Property meta data map.
		typedef std::map<int, MTACCOUNTLib::IMTPropertyMetaDataPtr> PropertyMetadataMap;

		//----- Extension properties map.
		typedef std::map<_bstr_t, PropertyMetadataMap*> ExtensionPropertiesMap;
		ExtensionPropertiesMap mExtensionPropertiesMap;

		//----- Update queries map.
		typedef vector<string> SQLQueryVector;
		typedef std::map<_bstr_t, SQLQueryVector> ExtensionQueryMap;
		ExtensionQueryMap mExtensionQueryMap;
			// Map of SQL statements used to update and insert from
			// temp table to destination table. Also used to copy from 
			// from source table to destination table.

		//----- Dynamically generates queries. Queries used to create temp table and to
		//----- copy from temp table to destination tables.
		HRESULT GenerateQueries(COdbcConnectionInfo& NetMeterDBInfo, COdbcConnectionInfo& stageDBInfo);

		//----- Process a batch or sessions, some set smaller than the passed in session set.
		HRESULT ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& sessionArray, COdbcConnectionHandle & netMeterConnection);

		//----- Insert array of data records into temp table.
		template <class T>
		HRESULT InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
							        T insertStmtPtr);

	private:
		long mlngDestinationPropID;               // Property containing the ID of the target
		MTPropertyNameVector mCopyProperties;     // Properties to copy
		MTExtensionNameMap mDestExtensions;       // Map of source extension names

		//------ SQL query strings; set in GenerateQueries()
		string mstrCreateTempTableSQL;		  // Used to create the temp table
		string mstrInsertIntoTempTableSQL;	  // Used to insert array values into temp table
		string mstrTruncateTmpTableSQL;

		//----- Temp table names used in the staging database.
		string mTagName;
		string mTmpTableName;
		string mTmpTableFullName;

		//----- TRUE by default, uses BCP for inserts into temp table 
		bool mUseBcpFlag;

    //----- FALSE by default, indicates that some sessions had errors.
    bool mbSessionsFailed;

		//----- Number os sessions to process at one time from a given session set.
		int mArraySize;
  
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
		boost::shared_ptr<COdbcConnectionCommand> mNetMeterDbConnectionCommand;  // NetMeter db connection
  	boost::shared_ptr<COdbcConnectionCommand> mStageDbBcpConnectionCommand;  // Stage db connection, for temp table BCPing
		boost::shared_ptr<COdbcPreparedBcpStatementCommand> mBcpInsertToTmpTableStmtCommand;
		boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertToTmpTableStmtCommand;
		boost::shared_ptr<COdbcPreparedArrayStatementCommand> mSqlArrayInsertToTmpTableStmtCommand;

		//----- Retrieve queries.
		QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter;

		//-----
		MTPipelineLib::IMTNameIDPtr mNameID;
		MTPipelineLib::IMTSystemContextPtr mSysContext;
};

//----- ProgId declaration
PLUGIN_INFO(CLSID_MTBATCHCOPYACCOUNTPROPERTIES,
            CMTBatchCopyAccountPropertiesPlugin,
            "MetraPipeline.MTCopyAccountProperties.1",
            "MetraPipeline.MTCopyAccountProperties",
            "Free")

#endif /* _BATCHCOPYACCOUNTPROPERTIES_H */

//-- EOF --
