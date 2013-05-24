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
    /// UsageQualificationGroup is specified to filter the usage events that
    /// are impacted by this decision.  This class is involved in 
    /// updating the table t_amp_usagequalgroup.  Each UsageQualificationGroup
    /// can contain one or more UsageQualification objects.
    /// </summary>
  [DataContract]
  [Serializable]
  public class UsageQualificationGroup : BaseObject
  {
    #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;

    /// <summary>
    /// Unique name assigned to this usage qualification group.
    /// </summary>
    [MTDataMember(Description = "Unique name of the usage qualification group", Length = 40)]
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
    /// A sentence or two describing this usage qualification group.
    /// </summary>
    [MTDataMember(Description = "Description of the usage qualification group", Length = 40)]
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
    /// A unique identifier assigned to this usage qualification group when
    /// it is inserted into the databse.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the usage qualification group", Length = 40)]
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

    #region UsageQualificationFilters
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUsageQualificationFiltersDirty = false;
    private List<UsageQualificationFilter> m_UsageQualificationFilters;
    /// <summary>
    /// This is the ordered list of filters that will be executed
    /// to determine which usage records should be considered by the decision.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<UsageQualificationFilter> UsageQualificationFilters
    {
        get { return m_UsageQualificationFilters; }
        set
        {
            m_UsageQualificationFilters = value;
            isUsageQualificationFiltersDirty = true;
        }
    }
    [ScriptIgnore]
    public bool IsUsageQualificationFiltersDirty
    {
        get { return isUsageQualificationFiltersDirty; }
    }
    #endregion
  }
}
