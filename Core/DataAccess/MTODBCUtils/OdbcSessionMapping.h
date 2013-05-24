/**************************************************************************
* Copyright 1997-2006 by MetraTech
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
* $Header$
* 
***************************************************************************/

#ifndef _ODBCSESSIONMAPPING_H_
#define _ODBCSESSIONMAPPING_H_

#include "OdbcColumnMetadata.h"
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")
#import <MTEnumConfigLib.tlb> 
#import <MetraTime.tlb> 
#include "OdbcConnection.h"
#include "OdbcIdGenerator.h"
#include <mtglobal_msg.h>
#include "NTLogger.h"
#include "loggerconfig.h"
#include <DBAccess.h>
#include <boost/shared_ptr.hpp>
#include "OdbcResourceManager.h"

#ifndef DB_BOOLEAN_TRUE_A
#define DB_BOOLEAN_TRUE_A  "1"
#endif

#ifndef DB_BOOLEAN_FALSE_A
#define DB_BOOLEAN_FALSE_A "0"
#endif

#ifndef DB_UID_SIZE
#define DB_UID_SIZE 16
#endif

class COdbcColumnMetadata;
class COdbcStagingTable;
class COdbcStatement;
class COdbcConnection;
class CMSIXDefinition;

// Stuff for shared session implementation
class CSessionWriterSession;
class SharedSessionHeader;
class SharedSessionMappedViewHandle;
class PipelineInfo;

#include <MSIXProperties.h>
#include <MSIX.h>
#include <sharedsess.h>
#include <MTDecimalVal.h>
#include <MTDec.h>

#include "OdbcSessionRouter.h"

#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcPreparedBcpStatement.h"
#include "OdbcException.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"
#include "OdbcSessionTypeConversion.h"
#include "DistributedTransaction.h"
#include <OdbcStagingTable.h>

// Stuff for shared session impl.
#include "OdbcSessionWriterSession.h"

std::string& PropertyError(long aPropId, std::string& arMessage);

/////////////////////////////////////////////////////
// Mapping of session properties to the parameters of an
// ODBC prepared insert statement (of either BCP or Array Insert type)
/////////////////////////////////////////////////////
template<class STATEMENT>
class COdbcSessionPropertyMapping
{
private:
	int mSessionId;
	int mColumnPosition;
	OdbcSqlDatatype mType;
	bool mNullable;
	CMSIXProperties::PropertyType mMSIXType;
	MSIXPropertyValue* mDefaultVal;
	
	// Guarantee that the DB type and the MSIX type are compatible
	// with one another.  At least warn if they are not because it
	// might imply a performance hit.
	void ValidateType();

	COdbcSessionPropertyMapping(int aSessionId,
															int aColumnPosition,
															OdbcSqlDatatype aType,
															bool aNullable,
															CMSIXProperties::PropertyType aMSIXType,
															MSIXPropertyValue * apDefaultVal);

	void ApplyDefault(STATEMENT* aStatement);
	
public:
	~COdbcSessionPropertyMapping();

	// Factory interface for creation.  I may want to implement subclassing instead of a switch statement
	static COdbcSessionPropertyMapping<STATEMENT>* Create(int aSessionId,
																												int aColumnPosition,
																												OdbcSqlDatatype aType,
																												bool aNullable,
																												CMSIXProperties::PropertyType aMSIXType,
																												MSIXPropertyValue * apDefaultVal = NULL);
	
	// Write the property from the shared session to the statement.  Perform conversion and reformatting as necessary.
	virtual void WriteSessionProperty(CSessionWriterSession* aSession, 
																		STATEMENT* aStatement);
};

/////////////////////////////////////////////////////
// COdbcSessionStatementWriter - Writes part of a Metratech
// session to persistent storage
/////////////////////////////////////////////////////
class COdbcSessionStatementWriter
{
public:
	virtual ~COdbcSessionStatementWriter() {}

	// Copy all properties from the session into the corresponding
	// ODBC prepared statement.  Not all properties of the session
	// will be copied.

	virtual void BeginBatch() =0;
	virtual void WriteSession(__int64 sessionId, CSessionWriterSession* aSession)=0;
	virtual void WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession)=0;
	virtual int ExecuteBatch() =0;
	virtual void EndBatch() =0;
	virtual double GetTotalExecuteMillis() =0;
};

/////////////////////////////////////////////////////
// COdbcSessionMappings
// a collection of objects that map session properties
// to database columns.
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
class COdbcSessionMappings
{
private:
	vector<MAPPING*> mMappings;

public:
	void WriteMappedProperties(CSessionWriterSession* aSession,
														 STMT * apStatement);

	void AddMapping(MAPPING * apMapping)
	{ mMappings.push_back(apMapping); }

	void Clear()
	{
		for (int i = 0; i < (int) mMappings.size(); i++)
			delete mMappings[i];
		mMappings.clear();
	}
};

// Template meta function to get command from statement.
template <class T>
struct COdbcCommandType 
{
  typedef COdbcPreparedBcpStatementCommand type;
  static void GetStatementCommands(boost::shared_ptr<type> command,
                                   std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& bcpStatements,
                                   std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& arrayStatements,
                                   std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& insertStatements)
  {
    bcpStatements.push_back(command);
  }
};

template <>
struct COdbcCommandType <class COdbcPreparedArrayStatement>
{
  typedef COdbcPreparedInsertStatementCommand type;
  static void GetStatementCommands(boost::shared_ptr<type> command,
                                   std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& bcpStatements,
                                   std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& arrayStatements,
                                   std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& insertStatements)
  {
    insertStatements.push_back(command);
  }
};

/////////////////////////////////////////////////////
// COdbcSessionWriterBase - 
// Basic implementation of a session writer.
// used as a base class for other session writers
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
class COdbcSessionWriterBase : public COdbcSessionStatementWriter
{
protected:
	// this must be set up in the constructor
	boost::shared_ptr<typename COdbcCommandType<STMT>::type > mStatementCommand;

  boost::shared_ptr<COdbcConnectionCommand> mConnectionCommand;

  MTAutoSingleton<COdbcResourceManager> mOdbcManager;

  // Connection handle: created in BeginBatch and freed in EndBatch
  boost::shared_ptr<COdbcConnectionHandle> mConnectionHandle;

  // The database statement object: created in BeginBatch and freed in EndBatch
  STMT * mStatementObject;

	bool mInitialized;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
	
protected:
	// mappings between session properties and database columns
	COdbcSessionMappings<STMT, MAPPING> mMappings;

	// helper function to write the current time to a column
	void WriteDateCreated(int aColumn, CSessionWriterSession* aSession);

	// helper function to return the pipeline property ID
	// given a "special" column name
	static int GetSpecialPropertySessionId(const string & arColumnName);

	// helper function to convert a default value
	BOOL ConvertDefault(const CMSIXProperties * apProperty,
											MSIXPropertyValue ** apDefaultVal);
	
	void TearDown();

protected:
	// number of sessions within each batch ID
	std::map<std::wstring, int> mBatchCounts;

  void AddStatementCommand(const COdbcConnectionInfo & info,
                           boost::shared_ptr<typename COdbcCommandType<STMT>::type > stmt)
  {
    mStatementCommand = stmt;
    std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
    std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
    std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;
    GetStatementCommands(bcpStatements, arrayStatements, insertStatements);
    mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
      new COdbcConnectionCommand(info,
                                 COdbcConnectionCommand::TXN_AUTO,
                                 bcpStatements.size() > 0,
                                 bcpStatements,
                                 arrayStatements,
                                 insertStatements));

    mOdbcManager->RegisterResourceTree(mConnectionCommand);
  }

  STMT * GetStatement()
  {
    if (mStatementObject == NULL)
    {
      mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>(new COdbcConnectionHandle(mOdbcManager, mConnectionCommand));
      mStatementObject = (*mConnectionHandle)[mStatementCommand];
      mStatementObject->BeginBatch();
    }
    return mStatementObject;
  }

private:
  METRATIMELib::IMetraTimeClientPtr mMetraTime;

	// update the mBatchCounts map
	void UpdateBatchIDs(CSessionWriterSession* aSession);

	void WriteBatchIDs();

	void ClearBatchCounts()
	{ mBatchCounts.clear(); }
		
	// return true if at least one session had a batch ID set
	bool UsingBatchIDs() const
	{ return (mBatchCounts.size() > 0); }

	BOOL AttemptDefaultConversion(const CMSIXProperties * apProperty,
																MSIXPropertyValue * apDefaultVal);

public:
	COdbcSessionWriterBase();
	virtual ~COdbcSessionWriterBase();
	
	void BeginBatch()
	{	
		ClearBatchCounts();
//     mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>(new COdbcConnectionHandle(mOdbcManager, mConnectionCommand));
//     mStatementObject = (*mConnectionHandle)[mStatementCommand];
// 		mStatementObject->BeginBatch();
	}

	void WriteSession(__int64 sessionId, CSessionWriterSession* aSession);
	void WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession);
	int ExecuteBatch();
  void EndBatch()
  {
    mStatementObject = NULL;
    mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
  }
	double GetTotalExecuteMillis();
  void GetStatementCommands(std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& bcpStatements,
                            std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& arrayStatements,
                            std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& insertStatements)
  {
    COdbcCommandType<STMT>::GetStatementCommands(mStatementCommand, bcpStatements, arrayStatements, insertStatements);
  }
};


/////////////////////////////////////////////////////
// COdbcSessionAccUsageWriter - 
// Write reserved session "underscore" parameters into
// t_acc_usage.
/////////////////////////////////////////////////////
template<class STMT, class MAPPING>
class COdbcSessionAccUsageWriter : public COdbcSessionWriterBase<STMT, MAPPING>
{
protected:
	int mIdSessColumnPos;
	int mIdParentSessColumnPos;
	int mIdDtCrt;
	string mAccUsageName;

public:
	void SetUp(const COdbcConnectionInfo & aConnectionInfo);
	inline const char* GetAccUsageName() { return mAccUsageName.c_str(); }

protected:
	MAPPING * MapAccUsageColumn(const COdbcColumnMetadata * apMetaData);

public:
	COdbcSessionAccUsageWriter(const COdbcConnectionInfo & aConnectionInfo, const char* szAccUsageName = NULL);

	void WriteSession(__int64 sessionId, CSessionWriterSession* aSession);
	void WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession);
};

/////////////////////////////////////////////////////
// COdbcSessionProductViewWriter - 
// Writes configurable product view parameter properties
// to an underlying product view database table
/////////////////////////////////////////////////////
template<class STMT, class MAPPING>
class COdbcSessionProductViewWriter : public COdbcSessionWriterBase<STMT, MAPPING>
{
private:
	int mIdSessColumnPos;
	
public:
	void SetUp(const COdbcConnectionInfo& aConnectionInfo,
						 CMSIXDefinition* apProductView, MTPipelineLib::IMTNameIDPtr aNameID);
						 
public:
	COdbcSessionProductViewWriter();
	
	void WriteSession(__int64 sessionId, CSessionWriterSession* aSession);
	void WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession);
};


/////////////////////////////////////////////////////
// COdbcSessionFullTableWriter - 
// Writes configurable acc usage and product view parameter properties
// to a single table
/////////////////////////////////////////////////////
template<class STMT, class MAPPING>
class COdbcSessionFullTableWriter : public COdbcSessionWriterBase<STMT, MAPPING>
{
private:
	int mIdSessColumnPos;
	int mIdParentSessColumnPos;
	int mIdDtCrt;

public:
	void SetUp(const COdbcConnectionInfo& aConnectionInfo,
						 CMSIXDefinition* apProductView, MTPipelineLib::IMTNameIDPtr aNameID);
						 
public:
	COdbcSessionFullTableWriter();
	
	void WriteSession(__int64 sessionId, CSessionWriterSession* aSession);
	void WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession);
};


/////////////////////////////////////////////////////
// COdbcSessionWriter - 
// Public/external interface to the session writers
/////////////////////////////////////////////////////

class COdbcSessionWriter
{
private:
	vector<COdbcSessionStatementWriter*> mWriters;
	COdbcLongIdGenerator* mGenerator;
	map<__int64, long> mSessionMap;

protected:
	CMSIXDefinition* mpProductView;
	string mTableName;

	BOOL mIsInitialized;

	// Sessions flushed to the staging table.
 	int mCurrentSessionsInBatch;

	// Sessions in the statement buffers (not yet flushed to staging tables).
 	int mCurrentSessionsInBuffer;

  // Is data metered (arguably this should just be either the predicate
  // (mCurrentSessionsInBuffer > 0 || mCurrentSessionsInBatch > 0) 
  // or the predicate
  // (mCurrentSessionsInBatch > 0) 
	bool mIsDataMetered;

	// Call EndBatch automatically if true.
	// EndBatch will be called after ExecuteBatch.
	bool mAutoEndBatch;
	void EnableAutoEndBatch(bool bEnable = true)
	{
		mAutoEndBatch = bEnable;
	}

private:
	__int64 mTotalCheckRequiredTicks;
	__int64 mTotalApplyDefaultsTicks;
	__int64 mTotalWriteSessionPropertiesTicks;
	__int64 mTicksPerSec;

protected:
	void AddWriter(COdbcSessionStatementWriter* aWriter)
	{
		mWriters.push_back(aWriter);
	}

	// For any values which have not yet been set, set defaults
	void ApplyDefaults(CSessionWriterSession* aSession);

	// Make sure that all required properties are set
	void CheckRequired(CSessionWriterSession* aSession);

	SharedSessionHeader* mpHeader;

	// Set string and long properties used to set error info on failed session.
	void SetStringProperty(SharedSession* sess, long aPropId, const wchar_t * aStringVal);
	void SetLongProperty(SharedSession* sess, long aPropId, long aLongVal);

	// Find the failed sessions in set and mark them as failed.
	void UpdateFailedSessions(COdbcConnection* conn,
							ConstarintQueryPtr& query);
  
	// Fail all the sessions due to ODBC error
	void FailAllSessions(COdbcException &ex)
	{
		map<__int64, long>::const_iterator iter = mSessionMap.begin();
		map<__int64, long>::const_iterator end = mSessionMap.end();

		for(; iter != end; ++iter)
		{
			SharedSession* sess = mpHeader->GetSession((*iter).second);
			SetStringProperty(sess, PipelinePropIDs::ErrorStringCode(), _bstr_t(ex.getMessage().c_str()));
			// ESR-2953 error message for t_failed_transaction.tx_errorcodemessage
			SetLongProperty(sess, PipelinePropIDs::ErrorCodeCode(), DB_ERR_ODBC_ERROR);
			sess->MarkRootAsFailed(mpHeader);
		}
	};

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the generated database ID is returned
	__int64 WriteSession(CSessionWriterSession* aSession);

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the generated database ID is returned
	__int64 WriteChildSession(__int64 aParentId, CSessionWriterSession* aSession);

	int GetCurrentSessionsInBatch() { return mCurrentSessionsInBatch; }
	int GetCurrentSessionsInBuffer() { return mCurrentSessionsInBuffer; }

	// set up this writer.  Called when an attempt is made to write the first
	// session.
	virtual void Setup() {}

public:
	COdbcSessionWriter(COdbcLongIdGenerator* aGenerator,
										 SharedSessionHeader* apHeader);

	virtual ~COdbcSessionWriter();

	// The largest number of sessions that will be batched before
	// flushing out to the database.
	virtual int GetMaxBatchSize() const=0;

	// Called before first session written. 
	// Gives objects an opportunity to (re)intialize batch state
	virtual void BeginBatch();

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the generated database ID is returned.
	virtual __int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession);

	// Write a child session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the generated database ID is returned.
	virtual __int64 WriteChildSession(__int64 aParentId,
									  MTPipelineLib::IMTSessionPtr aSession);

	// Although the session writer will execute batches once 
	// maxBatchSize sessions have been added, clients can also
	// force an execute themselves.
	virtual int ExecuteBatch();

	// By default this method calls EndBatch on underlying writers, but it also gives caller
	// an opportunity to do some post batch processing.
	// This call will be automatically executed immediately after ExecuteBatch.
	// Do disable the default exectution, call EnableAutoEndBatch(false)
	virtual void EndBatch();

	// Update the internal session map for specific session.
	void UpdateSessionMap(__int64 id_sess, MTPipelineLib::IMTSessionPtr aSession)
	{
		mSessionMap[id_sess] = aSession->GetSessionID();
	}

	// return TRUE if this writer has been initialized
	BOOL IsInitialized() const
		{ return mIsInitialized; }

	// Return true if data was metered.
	bool IsDataMetered() const
		{ return mIsDataMetered; }

	// Return table name the writer is writing to.
	wstring GetTableName() const
		{ return wstring(_bstr_t(mTableName.c_str())); }

public:

	// Performance information.  Total time executing query batches
	double GetTotalExecuteMillis();

	// Total number of milliseconds spent checking required properties
	double GetTotalCheckRequiredMillis() const;

	// Total number of milliseconds spent setting default values
	double GetTotalApplyDefaultsMillis() const;

	// Total number of milliseconds spent actually writing session properties
	double GetTotalWriteSessionPropertiesMillis() const;
};

/////////////////////////////////////////////////////
//
// BCP implementation
//
/////////////////////////////////////////////////////

// PropertyMapping to bind session properties to a BCP statement
typedef COdbcSessionPropertyMapping<COdbcPreparedBcpStatement>
  COdbcBcpSessionPropertyMapping;

/////////////////////////////////////////////////////
// COdbcBcpSessionAccUsageWriter - 
// Write reserved session "underscore" parameters into
// t_acc_usage.
/////////////////////////////////////////////////////
class COdbcBcpSessionAccUsageWriter :
	public COdbcSessionAccUsageWriter<COdbcPreparedBcpStatement,
	COdbcBcpSessionPropertyMapping>
{
  public:
	  COdbcBcpSessionAccUsageWriter(const COdbcConnectionInfo& aConnectionInfo)
		  : COdbcSessionAccUsageWriter<COdbcPreparedBcpStatement,
		  COdbcBcpSessionPropertyMapping>(aConnectionInfo)
	  {
		  // we must prepare the statement
		  // Accept default BCP settings
		  AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
                            new COdbcPreparedBcpStatementCommand(aConnectionInfo.GetCatalogPrefix() + std::string("t_acc_usage"), COdbcBcpHints())));
	  }

  protected:
	  COdbcBcpSessionAccUsageWriter(const COdbcConnectionInfo& aConnectionInfo,	bool aDontCreateStatement)
		  : COdbcSessionAccUsageWriter<COdbcPreparedBcpStatement,
		                              COdbcBcpSessionPropertyMapping>(aConnectionInfo)
	  {
		  // this constructor assumes subclasses set up the statement
	  }
};

/////////////////////////////////////////////////////
// COdbcBcpSessionStagingAccUsageWriter - 
// Write reserved session "underscore" parameters into
// t_acc_usage.
/////////////////////////////////////////////////////
class COdbcBcpSessionStagingAccUsageWriter : public COdbcSessionAccUsageWriter<COdbcPreparedBcpStatement, COdbcBcpSessionPropertyMapping>
{
  public:
	  COdbcBcpSessionStagingAccUsageWriter(const COdbcConnectionInfo& aConnectionInfo, int aMaxBatchSize)
		  : COdbcSessionAccUsageWriter<COdbcPreparedBcpStatement,
                                   COdbcBcpSessionPropertyMapping>(aConnectionInfo, "t_acc_usage")
	  {
		  // Prepare a minimally logged bcp into the staging table
   	  COdbcBcpHints hints;
  	  hints.SetMinimallyLogged(true);
	    hints.AddOrder("id_sess, id_usage_interval");
      AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
                            new COdbcPreparedBcpStatementCommand(aConnectionInfo.GetCatalogPrefix() + std::string(GetAccUsageName()), hints)));
	  }
};

/////////////////////////////////////////////////////
// COdbcBcpSessionProductViewWriter - 
// Writes configurable product view parameter properties
// to an underlying product view database table
/////////////////////////////////////////////////////

class COdbcBcpSessionProductViewWriter
	: public COdbcSessionProductViewWriter<COdbcPreparedBcpStatement, COdbcBcpSessionPropertyMapping>
{
public:
	COdbcBcpSessionProductViewWriter(CMSIXDefinition* apProductView, 
																	 MTPipelineLib::IMTNameIDPtr aNameID,
																	 const COdbcConnectionInfo& aConnectionInfo)
	{
		// we must prepare the statement
		string tableName(ascii(apProductView->GetTableName()));
	
		// Accept default BCP settings
		AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
                          new COdbcPreparedBcpStatementCommand(aConnectionInfo.GetCatalogPrefix() + tableName, COdbcBcpHints())));
	}
};

/////////////////////////////////////////////////////
// COdbcSessionStagingTableWriter - template
// Writes all session relevant properties to a t_pv_* staging table
/////////////////////////////////////////////////////
template<class STMT, class MAPPING>
class COdbcSessionStagingTableWriter : public COdbcSessionWriterBase<STMT, MAPPING>
{
  protected:
	  int mIdSessColumnPos;

  public:
	  void SetUp(const COdbcConnectionInfo& aConnectionInfo,
						   COdbcStagingTable* aStagingTable,
						   CMSIXDefinition* apProductView, 
						   MTPipelineLib::IMTNameIDPtr aNameID)
    {
	    mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);

      boost::shared_ptr<COdbcConnection> apConnection(new COdbcConnection(aConnectionInfo));

	    // Erase the mappings set up in the base class
	    mMappings.Clear();

	    // Table name is different
	    COdbcColumnMetadataVector v = apConnection->GetMetadata()->GetColumnMetadata(
                                        		    apConnection->GetConnectionInfo().GetCatalog(),
                                                aStagingTable->GetName());
	    COdbcColumnMetadataVector::iterator it = v.begin();

	    // Implement special handling of id_sess (this identifier we generate and set).
	    // For columns starting with c_ treat them as product view properties.
	    int productViewColumnsFound=0;
	    while(it != v.end())
	    {
        std::string columnName = (*it)->GetColumnName();
        if (_stricmp(columnName.c_str(), "id_sess") == 0)
		    {
			    mIdSessColumnPos = (*it)->GetOrdinalPosition();
		    }
        else if (_stricmp(columnName.c_str(), "id_usage_interval") == 0)
        {
 				    int sessionId = GetSpecialPropertySessionId((*it)->GetColumnName());
				    mMappings.AddMapping(MAPPING::Create(sessionId, 
																						    (*it)->GetOrdinalPosition(), 
																						    (*it)->GetDataType(), 
																						    (*it)->IsNullable(),
																						    CMSIXProperties::TYPE_DECIMAL));
        }
		    else if ((columnName[0] == 'C' || columnName[0] == 'c') && columnName[1] == '_')
		    {
			    BOOL bResult;
			    productViewColumnsFound++;
			    std::wstring wPropertyName;
			    bResult = ASCIIToWide(wPropertyName, columnName.c_str()+2, columnName.length()-2);
			    CMSIXProperties* msixProperty;
			    bResult = apProductView->FindProperty(wPropertyName, msixProperty);
			    if (!bResult) 
			    {
				    throw COdbcException("Could not find matching product view property for product view column '" + 
														    columnName + "'");
			    }

			    ASSERT(_wcsicmp(wPropertyName.c_str(), msixProperty->GetDN().c_str()) == 0);

			    MSIXPropertyValue * defaultVal = NULL;
			    if (!ConvertDefault(msixProperty, &defaultVal))
			    {
     		    char buf[512];
		        sprintf(buf, "Cannot initialize default value of property '%s' from %s", 
						        ascii(wPropertyName), ascii(apProductView->GetName()));

				    throw COdbcException(buf);
			    }
			    // Found the MSIX property.  Get the session id.
			    // TODO: validate type compatibility between session and db column
			    int sessionId = aNameID->GetNameID(msixProperty->GetDN().c_str());
    		
			    mMappings.AddMapping(MAPPING::Create(sessionId, 
                                              (*it)->GetOrdinalPosition(), 
																					    (*it)->GetDataType(),
																					    (*it)->IsNullable(),
																					    msixProperty->GetPropertyType(),
																					    defaultVal));
		    }
		    else
		    {
   		    char buf[512];
		      sprintf(buf, "Staging table '%s' has unrecognized column '%s'", 
						      aStagingTable->GetName().c_str(), columnName.c_str());
		      throw COdbcException(buf);
		    }
		    it++;
	    }

	    // Check to make sure that we have found all of the product view properties.
	    // Assume that database columns are named by appending c_ to product view property name.
	    // We'll walk through both of these lists to do a type validation.
	    MSIXPropertiesList & propList = apProductView->GetMSIXPropertiesList();
	    if (propList.size() != (unsigned int) productViewColumnsFound)
	    {
		    char buf[256];
		    sprintf(buf, "Staging table '%s' has %d product view columns and product view definition has %d properties", 
						    aStagingTable->GetName().c_str(),
						    productViewColumnsFound, 
						    propList.size());
		    throw COdbcException(buf);
	    }
    }

    void WriteSession(__int64 sessionId, CSessionWriterSession* aSession)
    {
	    // First write id_sess
//       ASSERT(mStatementObject);
	    GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);

	    // let the base class do the rest
	    COdbcSessionWriterBase<STMT, MAPPING>::WriteSession(sessionId, aSession);
    }

  public:
	  COdbcSessionStagingTableWriter(const COdbcConnectionInfo & aConnectionInfo,
		                               COdbcStagingTable* aStagingTable,
		                               CMSIXDefinition* apProductView, 
		                               MTPipelineLib::IMTNameIDPtr aNameID)
	    : COdbcSessionWriterBase<STMT, MAPPING>()
    {
	    SetUp(aConnectionInfo, aStagingTable, apProductView, aNameID);
    }
};

/////////////////////////////////////////////////////
// Writes all session relevant properties to a t_pv_* staging table
// using Bcp.
/////////////////////////////////////////////////////
class COdbcBcpSessionStagingTableWriter : public COdbcSessionStagingTableWriter<COdbcPreparedBcpStatement,
                                                                                COdbcBcpSessionPropertyMapping>
{
  public:
    COdbcBcpSessionStagingTableWriter(const COdbcConnectionInfo& aConnectionInfo,
		                                  COdbcStagingTable* aStagingTable,
		                                  CMSIXDefinition* apProductView, 
		                                  MTPipelineLib::IMTNameIDPtr aNameID,
                                      int aMaxBatchSize)
      : COdbcSessionStagingTableWriter<COdbcPreparedBcpStatement, COdbcBcpSessionPropertyMapping>
              (aConnectionInfo, aStagingTable, apProductView, aNameID)
    {
 	    // Prepare a minimally logged bcp into the staging table
	    COdbcBcpHints hints;
	    hints.SetMinimallyLogged(true);
	    hints.AddOrder("id_sess, id_usage_interval");
	    AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
                            new COdbcPreparedBcpStatementCommand(aConnectionInfo.GetCatalogPrefix() + aStagingTable->GetName(), hints)));
    }
};

/////////////////////////////////////////////////////
// COdbcBcpSessionWriter - 
// Writes a session of the appropriate product view type
// to the database
/////////////////////////////////////////////////////
class COdbcBcpSessionWriter : public COdbcSessionWriter
{
private:
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
	boost::shared_ptr<COdbcConnectionCommand> mAccUsageConnectionCommand;
	boost::shared_ptr<COdbcConnectionCommand> mProductViewConnectionCommand;
	int mMaxBatchSize;

public:
	COdbcBcpSessionWriter(int aMaxBatchSize, 
												const COdbcConnectionInfo& aOdbcConnectionInfo,
												COdbcLongIdGenerator* aGenerator,
												CMSIXDefinition* arProductView,
												MTPipelineLib::IMTNameIDPtr aNameID,
												SharedSessionHeader* apHeader);

	virtual ~COdbcBcpSessionWriter();

	// The largest number of sessions that will be batched before
	// flushing out to the database.
	int GetMaxBatchSize() const;
};

/////////////////////////////////////////////////////
// COdbcStagedWriterBase - Base class for staged writer
/////////////////////////////////////////////////////
template<class ACCUSSAGEWRITER>
class COdbcStagedWriterBase : public COdbcSessionWriter
{
protected:
	bool mStageOnly;
	int mMaxBatchSize;
 	string mTableSuffix;
	COdbcConnection* mSharedConnection;
	COdbcStatement* mSharedStatement;
	COdbcStagingTable* mStagingTable;
  string mTruncateQuery;
	COdbcConnectionInfo mStageDatabaseConnectionInfo;
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
  boost::shared_ptr<COdbcConnectionCommand> mTruncateConnectionCommand;
	MTPipelineLib::IMTNameIDPtr mNameID;

  // Truncate the staging table the first time it is written to.
  // This allows clean table in case of previous error and avoids writes
  // after the final inserts (locks can be avoided by committing staging table loads)
  void TruncateOnFirstWrite()
  {
	  if (false == mStageOnly && GetCurrentSessionsInBuffer() == 0 && GetCurrentSessionsInBatch() == 0)
    {
//       boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(mStageDatabaseConnectionInfo));
      COdbcConnectionHandle conn(mOdbcManager, mTruncateConnectionCommand);
      boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
      stmt->ExecuteUpdate(mTruncateQuery);
    }
  }

public:

	COdbcStagedWriterBase(int aMaxBatchSize,
                        COdbcConnection* aOdbcConnection,
						const COdbcConnectionInfo& aStageDatabaseConnectionInfo,
                        COdbcLongIdGenerator* aGenerator,
                        SharedSessionHeader* apHeader,
                        const string& aTableSuffix,
                        bool aStageOnly,
                        bool bAutoEndBatch)
	  : COdbcSessionWriter(aGenerator, apHeader),
	    mSharedConnection(aOdbcConnection),
  		mStageDatabaseConnectionInfo(aStageDatabaseConnectionInfo),
	    mStagingTable(NULL),
	    mSharedStatement(NULL),
   		mTableSuffix(aTableSuffix),
		mStageOnly(aStageOnly),
 	    mMaxBatchSize(aMaxBatchSize),
		mNameID(MTPROGID_NAMEID)
  { 
    // Do not call EndBatch automatically. The caller will do this.
    EnableAutoEndBatch(bAutoEndBatch);

    mTruncateConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(new COdbcConnectionCommand(aStageDatabaseConnectionInfo, 
                                                                                                      COdbcConnectionCommand::TXN_AUTO,
                                                                                                      false));
    mOdbcManager->RegisterResourceTree(mTruncateConnectionCommand);
  }

  virtual ~COdbcStagedWriterBase()
  {
	  delete mSharedStatement;
	  delete mStagingTable;
  }

 	// The largest number of sessions that will be batched before
	// flushing out to the database.
	int GetMaxBatchSize() const { return mMaxBatchSize; }

  // Must be implemented.
  virtual void Setup()
  {
    // Call base class, in case it ever does anything
    COdbcSessionWriter::Setup();

    mStagingTable = new COdbcStagingTable(mSharedConnection, mTableName, mTableSuffix);

    // Create statment object on each connection for moving staged data to NetMeter.
    mSharedStatement = mSharedConnection->CreateStatement();

    // Create the staging table if it doesn't exist
    // CR 15786 - This query fails to execute if the query length
    // exceeds 4096 characters when using Odbc. Using ADO instead.
    wstring wddl;
    ASCIIToWide(wddl, mStagingTable->GetCreateStageTableQuery());
    ExecuteQuery(L"\\Queries\\DynamicTable", wddl);

    // This is a bit expensive to generate cause the DBNameHash so do it once.
    mTruncateQuery = mStagingTable->GetTruncateQuery();

    // Create acc usage stage writer.
    ACCUSSAGEWRITER * tmp = new ACCUSSAGEWRITER(mStageDatabaseConnectionInfo, mMaxBatchSize);
    AddWriter(tmp);
  }

  // -------------------------------------------------------------------------
  // Description: Execute a query
  // -------------------------------------------------------------------------
  BOOL ExecuteQuery(const wstring & arConfigPath, const wstring & arQuery)
  {
	  DBAccess dbAccess;
	  BOOL success = TRUE;
    LoggerConfigReader configReader;
    NTLogger logger;
    logger.Init(configReader.ReadConfiguration("logging"), "OdbcSessionMapping");

	  // initialize the database context
	  if (!dbAccess.Init(arConfigPath))
	  {
		  logger.LogThis(LOG_ERROR, "Database initialization failed");
		  success = FALSE;
	  }

	  if (success)
	  {
		  if (!dbAccess.Execute(arQuery))
		  {
			  logger.LogThis(LOG_ERROR, "Database execution failed");
			  success = FALSE;
		  }

		  // always disconnect from the database
		  if (!dbAccess.Disconnect())
		  {
			  logger.LogThis(LOG_ERROR, "Database disconnect failed");
			  success = FALSE;
		  }
	  }

	  return success;
  }

  //
  virtual void EndBatch()
  {
    static std::string OdbcIntegrityViolation("23000"); //xxx Should find a better flace for this...
    if (false == mStageOnly && GetCurrentSessionsInBatch() > 0)
    {
      // Move data from stage to NetMeter...
 	    vector<InsertQueryPtr>::const_iterator iter = mStagingTable->GetInsertQueries().begin();
 	    vector<InsertQueryPtr>::const_iterator end = mStagingTable->GetInsertQueries().end();

      // Execute all the sql insert statements
      vector<string> SuccessfulConstraint;
      try
      {
        for ( ; iter != end; ++iter )
        {
          // Execute the insert query.
          mSharedStatement->ExecuteUpdate((*iter)->Query);

          // For unique key queries track which are successful. If one fails we do not
          // need to execute constraint validation against the successful ones.
          if ((*iter)->ConstraintName.empty() == false)
            SuccessfulConstraint.push_back((*iter)->ConstraintName);
        }
      }
   	  catch(COdbcException& ex) 
      {
        if (ex.getSqlState() == OdbcIntegrityViolation)
        {
          // Validate all constraints.
          vector<ConstarintQueryPtr>::const_iterator iter = mStagingTable->GetConstraintQueries().begin();
          vector<ConstarintQueryPtr>::const_iterator end = mStagingTable->GetConstraintQueries().end();
		  if(iter != end)
		  {
          for (; iter != end; ++iter)
          {
            // Check if constraint insert was successful.
            bool bFound = false;
		    for(std::vector<string>::const_iterator it=SuccessfulConstraint.begin();
                it != SuccessfulConstraint.end(); it++)
		        {
				  if ((*iter)->ConstraintName == *it)
				  {
					bFound = true;
					break;
				  }
		        }
        
            // Updated failed sessions for any contraints that were not successful.
            if (bFound == false)
              UpdateFailedSessions(mSharedConnection, (ConstarintQueryPtr) *iter);
          }
		  }
		  else
		  {
			  // We've received an integrity check violation but have no unique constraints defined for the table
			  // Can only handle by failing all the sessions in the set and forcing a complete retry.
			  FailAllSessions(ex);
		  }
        }

        // Rethrow the error.
        throw ex;
      }

      // Call base class.
      COdbcSessionWriter::EndBatch();
    }
  }
};

/////////////////////////////////////////////////////
// COdbcStagedSessionWriter - template
// Writes a session of the appropriate product view type
// to the database. Writes synchronously to staging table, then
// moves data from staging table to t_acc_usage and t_pv_*
/////////////////////////////////////////////////////
template<class STAGINGTABLEWRITER, class ACCUSSAGEWRITER>
class COdbcStagedSessionWriter : public COdbcStagedWriterBase<ACCUSSAGEWRITER>
{
  public:
	  COdbcStagedSessionWriter(int aMaxBatchSize, COdbcConnection* aOdbcConnection,
														 const COdbcConnectionInfo& aStageDatabaseConnectionInfo,
														 COdbcLongIdGenerator* aGenerator,
														 CMSIXDefinition* apProductView,
														 const string& aTableSuffix,
														 bool aStageOnly,
														 SharedSessionHeader* apHeader,
                             bool bAutoEndBatch)
      : COdbcStagedWriterBase<ACCUSSAGEWRITER>(aMaxBatchSize, aOdbcConnection,
                              aStageDatabaseConnectionInfo,
                              aGenerator,
                              apHeader,
                              aTableSuffix,
                              aStageOnly,
                              bAutoEndBatch)
      {
        mTableName = ascii(apProductView->GetTableName());
        mStageDatabaseConnectionInfo = aStageDatabaseConnectionInfo;
        mpProductView = apProductView;
      }

    ~COdbcStagedSessionWriter()
    {
    }

	  virtual void Setup()
    {
      // Must call base class first
      COdbcStagedWriterBase<ACCUSSAGEWRITER>::Setup();

      // Create product view stage writer.
      STAGINGTABLEWRITER * tmp = new STAGINGTABLEWRITER(mStageDatabaseConnectionInfo, mStagingTable, mpProductView, mNameID, mMaxBatchSize);
      AddWriter(tmp);
      // Begin Batch now.
      BeginBatch();
    }

	  virtual __int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession)
    {
	    // Intialize if necessary
	    if (!mIsInitialized)
	    {
		    Setup();
		    mIsInitialized = TRUE;
	    }

	    TruncateOnFirstWrite();
	    return COdbcSessionWriter::WriteSession(aSession);
    }

	  virtual __int64 WriteChildSession(__int64 aParentId, 
																			MTPipelineLib::IMTSessionPtr aSession)
    {
	    // Intialize if necessary
	    if (!mIsInitialized)
	    {
		    Setup();
		    mIsInitialized = TRUE;
	    }

	    TruncateOnFirstWrite();
	    return COdbcSessionWriter::WriteChildSession(aParentId, aSession);
    }
};

/////////////////////////////////////////////////////
// COdbcAccUsageStagedWriter - template
// Writes acc ussage data to the database.
// Moves data from staging table to t_acc_usage
/////////////////////////////////////////////////////
template<class ACCUSSAGEWRITER>
class COdbcAccUsageStagedWriter : public COdbcStagedWriterBase<ACCUSSAGEWRITER>
{
  private:
    
    /* This call in not applicable to this object.
       All this object really does is truncate the stage table and then
       do an insert into t_acc_uasage when done. */
    virtual int ExecuteBatch()
    {
      // This code does nothing for acc usage stage.
      return 0;
    }

  public:

 	  COdbcAccUsageStagedWriter(COdbcConnection* aOdbcConnection,
													    const COdbcConnectionInfo& aStageDatabaseConnectionInfo,
                              COdbcLongIdGenerator* aGenerator,
                              SharedSessionHeader* apHeader,
                              int aMaxBatchSize)
      : COdbcStagedWriterBase<ACCUSSAGEWRITER>(aMaxBatchSize, aOdbcConnection, aStageDatabaseConnectionInfo,
                                               aGenerator, apHeader, "", false, false)
    {
		mTableName = "t_acc_usage";

		// Account usage table depends on all product view tables; it's always metered.
		mIsDataMetered = true;

		// Intialize writer.
	    Setup();
    }

    virtual void Setup()
    {
      // Must call base class first
      COdbcStagedWriterBase<ACCUSSAGEWRITER>::Setup();

      // Acc usage writer initialized.
 	    mIsInitialized = TRUE;
    }

    virtual void BeginBatch()
    {
      // Truncate account usage at the begining of each batch.
	    if (false == mStageOnly)
      {
//         boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(mStageDatabaseConnectionInfo));
        COdbcConnectionHandle conn(mOdbcManager, mTruncateConnectionCommand);
        boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
        stmt->ExecuteUpdate(mTruncateQuery);
      }

      // Call base class last
      COdbcStagedWriterBase<ACCUSSAGEWRITER>::BeginBatch();
    }

    // Truncate the Acc Usage Table.
    virtual void EndBatch()
    {
      // Pretend that we actually have a session so that default
      // EndBatch call does work.
      mCurrentSessionsInBatch = 1;

      // Call base class
      COdbcStagedWriterBase<ACCUSSAGEWRITER>::EndBatch();
    }
	  virtual __int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession)
    {
      ASSERT(FALSE);
      return -1LL;
    }

	  virtual __int64 WriteChildSession(__int64 aParentId, 
																			MTPipelineLib::IMTSessionPtr aSession)
    {
      ASSERT(FALSE);
      return -1LL;
    }
};

typedef COdbcAccUsageStagedWriter<COdbcBcpSessionStagingAccUsageWriter>
      COdbcBcpAccUsageStagedWriter;

/////////////////////////////////////////////////////
//
// array implementation
//
/////////////////////////////////////////////////////

// Array version
typedef COdbcSessionPropertyMapping<COdbcPreparedArrayStatement>
  COdbcArraySessionPropertyMapping;

// Writes all session relevant properties to a t_pv_* staging table
class COdbcArraySessionStagingTableWriter : public COdbcSessionStagingTableWriter<COdbcPreparedArrayStatement,
                                                                                  COdbcArraySessionPropertyMapping>
{
  public:
    COdbcArraySessionStagingTableWriter(const COdbcConnectionInfo& aConnectionInfo,
		                                    COdbcStagingTable* aStagingTable,
		                                    CMSIXDefinition* apProductView, 
		                                    MTPipelineLib::IMTNameIDPtr aNameID,
                                        int aMaxBatchSize)
      : COdbcSessionStagingTableWriter<COdbcPreparedArrayStatement, COdbcArraySessionPropertyMapping>
              (aConnectionInfo, aStagingTable, apProductView, aNameID)
    {
		  // Prepare an insert statement into the staging table
	    AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
                            new COdbcPreparedInsertStatementCommand(aStagingTable->GetName(), aMaxBatchSize, true)));
    }
};

// Write reserved session "underscore" parameters into t_acc_usage.
class COdbcArraySessionStagingAccUsageWriter : public COdbcSessionAccUsageWriter<COdbcPreparedArrayStatement,
                                                                                 COdbcArraySessionPropertyMapping>
{
  public:
	  COdbcArraySessionStagingAccUsageWriter(const COdbcConnectionInfo& aConnection, int aMaxBatchSize)
		  : COdbcSessionAccUsageWriter<COdbcPreparedArrayStatement,
                                   COdbcArraySessionPropertyMapping>(aConnection, "t_acc_usage")
	  {
		  // Prepare an insert statement into the staging table
		  AddStatementCommand(aConnection, boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
                            new COdbcPreparedInsertStatementCommand(GetAccUsageName(), aMaxBatchSize, true)));
	  }
};

typedef COdbcAccUsageStagedWriter<COdbcArraySessionStagingAccUsageWriter>
      COdbcArrayAccUsageStagedWriter;

/////////////////////////////////////////////////////
// COdbcArraySessionAccUsageWriter
/////////////////////////////////////////////////////
class COdbcArraySessionAccUsageWriter :
	public COdbcSessionAccUsageWriter<COdbcPreparedArrayStatement, COdbcArraySessionPropertyMapping>
{
  public:
	  COdbcArraySessionAccUsageWriter(const COdbcConnectionInfo& aConnection, int aMaxArraySize)
		  : COdbcSessionAccUsageWriter<COdbcPreparedArrayStatement,
		                               COdbcArraySessionPropertyMapping>(aConnection)
	  {
		  // We must prepare the statement
		  AddStatementCommand(aConnection, boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
                            new COdbcPreparedInsertStatementCommand("t_acc_usage", aMaxArraySize, true)));
	  }
};

/////////////////////////////////////////////////////
// COdbcArrayProductViewWriter
/////////////////////////////////////////////////////
class COdbcArraySessionProductViewWriter
	: public COdbcSessionProductViewWriter<COdbcPreparedArrayStatement, COdbcArraySessionPropertyMapping>
{
public:
	COdbcArraySessionProductViewWriter(CMSIXDefinition* apProductView, 
																const COdbcConnectionInfo & aConnectionInfo,
																int aMaxArraySize)
	{
		// we must prepare the statement
		string tableName(ascii(apProductView->GetTableName()));
		AddStatementCommand(aConnectionInfo, boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
                          new COdbcPreparedInsertStatementCommand(tableName, aMaxArraySize, true)));
	}
};

/////////////////////////////////////////////////////
// COdbcArraySessionWriter - 
// Writes a session of the appropriate product view type
// to the database
/////////////////////////////////////////////////////
class COdbcArraySessionWriter : public COdbcSessionWriter
{
private:
	int mMaxBatchSize;
  
public:
	COdbcArraySessionWriter(int aMaxBatchSize, 
													COdbcConnection * apOdbcConnection,
													COdbcLongIdGenerator* aGenerator,
													CMSIXDefinition* arProductView,
													MTPipelineLib::IMTNameIDPtr aNameID,
													SharedSessionHeader* apHeader);

	virtual ~COdbcArraySessionWriter();

	virtual void Setup();

	// The largest number of sessions that will be batched before
	// flushing out to the database.
	int GetMaxBatchSize() const;

};

// include the template definitions
#include "OdbcSessionMappingDef.h"


#endif
