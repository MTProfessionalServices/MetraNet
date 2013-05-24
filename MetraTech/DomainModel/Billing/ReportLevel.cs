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
    public class ReportLevel : ReportLineItem
    {
        #region Name
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNameDirty = false;
        private string m_Name;
        [MTDataMember(Description = "This is the report level name.", Length = 40)]
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

        #region OwnerSlice
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isOwnerSliceDirty = false;
        private AccountSlice m_OwnerSlice;
        [MTDataMember(Description = "This account slice defines the owning account(s)", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountSlice OwnerSlice
        {
            get { return m_OwnerSlice; }
            set
            {
                m_OwnerSlice = value;
                isOwnerSliceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsOwnerSliceDirty
        {
            get { return isOwnerSliceDirty; }
        }
        #endregion

        #region FolderSlice
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isFolderSliceDirty = false;
        private AccountSlice m_FolderSlice;
        [MTDataMember(Description = "This slice defines the folder this report level represents", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountSlice FolderSlice
        {
            get { return m_FolderSlice; }
            set
            {
                m_FolderSlice = value;
                isFolderSliceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsFolderSliceDirty
        {
            get { return isFolderSliceDirty; }
        }
        #endregion

        #region TotalDisplayAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTotalDisplayAmountDirty = false;
        private decimal m_TotalDisplayAmount;
        [MTDataMember(Description = "This is the total amount displayed.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal TotalDisplayAmount
        {
            get { return m_TotalDisplayAmount; }
            set
            {
                m_TotalDisplayAmount = value;
                isTotalDisplayAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTotalDisplayAmountDirty
        {
            get { return isTotalDisplayAmountDirty; }
        }
        #endregion

        #region TotalDisplayAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isTotalDisplayAmountAsStringDirty = false;
        private string m_TotalDisplayAmountAsString;
        [MTDataMember(Description = "This is the text representation of the total amount displayed.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string TotalDisplayAmountAsString
        {
            get { return m_TotalDisplayAmountAsString; }
            set
            {
                m_TotalDisplayAmountAsString = value;
                isTotalDisplayAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsTotalDisplayAmountAsStringDirty
        {
            get { return isTotalDisplayAmountAsStringDirty; }
        }
        #endregion

        #region NumPreBillAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumPreBillAdjustmentsDirty = false;
        private int m_NumPreBillAdjustments;
        [MTDataMember(Description = "This is the number of the pre bill adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumPreBillAdjustments
        {
            get { return m_NumPreBillAdjustments; }
            set
            {
                m_NumPreBillAdjustments = value;
                isNumPreBillAdjustmentsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumPreBillAdjustmentsDirty
        {
            get { return isNumPreBillAdjustmentsDirty; }
        }
        #endregion

        #region NumPostBillAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isNumPostBillAdjustmentsDirty = false;
        private int m_NumPostBillAdjustments;
        [MTDataMember(Description = "This is the number of the post bill adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public int NumPostBillAdjustments
        {
            get { return m_NumPostBillAdjustments; }
            set
            {
                m_NumPostBillAdjustments = value;
                isNumPostBillAdjustmentsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsNumPostBillAdjustmentsDirty
        {
            get { return isNumPostBillAdjustmentsDirty; }
        }
        #endregion

        #region PreBillAdjustmentsDisplayAmount
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustmentsDisplayAmountDirty = false;
        private decimal m_PreBillAdjustmentsDisplayAmount;
        [MTDataMember(Description = "This is the display amount of the pre bill adjustments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreBillAdjustmentsDisplayAmount
        {
            get { return m_PreBillAdjustmentsDisplayAmount; }
            set
            {
                m_PreBillAdjustmentsDisplayAmount = value;
                isPreBillAdjustmentsDisplayAmountDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustmentsDisplayAmountDirty
        {
            get { return isPreBillAdjustmentsDisplayAmountDirty; }
        }
        #endregion

        #region PreBillAdjustmentsDisplayAmountAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreBillAdjustmentsDisplayAmountAsStringDirty = false;
        private string m_PreBillAdjustmentsDisplayAmountAsString;
        [MTDataMember(Description = "This is the text representation of pre-bill adjustments display amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreBillAdjustmentsDisplayAmountAsString
        {
            get { return m_PreBillAdjustmentsDisplayAmountAsString; }
            set
            {
                m_PreBillAdjustmentsDisplayAmountAsString = value;
                isPreBillAdjustmentsDisplayAmountAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPreBillAdjustmentsDisplayAmountAsStringDirty
        {
            get { return isPreBillAdjustmentsDisplayAmountAsStringDirty; }
        }
        #endregion

        #region Charges
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isChargesDirty = false;
        private List<ReportCharge> m_Charges;
        [MTDataMember(Description = "These are the charges.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<ReportCharge> Charges
        {
            get { return m_Charges; }
            set
            {
                m_Charges = value;
                isChargesDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsChargesDirty
        {
            get { return isChargesDirty; }
        }
        #endregion

        #region ProductOfferings
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isProductOfferingsDirty = false;
        private List<ReportProductOffering> m_ProductOfferings;
        [MTDataMember(Description = "These are the product offerings.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<ReportProductOffering> ProductOfferings
        {
            get { return m_ProductOfferings; }
            set
            {
                m_ProductOfferings = value;
                isProductOfferingsDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsProductOfferingsDirty
        {
            get { return isProductOfferingsDirty; }
        }
        #endregion

        #region AccountEffectiveDate
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isAccountEffectiveDateDirty = false;
        private DateRangeSlice mAccountEffectiveDate;
        [MTDataMember(Description = "Effective range of the account in account hierarchy.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public DateRangeSlice AccountEffectiveDate
        {
            get { return mAccountEffectiveDate; }
            set
            {
                mAccountEffectiveDate = value;
                isAccountEffectiveDateDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsAccountEffectiveDateDirty
        {
            get { return isAccountEffectiveDateDirty; }
        }
        #endregion

        #region HierarchyPath
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isHierarchyPathDirty = false;
        private string m_HierarchyPath;
        [MTDataMember(Description = "stores hierarchy information", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string HierarchyPath
        {
            get { return m_HierarchyPath; }
            set
            {
                m_HierarchyPath = value;
                isHierarchyPathDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsHierarchyPathDirty
        {
            get { return isHierarchyPathDirty; }
        }
        #endregion
    }

}