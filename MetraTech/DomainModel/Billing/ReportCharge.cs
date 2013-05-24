using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
    [DataContract]
    [Serializable]
    public class ReportCharge : ReportLineItem
    {
        #region DisplayName
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isDisplayNameDirty = false;
        private string m_DisplayName;
        [MTDataMember(Description = "This is the display name for the charge", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string DisplayName
        {
            get { return m_DisplayName; }
            set
            {
                m_DisplayName = value;
                isDisplayNameDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsDisplayNameDirty
        {
            get { return isDisplayNameDirty; }
        }
        #endregion

        #region SubCharges
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isSubChargesDirty = false;
        private List<ReportCharge> m_SubCharges = null;
        [MTDataMember(Description = "These are the sub-charges included in this charge.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<ReportCharge> SubCharges
        {
            get { return m_SubCharges; }
            set
            {
                m_SubCharges = value;
                isSubChargesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsSubChargesDirty
        {
            get { return isSubChargesDirty; }
        }
        #endregion

        #region ProductSlice
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductSliceDirty = false;
        private SingleProductSlice m_ProductSlice;
        [MTDataMember(Description = "This is the product slice used to select this charge.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public SingleProductSlice ProductSlice
        {
            get { return m_ProductSlice; }
            set
            {
                m_ProductSlice = value;
                isProductSliceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsProductSliceDirty
        {
            get { return isProductSliceDirty; }
        }
        #endregion
    }
}