using System;
using System.Collections;

using System.Messaging;
using System.Diagnostics;
using System.EnterpriseServices;
using System.Text;
using System.IO;
using System.Collections.Specialized;
using System.Runtime.InteropServices;

using MetraTech.Interop.PipelineControl;
using MetraTech.Interop.NameID;
using MetraTech.PipelineInterop;
using MetraTech.DataAccess;
using Rowset = MetraTech.Interop.Rowset;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech;
using MetraTech.Xml;

namespace MetraTech.Pipeline.ReRun
{
	using MetraTech.Interop.MTProgressExec;
  using RCD = MetraTech.Interop.RCD;

	[Guid("de6901d9-d6e5-4c6a-baeb-21eaea5f38f4")]
	public interface IBulkFailedTransactions
	{
		Auth.IMTSessionContext SessionContext{get;set;}

		/// <summary>
		/// Resubmit a set of failed sessions.
		/// </summary>
		void Resubmit(IMessageLabelSet errors, IMTProgress progress,
									Hashtable exceptions);

		/// <summary>
		/// Resubmit a set of failed sessions.
		/// </summary>
		Rowset.IMTSQLRowset ResubmitCollection(IMTCollection errors, IMTProgress progress);

        /// <summary>
        /// Resubmit all the failed transactions that are currently in open or corrected state. (possible states of 'N' or 'C')
        /// </summary>
        int ResubmitAll();
		/// <summary>
		/// Resubmit a set of failed sessions asynchronously. Returns a billing rerun ID that
		/// can be polled for status.
		/// </summary>
		int ResubmitCollectionAsync(IMTCollection errors);

		/// <summary>
		/// Helper function to resubmit a single session.
		/// </summary>
		void ResubmitSession(string sessionID);

		/// <summary>
		/// Delete a set of failed sessions.
		/// </summary>
		void Delete(IMessageLabelSet errors, IMTProgress progress,
								Hashtable exceptions);

		/// <summary>
		/// Delete a set of failed sessions.
		/// </summary>
		Rowset.IMTSQLRowset DeleteCollection(IMTCollection errors, IMTProgress progress);

		/// <summary>
		/// Helper function to delete a single session.
		/// </summary>
		void DeleteSession(string sessionID);

		void ResubmitSuspendedMessage(string messageID);
		void ResubmitSuspendedMessages(IMessageLabelSet messages);
		void ResubmitSuspendedMessageCollection(IMTCollection messages);

		void DeleteSuspendedMessage(string messageID);
		void DeleteSuspendedMessages(IMessageLabelSet messages);
		void DeleteSuspendedMessageCollection(IMTCollection messages);

    /// <summary>
    /// Update the failed transaction status on a set of failed sessions
    /// </summary>
    Rowset.IMTSQLRowset UpdateStatusCollection(IMTCollection errors, string newStatus, string reasonCode, string comment);


	}

  /// <summary>
  /// Resubmits and deletes failed transactions, 
  /// marks corresponding database records transactionally.
	/// INTERNAL USE ONLY
  /// </summary>
  [Guid("19e1e297-31f3-4084-9edb-3a06f50f7cda")]
  public interface IBulkFailureWriter
  {
		Auth.IMTSessionContext SessionContext 
		{
			get;
			set;
		}

		void DeleteFailures(Logger aLogger, 
												IMessageLabelSet errors,
												IMTProgress progress,
												Hashtable exceptions);

		void ResubmitFailures(Logger aLogger, 
													IMessageLabelSet errors,
													IMTProgress progress,
													Hashtable exceptions);

		// resubmits errors asynchronously
		// returns a rerun ID that can be used to query for completion status
		int ResubmitFailuresAsync(Logger aLogger, 
															IMessageLabelSet errors);
      int ResubmitAll(Logger aLogger);

		void DeleteSuspendedMessages(Logger aLogger, IMessageLabelSet messages);
		void ResubmitSuspendedMessages(Logger aLogger, IMessageLabelSet messages);

    void UpdateFailureStatuses(Logger aLogger,
                               IMTCollection idsFailedTransaction,
                               string newStatus,
                               string reasonCode,
                               string comment,
                               Hashtable exceptions);
  }



	/// <summary>
	/// Class used to manage sets of failed transacitons
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("71c90615-eadd-4179-989d-4a264cee870d")]
	public class BulkFailedTransactions : IBulkFailedTransactions
	{
		// resubmit:
		//
		// get error info
		// if (error has saved message)
		//   read message from save area
		// else
		//   read message from queue
		//
		// send message to resubmit queue
		// remove message from error queue
		//
		// if (error has saved message)
		//   delete message from saved area
		// 
		// commit

    private Auth.IMTSessionContext mCtx;
    
    public Auth.IMTSessionContext SessionContext
    {get{return mCtx;}set{mCtx = value;}}

		public BulkFailedTransactions()
		{
		  PipelineConfig config = new PipelineConfig();
		  mDBQueueMode = config.IsDBQueue;
			mLogger = new Logger("[BulkFailedTransactions]");
    }


		public void Resubmit(IMessageLabelSet errors, IMTProgress progress,
												 Hashtable exceptions)
    {
			try
			{
				ResubmitInternal(errors, progress, exceptions);
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		public Rowset.IMTSQLRowset ResubmitCollection(IMTCollection errors, IMTProgress progress)
    {
			try
			{
				IMessageLabelSet messageSet = new MessageLabelSet();
				foreach (string uid in errors)
					messageSet.Add(uid);

				Hashtable exceptions = new Hashtable();
				ResubmitInternal(messageSet, progress, exceptions);

				Rowset.IMTSQLRowset errorRs =
					(Rowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

				errorRs.InitDisconnected();
				errorRs.AddColumnDefinition("tx_uid_encoded","char",256);
				errorRs.AddColumnDefinition("exception","char",256);
				errorRs.OpenDisconnected();

				// get the base rowset back

				foreach (string key in exceptions.Keys)
				{
					errorRs.AddRow();
					errorRs.AddColumnData("tx_uid_encoded", key);
					errorRs.AddColumnData("exception",exceptions[key]);
				}
				if (exceptions.Count > 0)
					errorRs.MoveFirst();
				return errorRs;
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

        public int ResubmitAll()
        {
            IBulkFailureWriter writer = CreateFailureWriter();
            int numResubmitted = writer.ResubmitAll(mLogger);
            return numResubmitted;
        }

		public int ResubmitCollectionAsync(IMTCollection errors)
		{
			try
			{
				IMessageLabelSet messageSet = new MessageLabelSet();
				foreach (string uid in errors)
					messageSet.Add(uid);

				Hashtable exceptions = new Hashtable();

				IBulkFailureWriter writer = CreateFailureWriter();
				int rerunID = writer.ResubmitFailuresAsync(mLogger, messageSet);
				return rerunID;
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		public void ResubmitSession(string sessionID)
    {
			try
			{
				IMessageLabelSet messageSet = new MessageLabelSet();
				messageSet.Add(sessionID);
				ResubmitInternal(messageSet, null, null);
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		private void ResubmitInternal(IMessageLabelSet errors,
																	IMTProgress progress,
																	Hashtable exceptions)
		{
			IBulkFailureWriter writer = CreateFailureWriter();
			writer.ResubmitFailures(mLogger, errors, progress, exceptions);
		}


		// delete
		//
		// get error info
		// remove message from error queue
		// if (error has saved message)
		//   delete message from saved area
		// 
		// commit

		public void Delete(IMessageLabelSet errors, IMTProgress progress,
											 Hashtable exceptions)
		{
			try
			{
				DeleteInternal(errors, progress, exceptions);
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		public Rowset.IMTSQLRowset DeleteCollection(IMTCollection errors, IMTProgress progress)
    {
			try
			{
				IMessageLabelSet messageSet = new MessageLabelSet();
				foreach (string uid in errors)
					messageSet.Add(uid);

				Hashtable exceptions = new Hashtable();
				DeleteInternal(messageSet, progress, exceptions);

				Rowset.IMTSQLRowset errorRs =
					(Rowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

				errorRs.InitDisconnected();
				errorRs.AddColumnDefinition("tx_uid_encoded","char",256);
				errorRs.AddColumnDefinition("exception","char",256);
				errorRs.OpenDisconnected();

				// get the base rowset back

				foreach (string key in exceptions.Keys)
				{
					errorRs.AddRow();
					errorRs.AddColumnData("tx_uid_encoded", key);
					errorRs.AddColumnData("exception",exceptions[key]);
				}
				if (exceptions.Count > 0)
					errorRs.MoveFirst();
				return errorRs;
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		public void DeleteSession(string sessionID)
    {
			try
			{
				IMessageLabelSet messageSet = new MessageLabelSet();
				messageSet.Add(sessionID);

				Hashtable exceptions = new Hashtable();
				DeleteInternal(messageSet, null, null);
			}
			catch (Exception err)
			{
				mLogger.LogError(err.ToString());
				throw;
			}
		}

		public void ResubmitSuspendedMessage(string messageID)
		{
			IMessageLabelSet messages = new MessageLabelSet();
			messages.Add(messageID);
			ResubmitSuspendedMessages(messages);
		}

		public void ResubmitSuspendedMessageCollection(IMTCollection messages)
		{
			IMessageLabelSet messageSet = new MessageLabelSet();
			foreach (string uid in messages)
				messageSet.Add(uid);
			ResubmitSuspendedMessages(messageSet);
		}

		public void ResubmitSuspendedMessages(IMessageLabelSet messages)
		{
			try
			{
				IBulkFailureWriter writer = CreateFailureWriter();
				writer.ResubmitSuspendedMessages(mLogger, messages);
			}
			catch (Exception e)
			{
				mLogger.LogError(e.ToString());
				throw;
			}
		}

		public void DeleteSuspendedMessage(string messageID)
		{
			IMessageLabelSet messages = new MessageLabelSet();
			messages.Add(messageID);
			DeleteSuspendedMessages(messages);
		}

		public void DeleteSuspendedMessageCollection(IMTCollection messages)
		{
			IMessageLabelSet messageSet = new MessageLabelSet();
			foreach (string uid in messages)
				messageSet.Add(uid);
			DeleteSuspendedMessages(messageSet);
		}

		public void DeleteSuspendedMessages(IMessageLabelSet messages)
		{
			try
			{
				IBulkFailureWriter writer = CreateFailureWriter();
				writer.DeleteSuspendedMessages(mLogger, messages);
			}
			catch (Exception e)
			{
				mLogger.LogError(e.ToString());
				throw;
			}
		}

		private void DeleteInternal(IMessageLabelSet errors, IMTProgress progress,
																Hashtable exceptions)
		{
			IBulkFailureWriter writer = CreateFailureWriter();
			writer.DeleteFailures(mLogger, errors, progress, exceptions);
		}

		// this is only used by the MSMQ-based billing rerun 
		// TODO: move this somewhere better
		public void SpoolMessage(MessageQueue queue,
														 byte [] messageBody, string uid, bool express)
		{
			new MessageOps().SpoolMessage(queue, messageBody, uid, express);
		}

		private IBulkFailureWriter CreateFailureWriter()
		{
			IBulkFailureWriter writer;
			if (mDBQueueMode)
				writer = new DBFailureWriter();
			else
				writer = new MSMQFailureWriter();

			writer.SessionContext = SessionContext;

			return writer;
		}

    public Rowset.IMTSQLRowset UpdateStatusCollection(IMTCollection idsFailedTransaction, string newStatus, string reasonCode, string comment)
    {
      IBulkFailureWriter writer = CreateFailureWriter();
      Hashtable exceptions = new Hashtable();
      writer.UpdateFailureStatuses(mLogger, idsFailedTransaction, newStatus, reasonCode, comment, exceptions);

      Rowset.IMTSQLRowset errorRs =
        (Rowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

      errorRs.InitDisconnected();
      errorRs.AddColumnDefinition("tx_FailureCompoundID_encoded","string",30);
      errorRs.AddColumnDefinition("error","int32",4);
      errorRs.AddColumnDefinition("exception","string",256);
      errorRs.OpenDisconnected();

      // construct our rowset of errors
      if (exceptions.Count > 0)
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();

        foreach (string idFailure in exceptions.Keys)
        {
          errorRs.AddRow();
          errorRs.AddColumnData("tx_FailureCompoundID_encoded",idFailure);
          errorRs.AddColumnData("error",exceptions[idFailure]);
          string exceptionMessage = "";
          try {exceptionMessage = rcd.get_ErrorMessage(exceptions[idFailure]);}
          catch{}
          errorRs.AddColumnData("exception",exceptionMessage);
        }

        errorRs.MoveFirst();
      }

      return errorRs;

    }

		private Logger mLogger;
		private bool mDBQueueMode;
	}
}
