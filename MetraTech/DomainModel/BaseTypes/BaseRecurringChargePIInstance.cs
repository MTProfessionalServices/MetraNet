using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public abstract class BaseRecurringChargePIInstance : BasePriceableItemInstance
    {
        #region Cycle
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCycleDirty = false;
        private ExtendedUsageCycleInfo m_Cycle;
    [MTDataMember(Description = "This specifies the usage cycle for the priceable item template.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public ExtendedUsageCycleInfo Cycle
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

        #region FixedProrationLength
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFixedProrationLengthDirty = false;
    private Nullable<bool> m_FixedProrationLength;
    [MTDataMember(Description = "This flag indicates whether the recurring charge uses a fixed number of days to calculate proration or if it uses the actual number of days used in the period to calculate proration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<bool> FixedProrationLength
    {
      get { return m_FixedProrationLength; }
      set
      {
          m_FixedProrationLength = value;
          isFixedProrationLengthDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFixedProrationLengthDirty
    {
      get { return isFixedProrationLengthDirty; }
    }
    #endregion

        #region ProrateOnDeactivation
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProrateOnDeactivationDirty = false;
    private Nullable<bool> m_ProrateOnDeactivation;
    [MTDataMember(Description = "This flag indicates whether the recurring charge should be prorated when the subscription terminates in the middle of the interval.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<bool> ProrateOnDeactivation
    {
      get { return m_ProrateOnDeactivation; }
      set
      {
          m_ProrateOnDeactivation = value;
          isProrateOnDeactivationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProrateOnDeactivationDirty
    {
      get { return isProrateOnDeactivationDirty; }
    }
    #endregion

    #region ProrateInstantly
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProrateInstantlyDirty = false;
    private Nullable<bool> m_ProrateInstantly;
    [MTDataMember(Description = "This flag indicates whether the recurring charge should be prorated when the subscription starts and there's a definite ending date.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<bool> ProrateInstantly
    {
      get { return m_ProrateInstantly; }
      set
      {
        m_ProrateInstantly = value;
        isProrateInstantlyDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProrateInstantlyDirty
    {
      get { return isProrateInstantlyDirty; }
    }
    #endregion


        #region ProrateOnActivation
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isProrateOnActivationDirty = false;
    private  Nullable<bool> m_ProrateOnActivation;
    [MTDataMember(Description = "This flag indicates whether the recurring charge should be prorated when the subscription starts in the middle of the interval.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<bool> ProrateOnActivation
    {
      get { return m_ProrateOnActivation; }
      set
      {
          m_ProrateOnActivation = value;
          isProrateOnActivationDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsProrateOnActivationDirty
    {
      get { return isProrateOnActivationDirty; }
    }
    #endregion

        #region ChargeAdvance
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeAdvanceDirty = false;
    private  Nullable<bool> m_ChargeAdvance;
    [MTDataMember(Description = "This flag indicates whether this recurring charge should be applied to the account in advance of the interval of usage or if it should be charged in arrears.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<bool> ChargeAdvance
    {
      get { return m_ChargeAdvance; }
      set
      {
          m_ChargeAdvance = value;
          isChargeAdvanceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsChargeAdvanceDirty
    {
      get { return isChargeAdvanceDirty; }
    }
    #endregion

        #region ChargePerParticipant
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargePerParticipantDirty = false;
    private  Nullable<bool> m_ChargePerParticipant;
    [MTDataMember(Description = "when used in a group subscription, this flag determines whether the recurring charge gets applied to only once to the group subscription per interval or if it is applied to each member of the group subscription per interval.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public  Nullable<bool> ChargePerParticipant
    {
      get { return m_ChargePerParticipant; }
      set
      {
          m_ChargePerParticipant = value;
          isChargePerParticipantDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsChargePerParticipantDirty
    {
      get { return isChargePerParticipantDirty; }
    }
    #endregion
    }
}