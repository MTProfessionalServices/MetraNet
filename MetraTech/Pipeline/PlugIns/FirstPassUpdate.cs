
using System.Runtime.InteropServices;

//[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]

namespace MetraTech.Pipeline.PlugIns
{
	using MetraTech;
	using MetraTech.Xml;
	using MetraTech.Pipeline;
	using MetraTech.DataAccess;
	using MetraTech.Interop.MTPipelineLib;

	using System;
	using System.Collections;
	using System.Text;
	using System.EnterpriseServices;


	[Guid("4e77ace2-e025-4d33-b8cc-c834a6fca0da")]
	public interface ITransactionChanger
	{
		/// <summary>
		/// Resubmit a set of failed sessions.
		/// </summary>
		void UpdateFirstPassTransaction(IProductViewDefinition firstPass,
																		IProductViewDefinition secondPass,
																		long firstID, long secondID);
	}


	/// <summary>
	/// Class used to manage sets of failed transacitons
	/// </summary>
	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [ClassInterface(ClassInterfaceType.AutoDual)]
	[Guid("8821bc6e-7046-4454-8589-d6dbb12261a2")]
	public class TransactionChanger : ServicedComponent, ITransactionChanger
	{
		public void UpdateFirstPassTransaction(
			IProductViewDefinition firstPass, IProductViewDefinition secondPass,
			long firstID, long secondID)
		{
			string query = GenerateUpdateStatement(firstPass, secondPass, firstID, secondID);
			Logger logger = new Logger("[FirstPassUpdate]");
			logger.LogDebug("Update query:\n{0}", query);
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTStatement stmt = conn.CreateStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
			}
		}

		/*
		public void UpdateFirstPassTransaction(IMTSession session)
		{
			// update first set first.c_col1 = second.c_col1, first.c_col2 = ....
			ProductViewDefinitionCollection collection = new ProductViewDefinitionCollection();
			IProductViewDefinition firstPass = collection.GetProductViewDefinition("metratech.com/songdownloads_temp");
			IProductViewDefinition secondPass = collection.GetProductViewDefinition("metratech.com/songdownloads");
			string query = GenerateUpdateStatement(firstPass, secondPass, 123, 456);
			System.Console.WriteLine(query);
		}
		*/

		public string GenerateUpdateStatement(
			IProductViewDefinition firstPass, IProductViewDefinition secondPass,
			long firstID, long secondID)
		{
			StringBuilder queryBuilder = new StringBuilder();
			queryBuilder.Append("update ");
			queryBuilder.Append(firstPass.TableName);
			queryBuilder.Append(" set\n");

			bool firstProp = true;
			foreach (MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData propMeta in firstPass.Values)
			{
				if (!firstProp)
					queryBuilder.Append(",\n");
				else
					firstProp = false;

				queryBuilder.Append(propMeta.DBColumnName);
				queryBuilder.Append(" = secondPass.");
				queryBuilder.Append(propMeta.DBColumnName);
				queryBuilder.Append(" ");
			}
			queryBuilder.Append("\nfrom ");
			queryBuilder.Append(secondPass.TableName);
			queryBuilder.Append(" secondPass\nwhere ");
			queryBuilder.Append(firstPass.TableName);
			queryBuilder.Append(".id_sess = ");
			queryBuilder.Append(firstID);
			queryBuilder.Append(" and secondPass.id_sess = ");
			queryBuilder.Append(secondID);
			return queryBuilder.ToString();
		}
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("5a8ed699-5860-43b0-93d7-494f5e34d9e8")]
	public class FirstPassUpdate : BatchSkeleton, IBatchPlugIn
	{
		public FirstPassUpdate()
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

			mResubmitCode = nameID.GetNameID("_Resubmit");
			mAggregateRate2Code = nameID.GetNameID("_AggregateRate2");
			mFirstPassIDCode = nameID.GetNameID("_FirstPassID");
			mSessionIDCode = nameID.GetNameID("_SessionID");

			mPVCollection = new ProductViewDefinitionCollection();
		}

		// the skeleton calls ShutdownDatabase so we have nothing
		// else to do
    void IBatchPlugIn.Shutdown()
		{ }

    void IBatchPlugIn.ProcessSessions(IMTSessionSet sessions)
		{
			IMTTransaction transaction = null;

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

						if (RequiresUpdate(session))
						{
							mLogger.LogDebug("session {0} requires update of first pass product view",
															 session.UIDAsString);
							IProductViewDefinition firstPassPV = LookupFirstPassPV(session);
							IProductViewDefinition secondPassPV = LookupSecondPassPV(session);

							long firstPassID = session.GetLongLongProperty(mFirstPassIDCode);
							long secondPassID = session.GetLongLongProperty(mSessionIDCode);

							UpdateFirstPass(firstPassPV, secondPassPV,
															firstPassID, secondPassID, transaction);
						}
						else
						{
							mLogger.LogDebug("no update of first pass product view required for session {0}",
															 session.UIDAsString);
						}
					}
					finally
					{
						// important - explicitly release our reference to the object
						Marshal.ReleaseComObject(session);
					}
				}
			}
			finally
			{
				ICustomAdapter adapter = (ICustomAdapter)enumerator;
				Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
				Marshal.ReleaseComObject(sessions);

				if (firstSession && transaction != null)
					Marshal.ReleaseComObject(transaction);
			}
		}

		void IBatchPlugIn.InitializeDatabase()
		{
		}

		void IBatchPlugIn.ShutdownDatabase()
		{
		}

		private void UpdateFirstPass(
			IProductViewDefinition firstPassPV, IProductViewDefinition secondPassPV,
			long firstPassID, long secondPassID, IMTTransaction txn)
		{
			TransactionChanger updater = null;
			try
			{
				if (txn != null)
				{
					updater = (TransactionChanger)
						BYOT.CreateWithTransaction(txn.GetTransaction(),
																			 typeof(TransactionChanger));
				}
				else
					updater = new TransactionChanger();

				updater.UpdateFirstPassTransaction(firstPassPV, secondPassPV,
																					 firstPassID, secondPassID);
			}
			finally
			{
				if (updater != null)
					updater.Dispose();
			}
		}

		private IProductViewDefinition LookupFirstPassPV(IMTSession session)
		{
			
			IMTNameID nameid = (MetraTech.Interop.MTPipelineLib.IMTNameID)new MetraTech.Interop.NameID.MTNameID();
			string sFirstPassPV =  nameid.GetName(session.ServiceID);
			return mPVCollection.GetProductViewDefinition(sFirstPassPV.ToLower());

		}

		private IProductViewDefinition LookupSecondPassPV(IMTSession session)
		{
			IMTNameID nameid = (MetraTech.Interop.MTPipelineLib.IMTNameID)new MetraTech.Interop.NameID.MTNameID();
			string sSecondPassPV =  nameid.GetName(session.ServiceID);
			int len = sSecondPassPV.Length;
			//remove "_temp"
			sSecondPassPV = sSecondPassPV.Remove(len - 5, 5);
			return mPVCollection.GetProductViewDefinition(sSecondPassPV.ToLower());
		}

		private bool RequiresUpdate(IMTSession session)
		{
			if (session.PropertyExists(mResubmitCode, MTSessionPropType.SESS_PROP_TYPE_BOOL)
					&& session.GetBoolProperty(mResubmitCode)
					// TODO: check aggregate rate 2 flag
					&& session.PropertyExists(mFirstPassIDCode, MTSessionPropType.SESS_PROP_TYPE_LONGLONG))
				return true;
			return false;
		}
		//		private IMTConnection mConnection;
		//		private IMTCallableStatement mBatchUpdate;

		private ProductViewDefinitionCollection mPVCollection;
		private int mResubmitCode;
		private int mAggregateRate2Code;
		private int mFirstPassIDCode;
		private int mSessionIDCode;
	}
}
