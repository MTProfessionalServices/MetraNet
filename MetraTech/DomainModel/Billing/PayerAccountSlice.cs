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
    public class  PayerAccountSlice : AccountSlice
    {
        #region PayerID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isPayerIDDirty = false;
        private AccountIdentifier m_PayerID;
        [MTDataMember(Description = "This is the payer identifier.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public AccountIdentifier PayerID
        {
          get { return m_PayerID; }
          set
          {
              m_PayerID = value;
              isPayerIDDirty = true;
          }
        }
        [ScriptIgnore]
        public bool IsPayerIDDirty
        {
          get { return isPayerIDDirty; }
        }
        #endregion
    }
}