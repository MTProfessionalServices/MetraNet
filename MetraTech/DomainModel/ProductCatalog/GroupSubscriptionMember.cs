using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]
  public class GroupSubscriptionMember : BaseObject
  {
    #region GroupId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isGroupIdDirty = false;
    private int? m_GroupId;
    [MTDataMember(Description = "This is the identifier of the GroupSubscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? GroupId
    {
      get { return m_GroupId; }
      set
      {

        m_GroupId = value;
        isGroupIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsGroupIdDirty
    {
      get { return isGroupIdDirty; }
    }
    #endregion

    #region AccountId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountIdDirty = false;
    private int? m_AccountId;
    [MTDataMember(Description = "This is the id of the group subscription member account")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? AccountId
    {
      get { return m_AccountId; }
      set
      {

        m_AccountId = value;
        isAccountIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAccountIdDirty
    {
      get { return isAccountIdDirty; }
    }
    #endregion

    #region MembershipSpan
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMembershipSpanDirty = false;
    private ProdCatTimeSpan m_MembershipSpan = new ProdCatTimeSpan();
    [MTDataMember(Description = "This is the membership time span for the account", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan MembershipSpan
    {
      get { return m_MembershipSpan; }
      set
      {

        m_MembershipSpan = value;
        isMembershipSpanDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMembershipSpanDirty
    {
      get { return isMembershipSpanDirty; }
    }
    #endregion

    #region AccountName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountNameDirty = false;
    private string m_AccountName;
    [MTDataMember(Description = "This is the name of the group subscription member account")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string AccountName
    {
        get { return m_AccountName; }
        set
        {

            m_AccountName = value;
            isAccountNameDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsAccountNameDirty
    {
        get { return isAccountNameDirty; }
    }
    #endregion


  }
}
