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
	[Guid("55B8034D-72EB-30F1-87C3-93B80F7267B1")]
	public class ReversePaymentWriter : ServicedComponent
	{
        [AutoComplete]
        internal bool UpdatePaymentStatus(Logger logger, int intervalID, int accountID, int pendingapprovalenumID)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement reversePayments = conn.CreateCallableStatement("ReversePayments"))
                {

                    // add param here
                    reversePayments.AddParam("id_interval", MTParameterType.Integer, intervalID);
                    reversePayments.AddParam("id_acc", MTParameterType.Integer, accountID);
                    reversePayments.AddParam("id_enum", MTParameterType.Integer, pendingapprovalenumID);
                    reversePayments.AddOutputParam("status", MTParameterType.Integer);
                    reversePayments.ExecuteNonQuery();


                    int status = (int)reversePayments.GetOutputValue("status");
                    if (status != 0)
                        return false;
                    else
                        return true;
                }
            }
        }
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("c16cc049-ce61-46e3-a6a6-f9945b1a47fb")]
	public class ReversePayments : PaymentsSkeleton, IPaymentsPlugIn
	{
		public ReversePayments()
		{
			// have to tell the base class that we implement the interface
			PlugIn = this;
		}

		void IPaymentsPlugIn.Configure(Logger logger,
									   IMTConfigPropSet propSet,
									   IMTNameID nameID,
									   IMTSystemContext sysContext)
		{
			mLogger.LogDebug("ReversePayments plug-in starting");
			SafeToRetry = false;

			mIntervalIDCode = nameID.GetNameID("_intervalID");
			mAccounIDCode = nameID.GetNameID("_accountID");
			mPendingApprovalEnumCode = nameID.GetNameID("pendingapprovalenum");
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
			long accountID;
			long pendingapprovalenumID;

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
						accountID = session.GetLongProperty(mAccounIDCode);
						pendingapprovalenumID = session.GetEnumProperty(mPendingApprovalEnumCode);
						if (!UpdatePaymentStatus(transaction, (int)intervalID, (int)accountID, (int)pendingapprovalenumID))
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

		private bool UpdatePaymentStatus(IMTTransaction txn, int intervalID, int accountID, int pendingapprovalenumID)
		{
			ReversePaymentWriter writer = null;
			try
			{
				if (txn != null)
				{
					writer = (ReversePaymentWriter)	BYOT.CreateWithTransaction(txn.GetTransaction(),
																			   typeof(ReversePaymentWriter));
				}
				else
					writer = new ReversePaymentWriter();

				if (!writer.UpdatePaymentStatus(mLogger, intervalID, accountID, pendingapprovalenumID))
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
		private int mPendingApprovalEnumCode;
		private int mStatusCode;
	}
}
