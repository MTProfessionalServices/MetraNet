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
    public class ExportReportDefinition : BaseObject
    {
        #region ReportTitle
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportTitleDirty = false;
        private string m_ReportTitle;
        [MTDataMember(Description = "This the Export Report Title.", Length = 50)]
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

        #region ReportType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportTypeDirty = false;
        private string m_ReportType;
        [MTDataMember(Description = "This the Export Report Type.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string   ReportType
        {
          get { return m_ReportType; }
          set
          {
            m_ReportType = value;
            isReportTypeDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportTypeDirty
        {
          get { return isReportTypeDirty; }
        }
        #endregion

        #region ReportDefinitionSource
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportDefinitionSourceDirty = false;
        private string m_ReportDefinitionSource;
        [MTDataMember(Description = "This the Export Report Definition Source, whether Query or Crystal.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ReportDefinitionSource
        {
          get { return m_ReportDefinitionSource; }
          set
          {
            m_ReportDefinitionSource = value;
            isReportDefinitionSourceDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportDefinitionSourceDirty
        {
          get { return isReportDefinitionSourceDirty; }
        }
        #endregion

        #region ReportDescription
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportDescriptionDirty = false;
        private string m_ReportDescription;
        [MTDataMember(Description = "This the Export Report Description.", Length = 255)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ReportDescription
        {
          get { return m_ReportDescription; }
          set
          {
            m_ReportDescription = value;
            isReportDescriptionDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportDescriptionDirty
        {
          get { return isReportDescriptionDirty; }
        }
        #endregion

        #region ReportQueryTag
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportQueryTagDirty = false;
        private string m_ReportQueryTag;
        [MTDataMember(Description = "This the Export Report Query Tag in Common Queries.xml.", Length = 100)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ReportQueryTag
        {
          get { return m_ReportQueryTag; }
          set
          {
            m_ReportQueryTag = value;
            isReportQueryTagDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportQueryTagDirty
        {
          get { return isReportQueryTagDirty; }
        }
        #endregion

        #region PreventAdhocExecution
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreventAdhocExecutionDirty = false;
        private PreventAdhocExecutionEnum m_PreventAdhocExecution;
        [MTDataMember(Description = "Whether to allow adhoc execution or not", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PreventAdhocExecutionEnum PreventAdhocExecution
        {
          get { return m_PreventAdhocExecution; }
          set
          {
            m_PreventAdhocExecution = value;
            isPreventAdhocExecutionDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreventAdhocExecutionDirty
        {
          get { return isPreventAdhocExecutionDirty; }
        }
        #endregion

        #region PreventAdhocExec
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreventAdhocExecDirty = false;
        private PreventAdhocExecutionEnum m_PreventAdhocExec;
        [MTDataMember(Description = "This is the Prevent AdHoc execution enum...", Length = 10)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]

        public PreventAdhocExecutionEnum PreventAdhocExec
        {
          get { return m_PreventAdhocExec; }
          set
          {
            m_PreventAdhocExec = value;
            isPreventAdhocExecDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreventAdhocExecDirty
        {
          get { return isPreventAdhocExecDirty; }
        }
        #endregion

        #region bPreventAdhocExecution
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbPreventAdhocExecutionDirty = false;
        private bool m_bPreventAdhocExecution;
        [MTDataMember(Description = "Whether to allow adhoc execution or not", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool bPreventAdhocExecution
        {
          get { return m_bPreventAdhocExecution; }
          set
          {
            m_bPreventAdhocExecution = value;
            isbPreventAdhocExecutionDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbPreventAdhocExecutionDirty
        {
          get { return isbPreventAdhocExecutionDirty; }
        }
        #endregion

        #region bPreventAdhocExec
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbPreventAdhocExecDirty = false;
        private bool m_bPreventAdhocExec;
        [MTDataMember(Description = "This is the Prevent AdHoc execution enum...", Length = 10)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]

        public bool bPreventAdhocExec
        {
          get { return m_bPreventAdhocExec; }
          set
          {
            m_bPreventAdhocExec = value;
            isbPreventAdhocExecDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbPreventAdhocExecDirty
        {
          get { return isbPreventAdhocExecDirty; }
        }
        #endregion


      
      #region ReportID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportIDDirty = false;
        private int m_ReportID;
        [MTDataMember(Description = "Unique Identifier of the Report.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ReportID
        {
          get { return m_ReportID; }
          set
          {
            m_ReportID = value;
            isReportIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportIDDirty
        {
          get { return isReportIDDirty; }
        }
        #endregion

        #region ReportParametertID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isReportParameterIDDirty = false;
        private int m_ReportParameterID;
        [MTDataMember(Description = "Unique Identifier of the Report Parameter.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ReportParameterID
        {
          get { return m_ReportParameterID; }
          set
          {
            m_ReportParameterID = value;
            isReportParameterIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsReportParameterIDDirty
        {
          get { return isReportParameterIDDirty; }
        }
        #endregion
     
      #region ParametertID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterIDDirty = false;
        private int m_ParameterID;
        [MTDataMember(Description = "Unique Identifier of the Parameter.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ParameterID
        {
          get { return m_ParameterID; }
          set
          {
            m_ParameterID = value;
            isParameterIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterIDDirty
        {
          get { return isParameterIDDirty; }
        }
        #endregion

        #region ParameterName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterNameDirty = false;
        private string m_ParameterName;
        [MTDataMember(Description = "This the Parameter Name.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName
        {
          get { return m_ParameterName; }
          set
          {
            m_ParameterName = value;
            isParameterNameDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterNameDirty
        {
          get { return isParameterNameDirty; }
        }
        #endregion

        #region ParameterDescription
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterDescriptionDirty = false;
        private string m_ParameterDescription;
        [MTDataMember(Description = "This the Parameter Description.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterDescription
        {
          get { return m_ParameterDescription; }
          set
          {
            m_ParameterDescription = value;
            isParameterDescriptionDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterDescriptionDirty
        {
          get { return isParameterDescriptionDirty; }
        }
        #endregion

      //Following are added just for AdHoc Report Queue Management, START  

        #region AdhocIDReportInstance
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocIDReportInstanceDirty = false;
        private int m_AdhocIDReportInstance;
        [MTDataMember(Description = "This the Report Instance ID..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AdhocIDReportInstance
        {
          get { return m_AdhocIDReportInstance; }
          set
          {
            m_AdhocIDReportInstance = value;
            isAdhocIDReportInstanceDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocIDReportInstanceDirty
        {
          get { return isAdhocIDReportInstanceDirty; }
        }
        #endregion

        #region AdhocIDReport
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocIDReportDirty = false;
        private int m_AdhocIDReport;
        [MTDataMember(Description = "This the Report ID..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AdhocIDReport
        {
          get { return m_AdhocIDReport; }
          set
          {
            m_AdhocIDReport = value;
            isAdhocIDReportDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocIDReportDirty
        {
          get { return isAdhocIDReportDirty; }
        }
        #endregion

        #region AdhocOnlineReport
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocOnlineReportDirty = false;
        private ShowReportOnlineEnum m_AdhocOnlineReport;
        [MTDataMember(Description = "Whether Online Report is required..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ShowReportOnlineEnum AdhocOnlineReport
        {
          get { return m_AdhocOnlineReport; }
          set
          {
            m_AdhocOnlineReport = value;
            isAdhocOnlineReportDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocOnlineReportDirty
        {
          get { return isAdhocOnlineReportDirty; }
        }
        #endregion

        #region AdhocReportOutputType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocReportOutputTypeDirty = false;
        private ReportOutputTypeEnum m_AdhocReportOutputType;
        [MTDataMember(Description = "This is the Report Output Type like CSV, TXT, XML etc", Length = 10)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]

        public ReportOutputTypeEnum AdhocReportOutputType
        {
          get { return m_AdhocReportOutputType; }
          set
          {
            m_AdhocReportOutputType = value;
            isAdhocReportOutputTypeDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocReportOutputTypeDirty
        {
          get { return isAdhocReportOutputTypeDirty; }
        }
        #endregion

        #region AdhocReportDistributionType
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocReportDistributionTypeDirty = false;
        private ReportDeliveryTypeEnum m_AdhocReportDistributionType;
        [MTDataMember(Description = "This is the Report Distribution Type like Disk, FTP etc", Length = 10)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]

        public ReportDeliveryTypeEnum AdhocReportDistributionType
        {
          get { return m_AdhocReportDistributionType; }
          set
          {
            m_AdhocReportDistributionType = value;
            isAdhocReportDistributionTypeDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocReportDistributionTypeDirty
        {
          get { return isAdhocReportDistributionTypeDirty; }
        }
        #endregion

        #region AdhocReportDestination
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocReportDestinationDirty = false;
        private string m_AdhocReportDestination;
        [MTDataMember(Description = "This the Report Destination ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdhocReportDestination
        {
          get { return m_AdhocReportDestination; }
          set
          {
            m_AdhocReportDestination = value;
            isAdhocReportDestinationDirty = true;
          }
        }
        [ScriptIgnore]
        public bool AdhocIsReportDestinationDirty
        {
          get { return isAdhocReportDestinationDirty; }
        }
        #endregion

        #region AdhocFTPAccessUser
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocFTPAccessUserDirty = false;
        private string m_AdhocFTPAccessUser;
        [MTDataMember(Description = "This the FTP Access User ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdhocFTPAccessUser
        {
          get { return m_AdhocFTPAccessUser; }
          set
          {
            m_AdhocFTPAccessUser = value;
            isAdhocFTPAccessUserDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocFTPAccessUserDirty
        {
          get { return isAdhocFTPAccessUserDirty; }
        }
        #endregion

        #region AdhocFTPAccessPassword
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocFTPAccessPasswordDirty = false;
        private string m_AdhocFTPAccessPassword;
        [MTDataMember(Description = "This the FTP Access Password ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdhocFTPAccessPassword
        {
          get { return m_AdhocFTPAccessPassword; }
          set
          {
            m_AdhocFTPAccessPassword = value;
            isAdhocFTPAccessPasswordDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocFTPAccessPasswordDirty
        {
          get { return isAdhocFTPAccessPasswordDirty; }
        }
        #endregion

        #region AdhocGenerateControlFile
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocGenerateControlFileDirty = false;
        private GenerateControlFileEnum m_AdhocGenerateControlFile;
        [MTDataMember(Description = "Where Generate Control File ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public GenerateControlFileEnum AdhocGenerateControlFile
        {
          get { return m_AdhocGenerateControlFile; }
          set
          {
            m_AdhocGenerateControlFile = value;
            isAdhocGenerateControlFileDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocGenerateControlFileDirty
        {
          get { return isAdhocGenerateControlFileDirty; }
        }
        #endregion

        #region bAdhocGenerateControlFile
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbAdhocGenerateControlFileDirty = false;
        private bool m_bAdhocGenerateControlFile;
        [MTDataMember(Description = "Where Generate Control File ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool bAdhocGenerateControlFile
        {
          get { return m_bAdhocGenerateControlFile; }
          set
          {
            m_bAdhocGenerateControlFile = value;
            isbAdhocGenerateControlFileDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbAdhocGenerateControlFileDirty
        {
          get { return isbAdhocGenerateControlFileDirty; }
        }
        #endregion


        #region AdhocControlFileDeliveryLocation
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocControlFileDeliveryLocationDirty = false;
        private string m_AdhocControlFileDeliveryLocation;
        [MTDataMember(Description = "Control File Delivery Location ..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdhocControlFileDeliveryLocation
        {
          get { return m_AdhocControlFileDeliveryLocation; }
          set
          {
            m_AdhocControlFileDeliveryLocation = value;
            isAdhocControlFileDeliveryLocationDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocControlFileDeliveryLocationDirty
        {
          get { return isAdhocControlFileDeliveryLocationDirty; }
        }
        #endregion

        #region AdhocCompressReport
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocCompressReportDirty = false;
        private CompressReportEnum m_AdhocCompressReport;
        [MTDataMember(Description = "Whether to Compress Report..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public CompressReportEnum AdhocCompressReport
        {
          get { return m_AdhocCompressReport; }
          set
          {
            m_AdhocCompressReport = value;
            isAdhocCompressReportDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocCompressReportDirty
        {
          get { return isAdhocCompressReportDirty; }
        }
        #endregion

        #region bAdhocCompressReport
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbAdhocCompressReportDirty = false;
        private bool m_bAdhocCompressReport;
        [MTDataMember(Description = "Whether to Compress Report..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool bAdhocCompressReport
        {
          get { return m_bAdhocCompressReport; }
          set
          {
            m_bAdhocCompressReport = value;
            isbAdhocCompressReportDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbAdhocCompressReportDirty
        {
          get { return isbAdhocCompressReportDirty; }
        }
        #endregion

      
      #region AdhocCompressThreshold
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocCompressThresholdDirty = false;
        private int m_AdhocCompressThreshold;
        [MTDataMember(Description = "Compress Threshold..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AdhocCompressThreshold
        {
          get { return m_AdhocCompressThreshold; }
          set
          {
            m_AdhocCompressThreshold = value;
            isAdhocCompressThresholdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocCompressThresholdDirty
        {
          get { return isAdhocCompressThresholdDirty; }
        }
        #endregion

        #region AdhocOutputExecParameters
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocOutputExecParametersDirty = false;
        private WriteExecParamsToReportEnum m_AdhocOutputExecParameters;
        [MTDataMember(Description = "Whether to output  Exec Parameters to report..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public WriteExecParamsToReportEnum AdhocOutputExecParameters
        {
          get { return m_AdhocOutputExecParameters; }
          set
          {
            m_AdhocOutputExecParameters = value;
            isAdhocOutputExecParametersDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocOutputExecParametersDirty
        {
          get { return isAdhocOutputExecParametersDirty; }
        }
        #endregion

        #region bAdhocOutputExecParameters
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbAdhocOutputExecParametersDirty = false;
        private bool m_bAdhocOutputExecParameters;
        [MTDataMember(Description = "Whether to output  Exec Parameters to report..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool bAdhocOutputExecParameters
        {
          get { return m_bAdhocOutputExecParameters; }
          set
          {
            m_bAdhocOutputExecParameters = value;
            isbAdhocOutputExecParametersDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbAdhocOutputExecParametersDirty
        {
          get { return isbAdhocOutputExecParametersDirty; }
        }
        #endregion

      
      #region AdhocUseQuotedIdentifiers
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocUseQuotedIdentifiersDirty = false;
        private UseQuotedIdentifiersEnum m_AdhocUseQuotedIdentifiers;
        [MTDataMember(Description = "Whether to Use Quoted Identifiers.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public UseQuotedIdentifiersEnum AdhocUseQuotedIdentifiers
        {
          get { return m_AdhocUseQuotedIdentifiers; }
          set
          {
            m_AdhocUseQuotedIdentifiers = value;
            isAdhocUseQuotedIdentifiersDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocUseQuotedIdentifiersDirty
        {
          get { return isAdhocUseQuotedIdentifiersDirty; }
        }
        #endregion

        #region bAdhocUseQuotedIdentifiers
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isbAdhocUseQuotedIdentifiersDirty = false;
        private bool m_bAdhocUseQuotedIdentifiers;
        [MTDataMember(Description = "Whether to Use Quoted Identifiers.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public bool bAdhocUseQuotedIdentifiers
        {
          get { return m_bAdhocUseQuotedIdentifiers; }
          set
          {
            m_bAdhocUseQuotedIdentifiers = value;
            isbAdhocUseQuotedIdentifiersDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsbAdhocUseQuotedIdentifiersDirty
        {
          get { return isbAdhocUseQuotedIdentifiersDirty; }
        }
        #endregion

      
      #region AdhocOutputFileName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocOutputFileNameDirty = false;
        private string m_AdhocOutputFileName;
        [MTDataMember(Description = "Output File Name.", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string AdhocOutputFileName
        {
          get { return m_AdhocOutputFileName; }
          set
          {
            m_AdhocOutputFileName = value;
            isAdhocOutputFileNameDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocOutputFileNameDirty
        {
          get { return isAdhocOutputFileNameDirty; }
        }
        #endregion

        #region AdhocIdentifier
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocIdentifierDirty = false;
        private int m_AdhocIdentifier;
        [MTDataMember(Description = "Unique Identifier of the Report.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AdhocIdentifier
        {
          get { return m_AdhocIdentifier; }
          set
          {
            m_AdhocIdentifier = value;
            isAdhocIdentifierDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocIdentifierDirty
        {
          get { return isAdhocIdentifierDirty; }
        }
        #endregion

        #region AdhocDSID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAdhocDSIDDirty = false;
        private int m_AdhocDSID;
        [MTDataMember(Description = "Unique Identifier of the Report.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int AdhocDSID
        {
          get { return m_AdhocDSID; }
          set
          {
            m_AdhocDSID = value;
            isAdhocDSIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsAdhocDSIDDirty
        {
          get { return isAdhocDSIDDirty; }
        }
        #endregion

        //Parameter Name Numbers

        #region ParameterName1
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterName1Dirty = false;
        private string m_ParameterName1;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName1
        {
          get { return m_ParameterName1; }
          set
          {
            m_ParameterName1 = value;
            isParameterName1Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterName1Dirty
        {
          get { return isParameterName1Dirty; }
        }
        #endregion

        #region ParameterName2
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterName2Dirty = false;
        private string m_ParameterName2;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName2
        {
          get { return m_ParameterName2; }
          set
          {
            m_ParameterName2 = value;
            isParameterName2Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterName2Dirty
        {
          get { return isParameterName2Dirty; }
        }
        #endregion

        #region ParameterName3
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterName3Dirty = false;
        private string m_ParameterName3;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName3
        {
          get { return m_ParameterName3; }
          set
          {
            m_ParameterName3 = value;
            isParameterName3Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterName3Dirty
        {
          get { return isParameterName3Dirty; }
        }
        #endregion

        #region ParameterName4
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterName4Dirty = false;
        private string m_ParameterName4;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName4
        {
          get { return m_ParameterName4; }
          set
          {
            m_ParameterName4 = value;
            isParameterName4Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterName4Dirty
        {
          get { return isParameterName4Dirty; }
        }
        #endregion

        #region ParameterName5
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterName5Dirty = false;
        private string m_ParameterName5;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterName5
        {
          get { return m_ParameterName5; }
          set
          {
            m_ParameterName5 = value;
            isParameterName5Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterName5Dirty
        {
          get { return isParameterName5Dirty; }
        }
        #endregion

        //Parameter Value Numbers..
        #region ParameterValue1
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterValue1Dirty = false;
        private string m_ParameterValue1;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterValue1
        {
          get { return m_ParameterValue1; }
          set
          {
            m_ParameterValue1 = value;
            isParameterValue1Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterValue1Dirty
        {
          get { return isParameterValue1Dirty; }
        }
        #endregion

        #region ParameterValue2
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterValue2Dirty = false;
        private string m_ParameterValue2;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterValue2
        {
          get { return m_ParameterValue2; }
          set
          {
            m_ParameterValue2 = value;
            isParameterValue2Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterValue2Dirty
        {
          get { return isParameterValue2Dirty; }
        }
        #endregion

        #region ParameterValue3
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterValue3Dirty = false;
        private string m_ParameterValue3;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterValue3
        {
          get { return m_ParameterValue3; }
          set
          {
            m_ParameterValue3 = value;
            isParameterValue3Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterValue3Dirty
        {
          get { return isParameterValue3Dirty; }
        }
        #endregion

        #region ParameterValue4
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterValue4Dirty = false;
        private string m_ParameterValue4;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterValue4
        {
          get { return m_ParameterValue4; }
          set
          {
            m_ParameterValue4 = value;
            isParameterValue4Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterValue4Dirty
        {
          get { return isParameterValue4Dirty; }
        }
        #endregion

        #region ParameterValue5
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParameterValue5Dirty = false;
        private string m_ParameterValue5;
        [MTDataMember(Description = "This the Parameter Name Type..", Length = 50)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string ParameterValue5
        {
          get { return m_ParameterValue5; }
          set
          {
            m_ParameterValue5 = value;
            isParameterValue5Dirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParameterValue5Dirty
        {
          get { return isParameterValue5Dirty; }
        }
        #endregion

        #region ParamCount 
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isParamCountDirty = false;
        private int m_ParamCount;
        [MTDataMember(Description = "Unique Identifier of the Report.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int ParamCount
        {
          get { return m_ParamCount; }
          set
          {
            m_ParamCount = value;
            isParamCountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsParamCountDirty
        {
          get { return isParamCountDirty; }
        }
        #endregion
      
      //Above are added just for AdHoc Report Queue Management, END 
     
      }
      
    }

