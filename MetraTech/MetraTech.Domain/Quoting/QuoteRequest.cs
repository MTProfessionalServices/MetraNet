using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
  [DataContract]
  [Serializable]
  public class QuoteRequest
  {
    #region Accounts

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountsDirty;
    private List<int> _accounts;
    [MTDataMember(Description = "List of accounts to create quote for")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<int> Accounts
    {
      get { return _accounts; }
      set
      {
        _accounts = value ?? new List<int>();        
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
    private bool isProductOfferingsDirty;
    private List<int> _productOfferings;
    [MTDataMember(Description = "List of product offerings to create quote for")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<int> ProductOfferings
    {
      get { return _productOfferings; }
      set
      {
          _productOfferings = value ?? new List<int>();         
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
    private bool isQuoteIdentifierDirty;
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
    private bool isQuoteDescriptionDirty;
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

    #region Quoting parameters
    
    private List<QuoteIndividualPrice> _icbPrices;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    [MTDataMember(Description = "Quote individual price parameters", Length = 40)]
    public List<QuoteIndividualPrice> IcbPrices
    {
      get { return _icbPrices; }
      set
      {
          _icbPrices = value ?? new List<QuoteIndividualPrice>();
          IsIcbPricesDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsIcbPricesDirty { get; set; }

    #endregion

    #region EffectiveDate

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEffectiveDateDirty;
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
    private bool isEffectiveEndDateDirty;
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
    private bool isLocalizationDirty;
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
    private bool isReportParametersDirty;
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
    private bool isSubscriptionParametersDirty;
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
    private bool isDebugDoNotCleanupUsageDirty;
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
      IcbPrices = new List<QuoteIndividualPrice>();

      EffectiveDate = MetraTime.Now;
      EffectiveEndDate = MetraTime.Now;

      ReportParameters = new ReportParams { PDFReport = false };

      DebugDoNotCleanupUsage = true;
    }
  }
}