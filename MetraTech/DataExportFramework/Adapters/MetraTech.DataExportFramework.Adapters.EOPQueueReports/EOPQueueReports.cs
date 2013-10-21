using System;
using System.Linq;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;

namespace MetraTech.DataExportFramework.Adapters.EOPQueueReports
{
  public class EOPQueueReports : IRecurringEventAdapter2
  {
    public bool SupportsScheduledEvents
    {
      get { return false; }
    }

    public bool SupportsEndOfPeriodEvents
    {
      get { return true; }
    }

    public ReverseMode Reversibility
    {
      get { return ReverseMode.Custom; }
    }

    public bool AllowMultipleInstances
    {
      get { return false; }
    }

    private bool _mbInitialized ;
    private readonly Logger _moLogger;
    private const string MName = "EOPQueueReports";

    private string _msReverseQueueTag;
    private string _msQueryPath;
    private string _msEopInstanceName = "";
    private string _msSplitReverseQueueTag;

    private string _msCompleteQueryStatusCheckTag;
    private string _msCompleteQueryQueueCheck;
    private int _miTimeout; //in seconds
    private int _miPauseTime; //in seconds
    private string _msCompleteQueryPath;

    /// <summary>
    /// Specifies whether the adapter can process billing groups as a group
    /// of accounts, as individual accounts or if it
    /// cannot process billing groups at all.
    /// This setting is only valid for end-of-period adapters.
    /// </summary>
    /// <returns>BillingGroupSupportType</returns>
    public BillingGroupSupportType BillingGroupSupport
    {
      get { return BillingGroupSupportType.Account; }
    }

    /// <summary>
    /// Specifies whether this adapter has special constraints on the membership
    /// of a billing group.
    /// This setting is only valid for adapters that support billing groups.
    /// </summary>
    /// <returns>True if constraints exist, false otherwise</returns>
    public bool HasBillingGroupConstraints
    {
      get { return false; }
    }

    public EOPQueueReports()
    {
      _moLogger = new Logger("[EOPQUEUEREPORTSADAPTER]");
      _mbInitialized = false;
      //mbSupportsEndOfPeriodEvents = true;
      //mbSupportsScheduledEvents = false;
    }

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
        _moLogger.LogDebug("Starting initialization...");
        if (!bLimitedInit)
        {
          ReadConfig(sConfigFile);
        }

        _mbInitialized = true;
        _moLogger.LogDebug("Initialization completed.");
      }
      catch (Exception e)
      {
        _moLogger.LogError("An error occurred during initialization: " + e.Message + "  Inner Exception: " +
                          e.InnerException.Message);
        throw;
      }
    }

    private void ReadConfig(string sConfigFile)
    {
      var oDoc = new XmlDocument();
      oDoc.Load(sConfigFile);

      try
      {
        //read the query tag information
        _msQueryPath = oDoc.SelectSingleNode("xmlconfig/queueeopquery/path").InnerText;
        _msReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/queueeopquery/reversequerytag").InnerText;
        _msEopInstanceName = oDoc.SelectSingleNode("xmlconfig/name").InnerText;

        try
        {
          _msSplitReverseQueueTag = oDoc.SelectSingleNode("xmlconfig/queueeopquery/pulllisttag").InnerText;
        }
        catch
        {
          _msSplitReverseQueueTag = String.Empty;
        }
        _msCompleteQueryPath = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/path").InnerText;
        _msCompleteQueryQueueCheck = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/checkqueuequery").InnerText;
        _msCompleteQueryStatusCheckTag = oDoc.SelectSingleNode("xmlconfig/eopcompletequery/checkexecstatustag").InnerText;
      }
      catch (Exception ex)
      {
        throw new Exception("ReadConfig error!", ex);
      }
      try
      {
        _miTimeout = Convert.ToInt32(oDoc.SelectSingleNode("xmlconfig/timeout/period").InnerText);
      }
      catch
      {
        _moLogger.LogDebug("No timeout found, rolling back to default of 600 seconds");
        _miTimeout = 600;
      }
      try
      {
        _miPauseTime = Convert.ToInt32(oDoc.SelectSingleNode("xmlconfig/timeout/pause").InnerText);
      }
      catch
      {
        _moLogger.LogDebug("No pause time found, rolling back to default of 10 seconds");
        _miPauseTime = 10;
      }
    }

    public string Execute(IRecurringEventRunContext oContext)
    {
      if (!_mbInitialized)
        return ("Adapter not initialized");

      using(var cn = ConnectionManager.CreateConnection())
      using(var selectst = cn.CreateCallableStatement("Export_QueueEOPReports"))
      try
      {
        var totalQueued = 0;
        selectst.AddParam("eopInstanceName", MTParameterType.String, _msEopInstanceName);
        selectst.AddParam("intervalId", MTParameterType.Integer, oContext.UsageIntervalID);
        selectst.AddParam("id_billgroup", MTParameterType.Integer, oContext.BillingGroupID);
        selectst.AddParam("runId", MTParameterType.Integer, oContext.RunID);
        selectst.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());
        IMTDataReader reader;

        if (cn.ConnectionInfo.IsOracle)
        {
          selectst.ExecuteNonQuery();
          var selectAdSt = cn.CreateAdapterStatement(_msQueryPath, "__GET_EXPORTED_EOP_REPORTS_INFO__");
          reader = selectAdSt.ExecuteReader();
        }
        else
        {
          reader = selectst.ExecuteReader();
        }

        while (reader.Read())
        {
          var sDestn = Convert.ToString(reader.GetValue("c_rep_destn"));
          if (sDestn.IndexOf("%%month%%") > 0)
            sDestn = sDestn.Replace("%%month%%",
                                    Convert.ToDateTime(reader.GetValue("dt_sched_run")).Month.ToString());

          if (sDestn.IndexOf("%%year%%") > 0)
            sDestn = sDestn.Replace("%%year%%", Convert.ToDateTime(reader.GetValue("dt_sched_run")).Year.ToString());

          foreach (var prmNameVal in
              Convert.ToString(reader.GetValue("c_param_name_values"))
                     .Split(new Char[] {','})
                     .Where(prmNameVal => sDestn.IndexOf(prmNameVal.Split(new Char[] {'='})[0]) > 0))
          {
            sDestn = sDestn.Replace(prmNameVal.Split(new Char[] {'='})[0], prmNameVal.Split(new Char[] {'='})[1]);
          }

          oContext.RecordInfo("Report:&nbsp;" + Convert.ToString(reader.GetValue("c_rep_title"))
                              + "&nbsp;&nbsp;InstanceID:&nbsp;" +
                              Convert.ToString(reader.GetValue("id_rep_instance_id"))
                              + "<BR>" + "Execution Parameters:&nbsp; " +
                              Convert.ToString(reader.GetValue("c_param_name_values")).Replace("%", "") + "<BR>"
                              + "Report Delivered via:&nbsp; " +
                              Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
                              + "Destination:&nbsp; " + sDestn.Replace("%", "") + "<BR>");
          totalQueued++;
        }
        reader.Close();
        reader.Dispose();

        if (totalQueued > 0)
        {
          oContext.RecordInfo(string.Format(
            "{0} EOP Reports were successfully Queued to the WorkQueue for execution.", totalQueued.ToString()));
          oContext.RecordInfo(
            string.Format("This adapter will monitor for completion every {0} seconds for {1} minutes.", _miPauseTime,
                          (_miTimeout/60)));
        }
        else
        {
          oContext.RecordWarning(string.Format("No EOP Reports found for this adapter."));
        }

        return ExecuteQueueEOPReportsComplete(oContext);
      }
      catch (Exception ex)
      {
        oContext.RecordWarning("Error during execution - exception stack trace:-\n" + ex.ToString());
        throw new Exception("Failed during queue of EOP reports");
      }
    }

    private string ExecuteQueueEOPReportsComplete(IRecurringEventRunContext oContext)
    {
      int counter = _miTimeout/_miPauseTime;
      var bIsComplete = false;
      try
      {
        _moLogger.LogDebug("Executing...");
        var i = 0;
        while (i < counter)
        {
          if (!CheckIfEOPReportsOnQueue(oContext))
          {
            //There are none of the queued reports on the queue, check if they have all successfully executed.
            using(var cn = ConnectionManager.CreateConnection())
            using(var selectst = cn.CreateAdapterStatement(_msCompleteQueryPath, _msCompleteQueryStatusCheckTag))
              try
              {
                selectst.AddParam("%%EOP_INSTANCE_NAME%%", _msEopInstanceName, true);
                selectst.AddParam("%%ID_RUN%%", oContext.RunID, true);
                var reader = selectst.ExecuteReader();
                while (reader.Read())
                {
                  var sDestn = Convert.ToString(reader.GetValue("c_rep_destn")).Replace("%", "");
                  if (sDestn.IndexOf("%%month%%") > 0)
                    sDestn = sDestn.Replace("%%month%%",
                                            Convert.ToDateTime(reader.GetValue("dt_sched_run")).Month.ToString());

                  if (sDestn.IndexOf("%%year%%") > 0)
                    sDestn = sDestn.Replace("%%year%%",
                                            Convert.ToDateTime(reader.GetValue("dt_sched_run")).Year.ToString());

                  foreach (var prmNameVal in
                    Convert.ToString(reader.GetValue("c_execute_paraminfo"))
                           .Split(new Char[] {';'})
                           .Where(prmNameVal => sDestn.IndexOf(prmNameVal.Split(new Char[] {'='})[0]) > 0))
                  {
                    sDestn = sDestn.Replace(prmNameVal.Split(new Char[] {'='})[0], prmNameVal.Split(new Char[] {'='})[1]);
                  }
                  if ((Convert.ToString(reader.GetValue("c_run_result_status")) != "SUCCESS"))
                  {
                    oContext.RecordWarning("Report:&nbsp;" + Convert.ToString(reader.GetValue("c_rep_title"))
                                           + "&nbsp;&nbsp;InstanceID:&nbsp;" +
                                           Convert.ToString(reader.GetValue("id_rep_instance_id"))
                                           + "<BR>" + "Execution Parameters:&nbsp; " +
                                           Convert.ToString(reader.GetValue("c_execute_paraminfo")) + "<BR>"
                                           + "Report Delivered via:&nbsp; " +
                                           Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
                                           + "Destination:&nbsp; " + sDestn.Replace("%", "") + "<BR>" +
                                           Convert.ToString(reader.GetValue("c_run_result_descr")) + "<BR>");
                  }
                  else
                  {
                    oContext.RecordInfo("Report:&nbsp;" + Convert.ToString(reader.GetValue("c_rep_title"))
                                        + "&nbsp;&nbsp;InstanceID:&nbsp;" +
                                        Convert.ToString(reader.GetValue("id_rep_instance_id"))
                                        + "<BR>" + "Execution Parameters:&nbsp; " +
                                        Convert.ToString(reader.GetValue("c_execute_paraminfo")) + "<BR>"
                                        + "Report Delivered via:&nbsp; " +
                                        Convert.ToString(reader.GetValue("c_rep_distrib_type")) + "<BR>"
                                        + "Destination:&nbsp; " + sDestn.Replace("%", "") + "<BR>" +
                                        Convert.ToString(reader.GetValue("c_run_result_descr")) + "<BR>");
                  }
                }
              }
              catch (Exception ex)
              {
                oContext.RecordInfo(
                  "No Reports were found on the queue, but an Exception occurred during report execution status check - exception stack trace:-\n" +
                  ex);
                oContext.RecordInfo("You may need to reverse and run the previous step " + _msEopInstanceName + " again");
                throw new Exception("Failed during status check of the executed reports", ex);
              }
            bIsComplete = true;
            break;
          }

          System.Threading.Thread.Sleep(_miPauseTime*1000);
          i++;
        }
        if (!bIsComplete)
        {
          _moLogger.LogDebug("Adapter has timed out while monitoring for the report execution");
          oContext.RecordWarning("Adapter has timed out while monitoring for the report execution");
          throw new Exception("Timed out while waiting for the EOPreports to complete");
        }
        return ("EOP reports completed successfully");
      }
      catch (Exception ex)
      {
        oContext.RecordInfo("Error during execution - exception stack trace:-\n" + ex);
        throw new Exception("Failed while doing a status check queued EOP reports");
      }
    }

    private bool CheckIfEOPReportsOnQueue(IRecurringEventRunContext oContext)
    {
      using (var cn = ConnectionManager.CreateConnection())
      using (var selectst = cn.CreateAdapterStatement(_msCompleteQueryPath, _msCompleteQueryQueueCheck))
      {
        selectst.AddParam("%%EOP_INSTANCE_NAME%%", _msEopInstanceName, true);
        selectst.AddParam("%%ID_RUN%%", oContext.RunID, true);
        var rdr = selectst.ExecuteReader();
        return rdr.Read();
      }
    }

    public void CreateBillingGroupConstraints(int intervalId, int materializationId)
    {
      _moLogger.LogDebug(string.Concat(MName,
                                      ". CreateBillingGroupConstraints should not have been called: billing group constraits are not enforced by this adapter - check the HasBillingGroupConstraints property."));
    }

    public void SplitReverseState(int parentRunId, int parentBillingGroupId, int childRunId, int childBillingGroupId)
    {
      _moLogger.LogDebug("Executing...");
      if (!_mbInitialized)
      {
        _moLogger.LogInfo(String.Concat(MName, " is not initialized, can not create pull list."));
        return;
      }

      if (String.IsNullOrEmpty(_msSplitReverseQueueTag) ||
          String.IsNullOrWhiteSpace(_msSplitReverseQueueTag.Trim())) return;

      using (var cn = ConnectionManager.CreateConnection())
      using (var selectst = cn.CreateAdapterStatement(_msQueryPath, _msSplitReverseQueueTag))
      {
        // Values used in the query today
        selectst.AddParamIfFound("%%PARENT_ID_RUN%%", parentRunId);
        selectst.AddParamIfFound("%%PARENT_ID_BILLGROUP%%", parentBillingGroupId);
        selectst.AddParamIfFound("%%CHILD_ID_RUN%%", childRunId);
        selectst.AddParamIfFound("%%CHILD_ID_BILLGROUP%%", childBillingGroupId);
        selectst.AddParamIfFound("%%METRATIME%%", MetraTime.Now.ToLocalTime());
        selectst.ExecuteNonQuery();
      }
    }

    public string Reverse(IRecurringEventRunContext oContext)
    {
      _moLogger.LogDebug("Executing...");
      if (!_mbInitialized)
        return ("Adapter not initialized");

      using (var cn = ConnectionManager.CreateConnection())
      using (var selectst = cn.CreateAdapterStatement(_msQueryPath, _msReverseQueueTag))
      {
        selectst.AddParam("%%ID_RUN%%", oContext.RunIDToReverse, true);
        var rows = selectst.ExecuteNonQuery();
        //oContext.RecordInfo(rows.ToString() + " EOP Reports were successfully Removed from the WorkQueue");
        oContext.RecordWarning(
          "If the reversed number is less than the Queued number, some reports have already picked up for execution by the Reporting Framework.");
        return (rows + " EOP Reports were successfully Removed from the WorkQueue");
      }
    }

    public void Shutdown()
    {
      //Nothing to do here.
    }
  }
}