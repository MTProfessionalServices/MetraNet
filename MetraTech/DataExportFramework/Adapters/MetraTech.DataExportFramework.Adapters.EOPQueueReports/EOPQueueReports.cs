using System;
using System.Xml;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using MetraTech;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;

using System.Runtime.InteropServices;

namespace MetraTech.DataExportFramework.Adapters.EOPQueueReports
{
    public class EOPQueueReports : MetraTech.UsageServer.IRecurringEventAdapter2
	{

        public bool SupportsScheduledEvents { get { return false; } }
        public bool SupportsEndOfPeriodEvents { get { return true; } }
        public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
        public bool AllowMultipleInstances { get { return false; } }

		private bool mbInitialized = false;
		private Logger moLogger;
        private static string mName = "EOPQueueReports";

		private string msQueryTag;
		private string msReverseQueueTag;
		private string msQueryPath;
		private string msEOPInstanceName = "";

        private string msCompleteQueryStatusCheckTag;
        private string msCompleteQueryQueueCheck;
        private int miTimeout;			//in seconds
        private int miPauseTime;	//in seconds
        private string msCompleteQueryPath;
        //private bool mbSupportsScheduledEvents = false;
        //private bool mbSupportsEndOfPeriodEvents = true;
        

        /// <summary>
        /// Specifies whether the adapter can process billing groups as a group
        /// of accounts, as individual accounts or if it
        /// cannot process billing groups at all.
        /// This setting is only valid for end-of-period adapters.
        /// </summary>
        /// <returns>BillingGroupSupportType</returns>
        public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }

        /// <summary>
        /// Specifies whether this adapter has special constraints on the membership
        /// of a billing group.
        /// This setting is only valid for adapters that support billing groups.
        /// </summary>
        /// <returns>True if constraints exist, false otherwise</returns>
        public bool HasBillingGroupConstraints { get { return false; } }

		public EOPQueueReports()
		{	
			moLogger = new Logger("[EOPQUEUEREPORTSADAPTER]");
			mbInitialized = false;

           
            //mbSupportsEndOfPeriodEvents = true;
            //mbSupportsScheduledEvents = false;
		}

		private ArrayList moReportsList = new ArrayList();



		/// <summary>
		/// Initialization will check on limitedinit and call readConfig.
		/// If there is an overriden ReadConfig, that will get called first,
		/// where the base Class' ReadConfig call is first made and then
		/// Inherited class specific ReadConfig is done.
		/// </summary>
		/// <param name="sEventName"></param>
		/// <param name="sConfigFile"></param>
		/// <param name="oContext"></param>
		/// <param name="bLimitedInit"></param>
		public virtual void Initialize(string sEventName, string sConfigFile, IMTSessionContext oContext, bool bLimitedInit)
		{
			try
			{
				moLogger.LogDebug("Starting initialization...");
				if(!bLimitedInit)
				{
					ReadConfig(sConfigFile);
				}

				mbInitialized = true;
				moLogger.LogDebug("Initialization completed.");
			}
			catch(System.Exception e)
			{
				moLogger.LogError("An error occurred during initialization: " + e.Message + "  Inner Exception: " + e.InnerException.Message);
				throw (e);
			}
		}

		private void ReadConfig(string sConfigFile)
		{
			XmlDocument oDoc = new XmlDocument();
			oDoc.Load(sConfigFile);

			try
			{
				//read the query tag information
				msQueryPath = oDoc.SelectSingleNode("xmlconfig/queueeopquery/path").InnerText;
				msQueryTag = oDoc.SelectSingleNode("xmlconfig/queueeopquery/querytag").InnerText;
				msReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/queueeopquery/reversequerytag").InnerText;
				msEOPInstanceName = oDoc.SelectSingleNode("xmlconfig/name").InnerText;

                msCompleteQueryPath = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/path").InnerText;
                msCompleteQueryQueueCheck = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/checkqueuequery").InnerText;
                msCompleteQueryStatusCheckTag = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/checkexecstatustag").InnerText;

			}
			catch (Exception ex) 
			{
				throw new Exception("ReadConfig error!", ex);
			}
            try
            {
                miTimeout = Convert.ToInt32(oDoc.SelectSingleNode("xmlconfig/timeout/period").InnerText);
            }
            catch
            {
                moLogger.LogDebug("No timeout found, rolling back to default of 600 seconds");
                miTimeout = 600;
            }
            try
            {
                miPauseTime = Convert.ToInt32(oDoc.SelectSingleNode("xmlconfig/timeout/pause").InnerText);
            }
            catch
            {
                moLogger.LogDebug("No pause time found, rolling back to default of 10 seconds");
                miPauseTime = 10;
            }
		}

		public string Execute(MetraTech.UsageServer.IRecurringEventRunContext oContext)
		{
			IMTConnection cn = null;
			int totalQueued = 0;
			try 
			{
				if (mbInitialized)
				{
					cn = ConnectionManager.CreateConnection();
          IMTCallableStatement selectst = null;
          selectst = cn.CreateCallableStatement("Export_QueueEOPReports"); 
					selectst.AddParam("eopInstanceName", MTParameterType.String, msEOPInstanceName);
					selectst.AddParam("intervalId", MTParameterType.Integer, oContext.UsageIntervalID);
          selectst.AddParam("id_billgroup", MTParameterType.Integer, oContext.BillingGroupID);
          selectst.AddParam("runId", MTParameterType.Integer, oContext.RunID);
          selectst.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime()); 
				  IMTDataReader reader;

          if (cn.ConnectionInfo.IsOracle)
          {
            selectst.ExecuteNonQuery();
            var selectAdSt = cn.CreateAdapterStatement(msQueryPath, "__GET_EXPORTED_EOP_REPORTS_INFO__");
            reader = selectAdSt.ExecuteReader();
          }
          else
          {
            reader = selectst.ExecuteReader();  
          }

					while (reader.Read())
					{
						string sDestn = Convert.ToString(reader.GetValue("c_rep_destn"));
						if (sDestn.IndexOf("%%month%%") > 0)
							sDestn = sDestn.Replace("%%month%%", Convert.ToDateTime(reader.GetValue("dt_sched_run")).Month.ToString());

						if (sDestn.IndexOf("%%year%%") > 0)
							sDestn = sDestn.Replace("%%year%%", Convert.ToDateTime(reader.GetValue("dt_sched_run")).Year.ToString());

						foreach (string prmNameVal in Convert.ToString(reader.GetValue("c_param_name_values")).Split(new Char[]{','}))
						{
							if (sDestn.IndexOf(prmNameVal.Split(new Char[]{'='})[0]) > 0)
								sDestn = sDestn.Replace(prmNameVal.Split(new Char[]{'='})[0], prmNameVal.Split(new Char[]{'='})[1]);
						}
						oContext.RecordInfo("Report:&nbsp;"+Convert.ToString(reader.GetValue("c_rep_title")) 
							+ "&nbsp;&nbsp;InstanceID:&nbsp;" + Convert.ToString(reader.GetValue("id_rep_instance_id")) 
							+ "<BR>" + "Execution Parameters:&nbsp; "+Convert.ToString(reader.GetValue("c_param_name_values")).Replace("%", "") + "<BR>"
							+ "<BR>" + "Field Definition File Used:&nbsp; "+Convert.ToString(reader.GetValue("c_xmlconfig_loc")).Replace("%", "") + "<BR>"
							+ "Report Delivered via:&nbsp; "+Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
							+ "Destination:&nbsp; "+sDestn.Replace("%", "") + "<BR>");
						totalQueued++;
					}
					reader.Close();
					reader.Dispose();

                    if (totalQueued > 0)
                    {
                        oContext.RecordInfo(string.Format("{0} EOP Reports were successfully Queued to the WorkQueue for execution.", totalQueued.ToString()));
                        oContext.RecordInfo(string.Format("This adapter will monitor for completion every {0} seconds for {1} minutes.", miPauseTime, (miTimeout / 60)));
                    }
                    else
                    {
                        oContext.RecordWarning(string.Format("No EOP Reports found for this adapter."));
                    }
                                        
                    return ExecuteQueueEOPReportsComplete(oContext);
  				}
				else
					return ("Adapter not initialized");
			}
			catch (Exception ex)
			{
				oContext.RecordWarning("Error during execution - exception stack trace:-\n" + ex.ToString());
				throw new Exception("Failed during queue of EOP reports");
			}
			finally
			{
				if (cn != null)
				{	
					cn.Dispose();
					cn.Close();
				}
			}
            
		}

        private string ExecuteQueueEOPReportsComplete(IRecurringEventRunContext oContext)
        {
            int counter = miTimeout / miPauseTime;
            bool bIsComplete = false;
            try
            {
                moLogger.LogDebug("Executing...");
          
                    int i = 0;
                    while (i < counter)
                    {
                        if (!CheckIfEOPReportsOnQueue(oContext))
                        {
                            //There are none of the queued reports on the queue, check if they have all successfully executed.
                            IMTConnection cn = null;
                            IMTDataReader reader = null;
                            try
                            {
                                cn = ConnectionManager.CreateConnection();
                                IMTAdapterStatement selectst = null;
                                selectst = cn.CreateAdapterStatement(msCompleteQueryPath, msCompleteQueryStatusCheckTag);

                                selectst.AddParam("%%EOP_INSTANCE_NAME%%", msEOPInstanceName, true);
                                selectst.AddParam("%%ID_RUN%%", oContext.RunID, true);
                                reader = selectst.ExecuteReader();
                                while (reader.Read())
                                {
                                    string sDestn = Convert.ToString(reader.GetValue("c_rep_destn")).Replace("%", "");
                                    if (sDestn.IndexOf("%%month%%") > 0)
                                        sDestn = sDestn.Replace("%%month%%", Convert.ToDateTime(reader.GetValue("dt_sched_run")).Month.ToString());

                                    if (sDestn.IndexOf("%%year%%") > 0)
                                        sDestn = sDestn.Replace("%%year%%", Convert.ToDateTime(reader.GetValue("dt_sched_run")).Year.ToString());

                                    foreach (string prmNameVal in Convert.ToString(reader.GetValue("c_execute_paraminfo")).Split(new Char[] { ';' }))
                                    {
                                        if (sDestn.IndexOf(prmNameVal.Split(new Char[] { '=' })[0]) > 0)
                                            sDestn = sDestn.Replace(prmNameVal.Split(new Char[] { '=' })[0], prmNameVal.Split(new Char[] { '=' })[1]);
                                    }
                                    if ((Convert.ToString(reader.GetValue("c_run_result_status")) != "SUCCESS"))
                                    {
                                        oContext.RecordWarning("Report:&nbsp;" + Convert.ToString(reader.GetValue("c_rep_title"))
                                            + "&nbsp;&nbsp;InstanceID:&nbsp;" + Convert.ToString(reader.GetValue("id_rep_instance_id"))
                                            + "<BR>" + "Execution Parameters:&nbsp; " + Convert.ToString(reader.GetValue("c_execute_paraminfo")) + "<BR>"
                                            + "Report Delivered via:&nbsp; " + Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
                                            + "Destination:&nbsp; " + sDestn.Replace("%", "") + "<BR>" + Convert.ToString(reader.GetValue("c_run_result_descr")) + "<BR>");
                                    }
                                    else
                                    {
                                        oContext.RecordInfo("Report:&nbsp;" + Convert.ToString(reader.GetValue("c_rep_title"))
                                            + "&nbsp;&nbsp;InstanceID:&nbsp;" + Convert.ToString(reader.GetValue("id_rep_instance_id"))
                                            + "<BR>" + "Execution Parameters:&nbsp; " + Convert.ToString(reader.GetValue("c_execute_paraminfo")) + "<BR>"
                                            + "Report Delivered via:&nbsp; " + Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
                                            + "Destination:&nbsp; " + sDestn.Replace("%", "") + "<BR>" + Convert.ToString(reader.GetValue("c_run_result_descr")) + "<BR>");
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                oContext.RecordInfo("No Reports were found on the queue, but an Exception occurred during report execution status check - exception stack trace:-\n" + ex.ToString());
                                oContext.RecordInfo("You may need to reverse and run the previous step " + msEOPInstanceName + " again");
                                throw new Exception("Failed during status check of the executed reports", ex);
                            }
                            finally
                            {
                                if (reader != null)
                                {
                                    reader.Close();
                                    reader.Dispose();
                                }
                                if (cn != null)
                                {
                                    cn.Dispose();
                                    cn.Close();
                                }
                            }
                            bIsComplete = true;
                            break;
                        }
                        else
                        {
                            System.Threading.Thread.Sleep(miPauseTime * 1000);
                            i++;
                        }
                    }
                    if (!bIsComplete)
                    {
                        moLogger.LogDebug("Adapter has timed out while monitoring for the report execution");
                        oContext.RecordWarning("Adapter has timed out while monitoring for the report execution");
                        throw new Exception("Timed out while waiting for the EOPreports to complete");
                    }
                    else
                    {
                        return ("EOP reports completed successfully");
                    }
             }
            catch (Exception ex)
            {
                oContext.RecordInfo("Error during execution - exception stack trace:-\n" + ex.ToString());
                throw new Exception("Failed while doing a status check queued EOP reports");
            }
        }
        private bool CheckIfEOPReportsOnQueue(MetraTech.UsageServer.IRecurringEventRunContext oContext)
        {
            IMTConnection cn = null;
            IMTDataReader rdr = null;
            try
            {
                cn = ConnectionManager.CreateConnection();
                IMTAdapterStatement selectst = null;

                selectst = cn.CreateAdapterStatement(msCompleteQueryPath, msCompleteQueryQueueCheck);

                selectst.AddParam("%%EOP_INSTANCE_NAME%%", msEOPInstanceName, true);
                selectst.AddParam("%%ID_RUN%%", oContext.RunID, true);
               
                rdr = selectst.ExecuteReader();
                if (rdr.Read())
                    return true;
                else
                    return false;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
            finally
            {
                if (rdr != null)
                {
                    rdr.Close();
                    rdr.Dispose();
                }
                if (cn != null)
                {
                    cn.Dispose();
                    cn.Close();
                }
            }
        }

        public void CreateBillingGroupConstraints(int intervalID, int materializationID)
        {
            throw new ApplicationException(string.Concat(EOPQueueReports.mName, ". CreateBillingGroupConstraints should not have been called: billing group constraits are not enforced by this adapter - check the HasBillingGroupConstraints property."));
        }
        public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
        {
            //throw new ApplicationException(string.Concat(EOPQueueReports.mName, ". SplitReverseState should not have been called: reverse is not needed for this adapter - check the Reversibility property."));
            moLogger.LogDebug("Splitting reverse state of QueueEOPReports Adapter");
        }
		public string Reverse(MetraTech.UsageServer.IRecurringEventRunContext oContext)
		{
			IMTConnection cn = null;
			try 
			{
				moLogger.LogDebug("Executing...");
				if (mbInitialized)
				{
					cn = ConnectionManager.CreateConnection();
					IMTAdapterStatement selectst = cn.CreateAdapterStatement(msQueryPath, msReverseQueueTag);
					selectst.AddParam("%%ID_RUN%%", oContext.RunIDToReverse, true);
					int rows = selectst.ExecuteNonQuery();
					//oContext.RecordInfo(rows.ToString() + " EOP Reports were successfully Removed from the WorkQueue");
					oContext.RecordWarning("If the reversed number is less than the Queued number, some reports have already picked up for execution by the Reporting Framework.");
					return(rows.ToString() + " EOP Reports were successfully Removed from the WorkQueue");
				}
				else
					return ("Adapter not initialized");
			}
			catch (Exception ex)
			{
				throw (ex);
			}
			finally
			{
				if (cn != null)
				{	
					cn.Dispose();
					cn.Close();
				}
			}		
		}
	
		public void Shutdown()
		{
			//Nothing to do here.
		}
	}

	
}
