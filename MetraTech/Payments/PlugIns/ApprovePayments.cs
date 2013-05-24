using System.Runtime.InteropServices;

//[assembly: System.EnterpriseServices.ApplicationName("MetraNet")]

namespace MetraTech.Payments.PlugIns
{
	using MetraTech;
	using MetraTech.DataAccess;
	using MetraTech.Interop.MTPipelineLib;

	using System;
	using System.Collections;
	using System.EnterpriseServices;

	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("004B1CBE-C527-38B4-8FF2-780015CD88AB")]
	public class ApprovePaymentsWriter : ServicedComponent
	{
        [AutoComplete]
        internal bool UpdatePaymentStatus(Logger logger, int intervalID, int accountID)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement approvePayments =
                    conn.CreateCallableStatement("ApprovePayments"))
                {

                    // add param here
                    approvePayments.AddParam("id_interval", MTParameterType.Integer, intervalID);
                    approvePayments.AddParam("id_acc", MTParameterType.Integer, accountID);
                    approvePayments.AddOutputParam("status", MTParameterType.Integer);
                    approvePayments.ExecuteNonQuery();

                    int status = (int)approvePayments.GetOutputValue("status");
                    if (status != 0)
                        return false;
                    else
                        return true;
                }
            }
        }
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("bef47ebf-7029-4622-a31e-3b8ea5dbfa4c")]
	public class ApprovePayments : PaymentsSkeleton, IPaymentsPlugIn
	{
		public ApprovePayments()
		{
			// have to tell the base class that we implement the interface
			PlugIn = this;
		}

		void IPaymentsPlugIn.Configure(Logger logger,
									   IMTConfigPropSet propSet,
									   IMTNameID nameID,
									   IMTSystemContext sysContext)
		{
			mLogger.LogDebug("ApprovePayments plug-in starting");
			SafeToRetry = false;

			mIntervalIDCode = nameID.GetNameID("_intervalID");
			mAccounIDCode = nameID.GetNameID("_accountID");
			mStatusCode = nameID.GetNameID("status");
		}

		// the skeleton calls ShutdownDatabase so we have nothing
		// else to do
		void IPaymentsPlugIn.Shutdown()
		{ }

		//TODO -- its not a session set
		void IPaymentsPlugIn.ProcessSessions(IMTSessionSet sessions)
		{
			IMTTransaction transaction = null;

			// count the number of sessions per batch ID
			Hashtable batchCounts = new Hashtable();
			bool firstSession = true;
			IEnumerator enumerator = sessions.GetEnumerator();
			long intervalID;
			long accounID;

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

						intervalID = session.GetLongProperty(mIntervalIDCode);
						accounID = session.GetLongProperty(mAccounIDCode);
						if (!UpdatePaymentStatus(transaction, (int)intervalID, (int) accounID))
							session.SetLongProperty (mStatusCode, -1);
						else
							session.SetLongProperty (mStatusCode, 0);
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
				// important - explicitly release our reference to the object
				ICustomAdapter adapter = (ICustomAdapter)enumerator;
				Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
				Marshal.ReleaseComObject(sessions);
			}
		}

		void IPaymentsPlugIn.InitializeDatabase()
		{
		}

		void IPaymentsPlugIn.ShutdownDatabase()
		{
		}

		private bool UpdatePaymentStatus(IMTTransaction txn, int intervalID, int accounID)
		{
			ApprovePaymentsWriter writer = null;
			try
			{
				if (txn != null)
				{
					writer = (ApprovePaymentsWriter)
						BYOT.CreateWithTransaction(txn.GetTransaction(),
												   typeof(ApprovePaymentsWriter));
				}
				else
					writer = new ApprovePaymentsWriter();

				if (!writer.UpdatePaymentStatus(mLogger, intervalID, accounID))
					return false;
				else
					return true;
			}
			finally
			{
				if (writer != null)
					writer.Dispose();
			}
		}

		private int mIntervalIDCode;
		private int mAccounIDCode;
		private int mStatusCode;
	}
}

// EOF