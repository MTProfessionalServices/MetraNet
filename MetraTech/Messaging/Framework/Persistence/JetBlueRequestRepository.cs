using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.OleDb;

namespace MetraTech.Messaging.Framework.Persistence
{
  using Messages;

  public class JetBlueRequestRepository : IRequestRepository, IDisposable
  {
    private Logger mLogger = new Logger("[JetBlueRequestRepository]");
    private static object mutex = new object();
    private string ConnectionString;
    private OleDbConnection conn;
    private OleDbTransaction txn;
    OleDbCommand cmdStoreRequest;
    OleDbCommand cmdReadRequest;
    OleDbCommand cmdDeleteRequest;
    OleDbCommand cmdCancelTimeout;
    OleDbCommand cmdCancelTimeouts;
    OleDbCommand cmdArchiveRequests;
    OleDbCommand cmdGetTimeouts;


    public JetBlueRequestRepository(string path)
    {
      // If database does not exist - create it first
      JetBlueDatabase db = new JetBlueDatabase();
      db.CreateDatabase(path);

      ConnectionString = JetBlueDatabase.ConnectionString(path);
      conn = new OleDbConnection(ConnectionString);
      conn.Open();
      BeginTxn();
    }

    private string StoreRequestQuery = "insert into Requests (CorrelationId, CreateDate, TimeoutDate, Request, NeedTimeout, ReplyTo) values (@id, @createDate,@timeoutDate,@Request,@needTimeout,@replyTo)";
    private string ReadRequestQuery = "select CreateDate, TimeoutDate, Request, NeedTimeout, ReplyTo from Requests where CorrelationId = @id";
    private string DeleteRequestQuery = "delete from Requests where CorrelationId = @id";
    private string CancelTimeoutQuery = "update Requests set NeedTimeout = false where CorrelationId = @id";
    private string CancelTimeoutsQuery = "update Requests set NeedTimeout = false where TimeoutDate < @timeoutDate and NeedTimeout = true";
    private string ArchiveRequestsQuery = "delete from Requests where CreateDate < @createDate";
    private string GetTimeoutsQuery = "select CorrelationId, CreateDate, TimeoutDate, Request, ReplyTo from Requests where TimeoutDate < @timeoutDate and NeedTimeout = true";

    private void BeginTxn()
    {
      txn = conn.BeginTransaction();
      // Prepare Store Request command
      cmdStoreRequest = conn.CreateCommand();
      cmdStoreRequest.Transaction = txn;
      cmdStoreRequest.CommandText = StoreRequestQuery;
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@id", OleDbType.Guid));
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@createDate", OleDbType.Date));
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@timeoutDate", OleDbType.Date));
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@Request", OleDbType.LongVarChar, -1));
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@needTimeout", OleDbType.Boolean));
      cmdStoreRequest.Parameters.Add(new OleDbParameter("@replyTo", OleDbType.LongVarChar, -1));
      cmdStoreRequest.Prepare();

      // Prepare Read Request command
      cmdReadRequest = conn.CreateCommand();
      cmdReadRequest.Transaction = txn;
      cmdReadRequest.CommandText = ReadRequestQuery;
      cmdReadRequest.Parameters.Add(new OleDbParameter("@id", OleDbType.Guid));
      cmdReadRequest.Prepare();

      // Prepare Delete Request command
      cmdDeleteRequest = conn.CreateCommand();
      cmdDeleteRequest.Transaction = txn;
      cmdDeleteRequest.CommandText = DeleteRequestQuery;
      cmdDeleteRequest.Parameters.Add(new OleDbParameter("@id", OleDbType.Guid));
      cmdDeleteRequest.Prepare();

      // Prepare Cancel Timeout command
      cmdCancelTimeout = conn.CreateCommand();
      cmdCancelTimeout.Transaction = txn;
      cmdCancelTimeout.CommandText = CancelTimeoutQuery;
      cmdCancelTimeout.Parameters.Add(new OleDbParameter("@id", OleDbType.Guid));
      cmdCancelTimeout.Prepare();

      // Prepare Cancel Timeouts command
      cmdCancelTimeouts = conn.CreateCommand();
      cmdCancelTimeouts.Transaction = txn;
      cmdCancelTimeouts.CommandText = CancelTimeoutsQuery;
      cmdCancelTimeouts.Parameters.Add(new OleDbParameter("@timeoutDate", OleDbType.Date));
      cmdCancelTimeouts.Prepare();

      // Prepare Cancel Timeouts command
      cmdArchiveRequests = conn.CreateCommand();
      cmdArchiveRequests.Transaction = txn;
      cmdArchiveRequests.CommandText = ArchiveRequestsQuery;
      cmdArchiveRequests.Parameters.Add(new OleDbParameter("@createDate", OleDbType.Date));
      cmdArchiveRequests.Prepare();

      // Prepare get Timeouts command
      cmdGetTimeouts = conn.CreateCommand();
      cmdGetTimeouts.Transaction = txn;
      cmdGetTimeouts.CommandText = GetTimeoutsQuery;
      cmdGetTimeouts.Parameters.Add(new OleDbParameter("@timeoutDate", OleDbType.Date));
      cmdGetTimeouts.Prepare();
    }

    public void Flush()
    {
      mLogger.LogDebug("JetBlueRequestRepository:Flush() Committing transactions to disk: Start...");
      lock (mutex)
      {
        mLogger.LogDebug("JetBlueRequestRepository:Flush() Lock obtained starting commit...");
        txn.Commit();
        mLogger.LogDebug("JetBlueRequestRepository:Flush() Commit completed");
 
        txn.Dispose();
        txn = null;

        cmdStoreRequest.Dispose();
        cmdReadRequest.Dispose();
        cmdDeleteRequest.Dispose();
        cmdCancelTimeout.Dispose();
        cmdCancelTimeouts.Dispose();
        cmdArchiveRequests.Dispose();
        cmdGetTimeouts.Dispose();

        // TO avoid weird error with running out of locks.
        // TODO: only close connection once in 100 flushes.
        conn.Close();
        conn.Dispose();
        conn = new OleDbConnection(ConnectionString);
        conn.Open();

        BeginTxn();
      }
      mLogger.LogDebug("JetBlueRequestRepository:Flush() Committing transactions to disk: End");
    }

    //CorrelationId GUID CONSTRAINT PrimaryKey PRIMARY KEY,
    //CreateDate DateTime,
    //TimeoutDate DateTime,
    //Request TEXT,


    #region RequestRepository Members

    public void StoreRequest(Request request)
    {
      mLogger.LogDebug("Storing Request {0}", request.MessageBody);
      Guid correlationId = request.CorrelationId;
      DateTime createDate = request.CreateDate;
      DateTime timeoutDate = request.TimeoutDate;
      string body = (request.MessageBody == null) ? "" : request.MessageBody;
      bool needTimeout = request.IsTimeoutNeeded;
      string replyTo = (request.ReplyToAddress == null) ? "" : request.ReplyToAddress;
      lock (mutex)
      {
        cmdStoreRequest.Parameters["@id"].Value = correlationId;
        cmdStoreRequest.Parameters["@createDate"].Value = createDate;
        cmdStoreRequest.Parameters["@timeoutDate"].Value = timeoutDate;
        cmdStoreRequest.Parameters["@Request"].Value = body;
        cmdStoreRequest.Parameters["@needTimeout"].Value = needTimeout;
        cmdStoreRequest.Parameters["@replyTo"].Value = replyTo;
        cmdStoreRequest.ExecuteNonQuery();
      }
    }

    /// <summary>
    /// This class is to avoid any xml parsing inside locks. 
    /// Request is doing XML parsing when created, so light weight class is just to hold properties and do no parsing.
    /// </summary>
    private struct RequestLight
    {
      public Guid CorrelationId;
      public DateTime CreateDate;
      public DateTime TimeoutDate;
      public string MessageBody;
      public bool IsTimeoutNeeded;
      public string ReplyToAddress;
    }

    public Request GetRequest(Guid correlationId)
    {
      mLogger.LogDebug("Reading Request");
      RequestLight tmp = new RequestLight();
      lock (mutex)
      {
        cmdReadRequest.Parameters["@id"].Value = correlationId;
        using (OleDbDataReader reader = cmdReadRequest.ExecuteReader())
        {
          if (reader.Read())
          {
            tmp.CorrelationId = correlationId;
            tmp.CreateDate = reader.GetDateTime(0);
            tmp.TimeoutDate = reader.GetDateTime(1);
            tmp.MessageBody = reader.GetString(2);
            tmp.IsTimeoutNeeded = reader.GetBoolean(3);
            tmp.ReplyToAddress = reader.GetString(4);
            reader.Close();
          }
          else
          {
            reader.Close();
            return null;
          }
        }
      }
      Request msg = new Request();
      msg.CorrelationId = tmp.CorrelationId;
      msg.CreateDate = tmp.CreateDate;
      msg.TimeoutDate = tmp.TimeoutDate;
      msg.MessageBody = tmp.MessageBody;
      msg.IsTimeoutNeeded = tmp.IsTimeoutNeeded;
      msg.ReplyToAddress = tmp.ReplyToAddress;
      return msg;
    }

    public void DeleteRequest(Guid correlationId)
    {
      mLogger.LogDebug("Deleting Request");
      lock (mutex)
      {
        cmdDeleteRequest.Parameters["@id"].Value = correlationId;
        int rowsAffected = cmdDeleteRequest.ExecuteNonQuery();
      }
    }

    public Dictionary<Guid, Request> GetTimeouts(DateTime timeoutDate)
    {
      mLogger.LogDebug("Reading timeout Requests: Start...");
      List<RequestLight> tmpTimeouts = new List<RequestLight>();
      lock (mutex)
      {
        cmdGetTimeouts.Parameters["@timeoutDate"].Value = timeoutDate;
        OleDbDataReader reader = cmdGetTimeouts.ExecuteReader();
        while (reader.Read())
        {
          RequestLight msg = new RequestLight();
          msg.CorrelationId = reader.GetGuid(0);;
          msg.CreateDate = reader.GetDateTime(1);
          msg.TimeoutDate = reader.GetDateTime(2);
          msg.MessageBody = reader.GetString(3);
          msg.IsTimeoutNeeded = true;
          msg.ReplyToAddress = reader.GetString(4);
          tmpTimeouts.Add(msg);
        }
        reader.Close();
      }
      Dictionary<Guid, Request> timeouts = new Dictionary<Guid, Request>();
      foreach (RequestLight requestLight in tmpTimeouts)
      {
        Request request = new Request();
        request.CorrelationId = requestLight.CorrelationId;
        request.CreateDate = requestLight.CreateDate;
        request.TimeoutDate = requestLight.TimeoutDate;
        request.MessageBody = requestLight.MessageBody;
        request.IsTimeoutNeeded = requestLight.IsTimeoutNeeded;
        request.ReplyToAddress = requestLight.ReplyToAddress;
        timeouts.Add(request.CorrelationId, request);
      }
      mLogger.LogDebug("Reading timeout Requests: End");
      return timeouts;
    }

    public bool CancelTimeout(Guid correlationId)
    {
      mLogger.LogDebug("Cancelling timeout for Request");
      int rowsAffected = 0;
      lock (mutex)
      {
        cmdCancelTimeout.Parameters["@id"].Value = correlationId;
        rowsAffected = cmdCancelTimeout.ExecuteNonQuery();
      }
      return rowsAffected > 0;
    }

    public int CancelTimeout(DateTime timeoutDate)
    {
      mLogger.LogDebug("Cancelling timeout for Request");
      int rowsAffected = 0;
      lock (mutex)
      {
        cmdCancelTimeouts.Parameters["@timeoutDate"].Value = timeoutDate;
        rowsAffected = cmdCancelTimeouts.ExecuteNonQuery();
      }
      return rowsAffected;
    }

    public int ArchiveOldRequests(DateTime createDate)
    {
      mLogger.LogTrace("Delete old Requests");
      int rowsAffected = 0;
      lock (mutex)
      {
        cmdArchiveRequests.Parameters["@createDate"].Value = createDate;
        rowsAffected = cmdArchiveRequests.ExecuteNonQuery();
      }
      //If we actually archived something, log it as debug, otherwise log it as traces
      if (rowsAffected > 0)
        mLogger.LogDebug("Delete old Requests - {0} rows deleted", rowsAffected);
      else
        mLogger.LogTrace("Delete old Requests - {0} rows deleted", rowsAffected);
      return rowsAffected;
    }

    #endregion


    #region IDisposable Members

    public void Dispose()
    {
      try
      {
        if (txn != null)
        {
          txn.Commit();
          txn = null;
        }
        if (conn != null)
        {
          conn.Close();
          conn = null;
        }
      }
      catch (Exception)
      {
      }
    }

    ~JetBlueRequestRepository()
    {
      Dispose();
    }

    #endregion

  }
}
