using System;
using System.Collections;
using System.Diagnostics;
using System.Runtime.InteropServices;

using MetraTech.DataAccess;
using MetraTech;
using MetraTech.Xml;

using QueryAdapter = MetraTech.Interop.QueryAdapter;
using Rowset = MetraTech.Interop.Rowset;


namespace MetraTech.Pipeline
{

	[Guid("c236f065-4799-4b13-bab8-234a951d1170")]
	public interface ISuspendedTxnManager
	{
		/// <summary>
		/// Resubmits any suspended transactions based on the suspended duration
		/// defined in pipeline.xml. Does not resubmit sessions of service definitions
		/// that are marked with "noresubmit".
		/// Returns a count of suspended transactions (messages) that were resubmitted.
		/// </summary>
		int FindAndResubmit();

		Rowset.IMTSQLRowset GetSuspendedMessagesRowset();
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("5b94f74c-1107-439f-a913-418ef9be21fd")]
	public class SuspendedTxnManager : ISuspendedTxnManager
	{

		public SuspendedTxnManager()
		{
			mLogger = new Logger("[SuspendedTxnManager]");
		  ReadConfig();
		}

		// finds and resubmits all suspended transactions based on the definition
		// of suspended given in pipeline.xml
		public int FindAndResubmit()
		{
			return FindAndResubmit(mSuspendedDuration);
		}

		public int FindAndResubmit(int suspendedDuration)
		{
			InitializeNoResubmitFilter();

			mLogger.LogInfo("Calculating set of suspended messages...");

			int count = 0;
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                                                                             "__AUTORESUBMIT_SUSPENDED_MESSAGES__"))
                {
                    stmt.AddParam("%%SUSPENDED_DURATION%%", suspendedDuration);
                    stmt.AddParam("%%SUSPENDED_NORESUBMIT_FILTER%%", (mNoResubmitFilter == null) ? "" : mNoResubmitFilter);
                    count = stmt.ExecuteNonQuery();
                }
			}

			if (count > 0)
				mLogger.LogInfo("{0} suspended messages were successfully resubmitted", count);
			else
				mLogger.LogInfo("No suspended messages were found that could be resubmited");
			
			return count;
		}

		public Rowset.IMTSQLRowset GetSuspendedMessagesRowset()
		{
			Rowset.IMTSQLRowset rowset = new Rowset.MTSQLRowset();
			rowset.Init(@"Queries\Pipeline");
			rowset.SetQueryTag("__GET_SUSPENDED_MESSAGES_FOR_DISPLAY__");
			rowset.AddParam("%%SUSPENDED_DURATION%%", mSuspendedDuration, false);
			rowset.Execute();

			return rowset;
		}


		private void ReadConfig()
		{
			mSuspendedDuration = PipelineConfig.SuspendedDuration;
			mLogger.LogDebug("Messages processing for longer than {0} seconds will be considered suspended", mSuspendedDuration);
			if (mSuspendedDuration < 60)
				mLogger.LogWarning("Suspended duration is set to less than 60 seconds. This may cause long running sessions " + 
													 "to be mistakenly considered suspended!");
		}

		private void InitializeNoResubmitFilter()
		{
			// the initialization of the service def collection object is expensive
			// so the no resubmit filter gets lazily generated
			if (mNoResubmitFilterGenerated)
				return;

			// builds up collections of noresubmit service def IDs
			string noResubmitList = null;
			ServiceDefinitionCollection services = new ServiceDefinitionCollection();
			foreach (string svcDefName in services.Names)
			{
				IServiceDefinition svcDef = services.GetServiceDefinition(svcDefName);
				MetraTech.Interop.MTProductCatalog.IMTAttributes attrs = svcDef.Attributes;

				if (attrs.Exists("noresubmit"))
				{
					string val = (string) ((MetraTech.Interop.MTProductCatalog.IMTAttribute) attrs["noresubmit"]).Value;
					if (string.Compare(val, "Y", true) == 0)
					{
						mLogger.LogDebug("Service definition '{0}' marked as being ineligible for resubmit", svcDef.Name);

						if (noResubmitList == null)
							noResubmitList = svcDef.NameID.ToString();
						else
							noResubmitList += ", " + svcDef.NameID;
						
					}
				}
			}

			if (noResubmitList != null)
			{
				QueryAdapter.IMTQueryAdapter query = new QueryAdapter.MTQueryAdapter();
				query.Init(@"Queries\Pipeline");
				query.SetQueryTag("__SUSPENDED_NORESUBMIT_FILTER__");
				query.AddParam("%%NORESUBMIT_LIST%%", noResubmitList, true);
				mNoResubmitFilter = query.GetQuery();
			}

			mNoResubmitFilterGenerated = true;
		}

		// seconds that must elapse for an "processing" message to be considered suspended
		int mSuspendedDuration; 

		// contains a SQL clause which filters out messages containing service definitions
		// marked with "noresubmit"
		string mNoResubmitFilter = null;
		bool mNoResubmitFilterGenerated = false;

		Logger mLogger;
	}
}
