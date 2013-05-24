using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using ADOX;
using System.IO;
using MetraTech;

namespace MetraTech.Messaging.Framework.Persistence
{
  public class JetBlueDatabase
  {
    public Logger mLogger = new Logger("[JetBlueDatabase]");
    public void CreateDatabase(string path)
    {
      if (DatabaseExists(path))
      {
        mLogger.LogDebug("Database already exist {0}", GetDataSource(path));
      }
      else
      {
        CreateJetBlueDatabase(path);
        CreateTables(path);
      }
    }

    public bool DatabaseExists(string path)
    {
      Directory.CreateDirectory(path);
      string DataSource = GetDataSource(path);
      return File.Exists(DataSource);
    }

    public void DeleteDatabase(string path)
    {
      string file = GetDataSource(path);
      GC.Collect();
      File.Delete(file);
    }

    public static string ConnectionString(string path)
    {
      return string.Format(@"Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0};Jet OLEDB:Engine Type=5", GetDataSource(path));
    }

    private static string GetDataSource(string path)
    {
      return path + @"\RequestRepository.mdb";
    }

    private void CreateJetBlueDatabase(string path)
    {
      if (DatabaseExists(path)) return;
      ADOX.CatalogClass cat = new ADOX.CatalogClass();
      string connectionString = ConnectionString(path);
      cat.Create(connectionString);
      Marshal.ReleaseComObject(cat);
      cat = null;
      GC.Collect(); // have to do it other wise the db is locked
      mLogger.LogInfo("Database Created Successfully {0}", GetDataSource(path));
    }

    private string CreateRequestsTable = @"
      Create Table Requests (
         CorrelationId GUID,
         CreateDate DateTime,
         TimeoutDate DateTime,
         Request TEXT,
         NeedTimeout BIT,
         ReplyTo TEXT(255)
      )
    ";

    private string CreateCorrelationIdIndex = @"CREATE UNIQUE INDEX correlation_idx ON Requests ( CorrelationId )";
    private string CreateTimeoutIndex = @"CREATE INDEX timeout_idx ON Requests ( TimeoutDate,NeedTimeout )";
    private string CreateArchiveIndex = @"CREATE INDEX archive_idx ON Requests ( CreateDate )";

    private void CreateTables(string path)
    {
      System.Data.OleDb.OleDbConnection conn = new System.Data.OleDb.OleDbConnection();
      //conn.ConnectionString = @"Provider=Microsoft.Jet.OLEDB.4.0;Data source= C:\TEMP\NewMDB.mdb";
      conn.ConnectionString = ConnectionString(path);
      try
      {
        conn.Open();
        System.Data.OleDb.OleDbCommand cmd = conn.CreateCommand();
        cmd.CommandText = CreateRequestsTable;
        cmd.ExecuteNonQuery();
        mLogger.LogDebug("Table created");
        cmd.CommandText = CreateCorrelationIdIndex;
        cmd.ExecuteNonQuery();
        mLogger.LogDebug("CorrelationId Index created");
        cmd.CommandText = CreateTimeoutIndex;
        cmd.ExecuteNonQuery();
        mLogger.LogDebug("Timeout Index created");
        cmd.CommandText = CreateArchiveIndex;
        cmd.ExecuteNonQuery();
        mLogger.LogDebug("Archive Index created");
      }
      catch (Exception ex)
      {
        mLogger.LogException("unable to create tables", ex);
        throw new Exception("unable to create tables", ex);
      }
      finally
      {
        conn.Close();
      }

    }

  }
}
