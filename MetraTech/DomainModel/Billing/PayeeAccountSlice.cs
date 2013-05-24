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
    public class PayeeAccountSlice : AccountSlice
    {
        #region PayeeID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]  
        private bool isPayeeIDDirty = false;
        private AccountIdentifier m_PayeeID;
        [MTDataMember(Description = "This is the identifier of the payee.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier PayeeID
        {
          get { return m_PayeeID; }
          set
          {
              m_PayeeID = value;
              isPayeeIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayeeIDDirty
        {
          get { return isPayeeIDDirty; }
        }
        #endregion
    }
}