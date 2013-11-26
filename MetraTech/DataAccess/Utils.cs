

using System.Globalization;

namespace MetraTech.DataAccess
{
  using System;
  using System.Diagnostics;
  using System.Runtime.InteropServices;
  using System.Transactions;
  using System.EnterpriseServices;

  [Guid("9417b7ec-bbfb-4f1c-ad39-815859697862")]
  [ComVisible(true)]
  [Obsolete("Use MetraTech.DataAccess.IIdGenerator2", true)]
  public interface IIdGenerator
  {
    void Initialize(string columnName,
                    int blockSize);

    int NextId
    { get; }

    int BlockSize
    { set; }

    int GetBlock(int n);
  }

  [Guid("5EAC62D4-0C12-444f-9035-0B14E2BEEC0E")]
  [ComVisible(true)]
  public interface IIdGenerator2
  {
    void Initialize(string columnName,
                    int blockSize);

    int NextId
    { get; }

    int NextIdForImportExport
    { get; }

    int BlockSize
    { set; }

    int NextMashedId
    { get; }
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("ecaa1960-283a-4086-936a-d6ef92ce547a")]
  [ComVisible(true)]
  public class IdGenerator : IIdGenerator2
  {
    public IdGenerator()
    {
      mColumnName = "";
      mBlockSize = 1000;
    }

    public IdGenerator(string columnName)
    {
      mColumnName = columnName;
      mBlockSize = 1000;
    }

    public IdGenerator(string columnName, int blockSize)
    {
      mColumnName = columnName;
      mBlockSize = blockSize;
    }

    public void Initialize(string columnName, int blockSize)
    {
      mColumnName = columnName;
      mBlockSize = blockSize;
    }

    public int NextId
    {
      get
      {
        lock (this)
        {
          if (mCurrentBlockStart == mCurrentBlockEnd)
          {
            GetNextBlock();
            Debug.Assert(mCurrentBlockStart < mCurrentBlockEnd);
          }
          return mCurrentBlockStart++;
        }
      }
    }

    public int NextIdForImportExport
    {
      get
      {
        lock (this)
        {
          if (mCurrentBlockStart == mCurrentBlockEnd)
          {
            GetNextBlockForImportExport();
            Debug.Assert(mCurrentBlockStart < mCurrentBlockEnd);
          }
          return mCurrentBlockStart++;
        }
      }
    }

    public int NextMashedId
    {
      get
      {
        int tmp = 0;

        do
        {
          tmp = NextId;
          tmp += (tmp << 12);
          tmp &= 0x7fffffff;

          tmp ^= (tmp >> 22);

          tmp += (tmp << 4);
          tmp &= 0x7fffffff;

          tmp ^= (tmp >> 9);

          tmp += (tmp << 10);
          tmp &= 0x7fffffff;

          tmp ^= (tmp >> 2);

          tmp += (tmp << 7);
          tmp &= 0x7fffffff;

          tmp ^= (tmp >> 12);
        } while (tmp < mMinimumId);

        return tmp;
      }
    }

    // set block size
    public int BlockSize
    {
      set
      {
        lock (this)
        {
          Debug.Assert(value > 0);
          mBlockSize = value;
        }
      }
    }

    // reserve n consecutive IDs (where n <= blockSize)
    [Obsolete("The IDGenerator can be used to allocate and cache a block without this method")]
    public int GetBlock(int n)
    {
      Debug.Assert(n <= mBlockSize);

      lock (this)
      {
        if (mCurrentBlockStart + n < mCurrentBlockEnd)
        {
          int temp = mCurrentBlockStart;
          mCurrentBlockStart += n;
          Debug.Assert(mCurrentBlockStart < mCurrentBlockEnd);
          return temp;
        }
        else
        {
          // this would go over our block size
          GetNextBlock();
          // Use (n - 1) below because we should count the value in
          // mCurentBlockStart as one of the values we are returning.
          //
          // Example:   I request a block of 100 ids.
          // mCurrentBlockStart is 100.  mCurrentBlockEnd is
          // mCurrentBlockStart plus our internal block size (or 200).
          // So we want to insure that we have 100 ids.  In this case
          // we do, we have the ids from 100 to 199.  mCurrentBlockStart
          // + 100 is 200 but we only need up to 199 (100 to 199 is 100
          // ids).  So the assert below wants to be mCurrentBlockStart
          // Plus the block size minus 1.  This assert would fail
          // anytime that you requested a block of ids that was the
          // same size as the internal block size if you were to test
          // against (mCurrentBlockStart + n < mCurrentBlockEnd) even
          // though we have enough ids to satisfy the request.
          Debug.Assert(mCurrentBlockStart + (n - 1) < mCurrentBlockEnd);
          int temp = mCurrentBlockStart;
          mCurrentBlockStart += n;
          return temp;
        }
      }
    }

    private static object m_AllocationLock = new object();

    private void GetNextBlock()
    {
      //lock (m_AllocationLock)
      {
        IIdBlockAllocator blockAllocator = new IdBlockAllocator();
        int blockStart, minId;
        blockAllocator.GetNextBlock(mColumnName, mBlockSize, out blockStart, out minId);

        mCurrentBlockStart = blockStart;
        mCurrentBlockEnd = mCurrentBlockStart + mBlockSize;
        mMinimumId = minId;
      }
    }
    
    private void GetNextBlockForImportExport()
    {
      var blockAllocator = new IdBlockAllocatorTransactional();
      int blockStart, minId;
      blockAllocator.GetNextBlock(mColumnName, mBlockSize, out blockStart, out minId);

      mCurrentBlockStart = blockStart;
      mCurrentBlockEnd = mCurrentBlockStart + mBlockSize;
      mMinimumId = minId;
    }

    //private void GetNextBlock()
    //{
    //  // Using a transaction scope that requires a new transaction and has full COM+ context synchronization
    //  // removes the need for the IDGeneratorWrapper.  The COM+ synchronizaiton will allow this code to play
    //  // well with COM+ objects
    //  using (TransactionScope scope =
    //            new TransactionScope(TransactionScopeOption.Suppress,
    //                                new TransactionOptions(),
    //                                EnterpriseServicesInteropOption.Automatic))
    //  {
    //    // NOTE: we reopen a connection each time we get a block of IDs.
    //    //  this is to avoid the danger of leaving the connection open
    //    //  if the object isn't disposed of correctly.
    //    using (IMTConnection conn = ConnectionManager.CreateConnection())
    //    {

    //      if (mSelectQuery == null)
    //      {
    //        if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
    //          mSelectQuery = String.Format("SELECT id_current, id_min_id FROM t_current_id WITH(UPDLOCK) WHERE nm_current = '{0}'", mColumnName);
    //        else
    //          mSelectQuery = String.Format("SELECT id_current, id_min_id FROM t_current_id WHERE nm_current = '{0}' FOR UPDATE OF id_current", mColumnName);

    //        mUpdateQuery = String.Format("UPDATE t_current_id SET id_current=id_current+{0} where nm_current='{1}'", mBlockSize, mColumnName);
    //      }

    //      //SELECT ... FOR UPDATE and UPDLOCK will be a transaction duration lock and obviates the need for serializable isolation.
    //      //conn.IsolationLevel = System.Data.IsolationLevel.Serializable;

    //      IMTStatement stmt = conn.CreateStatement(mSelectQuery);

    //      using (IMTDataReader reader = stmt.ExecuteReader())
    //      {
    //        if (!reader.Read())
    //          throw new DataAccessException("No rows returned from query to t_current_id");

    //        int start = reader.GetInt32(0);

    //        mCurrentBlockStart = start;
    //        mCurrentBlockEnd = start + mBlockSize;

    //        if (!reader.IsDBNull(1))
    //        {
    //          mMinimumId = reader.GetInt32(1);
    //        }

    //        if (reader.Read())
    //          throw new DataAccessException("More than one row returned from query to t_current_id");
    //      }

    //      stmt = conn.CreateStatement(mUpdateQuery);

    //      stmt.ExecuteNonQuery();

    //    }

    //    scope.Complete();
    //  }
    //}

    public string ColumnName
    {
      get { return mColumnName; }
    }

    string mColumnName;
    int mBlockSize;

    //string mSelectQuery;
    //string mUpdateQuery;

    int mCurrentBlockStart = 0;
    int mCurrentBlockEnd = 0;
    int mMinimumId = 1000;
    
  }

  [ComVisible(true)]
  [Guid("46b7b3ea-a8ce-4b5b-8f16-518764c64936")]
  public interface IIdBlockAllocator
  {
    void GetNextBlock(string blockName, int blockSize, out int blockStart, out int minId);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.NotSupported)]
  [ComVisible(true)]
  [Guid("83e9a272-8fae-4231-915d-2adf3e008e97")]
  public class IdBlockAllocator : ServicedComponent, IIdBlockAllocator
  {
    public IdBlockAllocator()
    {
    }

    public void GetNextBlock(string blockName, int blockSize, out int blockStart, out int minId)
    {
      blockStart = -1;
      minId = -1;

      // NOTE: we reopen a connection each time we get a block of IDs.
      //  this is to avoid the danger of leaving the connection open
      //  if the object isn't disposed of correctly.
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {

          string selectQuery = null;

          if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
              selectQuery = String.Format("SELECT id_current, id_min_id FROM t_current_id WITH(UPDLOCK) WHERE nm_current = '{0}'", blockName);
          else
              selectQuery = String.Format("SELECT id_current, id_min_id FROM t_current_id WHERE nm_current = '{0}' FOR UPDATE OF id_current", blockName);

          string updateQuery = String.Format("UPDATE t_current_id SET id_current=id_current+{0} where nm_current='{1}'", blockSize, blockName);


          //SELECT ... FOR UPDATE and UPDLOCK will be a transaction duration lock and obviates the need for serializable isolation.
          //conn.IsolationLevel = System.Data.IsolationLevel.Serializable;
          conn.AutoCommit = false;
          using (IMTStatement stmt = conn.CreateStatement(selectQuery))
          {

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (!reader.Read())
                  {
                      conn.RollbackTransaction();
                      throw new DataAccessException("No rows returned from query to t_current_id");
                  }

                  int start = reader.GetInt32(0);

                  blockStart = start;

                  if (!reader.IsDBNull(1))
                  {
                      minId = reader.GetInt32(1);
                  }

                  if (reader.Read())
                  {
                      conn.RollbackTransaction();
                      throw new DataAccessException("More than one row returned from query to t_current_id");
                  }
              }
          }
          
          using (IMTStatement stmt = conn.CreateStatement(updateQuery))
          {

              stmt.ExecuteNonQuery();
          }
          
          conn.CommitTransaction();
      }
    }
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported)]
  [ComVisible(true)]
  [Guid("B1889E7E-8933-429E-8DDB-CCE4C37D90DC")]
  public class IdBlockAllocatorTransactional : IIdBlockAllocator
  {
    public void GetNextBlock(string blockName, int blockSize, out int blockStart, out int minId)
    {
      blockStart = -1;
      minId = -1;
      
      using (var tran = new TransactionScope())
      {
        using (var conn = ConnectionManager.CreateNonServicedConnection())
        {
          var selectQuery = String.Format(CultureInfo.InvariantCulture,
                                          conn.ConnectionInfo.DatabaseType == DBType.SQLServer
                                            ? "SELECT id_current, id_min_id FROM t_current_id WITH(UPDLOCK) WHERE nm_current = '{0}'"
                                            : "SELECT id_current, id_min_id FROM t_current_id WHERE nm_current = '{0}' FOR UPDATE OF id_current",
                                          blockName);

          var updateQuery = String.Format(CultureInfo.InvariantCulture,
                                          "UPDATE t_current_id SET id_current=id_current+{0} where nm_current='{1}'",
                                          blockSize, blockName);

          using (var stmt = conn.CreateStatement(selectQuery))
          {
            using (var reader = stmt.ExecuteReader())
            {
              if (!reader.Read())
                throw new DataAccessException("No rows returned from query to t_current_id");

              var start = reader.GetInt32(0);

              blockStart = start;

              if (!reader.IsDBNull(1))
                minId = reader.GetInt32(1);

              if (reader.Read())
                throw new DataAccessException("More than one row returned from query to t_current_id");
            }
          }

          using (var stmt = conn.CreateStatement(updateQuery))
          {
            stmt.ExecuteNonQuery();
          }

          tran.Complete();
        }
      }
    }
  }

  [Guid("c83fcc12-e38a-41a8-bd1e-57c5f211517b")]
  [ComVisible(true)]
  public interface ILongIdGenerator
  {
    void Initialize(string columnName,
                    long blockSize);

    long NextId
    { get; }

    long BlockSize
    { set; }

    long GetBlock(long n);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("e280850a-0b52-4a01-b16a-51ffb9e2da73")]
  [ComVisible(true)]
  public class LongIdGenerator : ILongIdGenerator
  {
    public LongIdGenerator()
    {
      mColumnName = "";
      mBlockSize = 1000;
    }

    public LongIdGenerator(string columnName)
    {
      mColumnName = columnName;
      mBlockSize = 10000;
    }

    public LongIdGenerator(string columnName, long blockSize)
    {
      mColumnName = columnName;
      mBlockSize = blockSize;
    }

    public void Initialize(string columnName, long blockSize)
    {
      mColumnName = columnName;
      mBlockSize = blockSize;
    }

    public long NextId
    {
      get
      {
        lock (this)
        {
          if (mCurrentBlockStart == mCurrentBlockEnd)
          {
            GetNextBlock();
            Debug.Assert(mCurrentBlockStart < mCurrentBlockEnd);
          }
          return mCurrentBlockStart++;
        }
      }
    }

    // set block size
    public long BlockSize
    {
      set
      {
        lock (this)
        {
          Debug.Assert(value > 0);
          mBlockSize = value;
        }
      }
    }

    // reserve n consecutive IDs (where n <= blockSize)
    public long GetBlock(long n)
    {
      Debug.Assert(n <= mBlockSize);

      lock (this)
      {
        if (mCurrentBlockStart + n < mCurrentBlockEnd)
        {
          long temp = mCurrentBlockStart;
          mCurrentBlockStart += n;
          Debug.Assert(mCurrentBlockStart < mCurrentBlockEnd);
          return temp;
        }
        else
        {
          // this would go over our block size
          GetNextBlock();
          // Use (n - 1) below because we should count the value in
          // mCurentBlockStart as one of the values we are returning.
          //
          // Example:   I request a block of 100 ids.
          // mCurrentBlockStart is 100.  mCurrentBlockEnd is
          // mCurrentBlockStart plus our internal block size (or 200).
          // So we want to insure that we have 100 ids.  In this case
          // we do, we have the ids from 100 to 199.  mCurrentBlockStart
          // + 100 is 200 but we only need up to 199 (100 to 199 is 100
          // ids).  So the assert below wants to be mCurrentBlockStart
          // Plus the block size minus 1.  This assert would fail
          // anytime that you requested a block of ids that was the
          // same size as the internal block size if you were to test
          // against (mCurrentBlockStart + n < mCurrentBlockEnd) even
          // though we have enough ids to satisfy the request.
          Debug.Assert(mCurrentBlockStart + (n - 1) < mCurrentBlockEnd);
          long temp = mCurrentBlockStart;
          mCurrentBlockStart += n;
          return temp;
        }
      }
    }

    private void GetNextBlock()
    {
      // NOTE: we reopen a connection each time we get a block of IDs.
      //  this is to avoid the danger of leaving the connection open
      //  if the object isn't disposed of correctly.
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            if (mSelectQuery == null)
            {
                if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
                    mSelectQuery = String.Format("SELECT id_current FROM t_current_long_id WITH(UPDLOCK) WHERE nm_current = '{0}'", mColumnName);
                else
                    mSelectQuery = String.Format("SELECT id_current FROM t_current_long_id WHERE nm_current = '{0}' FOR UPDATE OF id_current", mColumnName);

                mUpdateQuery = String.Format("UPDATE t_current_long_id SET id_current=id_current+{0} where nm_current='{1}'", mBlockSize, mColumnName);
            }

            conn.AutoCommit = false;
            //SELECT ... FOR UPDATE and UPDLOCK will be a transaction duration lock and obviates the need for serializable isolation.
            //conn.IsolationLevel = System.Data.IsolationLevel.Serializable;

            using (IMTStatement stmt = conn.CreateStatement(mSelectQuery))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (!reader.Read())
                        throw new DataAccessException("No rows returned from query to t_current_long_id");

                    long start = reader.GetInt64(0);

                    mCurrentBlockStart = start;
                    mCurrentBlockEnd = start + mBlockSize;

                    if (reader.Read())
                        throw new DataAccessException("More than one row returned from query to t_current_long_id");
                }
            }

            using(IMTStatement stmt = conn.CreateStatement(mUpdateQuery))
            {
                stmt.ExecuteNonQuery();
            }

            conn.CommitTransaction();
        }
    }

    string mColumnName;
    long mBlockSize;

    string mSelectQuery;
    string mUpdateQuery;

    long mCurrentBlockStart = 0;
    long mCurrentBlockEnd = 0;
  }
}
