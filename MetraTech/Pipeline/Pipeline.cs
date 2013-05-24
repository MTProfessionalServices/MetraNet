using System;
using System.Collections;

using System.Messaging;
using System.Diagnostics;
using System.EnterpriseServices;
using System.Text;
using System.IO;
using System.Collections.Specialized;
using System.Threading;

using MetraTech.Interop.PipelineControl;
using MetraTech.Interop.NameID;
using MetraTech.PipelineInterop;
using MetraTech.DataAccess;
using MetraTech;
using MetraTech.Xml;

using System.Runtime.InteropServices;

[assembly: GuidAttribute("daeeba42-4a9e-4cf9-92ee-409f13820f02")]

namespace MetraTech.Pipeline
{
	using MetraTech.Interop.MTProgressExec;

	[ComVisible(false)]
	public enum TrxAtomicity{SingleMessage, MessageSet}

	[ComVisible(false)]
	public class PipelineConfig : MetraTech.PipelineInterop.PipelineConfig
	{
    public MessageQueue RoutingQueueJournal
		{
			get
			{ return RetrieveQueue(PipelineQueueType.RoutingQueue, true); }
		}

    public MessageQueue ResubmitQueue
		{
			get
			{ return RetrieveQueue(PipelineQueueType.ResubmitQueue); }
		}

    public MessageQueue AuditQueue
		{
			get
			{ return RetrieveQueue(PipelineQueueType.AuditQueue); }
		}

    public MessageQueue ErrorQueue
		{
			get
			{ return RetrieveQueue(PipelineQueueType.ErrorQueue); }
		}

    private MessageQueue RetrieveQueue(PipelineQueueType whichQueue)
		{
			return RetrieveQueue(whichQueue, false);
		}

    private MessageQueue RetrieveQueue(PipelineQueueType whichQueue, bool journal)
		{
			ArrayList queues = PipelineQueues;
			MessageQueue messageQueue = null;
			for (int i = 0; i < queues.Count; i++)
			{
				PipelineQueue queue =
					(PipelineQueue) queues[i];
				if (queue.Type == whichQueue)
				{
					// TODO: handle public queues
					messageQueue = OpenPrivateQueue(queue.MachineName, queue.Name, journal);
					break;
				}
			}
			Debug.Assert(messageQueue != null);
			if (messageQueue == null)
				throw new ApplicationException("Unable to find queue " + whichQueue.ToString());
			return messageQueue;
		}


		public MessageQueue OpenQueue(string machine, string queueName)
		{
			return OpenQueue(machine, queueName, false);
		}

		public MessageQueue OpenQueue(string machine, string queueName, bool journal)
		{
			if (UsePrivateQueues)
				return OpenPrivateQueue(machine, queueName, journal);
			else
			{
				Debug.Assert(false, "Public queues not yet supported");
				return null;
			}
		}

		public static MessageQueue OpenPrivateQueue(string machine, string queueName, bool openJournal)
		{
			System.Text.StringBuilder nameBuilder = new System.Text.StringBuilder();
			if (machine != null && machine.Length > 0)
			{
				// direct remote connection
				nameBuilder.Append("FormatName:DIRECT=OS:");
				nameBuilder.Append(machine);
				nameBuilder.Append("\\PRIVATE$\\");
				nameBuilder.Append(queueName);
				if (openJournal)
					nameBuilder.Append(";JOURNAL");
				return new MessageQueue(nameBuilder.ToString());
			}
			else
			{
				// local connection
				nameBuilder.Append(".\\Private$\\");
				nameBuilder.Append(queueName);
				if (openJournal)
					nameBuilder.Append("\\Journal$");
				string qname = nameBuilder.ToString();
				return new MessageQueue(qname);
			}
		}
			
		public static bool IsRemote(MessageQueue queue)
		{
			// TODO: not a very good test, but this works for the
			// queues we create
			//BP: it actuallty doesn't work, FormatName will always
			//return Formatted name containing DIRECT=OS, even for localhost
			//string qname = queue.FormatName;
			//return qname.StartsWith("DIRECT=OS:");
			
			//Use this method: for local machine it
			//will return "." in machinename property
			string mymachine = System.Windows.Forms.SystemInformation.ComputerName;
			string qmachine = queue.MachineName;
			bool remote = (qmachine != ".") && (qmachine.ToUpper() != mymachine.ToUpper());
			return remote;
		}

		// returns the number of milliseconds that must elapse
		// before a message is considered suspended
		public static int SuspendedDuration
		{
			get
			{
				MTXmlDocument doc = new MTXmlDocument();
				doc.LoadConfigFile("\\pipeline\\pipeline.xml");

				decimal hours = doc.GetNodeValueAsDecimal("/xmlconfig/suspend_restart_period", 6);
				int seconds = Decimal.ToInt32(Decimal.Round(hours * 60 * 60, 0));
				return seconds;
			}
		}


	}

	/// <summary>
	/// A collection of message labels.  Used when performing
	/// set operations.
	/// </summary>
	/// 
	[Guid("b2f97751-bae9-4994-96a5-98988bd41663")]
	public interface IMessageLabelSet
	{
		void Add(string label);
		void Remove(string label);

		int Count
		{ get; }

		bool IsEmpty
		{ get; }

		bool Contains(string label);

		IEnumerator GetEnumerator();

		MessageLabelSet Intersection(IMessageLabelSet other);
	}


	/// <summary>
	/// A collection of message labels.  Used when performing
	/// set operations.
	/// </summary>
	/// 
	[Guid("8d2d9944-8422-4836-b99d-9770edbd41fd")]
	[ClassInterface(ClassInterfaceType.None)]
	public class MessageLabelSet : IMessageLabelSet
	{
		public MessageLabelSet()
		{
			mHashtable = new Hashtable();
		}

		public void Add(string label)
		{
			mHashtable[label] = label;
		}

		public void Remove(string label)
		{
			mHashtable.Remove(label);
		}

		public int Count
		{
			get
			{ return mHashtable.Count; }
		}

		public bool IsEmpty
		{
			get
			{ return Count == 0; }
		}

		public bool Contains(string label)
		{
			return mHashtable.Contains(label);
		}

    public IEnumerator GetEnumerator()
		{
			return mHashtable.Keys.GetEnumerator();
		}


		public MessageLabelSet Intersection(IMessageLabelSet other)
		{
			MessageLabelSet intersection = new MessageLabelSet();

			foreach (string id in this)
			{
				if (other.Contains(id))
					intersection.Add(id);
			}

			return intersection;
		}

		private Hashtable mHashtable;
	}


	[Guid("f899fe92-c419-4f75-a986-8065c6809254")]
	[ClassInterface(ClassInterfaceType.None)]
	public class SessionError : IMTSessionError
	{
		IMTSessionError mError;

		public SessionError(IMTSessionError error)
		{
			mError = error;
		}

		public string ProcedureName
		{
			get
			{
				return mError.ProcedureName;
			}
			set
			{
				mError.ProcedureName = value;
			}
		}

		public string ModuleName
		{
			get
			{
				return mError.ModuleName;
			}
			set
			{
				mError.ModuleName = value;
			}
		}

		public string PlugInName
		{
			get
			{
				return mError.PlugInName;
			}
			set
			{
				mError.PlugInName = value;
			}
		}

		public string StageName
		{
			get
			{
				return mError.StageName;
			}
			set
			{
				mError.StageName = value;
			}
		}

		public string ErrorMessage
		{
			get
			{
				return mError.ErrorMessage;
			}
			set
			{
				mError.ErrorMessage = value;
			}
		}

		public string sessionID
		{
			get
			{
				return mError.sessionID;
			}
			set
			{
				mError.sessionID = value;
			}
		}

		public uint ErrorCode
		{
			get
			{
				return mError.ErrorCode;
			}
			set
			{
				mError.ErrorCode = value;
			}
		}

		public int LineNumber
		{
			get
			{
				return mError.LineNumber;
			}
			set
			{
				mError.LineNumber = value;
			}
		}

		public string IPAddress
		{
			get
			{
				return mError.IPAddress;
			}
		}

		public DateTime FailureTime
		{
			get
			{
				return mError.FailureTime;
			}
		}

		public DateTime MeteredTime
		{
			get
			{
				return mError.MeteredTime;
			}
		}

		public string RootSessionID
		{
			get
			{
				return mError.RootSessionID;
			}
			set
			{
				mError.RootSessionID = value;
			}
		}

		public string SessionSetID
		{
			get
			{
				return mError.SessionSetID;
			}
			set
			{
				mError.SessionSetID = value;
			}
		}

		public string XMLMessage
		{
			get
			{
				MetraTech.Pipeline.Messages.IFailedMSIXMessageUtils utils =
					new MetraTech.Pipeline.Messages.FailedMSIXMessageUtils();
				if (utils.HasSavedFailedTransactionMessage(RootSessionID))
					return utils.LoadFailedTransactionMessage(RootSessionID);
				else
					return OriginalXMLMessage;
			}
			set
			{
				mError.XMLMessage = value;
			}
		}

		public string OriginalXMLMessage
		{
			get
			{
				return mError.OriginalXMLMessage;
			}
			set
			{
				mError.OriginalXMLMessage = value;
			}
		}

		public IMTSession session
		{
			get
			{
				return mError.session;
			}
		}

    public void SaveXMLMessage(string xml, IMTCollection childrenToDelete)
		{
			mError.SaveXMLMessage(xml, childrenToDelete);
		}

		public bool HasSavedXMLMessage
		{
			get
			{
				return mError.HasSavedXMLMessage;
			}
		}

		public void DeleteSavedXMLMessage()
		{
			mError.DeleteSavedXMLMessage();
		}

		public void InitFromStream(byte[] message)
		{
			mError.InitFromStream(message);
		}
	}


	[Guid("930324fa-e591-4342-aa80-2f127e4fe4d8")]
	public interface IPipelineManager
	{
		/// <summary>
		/// Inidicate if pipeline is currently running.
		/// </summary>
		/// <returns></returns>
		bool IsRunning
		{
			get;
		}

		/// <summary>
		/// Instructs all pipelines in the deployment to stop processing new usage.
		/// Blocks until all pipelines finish processing what they are currently
		/// working on. When this method returns, the system is guaranteed to be quiet.
		/// </summary>
		void PauseAllProcessing();

		/// <summary>
		/// Instructs all pipelines in the deployment to resume processing.
		/// This method returns immediately.
		/// </summary>
		void ResumeAllProcessing();
	}


	/// <summary>
	/// Manages various aspects of pipeline operation
	/// </summary>
	[Guid("9332c963-61c5-4923-b409-4a1d6f537e94")]
	[ClassInterface(ClassInterfaceType.None)]
	public class PipelineManager : IPipelineManager
	{
		public bool IsRunning
		{
			get
			{
				using(IMTConnection conn = ConnectionManager.CreateConnection())
				{
					// Get the number of pipelines on line.
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                        "__GET_NUMBER_OF_PIPELINES_RUNNING__"))
                    {
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            reader.Read();
                            if (reader.GetInt32(0) > 0)
                                return true;
                        }
                    }

					return false;
				}
			}
		}

		public void PauseAllProcessing()
		{
			mLogger.LogInfo("Pausing all pipeline processing");
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                // forces the router to stop routing new sessions by 
                // changing the state of t_pipeline rows
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                    "__PAUSE_ALL_PIPELINE_PROCESSING__"))
                {
                    stmt.ExecuteNonQuery();
                }
            }

			try
			{
				using(IMTConnection conn = ConnectionManager.CreateConnection())
				{
					//
					// blocks until all pipelines are fully paused
					//
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                        "__GET_NUMBER_OF_PIPELINES_PROCESSING__"))
                    {
                        int tries = 0;
                        while (true)
                        {
                            mLogger.LogDebug("Waiting for existing pipeline processing to complete - attempt {0}", tries);
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                reader.Read();
                                int processing = reader.GetInt32(0);
                                if (processing == 0)
                                    break;
                            }

                            if (tries++ > 36) // gives up after 3 minutes
                                throw new ApplicationException("Timeout waiting for all pipelines to pause!");

                            Thread.Sleep(5000);
                        }
                    }
				}
				mLogger.LogInfo("All pipelines are now paused");
			}
			catch (Exception e)
			{
				// Make sure to resume processing on any error.
				mLogger.LogDebug("Resuming all pipeline processing");
				ResumeAllProcessing();

				throw e;
			}
		}

		public void ResumeAllProcessing()
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                                                                       "__RESUME_ALL_PIPELINE_PROCESSING__"))
                {
                    stmt.ExecuteNonQuery();
                }
            }
			mLogger.LogInfo("All pipelines have resumed processing");
		}

		Logger mLogger = new Logger("[PipelineManager]");
	}
}

// EOF