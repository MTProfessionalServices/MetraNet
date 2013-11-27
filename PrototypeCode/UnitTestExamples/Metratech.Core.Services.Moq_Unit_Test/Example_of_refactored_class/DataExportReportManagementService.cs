using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using System.Reflection;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.MTAuth;
using System.Security.Cryptography;
using MetraTech.DataAccess;
using MetraTech.Security.Crypto;
using System.Transactions;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using MetraTech.Security;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IDataExportReportManagementService
  {

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddNewReportDefinition(string ReportTitle, string ReportType, string ReportDefinitionSource, string ReportDescription, string ReportQuerySource,
                                string ReportQueryTag, int PreventAdhocExecution);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateReportDefinition(int IDReport, string ReportDefinitionSource, string ReportDescription, string ReportQuerySource,
                                string ReportQueryTag, string ReportType, int PreventAdhocExecution);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteExistingReportDefinition(int IDReport);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreateNewReportInstance(int IDReport, string InstanceDescr, string ReportOutputType, string ReportDistributionType, string ReportDestination, string ReportExecutionType,
     string ReportXMLConfigLocation, DateTime ReportActivationDate, DateTime ReportDeActivationDate, string DestinationAccessUser, string DestinationAccessPassword,
     int CompressReport, int CompressThreshold, int DSID, string EOPInstanceName, int CreateControlFile, string ControlFileDestination, int OutputExecutionParameters,
     int UseQuotedIdentifiers, DateTime LastRunDateTime, DateTime NextRunDateTime, string ParameterDefaultNameValues, string OutputFileName);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateExistingReportInstance(int IDReport, int IDReportInstance, string InstanceDescr, string ReportOutputType, string ReportDistributionType,
          string ReportDestination, string ReportExecutionType, string ReportXMLConfigLocation, DateTime ReportActivationDate, DateTime ReportDeActivationDate,
          string DestinationAccessUser, string DestinationAccessPassword, int CompressReport, int CompressThreshold, string EOPInstanceName, int DSID,
          int CreateControlFile, string ControlFileDestination, int OutputExecutionParameters, int UseQuotedIdentifiers, DateTime LastRunDateTime,
          DateTime NextRunDateTime, string ParameterDefaultNameValues, string OutputFileName);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteExistingReportInstance(int IDReportInstance);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ScheduleReportInstance(int IDReportInstance, string ScheduleType, string ExecuteTime, int RepeatHours, string ExecuteStartTime, string ExecuteEndTime,
       int SkipFirstDayOfMonth, int SkipLastDayOfMonth, int DaysInterval, string ExecuteWeekDays, string SkipWeekDays, int ExecuteMonthDay, int ExecuteFirstDayOfMonth,
       int ExecuteLastDayOfMonth, string SkipTheseMonths, int MonthToDate, int IDReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteReportInstanceSchedule(int IDReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void QueueAdHocReport(int IDReport, string OutputType, string DeliveryType, string Destination, int CompressReport, int CompressThreshold, int Identifier,
      string ParameterNameValues, string FTPUser, string FTPPassword, int CreateControlFile, string ControlFileDestination, int OutputExecutionParametersInfo,
      string OutputFileName, int DSID, int UseQuotedIdentifiers);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteReportParameters(int ReportID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeleteOneReportParameter(int ReportID, int IDParameterName);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AssignNewReportParameter(int IDReport, int IDParameterName, string ParamDescr);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddNewReportParameters(string ParameterName, string ParameterDescription);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReportDefinitionParameters(int IDReport, ref MTList<ExportReportDefinition> reportParametersList);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdHocReportDefinitions(ref MTList<ExportReportDefinition> exportReportDefinition);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAllParametersAvailableForAssignment(int IDReport, ref MTList<ExportReportParameters> allAvailableReportParametersList);
    //void GetAllParameters(ref MTList<ExportReportParameters> allReportParametersList);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAllSchedulesOfAReportInstance(int IDReportInstance, ref MTList<ExportReportSchedule> exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReportDefinitionInfo(int IDReport, ref MTList<ExportReportDefinition> exportReportDefinition);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAReportDef(int IDReport, out ExportReportDefinition reportdef);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAllReportDefinitionInfo(ref MTList<ExportReportDefinition> exportReportDefinition);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAReportScheduleInfo(int IDReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAssignedReportDefinitionParametersInfo(int IDReport, ref MTList<ExportReportParameters> assignedReportParametersList);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReportDefinitionInfoFromReportTitle(int ReportTitle);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAllInstancesOfAReport(ref MTList<ExportReportInstance> exportReportInstances, int IDReport);
    //void GetAllInstancesOfAReport(ref MTList<ExportReportInstance> exportReportInstances);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAReportInstanceDetails(int IDReportInstance, ref MTList<ExportReportInstance> exportReportInstance);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetInstanceParameterValues(int IDReportInstance, ref MTList<ExportReportInstance> exportReportInstanceParamValues);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAReportInstance(int IDReportInstance, out ExportReportInstance reportinstance);

    //Report Instance Schedule Management  
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetADailyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAScheduleInfoDaily(int intincomingIDSchedule, out ExportReportSchedule exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAMonthlyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAScheduleInfoMonthly(int intincomingIDSchedule, out ExportReportSchedule exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAWeeklyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAScheduleInfoWeekly(int intincomingIDSchedule, out ExportReportSchedule exportReportSchedule);


    //Report Instance Schedule Management  
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CheckIfScheduleExists(int IDReportInstance, out ExportReportSchedule whetherscheduleexists);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateReportInstanceScheduleDaily(int IDReportInstance, int IDSchedule, string ExecuteTime, int RepeatHour, string ExecuteStartTime, string ExecuteEndTime,
       int SkipLastDayOfMonth, int SkipFirstDayOfMonth, int DaysInterval, int MonthToDate);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateReportInstanceScheduleWeekly(int IDReportInstance, int IDSchedule, string ExecuteTime, string ExecuteWeekDays, string SkipWeekDays, int MonthToDate);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateReportInstanceScheduleMonthly(int IDReportInstance, int IDSchedule, int ExecuteDay, string ExecuteTime, int ExecuteFirstDayOfMonth, int ExecuteLastDayOfMonth,
    string SkipMonths);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetExportLogDashboard(ref MTList<ExportReportInstance> getExportLogDashboard);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetExportQueueDashboard(ref MTList<ExportReportInstance> getExportQueueDashboard);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdateReportInstanceParameterValue(int IDParameterValueInstance, string ParameterValueInstance);


  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class DataExportReportManagementService : CMASServiceBase, IDataExportReportManagementService
  {
    private static ILogger mLogger = new Logger("[DataExportManagementService]");
    const string DATAEXPORTMANAGEMENT_QUERY_FOLDER = "Queries\\DataExportManagement";

    #region Additional changes for using FakeItEasy
    public delegate IMTConnection CreateConnectionDelegate();
    public delegate IMTConnection CreateConnectionFromPathDelegate(string pathToFolder);

    private CreateConnectionDelegate _createConnectionDelegate = null;
    private CreateConnectionFromPathDelegate _createConnectionFromPathDelegate = null;
      
    public DataExportReportManagementService()
    {
      _createConnectionDelegate = ConnectionManager.CreateConnection;
      _createConnectionFromPathDelegate = ConnectionManager.CreateConnection;
    }

    public DataExportReportManagementService(CreateConnectionDelegate createConnDelegate, CreateConnectionFromPathDelegate createConnFromPathDelegate)
    {
      _createConnectionDelegate = createConnDelegate;
      _createConnectionFromPathDelegate = createConnFromPathDelegate;
    }

    #endregion Additional changes for using FakeItEasy

    #region Interface Methods.
    /// <summary>
    /// 
    /// </summary>

    // Add New Report Definition
    public void AddNewReportDefinition(string ReportTitle, string ReportType, string ReportDefinitionSource, string ReportDescription, string ReportQuerySource,
        string ReportQueryTag, int PreventAdhocExecution)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddNewReportDefinition"))
      {
        try
        {
          using (IMTConnection conn = _createConnectionDelegate())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_InsertReportDefinition"))
            {
              callStmt.AddParam("c_report_title", MTParameterType.String, ReportTitle);
              callStmt.AddParam("c_report_desc", MTParameterType.String, ReportDescription);
              callStmt.AddParam("c_rep_type", MTParameterType.String, ReportType);
              callStmt.AddParam("c_rep_def_source", MTParameterType.String, ReportDefinitionSource);
              callStmt.AddParam("c_rep_query_source", MTParameterType.String, ReportQuerySource);
              callStmt.AddParam("c_rep_query_tag", MTParameterType.String, ReportQueryTag);
              callStmt.AddParam("c_prevent_adhoc_execution", MTParameterType.Integer, PreventAdhocExecution);
              mLogger.LogInfo("Executing sp export_InsertReportDefinition to create a new report definition..");
              callStmt.ExecuteReader();
            }
          }
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Report Creation Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Report Creation Failed", e);

          throw new MASBasicException("Report Creation Failed");
        }
      }
    }

    public void UpdateReportDefinition(int IDReport, string ReportDefinitionSource, string ReportDescription, string ReportQuerySource,
                                string ReportQueryTag, string ReportType, int PreventAdhocExecution)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateReportDefinition"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateReportDefinition"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              callStmt.AddParam("c_rep_type", MTParameterType.String, ReportType);
              callStmt.AddParam("c_report_desc", MTParameterType.String, ReportDescription);
              callStmt.AddParam("c_rep_def_source", MTParameterType.String, ReportDefinitionSource);
              callStmt.AddParam("c_rep_query_source", MTParameterType.String, ReportQuerySource);
              callStmt.AddParam("c_rep_query_tag", MTParameterType.String, ReportQueryTag);
              callStmt.AddParam("c_prevent_adhoc_execution", MTParameterType.Integer, PreventAdhocExecution);
              mLogger.LogInfo("Executing sp export_UpdateReportDefinition to update existing report definition..");
              callStmt.ExecuteReader();
            }
          }
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Updating Existing Report Definition Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Updating Existing Report Definition Failed", e);

          throw new MASBasicException("Updating Existing Report Definition Failed");
        }
      }
    }

    // Delete Existing Report Definition 
    public void DeleteExistingReportDefinition(int IDReport)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteExistingReportDefinition"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_DeleteReportDefintion"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              mLogger.LogInfo("Executing export_DeleteReportDefintion to delete an existing report definition..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Delete Report Definition Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Delete Report Definition Failed", e);

          throw new MASBasicException("Delete Report Definition Failed");
        }
      }
    }



    // Add New Report Definition
    public void CreateNewReportInstance(int IDReport, string InstanceDescr, string ReportOutputType, string ReportDistributionType, string ReportDestination,
    string ReportExecutionType, string ReportXMLConfigFileLocation, DateTime ReportActivationDate, DateTime ReportDeActivationDate, string DestinationAccessUser,
    string DestinationAccessPassword, int CompressReport, int CompressThreshold, int DSID, string EOPInstanceName, int CreateControlFile, string ControlFileDestination,
    int OutputExecutionParameters, int UseQuotedIdentifiers, DateTime LastRunDateTime, DateTime NextRunDateTime, string ParameterDefaultNameValues, string OutputFileName)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreateNewReportInstance"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_CreateReportInstance"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              callStmt.AddParam("desc", MTParameterType.String, InstanceDescr);
              callStmt.AddParam("outputType", MTParameterType.String, ReportOutputType);
              callStmt.AddParam("distributionType", MTParameterType.String, ReportDistributionType);
              callStmt.AddParam("destination", MTParameterType.String, ReportDestination);
              callStmt.AddParam("ReportExecutionType", MTParameterType.String, ReportExecutionType);
              callStmt.AddParam("xmlConfigLocation", MTParameterType.String, ReportXMLConfigFileLocation);
              callStmt.AddParam("c_report_online", MTParameterType.Integer, 0);
              callStmt.AddParam("dtActivate", MTParameterType.DateTime, ReportActivationDate);
              callStmt.AddParam("dtDeActivate", MTParameterType.DateTime, ReportDeActivationDate);
              callStmt.AddParam("directMoveToDestn", MTParameterType.Integer, 0);
              callStmt.AddParam("destnAccessUser", MTParameterType.String, DestinationAccessUser);
              callStmt.AddParam("destnAccessPwd", MTParameterType.String, DestinationAccessPassword);
              callStmt.AddParam("compressreport", MTParameterType.Integer, CompressReport);
              callStmt.AddParam("compressthreshold", MTParameterType.Integer, CompressThreshold);
              callStmt.AddParam("ds_id", MTParameterType.Integer, DSID);
              callStmt.AddParam("eopinstancename", MTParameterType.String, EOPInstanceName);
              callStmt.AddParam("createcontrolfile", MTParameterType.Integer, CreateControlFile);
              callStmt.AddParam("controlfiledelivery", MTParameterType.String, ControlFileDestination);
              callStmt.AddParam("outputExecuteParams", MTParameterType.Integer, OutputExecutionParameters);
              callStmt.AddParam("UseQuotedIdentifiers", MTParameterType.Integer, UseQuotedIdentifiers);
              callStmt.AddParam("dtLastRunDateTime", MTParameterType.DateTime, LastRunDateTime);
              callStmt.AddParam("dtNextRunDateTime", MTParameterType.DateTime, NextRunDateTime);
              callStmt.AddParam("paramDefaultNameValues", MTParameterType.String, ParameterDefaultNameValues);
              callStmt.AddParam("outputFileName", MTParameterType.String, OutputFileName);
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());
              callStmt.AddOutputParam("ReportInstanceId", MTParameterType.Integer);

              mLogger.LogInfo("Executing export_CreateReportInstance to create a new report instance..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Report Instance Creation Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Report Instance Creation Failed", e);
          throw new MASBasicException("Report Instance Creation Failed");
        }
      }
    }

    // Update Existing Report Instance
    public void UpdateExistingReportInstance(int IDReport, int IDReportInstance, string InstanceDescr, string ReportOutputType, string ReportDistributionType,
    string ReportDestination, string ReportExecutionType, string ReportXMLConfigFileLocation, DateTime ReportActivationDate, DateTime ReportDeActivationDate,
    string DestinationAccessUser, string DestinationAccessPassword, int CompressReport, int CompressThreshold, string EOPInstanceName, int DSID, int CreateControlFile,
    string ControlFileDestination, int OutputExecutionParameters, int UseQuotedIdentifiers, DateTime LastRunDateTime, DateTime NextRunDateTime, string ParameterDefaultNameValues,
    string OutputFileName)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateExistingReportInstance"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateReportInstance"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              callStmt.AddParam("ReportInstanceId", MTParameterType.Integer, IDReportInstance);
              callStmt.AddParam("desc", MTParameterType.String, InstanceDescr);
              callStmt.AddParam("outputType", MTParameterType.String, ReportOutputType);
              callStmt.AddParam("distributionType", MTParameterType.String, ReportDistributionType);
              callStmt.AddParam("destination", MTParameterType.String, ReportDestination);
              callStmt.AddParam("ReportExecutionType", MTParameterType.String, ReportExecutionType);
              callStmt.AddParam("xmlConfigLocation", MTParameterType.String, ReportXMLConfigFileLocation);
              callStmt.AddParam("dtActivate", MTParameterType.DateTime, ReportActivationDate);
              callStmt.AddParam("dtDeActivate", MTParameterType.DateTime, ReportDeActivationDate);
              callStmt.AddParam("destnAccessUser", MTParameterType.String, DestinationAccessUser);
              callStmt.AddParam("destnAccessPwd", MTParameterType.String, DestinationAccessPassword);
              callStmt.AddParam("compressreport", MTParameterType.Integer, CompressReport);
              callStmt.AddParam("compressthreshold", MTParameterType.Integer, CompressThreshold);
              callStmt.AddParam("ds_id", MTParameterType.Integer, DSID);
              callStmt.AddParam("eopinstancename", MTParameterType.String, EOPInstanceName);
              callStmt.AddParam("createcontrolfile", MTParameterType.Integer, CreateControlFile);
              callStmt.AddParam("controlfiledelivery", MTParameterType.String, ControlFileDestination);
              callStmt.AddParam("outputExecuteParams", MTParameterType.Integer, OutputExecutionParameters);
              callStmt.AddParam("UseQuotedIdentifiers", MTParameterType.Integer, UseQuotedIdentifiers);
              callStmt.AddParam("dtLastRunDateTime", MTParameterType.DateTime, LastRunDateTime);
              callStmt.AddParam("dtNextRunDateTime", MTParameterType.DateTime, NextRunDateTime);
              callStmt.AddParam("outputFileName", MTParameterType.String, OutputFileName);
              callStmt.AddParam("paramDefaultNameValues", MTParameterType.String, ParameterDefaultNameValues);

              mLogger.LogInfo("Executing export_UpdateReportInstance to update an existing report instance..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Report Instance Update Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Report Instance Update Failed", e);

          throw new MASBasicException("Report Instance Update Failed");
        }
      }
    }



    // Delete Existing Report Instance 
    public void DeleteExistingReportInstance(int IDReportInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteExistingReportInstance"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_DeleteReportInstance"))
            {
              callStmt.AddParam("id_rep_instance", MTParameterType.Integer, IDReportInstance);

              mLogger.LogInfo("Executing export_DeleteReportInstance to delete an existing report instance..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Report Instance Delete Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Report Instance Delete Failed", e);

          throw new MASBasicException("Report Instance Delete Failed");
        }
      }
    }


    // Create a New Report Instance Schedule  
    public void ScheduleReportInstance(int IDReportInstance, string ScheduleType, string ExecuteTime, int RepeatHours, string ExecuteStartTime,
       string ExecuteEndTime, int SkipFirstDayOfMonth, int SkipLastDayOfMonth, int DaysInterval, string ExecuteWeekDays, string SkipWeekDays,
       int ExecuteMonthDay, int ExecuteFirstDayOfMonth, int ExecuteLastDayOfMonth, string SkipTheseMonths, int MonthToDate, int IDReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ScheduleReportInstance"))
      {
        try
        {
          /*
          if ((SkipWeekDays.Substring(1, 1)) == ",")
          {
            SkipWeekDays = SkipWeekDays.Replace((SkipWeekDays.Substring(1, 1)), "");
          }

          if (ExecuteWeekDays.Substring(1, 1) == ",")
          {
            ExecuteWeekDays = ExecuteWeekDays.Replace((ExecuteWeekDays.Substring(1, 1)), "");
          }

          if (SkipTheseMonths.Substring(1, 1) == ",")
          {
            SkipTheseMonths = SkipTheseMonths.Replace((SkipTheseMonths.Substring(1, 1)), "");
          }
          */
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("export_ScheduleReportInstance"))
            {
              callStmt.AddParam("ReportInstanceId", MTParameterType.Integer, IDReportInstance);
              callStmt.AddParam("ScheduleType", MTParameterType.String, ScheduleType);
              callStmt.AddParam("ExecuteTime", MTParameterType.String, ExecuteTime);
              callStmt.AddParam("RepeatHours", MTParameterType.Integer, RepeatHours);
              callStmt.AddParam("ExecuteStartTime", MTParameterType.String, ExecuteStartTime);
              callStmt.AddParam("ExecuteEndTime", MTParameterType.String, ExecuteEndTime);
              callStmt.AddParam("SkipFirstDayOfMonth", MTParameterType.Integer, SkipFirstDayOfMonth);//BIT type
              callStmt.AddParam("SkipLastDayOfMonth", MTParameterType.Integer, SkipLastDayOfMonth);//BIT type
              callStmt.AddParam("DaysInterval", MTParameterType.Integer, DaysInterval);
              callStmt.AddParam("ExecuteWeekDays", MTParameterType.String, ExecuteWeekDays);
              callStmt.AddParam("SkipWeekDays", MTParameterType.String, SkipWeekDays);
              callStmt.AddParam("ExecuteMonthDay", MTParameterType.Integer, ExecuteMonthDay);
              callStmt.AddParam("ExecuteFirstDayOfMonth", MTParameterType.Integer, ExecuteFirstDayOfMonth);//BIT type
              callStmt.AddParam("ExecuteLastDayOfMonth", MTParameterType.Integer, ExecuteLastDayOfMonth);//BIT type
              callStmt.AddParam("SkipTheseMonths", MTParameterType.String, SkipTheseMonths);
              callStmt.AddParam("monthtodate", MTParameterType.Integer, MonthToDate);//BIT type
              callStmt.AddParam("ValidateOnly", MTParameterType.Integer, 0);//BIT type
              callStmt.AddParam("IdRpSchedule", MTParameterType.Integer, IDReportSchedule);
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());
              callStmt.AddOutputParam("ScheduleId", MTParameterType.Integer);

              mLogger.LogInfo("Executing export_ScheduleReportInstance to schedule a report instance..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Scheduling Report Instance Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Scheduling Report Instance Failed", e);

          throw new MASBasicException("Scheduling Report Instance Failed");
        }
      }
    }


    // Delete a Report Instance Schedule  
    public void DeleteReportInstanceSchedule(int IDReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteReportInstanceSchedule"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);
            queryAdapter.SetQueryTag("__EXPORT_DELETE_REPORT_INSTANCE_SCHEDULE__");
            queryAdapter.AddParam("%%ID_RP_SCHEDULE%%", IDReportSchedule, true);

            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
            {
              mLogger.LogInfo("Executing direct delete query to delete report instance schedule..");
              stmt.ExecuteNonQuery();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Deleting Report Instance Schedule Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Deleting Report Instance Schedule Failed", e);

          throw new MASBasicException("Deleting Report Instance Schedule Failed");
        }
      }
    }


    // Queue AdHoc Report   
    public void QueueAdHocReport(int IDReport, string OutputType, string DeliveryType, string Destination, int CompressReport, int CompressThreshold, int Identifier,
       string ParameterNameValues, string FTPUser, string FTPPassword, int CreateControlFile, string ControlFileDestination, int OutputExecutionParametersInfo,
       string OutputFileName, int DSID, int UseQuotedIdentifiers)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("QueueAdHocReport"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_Queue_AdHocReport"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              callStmt.AddParam("outputType", MTParameterType.String, OutputType);
              callStmt.AddParam("deliveryType", MTParameterType.String, DeliveryType);
              callStmt.AddParam("destn", MTParameterType.String, Destination);
              callStmt.AddParam("compressReport", MTParameterType.Integer, CompressReport);//BIT
              callStmt.AddParam("compressThreshold", MTParameterType.Integer, CompressThreshold);
              callStmt.AddParam("identifier", MTParameterType.String, Identifier);
              callStmt.AddParam("paramNameValues", MTParameterType.String, ParameterNameValues);
              callStmt.AddParam("ftpUser", MTParameterType.String, FTPUser);
              callStmt.AddParam("ftpPassword", MTParameterType.String, FTPPassword);
              callStmt.AddParam("createControlFile", MTParameterType.Integer, CreateControlFile);//BIT
              callStmt.AddParam("controlFileDestn", MTParameterType.String, ControlFileDestination);
              callStmt.AddParam("outputExecParamsInfo", MTParameterType.Integer, OutputExecutionParametersInfo);//BIT
              callStmt.AddParam("dsid", MTParameterType.String, DSID);
              callStmt.AddParam("outputFileName", MTParameterType.String, OutputFileName);
              callStmt.AddParam("usequotedidentifiers", MTParameterType.Integer, UseQuotedIdentifiers);//BIT
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());

              mLogger.LogInfo("Executing stored procedure export_Queue_AdHocReport to queue AdHoc Report..");
              callStmt.ExecuteReader();
            }
          }
        }
        //scope.Complete();

        catch (MASBasicException masE)
        {
          mLogger.LogException("Queue AdHoc Report Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Queue AdHoc Report Failed", e);
          throw new MASBasicException("Queue AdHoc Report Failed");
        }
      }
    }

    // Delete all parameters assigned to a report
    public void DeleteReportParameters(int ReportID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteReportParameters"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);
            queryAdapter.SetQueryTag("__EXPORT_DELETE_PARAMETERS_FOR_REPORT__");
            queryAdapter.AddParam("%%ID_REP%%", ReportID, true);

            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
            {
              mLogger.LogInfo("Executing direct delete query to remove all parameters assigned to a report..");
              stmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Deleting Report Parameter Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Deleting Report Parameter Failed", e);

          throw new MASBasicException("Deleting Report Parameter Failed");
        }
      }
    }

    // Delete One Report Parameter at a time 
    public void DeleteOneReportParameter(int ReportID, int IDParameterName)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeleteOneReportParameter"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_DeleteAssignedReportPar"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, ReportID);
              callStmt.AddParam("id_param_name", MTParameterType.Integer, IDParameterName);

              mLogger.LogInfo("Executing stored procedure Export_DeleteAssignedReportPar to remove one report parameter at a time..");
              callStmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Deleting One Report Parameter Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Deleting One Report Parameter Failed", e);
          throw new MASBasicException("Deleting One Report Parameter Failed");
        }
      }
    }


    // Add New Report Parameters      
    public void AddNewReportParameters(string ParameterName, string ParameterDescription)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddNewReportParameters"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("export_InsertParamName"))
            {
              callStmt.AddParam("paramName", MTParameterType.String, ParameterName);
              callStmt.AddParam("paramDesc", MTParameterType.String, ParameterDescription);

              mLogger.LogInfo("Adding New Report Parameters..");
              callStmt.ExecuteNonQuery();
              mLogger.LogInfo("Adding New Report Parameters Completed..");
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Adding New Report Parameter Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Adding New Report Parameter Failed..", e);
          throw new MASBasicException("Adding New Report Parameter Failed..");
        }
      }
    }

    // Add/Assign New Report Parameters      
    public void AssignNewReportParameter(int IDReport, int IDParameterName, string ParamDescr)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AssignNewReportParameter"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_AssignNewReportParams"))
            {
              callStmt.AddParam("id_rep", MTParameterType.Integer, IDReport);
              callStmt.AddParam("id_param_name", MTParameterType.Integer, IDParameterName);
              callStmt.AddParam("descr", MTParameterType.String, ParamDescr);

              mLogger.LogInfo("Adding One New Report Parameter at a time..");
              callStmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Adding One New Report Parameter at a time Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Adding One New Report Parameter at a time Failed..", e);
          throw new MASBasicException("Adding One New Report Parameter at a time Failed..");
        }
      }
    }


    //Get Report Parameters for a given report by executing GetReportDefinitionParameters

    public void GetReportDefinitionParameters(int IDReport, ref MTList<ExportReportDefinition> reportParametersList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReportDefinitionParameters"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_REPORT_DEFINITION_PARAMETERS_FOR_DISPLAY__"))
            {
              stmt.AddParam("%%ID_REP%%", IDReport);
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  ExportReportDefinition erp = new ExportReportDefinition();

                  erp.ParameterName = rdr.GetString(0);
                  erp.ParameterDescription = rdr.IsDBNull(1) ? String.Empty : rdr.GetString(1);
                  reportParametersList.Items.Add(erp);
                }
              }
              reportParametersList.TotalRows = stmt.TotalRows;
            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Selecting Parameters Assigned to a Given Report Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Selecting Parameters Assigned to a Given Report Failed..", e);
          throw new MASBasicException("Selecting Parameters Assigned to a Given Report Failed..");
        }
      }
    }


    //Get All AdHoc Reports along with their parameteres by executing select query

    public void GetAdHocReportDefinitions(ref MTList<ExportReportDefinition> exportReportDefinition)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdHocReportDefinitions"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_ADHOC_REPORT_DEFINITIONS__"))
            {
              ApplyFilterSortCriteria<ExportReportDefinition>(stmt, exportReportDefinition);
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  ExportReportDefinition reportdefinition = new ExportReportDefinition();

                  reportdefinition.ReportID = rdr.GetInt32(0);
                  reportdefinition.ReportTitle = rdr.GetString(1);
                  reportdefinition.ReportDescription = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);
                  if ((rdr.GetInt32(3)) == 0)
                  {
                    //reportdefinition.PreventAdhocExecution = PreventAdhocExecutionEnum.No;
                    reportdefinition.bPreventAdhocExecution = false;
                  }
                  else
                  {
                    reportdefinition.bPreventAdhocExecution = true;
                  }
                  exportReportDefinition.Items.Add(reportdefinition);
                }
              }
              exportReportDefinition.TotalRows = stmt.TotalRows;
            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Adhoc Report Definitions Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Adhoc Report Definitions Failed..", e);
          throw new MASBasicException("Get Adhoc Report Definitions Failed..");
        }
      }
    }

    //Get All Parameteres currently available for assignment to a given report in the system 

    public void GetAllParametersAvailableForAssignment(int IDReport, ref MTList<ExportReportParameters> allAvailableReportParametersList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAllParametersAvailableForAssignment"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_AVAILABLE_FOR_ASSIGNMENT_PARAMETERS_LIST__"))
            {
              ApplyFilterSortCriteria<ExportReportParameters>(stmt, allAvailableReportParametersList);

              stmt.AddParam("%%ID_REP%%", IDReport);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  ExportReportParameters exportreportparameters = new ExportReportParameters();

                  exportreportparameters.IDParameter = rdr.GetInt32(0);
                  exportreportparameters.ParameterName = rdr.GetString(1);
                  exportreportparameters.ParameterDescription = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);

                  allAvailableReportParametersList.Items.Add(exportreportparameters);

                }

              }

              allAvailableReportParametersList.TotalRows = stmt.TotalRows;

              mLogger.LogInfo("Selecting All Parameters available for assignment to this report..");

            }
          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Selecting All Parameters available for assignment to this report..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Selecting All Parameters available for assignment to this report..", e);

          throw new MASBasicException("Selecting All Parameters available in the system Failed..");
        }
      }
    }


    //Get All Schedules of a Report Instance 

    public void GetAllSchedulesOfAReportInstance(int IDReportInstance, ref MTList<ExportReportSchedule> exportReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAllSchedulesOfAReportInstance"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_REPORT_INSTANCE_SCHEDULES__"))
            {
              stmt.AddParam("%%ID_REP_INSTANCE%%", IDReportInstance);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  ExportReportSchedule ers = new ExportReportSchedule();

                  ers.IDSchedule = rdr.GetInt32(0);

                  if ((rdr.GetString(1).ToLower() == "daily"))
                  {
                    //ers.ScheduleType = (ScheduleTypeEnum.Daily).ToString();
                    ers.ScheduleTypeText = "Daily";
                  }
                  else
                  {
                    if ((rdr.GetString(1).ToLower() == "weekly"))
                    {
                      //ers.ScheduleType = (ScheduleTypeEnum.Weekly).ToString();
                      ers.ScheduleTypeText = "Weekly";
                    }
                    else
                    {
                      //ers.ScheduleType = (ScheduleTypeEnum.Monthly).ToString();
                      ers.ScheduleTypeText = "Monthly";
                    }

                  }

                  exportReportSchedule.Items.Add(ers);

                }
              }

              exportReportSchedule.TotalRows = stmt.TotalRows;

            }
          }
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Selecting All Schedules of a Report Instance Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Selecting All Schedules of a Report Instance Failed..", e);

          throw new MASBasicException("Selecting All Schedules of a Report Instance Failed..");
        }
      }
    }


    //Get Report Definition Info of a report
    public void GetReportDefinitionInfo(int IDReport, ref MTList<ExportReportDefinition> exportReportDefinition)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReportDefinitionInfo"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_REPORT_DEF_INFO__"))
            {
              stmt.AddParam("%%ID_REP%%", IDReport);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {


                while (rdr.Read())
                {
                  ExportReportDefinition reportdefinition = new ExportReportDefinition();

                  reportdefinition.ReportID = rdr.GetInt32(0);
                  reportdefinition.ReportTitle = rdr.GetString(1);
                  reportdefinition.ReportType = rdr.GetString(2);
                  reportdefinition.ReportDefinitionSource = rdr.IsDBNull(3) ? String.Empty : rdr.GetString(3);
                  reportdefinition.ReportQuerySource = rdr.IsDBNull(4) ? String.Empty : rdr.GetString(4);
                  reportdefinition.ReportQueryTag = rdr.IsDBNull(5) ? String.Empty : rdr.GetString(5);
                  reportdefinition.ReportDescription = rdr.IsDBNull(6) ? String.Empty : rdr.GetString(6);

                  if ((rdr.GetInt32(7)) == 0)
                  {
                    //reportdefinition.PreventAdhocExecution = PreventAdhocExecutionEnum.Yes;
                    reportdefinition.bPreventAdhocExecution = false;
                  }
                  else
                  {
                    //reportdefinition.PreventAdhocExecution = PreventAdhocExecutionEnum.No;
                    reportdefinition.bPreventAdhocExecution = true;
                  }

                  exportReportDefinition.Items.Add(reportdefinition);
                }

              }

              exportReportDefinition.TotalRows = stmt.TotalRows;
            }

          }
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Report Definition Info Failed for report id", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Report Definition Info Failed for report id..", e);

          throw new MASBasicException("Get Report Definition Info Failed for report id..");
        }

      }
    }


    //Get All Report Definition Info of a report 
    public void GetAllReportDefinitionInfo(ref MTList<ExportReportDefinition> exportReportDefinition)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAllReportDefinitionInfo"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            //using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER,"__GET_REPORT_DEFINITIONS__"))
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_REPORT_DEFINITIONS__"))
            {
              ApplyFilterSortCriteria<ExportReportDefinition>(stmt, exportReportDefinition);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {
                  ExportReportDefinition reportdefinition = new ExportReportDefinition();

                  reportdefinition.ReportID = rdr.GetInt32(0);
                  reportdefinition.ReportTitle = rdr.GetString(1);
                  reportdefinition.ReportDescription = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);
                  if ((rdr.GetInt32(3)) == 0)
                  {
                    //reportdefinition.PreventAdhocExecution = PreventAdhocExecutionEnum.No;
                    reportdefinition.bPreventAdhocExecution = false;
                  }
                  else
                  {
                    reportdefinition.bPreventAdhocExecution = true;
                    //reportdefinition.PreventAdhocExecution = PreventAdhocExecutionEnum.Yes;
                  }

                  //reportdefinition.PreventAdhocExecution = rdr.GetInt32(3); 

                  exportReportDefinition.Items.Add(reportdefinition);
                }
              }

              exportReportDefinition.TotalRows = stmt.TotalRows;


            }
          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get All Report Definition Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get All Report Definition Info Failed..", e);

          throw new MASBasicException("Get All Report Definition Info Failed..");
        }

      }
    }

    //Get A Schedule Info  
    public void GetAReportScheduleInfo(int IDReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAReportScheduleInfo"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);

            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER,
                                                               "__EXPORT_GET_SCHEDULE_INFO__"))
            {

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                stmt.AddParam("%%ID_RP_SCHEDULE%%", IDReportSchedule, true);

                while (rdr.Read())
                  //IMTCollection reportparams = new IMTCollection();
                  //reportparams.Add(rdr.GetString());                                
                  //paramname = rdr.GetString(0);
                  mLogger.LogInfo("The param number is ");
                //paramcount = paramcount++;

              }

              mLogger.LogInfo("Get A Report Schedule Info..");
              //stmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get A Report Schedule Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get A Report Schedule Info Failed..", e);

          throw new MASBasicException("Get A Report Schedule Info Failed..");
        }

      }
    }


    //Get A Schedule Info  
    public void GetAssignedReportDefinitionParametersInfo(int IDReport, ref MTList<ExportReportParameters> assignedReportParametersList)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAssignedReportDefinitionParametersInfo"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_ASSIGNED_REPORT_DEFINITIONS_PARAMETERS__"))
            {
              ApplyFilterSortCriteria<ExportReportParameters>(stmt, assignedReportParametersList);

              stmt.AddParam("%%ID_REP%%", IDReport, true);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  ExportReportParameters assignedreportparameters = new ExportReportParameters();

                  assignedreportparameters.IDParameter = rdr.GetInt32(0);
                  assignedreportparameters.ParameterName = rdr.GetString(1);
                  assignedreportparameters.ParameterDescription = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);


                  assignedReportParametersList.Items.Add(assignedreportparameters);
                }
              }

              assignedReportParametersList.TotalRows = stmt.TotalRows;

            }
          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Assigned Report Definition Parameter Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Assigned Report Definition Parameter Failed..", e);

          throw new MASBasicException("Get Assigned Report Definition Parameter Failed..");
        }
      }
    }

    //Get A Schedule Info  
    public void GetSelectedParameters(int IDParameters)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetSelectedParameters"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);

            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER,
                                                               "__EXPORT_GET_SELECTED_PARAMETERS__"))
            {

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                stmt.AddParam("%%PARAMETER_IDS%%", IDParameters, true);

                while (rdr.Read())
                  //IMTCollection reportparams = new IMTCollection();
                  //reportparams.Add(rdr.GetString());                                
                  //paramname = rdr.GetString(0);
                  mLogger.LogInfo("The param number is ");
                //paramcount = paramcount++;

              }

              mLogger.LogInfo("Get Selected Parameters..");
              //stmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Selected Parameters Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Selected Parameters Failed..", e);

          throw new MASBasicException("Get Selected Parameters Failed..");
        }
      }
    }

    //Get Report Definition Info of a report 
    public void GetReportDefinitionInfoFromReportTitle(int ReportTitle)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReportDefinitionInfoFromReportTitle"))
      {

        try
        {
          int IDReport = 0;
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            QueryAdapter.MTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
            queryAdapter.Init(DATAEXPORTMANAGEMENT_QUERY_FOLDER);

            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER,
                                                               "__EXPORT_REPORT_DEF_INFO_FROM_REPORT_TITLE__"))
            {

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                stmt.AddParam("%%REPORT_TITLE%%", ReportTitle, true);
                //string reportparams[] = new string[paramcount];
                //int IDReport=0;
                while (rdr.Read())

                  //IMTCollection reportparams = new IMTCollection();
                  //reportparams.Add(rdr.GetString());                                
                  IDReport = rdr.GetInt32(0);
                mLogger.LogInfo("The Report ID is {0}  ", IDReport);
                //paramcount = paramcount++;

              }

              mLogger.LogInfo("Get Report Definition Info from Report Title..");
              //stmt.ExecuteNonQuery();
            }
          }
          //scope.Complete();
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Report Definition Info from Report Title Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Report Definition Info from Report Title Failed..", e);

          throw new MASBasicException("Get Report Definition Info from Report Title Failed..");
        }

      }
    }



    //Get All Instances of a Report 
    //public void GetAllInstancesOfAReport(ref MTList<ExportReportInstance> exportReportInstances)
    public void GetAllInstancesOfAReport(ref MTList<ExportReportInstance> exportReportInstances, int IDReport)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAllInstancesOfAReport"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            //using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_REPORT_INSTANCES__"))

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_REPORT_INSTANCES__"))
            {
              ApplyFilterSortCriteria<ExportReportInstance>(stmt, exportReportInstances);

              stmt.AddParam("%%ID_REP%%", IDReport);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {

                  ExportReportInstance reportinstances = new ExportReportInstance();

                  reportinstances.IDReportInstance = rdr.GetInt32(0);
                  reportinstances.IDReport = rdr.GetInt32(1);
                  reportinstances.ReportInstanceDescription = rdr.GetString(2);
                  reportinstances.ReportExecutionTypeText = rdr.IsDBNull(3) ? String.Empty : rdr.GetString(3);
                  reportinstances.ReportTitle = rdr.GetString(4);

                  exportReportInstances.Items.Add(reportinstances);

                }

              }

              exportReportInstances.TotalRows = stmt.TotalRows;

              foreach (ExportReportInstance eri in exportReportInstances.Items)
              {

                mLogger.LogDebug("The Report ID value in the list is : {0}  ", eri.IDReport);
                mLogger.LogDebug("The Report Instance ID value in the list is : {0}  ", eri.IDReportInstance);
                mLogger.LogDebug("The Report Instance Description value in the list is : {0}  ", eri.ReportInstanceDescription);
                mLogger.LogDebug("The Execution Type value in the list is : {0}  ", eri.ReportExecutionType);
              }

              mLogger.LogDebug("There are {0}  items in the report instance list", exportReportInstances.Items.Count.ToString());

            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Report Instances Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Report Instances Info Failed....", e);

          throw new MASBasicException("Get Report Instances Info Failed..");
        }
      }
    }


    //Get Details of a Report Instance  
    public void GetAReportInstanceDetails(int IDReportInstance, ref MTList<ExportReportInstance> exportReportInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAReportInstanceDetails"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            //using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_REPORT_INSTANCES__"))

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_A_REPORT_INSTANCE_DETAILS__"))
            {

              stmt.AddParam("%%ID_REP_INSTANCE_ID%%", IDReportInstance);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {

                  ExportReportInstance reportinstance = new ExportReportInstance();

                  reportinstance.ReportInstanceDescription = rdr.GetString(0);

                  //Show Report Onlne True/False
                  if (rdr.GetString(1) == "No")
                  {
                    reportinstance.OnlineReport = ShowReportOnlineEnum.No;
                  }
                  else
                  {
                    reportinstance.OnlineReport = ShowReportOnlineEnum.No;
                  }

                  reportinstance.InstanceActivationDate = rdr.GetDateTime(2);
                  reportinstance.InstanceDeactivationDate = rdr.GetDateTime(3);

                  if (rdr.GetString(4) == "XML")
                  {
                    reportinstance.ReportOutputType = ReportOutputTypeEnum.XML;
                  }
                  else
                  {
                    if (rdr.GetString(4) == "TXT")
                    {
                      reportinstance.ReportOutputType = ReportOutputTypeEnum.TXT;
                    }
                    else
                    {
                      reportinstance.ReportOutputType = ReportOutputTypeEnum.CSV;
                    }
                  }

                  reportinstance.XMLConfigLocation = rdr.GetString(5);


                  if (rdr.GetString(6) == "Disk")
                  {

                    reportinstance.ReportDistributionType = ReportDeliveryTypeEnum.Disk;
                  }
                  else
                  {

                    reportinstance.ReportDistributionType = ReportDeliveryTypeEnum.FTP;
                  }


                  reportinstance.ReportDestination = rdr.IsDBNull(7) ? String.Empty : rdr.GetString(7);
                  reportinstance.FTPAccessUser = rdr.IsDBNull(8) ? String.Empty : rdr.GetString(8);

                  if (rdr.IsDBNull(9))
                  {
                    reportinstance.FTPAccessPassword = String.Empty;
                  }
                  else
                  {
                    var encryptedPassword = rdr.GetString(9);

                    //Decrypt the password
                    var cryptoManager = new CryptoManager();
                    var decryptedPassword = cryptoManager.Decrypt(CryptKeyClass.DatabasePassword, encryptedPassword);

                    reportinstance.FTPAccessPassword = decryptedPassword;
                  }

                  //if (rdr.GetString(10) == "Adhoc")
                  //{

                  //  reportinstance.ReportExecutionType = ReportExecutionTypeEnum.AdHoc;
                  //}
                  //else 
                  //{
                  if (rdr.GetString(10) == "EOP")
                  {
                    reportinstance.ReportExecutionType = ReportExecutionTypeEnum.EOP;

                  }
                  else
                  {
                    reportinstance.ReportExecutionType = ReportExecutionTypeEnum.Scheduled;

                  }

                  //}

                  if (rdr.GetString(11) == "No")
                  {
                    reportinstance.bGenerateControlFile = false;
                    //reportinstance.GenerateControlFile = GenerateControlFileEnum.No;
                  }
                  else
                  {
                    reportinstance.bGenerateControlFile = true;
                    //reportinstance.GenerateControlFile = GenerateControlFileEnum.Yes;
                  }

                  reportinstance.ControlFileDeliveryLocation = rdr.IsDBNull(12) ? String.Empty : rdr.GetString(12);


                  if (rdr.GetString(14) == "No")
                  {
                    reportinstance.bCompressReport = false;
                    //reportinstance.CompressReport = CompressReportEnum.No;
                  }
                  else
                  {
                    reportinstance.bCompressReport = true;
                    //reportinstance.CompressReport = CompressReportEnum.Yes;
                  }

                  reportinstance.CompressThreshold = rdr.GetInt32(15);

                  if (rdr.GetString(16) == "No")
                  {
                    reportinstance.bOutputExecParameters = false;
                    //reportinstance.OutputExecParameters = WriteExecParamsToReportEnum.No;
                  }
                  else
                  {
                    reportinstance.bOutputExecParameters = true;
                    //reportinstance.OutputExecParameters = WriteExecParamsToReportEnum.Yes;
                  }

                  if (rdr.GetString(17) == "No")
                  {
                    reportinstance.bUseQuotedIdentifiers = false;
                    //reportinstance.UseQuotedIdentifiers = UseQuotedIdentifiersEnum.No;

                  }
                  else
                  {
                    reportinstance.bUseQuotedIdentifiers = true;
                    //reportinstance.UseQuotedIdentifiers = UseQuotedIdentifiersEnum.Yes;
                  }

                  reportinstance.LastRunDate = rdr.GetDateTime(18);

                  reportinstance.NextRunDate = rdr.IsDBNull(19) ? DateTime.Now : rdr.GetDateTime(19);

                  reportinstance.OutputFileName = rdr.IsDBNull(20) ? String.Empty : rdr.GetString(20);

                  exportReportInstance.Items.Add(reportinstance);

                }

              }

              exportReportInstance.TotalRows = stmt.TotalRows;

              mLogger.LogDebug("There are {0}  items in the report instance list", exportReportInstance.Items.Count.ToString());

            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Report Instances Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Report Instances Info Failed....", e);

          throw new MASBasicException("Get Report Instances Info Failed..");
        }
      }
    }



    //Get Details of a Report Instance Parameter Values  

    public void GetInstanceParameterValues(int IDReportInstance, ref MTList<ExportReportInstance> exportReportInstanceParamValues)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetInstanceParameterValues"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_REPORTINSTANCE_DEFAULT_PARAMETER_VALUES__"))
            {
              ApplyFilterSortCriteria<ExportReportInstance>(stmt, exportReportInstanceParamValues);

              stmt.AddParam("%%ID_REP_INSTANCE_ID%%", IDReportInstance);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {

                  ExportReportInstance reportinstanceparametervalues = new ExportReportInstance();

                  reportinstanceparametervalues.IDParameterInstance = rdr.GetInt32(0);
                  reportinstanceparametervalues.ParameterNameInstance = rdr.GetString(1);
                  reportinstanceparametervalues.ParameterDescriptionInstance = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);
                  reportinstanceparametervalues.ParameterValueInstance = rdr.GetString(3);
                  reportinstanceparametervalues.IDParameterValueInstance = rdr.GetInt32(4);

                  exportReportInstanceParamValues.Items.Add(reportinstanceparametervalues);
                }

              }

              exportReportInstanceParamValues.TotalRows = stmt.TotalRows;
            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Report Instances Parameter Value Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Report Instances Parameter Value  Info Failed....", e);

          throw new MASBasicException("Get Report Instances Parameter Value Info Failed..");
        }
      }
    }


    public void GetAReportInstance(int IDReportInstance, out ExportReportInstance reportinstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAReportInstance"))
      {
        try
        {
          MTList<ExportReportInstance> eri = new MTList<ExportReportInstance>();

          GetAReportInstanceDetails(IDReportInstance, ref eri);

          reportinstance = eri.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving report instance..", e);
          throw new MASBasicException("Error retrieving report instance..");
        }
      }
    }


    public void GetAReportDef(int IDReport, out ExportReportDefinition reportdef)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAReportDef"))
      {
        try
        {
          MTList<ExportReportDefinition> erd = new MTList<ExportReportDefinition>();

          GetReportDefinitionInfo(IDReport, ref erd);

          reportdef = erd.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving report definition..", e);
          throw new MASBasicException("Error retrieving report definition..");
        }
      }
    }


    //Report Instance Schedules Management Section     

    //Get Details of a Daily Report Instance Schedule   
    public void GetADailyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetADailyScheduleDetails"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_SCHEDULE_INFO_DAILY__"))
            {

              stmt.AddParam("%%ID_RP_SCHEDULE%%", IDReportSchedule);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {

                  ExportReportSchedule dailyreportschedule = new ExportReportSchedule();

                  dailyreportschedule.IDSchedule = rdr.GetInt32(0);
                  dailyreportschedule.ExecuteTime = rdr.GetString(1);
                  dailyreportschedule.RepeatHour = rdr.GetInt32(2);
                  dailyreportschedule.ExecuteStartTime = rdr.IsDBNull(3) ? String.Empty : rdr.GetString(3);
                  dailyreportschedule.ExecuteEndTime = rdr.IsDBNull(4) ? String.Empty : rdr.GetString(4);

                  //Skip Last Day Of Month True/False
                  if (rdr.GetString(5) == "No")
                  {
                    dailyreportschedule.bSkipLastDayMonth = false;
                    //dailyreportschedule.SkipLastDayMonth = SkipLastDayOfMonthEnum.No;
                  }
                  else
                  {
                    dailyreportschedule.bSkipLastDayMonth = true;
                    //dailyreportschedule.SkipLastDayMonth = SkipLastDayOfMonthEnum.Yes;
                  }

                  //Skip First Day Of Month True/False
                  if (rdr.GetString(6) == "No")
                  {
                    dailyreportschedule.bSkipFirstDayMonth = false;
                    //dailyreportschedule.SkipFirstDayMonth = SkipFirstDayOfMonthEnum.No;
                  }
                  else
                  {
                    dailyreportschedule.bSkipFirstDayMonth = true;
                    //dailyreportschedule.SkipFirstDayMonth = SkipFirstDayOfMonthEnum.Yes;
                  }

                  dailyreportschedule.DaysInterval = rdr.GetInt32(7);

                  //Month To Date True/False
                  if (rdr.GetString(8) == "No")
                  {
                    dailyreportschedule.bMonthToDate = false;
                    //dailyreportschedule.MonthToDate = MonthToDateEnum.No;
                  }
                  else
                  {
                    dailyreportschedule.bMonthToDate = true;
                    //dailyreportschedule.MonthToDate = MonthToDateEnum.Yes;
                  }

                  exportReportSchedule.Items.Add(dailyreportschedule);

                }

              }

              exportReportSchedule.TotalRows = stmt.TotalRows;


            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Daily Schedule Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Daily Schedule Info Failed..", e);

          throw new MASBasicException("Get Daily Schedule Info Failed..");
        }
      }
    }



    public void GetAScheduleInfoDaily(int IDReportSchedule, out ExportReportSchedule dailyreportschedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAScheduleInfoDaily"))
      {
        try
        {
          MTList<ExportReportSchedule> drs = new MTList<ExportReportSchedule>();

          GetADailyScheduleDetails(IDReportSchedule, ref drs);

          dailyreportschedule = drs.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving report schedule..", e);
          throw new MASBasicException("Error retrieving report schedule..");
        }
      }
    }


    //Get Details of a Weekly Report Instance Schedule   
    public void GetAWeeklyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAWeeklyScheduleDetails"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_SCHEDULE_INFO_WEEKLY__"))
            {

              stmt.AddParam("%%ID_RP_SCHEDULE%%", IDReportSchedule);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {
                  ExportReportSchedule weeklyreportschedule = new ExportReportSchedule();

                  weeklyreportschedule.IDSchedule = rdr.GetInt32(0);
                  weeklyreportschedule.ExecuteTime = rdr.GetString(1);

                  weeklyreportschedule.ExecuteWeekDays = rdr.GetString(2);
                  //We need to parse strexecuteweekdays here and set the individual executeday flag true/false
                  var strexecuteweekdays = weeklyreportschedule.ExecuteWeekDays;

                  //weeklyreportschedule.SkipWeekDays = rdr.GetString(3);
                  //We need to parse strskipweekdays here and set the individual executeday flag true/false
                  //I am parsing it on the db side..

                  if (rdr.GetString(3) == "Yes")
                  {
                    weeklyreportschedule.bSkipSunday = true;
                    //weeklyreportschedule.SkipSunday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipSunday = false;
                    //weeklyreportschedule.SkipSunday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(4) == "Yes")
                  {
                    weeklyreportschedule.bSkipMonday = true;
                    //weeklyreportschedule.SkipMonday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipMonday = false;
                    //weeklyreportschedule.SkipMonday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(5) == "Yes")
                  {
                    weeklyreportschedule.bSkipTuesday = true;
                    //weeklyreportschedule.SkipTuesday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipTuesday = false;
                    //weeklyreportschedule.SkipTuesday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(6) == "Yes")
                  {
                    weeklyreportschedule.bSkipWednesday = true;
                    //weeklyreportschedule.SkipWednesday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipWednesday = false;
                    //weeklyreportschedule.SkipWednesday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(7) == "Yes")
                  {
                    weeklyreportschedule.bSkipThursday = true;
                    //weeklyreportschedule.SkipThursday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipThursday = false;
                    //weeklyreportschedule.SkipThursday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(8) == "Yes")
                  {
                    weeklyreportschedule.bSkipFriday = true;
                    //weeklyreportschedule.SkipFriday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipFriday = false;
                    //weeklyreportschedule.SkipFriday = SkipThisDayEnum.No;
                  }

                  if (rdr.GetString(9) == "Yes")
                  {
                    weeklyreportschedule.bSkipSaturday = true;
                    //weeklyreportschedule.SkipSaturday = SkipThisDayEnum.Yes;

                  }
                  else
                  {
                    weeklyreportschedule.bSkipSaturday = false;
                    //weeklyreportschedule.SkipSaturday = SkipThisDayEnum.No;
                  }

                  //Month To Date True/False
                  if (rdr.GetString(10) == "No")
                  {
                    weeklyreportschedule.bMonthToDate = false;
                    //weeklyreportschedule.MonthToDate = MonthToDateEnum.No;

                  }
                  else
                  {
                    weeklyreportschedule.bMonthToDate = true;
                    //weeklyreportschedule.MonthToDate = MonthToDateEnum.No;
                  }

                  exportReportSchedule.Items.Add(weeklyreportschedule);

                }

              }

              exportReportSchedule.TotalRows = stmt.TotalRows;

              mLogger.LogDebug("There are {0}  items in the report instance schedule list", exportReportSchedule.Items.Count.ToString());

            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Weekly Schedule Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Weekly Schedule Info Failed..", e);

          throw new MASBasicException("Get Weekly Schedule Info Failed..");
        }
      }
    }


    public void GetAScheduleInfoWeekly(int IDReportSchedule, out ExportReportSchedule weeklyreportschedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAScheduleInfoWeekly"))
      {
        try
        {
          MTList<ExportReportSchedule> wrs = new MTList<ExportReportSchedule>();

          GetAWeeklyScheduleDetails(IDReportSchedule, ref wrs);

          weeklyreportschedule = wrs.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving weekly report schedule..", e);
          throw new MASBasicException("Error retrieving weekly report schedule..");
        }
      }
    }


    //Get Details of a Monthly Report Instance Schedule   
    public void GetAMonthlyScheduleDetails(int IDReportSchedule, ref MTList<ExportReportSchedule> exportReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAMonthlyScheduleDetails"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_GET_SCHEDULE_INFO_MONTHLY__"))
            {

              stmt.AddParam("%%ID_RP_SCHEDULE%%", IDReportSchedule);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {
                  ExportReportSchedule monthlyreportschedule = new ExportReportSchedule();


                  monthlyreportschedule.IDSchedule = rdr.GetInt32(0);
                  monthlyreportschedule.ExecuteDay = rdr.GetInt32(1);
                  monthlyreportschedule.ExecuteTime = rdr.GetString(2);
                  //Execute First Day of Month True/False
                  if (rdr.GetString(3) == "No")
                  {
                    monthlyreportschedule.bExecuteFirstDayMonth = false;
                    //monthlyreportschedule.ExecuteFirstDayMonth = ExecuteFirstDayOfMonthEnum.No;
                  }
                  else
                  {
                    monthlyreportschedule.bExecuteFirstDayMonth = true;
                    //monthlyreportschedule.ExecuteFirstDayMonth = ExecuteFirstDayOfMonthEnum.Yes;
                  }

                  //Skip First Day Of Month True/False
                  if (rdr.GetString(4) == "No")
                  {
                    monthlyreportschedule.bExecuteLastDayMonth = false;
                    //monthlyreportschedule.ExecuteLastDayMonth = ExecuteLastDayOfMonthEnum.No;
                  }
                  else
                  {
                    monthlyreportschedule.bExecuteLastDayMonth = true;
                    //monthlyreportschedule.ExecuteLastDayMonth = ExecuteLastDayOfMonthEnum.Yes;
                  }


                  //Parse skip months string but on the db side..
                  if (rdr.GetString(5) == "Yes")
                  {
                    monthlyreportschedule.bSkipJanuary = true;
                    //monthlyreportschedule.SkipJanuary = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipJanuary = false;
                    //monthlyreportschedule.SkipJanuary = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(6) == "Yes")
                  {
                    monthlyreportschedule.bSkipFebruary = true;
                    //monthlyreportschedule.SkipFebruary = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipFebruary = false;
                    //monthlyreportschedule.SkipFebruary = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(7) == "Yes")
                  {
                    monthlyreportschedule.bSkipMarch = true;
                    //monthlyreportschedule.SkipMarch = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipMarch = false;
                    //monthlyreportschedule.SkipMarch = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(8) == "Yes")
                  {
                    monthlyreportschedule.bSkipApril = true;
                    //monthlyreportschedule.SkipApril = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipApril = false;
                    //monthlyreportschedule.SkipApril = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(9) == "Yes")
                  {
                    monthlyreportschedule.bSkipMay = true;
                    //monthlyreportschedule.SkipMay = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipMay = false;
                    //monthlyreportschedule.SkipMay = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(10) == "Yes")
                  {
                    monthlyreportschedule.bSkipJune = true;
                    //monthlyreportschedule.SkipJune = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipJune = false;
                    //monthlyreportschedule.SkipJune = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(11) == "Yes")
                  {
                    monthlyreportschedule.bSkipJuly = true;
                    //monthlyreportschedule.SkipJuly = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipJuly = false;
                    //monthlyreportschedule.SkipJuly = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(12) == "Yes")
                  {
                    monthlyreportschedule.bSkipAugust = true;
                    //monthlyreportschedule.SkipAugust = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipAugust = false;
                    //monthlyreportschedule.SkipAugust = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(13) == "Yes")
                  {
                    monthlyreportschedule.bSkipSeptember = true;
                    //monthlyreportschedule.SkipSeptember = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipSeptember = false;
                    //monthlyreportschedule.SkipSeptember = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(14) == "Yes")
                  {
                    monthlyreportschedule.bSkipOctober = true;
                    //monthlyreportschedule.SkipOctober = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipOctober = false;
                    //monthlyreportschedule.SkipOctober = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(15) == "Yes")
                  {
                    monthlyreportschedule.bSkipNovember = true;
                    // monthlyreportschedule.SkipNovember = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipNovember = false;
                    //monthlyreportschedule.SkipNovember = SkipThisMonthEnum.No;
                  }

                  if (rdr.GetString(16) == "Yes")
                  {
                    monthlyreportschedule.bSkipDecember = true;
                    //monthlyreportschedule.SkipDecember = SkipThisMonthEnum.Yes;
                  }
                  else
                  {
                    monthlyreportschedule.bSkipDecember = false;
                    //monthlyreportschedule.SkipDecember = SkipThisMonthEnum.No;
                  }

                  exportReportSchedule.Items.Add(monthlyreportschedule);

                }

              }

              exportReportSchedule.TotalRows = stmt.TotalRows;

              mLogger.LogDebug("There are {0}  items in the report instance schedule list", exportReportSchedule.Items.Count.ToString());

            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Monthly Schedule Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Monthly Schedule Info Failed..", e);

          throw new MASBasicException("Get Monthly Schedule Info Failed..");
        }
      }
    }


    public void GetAScheduleInfoMonthly(int IDReportSchedule, out ExportReportSchedule monthlyreportschedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAScheduleInfoMonthly"))
      {
        try
        {
          MTList<ExportReportSchedule> mrs = new MTList<ExportReportSchedule>();

          GetAMonthlyScheduleDetails(IDReportSchedule, ref mrs);

          monthlyreportschedule = mrs.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving monthly report schedule..", e);
          throw new MASBasicException("Error retrieving monthly report schedule..");
        }
      }
    }


    public void CheckIfScheduleExists(int IDReportInstance, out ExportReportSchedule whetherscheduleexists)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CheckIfScheduleExists"))
      {
        try
        {
          MTList<ExportReportSchedule> cise = new MTList<ExportReportSchedule>();

          IsExistingSchedule(IDReportInstance, ref cise);

          whetherscheduleexists = cise.Items[0];
        }
        catch (Exception e)
        {
          mLogger.LogException("Error retrieving monthly report schedule..", e);
          throw new MASBasicException("Error retrieving monthly report schedule..");
        }
      }
    }



    public void IsExistingSchedule(int IDReportInstance, ref MTList<ExportReportSchedule> exportReportSchedule)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("IsExistingSchedule"))
      {

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__EXPORT_CHECK_IF_SCHEDULE_EXISTS_FOR_AN_INSTANCE__"))
            {

              stmt.AddParam("%%ID_REPORT_INSTANCE%%", IDReportInstance);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {

                  ExportReportSchedule checkifscheduleexists = new ExportReportSchedule();

                  checkifscheduleexists.IDSchedule = rdr.GetInt32(0);

                  exportReportSchedule.Items.Add(checkifscheduleexists);

                }

              }

              exportReportSchedule.TotalRows = stmt.TotalRows;

            }

          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Daily Schedule Info Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Daily Schedule Info Failed..", e);

          throw new MASBasicException("Get Daily Schedule Info Failed..");
        }
      }
    }





    public void UpdateReportInstanceScheduleDaily(int IDReportInstance, int IDSchedule, string ExecuteTime, int RepeatHour, string ExecuteStartTime, string ExecuteEndTime,
       int SkipLastDayOfMonth, int SkipFirstDayOfMonth, int DaysInterval, int MonthToDate)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateReportInstanceScheduleDaily"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateInstanceSchedDly"))
            {
              callStmt.AddParam("id_report_instance", MTParameterType.Integer, IDReportInstance);
              callStmt.AddParam("id_schedule_daily", MTParameterType.Integer, IDSchedule);
              callStmt.AddParam("c_exec_time", MTParameterType.String, ExecuteTime);
              callStmt.AddParam("c_repeat_hour", MTParameterType.Integer, RepeatHour);
              callStmt.AddParam("c_exec_start_time", MTParameterType.String, ExecuteStartTime);
              callStmt.AddParam("c_exec_end_time", MTParameterType.String, ExecuteEndTime);
              callStmt.AddParam("c_skip_last_day_month", MTParameterType.Integer, SkipLastDayOfMonth);//BIT
              callStmt.AddParam("c_skip_first_day_month", MTParameterType.Integer, SkipFirstDayOfMonth);//BIT
              callStmt.AddParam("c_days_interval", MTParameterType.Integer, DaysInterval);
              callStmt.AddParam("c_month_to_date", MTParameterType.Integer, MonthToDate);
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());

              mLogger.LogInfo("Executing export_UpdateReportInstanceSchedule_Daily..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Updating Existing Report Instance Daily Schedule Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Updating Existing Report Instance Daily Schedule Failed", e);
          throw new MASBasicException("Updating Existing Report Instance Daily Schedule Failed");
        }
      }
    }


    public void UpdateReportInstanceScheduleWeekly(int IDReportInstance, int IDSchedule, string ExecuteTime, string ExecuteWeekDays, string SkipWeekDays, int MonthToDate)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateReportInstanceScheduleWeekly"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateInstancSchedWkly"))
            {
              callStmt.AddParam("id_report_instance", MTParameterType.Integer, IDReportInstance);
              callStmt.AddParam("id_schedule_weekly", MTParameterType.Integer, IDSchedule);
              callStmt.AddParam("c_exec_time", MTParameterType.String, ExecuteTime);
              callStmt.AddParam("c_exec_week_days", MTParameterType.String, ExecuteWeekDays);
              callStmt.AddParam("c_skip_week_days", MTParameterType.String, SkipWeekDays);
              callStmt.AddParam("c_month_to_date", MTParameterType.Integer, MonthToDate);
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());

              mLogger.LogInfo("Executing Export_UpdateInstancSchedWkly..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Updating Existing Report Instance Weekly Schedule Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Updating Existing Report Instance Weekly Schedule Failed", e);
          throw new MASBasicException("Updating Existing Report Instance Weekly Schedule Failed");
        }
      }
    }


    public void UpdateReportInstanceScheduleMonthly(int IDReportInstance, int IDSchedule, int ExecuteDay, string ExecuteTime, int ExecuteFirstDayOfMonth, int ExecuteLastDayOfMonth,
    string SkipMonths)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateReportInstanceScheduleMonthly"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateInstancSchedMonly"))
            {
              callStmt.AddParam("id_report_instance", MTParameterType.Integer, IDReportInstance);
              callStmt.AddParam("id_schedule_monthly", MTParameterType.Integer, IDSchedule);
              callStmt.AddParam("c_exec_day", MTParameterType.Integer, ExecuteDay);
              callStmt.AddParam("c_exec_time", MTParameterType.String, ExecuteTime);
              callStmt.AddParam("c_exec_first_month_day", MTParameterType.Integer, ExecuteFirstDayOfMonth);//BIT
              callStmt.AddParam("c_exec_last_month_day", MTParameterType.Integer, ExecuteLastDayOfMonth);//BIT
              callStmt.AddParam("c_skip_months", MTParameterType.String, SkipMonths);
              callStmt.AddParam("system_datetime", MTParameterType.DateTime, MetraTime.Now.ToLocalTime());

              mLogger.LogInfo("Executing export_UpdateReportInstanceSchedule_Monthly..");
              callStmt.ExecuteNonQuery();
            }
          }
        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Updating Existing Report Instance Monthly Schedule Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Updating Existing Report Instance Monthly Schedule Failed", e);
          throw new MASBasicException("Updating Existing Report Instance Monthly Schedule Failed");
        }
      }
    }


    public void UpdateReportInstanceParameterValue(int IDParameterValueInstance, string ParameterValueInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("UpdateReportInstanceParameterValue"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTCallableStatement callStmt = conn.CreateCallableStatement("Export_UpdateReportInstancePar"))
            {
              callStmt.AddParam("id_parameter_value", MTParameterType.Integer, IDParameterValueInstance);
              callStmt.AddParam("parameter_value", MTParameterType.String, ParameterValueInstance);

              mLogger.LogInfo("Executing Export_UpdateReportInstancePar..");
              callStmt.ExecuteNonQuery();
            }
          }
        }
        catch (MASBasicException masE)
        {
          mLogger.LogException("Updating Existing Report Instance Parameter Value Failed", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Updating Existing Report Instance  Parameter Value  Failed", e);
          throw new MASBasicException("Updating Existing Report Instance  Parameter Value  Failed");
        }
      }
    }

    public void GetExportLogDashboard(ref MTList<ExportReportInstance> getExportLogDashboard)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetExportLogDashboard"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_EXPORT_LOG_DASHBOARD__"))
            {
              ApplyFilterSortCriteria<ExportReportInstance>(stmt, getExportLogDashboard);

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {
                  ExportReportInstance getexportlogdashboard = new ExportReportInstance();

                  getexportlogdashboard.AuditID = rdr.GetInt32(0);
                  getexportlogdashboard.ReportTitle = rdr.GetString(1);
                  getexportlogdashboard.ReportExecutionTypeText = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);
                  getexportlogdashboard.ReportOutputTypeText = rdr.IsDBNull(3) ? String.Empty : rdr.GetString(3);
                  getexportlogdashboard.OutputFileName = rdr.IsDBNull(4) ? String.Empty : rdr.GetString(4);
                  getexportlogdashboard.ReportDestination = rdr.IsDBNull(5) ? String.Empty : rdr.GetString(5);
                  getexportlogdashboard.ReportDistributionTypeText = rdr.IsDBNull(6) ? String.Empty : rdr.GetString(6);
                  getexportlogdashboard.LastRunDate = rdr.GetDateTime(7);
                  getexportlogdashboard.NextRunDate = rdr.IsDBNull(8) ? DateTime.Now : rdr.GetDateTime(8);
                  getexportlogdashboard.InstanceRunResult = rdr.GetString(9);
                  getexportlogdashboard.IDReport = rdr.GetInt32(10);

                  getExportLogDashboard.Items.Add(getexportlogdashboard);

                }

              }

              getExportLogDashboard.TotalRows = stmt.TotalRows;


            }
          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Export Dashboard Details Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Export Dashboard Details Failed..", e);

          throw new MASBasicException("Get Export Dashboard Details Failed..");
        }
      }
    }

    public void GetExportQueueDashboard(ref MTList<ExportReportInstance> getExportQueueDashboard)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetExportQueueDashboard"))
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(DATAEXPORTMANAGEMENT_QUERY_FOLDER))
          {

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(DATAEXPORTMANAGEMENT_QUERY_FOLDER, "__GET_EXPORT_QUEUE_DASHBOARD__"))
            {
              ApplyFilterSortCriteria<ExportReportInstance>(stmt, getExportQueueDashboard);


              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                while (rdr.Read())
                {
                  ExportReportInstance getexportqueuedashboard = new ExportReportInstance();

                  getexportqueuedashboard.WorkQueueID = rdr.GetGuid(0);
                  getexportqueuedashboard.ReportTitle = rdr.GetString(1);
                  getexportqueuedashboard.ReportExecutionTypeText = rdr.IsDBNull(2) ? String.Empty : rdr.GetString(2);
                  getexportqueuedashboard.ReportOutputTypeText = rdr.IsDBNull(3) ? String.Empty : rdr.GetString(3);
                  getexportqueuedashboard.OutputFileName = rdr.IsDBNull(4) ? String.Empty : rdr.GetString(4);
                  getexportqueuedashboard.ReportDestination = rdr.IsDBNull(5) ? String.Empty : rdr.GetString(5);
                  getexportqueuedashboard.ReportDistributionTypeText = rdr.IsDBNull(6) ? String.Empty : rdr.GetString(6);
                  getexportqueuedashboard.LastRunDate = rdr.GetDateTime(7);
                  getexportqueuedashboard.NextRunDate = rdr.IsDBNull(8) ? DateTime.Now : rdr.GetDateTime(8);
                  getexportqueuedashboard.InstanceRunResult = rdr.IsDBNull(9) ? String.Empty : rdr.GetString(9);
                  getexportqueuedashboard.IDReport = rdr.GetInt32(10);
                  getexportqueuedashboard.intWorkQueueID = rdr.GetInt32(11);

                  getExportQueueDashboard.Items.Add(getexportqueuedashboard);

                }

              }

              getExportQueueDashboard.TotalRows = stmt.TotalRows;


            }
          }

        }

        catch (MASBasicException masE)
        {
          mLogger.LogException("Get Export Dashboard Details Failed..", masE);
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Get Export Dashboard Details Failed..", e);

          throw new MASBasicException("Get Export Dashboard Details Failed..");
        }
      }
    }

    #endregion
  
public  CreateConnectionFromPathDelegate createConnFromPathDelegate { get; set; }}
}
