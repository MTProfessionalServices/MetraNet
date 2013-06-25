using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.DomainModel.BaseTypes
{
  //Eventually for ActivityServices might need to accept and return well defined structures
  [DataContract]
  [Serializable]
  public class QuoteRequest
  {
    #region Accounts

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountsDirty = false;
    private List<int> m_Accounts;
    [MTDataMember(Description = "List of accounts to create quote for")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<int> Accounts
    {
      get { return m_Accounts; }
      set
      {
        m_Accounts = value;
        isAccountsDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsAccountsDirty
    {
      get { return isAccountsDirty; }
    }

    #endregion

    #region ProductOfferings

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProductOfferingsDirty = false;
    private List<int> m_ProductOfferings;
    [MTDataMember(Description = "List of product offerings to create quote for")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<int> ProductOfferings
    {
      get { return m_ProductOfferings; }
      set
      {
        m_ProductOfferings = value;
        isProductOfferingsDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsProductOfferingsDirty
    {
      get { return isProductOfferingsDirty; }
    }

    #endregion

    #region QuoteIdentifier

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isQuoteIdentifierDirty = false;
    private string m_QuoteIdentifier;
    [MTDataMember(Description = "Quote identifier", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string QuoteIdentifier
    {
      get { return m_QuoteIdentifier; }
      set
      {
        m_QuoteIdentifier = value;
        isQuoteIdentifierDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsQuoteIdentifierDirty
    {
      get { return isQuoteIdentifierDirty; }
    }

    #endregion

    #region QuoteDescription

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isQuoteDescriptionDirty = false;
    private string m_QuoteDescription;
    [MTDataMember(Description = "Quote identifier", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string QuoteDescription
    {
      get { return m_QuoteDescription; }
      set
      {
        m_QuoteDescription = value;
        isQuoteDescriptionDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsQuoteDescriptionDirty
    {
      get { return isQuoteDescriptionDirty; }
    }

    #endregion

    #region EffectiveDate

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEffectiveDateDirty = false;
    private DateTime m_EffectiveDate;
    [MTDataMember(Description = "Quote effective date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime EffectiveDate
    {
      get { return m_EffectiveDate; }
      set
      {
        m_EffectiveDate = value;
        isEffectiveDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsEffectiveDateDirty
    {
      get { return isEffectiveDateDirty; }
    }

    #endregion

    #region EffectiveEndDate

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEffectiveEndDateDirty = false;
    private DateTime m_EffectiveEndDate;
    [MTDataMember(Description = "Quote effective end date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime EffectiveEndDate
    {
      get { return m_EffectiveEndDate; }
      set
      {
        m_EffectiveEndDate = value;
        isEffectiveEndDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsEffectiveEndDateDirty
    {
      get { return isEffectiveEndDateDirty; }
    }

    #endregion

    #region Localization

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizationDirty = false;
    private string m_Localization;
    [MTDataMember(Description = "Quote localization", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Localization
    {
      get { return m_Localization; }
      set
      {
        m_Localization = value;
        isLocalizationDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsLocalizationDirty
    {
      get { return isLocalizationDirty; }
    }

    #endregion

    #region ReportParameters

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportParametersDirty = false;
    private ReportParams m_ReportParameters;
    [MTDataMember(Description = "Quote report parameters", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ReportParams ReportParameters
    {
      get { return m_ReportParameters; }
      set
      {
        m_ReportParameters = value;
        isReportParametersDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsReportParametersDirty
    {
      get { return isReportParametersDirty; }
    }

    #endregion

    #region SubscriptionParameters

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSubscriptionParametersDirty = false;
    private SubscriptionParameters m_SubscriptionParameters;
    [MTDataMember(Description = "Quote Subscription parameters", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SubscriptionParameters SubscriptionParameters
    {
      get { return m_SubscriptionParameters; }
      set
      {
        m_SubscriptionParameters = value;
        isSubscriptionParametersDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsSubscriptionParametersDirty
    {
      get { return isSubscriptionParametersDirty; }
    }

    #endregion

    #region DebugDoNotCleanupUsage

    /// <summary>
    /// When debugging do not clean up usage data after quote run
    /// </summary>
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDebugDoNotCleanupUsageDirty = false;
    private bool m_DebugDoNotCleanupUsage;
    [MTDataMember(Description = "When debugging do not clean up usage data after quote run", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool DebugDoNotCleanupUsage
    {
      get { return m_DebugDoNotCleanupUsage; }
      set
      {
        m_DebugDoNotCleanupUsage = value;
        isDebugDoNotCleanupUsageDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsDebugDoNotCleanupUsageDirty
    {
      get { return isDebugDoNotCleanupUsageDirty; }
    }

    #endregion

    public QuoteRequest()
    {
      Accounts = new List<int>();
      ProductOfferings = new List<int>();
      SubscriptionParameters = new SubscriptionParameters();

      EffectiveDate = MetraTime.Now;
      EffectiveEndDate = MetraTime.Now;

      ReportParameters = new ReportParams() { PDFReport = false };

      DebugDoNotCleanupUsage = true;
    }
  }

  [DataContract]
  [Serializable]
  public enum QuoteStatus
  {
    [EnumMember]
    InProgress,
    [EnumMember]
    Failed,
    [EnumMember]
    Complete
  };

  [DataContract]
  [Serializable]
  public class QuoteResponse
  {
    #region ReportParameters

    /// <summary>
    /// When debugging do not clean up usage data after quote run
    /// </summary>
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIdQuoteDirty = false;
    private int m_idQuote;
    [MTDataMember(Description = "Quote Id")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int idQuote
    {
      get { return m_idQuote; }
      set
      {
        m_idQuote = value;
        isIdQuoteDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsIdQuoteDirty
    {
      get { return isIdQuoteDirty; }
    }

    #endregion

    #region StatusDirty

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStatusDirty = false;
    private QuoteStatus m_Status;
    [MTDataMember(Description = "Quote status")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public QuoteStatus Status
    {
      get { return m_Status; }
      set
      {
        m_Status = value;
        isStatusDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStatusDirty
    {
      get { return isStatusDirty; }
    }

    #endregion

    #region FailedMessage

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFailedMessageDirty = false;
    private string m_FailedMessage;
    [MTDataMember(Description = "Quote failed message")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FailedMessage
    {
      get { return m_FailedMessage; }
      set
      {
        m_FailedMessage = value;
        isFailedMessageDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsFailedMessageDirty
    {
      get { return isFailedMessageDirty; }
    }

    #endregion

    #region TotalAmount

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTotalAmountDirty = false;
    private decimal m_TotalAmount;
    [MTDataMember(Description = "Quote total amount")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal TotalAmount
    {
      get { return m_TotalAmount; }
      set
      {
        m_TotalAmount = value;
        isTotalAmountDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsTotalAmountDirty
    {
      get { return isTotalAmountDirty; }
    }

    #endregion

    #region Currency

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCurrencyDirty = false;
    private string m_Currency;
    [MTDataMember(Description = "Quote currency")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Currency
    {
      get { return m_Currency; }
      set
      {
        m_Currency = value;
        isCurrencyDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCurrencyDirty
    {
      get { return isCurrencyDirty; }
    }

    #endregion

    #region ReportLink

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportLinkDirty = false;
    private string m_ReportLink;
    [MTDataMember(Description = "Quote report link")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportLink
    {
      get { return m_ReportLink; }
      set
      {
        m_ReportLink = value;
        isReportLinkDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsReportLinkDirty
    {
      get { return isReportLinkDirty; }
    }

    #endregion

    #region CreationDate

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCreationDateDirty = false;
    private DateTime m_CreationDate;
    [MTDataMember(Description = "Quote creation date")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime CreationDate
    {
      get { return m_CreationDate; }
      set
      {
        m_CreationDate = value;
        isCreationDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCreationDateDirty
    {
      get { return isCreationDateDirty; }
    }

    #endregion

    #region MessageLog

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMessageLogDirty = false;
    private List<QuoteLogRecord> m_MessageLog;
    [MTDataMember(Description = "Quote message log")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<QuoteLogRecord> MessageLog
    {
      get { return m_MessageLog; }
      set
      {
        m_MessageLog = value;
        isMessageLogDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsMessageLogDirty
    {
      get { return isMessageLogDirty; }
    }

    #endregion
  }

  [DataContract]
  [Serializable]
  public class ReportParams
  {
    #region PDFReport

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPDFReportDirty = false;
    private bool m_PDFReport;
    [MTDataMember(Description = "Quote PDF report")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool PDFReport
    {
      get { return m_PDFReport; }
      set
      {
        m_PDFReport = value;
        isPDFReportDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPDFReportDirty
    {
      get { return isPDFReportDirty; }
    }

    #endregion

    #region ReportTemplateName

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportTemplateNameDirty = false;
    private string m_ReportTemplateName;
    [MTDataMember(Description = "Quote report template name")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportTemplateName
    {
      get { return m_ReportTemplateName; }
      set
      {
        m_ReportTemplateName = value;
        isReportTemplateNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsReportTemplateNameDirty
    {
      get { return isReportTemplateNameDirty; }
    }

    #endregion
  }

  [DataContract]
  [SerializableAttribute]
  public class QuoteLogRecord
  {
    #region QuoteIdentifier

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isQuoteIdentifierDirty = false;
    private string m_QuoteIdentifier;
    [MTDataMember(Description = "Quote identifier")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string QuoteIdentifier
    {
      get { return m_QuoteIdentifier; }
      set
      {
        m_QuoteIdentifier = value;
        isQuoteIdentifierDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsQuoteIdentifierDirty
    {
      get { return isQuoteIdentifierDirty; }
    }

    #endregion

    #region DateAdded

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDateAddedDirty = false;
    private DateTime m_DateAdded;
    [MTDataMember(Description = "Log record date")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime DateAdded
    {
      get { return m_DateAdded; }
      set
      {
        m_DateAdded = value;
        isDateAddedDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsDateAddedDirty
    {
      get { return isDateAddedDirty; }
    }

    #endregion

    #region Message

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMessageDirty = false;
    private string m_Message;
    [MTDataMember(Description = "Log message")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Message
    {
      get { return m_Message; }
      set
      {
        m_Message = value;
        isMessageDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsMessageDirty
    {
      get { return isMessageDirty; }
    }

    #endregion
  }

  [DataContract]
  [Serializable]
  public class SubscriptionParameters
  {
    public SubscriptionParameters()
    {
      UDRCValues = new Dictionary<string, List<UDRCInstanceValueBase>>();
    }

    #region UDRCValues

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUDRCValuesDirty = false;
    private Dictionary<string, List<UDRCInstanceValueBase>> m_UDRCValues;

    [MTDataMember(Description = "These are the temporal collections of values for UDRC instances in the PO", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<string, List<UDRCInstanceValueBase>> UDRCValues
    {
      get
      {
        if (m_UDRCValues == null)
        {
          m_UDRCValues = new Dictionary<string, List<UDRCInstanceValueBase>>();
        }

        return m_UDRCValues;
      }
      set
      {
        m_UDRCValues = value;
        isUDRCValuesDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsUDRCValuesDirty
    {
      get { return isUDRCValuesDirty; }
    }

    #endregion

    #region IsGroupSubscription

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIsGroupSubscriptionDirty = false;
    private bool m_IsGroupSubscription;

    [MTDataMember(Description = "Indicates whether use group subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool IsGroupSubscription
    {
      get
      {
        return m_IsGroupSubscription;
      }
      set
      {
        m_IsGroupSubscription = value;
        isIsGroupSubscriptionDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsIsGroupSubscriptionDirty
    {
      get { return isIsGroupSubscriptionDirty; }
    }
    #endregion

    #region CorporateAccountId

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCorporateAccountIdDirty = false;
    private int m_CorporateAccountId;

    [MTDataMember(Description = "Indicates whether use group subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int CorporateAccountId
    {
      get
      {
        return m_CorporateAccountId;
      }
      set
      {
        m_CorporateAccountId = value;
        isCorporateAccountIdDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCorporateAccountIdDirty
    {
      get { return isCorporateAccountIdDirty; }
    }
    #endregion
  }

}