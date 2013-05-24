#ifndef __ODBCRESOURCEMANAGER_H__
#define __ODBCRESOURCEMANAGER_H__

#include <vector>
#include <map>
#include <set>
#include <boost/shared_ptr.hpp>
#include <boost/cstdint.hpp>
#include <boost/utility.hpp>

#include "metra.h"
#include "OdbcConnection.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcPreparedBcpStatement.h"

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DLL_EXPORT
#define DLL_EXPORT __declspec(dllexport)
#else
#undef DLL_EXPORT
#define DLL_EXPORT
#endif

class COdbcConnectionHandle;

struct MD5Digest
{
  boost::uint64_t a;
  boost::uint64_t b;
  bool operator==(const MD5Digest& rhs) const
  {
    return a == rhs.a && b == rhs.b;
  }

  bool operator!=(const MD5Digest& rhs) const
  {
    return a != rhs.a || b != rhs.b;
  }
};

class COdbcPreparedBcpStatementCommand : boost::noncopyable
{
private:
  std::string mTableName;
  COdbcBcpHints mHints;
  MD5Digest mHashCode;

public:
  DLL_EXPORT COdbcPreparedBcpStatementCommand(const std::string& tableName, const COdbcBcpHints& hints);
  DLL_EXPORT ~COdbcPreparedBcpStatementCommand();

  DLL_EXPORT COdbcPreparedBcpStatement * Create(COdbcConnection * conn);

  const MD5Digest& GetHashCode() const 
  {
    return mHashCode;
  }
};

class COdbcPreparedArrayStatementCommand : boost::noncopyable
{
private:
  int mMaxArraySize;
  bool mBind;
  std::string mQueryString;
  std::vector<COdbcResultSetType> mResultSetTypes;
  MD5Digest mHashCode;

  void CalculateHashCode();
public:
  DLL_EXPORT COdbcPreparedArrayStatementCommand(const std::string& queryString, int maxArraySize, bool bind);
  DLL_EXPORT COdbcPreparedArrayStatementCommand(const std::string& queryString, int maxArraySize, bool bind, COdbcResultSetType * types, std::size_t numTypes);
  DLL_EXPORT ~COdbcPreparedArrayStatementCommand();

  DLL_EXPORT COdbcPreparedArrayStatement * Create(COdbcConnection * conn);

  const MD5Digest& GetHashCode() const 
  {
    return mHashCode;
  }
};

class COdbcPreparedInsertStatementCommand : boost::noncopyable
{
private:
  int mMaxArraySize;
  bool mBind;
  std::string mTableName;
  MD5Digest mHashCode;
public:
  DLL_EXPORT COdbcPreparedInsertStatementCommand(const std::string& tableName, int maxArraySize, bool bind);
  DLL_EXPORT ~COdbcPreparedInsertStatementCommand();

  DLL_EXPORT COdbcPreparedArrayStatement * Create(COdbcConnection * conn);

  const MD5Digest& GetHashCode() const 
  {
    return mHashCode;
  }
};

class COdbcConnectionCommand 
{
public:
  enum TransactionMode { TXN_PIPELINE, TXN_MANUAL, TXN_AUTO };

private:
  COdbcConnectionInfo mInfo;
  TransactionMode mTransactionMode;
  bool mBulkCopy;
  MD5Digest mHashCode;

  void CalculateHashCode();

  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > mPreparedBcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > mPreparedArrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > mPreparedInsertStatements;
public:

  /**
   * Register a ConnectionResource with connection, transaction and bulk copy requirements.  Also include
   * any dependent prepared statements.
   */
  DLL_EXPORT COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy);

  DLL_EXPORT COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                         boost::shared_ptr<COdbcPreparedBcpStatementCommand> preparedBcpStatement,
                         boost::shared_ptr<COdbcPreparedArrayStatementCommand> preparedArrayStatement);

  DLL_EXPORT COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                         boost::shared_ptr<COdbcPreparedBcpStatementCommand> preparedBcpStatement,
                         const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& preparedArrayStatements);

  DLL_EXPORT COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                         const std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& preparedBcpStatement,
                         const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& preparedArrayStatements,
                         const std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& preparedInsertStatements);

  DLL_EXPORT COdbcConnectionCommand(const COdbcConnectionCommand& rhs);

  DLL_EXPORT ~COdbcConnectionCommand();

  DLL_EXPORT const std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& GetPreparedBcpStatements() const;

  DLL_EXPORT const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& GetPreparedArrayStatements() const;

  DLL_EXPORT const std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& GetPreparedInsertStatements() const;

  const COdbcConnectionInfo& GetConnectionInfo() const { return mInfo; }
  TransactionMode GetTransactionMode() const { return mTransactionMode; }
  bool GetBulkCopy() const { return mBulkCopy; }

  const MD5Digest& GetHashCode() const 
  {
    return mHashCode;
  }

  DLL_EXPORT void Union(boost::shared_ptr<COdbcConnectionCommand> rhs);
};

class COdbcResourceSet
{
private:
  COdbcConnection * mConnection;
  std::map<boost::shared_ptr<COdbcPreparedArrayStatementCommand>, COdbcPreparedArrayStatement*> mPreparedArrayStatements;
  std::map<boost::shared_ptr<COdbcPreparedBcpStatementCommand>, COdbcPreparedBcpStatement*> mPreparedBcpStatements;
  std::map<boost::shared_ptr<COdbcPreparedInsertStatementCommand>, COdbcPreparedArrayStatement*> mPreparedInsertStatements;
 
public:
  COdbcResourceSet(boost::shared_ptr<COdbcConnectionCommand> resources);
  ~COdbcResourceSet();

  DLL_EXPORT COdbcConnection * GetConnection();
  DLL_EXPORT COdbcPreparedBcpStatement * operator[] (boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcpStatement);
  DLL_EXPORT COdbcPreparedArrayStatement * operator[] (boost::shared_ptr<COdbcPreparedArrayStatementCommand> arrayStatement);
  DLL_EXPORT COdbcPreparedArrayStatement * operator[] (boost::shared_ptr<COdbcPreparedInsertStatementCommand> insertStatement);
};

/**
 * Manages (ODBC) database resources for C++ plugins in a connection-efficient way.
 *
 * Plugin clients may register their requirements using resource descriptions during
 * plugin initialize time.  The manager examines registered resource descriptions and decides when
 * two resource requirements are connection compatible based on possibly database dependent rules (e.g.
 * two BCPs are not connection compatible hence cannot be satisfied simultaneously).  The manager
 * 
 *
 * Resources may be retrieved at runtime in the context of a pipeline session object (technically
 * in the context of a session object owner).  These semantics are necessary to support pipeline
 * transactions (essentially the session names the targeted transaction context that the client wants
 * to perform work in).
 * A client is expected to release any physical resources at the end of a ProcessSessions call
 * but such behavior is not enforces (much in the same way that there is no enforcement of releasing
 * references to IMTTransaction or IMTSQLRowset).
 *
 * Subtle Points:
 * 1) Backward compatibility: Many/most/all of the plugins that use ODBC today implement a model in which
 * they do NOT create a transaction if it doesn't exist.  That model is different than the standard MTSQLRowset
 * model in the pipeline which always creates a transaction when creating a rowset.  This effectively
 * implements READ COMMITTED semantics for the ODBC plugins as opposed to SERIALIZABLE for Rowset based
 * workloads.  We really can't escalate the isolation level without paying price with locking/deadlocking.
 *
 * Ideally, this means that when we get the pipeline ODBC connection we do not force creation of a transaction
 * whereas when we create a transaction we need to check for existing ODBC connection on the object owner and
 * join it to the transaction if necessary.
 *
 * For the moment we are avoiding this issue by only supporting AUTO transactions and forcing clients to
 * explicity join and leave pipeline distributed transactions.
 */
class COdbcResourceManager 
{
private:
  static NTThreadLock sLock;
  static boost::int32_t sRefCount;
  static COdbcResourceManager * sInstance;

  // These are the resource trees that we are instantiating.
  std::set<boost::shared_ptr<COdbcConnectionCommand> > mTargetTrees;
  // This maps registered trees to the targets that we'll create for them
  std::map<boost::shared_ptr<COdbcConnectionCommand>, boost::shared_ptr<COdbcConnectionCommand> > mRegisteredToTargetIndex;
  // These are the resource pools for each target that are available for allocation
  std::map<boost::shared_ptr<COdbcConnectionCommand>, std::set<COdbcResourceSet * > > mResourceFreePool;
  // These are the resource pools for each target that are allocated
  std::map<boost::shared_ptr<COdbcConnectionCommand>, std::set<COdbcResourceSet * > > mResourceAllocatedPool;
  // These are the resource pools for each target that are allocated but shouldn't be put back into the pool,
  // free 'em for good when they come back.
  std::set<COdbcResourceSet * > mBlacklist;

  NTThreadLock mLock;

  void InternalReinitialize(boost::shared_ptr<COdbcConnectionCommand> resource);

public:

  DLL_EXPORT static COdbcResourceManager * GetInstance();
  DLL_EXPORT static void ReleaseInstance();

  // TODO: Implement singleton pattern here.
  DLL_EXPORT COdbcResourceManager();

  DLL_EXPORT ~COdbcResourceManager();

  /**
   * Make resource manager aware of my interest in a connection with described resources.
   */
  DLL_EXPORT void RegisterResourceTree(boost::shared_ptr<COdbcConnectionCommand> resource);

  /**
   * Reinitialize resource manager state described by the command tree (e.g. due to stale connection).
   */
  DLL_EXPORT void Reinitialize(boost::shared_ptr<COdbcConnectionCommand> resource);

  /**
   * Reinitialize all resource manager state.
   */
  DLL_EXPORT void ReinitializeAll();

//   void RegisterResourceTree(boost::shared_ptr<COdbcConnectionCommand> resource, 
//                             boost::shared_ptr<COdbcPreparedBcpStatementCommand> stmt);
//   void RegisterResourceTree(boost::shared_ptr<COdbcConnectionCommand> resource, 
//                             const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& stmts);
//   void RegisterResourceTree(boost::shared_ptr<COdbcConnectionCommand> resource, 
//                             boost::shared_ptr<COdbcPreparedBcpStatementCommand> stmt, 
//                             const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& stmts);

  COdbcResourceSet * Allocate(boost::shared_ptr<COdbcConnectionCommand> resource);

  void Free(boost::shared_ptr<COdbcConnectionCommand> resource,  COdbcResourceSet * resourceSet);
};

/**
 * ODBC resources described by the resource tree and taken from the resource manager.  Requires
 * that the resource tree is already registered with the resource manager.
 */
class COdbcConnectionHandle
{
private:
  COdbcResourceSet * mResourceSet;
  boost::shared_ptr<COdbcConnectionCommand> mResources;
  MTAutoSingleton<COdbcResourceManager>& mManager;
public:
  DLL_EXPORT COdbcConnectionHandle(MTAutoSingleton<COdbcResourceManager>& manager, boost::shared_ptr<COdbcConnectionCommand> resources);
  DLL_EXPORT ~COdbcConnectionHandle();

  COdbcConnection * operator -> () 
  {
    return mResourceSet->GetConnection();
  }
  COdbcPreparedBcpStatement * operator[] (boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcpStatement)
  {
    return (*mResourceSet)[bcpStatement];
  }
  COdbcPreparedArrayStatement * operator[] (boost::shared_ptr<COdbcPreparedArrayStatementCommand> arrayStatement)
  {
    return (*mResourceSet)[arrayStatement];
  }
  COdbcPreparedArrayStatement * operator[] (boost::shared_ptr<COdbcPreparedInsertStatementCommand> insertStatement)
  {
    return (*mResourceSet)[insertStatement];
  }
};


// class COdbcConnectionExample
// {
// public:
//   int main()
//   {
//     boost::shared_ptr<COdbcResourceManager> resourceManager(new COdbcResourceManager());

//     boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcpCommand(new COdbcPreparedBcpStatementCommand("my_temp_table", bcpHints));

//     boost::shared_ptr<COdbcPreparedArrayStatementCommand> arrayCommand(new COdbcPreparedArrayCommand("select * from my_temp_table", 1000));

//     boost::shared_ptr<COdbcConnectionCommand> connectionCommand(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"), 
//                                                                                            COdbcConnectionManager::TXN_AUTO, 
//                                                                                            true,
//                                                                                            bcpCommand,
//                                                                                            arrayCommand));

//     resourceManager->RegisterResourceTree(connectionCommand);

//     {
//       COdbcConnectionHandle connectionHandle(resourceManager, connectionCommand);

//       // Execute in pipeline transaction context.
//       connectionHandle->JoinTransaction();
//       COdbcPreparedResultSetPtr rs (connectionHandle[arrayCommand]->ExecuteQuery());
//       connectionHandle->LeaveTransaction();
//     }
//   }
// };
#endif
