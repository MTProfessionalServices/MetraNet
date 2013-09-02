using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
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

    #region TotalTax

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTotalTaxDirty = false;
    private decimal m_TotalTax;
    [MTDataMember(Description = "Quote total amount")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal TotalTax
    {
        get { return m_TotalTax; }
        set
        {
            m_TotalTax = value;
            isTotalTaxDirty = true;
        }
    }

    [ScriptIgnore]
    public bool IsTotalTaxDirty
    {
        get { return isTotalTaxDirty; }
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
}