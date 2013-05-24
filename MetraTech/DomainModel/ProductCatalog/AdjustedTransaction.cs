using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.Web.Script.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]

  public class AdjustedTransaction : BaseObject
  {

    #region AdjustmentCreationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAdjustmentCreationDateDirty = false;
    private DateTime m_AdjustmentCreationDate;
    [MTDataMember(Description = "This is the adjustment creation date ", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public DateTime AdjustmentCreationDate
    {
      get { return m_AdjustmentCreationDate; }
      set
      {
        m_AdjustmentCreationDate = value;
        isAdjustmentCreationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAdjustmentCreationDateDirty
    {
      get { return isAdjustmentCreationDateDirty; }
    }
    
    #endregion

    #region SessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSessionIdDirty = false;
    private long m_SessionId;
    [MTDataMember(Description = "Session id", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public long SessionId
    {
      get { return m_SessionId; }
      set
      {
        m_SessionId = value;
        isSessionIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSessionIdDirty
    {
      get { return isSessionIdDirty; }
    }
    #endregion

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "Description", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Description
    {
      get { return m_Description; }
      set
      {
        m_Description = value;
        isDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDescriptionDirty
    {
      get { return isDescriptionDirty; }
    }
    #endregion

    #region Status
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isStatusDirty = false;
    private string m_Status;
    [MTDataMember(Description = "Adjustment Status", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Status
    {
      get { return m_Status; }
      set
      {
        m_Status = value;
        isStatusDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStatusDirty
    {
      get { return isStatusDirty; }
    }
    #endregion

    #region UsernamePayer
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsernamePayerDirty = false;
    private string m_UsernamePayer;
    [MTDataMember(Description = "Username payer", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UsernamePayer
    {
      get { return m_UsernamePayer; }
      set
      {
        m_UsernamePayer = value;
        isUsernamePayerDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUsernamePayerDirty
    {
      get { return isUsernamePayerDirty; }
    }
    #endregion

    #region UsernamePayee
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsernamePayeeDirty = false;
    private string m_UsernamePayee;
    [MTDataMember(Description = "Username payee", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string UsernamePayee
    {
      get { return m_UsernamePayee; }
      set
      {
        m_UsernamePayee = value;
        isUsernamePayeeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUsernamePayeeDirty
    {
      get { return isUsernamePayeeDirty; }
    }
    #endregion

    #region PITemplateDisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPITemplateDisplayNameDirty = false;
    private string m_PITemplateDisplayName;
    [MTDataMember(Description = "PI Template display name", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PITemplateDisplayName
    {
      get { return m_PITemplateDisplayName; }
      set
      {
        m_PITemplateDisplayName = value;
        isPITemplateDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPITemplateDisplayNameDirty
    {
      get { return isPITemplateDisplayNameDirty; }
    }
    #endregion

    #region Amount
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAmountDirty = false;
    private decimal m_Amount;
    [MTDataMember(Description = "amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal Amount
    {
      get { return m_Amount; }
      set
      {
        m_Amount = value;
        isAmountDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsAmountDirty
    {
      get { return isAmountDirty; }
    }
    #endregion

    #region PendingPrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPendingPrebillAdjAmtDirty = false;
    private decimal m_PendingPrebillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PendingPrebillAdjAmt
    {
      get { return m_PendingPrebillAdjAmt; }
      set
      {
        m_PendingPrebillAdjAmt = value;
        isPendingPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPendingPrebillAdjAmtDirty
    {
      get { return isPendingPrebillAdjAmtDirty; }
    }
    #endregion

    #region PendingPostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPendingPostbillAdjAmtDirty = false;
    private decimal m_PendingPostbillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PendingPostbillAdjAmt
    {
      get { return m_PendingPostbillAdjAmt; }
      set
      {
        m_PendingPostbillAdjAmt = value;
        isPendingPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPendingPostbillAdjAmtDirty
    {
      get { return isPendingPostbillAdjAmtDirty; }
    }
    #endregion

    #region PrebillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPrebillAdjAmtDirty = false;
    private decimal m_PrebillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PrebillAdjAmt
    {
      get { return m_PrebillAdjAmt; }
      set
      {
        m_PrebillAdjAmt = value;
        isPrebillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPrebillAdjAmtDirty
    {
      get { return isPrebillAdjAmtDirty; }
    }
    #endregion

    #region PostbillAdjAmt
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPostbillAdjAmtDirty = false;
    private decimal m_PostbillAdjAmt;
    [MTDataMember(Description = "Penidng Prebill Adj Amount", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public decimal PostbillAdjAmt
    {
      get { return m_PostbillAdjAmt; }
      set
      {
        m_PostbillAdjAmt = value;
        isPostbillAdjAmtDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPostbillAdjAmtDirty
    {
      get { return isPostbillAdjAmtDirty; }
    }
    #endregion

    #region ParentSessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParentSessionIdDirty = false;
    private long m_ParentSessionId;
    [MTDataMember(Description = "This is the parent session id.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public long ParentSessionId
    {
      get { return m_ParentSessionId; }
      set
      {
        m_ParentSessionId = value;
        isParentSessionIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParentSessionIdDirty
    {
      get { return isParentSessionIdDirty; }
    }
    #endregion

  }
}
