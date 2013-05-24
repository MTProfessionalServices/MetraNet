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
    public class PayerAndPayeeSlice : AccountSlice
    {
        #region PayerAccountId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPayerAccountIdDirty = false;
        private AccountIdentifier m_PayerAccountId;
        [MTDataMember(Description = "This is the payer account identifier", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier PayerAccountId
        {
          get { return m_PayerAccountId; }
          set
          {
              m_PayerAccountId = value;
              isPayerAccountIdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayerAccountIdDirty
        {
          get { return isPayerAccountIdDirty; }
        }
        #endregion

        #region PayeeAccountId
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPayeeAccountIdDirty = false;
        private AccountIdentifier m_PayeeAccountId;
        [MTDataMember(Description = "This is the payee account identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier PayeeAccountId
        {
          get { return m_PayeeAccountId; }
          set
          {
              m_PayeeAccountId = value;
              isPayeeAccountIdDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayeeAccountIdDirty
        {
          get { return isPayeeAccountIdDirty; }
        }
        #endregion
    }
}