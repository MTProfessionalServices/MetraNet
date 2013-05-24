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
    public class InvoiceBalances : BaseObject
    {
        #region Currency
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrencyDirty = false;
        private string m_Currency;
        [MTDataMember(Description = "This is the currency.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string Currency
        {
            get { return m_Currency; }
            set
            {
                m_Currency = value;
                isCurrencyDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrencyDirty
        {
            get { return isCurrencyDirty; }
        }
        #endregion

        #region PreviousBalance
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreviousBalanceDirty = false;
        private decimal m_PreviousBalance;
        [MTDataMember(Description = "This is the amount of previous balance.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal PreviousBalance
        {
            get { return m_PreviousBalance; }
            set
            {
                m_PreviousBalance = value;
                isPreviousBalanceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPreviousBalanceDirty
        {
            get { return isPreviousBalanceDirty; }
        }
        #endregion

        #region PreviousBalanceAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPreviousBalanceAsStringDirty = false;
        private string m_PreviousBalanceAsString;
        [MTDataMember(Description = "This is the text representation of the amount of previous balance.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string PreviousBalanceAsString
        {
            get { return m_PreviousBalanceAsString; }
            set
            {
                m_PreviousBalanceAsString = value;
                isPreviousBalanceAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsPreviousBalanceAsStringDirty
        {
            get { return isPreviousBalanceAsStringDirty; }
        }
        #endregion

        #region BalanceForward
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isBalanceForwardDirty = false;
        private decimal m_BalanceForward;
        [MTDataMember(Description = "This is the amount of balance forward.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal BalanceForward
        {
            get { return m_BalanceForward; }
            set
            {
                m_BalanceForward = value;
                isBalanceForwardDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsBalanceForwardDirty
        {
            get { return isBalanceForwardDirty; }
        }
        #endregion

        #region BalanceForwardAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isBalanceForwardAsStringDirty = false;
        private string m_BalanceForwardAsString;
        [MTDataMember(Description = "This is text representation of the amount of balance forward.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string BalanceForwardAsString
        {
            get { return m_BalanceForwardAsString; }
            set
            {
                m_BalanceForwardAsString = value;
                isBalanceForwardAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsBalanceForwardAsStringDirty
        {
            get { return isBalanceForwardAsStringDirty; }
        }
        #endregion

        #region CurrentBalance
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrentBalanceDirty = false;
        private decimal m_CurrentBalance;
        [MTDataMember(Description = "This is the current balance amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public decimal CurrentBalance
        {
            get { return m_CurrentBalance; }
            set
            {
                m_CurrentBalance = value;
                isCurrentBalanceDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrentBalanceDirty
        {
            get { return isCurrentBalanceDirty; }
        }
        #endregion

        #region CurrentBalanceAsString
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrentBalanceAsStringDirty = false;
        private string m_CurrentBalanceAsString;
        [MTDataMember(Description = "This is a text representation of the current balance amount.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public string CurrentBalanceAsString
        {
            get { return m_CurrentBalanceAsString; }
            set
            {
                m_CurrentBalanceAsString = value;
                isCurrentBalanceAsStringDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrentBalanceAsStringDirty
        {
            get { return isCurrentBalanceAsStringDirty; }
        }
        #endregion

        #region Estimation
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isEstimationDirty = false;
        private EstimationType m_Estimation;
        [MTDataMember(Description = "This is the estimation.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public EstimationType Estimation
        {
          get { return m_Estimation; }
          set
          {
              m_Estimation = value;
              isEstimationDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsEstimationDirty
        {
          get { return isEstimationDirty; }
        }
        #endregion

        #region Estimation Value Display Name
        public string EstimationValueDisplayName
        {
          get
          {
            return GetDisplayName(this.Estimation);
          }
          set
          {
            this.Estimation = ((EstimationType)(GetEnumInstanceByDisplayName(typeof(EstimationType), value)));
          }
        }
        #endregion
    }
}