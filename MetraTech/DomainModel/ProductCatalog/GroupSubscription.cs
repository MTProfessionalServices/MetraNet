using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
  #region Public Enums
  public enum DiscountDistribution
  {
    None,
    Account,
    AccountOrProportional
  }

  #endregion

  [DataContract]
  [Serializable]
  public class GroupSubscription : Subscription
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

    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the GroupSubscription", Length = 255)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Name
    {
      get { return m_Name; }
      set
      {

        m_Name = value;
        isNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNameDirty
    {
      get { return isNameDirty; }
    }
    #endregion

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "This is the description of the GroupSubscription", Length = 255)]
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

    #region CorporateAccountId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCorporateAccountIdDirty = false;
    private int m_CorporateAccountId;
    [MTDataMember(Description = "This is the id of the corporate account which owns the group subscription")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int CorporateAccountId
    {
      get { return m_CorporateAccountId; }
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

    #region DiscountAccountId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDiscountAccountIdDirty = false;
    private int? m_DiscountAccountId;
    [MTDataMember(Description = "This is the account that receives the discount on the group sub", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? DiscountAccountId
    {
      get { return m_DiscountAccountId; }
      set
      {
 
          m_DiscountAccountId = value;
          isDiscountAccountIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDiscountAccountIdDirty
    {
      get { return isDiscountAccountIdDirty; }
    }
    #endregion

    #region UsageCycleId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsageCycleIdDirty = false;
    private int m_UsageCycleId;
    [MTDataMember(Description = "This is the identifier of the usage cycle for the Group Subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int UsageCycleId
    {
      get { return m_UsageCycleId; }
      set
      {
 
          m_UsageCycleId = value;
          isUsageCycleIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUsageCycleIdDirty
    {
      get { return isUsageCycleIdDirty; }
    }
    #endregion
    
    #region Visible
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isVisibleDirty = false;
    private bool m_Visible;
    [MTDataMember(Description = "This flag indicates whether the group sub is visible to the subscriber", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool Visible
    {
      get { return m_Visible; }
      set
      {
 
          m_Visible = value;
          isVisibleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsVisibleDirty
    {
      get { return isVisibleDirty; }
    }
    #endregion

    #region ProportionalDistribution
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProportionalDistributionDirty = false;
    private bool m_ProportionalDistribution;
    [MTDataMember(Description = "Indicates whether the group sub is ProportionalDistribution", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool ProportionalDistribution
    {
      get { return m_ProportionalDistribution; }
      set
      {
 
          m_ProportionalDistribution = value;
          isProportionalDistributionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProportionalDistributionDirty
    {
      get { return isProportionalDistributionDirty; }
    }
    #endregion
      
    #region SupportsGroupOperations
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSupportsGroupOperationsDirty = false;
    private bool m_SupportsGroupOperations;
    [MTDataMember(Description = "Indicates whether the group subscription supports group operations", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool SupportsGroupOperations
    {
      get { return m_SupportsGroupOperations; }
      set
      {
 
          m_SupportsGroupOperations = value;
          isSupportsGroupOperationsDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSupportsGroupOperationsDirty
    {
      get { return isSupportsGroupOperationsDirty; }
    }
    #endregion

    #region DiscountDistribution
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDiscountDistributionDirty = false;
    private DiscountDistribution m_DiscountDistribution = DiscountDistribution.None;
    [MTDataMember(Description = "Specifies how distribution needs to be configured for a subscription based on this product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DiscountDistribution DiscountDistribution
    {
      get { return m_DiscountDistribution; }
      set
      {

        m_DiscountDistribution = value;
        isDiscountDistributionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDiscountDistributionDirty
    {
      get { return isDiscountDistributionDirty; }
    }
    #endregion

    #region Cycle
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isCycleDirty = false;
    private Cycle m_Cycle;
    [MTDataMember(Description = "Specifies how distribution needs to be configured for a subscription based on this product offering", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Cycle Cycle
    {
      get { return m_Cycle; }
      set
      {

        m_Cycle = value;
        isCycleDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCycleDirty
    {
      get { return isCycleDirty; }
    }
    #endregion

    #region UDRCInstances
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUDRCInstancesDirty = false;
    private List<UDRCInstance> m_UDRCInstances;
    [MTDataMember(Description = "UDRCInstances")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<UDRCInstance> UDRCInstances
    {
      get { return m_UDRCInstances; }
      set
      {

        m_UDRCInstances = value;
        isUDRCInstancesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUDRCInstancesDirty
    {
      get { return isUDRCInstancesDirty; }
    }
    #endregion

    #region FlatRateRecurringChargeInstances
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFlatRateRecurringChargeInstancesDirty = false;
    private List<FlatRateRecurringChargeInstance> m_FlatRateRecurringChargeInstances;
    [MTDataMember(Description = "FlatRateRecurringChargeInstances")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<FlatRateRecurringChargeInstance> FlatRateRecurringChargeInstances
    {
      get { return m_FlatRateRecurringChargeInstances; }
      set
      {

        m_FlatRateRecurringChargeInstances = value;
        isFlatRateRecurringChargeInstancesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFlatRateRecurringChargeInstancesDirty
    {
      get { return isFlatRateRecurringChargeInstancesDirty; }
    }
    #endregion

    #region Members
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMembersDirty = false;
    private MTList<GroupSubscriptionMember> m_Members;
    [MTDataMember(Description = "Members")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MTList<GroupSubscriptionMember> Members
    {
      get { return m_Members; }
      set
      {

        m_Members = value;
        isMembersDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMembersDirty
    {
      get { return isMembersDirty; }
    }
    #endregion

  }
}
