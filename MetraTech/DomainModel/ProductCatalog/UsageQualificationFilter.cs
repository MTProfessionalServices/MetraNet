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
    /// UsageQualificationFilter is specified to filter the usage events that
    /// are impacted by this decision.
    /// This class is involved in updating the table t_amp_usagequalifica.
    /// </summary>
  [DataContract]
  [Serializable]
  public class UsageQualificationFilter : BaseObject
  {
    #region Filter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFilterDirty = false;
    private string m_Filter;

    /// <summary>
    /// String containing an MVM conditional statement e.g. "OBJECT.c_isTollCall ne 0"
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string Filter
    {
      get { return m_Filter; }
      set
      {
          m_Filter = value;
          isFilterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFilterDirty
    {
      get { return isFilterDirty; }
    }
    #endregion

    #region Priority
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriorityDirty = false;
    private int m_Priority;

    /// <summary>
    /// Integer used to order the filters.  Lower numbered filters are processed first.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int Priority
    {
      get { return m_Priority; }
      set
      {
          m_Priority = value;
          isPriorityDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPriorityDirty
    {
      get { return isPriorityDirty; }
    }
    #endregion

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
    /// <summary>
    /// A unique identifier assigned to this usage qualification filter when
    /// it is inserted into the databse.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the usage qualification filter", Length = 40)]
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

  }
}
