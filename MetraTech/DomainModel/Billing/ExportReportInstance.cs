using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
  public class ExportReportInstance : BaseObject
  {
    #region IDReportInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isIDReportInstanceDirty = false;
    private int m_IDReportInstance;
    [MTDataMember(Description = "This the Report Instance ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDReportInstance
    {
      get { return m_IDReportInstance; }
      set
      {
        m_IDReportInstance = value;
        isIDReportInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDReportInstanceDirty
    {
      get { return isIDReportInstanceDirty; }
    }
    #endregion

    #region IDReport
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDReportDirty = false;
    private int m_IDReport;
    [MTDataMember(Description = "This the Report ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDReport
    {
      get { return m_IDReport; }
      set
      {
        m_IDReport = value;
        isIDReportDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDReportDirty
    {
      get { return isIDReportDirty; }
    }
    #endregion

    #region AuditID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAuditIDDirty = false;
    private int m_AuditID;
    [MTDataMember(Description = "This the Report ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AuditID
    {
      get { return m_AuditID; }
      set
      {
        m_AuditID = value;
        isAuditIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAuditIDDirty
    {
      get { return isAuditIDDirty; }
    }
    #endregion

    #region WorkQueueID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isWorkQueueIDDirty = false;
    private Guid  m_WorkQueueID;
    [MTDataMember(Description = "This the Report ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid WorkQueueID
    {
      get { return m_WorkQueueID; }
      set
      {
        m_WorkQueueID = value;
        isWorkQueueIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsWorkQueueIDDirty
    {
      get { return isWorkQueueIDDirty; }
    }
    #endregion

    #region intWorkQueueID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isintWorkQueueIDDirty = false;
    private int m_intWorkQueueID;
    [MTDataMember(Description = "This the Report ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int intWorkQueueID
    {
      get { return m_intWorkQueueID; }
      set
      {
        m_intWorkQueueID = value;
        isintWorkQueueIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsintWorkQueueIDDirty
    {
      get { return isintWorkQueueIDDirty; }
    }
    #endregion


      #region ReportTitle
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportTitleDirty = false;
    private string m_ReportTitle;
    [MTDataMember(Description = "This the Report Title..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportTitle
    {
      get { return m_ReportTitle; }
      set
      {
        m_ReportTitle = value;
        isReportTitleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportTitleDirty
    {
      get { return isReportTitleDirty; }
    }
    #endregion

      
      #region OnlineReport
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOnlineReportDirty = false;
    private ShowReportOnlineEnum m_OnlineReport;
    [MTDataMember(Description = "Whether Online Report is required..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ShowReportOnlineEnum OnlineReport
    {
      get { return m_OnlineReport; }
      set
      {
        m_OnlineReport = value;
        isOnlineReportDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsOnlineReportDirty
    {
      get { return isOnlineReportDirty; }
    }
    #endregion

    #region InstanceActivationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInstanceActivationDateDirty = false;
    private DateTime m_InstanceActivationDate;
    [MTDataMember(Description = "This the Report Instance Activation Date..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime InstanceActivationDate
    {
      get { return m_InstanceActivationDate; }
      set
      {
        m_InstanceActivationDate = value;
        isInstanceActivationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsInstanceActivationDateDirty
    {
      get { return isInstanceActivationDateDirty; }
    }
    #endregion

 
      #region InstanceDeactivationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInstanceDeactivationDateDirty = false;
    private DateTime m_InstanceDeactivationDate;
    [MTDataMember(Description = "This the Report Instance Deactivation Date..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime InstanceDeactivationDate
    {
      get { return m_InstanceDeactivationDate; }
      set
      {
        m_InstanceDeactivationDate = value;
        isInstanceDeactivationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsInstanceDeactivationDateDirty
    {
      get { return isInstanceDeactivationDateDirty; }
    }
    #endregion

    #region InstanceQueueDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInstanceQueueDateDirty = false;
    private DateTime m_InstanceQueueDate;
    [MTDataMember(Description = "This the Report Instance Activation Date..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime InstanceQueueDate
    {
      get { return m_InstanceQueueDate; }
      set
      {
        m_InstanceQueueDate = value;
        isInstanceQueueDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsInstanceQueueDateDirty
    {
      get { return isInstanceQueueDateDirty; }
    }
    #endregion

      
      #region ReportOutputType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportOutputTypeDirty = false;
    private ReportOutputTypeEnum m_ReportOutputType;
    [MTDataMember(Description = "This is the Report Output Type like CSV, TXT, XML etc", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]

    public ReportOutputTypeEnum ReportOutputType
    {
      get { return m_ReportOutputType; }
      set
      {
        m_ReportOutputType = value;
        isReportOutputTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportOutputTypeDirty
    {
      get { return isReportOutputTypeDirty; }
    }
    #endregion

    #region ReportOutputTypeText
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportOutputTypeTextDirty = false;
    private string m_ReportOutputTypeText;
    [MTDataMember(Description = "This is the Report Output Type like CSV, TXT, XML etc", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]

    public string ReportOutputTypeText
    {
      get { return m_ReportOutputTypeText; }
      set
      {
        m_ReportOutputTypeText = value;
        isReportOutputTypeTextDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportOutputTypeTextDirty
    {
      get { return isReportOutputTypeTextDirty; }
    }
    #endregion
      
    #region XMLConfigLocation
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isXMLConfigLocationDirty = false;
    private string m_XMLConfigLocation;
    [MTDataMember(Description = "This the Report XML Config Location..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string XMLConfigLocation
    {
      get { return m_XMLConfigLocation; }
      set
      {
        m_XMLConfigLocation = value;
        isXMLConfigLocationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsXMLConfigLocationDirty
    {
      get { return isXMLConfigLocationDirty; }
    }
    #endregion

    #region ReportDistributionType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportDistributionTypeDirty = false;
    private ReportDeliveryTypeEnum m_ReportDistributionType;
    [MTDataMember(Description = "This is the Report Distribution Type like Disk, FTP etc", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]

    public ReportDeliveryTypeEnum ReportDistributionType
    {
      get { return m_ReportDistributionType; }
      set
      {
        m_ReportDistributionType = value;
        isReportDistributionTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportDistributionTypeDirty
    {
      get { return isReportDistributionTypeDirty; }
    }
    #endregion

    #region ReportDistributionTypeText
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportDistributionTypeTextDirty = false;
    private string m_ReportDistributionTypeText;
    [MTDataMember(Description = "This is the Report Distribution Type like Disk, FTP etc", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]

    public string ReportDistributionTypeText
    {
      get { return m_ReportDistributionTypeText; }
      set
      {
        m_ReportDistributionTypeText = value;
        isReportDistributionTypeTextDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportDistributionTypeTextDirty
    {
      get { return isReportDistributionTypeTextDirty; }
    }
    #endregion

      
      #region ReportInstanceDescription
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportInstanceDescriptionDirty = false;
    private string m_ReportInstanceDescription;
    [MTDataMember(Description = "This the Report Instance Description..", Length = 100)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportInstanceDescription
    {
      get { return m_ReportInstanceDescription; }
      set
      {
        m_ReportInstanceDescription = value;
        isReportInstanceDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportInstanceDescriptionDirty
    {
      get { return isReportInstanceDescriptionDirty; }
    }
    #endregion

    #region InstanceRunResult
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isInstanceRunResultDirty = false;
    private string m_InstanceRunResult;
    [MTDataMember(Description = "This the Report Instance Description..", Length = 100)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string InstanceRunResult
    {
      get { return m_InstanceRunResult; }
      set
      {
        m_InstanceRunResult = value;
        isInstanceRunResultDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsInstanceRunResultDirty
    {
      get { return isInstanceRunResultDirty; }
    }
    #endregion

      
      #region ReportDestination
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportDestinationDirty = false;
    private string m_ReportDestination;
    [MTDataMember(Description = "This the Report Destination ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportDestination
    {
      get { return m_ReportDestination; }
      set
      {
        m_ReportDestination = value;
        isReportDestinationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportDestinationDirty
    {
      get { return isReportDestinationDirty; }
    }
    #endregion

    #region FTPAccessUser
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFTPAccessUserDirty = false;
    private string m_FTPAccessUser;
    [MTDataMember(Description = "This the FTP Access User ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FTPAccessUser
    {
      get { return m_FTPAccessUser; }
      set
      {
        m_FTPAccessUser = value;
        isFTPAccessUserDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFTPAccessUserDirty
    {
      get { return isFTPAccessUserDirty; }
    }
    #endregion

    #region FTPAccessPassword
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFTPAccessPasswordDirty = false;
    private string m_FTPAccessPassword;
    [MTDataMember(Description = "This the FTP Access Password ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FTPAccessPassword
    {
      get { return m_FTPAccessPassword; }
      set
      {
        m_FTPAccessPassword = value;
        isFTPAccessPasswordDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFTPAccessPasswordDirty
    {
      get { return isFTPAccessPasswordDirty; }
    }
    #endregion

    #region ReportExecutionType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportExecutionTypeDirty = false;
    private ReportExecutionTypeEnum m_ReportExecutionType;
    [MTDataMember(Description = "This the ExecutionType..", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ReportExecutionTypeEnum ReportExecutionType
    {
      get { return m_ReportExecutionType; }
      set
      {
        m_ReportExecutionType = value;
        isReportExecutionTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportExecutionTypeDirty
    {
      get { return isReportExecutionTypeDirty; }
    }
    #endregion

    #region ReportExecutionTypeText
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportExecutionTypeTextDirty = false;
    private string m_ReportExecutionTypeText;
    [MTDataMember(Description = "This the ExecutionType..", Length = 10)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportExecutionTypeText
    {
      get { return m_ReportExecutionTypeText; }
      set
      {
        m_ReportExecutionTypeText = value;
        isReportExecutionTypeTextDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsReportExecutionTypeTextDirty
    {
      get { return isReportExecutionTypeTextDirty; }
    }
    #endregion

      
      #region GenerateControlFile
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGenerateControlFileDirty = false;
    private GenerateControlFileEnum m_GenerateControlFile;
    [MTDataMember(Description = "Where Generate Control File ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public GenerateControlFileEnum GenerateControlFile
    {
      get { return m_GenerateControlFile; }
      set
      {
        m_GenerateControlFile = value;
        isGenerateControlFileDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsGenerateControlFileDirty
    {
      get { return isGenerateControlFileDirty; }
    }
    #endregion

    #region bGenerateControlFile
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbGenerateControlFileDirty = false;
    private bool m_bGenerateControlFile;
    [MTDataMember(Description = "Where Generate Control File ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bGenerateControlFile
    {
      get { return m_bGenerateControlFile; }
      set
      {
        m_bGenerateControlFile = value;
        isbGenerateControlFileDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbGenerateControlFileDirty
    {
      get { return isbGenerateControlFileDirty; }
    }
    #endregion

      
      
      #region ControlFileDeliveryLocation
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isControlFileDeliveryLocationDirty = false;
    private string m_ControlFileDeliveryLocation;
    [MTDataMember(Description = "Control File Delivery Location ..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ControlFileDeliveryLocation
    {
      get { return m_ControlFileDeliveryLocation; }
      set
      {
        m_ControlFileDeliveryLocation = value;
        isControlFileDeliveryLocationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsControlFileDeliveryLocationDirty
    {
      get { return isControlFileDeliveryLocationDirty; }
    }
    #endregion

    #region CompressReport
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompressReportDirty = false;
    private CompressReportEnum m_CompressReport;
    [MTDataMember(Description = "Whether to Compress Report..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public CompressReportEnum CompressReport
    {
      get { return m_CompressReport; }
      set
      {
        m_CompressReport = value;
        isCompressReportDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompressReportDirty
    {
      get { return isCompressReportDirty; }
    }
    #endregion

    #region bCompressReport
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbCompressReportDirty = false;
    private bool m_bCompressReport;
    [MTDataMember(Description = "Whether to Compress Report..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bCompressReport
    {
      get { return m_bCompressReport; }
      set
      {
        m_bCompressReport = value;
        isbCompressReportDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbCompressReportDirty
    {
      get { return isbCompressReportDirty; }
    }
    #endregion

      
      #region CompressThreshold
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCompressThresholdDirty = false;
    private int m_CompressThreshold;
    [MTDataMember(Description = "Compress Threshold..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int CompressThreshold
    {
      get { return m_CompressThreshold; }
      set
      {
        m_CompressThreshold = value;
        isCompressThresholdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCompressThresholdDirty
    {
      get { return isCompressThresholdDirty; }
    }
    #endregion

    #region OutputExecParameters
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOutputExecParametersDirty = false;
    private WriteExecParamsToReportEnum m_OutputExecParameters;
    [MTDataMember(Description = "Whether to output  Exec Parameters to report..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public WriteExecParamsToReportEnum OutputExecParameters
    {
      get { return m_OutputExecParameters; }
      set
      {
        m_OutputExecParameters = value;
        isOutputExecParametersDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsOutputExecParametersDirty
    {
      get { return isOutputExecParametersDirty; }
    }
    #endregion

    #region bOutputExecParameters
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbOutputExecParametersDirty = false;
    private bool m_bOutputExecParameters;
    [MTDataMember(Description = "Whether to output  Exec Parameters to report..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bOutputExecParameters
    {
      get { return m_bOutputExecParameters; }
      set
      {
        m_bOutputExecParameters = value;
        isbOutputExecParametersDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbOutputExecParametersDirty
    {
      get { return isbOutputExecParametersDirty; }
    }
    #endregion

      
      #region UseQuotedIdentifiers
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUseQuotedIdentifiersDirty = false;
    private UseQuotedIdentifiersEnum m_UseQuotedIdentifiers;
    [MTDataMember(Description = "Whether to Use Quoted Identifiers.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public UseQuotedIdentifiersEnum UseQuotedIdentifiers
    {
      get { return m_UseQuotedIdentifiers; }
      set
      {
        m_UseQuotedIdentifiers = value;
        isUseQuotedIdentifiersDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUseQuotedIdentifiersDirty
    {
      get { return isUseQuotedIdentifiersDirty; }
    }
    #endregion

    #region bUseQuotedIdentifiers
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isbUseQuotedIdentifiersDirty = false;
    private bool m_bUseQuotedIdentifiers;
    [MTDataMember(Description = "Whether to Use Quoted Identifiers.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool bUseQuotedIdentifiers
    {
      get { return m_bUseQuotedIdentifiers; }
      set
      {
        m_bUseQuotedIdentifiers = value;
        isbUseQuotedIdentifiersDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsbUseQuotedIdentifiersDirty
    {
      get { return isbUseQuotedIdentifiersDirty; }
    }
    #endregion

      #region LastRunDate 
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLastRunDateDirty = false;
    private DateTime m_LastRunDate;
    [MTDataMember(Description = "Last Run Date.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime LastRunDate
    {
      get { return m_LastRunDate; }
      set
      {
        m_LastRunDate = value;
        isLastRunDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLastRunDateDirty
    {
      get { return isLastRunDateDirty; }
    }
    #endregion

    #region NextRunDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNextRunDateDirty = false;
    private DateTime m_NextRunDate;
    [MTDataMember(Description = "Next Run Date.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime NextRunDate
    {
      get { return m_NextRunDate; }
      set
      {
        m_NextRunDate = value;
        isNextRunDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNextRunDateDirty
    {
      get { return isNextRunDateDirty; }
    }
    #endregion

    #region OutputFileName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOutputFileNameDirty = false;
    private string m_OutputFileName;
    [MTDataMember(Description = "Output File Name.", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string OutputFileName
    {
      get { return m_OutputFileName; }
      set
      {
        m_OutputFileName = value;
        isOutputFileNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsOutputFileNameDirty
    {
      get { return isOutputFileNameDirty; }
    }
    #endregion

    #region IDParameterValueInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDParameterValueInstanceDirty = false;
    private int m_IDParameterValueInstance;
    [MTDataMember(Description = "This the Parameter ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDParameterValueInstance
    {
      get { return m_IDParameterValueInstance; }
      set
      {
        m_IDParameterValueInstance = value;
        isIDParameterValueInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDParameterValueInstanceDirty
    {
      get { return isIDParameterValueInstanceDirty; }
    }
    #endregion
      
      
      #region IDParameterInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDParameterInstanceDirty = false;
    private int m_IDParameterInstance;
    [MTDataMember(Description = "This the Parameter ID..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IDParameterInstance
    {
      get { return m_IDParameterInstance; }
      set
      {
        m_IDParameterInstance = value;
        isIDParameterInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDParameterInstanceDirty
    {
      get { return isIDParameterInstanceDirty; }
    }
    #endregion


    #region ParameterNameInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterNameInstanceDirty = false;
    private string m_ParameterNameInstance;
    [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterNameInstance
    {
      get { return m_ParameterNameInstance; }
      set
      {
        m_ParameterNameInstance = value;
        isParameterNameInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterNameInstanceDirty
    {
      get { return isParameterNameInstanceDirty; }
    }
    #endregion

    #region ParameterDescriptionInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterDescriptionInstanceDirty = false;
    private string m_ParameterDescriptionInstance;
    [MTDataMember(Description = "This the Parameter Description..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterDescriptionInstance
    {
      get { return m_ParameterDescriptionInstance; }
      set
      {
        m_ParameterDescriptionInstance = value;
        isParameterDescriptionInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterDescriptionInstanceDirty
    {
      get { return isParameterDescriptionInstanceDirty; }
    }
    #endregion

    #region ParameterValueInstance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterValueInstanceDirty = false;
    private string m_ParameterValueInstance;
    [MTDataMember(Description = "This the Parameter Description..", Length = 50)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterValueInstance
    {
      get { return m_ParameterValueInstance; }
      set
      {
        m_ParameterValueInstance = value;
        isParameterValueInstanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterValueInstanceDirty
    {
      get { return isParameterValueInstanceDirty; }
    }
    #endregion


  }
}
