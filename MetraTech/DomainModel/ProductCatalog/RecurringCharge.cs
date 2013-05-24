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
  public class RecurringCharge : PriceableItem 
  {
    #region ChargePerParticipant
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargePerParticipantDirty = false;
    private bool m_ChargePerParticipant;
    [MTDataMember(Description = "Indicates whether the group sub is ChargePerParticipant")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool ChargePerParticipant
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

    #region ChargeAccountId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeAccountIdDirty = false;
    private int? m_ChargeAccountId;
    [MTDataMember(Description = "Designated account for the recurring charge in a group subscription", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? ChargeAccountId
    {
      get { return m_ChargeAccountId; }
      set
      {

        m_ChargeAccountId = value;
        isChargeAccountIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsChargeAccountIdDirty
    {
      get { return isChargeAccountIdDirty; }
    }
    #endregion

    #region ChargeAccountSpan
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isChargeAccountSpanDirty = false;
    private ProdCatTimeSpan m_ChargeAccountSpan = new ProdCatTimeSpan();
    [MTDataMember(Description = "Time span for the recurring charge in a group subscription for the charge account", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan ChargeAccountSpan
    {
      get { return m_ChargeAccountSpan; }
      set
      {

        m_ChargeAccountSpan = value;
        isChargeAccountSpanDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsChargeAccountSpanDirty
    {
      get { return isChargeAccountSpanDirty; }
    }
    #endregion
  }
}
