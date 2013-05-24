
using System.Runtime.InteropServices;

//[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]
namespace MetraTech.Pipeline.PlugIns
{
	using MetraTech;
	using MetraTech.Utils;
	using MetraTech.DataAccess;
	using MetraTech.Interop.MTPipelineLib;

	using System;
	using System.Collections;
	using System.EnterpriseServices;


	[Guid("30ebf468-a5a9-4f49-a5e9-ebc1c31f567d")]
	public interface IBatchIDWriter
	{
		void UpdateBatchCounts(/* Logger logger, */ IBatchCounts batchCounts);
	}

	[Guid("c8bb435f-d905-4399-a664-adb08c13f8dc")]
	// this class exists just to make it easier to use from C++
	public interface IBatchCounts : IEnumerable
	{
		void AddBatchCount(string batchID, int count);
		void IncrementBatchCount(string batchID);
	}

	[Guid("52dc685b-9df9-428b-9a09-61c782732b37")]
	// ESR-2870 Changed from Hashtable to SortedList to make foreach deterministic
	public class BatchCounts : SortedList, IBatchCounts
	{
		public void AddBatchCount(string batchID, int count)
		{
			this[batchID] = count;
		}

		public void IncrementBatchCount(string batchID)
		{
			if (this[batchID] == null)
				this[batchID] = 1;
			else
				this[batchID] = ((int) this[batchID]) + 1;
		}
	}

	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
	[Guid("d3ccc1d9-2f52-43a6-8348-c7677650264a")]
	public class BatchIDWriter : ServicedComponent, IBatchIDWriter
	{
    [AutoComplete]
		public void UpdateBatchCounts(/* Logger logger, */ IBatchCounts batchCounts)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                DateTime sysDate = MetraTech.MetraTime.Now;
                foreach (DictionaryEntry entry in batchCounts)
                {
                    using (IMTCallableStatement batchUpdate = conn.CreateCallableStatement("UpdateBatchStatus"))
                    {

                        string batchID = (string)entry.Key;
                        byte[] decodedID = MSIXUtils.DecodeUID(batchID);
                        int count = (int)entry.Value;

                        //					logger.LogDebug("{0} sessions found in batch {1}", count, batchID);

                        batchUpdate.AddParam("tx_batch", MTParameterType.Binary,
                                                                    decodedID);
                        batchUpdate.AddParam("tx_batch_encoded", MTParameterType.String,
                                                                    batchID);
                        batchUpdate.AddParam("n_completed", MTParameterType.Integer,
                                                                    count);
                        batchUpdate.AddParam("sysdate", MTParameterType.DateTime,
                                                                    sysDate);
                        batchUpdate.ExecuteNonQuery();
                    }
                }
            }
		}
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("d182e980-3397-4490-9f7d-c4c8c9a74a22")]
	public class BatchUpdate : BatchSkeleton, IBatchPlugIn
	{
		public BatchUpdate()
		{
			// have to tell the base class that we implement the interface
			PlugIn = this;
		}

		void IBatchPlugIn.Configure(Logger logger,
																IMTConfigPropSet propSet,
																IMTNameID nameID,
																IMTSystemContext sysContext)
		{
			mLogger.LogDebug("BatchUpdate plug-in starting");
			SafeToRetry = false;

			mCollectionIDCode = nameID.GetNameID("_CollectionID");
		}

		// the skeleton calls ShutdownDatabase so we have nothing
		// else to do
    void IBatchPlugIn.Shutdown()
		{ }

    void IBatchPlugIn.ProcessSessions(IMTSessionSet sessions)
		{
			throw new ApplicationException("Plug-in temporarily not supported");
			/*
			IMTTransaction transaction = null;

			// count the number of sessions per batch ID
			IBatchCounts batchCounts = new BatchCounts();
			bool firstSession = true;
			IEnumerator enumerator = sessions.GetEnumerator();
			try
			{
				while (enumerator.MoveNext())
				{
					IMTSession session = (IMTSession) enumerator.Current;
					try
					{
						if (firstSession)
						{
							// the transaction comes from the first session
							transaction = session.GetTransaction(true);
							firstSession = true;
						}

						if (session.PropertyExists(mCollectionIDCode,
																			 MTSessionPropType.SESS_PROP_TYPE_STRING))
						{
							string batchID = session.GetStringProperty(mCollectionIDCode);

              batchCounts.IncrementBatchCount(batchID);
						}
					}
					finally
					{
						// important - explicitly release our reference to the object
						Marshal.ReleaseComObject(session);
					}
				}

				UpdateBatchCounts(transaction, batchCounts);
			}
			finally
			{
				ICustomAdapter adapter = (ICustomAdapter)enumerator;
				Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
				Marshal.ReleaseComObject(sessions);
			}
			*/
		}

		void IBatchPlugIn.InitializeDatabase()
		{
			//mConnection = ConnectionManager.CreateConnection();
			//mBatchUpdate = mConnection.CreateCallableStatement("UpdateBatchStatus");
		}

		void IBatchPlugIn.ShutdownDatabase()
		{
			//mBatchUpdate = null;
			//mConnection.Dispose();
			//mConnection = null;
		}

		private void UpdateBatchCounts(IMTTransaction txn, IBatchCounts batchCounts)
		{
			BatchIDWriter writer = null;
			try
			{
				if (txn != null)
				{
					writer = (BatchIDWriter)
						BYOT.CreateWithTransaction(txn.GetTransaction(),
																			 typeof(BatchIDWriter));
				}
				else
					writer = new BatchIDWriter();

				writer.UpdateBatchCounts(/* mLogger, */ batchCounts);
			}
			finally
			{
				if (writer != null)
					writer.Dispose();
			}
		}

		//		private IMTConnection mConnection;
		//		private IMTCallableStatement mBatchUpdate;
		private int mCollectionIDCode;
	}
}
