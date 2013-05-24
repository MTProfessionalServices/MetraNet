using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;



// <xmlconfig>
//	<StoredProcs>
//		<CalculateInvoice>mtsp_InsertInvoice</CalculateInvoice>
//		<GenInvoiceNumbers>mtsp_GenerateInvoiceNumbers</GenInvoiceNumbers>
//	</StoredProcs>
//	<IsSample>N</IsSample>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
	/// <summary>
	/// Invoice Adapter, used to generate invoices at EOP.
	/// </summary>
	public class InvoiceAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
	{
		// data
			private Logger mLogger = new Logger ("[InvoiceAdapter]");
			private string mInvoiceCalc;
			private string mGenInvoiceNum;
			private string mIsSample;
			private bool mConfigSample;
			private string mConfigFile;
		
		//adapter capabilities
		public bool SupportsScheduledEvents { get { return false; }}
		public bool SupportsEndOfPeriodEvents { get { return true; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
    public BillingGroupSupportType BillingGroupSupport { get	{ return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; }}
		
		public InvoiceAdapter()
		{
		}

	    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing Invoice Adapter");
			mLogger.LogDebug("Using config file: {0}", configFile);
			mConfigFile = configFile;
			mLogger.LogDebug (mConfigFile);
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			status = ReadConfigFile(configFile);
			if (status)
				mLogger.LogDebug("Initialize successful");
			else
				mLogger.LogError("Initialize failed, Could not read config file");
			

		}

		public string Execute(IRecurringEventRunContext param)
		{
			string detail;
			mLogger.LogDebug("Executing Invoice Adapter");

			mLogger.LogDebug("Event type = {0}", param.EventType);
			mLogger.LogDebug("Run ID = {0}", param.RunID);
			mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);
			
			param.RecordInfo("Generating Invoices ... ");
			// need to execute the mtsp_InsertInvoice stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                //call the stored procedure used to calculate invoices and pass in the 
                //stored procedure used to generate invoice numbers as a parameter.
                mLogger.LogDebug("Calling Stored Procedure: {0}", mInvoiceCalc);
                using (IMTCallableStatement stmt = conn.CreateCallableStatement(mInvoiceCalc))
                {
                    stmt.AddParam("@id_billgroup", MTParameterType.Integer, param.BillingGroupID);
                    stmt.AddParam("@invoicenumber_storedproc", MTParameterType.String, mGenInvoiceNum);
                    stmt.AddParam("@is_sample", MTParameterType.String, mIsSample);
                    stmt.AddParam("@dt_now", MTParameterType.DateTime, MetraTime.Now);
                    stmt.AddParam("@id_run", MTParameterType.Integer, param.RunID);
                    stmt.AddOutputParam("@num_invoices", MTParameterType.Integer);
                    stmt.AddOutputParam("@return_code", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    int num_invoices, returncode;
                    string msg;

                    returncode = (int)stmt.GetOutputValue("@return_code");
                    num_invoices = (int)stmt.GetOutputValue("@num_invoices");

                    msg = String.Format(" '{0}' Invoices generated.", num_invoices);

                    detail = msg;
                    if (-1 == returncode)
                        throw new Exception("Invoice Adapter failed!");
                }
            }
			
			return detail;
		}

        public string Reverse(IRecurringEventRunContext param)
        {
            string detail;

            mLogger.LogDebug("Reversing Involice Adapter");
            mLogger.LogDebug("Event type = {0}", param.EventType);
            mLogger.LogDebug("Run ID = {0}", param.RunID);
            mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
            mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);

            // need to execute the mtsp_BackoutInvoices stored procedure
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                //call the stored procedure used to delete invoices generated for
                //a particular interval
                mLogger.LogDebug("Calling Stored Procedure: mtsp_BackoutInvoices");
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("mtsp_BackoutInvoices"))
                {
                    stmt.AddParam("@id_billgroup", MTParameterType.Integer, param.BillingGroupID);
                    stmt.AddParam("@id_run", MTParameterType.Integer, param.RunID);
                    stmt.AddOutputParam("@num_invoices", MTParameterType.Integer);
                    stmt.AddOutputParam("@info_string", MTParameterType.WideString, 500);
                    stmt.AddOutputParam("@return_code", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    int returncode, num_invoices;
                    string info_string, msg;

                    returncode = (int)stmt.GetOutputValue("@return_code");
                    num_invoices = (int)stmt.GetOutputValue("@num_invoices");
                    info_string = DBUtil.IsNull(stmt.GetOutputValue("@info_string"), "");

                    if (info_string != "")
                        param.RecordWarning(info_string);

                    msg = String.Format(" '{0}' Invoices backed out.", num_invoices);
                    detail = msg;

                    if (-1 == returncode)
                        throw new Exception("Invoice Adapter backout failed!");
                }
            }

            return detail;
        }

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Invoice Adapter");

		}
	
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
	
    public void SplitReverseState(int parentRunID, 
                                  int parentBillingGroupID,
                                  int childRunID, 
                                  int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Invoice Adapter");
    }

		private bool ReadConfigFile(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);  
			mInvoiceCalc = doc.GetNodeValueAsString("/xmlconfig/StoredProcs/CalculateInvoice");
			mGenInvoiceNum = doc.GetNodeValueAsString("/xmlconfig/StoredProcs/GenInvoiceNumbers");
			mConfigSample = doc.GetNodeValueAsBool("/xmlconfig/IsSample");
			if (mConfigSample)
				mIsSample = "Y";
			else
				mIsSample = "N";
			mLogger.LogDebug("Is Sample: {0}", mIsSample);
			return (true);
		}
		
	}

}
