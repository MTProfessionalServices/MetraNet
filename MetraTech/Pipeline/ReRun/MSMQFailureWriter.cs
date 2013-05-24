using System;
using System.Collections;
using System.Diagnostics;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Messaging;
using System.Collections.Specialized;
using System.Text;
using System.IO;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.Performance;
using MetraTech.Interop.PipelineControl;
using Auth = MetraTech.Interop.MTAuth;


namespace MetraTech.Pipeline.ReRun
{
	using MetraTech.Interop.MTProgressExec;

	/// <summary>
	/// MSMQFailureWriter represents a concrete IBulkFailureWriter
	/// used internally by the BulkFailedTransactions object when the 
	/// system is configured in MSMQ mode. It operates directly on 
	/// MSMQ queues to resubmit and delete failed transactions.
	/// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
  [Guid("b35240ee-3a97-4d9a-ab1d-4273f62c44a4")]
  public class MSMQFailureWriter : ServicedComponent, IBulkFailureWriter
  {
    public MSMQFailureWriter() { }

		// not used
		public Auth.IMTSessionContext SessionContext 
		{
			get
			{ return null; }
			set
			{ ; }
		}

		public void ResubmitFailures(Logger aLogger, IMessageLabelSet errors, IMTProgress progress, Hashtable exceptions)
		{
			MessageOps ops = new MessageOps();
			ops.ResubmitFailures(aLogger, errors, progress, exceptions);
		}

		public void DeleteFailures(Logger aLogger, IMessageLabelSet errors, IMTProgress progress, Hashtable exceptions)
		{
			MessageOps ops = new MessageOps();
			ops.DeleteFailures(aLogger, errors, progress, exceptions);
      
		}

    public void UpdateFailureStatuses(Logger logger, MetraTech.Interop.PipelineControl.IMTCollection errors, string newStatus, string reasonCode, string comment, Hashtable exceptions)
    {
      //Method not implemented for MSMQFailures (technically the existing method should work for both but the code would have to be reorganized)
      Debug.Assert(false);
      // not needed in v4.0
      throw new ApplicationException("Not implemented!");
    }

    public void ResubmitMessage(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessage, MessageQueue aResubmitQueue, 
																IMTPreparedStatement aMarkFailureStmt, IMTPreparedStatement sUpdateBatchStmt)
    {
			try
			{
				MessageOps ops = new MessageOps();
				ops.ResubmitMessage(aLogger, aCurrentErrorQueueMessage, aResubmitQueue, aMarkFailureStmt, sUpdateBatchStmt);
			}
			catch(Exception)
			{
				//this vote doesn't really matter, because it's decided by the root component
				//ContextUtil.MyTransactionVote = TransactionVote.Abort;
				throw;
			}
			//this vote doesn't really matter, because it's decided by the root component
			//ContextUtil.MyTransactionVote = TransactionVote.Commit;
    }

		[AutoComplete]
		public void ResubmitMessageWithAutoComplete(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessage, MessageQueue aResubmitQueue)
		{
			MessageOps ops = new MessageOps();
			ops.ResubmitMessage(aLogger, aCurrentErrorQueueMessage, aResubmitQueue, null, null);
		}

		public void DeleteMessage(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessage, 
															IMTPreparedStatement aMarkFailureStmt, IMTPreparedStatement sUpdateBatchStmt)
		{
			try
			{
				MessageOps ops = new MessageOps();
				ops.DeleteMessage(aLogger, aCurrentErrorQueueMessage, aMarkFailureStmt, sUpdateBatchStmt);
			}
			catch(Exception)
			{
				//this vote doesn't really matter, because it's decided by the root component
				//ContextUtil.MyTransactionVote = TransactionVote.Abort;
				throw;
			}
			//this vote doesn't really matter, because it's decided by the root component
			//ContextUtil.MyTransactionVote = TransactionVote.Commit;
		}

		[AutoComplete]
		public void DeleteMessageWithAutoComplete(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessage)
		{
			MessageOps ops = new MessageOps();
			ops.DeleteMessage(aLogger, aCurrentErrorQueueMessage, null, null);
		}

		[AutoComplete]
		public void ResubmitSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}

		[AutoComplete]
		public void DeleteSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}

        //This method was added in 5.1 to make it possible to resubmit more than 250000 failed transactions using control pipeline.
        //I am not implementing this using MSMQ as we would never be able to create/handle that many failed transactions using MSMQ, instead of the db.
        [AutoComplete]
        public int ResubmitAll(Logger logger)
        {
          throw new ApplicationException("Not implemented!");
        }

		public int ResubmitFailuresAsync(Logger aLogger, 
																		 IMessageLabelSet errors)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}
  
  }

	  



	/*
	 * The difference between MessageOps class and MessageWriter class
	 * is that the first one is NOT a serviced component, whereas the latter is.
	 * MessageWriter is simply a lightweight COM+ wrapper around MessageOps class, which
	 * implements all resubmit and delete operations.
	 */

	//BP: NOTE: Do not use MessageOps directly (TrxAtomicity to SingleMessage). It is much slower
	//due to an overhead of enlisting MSMQ with dist. transaction. Also, it has not
	//been thoroughly tested

	[ComVisible(false)]
	internal class MessageOps : IBulkFailureWriter
	{
		// not used
		public Auth.IMTSessionContext SessionContext 
		{
			get
			{ return null; }
			set
			{ ; }
		}

		public void ResubmitMessage(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessagePos, MessageQueue aResubmitQueue, 
																IMTPreparedStatement aMarkFailureStmt, IMTPreparedStatement sUpdateBatchStmt)
		{
			Debug.Assert(ContextUtil.IsInTransaction);
			Message msg = aCurrentErrorQueueMessagePos.Current;

			if (PipelineConfig.IsRemote(msg.DestinationQueue))
				throw new RemoteMSMQOperationException();
			
			string uid = msg.Label;
			System.IO.Stream bodyStream = msg.BodyStream;
			long bodyLen = bodyStream.Length;

			byte [] body = new byte[bodyLen];
			int bytesRead = bodyStream.Read(body, 0, (int) bodyLen);
			Debug.Assert(bytesRead == bodyLen);

			IMTSessionError rawSessionError = new MTSessionError();
			rawSessionError.InitFromStream(body);

			SessionError sessionError = new SessionError(rawSessionError);

			string sessionSetID = sessionError.SessionSetID;

			// NOTE: the body must be read first because marking the
			// failure to 'R' prevent us from being able to look it up
			// again.
			string xmlMessage = sessionError.XMLMessage;
			if(aMarkFailureStmt != null && sUpdateBatchStmt != null)
			{
				MarkFailure(aMarkFailureStmt, uid, "R");
				UpdateBatch(sUpdateBatchStmt, uid);
			}
			else
			{
				MarkFailure(uid, "R");
				UpdateBatch(uid);
			}
			SpoolMessage(aResubmitQueue, xmlMessage, sessionSetID, false);

			Message retmsg = aCurrentErrorQueueMessagePos.RemoveCurrent(MessageQueueTransactionType.Automatic);
		}
		
		public void DeleteMessage(Logger aLogger, MessageEnumerator aCurrentErrorQueueMessagePos,
															IMTPreparedStatement aMarkFailureStmt, IMTPreparedStatement sUpdateBatchStmt)
		{
			Debug.Assert(ContextUtil.IsInTransaction);
			Message msg = aCurrentErrorQueueMessagePos.Current;
			string uid = msg.Label;

			if (PipelineConfig.IsRemote(msg.DestinationQueue))
				throw new RemoteMSMQOperationException();
		
			if(aMarkFailureStmt != null && sUpdateBatchStmt != null)
			{
				MarkFailure(aMarkFailureStmt, uid, "D");
				UpdateBatch(sUpdateBatchStmt, uid);
			}
			else
			{
				MarkFailure(uid, "D");
				UpdateBatch(uid);
			}
			

			aCurrentErrorQueueMessagePos.RemoveCurrent(MessageQueueTransactionType.Automatic);

		}


		public void ResubmitFailures(Logger aLogger, 
																 IMessageLabelSet errors,
																 IMTProgress progress,
																 Hashtable exceptions)
		{
			bool bAtLeastOneError = false;
			long msgnum = 0;
			try
			{
			
				using (MessageQueue errorQueue = mPipelineConfig.ErrorQueue,
								 resubmitQueue = mPipelineConfig.ResubmitQueue)
				{
					if (PipelineConfig.IsRemote(errorQueue))
						throw new RemoteMSMQOperationException();

					using(IMTConnection conn = ConnectionManager.CreateConnection())
					{
						IMTPreparedStatement markFailureStmt = null;
						IMTPreparedStatement updateBatchStmt = null;

						//Only utilize prepared statements if this component (MessageOps) was already created
						//in DTC. Otherwise we can not use IMTPreparedStatement because it will be created
						//outside of the DTC context
						if(ContextUtil.IsInTransaction)
						{
							markFailureStmt = GetFailureUpdateQuery(conn);
							updateBatchStmt = GetBatchCountUpdateQuery(conn);
						}
						Debug.Assert(
							(ContextUtil.IsInTransaction == true && markFailureStmt != null && updateBatchStmt != null) ||
							(ContextUtil.IsInTransaction == false && markFailureStmt == null && updateBatchStmt == null));

						// read the labels and message bodies
						errorQueue.MessageReadPropertyFilter.ClearAll();
						errorQueue.MessageReadPropertyFilter.Label = true;
						errorQueue.MessageReadPropertyFilter.Body = true;
						//this property is only used to check for queue "remoteness"
						errorQueue.MessageReadPropertyFilter.DestinationQueue = true;

						MessageEnumerator errorEnum = errorQueue.GetMessageEnumerator();

						int completed = 0;
						int total = errors.Count;
						bool moreMessages = errorEnum.MoveNext();
						bool first = true;
						// update progress bar in 10% increments
						int progressStep = 1;
                        var performanceStopWatch = new PerformanceStopWatch();
                        performanceStopWatch.Start();
						while (moreMessages & errors.Count>0)
						{
							Message msg = null;
							try
							{
								msg = errorEnum.Current;
							}
								/*	
								*		The call to Current
								*		will throw an InvalidOperationException if we just moved past the end.
								*		There is no more elegant way to test for queue enum other than to rely
								*		on InvalidOperationException
								*/
							catch (InvalidOperationException)
							{
								moreMessages = errorEnum.MoveNext();
								
								if (moreMessages)
								{
									/* errorEnum.Current can throw InvalidOperationException
									 *if we are at the end of queue AND if we call RemoveCurrent enough times it
									 * can be pushed all the way back to the position before the first message
									 */
									continue;
								}
								else
									break;
							}

							string label = msg.Label;

							string uid = label;

							// Console.WriteLine("Label: " + uid);
							if (errors.Contains(uid))
							{
								msgnum++;
								try
								{
									aLogger.LogDebug("Resubmitting message with label {0}", uid);
									MSMQFailureWriter writer = new MSMQFailureWriter();
									if(ContextUtil.IsInTransaction)
									{
										//no transaction state flags will be set by ResubmitMessage call
										writer.ResubmitMessage(aLogger, errorEnum, resubmitQueue, markFailureStmt, updateBatchStmt);
									}
									else
										writer.ResubmitMessageWithAutoComplete(aLogger, errorEnum, resubmitQueue);

									
									try
									{
										if(writer != null)
											writer.Dispose();
									}
									catch(Exception){}
									
								
									if (first)
										moreMessages = errorEnum.MoveNext();

									errors.Remove(uid);

									completed++;
									if (progress != null)
									{
										int percent = (completed * 10) / total;
										if (percent >= progressStep)
										{
											progress.SetProgress(completed, total);
											++progressStep;
										}
									}
								}
								catch (Exception err)
								{
									bAtLeastOneError = true;
									//still remove this uid from collection, because otherwise
									//the real exception message would be overwritten by 
									// "Unable to find transaction in queues" message
									errors.Remove(uid);
									aLogger.LogError
										(string.Format("Exception caught resubmitting message with uid {0}: '{1}'", uid, err.Message));


									if (exceptions != null)
									{
										exceptions[uid] = err.Message;

										// skip this message where the error occurred.  Otherwise
										// we get into an infinite loop
										moreMessages = errorEnum.MoveNext();
										first = false;
									}
									else
										throw;
								}

							}
							else
							{
								moreMessages = errorEnum.MoveNext();
								first = false;
							}

                            performanceStopWatch.Stop("MSMQFailureWriter");
						}//while
					}

					//Any transaction left in the error list could not be found in the queues
					foreach (string uid in errors)
					{
						if (exceptions != null)
							exceptions[uid] = "Resubmit Failed Transaction: Unable to find transaction " + uid + " in queues.";
					}
				}
			}
			catch(Exception e)
			{
				//any other unexpected exception - just rollback and throw
				aLogger.LogError(string.Format("Unexpected exception caught resubmitting sessions: '{0}'", e.Message));
				if(ContextUtil.IsInTransaction)
				{
					ContextUtil.SetAbort();
				}
				throw;
			}

			if(ContextUtil.IsInTransaction)
			{
				if(bAtLeastOneError == true)
				{
					aLogger.LogError
						("At least one error was encountered during bulk resubmit operation. The whole set will be rolled back");
					ContextUtil.SetAbort();
				}
				else
					ContextUtil.SetComplete();
			}
		}

		public void DeleteFailures(Logger aLogger,
															 IMessageLabelSet errors,
															 IMTProgress progress,
															 Hashtable exceptions)
		{
			bool bAtLeastOneError = false;
			try
			{

				using (MessageQueue errorQueue = mPipelineConfig.ErrorQueue,
								 resubmitQueue = mPipelineConfig.ResubmitQueue)
				{
					if (PipelineConfig.IsRemote(errorQueue))
						throw new RemoteMSMQOperationException();

					using(IMTConnection conn = ConnectionManager.CreateConnection())
					{
						IMTPreparedStatement markFailureStmt = null;
						IMTPreparedStatement updateBatchStmt = null;
						//Only utilize prepared statements if this component (MessageOps) was already created
						//in DTC. Otherwise we can not use IMTPreparedStatement because it will be created
						//outside of the DTC context
						if(ContextUtil.IsInTransaction)
						{
							markFailureStmt = GetFailureUpdateQuery(conn);
							updateBatchStmt = GetBatchCountUpdateQuery(conn);
						}
						Debug.Assert(
							(ContextUtil.IsInTransaction == true && markFailureStmt != null && updateBatchStmt != null) ||
							(ContextUtil.IsInTransaction == false && markFailureStmt == null && updateBatchStmt == null));


						// read the labels only
						errorQueue.MessageReadPropertyFilter.ClearAll();
						errorQueue.MessageReadPropertyFilter.Label = true;
						errorQueue.MessageReadPropertyFilter.Body = false;
						//this property is only used to check for queue "remoteness"
						errorQueue.MessageReadPropertyFilter.DestinationQueue = true;

						MessageEnumerator errorEnum = errorQueue.GetMessageEnumerator();

						int completed = 0;
						int total = errors.Count;
						bool moreMessages = errorEnum.MoveNext();
						bool first = true;
						// update progress bar in 10% increments
						int progressStep = 1;
						while (moreMessages & errors.Count>0)
						{
							Message msg = null;
							try
							{
								msg = errorEnum.Current;
							}
								/*	
								*		The call to Current
								*		will throw an InvalidOperationException if we just moved past the end.
								*		There is no more elegant way to test for queue enum other than to rely
								*		on InvalidOperationException
								*/
							catch (InvalidOperationException)
							{
								moreMessages = errorEnum.MoveNext();
								
								if (moreMessages)
								{
									/* errorEnum.Current can throw InvalidOperationException
									 * if we are at the end of queue AND if we call RemoveCurrent enough times it
									 * can be pushed all the way back to the position before the first message
									 */
									continue;
								}
								else
									break;
							}

							string label = msg.Label;

							string uid = label;

							if (errors.Contains(uid))
							{
								try
								{
									aLogger.LogDebug("Deleting message with label {0}", uid);
									MSMQFailureWriter writer = new MSMQFailureWriter();
									if(ContextUtil.IsInTransaction)
									{
										//no transaction state flags will be set by ResubmitMessage call
										writer.DeleteMessage(aLogger, errorEnum, markFailureStmt, updateBatchStmt);
									}
									else
										writer.DeleteMessageWithAutoComplete(aLogger, errorEnum);
								
									if (first)
										moreMessages = errorEnum.MoveNext();

									errors.Remove(uid);
									completed++;
									if (progress != null)
									{
										int percent = (completed * 10) / total;
										if (percent >= progressStep)
										{
											progress.SetProgress(completed, total);
											++progressStep;
										}
									}
								}
								catch (Exception err)
								{
									bAtLeastOneError = true;
									//still remove this uid from collection, because otherwise
									//the real exception message would be overwritten by 
									// "Unable to find transaction in queues" message
									errors.Remove(uid);
									aLogger.LogError
										(string.Format("Exception caught deleting message with uid {0}: '{1}'", uid, err.Message));
									if (exceptions != null)
									{
										exceptions[uid] = err.Message;

										// skip this message where the error occurred.  Otherwise
										// we get into an infinite loop
										moreMessages = errorEnum.MoveNext();
										first = false;
									}
									else
										throw;
								}
							}
							else
							{
								moreMessages = errorEnum.MoveNext();
								first = false;
							}
						}
          
						//Any transaction left in the error list could not be found in the queues
						foreach (string uid in errors)
						{
							if (exceptions != null)
								exceptions[uid] = "Unable to find transaction " + uid + " in queues. Marking Failed Transaction Deleted.";
							MarkFailure(markFailureStmt, uid, "D");
							UpdateBatch(updateBatchStmt, uid);
						}
          

					}
				}
			}
			catch(Exception e)
			{
				//any other unexpected exception - just rollback and throw
				aLogger.LogError(string.Format("Unexpected exception caught deleting sessions: '{0}'", e.Message));
				if(ContextUtil.IsInTransaction)
				{
					ContextUtil.SetAbort();
				}
				throw;
			}

			if(ContextUtil.IsInTransaction)
			{
				if(bAtLeastOneError == true)
				{
					aLogger.LogError
						("At least one error was encountered during bulk delete operation. The whole set will be rolled back");
					ContextUtil.SetAbort();
				}
				else
					ContextUtil.SetComplete();
			}
		}


		public void SpoolMessage(MessageQueue queue,
			string message, string uid, bool express)
		{
			Encoding encoder = Encoding.Default;
			byte [] messageBytes = encoder.GetBytes(message);
			SpoolMessage(queue, messageBytes, uid, express);
		}

		public void SpoolMessage(
			MessageQueue queue, byte [] messageBody, string uid, bool express)
		{
			Message message = new Message();
			message.Recoverable = !express;
			message.Label = uid;

			// we send in the byte stream directly
			Stream stream = new MemoryStream();
			stream.Write(messageBody, 0, messageBody.Length);
			message.BodyStream = stream;

			// get the encoded property count structure
			byte [] propCount = CreatePropCount(0, 0, 0, 0);

			message.Extension = propCount;
			message.Priority = MessagePriority.Low;			// standard priority

			queue.Send(message, MessageQueueTransactionType.Automatic);
		}




		private void MarkFailure(IMTPreparedStatement stmt,
			string uid, string newState)
		{
			stmt.ClearParams();
			stmt.AddParam(MTParameterType.String, newState);
			stmt.AddParam(MTParameterType.String, uid);
			stmt.ExecuteNonQuery();
		}

		private void UpdateBatch(IMTPreparedStatement stmt,
			string uid)
		{
			stmt.ClearParams();
			stmt.AddParam(MTParameterType.String, uid);
			stmt.ExecuteNonQuery();
		}

		private void MarkFailure(string uid, string newState)
		{
			//TODO: Move to XML and call Adapter. Don't do it for now
			//to make patch less painful
			string query = String.Format
				("update t_failed_transaction set "
				+ "State = '{0}' where tx_FailureCompoundID_encoded = '{1}'", newState, uid);
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
            }
		}

		private void UpdateBatch(string uid)
		{
			//TODO: Move to XML and call Adapter. Don't do it for now
			//to make patch less painful
			//TODO: Port to Oracle too. It has to be something like this for Oracle
			//update t_batch  set n_failed = n_failed - 1  
			//where exists (select 1 from t_failed_transaction 
			//where t_batch.tx_batch_encoded = t_failed_transaction.tx_Batch_Encoded  and t_failed_transaction.tx_FailureCompoundID_encoded = 
			//'{0}')

			string query = String.Format
				("update t_batch "
				+ " set n_failed = n_failed - 1 "
				+ " from t_batch "
				+ " inner join t_failed_transaction on t_batch.tx_batch_encoded = t_failed_transaction.tx_Batch_Encoded "
				+ " where t_failed_transaction.tx_FailureCompoundID_encoded = '{0}'", uid);
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTStatement stmt = conn.CreateStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
            }
		}

		private byte [] CreatePropCount(int total, int smallStr,
			int mediumStr, int largeStr)
		{
			Stream stream = new MemoryStream();
			BinaryWriter writer = new BinaryWriter(stream);
			writer.Write(total);
			writer.Write(smallStr);
			writer.Write(mediumStr);
			writer.Write(largeStr);

			long propCountLen = stream.Length;
			byte [] propCountStruct = new byte[propCountLen];
			stream.Read(propCountStruct, 0, (int) propCountLen);
			return propCountStruct;
		}

		private IMTPreparedStatement GetFailureUpdateQuery(IMTConnection conn)
		{
			IMTPreparedStatement stmt =
				conn.CreatePreparedStatement(
				"update t_failed_transaction set "
				+ "State = ? where tx_FailureCompoundID_encoded = ?");

			return stmt;
		}

		private IMTPreparedStatement GetBatchCountUpdateQuery(IMTConnection conn)
		{
			IMTPreparedStatement stmt =
				conn.CreatePreparedStatement(
				"update t_batch "
				+ " set n_failed = n_failed - 1 "
				+ " from t_batch "
				+ " inner join t_failed_transaction on t_batch.tx_batch_encoded = t_failed_transaction.tx_Batch_Encoded "
				+ " where t_failed_transaction.tx_FailureCompoundID_encoded = ?");
			return stmt;
		}

    public void UpdateFailureStatuses(Logger logger, MetraTech.Interop.PipelineControl.IMTCollection errors, string newStatus, string reasonCode, string comment, Hashtable exceptions)
    {
      // Method not implemented for MSMQFailures (technically the existing method should work for
			// both but the code would have to be reorganized)
      Debug.Assert(false);
      // not needed in v4.0
      throw new ApplicationException("Not implemented!");
    }

		public void ResubmitSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}

		public void DeleteSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}

		public int ResubmitFailuresAsync(Logger aLogger, 
																		 IMessageLabelSet errors)
		{
			// not needed in v4.0
			throw new ApplicationException("Not implemented!");
		}

        public int ResubmitAll(Logger aLogger)
        {
            // not needed in v5.1
            throw new ApplicationException("Not implemented!");
        }
		private PipelineConfig mPipelineConfig = new PipelineConfig();

	}

	[Guid("ec4a34a1-9153-4aed-864b-d102dd3b3701")]
	public class RemoteMSMQOperationException : ApplicationException
	{
		public RemoteMSMQOperationException() :
			base("Message Queue operations must be executed on the same machine where message queues are installed."){}
	}
 
}

