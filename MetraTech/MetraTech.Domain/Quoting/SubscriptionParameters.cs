using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
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