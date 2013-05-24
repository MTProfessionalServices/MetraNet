using System;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
  [DataContract]
  [Serializable]
  public class AccountBillManager : BaseObject
  {
    #region AdminID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdminIDDirty = false;
    private int m_AdminID;
    [MTDataMember(Description = "This is the account admin id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AdminID
    {
      get { return m_AdminID; }
      set
      {
        m_AdminID = value;
        isAdminIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdminIDDirty
    {
      get { return isAdminIDDirty; }
    }
    #endregion

    #region AccountID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountIDDirty = false;
    private int m_AccountID;
    [MTDataMember(Description = "This is the account admin id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int AccountID
    {
      get { return m_AccountID; }
      set
      {
        m_AccountID = value;
        isAccountIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAccountIDDirty
    {
      get { return isAccountIDDirty; }
    }
    #endregion

    #region BillManager
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isBillManagerDirty = false;
    private string m_BillManager;
    [MTDataMember(Description = "This is the invoice description.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BillManager
    {
      get { return m_BillManager; }
      set
      {
        m_BillManager = value;
        isBillManagerDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsBillManagerDirty
    {
      get { return isBillManagerDirty; }
    }
    #endregion

    #region BillManagee
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isBillManageeDirty = false;
    private string m_BillManagee;
    [MTDataMember(Description = "This is the invoice description.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string BillManagee
    {
      get { return m_BillManagee; }
      set
      {
        m_BillManagee = value;
        isBillManageeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsBillManageeDirty
    {
      get { return isBillManageeDirty; }
    }
    #endregion
  }
}