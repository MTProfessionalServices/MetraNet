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
    public class InvoiceReport : BaseObject
    {
        #region InvoiceHeader
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isInvoiceHeaderDirty = false;
        private InvoiceInfo m_InvoiceHeader;
        [MTDataMember(Description = "This is the invoice header.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public InvoiceInfo InvoiceHeader
        {
          get { return m_InvoiceHeader; }
          set
          {
              m_InvoiceHeader = value;
              isInvoiceHeaderDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsInvoiceHeaderDirty
        {
          get { return isInvoiceHeaderDirty; }
        }
        #endregion

        #region PreviousBalances
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreviousBalancesDirty = false;
        private InvoiceBalances m_PreviousBalances;
        [MTDataMember(Description = "This is the previous balances section.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public InvoiceBalances PreviousBalances
        {
          get { return m_PreviousBalances; }
          set
          {
              m_PreviousBalances = value;
              isPreviousBalancesDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPreviousBalancesDirty
        {
          get { return isPreviousBalancesDirty; }
        }
        #endregion

        #region PostBillAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPostBillAdjustmentsDirty = false;
        private List<PostBillAdjustments> m_PostBillAdjustments;
        [MTDataMember(Description = "This is the post-bill adjustments section.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<PostBillAdjustments> PostBillAdjustments
        {
          get { return m_PostBillAdjustments; }
          set
          {
              m_PostBillAdjustments = value;
              isPostBillAdjustmentsDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPostBillAdjustmentsDirty
        {
          get { return isPostBillAdjustmentsDirty; }
        }
        #endregion

        #region ARAdjustments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isARAdjustmentsDirty = false;
        private List<ARAdjustment> m_ARAdjustments;
        [MTDataMember(Description = "This is the Accounts Receivable adjustments section.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<ARAdjustment> ARAdjustments
        {
          get { return m_ARAdjustments; }
          set
          {
              m_ARAdjustments = value;
              isARAdjustmentsDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsARAdjustmentsDirty
        {
          get { return isARAdjustmentsDirty; }
        }
        #endregion

        #region Payments
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPaymentsDirty = false;
        private List<Payment> m_Payments;
        [MTDataMember(Description = "These are the payments.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public List<Payment> Payments
        {
          get { return m_Payments; }
          set
          {
              m_Payments = value;
              isPaymentsDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPaymentsDirty
        {
          get { return isPaymentsDirty; }
        }
        #endregion

    }
}