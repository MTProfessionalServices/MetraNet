namespace MetraTech.Pipeline.Batch
{
	using MetraTech;
	using MetraTech.Utils;
	using MetraTech.DataAccess;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Pipeline.Batch;
	using MetraTech.Interop.MTAuditEvents;
  using System.Runtime.InteropServices;

	using System;
	using System.Diagnostics;
	using System.Web.Services.Protocols;

	[Guid("5c949539-cdad-4114-b56d-338f49d9c301")]
  public interface IBatchObject
	{
		int ID { get; set; }
		string Name { get; set; }
		string Namespace { get; set; }
		string Status { get; set; }
		DateTime CreationDate { get; set; } 
		string Source { get; set; }
		int CompletedCount { get; set; }
		int ExpectedCount { get; set; }
		int FailureCount { get; set; }
		string SequenceNumber { get; set; }
		DateTime SourceCreationDate { get; set; }
		string UID { get; set; } 
		int MeteredCount { get; set; }

		void Save(); 
		void MarkAsActive(string UID, string comment);  
		void MarkAsBackout(string UID, string comment);  
		void MarkAsFailed(string UID, string comment);  
		void MarkAsCompleted(string UID, string comment);  
		void MarkAsDismissed(string UID, string comment);  
		void UpdateMeteredCount(string UID, int meteredCount); 
		void LoadByName(string strName, string strNamespace, string strSequenceNumber);
		void LoadByUID(string UID);

    void SetSessionContext(MTSessionContext user);
	}

	[ComVisible(false)]
	public class BatchException : ApplicationException
	{
		public BatchException(String msg) : base (msg) {}
	}

	/// <summary>
	/// Summary description for BatchObject.
	/// </summary>
  /// 
  [Guid("2e7898ee-1a8b-481a-8e5f-3a9089978458")]
  [ClassInterface(ClassInterfaceType.None)]
	public class BatchObject : IBatchObject
	{
		private int mID;
		public int ID
		{
			get { return mID; }
			set { mID = value; }
		}

		private string mName;
		public string Name
		{
			get { return mName; }
			set { mName = value; }
		}

		private string mNamespace;
		public string Namespace
		{
			get { return mNamespace; }
			set { mNamespace = value; }
		}

		private string mStatus;
		public string Status
		{
			get { return mStatus; }
			set { mStatus = value; }
		}

		private DateTime mCreationDate;
		public DateTime CreationDate
		{
			get { return mCreationDate; }
			set { mCreationDate = value; }
		}

		private string mSource;
		public string Source
		{
			get { return mSource; }
			set { mSource = value; }
		}

		private int mCompletedCount;
		public int CompletedCount
		{
			get { return mCompletedCount; }
			set { mCompletedCount = value; }
		}

		private int mExpectedCount;
		public int ExpectedCount
		{
			get { return mExpectedCount; }
			set { mExpectedCount = value; }
		}

		private int mFailureCount;
		public int FailureCount
		{
			get { return mFailureCount; }
			set { mFailureCount = value; }
		}

		private string mSequenceNumber;
		public string SequenceNumber
		{
			get { return mSequenceNumber; }
			set { mSequenceNumber = value; }
		}

		private DateTime mSourceCreationDate;
		public DateTime SourceCreationDate
		{
			get { return mSourceCreationDate; }
			set { mSourceCreationDate = value; }
		}

		private string mUID;
		public string UID
		{
			get { return mUID; }
			set { mUID = value; }
		}

		private int mMeteredCount;
		public int MeteredCount
		{
			get { return mMeteredCount; }
			set { mMeteredCount = value; }
		}

		public BatchObject()
		{
			mStatus = "";
			mCompletedCount = 0;
			mExpectedCount = 0;
			mFailureCount = 0;
			mSourceCreationDate = MetraTime.Now; // investigate
			mCreationDate = MetraTime.Now;
			mUID = "";
			mName = "";
			mNamespace = "";
			mMeteredCount = 0;

			mAuditor = new Auditor();
			mLogger = new Logger("[BatchObject]");
      mSessionContext = new MTSessionContext();
		}

		public void SetSessionContext(MTSessionContext user)
		{
			mSessionContext = user;
			return;
		}

		public int GetAccountID()
		{
			Debug.Assert(mSessionContext != null);
			return(mSessionContext.AccountID);
		}

		public void Save()
		{
      int threadId = System.Threading.Thread.CurrentThread.ManagedThreadId;

      try
      {
        mLogger.LogDebug("[{0}] Entering BatchObject.Save", threadId);

        if (mSessionContext == null)
          throw new SoapException("Session context must be set first",
                                  SoapException.ServerFaultCode);

        mLogger.LogDebug("[{0}] Create UID", threadId);
        UID = MSIXUtils.CreateUID();
        Status = "A";

        mLogger.LogDebug("[{0}] Check for blank values", threadId);
        // check for blank values for name, namespace and sequence number
        if (Name == "")
          throw new SoapException("Name cannot be blank while creating a batch",
                                  SoapException.ServerFaultCode);
        if (Namespace == "")
          throw new SoapException("Namespace cannot be blank while creating a batch",
                                  SoapException.ServerFaultCode);
        if (SequenceNumber == "")
          throw new SoapException("Sequence Number cannot be blank while creating a batch",
                                  SoapException.ServerFaultCode);

        mLogger.LogDebug("[{0}] Open Connection", threadId);
        int batchID;
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
          mLogger.LogDebug("[{0}] Create statement", threadId);
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertMeteredBatch"))
          {

              mLogger.LogDebug("[{0}] Add Params", threadId);
              byte[] bytes = MSIXUtils.DecodeUID(UID);
              stmt.AddParam("tx_batch", MTParameterType.Binary, bytes);

              stmt.AddParam("tx_batch_encoded", MTParameterType.String, UID);
              stmt.AddParam("tx_source", MTParameterType.String, Source);
              stmt.AddParam("tx_sequence", MTParameterType.String, SequenceNumber);
              stmt.AddParam("tx_name", MTParameterType.WideString, Name);
              stmt.AddParam("tx_namespace", MTParameterType.WideString, Namespace);
              stmt.AddParam("tx_status", MTParameterType.String, Status);

              stmt.AddParam("dt_crt_source", MTParameterType.DateTime, SourceCreationDate);
              stmt.AddParam("dt_crt", MTParameterType.DateTime, MetraTime.Now);

              stmt.AddParam("n_completed", MTParameterType.Integer, 0);
              stmt.AddParam("n_failed", MTParameterType.Integer, FailureCount);
              stmt.AddParam("n_expected", MTParameterType.Integer, ExpectedCount);
              stmt.AddParam("n_metered", MTParameterType.Integer, 0);


              stmt.AddOutputParam("id_batch", MTParameterType.Integer);

              mLogger.LogDebug("[{0}] Execute InsertMeteredBatch", threadId);
              stmt.ExecuteNonQuery();

              batchID = (int)stmt.GetOutputValue("id_batch");
          }

          string msg;
          switch (batchID)
          {
            // MTBATCH_BATCH_ALREADY_EXISTS
            // A batch with name, namespace and sequence number combination 
            // already exists in the database ((DWORD)0xE4020001L)
            case -469630975:
              msg = String.Format("MetraTech Error Code [{0:X}]!", batchID);
              msg += " Batch with name [";
              msg += Name;
              msg += "], namespace [";
              msg += Namespace;
              msg += "] and sequence [";
              msg += SequenceNumber;
              msg += "] already exists in the database";
              throw new SoapException(msg,
                                      SoapException.ServerFaultCode);

            // MTBATCH_BATCH_CREATION_FAILED
            //  Creation of batch failed ((DWORD)0xE4020003L)
            case -1:
              msg = String.Format("MetraTech Error Code [{0:X}]!", -469630973);
              msg += String.Format(" Creation of batch failed");
              throw new SoapException(msg,
                                      SoapException.ServerFaultCode);

            // everything ok
            default:
              ID = batchID;
              break;
          }
        }


        // CR14935 - Removing the following auditing code since it seems to be causing
        // problems with the aggregate rating tests...need to come back to this in a 
        // future release...TRW 6.19.2007
        //mLogger.LogDebug("[{0}] Fire audit event", threadId);
        ////EventId, UserId, EntityTypeId, EntityId, BSTR Details
        //mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_CREATED,
        //                   0,
        //                   (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH,
        //                   batchID,
        //                   "Batch Created");
      }
      catch (Exception e)
      {
        mLogger.LogError("Exception caught in BatchObject.Save(): {0}", e.Message);
      }
      mLogger.LogDebug("[{0}] Exiting Save Method", threadId);
			return;
		}

		public void MarkAsActive(string UID, string comment)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);

			int batchID;
			ProcessUpdates(UID, comment, "A", out batchID);

			// EventId, UserId, EntityTypeId, EntityId, BSTR Details
			mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_MARK_AS_ACTIVE, 
												 GetAccountID(), 
												 (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH, 
												 batchID, 
												 comment); 
			return;
		}

		public void MarkAsBackout(string UID, string comment)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);

			int batchID;
			ProcessUpdates(UID, comment, "B", out batchID);

			mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_MARK_AS_BACKOUT, 
												 GetAccountID(),
												 (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH, 
												 batchID,
												 comment); 
			return;
		}

		public void MarkAsFailed(string UID, string comment)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);

			int batchID;
			ProcessUpdates(UID, comment, "F", out batchID);

			mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_MARK_AS_FAILED, 
												 GetAccountID(),
												 (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH, 
												 batchID,
												 comment); 
			return;
		}

		public void MarkAsDismissed(string UID, string comment)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);

			int batchID;
			ProcessUpdates(UID, comment, "D", out batchID);

			mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_MARK_AS_DISMISSED, 
												 GetAccountID(),
												 (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH, 
												 batchID,
												 comment); 
			return;
		}

		public void MarkAsCompleted(string UID, string comment)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);

			int batchID;
			ProcessUpdates(UID, comment, "C", out batchID);

			mAuditor.FireEvent((int)MTAuditEvent.AUDITEVENT_BATCH_MARK_AS_COMPLETED, 
												 GetAccountID(),
												 (int)MTAuditEntityType.AUDITENTITY_TYPE_BATCH, 
												 batchID,
												 comment); 
			return;
		}

		public void UpdateMeteredCount(string UID, int meteredCount)
		{
			if (mSessionContext == null)
				throw new SoapException("Session context must be set first", 
																SoapException.ServerFaultCode);
            byte[] decodedID = MSIXUtils.DecodeUID(UID);
          

			using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateMeteredCount"))
                {
                    stmt.AddParam("tx_batch", MTParameterType.Binary, decodedID);
                    stmt.AddParam("n_metered", MTParameterType.Integer, meteredCount);
                    stmt.AddParam("dt_change", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();
                    int status = (int)stmt.GetOutputValue("status");

                    if (status == -1)
                    {
                        string msg = String.Format("UpdateMeteredCount failed!");
                        throw new BatchException(msg);
                    }
                }
			}
		
			// assuming its successfull
			MeteredCount = meteredCount;

			return;
		}

		/// <summary>
		/// This method loads the batch object with the data from the database
		/// </summary>
		public void LoadByName(string strName, string strNamespace, string strSequenceNumber)
		{
			using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    "Queries\\MTBatch", "__LOAD_BATCH_BY_NAME__"))
                {
                    stmt.AddParam("%%BATCH_NAME%%", strName);
                    stmt.AddParam("%%BATCH_NAMESPACE%%", strNamespace);
                    stmt.AddParam("%%BATCH_SEQUENCENUMBER%%", strSequenceNumber);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ID = reader.GetInt32("id_batch");
                            Name = strName;
                            Namespace = strNamespace;
                            Status = reader.GetString("tx_status");
                            CreationDate = reader.GetDateTime("dt_crt");
                            if (!reader.IsDBNull("dt_crt_source"))
                            {
                                SourceCreationDate = reader.GetDateTime("dt_crt_source");
                            }
                            Source = reader.GetString("tx_source");
                            CompletedCount = reader.GetInt32("n_completed");
                            ExpectedCount = reader.GetInt32("n_expected");
                            FailureCount = reader.GetInt32("n_failed");
                            SequenceNumber = reader.GetString("tx_sequence");
                            UID = reader.GetString("tx_batch_encoded");
                            MeteredCount = reader.GetInt32("n_metered");
                        }
                        else
                        {
                            // Loading of batch from the database returned 0 rows
                            // MTBATCH_BATCH_LOAD_RETURNED_0_ROWS ((DWORD)0xE4020002L)
                            string msg;
                            msg = String.Format("MetraTech Error Code [{0:X}]!", -469630974);
                            msg += " Loading of Batch for name [";
                            msg += strName;
                            msg += "] and Namespace [";
                            msg += strNamespace;
                            msg += "] and Sequence Number [";
                            msg += strSequenceNumber;
                            msg += "] returned 0 rows";
                            throw new SoapException(msg,
                                                                            SoapException.ServerFaultCode);
                        }
                    }
                }
			}
			return;
		}

		/// <summary>
		/// This method loads the batch object with the data from the database
		/// </summary>
		public void LoadByUID(string aUID)
		{
            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    "Queries\\MTBatch", "__LOAD_BATCH_BY_ENCODED_UID__"))
                {
                    stmt.AddParam("%%BATCH_UID%%", aUID);

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ID = reader.GetInt32("id_batch"); // not null
                            Name = reader.GetString("tx_name"); // not null
                            Namespace = reader.GetString("tx_namespace"); // not null
                            Status = reader.GetString("tx_status");  // not null
                            CreationDate = reader.GetDateTime("dt_crt"); // not null
                            if (!reader.IsDBNull("dt_crt_source"))
                            {
                                SourceCreationDate = reader.GetDateTime("dt_crt_source");
                            }
                            Source = DBUtil.IsNull(reader.GetValue("tx_source"), ""); // NULL
                            CompletedCount = reader.GetInt32("n_completed"); // not null
                            ExpectedCount = DBUtil.IsNull(reader.GetValue("n_expected"), 0); // NULL
                            FailureCount = reader.GetInt32("n_failed"); // not null
                            SequenceNumber = DBUtil.IsNull(reader.GetValue("tx_sequence"), ""); // null
                            MeteredCount = DBUtil.IsNull(reader.GetValue("n_metered"), 0); // null
                            UID = aUID;
                        }
                        else
                        {
                            // Loading of batch from the database returned 0 rows
                            // MTBATCH_BATCH_LOAD_RETURNED_0_ROWS ((DWORD)0xE4020002L)
                            string msg;
                            msg = String.Format("MetraTech Error Code [{0:X}]!", -469630974);
                            msg += " Loading of Batch for UID [";
                            msg += aUID;
                            msg += "] returned 0 rows";
                            throw new SoapException(msg,
                                                                            SoapException.ServerFaultCode);
                        }
                    }
                }
            }
			return;
		}

		//
		//
		//
		protected void ProcessUpdates(string UID, string comment, string newstatus, out int batchID)
		{
            byte[] decodedID = MSIXUtils.DecodeUID(UID);

            using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("ModifyBatchStatus"))
                {
                    stmt.AddParam("tx_batch", MTParameterType.Binary, decodedID);
                    stmt.AddParam("dt_change", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("tx_new_status", MTParameterType.String, newstatus);
                    stmt.AddOutputParam("id_batch", MTParameterType.Integer);
                    stmt.AddOutputParam("tx_current_status", MTParameterType.String, 1);
                    stmt.AddOutputParam("status", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();
                    string currentbatchstatus = (String)stmt.GetOutputValue("tx_current_status");
                    int status = (int)stmt.GetOutputValue("status");
                    string msg;
                    switch (status)
                    {
                        // MTBATCH_BATCH_DOES_NOT_EXIST
                        // An attempt is being made to update a batch that does not 
                        // exist in the system ((DWORD)0xE4020007L)
                        case -469630969:
                            msg = String.Format("MetraTech Error Code [{0:X}]!", status);
                            msg += " An attempt is being made to update a Batch with UID [";
                            msg += UID;
                            msg += "] that does not exist in the system";
                            throw new SoapException(msg,
                                                                            SoapException.ServerFaultCode);


                        // MessageId: MTBATCH_STATE_CHANGE_NOT_PERMITTED
                        // State transition from '%1!s!' to '%2!s!' is not permitted
                        // MTBATCH_STATE_CHANGE_NOT_PERMITTED ((DWORD)0xE4020008L)
                        case -469630968:
                            msg = String.Format("MetraTech Error Code [{0:X}]!", status);
                            msg += " State transition from [";
                            msg += ConvertToLongName(currentbatchstatus);
                            msg += "] to [";
                            msg += ConvertToLongName(newstatus);
                            msg += "] is not permitted";
                            throw new SoapException(msg,
                                                                            SoapException.ServerFaultCode);


                        // MTBATCH_MARK_AS_FAILED_FAILED ((DWORD)0xE4020004L)
                        // Marking a batch as Failed operation did not 
                        // succeed ((DWORD)0xE4020004L)
                        case -1:
                            msg = String.Format("MetraTech Error Code [{0:X}]!", -469630972);
                            msg += " Marking a batch ";
                            msg += ConvertToLongName(newstatus);
                            msg += "] with UID [";
                            msg += UID;
                            msg += "] did not succeed";
                            throw new SoapException(msg,
                                                                            SoapException.ServerFaultCode);

                        // everything ok
                        case 1:
                        default:
                            batchID = (int)stmt.GetOutputValue("id_batch");
                            break;
                    }
                }
            }

			return;
		}

		//
		//
		//
	  protected string ConvertToLongName (string shortname)
		{
			if (0 == String.Compare(shortname, "C", true))
				return "Completed";
			else if (0 == String.Compare(shortname, "D", true))
				return "Dismissed";
			else if (0 == String.Compare(shortname, "B", true))
				return "Backout";
			else if (0 == String.Compare(shortname, "A", true))
				return "Active";
			else if (0 == String.Compare(shortname, "F", true))
				return "Failed";
			else
				return "Unknown Status";
		}

		private Auditor mAuditor;
		private Logger mLogger;
   	private MTSessionContext mSessionContext;
	}
}
