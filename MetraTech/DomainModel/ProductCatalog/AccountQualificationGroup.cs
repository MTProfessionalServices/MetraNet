using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// AccountQualificationGroup is specified to determine which accounts
    /// will be considered by a decision.
    /// This class is involved in updating tables t_amp_accountqualifi 
    /// and t_amp_accountqualgro to perform this action.
    /// </summary>
  [DataContract]
  [Serializable]
  public class AccountQualificationGroup : BaseObject
  {
    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    /// <summary>
    /// Unique name of the account qualification group.
    /// </summary>
    [MTDataMember(Description = "Unique name of the account qualification group", Length = 40)]
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

    #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    /// <summary>
    /// Short description of the account qualification group.
    /// </summary>
    [MTDataMember(Description = "Description of the account qualification group", Length = 40)]
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

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
    /// <summary>
    /// Unique identifier of the account qualification group that is assigned
    /// when the account qualification group is added to the databse.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the account qualification group", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Guid UniqueId
    {
      get { return m_UniqueId; }
      set
      {
          m_UniqueId = value;
          isUniqueIdDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsUniqueIdDirty
    {
      get { return isUniqueIdDirty; }
    }
    #endregion

    #region AccountQualifications
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isAccountQualificationsDirty = false;
    private List<AccountQualification> m_AccountQualifications;
    /// <summary>
    /// This is the ordered list of filters that will be executed
    /// to determine which usage records should be considered by the decision.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<AccountQualification> AccountQualifications
    {
        get { return m_AccountQualifications; }
        set
        {
            m_AccountQualifications = value;
            isAccountQualificationsDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsAccountQualificationsDirty
    {
        get { return isAccountQualificationsDirty; }
    }
    #endregion
  }
}
