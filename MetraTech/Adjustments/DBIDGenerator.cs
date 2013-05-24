using System;
using MetraTech.DataAccess;
using System.EnterpriseServices;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for DBIDGenerator.
  /// </summary>
  /// 
  [ComVisible(false)]
  public class DBIDGenerator
  {
    private static DBIDGenerator mInstance;
    private DBIDGenerator()
    {
     mCurrentNum = 0;
     mOffset = 0;
     mBlocksize= 100;
    }
    static DBIDGenerator()
    {
      mInstance = new DBIDGenerator();
    }


    public static DBIDGenerator GetInstance()
    {
      //double checked locking
      if(mInstance == null)
      {
        lock(typeof(DBIDGenerator))
        {
          //never be null
          if(mInstance == null)
            mInstance =  new DBIDGenerator();
        }
      }
      return mInstance;
    }
    public uint NextID(string aIDType)
    {
      lock(typeof(DBIDGenerator))
      {
        if(mCurrentNum == 0 || 
          mCurrentNum + mOffset == mCurrentNum + mBlocksize) 
        {
          FetchNewBlock(aIDType);
        }
        return mCurrentNum + mOffset++;
      }
    }
    public bool Init()
    {
      return true;
    }
   
    private void FetchNewBlock(string aIDType)
    {
      lock(typeof(DBIDGenerator))
      {
          using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
          {
              conn.AutoCommit = false;
              //SELECT ... FOR UPDATE and UPDLOCK will be a transaction duration lock and obviates the need for serializable isolation.
              //conn.IsolationLevel = System.Data.IsolationLevel.Serializable;

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\database", "__NEXT_BATCH_OF_IDS__"))
              {
                  stmt.AddParam("%%IDTYPE%%", aIDType);
                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      reader.Read();
                      mCurrentNum = (uint)reader.GetInt32(0);
                  }
              }

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\database", "__UPDATE_BATCH_IDS__"))
              {
                  stmt.AddParam("%%IDTYPE%%", aIDType);
                  stmt.AddParam("%%NEWVAL%%", (int)(mCurrentNum + mBlocksize));
                  stmt.ExecuteNonQuery();
              }

              conn.CommitTransaction();
          }

      }
    }

    protected uint mCurrentNum;
    protected uint mOffset;
    protected uint mBlocksize;
    protected string mIDType;
  }


  
}
