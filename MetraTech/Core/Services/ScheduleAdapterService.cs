using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.ServiceModel;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.UsageServer;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IScheduleAdapterService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetRecurrencePattern(int EventID, out BaseRecurrencePattern pattern);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateRecurrencePattern(int EventID, BaseRecurrencePattern pattern);

  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  [KnownType(typeof(MinutelyRecurrencePattern))]
  [KnownType(typeof(DailyRecurrencePattern))]
  public class ScheduleAdapterService : CMASServiceBase, IScheduleAdapterService
  {
    #region Members
    private Logger mLogger = new Logger("[ScheduledAdapterService]");
    #endregion

    #region Private Methods
    // Create and populate a new BaseRecurrencePattern object.
    BaseRecurrencePattern createNewMinutelyRecurrencePatternObj(ref BaseRecurrencePattern minutelyRecPattern)
    {
      return minutelyRecPattern;
    }

    public string GetQueryText(string queryTag)
    {
      string sql;
      using (HighResolutionTimer timer = new HighResolutionTimer("GetQueryText"))
      {
        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
        {
          queryAdapter.Item = new MTQueryAdapterClass();
          queryAdapter.Item.Init(@"Queries\UsageServer");
          queryAdapter.Item.SetQueryTag(queryTag);
          sql = queryAdapter.Item.GetQuery();
        }
      }
      return sql;

    }

    #endregion

    #region Service Methods
    public void GetRecurrencePattern(int EventID, out BaseRecurrencePattern pattern)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetRecurrencePattern"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(GetQueryText("__GET_RECURRENCE_PATTERN__")))
            {
              stmt.AddParam(MTParameterType.Integer, EventID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                RecurringEventManager manager = new RecurringEventManager();
                if (reader.Read())
                {
                  pattern = manager.ReadRecurrencePatternFromReader(reader);
                  mLogger.LogDebug("Retrieved {0} pattern for event Id {1}", pattern.ToString(), EventID);
                }
                else
                {
                  pattern = null;
                  mLogger.LogError("Pattern not found for event Id {0}", EventID);
                }
              }
            }
          }
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving Recurrence pattern from the system ", e);
          throw new MASBasicException("Error retrieving recurrence pattern");
        }
      }
    }

    public void UpdateRecurrencePattern(int EventID, BaseRecurrencePattern pattern)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateRecurrencePattern"))
      {
        try
        {
          string intervalType;
          int interval = 0;
          DateTime startDate = pattern.StartDate;
          string executionTimes = null;
          string daysOfWeek = null;
          string daysOfMonth = null;
          bool isPaused = pattern.IsPaused;
          DateTime OverrideDate = pattern.OverrideDate; ;
          DateTime UpdateDate = MetraTime.Now;

          if (pattern is MinutelyRecurrencePattern)
          {
            MinutelyRecurrencePattern minutely = (MinutelyRecurrencePattern)pattern;
            intervalType = "Minutely";
            interval = minutely.IntervalInMinutes;
          }
          else if (pattern is DailyRecurrencePattern)
          {
            DailyRecurrencePattern daily = (DailyRecurrencePattern)pattern;
            intervalType = "Daily";
            interval = daily.IntervalInDays;
            executionTimes = daily.ExecutionTimes.ToString();
          }
          else if (pattern is WeeklyRecurrencePattern)
          {
            WeeklyRecurrencePattern weekly = (WeeklyRecurrencePattern)pattern;
            intervalType = "Weekly";
            interval = weekly.IntervalInWeeks;
            executionTimes = weekly.ExecutionTimes.ToString();
            daysOfWeek = weekly.DaysOfWeek.ToString();
          }
          else if (pattern is MonthlyRecurrencePattern)
          {
            MonthlyRecurrencePattern monthly = (MonthlyRecurrencePattern)pattern;
            intervalType = "Monthly";
            interval = monthly.IntervalInMonth;
            executionTimes = monthly.ExecutionTimes.ToString();
            daysOfMonth = monthly.DaysOfMonth.ToString();
          }
          else if (pattern is ManualRecurrencePattern)
          {
            intervalType = "Manual";
          }
          else throw new UsageServerException(string.Format("Unknown interval type {0}", pattern.GetType().ToString()));

          using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(GetQueryText("__UPDATE_RECURRENCE_PATTERN__")))
            {
              stmt.AddParam(MTParameterType.String, intervalType);
              // for a manual it will be still uninitialized
              if (interval == 0) stmt.AddParam(MTParameterType.Integer, null);
              else stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.DateTime, startDate);
              stmt.AddParam(MTParameterType.String, executionTimes);
              stmt.AddParam(MTParameterType.String, daysOfWeek);
              stmt.AddParam(MTParameterType.String, daysOfMonth);
              stmt.AddParam(MTParameterType.String, isPaused == true ? "Y" : "N");
              if (OverrideDate == MetraTime.Min) stmt.AddParam(MTParameterType.DateTime, null);
              else stmt.AddParam(MTParameterType.DateTime, OverrideDate);
              stmt.AddParam(MTParameterType.DateTime, UpdateDate);

              stmt.AddParam(MTParameterType.Integer, EventID);

              stmt.ExecuteNonQuery();
            }
          }
          UsageServer.Client client = new UsageServer.Client();
          client.NotifyServiceOfConfigChange();
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving Recurrence pattern from the system ", e);
          throw new MASBasicException("Error retrieving recurrence pattern");
        }
      }
    }

    #endregion
  }
}
