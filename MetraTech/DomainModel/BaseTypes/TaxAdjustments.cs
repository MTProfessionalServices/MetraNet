using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    [KnownType(typeof(TaxData))]
    public class TaxAdjustments : BaseObject
    {
        #region PreBillTaxAdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillTaxAdjustmentAmountDirty = false;
        private decimal m_PreBillTaxAdjustmentAmount;
        [MTDataMember(Description = "This is the pre-bill  tax adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreBillTaxAdjustmentAmount
        {
          get { return m_PreBillTaxAdjustmentAmount; }
          set
          {
              m_PreBillTaxAdjustmentAmount = value;
              isPreBillTaxAdjustmentAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillTaxAdjustmentAmountDirty
        {
          get { return isPreBillTaxAdjustmentAmountDirty; }
        }
        #endregion

        #region PreBillTaxAdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillTaxAdjustmentAmountAsStringDirty = false;
        private string m_PreBillTaxAdjustmentAmountAsString;
        [MTDataMember(Description = "This is the pre-bill  tax adjustment amount as string.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreBillTaxAdjustmentAmountAsString
        {
          get { return m_PreBillTaxAdjustmentAmountAsString; }
          set
          {
              m_PreBillTaxAdjustmentAmountAsString = value;
              isPreBillTaxAdjustmentAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillTaxAdjustmentAmountAsStringDirty
        {
          get { return isPreBillTaxAdjustmentAmountAsStringDirty; }
        }
        #endregion

        #region PostBillTaxAdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillTaxAdjustmentAmountDirty = false;
        private decimal m_PostBillTaxAdjustmentAmount;
        [MTDataMember(Description = "This is the post-bill  tax adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PostBillTaxAdjustmentAmount
        {
            get { return m_PostBillTaxAdjustmentAmount; }
            set
            {
                m_PostBillTaxAdjustmentAmount = value;
                isPostBillTaxAdjustmentAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillTaxAdjustmentAmountDirty
        {
            get { return isPostBillTaxAdjustmentAmountDirty; }
        }
        #endregion

        #region PostBillTaxAdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillTaxAdjustmentAmountAsStringDirty = false;
        private string m_PostBillTaxAdjustmentAmountAsString;
        [MTDataMember(Description = "This is the post-bill  tax adjustment amount as string.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PostBillTaxAdjustmentAmountAsString
        {
            get { return m_PostBillTaxAdjustmentAmountAsString; }
            set
            {
                m_PostBillTaxAdjustmentAmountAsString = value;
                isPostBillTaxAdjustmentAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillTaxAdjustmentAmountAsStringDirty
        {
            get { return isPostBillTaxAdjustmentAmountAsStringDirty; }
        }
        #endregion
    }
}
