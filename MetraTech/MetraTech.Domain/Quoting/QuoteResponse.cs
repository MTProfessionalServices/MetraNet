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
    #region IdQuote

    /// <summary>
    /// When debugging do not clean up usage data after quote run
    /// </summary>
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private int _idQuote;
    [MTDataMember(Description = "Quote Id")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int IdQuote { get; set; }

    #endregion IdQuote

    #region QuoteStatus

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private QuoteStatus _status;
    [MTDataMember(Description = "Quote status")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public QuoteStatus Status
    {
      get { return _status; }
      set
      {
          _status = value;
          IsStatusDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsStatusDirty { get; private set; }

    #endregion QuoteStatus

    #region FailedMessage

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private string _failedMessage;
    [MTDataMember(Description = "Quote failed message")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FailedMessage
    {
      get { return _failedMessage; }
      set
      {
        _failedMessage = value;
        IsFailedMessageDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsFailedMessageDirty { get; private set; }

    #endregion

    #region TotalAmount

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private decimal _totalAmount;
    [MTDataMember(Description = "Quote total amount")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal TotalAmount
    {
      get { return _totalAmount; }
      set
      {
          _totalAmount = value;
        IsTotalAmountDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsTotalAmountDirty { get; private set; }

    #endregion

    #region TotalTax

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private decimal _totalTax;
    [MTDataMember(Description = "Quote total amount")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal TotalTax
    {
        get { return _totalTax; }
        set
        {
            _totalTax = value;
            IsTotalTaxDirty = true;
        }
    }

    [ScriptIgnore]
    public bool IsTotalTaxDirty { get; private set; }

    #endregion

    #region Currency

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private string _currency;
    [MTDataMember(Description = "Quote currency")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Currency
    {
      get { return _currency; }
      set
      {
        _currency = value;
        IsCurrencyDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCurrencyDirty { get; private set; }

    #endregion

    #region ReportLink

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private string _reportLink;
    [MTDataMember(Description = "Quote report link")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportLink
    {
      get { return _reportLink; }
      set
      {
        _reportLink = value;
        IsReportLinkDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsReportLinkDirty { get; private set; }

    #endregion

    #region CreationDate

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private DateTime _creationDate;
    [MTDataMember(Description = "Quote creation date")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime CreationDate
    {
      get { return _creationDate; }
      set
      {
        _creationDate = value;
        IsCreationDateDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsCreationDateDirty { get; private set; }

    #endregion

    #region MessageLog

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private List<QuoteLogRecord> _messageLog;
    [MTDataMember(Description = "Quote message log")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<QuoteLogRecord> MessageLog
    {
      get { return _messageLog; }
      set
      {
        _messageLog = value;
        IsMessageLogDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsMessageLogDirty { get; private set; }

    #endregion

    #region Artefacts 
    
    [MTDataMember(Description = "Contains Quote artefacts: subscription Ids, Usage Interval, Charges batches and etc.")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public QuoteResponseArtefacts Artefacts { get; set; }
      
    #endregion Artefacts

    public QuoteResponse()
    {
        MessageLog = new List<QuoteLogRecord>();
        Artefacts = null;
    }

    public QuoteResponse(QuoteResponseArtefacts qouteArtefacts) 
      : this()

    {
        Artefacts = qouteArtefacts;
    }
  }
}