#include "OdbcResourceManager.h"

#include "global.h"
#include "mtmd5.h"

COdbcPreparedBcpStatementCommand::COdbcPreparedBcpStatementCommand(const std::string& tableName, const COdbcBcpHints& hints)
  :
  mTableName(tableName),
  mHints(hints)
{
  MT_MD5_CTX ctx;
  MT_MD5_Init(&ctx);
  MT_MD5_Update(&ctx, (boost::uint8_t *) mTableName.c_str(), mTableName.size());

  bool tmp = mHints.GetMinimallyLogged();
  MT_MD5_Update(&ctx, (boost::uint8_t *) &tmp, sizeof(tmp));
  tmp = mHints.GetFireTriggers();
  MT_MD5_Update(&ctx, (boost::uint8_t *) &tmp, sizeof(tmp));
  
  for(std::vector<std::string>::const_iterator it = mHints.GetOrder().begin();
      it != mHints.GetOrder().end();
      ++it)
  {
    MT_MD5_Update(&ctx, (boost::uint8_t *) it->c_str(), it->size());
  }
  MT_MD5_Final((boost::uint8_t *) &mHashCode, &ctx);
}

COdbcPreparedBcpStatementCommand::~COdbcPreparedBcpStatementCommand()
{
}

COdbcPreparedBcpStatement * COdbcPreparedBcpStatementCommand::Create(COdbcConnection * conn)
{
  return conn->PrepareBcpInsertStatement(mTableName, mHints);
}

COdbcPreparedArrayStatementCommand::COdbcPreparedArrayStatementCommand(const std::string& queryString, int maxArraySize, bool bind)
  :
  mMaxArraySize(maxArraySize),
  mBind(bind),
  mQueryString(queryString)
{
  CalculateHashCode();
}

COdbcPreparedArrayStatementCommand::COdbcPreparedArrayStatementCommand(const std::string& queryString, int maxArraySize, bool bind, COdbcResultSetType * types, std::size_t numTypes)
  :
  mMaxArraySize(maxArraySize),
  mBind(bind),
  mQueryString(queryString)
{
  for(std::size_t i=0; i<numTypes; i++)
  {
    mResultSetTypes.push_back(types[i]);
  }
  CalculateHashCode();
}

COdbcPreparedArrayStatementCommand::~COdbcPreparedArrayStatementCommand()
{
}

COdbcPreparedArrayStatement * COdbcPreparedArrayStatementCommand::Create(COdbcConnection * conn)
{
  COdbcPreparedArrayStatement * stmt = conn->PrepareStatement(mQueryString, mMaxArraySize, mBind);
  if (mResultSetTypes.size() > 0)
  {
    stmt->SetResultSetTypes(&mResultSetTypes[0], mResultSetTypes.size());
  }
  return stmt;
}

void COdbcPreparedArrayStatementCommand::CalculateHashCode()
{
  MT_MD5_CTX ctx;
  MT_MD5_Init(&ctx);
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mMaxArraySize, sizeof(mMaxArraySize));
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mBind, sizeof(mBind));
  MT_MD5_Update(&ctx, (boost::uint8_t *) mQueryString.c_str(), mQueryString.size());
  for(std::vector<COdbcResultSetType>::const_iterator it = mResultSetTypes.begin();
      it != mResultSetTypes.end();
      it++)
  {
    MT_MD5_Update(&ctx, (boost::uint8_t *) &*it, sizeof(*it));
  }
  MT_MD5_Final((boost::uint8_t *) &mHashCode, &ctx);
}

COdbcPreparedInsertStatementCommand::COdbcPreparedInsertStatementCommand(const std::string& tableName, int maxArraySize, bool bind)
  :
  mMaxArraySize(maxArraySize),
  mBind(bind),
  mTableName(tableName)
{
  MT_MD5_CTX ctx;
  MT_MD5_Init(&ctx);
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mMaxArraySize, sizeof(mMaxArraySize));
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mBind, sizeof(mBind));
  MT_MD5_Update(&ctx, (boost::uint8_t *) mTableName.c_str(), mTableName.size());
  MT_MD5_Final((boost::uint8_t *) &mHashCode, &ctx);
}

COdbcPreparedInsertStatementCommand::~COdbcPreparedInsertStatementCommand()
{
}

COdbcPreparedArrayStatement * COdbcPreparedInsertStatementCommand::Create(COdbcConnection * conn)
{
  return conn->PrepareInsertStatement(mTableName, mMaxArraySize, mBind);
}

COdbcConnectionCommand::COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy)
  :
  mInfo(info),
  mTransactionMode(transactionMode),
  mBulkCopy(bulkCopy)
{
  CalculateHashCode();
}

COdbcConnectionCommand::COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                                               boost::shared_ptr<COdbcPreparedBcpStatementCommand> preparedBcpStatement,
                                               boost::shared_ptr<COdbcPreparedArrayStatementCommand> preparedArrayStatement)
  :
  mInfo(info),
  mTransactionMode(transactionMode),
  mBulkCopy(bulkCopy),
  mPreparedBcpStatements(1,preparedBcpStatement),
  mPreparedArrayStatements(1,preparedArrayStatement)
{
  CalculateHashCode();
}

COdbcConnectionCommand::COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                                               boost::shared_ptr<COdbcPreparedBcpStatementCommand> preparedBcpStatement,
                                               const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& preparedArrayStatements)
  :
  mInfo(info),
  mTransactionMode(transactionMode),
  mBulkCopy(bulkCopy),
  mPreparedBcpStatements(1,preparedBcpStatement),
  mPreparedArrayStatements(preparedArrayStatements)
{
}

COdbcConnectionCommand::COdbcConnectionCommand(const COdbcConnectionInfo & info, TransactionMode transactionMode, bool bulkCopy,
                                               const std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& preparedBcpStatements,
                                               const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& preparedArrayStatements,
                                               const std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& preparedInsertStatements)
  :
  mInfo(info),
  mTransactionMode(transactionMode),
  mBulkCopy(bulkCopy),
  mPreparedBcpStatements(preparedBcpStatements),
  mPreparedArrayStatements(preparedArrayStatements),
  mPreparedInsertStatements(preparedInsertStatements)
{
  CalculateHashCode();
  if (preparedBcpStatements.size() > 1)
  {
    throw std::logic_error("At most one BCP statement supported on any connection");
  }
}

COdbcConnectionCommand::COdbcConnectionCommand(const COdbcConnectionCommand& rhs)
  :
  mInfo(rhs.mInfo),
  mTransactionMode(rhs.mTransactionMode),
  mBulkCopy(rhs.mBulkCopy),
  mHashCode(rhs.mHashCode),
  mPreparedBcpStatements(rhs.mPreparedBcpStatements),
  mPreparedArrayStatements(rhs.mPreparedArrayStatements),
  mPreparedInsertStatements(rhs.mPreparedInsertStatements)
{
}

COdbcConnectionCommand::~COdbcConnectionCommand()
{
}

const std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >& COdbcConnectionCommand::GetPreparedBcpStatements() const
{
  return mPreparedBcpStatements;
}

const std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >& COdbcConnectionCommand::GetPreparedArrayStatements() const
{
  return mPreparedArrayStatements;
}

const std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >& COdbcConnectionCommand::GetPreparedInsertStatements() const
{
  return mPreparedInsertStatements;
}

void COdbcConnectionCommand::Union(boost::shared_ptr<COdbcConnectionCommand> rhs)
{
  if (this->GetHashCode() != rhs->GetHashCode()) 
  {
    throw std::logic_error("Cannot take union of commands with different connections");
  }

  mPreparedBcpStatements.insert(mPreparedBcpStatements.end(), rhs->mPreparedBcpStatements.begin(), rhs->mPreparedBcpStatements.end());
  mPreparedArrayStatements.insert(mPreparedArrayStatements.end(), rhs->mPreparedArrayStatements.begin(), rhs->mPreparedArrayStatements.end());
  mPreparedInsertStatements.insert(mPreparedInsertStatements.end(), rhs->mPreparedInsertStatements.begin(), rhs->mPreparedInsertStatements.end());
}

void COdbcConnectionCommand::CalculateHashCode()
{
  MT_MD5_CTX ctx;
  MT_MD5_Init(&ctx);
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetUserName().c_str(), mInfo.GetUserName().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetPassword().c_str(), mInfo.GetPassword().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetCatalog().c_str(), mInfo.GetCatalog().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetServer().c_str(), mInfo.GetServer().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetDataSource().c_str(), mInfo.GetDataSource().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) mInfo.GetDatabaseDriver().c_str(), mInfo.GetDatabaseDriver().size());
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mTransactionMode, sizeof(mTransactionMode));
  MT_MD5_Update(&ctx, (boost::uint8_t *) &mBulkCopy, sizeof(mBulkCopy));
  MT_MD5_Final((boost::uint8_t *) &mHashCode, &ctx);
}

NTThreadLock COdbcResourceManager::sLock;
boost::int32_t COdbcResourceManager::sRefCount(0);
COdbcResourceManager * COdbcResourceManager::sInstance(NULL);

COdbcResourceManager * COdbcResourceManager::GetInstance()
{
  AutoCriticalSection acs(&sLock);

  if (sRefCount++ == 0)
  {
    sInstance = new COdbcResourceManager();
  }
  return sInstance;
}

void COdbcResourceManager::ReleaseInstance()
{
  AutoCriticalSection acs(&sLock);

  if (--sRefCount == 0)
  {
    delete sInstance;
    sInstance = NULL;
  }
}

COdbcResourceManager::COdbcResourceManager()
{
}

COdbcResourceManager::~COdbcResourceManager()
{
  for(std::map<boost::shared_ptr<COdbcConnectionCommand>, std::set<COdbcResourceSet * > >::iterator outerIt = mResourceFreePool.begin();
      outerIt != mResourceFreePool.end();
      ++outerIt)
  {
    for(std::set<COdbcResourceSet * >::iterator innerIt = outerIt->second.begin();
        innerIt != outerIt->second.end();
        ++innerIt)
    {
      delete *innerIt;
    }
    outerIt->second.clear();
  }

  for(std::map<boost::shared_ptr<COdbcConnectionCommand>, std::set<COdbcResourceSet * > >::iterator outerIt = mResourceAllocatedPool.begin();
      outerIt != mResourceAllocatedPool.end();
      ++outerIt)
  {
    for(std::set<COdbcResourceSet * >::iterator innerIt = outerIt->second.begin();
        innerIt != outerIt->second.end();
        ++innerIt)
    {
      delete *innerIt;
    }
    outerIt->second.clear();
  }

  for(std::set<COdbcResourceSet * >::iterator innerIt = mBlacklist.begin();
      innerIt != mBlacklist.end();
      ++innerIt)
  {
    delete *innerIt;
  }  
}

void COdbcResourceManager::RegisterResourceTree(boost::shared_ptr<COdbcConnectionCommand> resource)
{
  AutoCriticalSection acs(&mLock);
  // See if we have any existing connections that are compatible and then look to see if we can 
  // support the requested statement resources on that connection.  Otherwise create a new connection.
  // Remember an association of the input command to the target resource tree.  When we create
  // actual connections we'll use the target resource tree which will potentially be the union of many
  // inputs.
  
  for(std::set<boost::shared_ptr<COdbcConnectionCommand> >::iterator it = mTargetTrees.begin();
      it != mTargetTrees.end();
      ++it)
  {
    // Current rule for connections is that compatible means equal.  For speed we use the md5 hash to determine
    // this.
    if ((*it)->GetHashCode() == resource->GetHashCode())
    {
      // Now look for conflicts among the statements.  The only rule we have now is that two BCPs conflict with
      // each other.
      if ((*it)->GetPreparedBcpStatements().size() > 0 && resource->GetPreparedBcpStatements().size() > 0)
      {
        continue;
      }

      // We have found a compatible resource tree. 
      // Modify the target to have the union of resources.
      (*it)->Union(resource);
      mRegisteredToTargetIndex[resource] = *it;
      // Clear connection pool because existing connections don't have the new resources.
      InternalReinitialize(*it);
      return;
    }
  }

  // We didn't find a compatible connection, so add a copy of the source.
  boost::shared_ptr<COdbcConnectionCommand> copy(new COdbcConnectionCommand(*resource.get()));
  mTargetTrees.insert(copy);
  mRegisteredToTargetIndex[resource] = copy;
}

void COdbcResourceManager::InternalReinitialize(boost::shared_ptr<COdbcConnectionCommand> resource)
{
  mResourceFreePool[resource].clear();

  // Blacklist all allocated connections.
  std::set<COdbcResourceSet *> & allocatedPool = mResourceAllocatedPool[resource];

  mBlacklist.insert(allocatedPool.begin(), allocatedPool.end());
  allocatedPool.clear();
}

void COdbcResourceManager::Reinitialize(boost::shared_ptr<COdbcConnectionCommand> resource)
{
  if (!resource) return;
  AutoCriticalSection acs(&mLock);
  std::map<boost::shared_ptr<COdbcConnectionCommand>, boost::shared_ptr<COdbcConnectionCommand> >::const_iterator it = mRegisteredToTargetIndex.find(resource);
  if (it == mRegisteredToTargetIndex.end()) 
  {
    throw std::logic_error("Connection resource tree not registered");
  }

  InternalReinitialize(it->second);
}

void COdbcResourceManager::ReinitializeAll()
{
  AutoCriticalSection acs(&mLock);
  
  for(std::set<boost::shared_ptr<COdbcConnectionCommand> >::iterator it = mTargetTrees.begin();
      it != mTargetTrees.end();
      ++it)
  {
    InternalReinitialize(*it);
  }
}

COdbcResourceSet * COdbcResourceManager::Allocate(boost::shared_ptr<COdbcConnectionCommand> resource)
{
  if (!resource) return NULL;
  AutoCriticalSection acs(&mLock);
  COdbcResourceSet * r = NULL;
  std::map<boost::shared_ptr<COdbcConnectionCommand>, boost::shared_ptr<COdbcConnectionCommand> >::const_iterator it = mRegisteredToTargetIndex.find(resource);
  if (it == mRegisteredToTargetIndex.end())
    throw std::runtime_error("Connection resource not registered");

  std::set<COdbcResourceSet * > & freePool(mResourceFreePool[it->second]);
  if (freePool.size() > 0)
  {
    r = *freePool.begin();
    freePool.erase(freePool.begin());
  }
  else
  {
    r = new COdbcResourceSet(it->second);
  }
  
  std::set<COdbcResourceSet * > & allocatedPool(mResourceAllocatedPool[it->second]);
  allocatedPool.insert(r);
  return r;
}

void COdbcResourceManager::Free(boost::shared_ptr<COdbcConnectionCommand> resource,  COdbcResourceSet * resourceSet)
{
  if (!resource) return;
  AutoCriticalSection acs(&mLock);
  // Check black list and free if we're on it, otherwise put back on free list.
  std::set<COdbcResourceSet *>::iterator it = mBlacklist.find(resourceSet);
  if (it != mBlacklist.end())
  {
    mBlacklist.erase(it);
    delete resourceSet;
  }
  else
  {
    std::map<boost::shared_ptr<COdbcConnectionCommand>, boost::shared_ptr<COdbcConnectionCommand> >::const_iterator resourceIt = mRegisteredToTargetIndex.find(resource);
    if (resourceIt == mRegisteredToTargetIndex.end())
      throw std::runtime_error("Connection resource not registered");
    it = mResourceAllocatedPool[resourceIt->second].find(resourceSet);
    if (it == mResourceAllocatedPool[resourceIt->second].end())
      throw std::runtime_error("COdbcResourceManager::Free internal error: resourceSet not found in allocated pool");
    mResourceFreePool[resourceIt->second].insert(resourceSet);
    mResourceAllocatedPool[resourceIt->second].erase(it);
  }
}


COdbcResourceSet::COdbcResourceSet(boost::shared_ptr<COdbcConnectionCommand> resource)
  :
  mConnection(NULL)
{
  // Create all resources
  mConnection = new COdbcConnection(resource->GetConnectionInfo());
  // TODO: Implement correct txn semantics.  Right now we only support TXN_AUTO
  mConnection->SetAutoCommit(true);

  for(std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> >::const_iterator it = resource->GetPreparedBcpStatements().begin();
      it != resource->GetPreparedBcpStatements().end();
      ++it)
  {
    mPreparedBcpStatements[*it] = (*it)->Create(mConnection);
  }
  for(std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> >::const_iterator it = resource->GetPreparedArrayStatements().begin();
      it != resource->GetPreparedArrayStatements().end();
      ++it)
  {
    mPreparedArrayStatements[*it] = (*it)->Create(mConnection);
  }
  for(std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> >::const_iterator it = resource->GetPreparedInsertStatements().begin();
      it != resource->GetPreparedInsertStatements().end();
      ++it)
  {
    mPreparedInsertStatements[*it] = (*it)->Create(mConnection);
  }  
}

COdbcResourceSet::~COdbcResourceSet()
{
  for(std::map<boost::shared_ptr<COdbcPreparedBcpStatementCommand>, COdbcPreparedBcpStatement*>::iterator it = mPreparedBcpStatements.begin();
      it != mPreparedBcpStatements.end();
      ++it)
  {
    it->second->Finalize();
    delete it->second;
  }
  mPreparedBcpStatements.clear();

  for(std::map<boost::shared_ptr<COdbcPreparedArrayStatementCommand>, COdbcPreparedArrayStatement*>::iterator it = mPreparedArrayStatements.begin();
      it != mPreparedArrayStatements.end();
      ++it)
  {
    delete it->second;
  }
  mPreparedArrayStatements.clear();

  for(std::map<boost::shared_ptr<COdbcPreparedInsertStatementCommand>, COdbcPreparedArrayStatement*>::iterator it = mPreparedInsertStatements.begin();
      it != mPreparedInsertStatements.end();
      ++it)
  {
    delete it->second;
  }
  mPreparedInsertStatements.clear();

  delete mConnection;
}

COdbcConnection * COdbcResourceSet::GetConnection ()
{
  return mConnection;
}

COdbcPreparedBcpStatement * COdbcResourceSet::operator[] (boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcpStatement)
{
  std::map<boost::shared_ptr<COdbcPreparedBcpStatementCommand>,COdbcPreparedBcpStatement *>::const_iterator it = mPreparedBcpStatements.find(bcpStatement);
  if (it == mPreparedBcpStatements.end())
    throw std::runtime_error("Command not registered");
  return it->second;
}

COdbcPreparedArrayStatement * COdbcResourceSet::operator[] (boost::shared_ptr<COdbcPreparedArrayStatementCommand> arrayStatement)
{
  std::map<boost::shared_ptr<COdbcPreparedArrayStatementCommand>,COdbcPreparedArrayStatement *>::const_iterator it = mPreparedArrayStatements.find(arrayStatement);
  if (it == mPreparedArrayStatements.end())
    throw std::runtime_error("Command not registered");
  return it->second;
}

COdbcPreparedArrayStatement * COdbcResourceSet::operator[] (boost::shared_ptr<COdbcPreparedInsertStatementCommand> insertStatement)
{
  std::map<boost::shared_ptr<COdbcPreparedInsertStatementCommand>,COdbcPreparedArrayStatement *>::const_iterator it = mPreparedInsertStatements.find(insertStatement);
  if (it == mPreparedInsertStatements.end())
    throw std::runtime_error("Command not registered");
  return it->second;
}

COdbcConnectionHandle::COdbcConnectionHandle(MTAutoSingleton<COdbcResourceManager>& manager, boost::shared_ptr<COdbcConnectionCommand> resources)
  :
  mResourceSet(NULL),
  mResources(resources),
  mManager(manager)
{
  mResourceSet = manager->Allocate(resources);
}

COdbcConnectionHandle::~COdbcConnectionHandle()
{
  if (mResourceSet != NULL)
  {
    mManager->Free(mResources, mResourceSet);
  }
}
