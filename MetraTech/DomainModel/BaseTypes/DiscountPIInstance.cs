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
    public abstract class DiscountPIInstance : BasePriceableItemInstance
    {
        protected override PriceableItemKinds GetPIKind()
        {
            return PriceableItemKinds.Discount;
        }

        #region Cycle
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCycleDirty = false;
        private UsageCycleInfo m_Cycle;
        [MTDataMember(Description = "This property stores an instance of a UsageCycleInfo child class. This specifies the usage cycle for the priceable item template.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public UsageCycleInfo Cycle
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
      }
}
