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
    public class CurrentAccountIntervalSlice : TimeSlice
    {
        #region AccountId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountIdDirty = false;
    private AccountIdentifier m_AccountId;
    [MTDataMember(Description = "This specifies the account for which the default interval is to be retrieved", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public AccountIdentifier AccountId
    {
      get { return m_AccountId; }
      set
      {
          m_AccountId = value;
          isAccountIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAccountIdDirty
    {
      get { return isAccountIdDirty; }
    }
    #endregion
    }
}