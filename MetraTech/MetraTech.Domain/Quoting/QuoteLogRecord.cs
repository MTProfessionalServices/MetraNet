using System;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
  [DataContract]
  [Serializable]
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
}