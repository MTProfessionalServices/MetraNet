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
    public class Adjustments : BaseObject
    {
        #region PreBillAdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustmentAmountDirty = false;
        private decimal m_PreBillAdjustmentAmount;
        [MTDataMember(Description = "This is the pre-bill adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreBillAdjustmentAmount
        {
          get { return m_PreBillAdjustmentAmount; }
          set
          {
              m_PreBillAdjustmentAmount = value;
              isPreBillAdjustmentAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustmentAmountDirty
        {
          get { return isPreBillAdjustmentAmountDirty; }
        }
        #endregion

        #region PreBillAdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustmentAmountAsStringDirty = false;
        private string m_PreBillAdjustmentAmountAsString;
        [MTDataMember(Description = "This is the string representation of the pre-bill adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreBillAdjustmentAmountAsString
        {
          get { return m_PreBillAdjustmentAmountAsString; }
          set
          {
              m_PreBillAdjustmentAmountAsString = value;
              isPreBillAdjustmentAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustmentAmountAsStringDirty
        {
          get { return isPreBillAdjustmentAmountAsStringDirty; }
        }
        #endregion

        #region PreBillAdjustedAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustedAmountDirty = false;
        private decimal m_PreBillAdjustedAmount;
        [MTDataMember(Description = "This is the pre-bill adjusted amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreBillAdjustedAmount
        {
          get { return m_PreBillAdjustedAmount; }
          set
          {
              m_PreBillAdjustedAmount = value;
              isPreBillAdjustedAmountDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustedAmountDirty
        {
          get { return isPreBillAdjustedAmountDirty; }
        }
        #endregion

        #region PreBillAdjustedAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustedAmountAsStringDirty = false;
        private string m_PreBillAdjustedAmountAsString;
        [MTDataMember(Description = "This is the string representation of the pre-bill adjusted amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreBillAdjustedAmountAsString
        {
          get { return m_PreBillAdjustedAmountAsString; }
          set
          {
              m_PreBillAdjustedAmountAsString = value;
              isPreBillAdjustedAmountAsStringDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustedAmountAsStringDirty
        {
          get { return isPreBillAdjustedAmountAsStringDirty; }
        }
        #endregion

        #region PostBillAdjustmentAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillAdjustmentAmountDirty = false;
        private decimal m_PostBillAdjustmentAmount;
        [MTDataMember(Description = "This is the post-bill adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PostBillAdjustmentAmount
        {
            get { return m_PostBillAdjustmentAmount; }
            set
            {
                m_PostBillAdjustmentAmount = value;
                isPostBillAdjustmentAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillAdjustmentAmountDirty
        {
            get { return isPostBillAdjustmentAmountDirty; }
        }
        #endregion

        #region PostBillAdjustmentAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillAdjustmentAmountAsStringDirty = false;
        private string m_PostBillAdjustmentAmountAsString;
        [MTDataMember(Description = "This is the string representation of the post-bill adjustment amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PostBillAdjustmentAmountAsString
        {
            get { return m_PostBillAdjustmentAmountAsString; }
            set
            {
                m_PostBillAdjustmentAmountAsString = value;
                isPostBillAdjustmentAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillAdjustmentAmountAsStringDirty
        {
            get { return isPostBillAdjustmentAmountAsStringDirty; }
        }
        #endregion

        #region PostBillAdjustedAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillAdjustedAmountDirty = false;
        private decimal m_PostBillAdjustedAmount;
        [MTDataMember(Description = "This is the post-bill adjusted amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PostBillAdjustedAmount
        {
            get { return m_PostBillAdjustedAmount; }
            set
            {
                m_PostBillAdjustedAmount = value;
                isPostBillAdjustedAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillAdjustedAmountDirty
        {
            get { return isPostBillAdjustedAmountDirty; }
        }
        #endregion

        #region PostBillAdjustedAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillAdjustedAmountAsStringDirty = false;
        private string m_PostBillAdjustedAmountAsString;
        [MTDataMember(Description = "This is the string representation of the post-bill adjusted amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PostBillAdjustedAmountAsString
        {
            get { return m_PostBillAdjustedAmountAsString; }
            set
            {
                m_PostBillAdjustedAmountAsString = value;
                isPostBillAdjustedAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPostBillAdjustedAmountAsStringDirty
        {
            get { return isPostBillAdjustedAmountAsStringDirty; }
        }
        #endregion

    }
}
