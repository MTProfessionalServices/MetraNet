using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{

    [DataContract]
    [Serializable]
    public abstract class NonRecurringChargePIInstance : BasePriceableItemInstance
    {
        protected override PriceableItemKinds GetPIKind()
        {
            return PriceableItemKinds.NonRecurring;
        }

        #region EventType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEventTypeDirty = false;
    private Nullable<NonRecurringChargeEvents> m_EventType;
    [MTDataMember(Description = "This property stores the type of event that triggers the non-recurring charge to be generated on the user's bill.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Nullable<NonRecurringChargeEvents> EventType
    {
      get { return m_EventType; }
      set
      {
          m_EventType = value;
          isEventTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEventTypeDirty
    {
      get { return isEventTypeDirty; }
    }
    #endregion    
    }
}
