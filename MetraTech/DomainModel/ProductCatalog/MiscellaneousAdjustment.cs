using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]
  public class MiscellaneousAdjustment : BaseObject
  {

    #region ViewId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isViewIdDirty = false;
    private int m_ViewId;
    [MTDataMember(Description = "The View id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ViewId
    {
      get { return m_ViewId; }
      set
      {
          m_ViewId = value;
          isViewIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsViewIdDirty
    {
      get { return isViewIdDirty; }
    }
    #endregion

    #region SessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSessionIdDirty = false;
    private long m_SessionId;
    [MTDataMember(Description = "The session id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public long SessionId
    {
      get { return m_SessionId; }
      set
      {
          m_SessionId = value;
          isSessionIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsSessionIdDirty
    {
      get { return isSessionIdDirty; }
    }
    #endregion
  
    #region IntervalId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIntervalIdDirty = false;
    private int m_IntervalId;
    [MTDataMember(Description = "Interval Id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IntervalId
    {
      get { return m_IntervalId; }
      set
      {
          m_IntervalId = value;
          isIntervalIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsIntervalIdDirty
    {
      get { return isIntervalIdDirty; }
    }
    #endregion

    #region Amount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountDirty = false;
    private decimal m_Amount;
    [MTDataMember(Description = "This the amount.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal Amount
    {
      get { return m_Amount; }
      set
      {
          m_Amount = value;
          isAmountDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAmountDirty
    {
      get { return isAmountDirty; }
    }
    #endregion

    #region Currency
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  private bool isCurrencyDirty = false;
  private SystemCurrencies m_Currency;
  [MTDataMember(Description = "This property stores a value from the Currency enumeration to indicate the currency. ", Length = 40)]
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  public SystemCurrencies Currency
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

    #region Currency Value Display Name
  public string CurrencyValueDisplayName
  {
    get
    {
      return GetDisplayName(this.Currency);
    }
    set
    {
      this.Currency = ((SystemCurrencies)(GetEnumInstanceByDisplayName(typeof(SystemCurrencies), value)));
    }
  }
  #endregion

    #region TimeStamp
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  private bool isTimeStampDirty = false;
  private DateTime m_TimeStamp;
  [MTDataMember(Description = "TimeStamp of the transaction", Length = 40)]
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  public DateTime TimeStamp
  {
    get { return m_TimeStamp; }
    set
    {
      m_TimeStamp = value;
      isTimeStampDirty = true;
    }
  }
  [ScriptIgnore]
  public bool IsTimeStampDirty
  {
    get { return isTimeStampDirty; }
  }
  #endregion

    #region SessionType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSessionTypeDirty = false;
    private string m_SessionType;
    [MTDataMember(Description = "Session Type", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SessionType
    {
      get { return m_SessionType; }
      set
      {
          m_SessionType = value;
          isSessionTypeDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsSessionTypeDirty
    {
      get { return isSessionTypeDirty; }
    }
    #endregion

    #region Reason
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReasonDirty = false;
    private SubscriberCreditAccountRequestReason m_Reason;
    [MTDataMember(Description = "Reason", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public SubscriberCreditAccountRequestReason Reason
    {
      get { return m_Reason; }
      set
      {
          m_Reason = value;
          isReasonDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsReasonDirty
    {
      get { return isReasonDirty; }
    }
    #endregion

    #region Reason Value Display Name
    public string ReasonValueDisplayName
  {
    get
    {
      return GetDisplayName(this.Reason);
    }
    set
    {
      this.Reason = ((SubscriberCreditAccountRequestReason)(GetEnumInstanceByDisplayName(typeof(SubscriberCreditAccountRequestReason), value)));
    }
  }
  #endregion

    #region Other
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOtherDirty = false;
    private string m_Other;
    [MTDataMember(Description = "Other", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Other
    {
      get { return m_Other; }
      set
      {
          m_Other = value;
          isOtherDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsOtherDirty
    {
      get { return isOtherDirty; }
    }
    #endregion

    #region Status
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStatusDirty = false;
    private string m_Status;
    [MTDataMember(Description = "Status", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Status
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

    #region AdjustmentAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentAmountDirty = false;
    private decimal m_AdjustmentAmount;
    [MTDataMember(Description = "Adjustment Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AdjustmentAmount
    {
      get { return m_AdjustmentAmount; }
      set
      {
          m_AdjustmentAmount = value;
          isAdjustmentAmountDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAdjustmentAmountDirty
    {
      get { return isAdjustmentAmountDirty; }
    }
    #endregion

    #region EmailNotification
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEmailNotificationDirty = false;
    private string m_EmailNotification;
    [MTDataMember(Description = "Email Notification", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string EmailNotification
    {
      get { return m_EmailNotification; }
      set
      {
          m_EmailNotification = value;
          isEmailNotificationDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsEmailNotificationDirty
    {
      get { return isEmailNotificationDirty; }
    }
    #endregion

    #region EmailAddress
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEmailAddressDirty = false;
    private string m_EmailAddress;
    [MTDataMember(Description = "Email Address", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string EmailAddress
    {
      get { return m_EmailAddress; }
      set
      {
          m_EmailAddress = value;
          isEmailAddressDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsEmailAddressDirty
    {
      get { return isEmailAddressDirty; }
    }
    #endregion

    #region ContentionSessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isContentionSessionIdDirty = false;
    private string m_ContentionSessionId;
    [MTDataMember(Description = "Contention Session Id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ContentionSessionId
    {
      get { return m_ContentionSessionId; }
      set
      {
          m_ContentionSessionId = value;
          isContentionSessionIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsContentionSessionIdDirty
    {
      get { return isContentionSessionIdDirty; }
    }
    #endregion

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "Description", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
          m_Description = value;
          isDescriptionDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

    #region SubscriberAccountId
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  private bool isSubscriberAccountIdDirty = false;
  private int m_SubscriberAccountId;
  [MTDataMember(Description = "The Subscriber Account Id", Length = 40)]
  [DataMember(IsRequired = false, EmitDefaultValue = false)]
  public int SubscriberAccountId
  {
    get { return m_SubscriberAccountId; }
    set
    {
      m_SubscriberAccountId = value;
      isSubscriberAccountIdDirty = true;
    }
  }
  [ScriptIgnore]
  public bool IsSubscriberAccountIdDirty
  {
    get { return isSubscriberAccountIdDirty; }
  }
  #endregion

    #region GuideIntervalId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGuideIntervalIdDirty = false;
    private int m_GuideIntervalId;
    [MTDataMember(Description = "Guide Interval Id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int GuideIntervalId
    {
      get { return m_GuideIntervalId; }
      set
      {
          m_GuideIntervalId = value;
          isGuideIntervalIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsGuideIntervalIdDirty
    {
      get { return isGuideIntervalIdDirty; }
    }
    #endregion

    #region TaxAmount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTaxAmountDirty = false;
    private decimal m_TaxAmount;
    [MTDataMember(Description = "This is the tax amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal TaxAmount
    {
      get { return m_TaxAmount; }
      set
      {
          m_TaxAmount = value;
          isTaxAmountDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsTaxAmountDirty
    {
      get { return isTaxAmountDirty; }
    }
    #endregion

    #region AmountWithTax
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountWithTaxDirty = false;
    private decimal m_AmountWithTax;
    [MTDataMember(Description = "This is the amount with tax.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal AmountWithTax
    {
      get { return m_AmountWithTax; }
      set
      {
          m_AmountWithTax = value;
          isAmountWithTaxDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsAmountWithTaxDirty
    {
      get { return isAmountWithTaxDirty; }
    }
    #endregion
  }
}
