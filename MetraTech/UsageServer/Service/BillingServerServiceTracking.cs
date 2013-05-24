using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DataAccess;
using System.Runtime.Serialization;

namespace MetraTech.UsageServer.Service
{
  public class ServiceTracking
  {
    private string mMachineIdentifier = null;
    public string MachineIdentifier
    {
      get { return mMachineIdentifier; }
    }

    private int mDBServerId = -1;
    public int DBServerId
    {
      get { return mDBServerId; }
    }

    private int mDBServiceId = -1;
    public int DBServiceId
    {
      get { return mDBServiceId; }
    }

    protected ServiceTracking()
    {
      
    }

    public ServiceTracking(string machineIdentifier)
    {
      mMachineIdentifier = machineIdentifier;
    }

    public void RecordStart()
    {
      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerStart"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, MachineIdentifier);
          //stmt.AddParam("b_ignore_deps", MTParameterType.Boolean, ignoreDeps);

          stmt.AddOutputParam("id_server", MTParameterType.Integer);
          stmt.AddOutputParam("id_service", MTParameterType.Integer); 
          stmt.AddOutputParam("status", MTParameterType.Integer);

          stmt.ExecuteNonQuery();


          status = (int)stmt.GetOutputValue("status");
          if (status==0)
          {
            mDBServerId = (int)stmt.GetOutputValue("id_server");
            mDBServiceId = (int)stmt.GetOutputValue("id_service");
          }
        }
      }

      switch (status)
      {
        case 0:
          //mLogger.LogDebug("Event instance {0} was successfully submitted for {1}.", instanceID, noun);
          break;

        case -1:
          throw new ServiceTrackingException(string.Format("Server with name {0} is already marked online",
                                                       MachineIdentifier));

        default:
          throw new Exception(string.Format("Unknown result {0} when attempting to call BillingServerStart stored procedure", status));
      }
    }

    public bool RecordHeartbeat(int MinutesToNextPromisedHeartbeat)
    {
      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerRecordHeartbeat"))
        {
          //stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, MachineIdentifier);
          stmt.AddParam("SecondsToNextPromised", MTParameterType.Integer, MinutesToNextPromisedHeartbeat * 60); 
          stmt.AddOutputParam("status", MTParameterType.Integer);

          stmt.ExecuteNonQuery();

          status = (int)stmt.GetOutputValue("status");

        }
      }

      switch (status)
      {
        case 0:
          return true;

        case -1:
          throw new ServiceTrackingException(string.Format("Error calling BillingServerRecordHeartbeat: Server with name {0} is already marked offline",
                                                       MachineIdentifier));
        default:
          throw new Exception(string.Format("Unknown result {0} when attempting to call BillingServerRecordHeartbeat stored procedure", status));
      }
    }

    /// <summary>
    /// Called when the service does not intened to send heartbeat; either temporarily or permanently.
    /// Removes the server/service from heartbeat checking.
    /// </summary>
    /// <returns></returns>
    public bool StopRecordingHeartbeat()
    {
      return RecordHeartbeat(0);
    }
    
    public void RecordStop()
    {
      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerStop"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, MachineIdentifier);
          //stmt.AddParam("b_ignore_deps", MTParameterType.Boolean, ignoreDeps);
          //stmt.AddOutputParam("id_server", MTParameterType.Integer);
          //stmt.AddOutputParam("id_service", MTParameterType.Integer);
          stmt.AddOutputParam("status", MTParameterType.Integer);

          stmt.ExecuteNonQuery();

          status = (int)stmt.GetOutputValue("status");

        }
      }

      switch (status)
      {
        case 0:
          //mLogger.LogDebug("Event instance {0} was successfully submitted for {1}.", instanceID, noun);
          break;

        case -1:
          throw new ServiceTrackingException(string.Format("Server with name {0} is already marked offline",
                                                       MachineIdentifier));

        default:
          throw new Exception(string.Format("Unknown result {0} when attempting to call BillingServerStop stored procedure", status));
      }
    }

    public void Repair()
    {
      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerRepair"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, MachineIdentifier);
          stmt.AddOutputParam("status", MTParameterType.Integer);
          stmt.ExecuteNonQuery();


          status = (int) stmt.GetOutputValue("status");
          if (status != 0)
          {
            throw new ServiceTrackingException(
              string.Format("Unknown return code ({0}) returned from BillingServerRepair stored procedure", status));
          }
        }
      }
    }

    public static List<string> GetMachinesThatMissedHeartbeat()
    {
      List<string> machinesThatMissedHeartbeat = new List<string>();
      
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
            {
                // gets a list of active scheduled event names
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer",
                                                                              "__GET_SERVERS_THAT_FAILED_HEARTBEAT_CHECK_"))
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string machineIdentifier = reader.GetString("tx_machine");
                            DateTime lastHeartbeat = reader.GetDateTime("tt_lastheartbeat");
                            DateTime promisedHeartbeat = reader.GetDateTime("tt_nextheartbeatpromised");

                            machinesThatMissedHeartbeat.Add(machineIdentifier);
                        }
                    }
                }
            }

      return machinesThatMissedHeartbeat;
    }
    public static void MarkMachineAsOffline(string machineIdentifier)
    {
      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerStop"))
        {
          stmt.AddParam("dt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
          stmt.AddParam("tx_machine", MTParameterType.String, machineIdentifier);
          //stmt.AddParam("b_ignore_deps", MTParameterType.Boolean, ignoreDeps);
          //stmt.AddOutputParam("id_server", MTParameterType.Integer);
          //stmt.AddOutputParam("id_service", MTParameterType.Integer);
          stmt.AddOutputParam("status", MTParameterType.Integer);

          stmt.ExecuteNonQuery();

          status = (int)stmt.GetOutputValue("status");

        }
      }

      switch (status)
      {
        case 0:
          //mLogger.LogDebug("Event instance {0} was successfully submitted for {1}.", instanceID, noun);
          break;

        case -1:
          throw new ServiceTrackingException(string.Format("Server with name {0} is already marked offline",
                                                       machineIdentifier));

        default:
          throw new Exception(string.Format("Unknown result {0} when attempting to call BillingServerStop stored procedure", status));
      }
    }

  }

  public class ServiceTrackingException : System.Exception
  {
    public ServiceTrackingException(){}

    public ServiceTrackingException(string message): base(message){}
    public ServiceTrackingException(string message,Exception innerException): base(message, innerException) {}
    protected ServiceTrackingException(SerializationInfo info, StreamingContext context) : base(info, context) { }
  }

  public class BillingServerServiceTracking : ServiceTracking
  {
    public void UpdateTaskConfigAndRetrieveTaskSettings(bool canInstantiateScheduledEvents, bool canCreateIntervals, bool canSoftCloseIntervals,
      out bool willInstantiateScheduledEvents, out bool willCreateIntervals, out bool willSoftCloseIntervals)
    {
      willInstantiateScheduledEvents = false;
      willCreateIntervals = false;
      willSoftCloseIntervals = false;

      int status;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
      {
        using (IMTCallableStatement stmt = conn.CreateCallableStatement("BillingServerUpdateTasks"))
        {
          stmt.AddParam("tx_machine", MTParameterType.String, MachineIdentifier);
          stmt.AddParam("canCreateScheduledEvents", MTParameterType.Boolean, canInstantiateScheduledEvents);
          stmt.AddParam("canCreateIntervals", MTParameterType.Boolean, canCreateIntervals);
          stmt.AddParam("canSoftCloseIntervals", MTParameterType.Boolean, canSoftCloseIntervals);

          stmt.AddOutputParam("willCreateScheduledEvents",MTParameterType.Boolean, 4);
          stmt.AddOutputParam("willCreateIntervals", MTParameterType.Boolean, 4);
          stmt.AddOutputParam("willSoftCloseIntervals", MTParameterType.Boolean, 4);

          stmt.AddOutputParam("status", MTParameterType.Integer);

          stmt.ExecuteNonQuery();


          status = (int)stmt.GetOutputValue("status");
          if (status == 0)
          {
            willInstantiateScheduledEvents = stmt.GetOutputValueAsBoolean("willCreateScheduledEvents");
            willCreateIntervals = stmt.GetOutputValueAsBoolean("willCreateIntervals");
            willSoftCloseIntervals = stmt.GetOutputValueAsBoolean("willSoftCloseIntervals");
          }
        }
      }

      switch (status)
      {
        case 0:
          //mLogger.LogDebug("Event instance {0} was successfully submitted for {1}.", instanceID, noun);
          break;

        //case -1:
        //  throw new UsageServerException(string.Format("Server with name {0} is already marked online",
        //                                               MachineIdentifier));

        default:
          throw new Exception(string.Format("Unknown result {0} when attempting to call BillingServerUpdateTasks stored procedure", status));
      }

    }


    public BillingServerServiceTracking(string machineIdentifier) : base(machineIdentifier)
    {
    }
  }


}
