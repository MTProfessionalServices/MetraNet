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
 * BatchAudit.h				                                               *
 * Header for BatchAudit.cpp -- Plugin for inserting audit records into    *
 *                              database.						           *
 ***************************************************************************/

#ifndef _BATCHAUDIT_H
#define _BATCHAUDIT_H

#include <BatchPlugInSkeleton.h>
#include <OdbcException.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcResourceManager.h>

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;


//----- Using strings.
using std::string;

//----- BatchAudit UUID: E17B2A26-6089-4ed0-905C-DD5F310073ED
CLSID CLSID_MTBATCHAUDIT = {
	0xe17b2a26,
	0x6089,
	0x4ed0,
	{ 0x90, 0x5c, 0xdd, 0x5f, 0x31, 0x0, 0x73, 0xed }
};

//----- Specify the default batch size to use for processing batch records.
#define DEFAULT_BCP_BATCH_SIZE	1000

/***************************************************************************
 * Plugin class                                                            *
 ***************************************************************************/
class ATL_NO_VTABLE CMTBatchAuditPlugin
	:	public MTBatchPipelinePlugIn<CMTBatchAuditPlugin, &CLSID_MTBATCHAUDIT>
{
	public:
		CMTBatchAuditPlugin()
			:	m_bUseBcpFlag(false),
        m_bSessionsFailed(false),
				m_uiArraySize(0),
  			m_lAuditEventID(-1),
				m_lAuditEntityTypeID(-1),
				m_lAuditEntityID(-1),
				m_lAuditDetailsID(-1)
		{
			/* Do nothing here */
		}

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

		//----- Insert array of data records into temp table.
		template <class T>
		HRESULT InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
                                T insertStmtPtr,
                                COdbcConnectionPtr connection,
                                COdbcConnectionHandle & stageConnection);

    //----- Generate queries.
    void GenerateQueries(string& AuditTableName,
                         string& AuditDetailsTableName,
                         const char* stagingDBName);

	private:

		//----- Temp table names used in the staging database.
		string m_strTagName;
		string m_strTmpTableName;
		string m_strTmpTableFullName;
    string m_strCreateTempTableSQL;

		//----- TRUE by default, uses BCP for inserts into temp table 
		bool m_bUseBcpFlag;

    //----- FALSE by default, indicates that some sessions had errors.
    bool m_bSessionsFailed;

		//----- Number os sessions to process at one time from a given session set.
		unsigned int m_uiArraySize;

		//------ SQL query strings.
		string m_strTruncateTmpTableSQL;
		string m_strUpdateAuditTableSQL;
		string m_strUpdateDetailsTableSQL;

		//----- NetMeter db connection
    MTAutoSingleton<COdbcResourceManager> m_OdbcManager;
    boost::shared_ptr<COdbcConnectionCommand> m_StageDbBcpConnectionCommand;  // Stage db connection, for temp table BCPing

		//----- Retrieve queries.
		QUERYADAPTERLib::IMTQueryAdapterPtr m_QueryAdapterAC;
		QUERYADAPTERLib::IMTQueryAdapterPtr m_QueryAdapterPipe;

		//----- Used to insert data into database.
		boost::shared_ptr<COdbcPreparedBcpStatementCommand> m_BcpInsertToTempTableStmtCommand;
		boost::shared_ptr<COdbcPreparedInsertStatementCommand> m_OracleArrayInsertToTempTableStmtCommand;
		boost::shared_ptr<COdbcPreparedArrayStatementCommand> m_SqlArrayInsertToTempTableStmtCommand;

		//----- Property ID's for our data.
  	long m_lAuditEventID;
		long m_lAuditEntityTypeID;
		long m_lAuditEntityID;
		long m_lAuditDetailsID;

};

//----- Plug-in name definition.
PLUGIN_INFO(CLSID_MTBATCHAUDIT,
            CMTBatchAuditPlugin,
            "MetraPipeline.MTAuditPluginWriter.1",
            "MetraPipeline.MTAuditPluginWriter",
            "Free")

#endif /* _BATCHAUDIT_H */

//-- EOF --
