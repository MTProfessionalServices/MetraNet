using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text;

namespace MetraTech.ActivityServices.Common
{
  [DataContract]
  [Serializable]
  public class AccountIdentifier
  {
    #region Constructors
    public AccountIdentifier(int accountID)
    {
      m_AccountID = accountID;
    }

    public AccountIdentifier(string userName, string nameSpace)
    {
      m_Username = userName;
      m_Namespace = nameSpace;
    }
    #endregion

    #region Public Properties
    public int? AccountID { get { return m_AccountID; } }
    
    public string Username { get { return m_Username; } }
    
    public string Namespace { get { return m_Namespace; } }
    #endregion

    #region Private Members
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private int? m_AccountID = null;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private string m_Username = null;
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private string m_Namespace = null;
    #endregion

  }
}
