using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.ProductCatalog
{
    /// <summary>
    /// An AccountQualification defines a rule for either filtering
    /// out accounts, or adding accounts to be considered while
    /// processing a decision.
    /// </summary>
  [DataContract]
  [Serializable]
  public class AccountQualification : BaseObject
  {
    #region TableToInclude
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTableToIncludeDirty = false;
    private string m_TableToInclude;
    /// <summary>
    /// Database table that you want to include data from (Note: from Jonah)
    /// </summary>
    [MTDataMember(Description = "Database table that want to include data from", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TableToInclude
    {
      get { return m_TableToInclude; }
      set
      {
          m_TableToInclude = value;
          isTableToIncludeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTableToIncludeDirty
    {
      get { return isTableToIncludeDirty; }
    }
    #endregion

    #region MvmFilter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMvmFilterDirty = false;
    private string m_MvmFilter;
    /// <summary>
    /// MVM-level filter to include/exclude accounts (Note: from Jonah)
    /// </summary>
    [MTDataMember(Description = "MVM-level filter to include/exclude accounts", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MvmFilter
    {
      get { return m_MvmFilter; }
      set
      {
          m_MvmFilter = value;
          isMvmFilterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMvmFilterDirty
    {
      get { return isMvmFilterDirty; }
    }
    #endregion

    #region Mode
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isModeDirty = false;
    private int m_Mode;
    /// <summary>
    /// How the row should be used. It can be just an MVM-level filter, 
    /// adding columns for existing accounts, adding new accounts to the list, 
    /// or replacing the current list with the results of this instruction. 
    /// I forget the valid values since I don’t actually use it. 
    /// It’s informational only as far as I’m concerned, but it 
    /// could be used to decide which fields to display.  (Note: from Jonah)
    /// </summary>
    [MTDataMember(Description = "informational field", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int Mode
    {
      get { return m_Mode; }
      set
      {
          m_Mode = value;
          isModeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsModeDirty
    {
      get { return isModeDirty; }
    }
    #endregion

    #region Priority
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPriorityDirty = false;
    private int m_Priority;
    /// <summary>
    /// An AccountQualificationGroup's priority determines when it will be executed with
    /// respect to other AccountQualificationGroups.  Lower priority integer values will
    /// be executed first.  If multiple AccountQualificationGroups have the same priority,
    /// the order of their execution is undefined.
    /// </summary>
    [MTDataMember(Description = "determines the order of execution", Length = 40)]
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

    #region DbFilter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDbFilterDirty = false;
    private string m_DbFilter;
    /// <summary>
    /// database-level filter that will be added to the query when 
    /// pulling data from the TableToInclude
    /// </summary>
    [MTDataMember(Description = "Db-level filter that will be added to the query", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DbFilter
    {
      get { return m_DbFilter; }
      set
      {
          m_DbFilter = value;
          isDbFilterDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDbFilterDirty
    {
      get { return isDbFilterDirty; }
    }
    #endregion

    #region MatchField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMatchFieldDirty = false;
    private string m_MatchField;
    /// <summary>
    /// field in the TableToInclude to join to
    /// </summary>
    [MTDataMember(Description = "field in the TableToInclude to join to", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MatchField
    {
      get { return m_MatchField; }
      set
      {
          m_MatchField = value;
          isMatchFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMatchFieldDirty
    {
      get { return isMatchFieldDirty; }
    }
    #endregion

    #region OutputField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isOutputFieldDirty = false;
    private string m_OutputField;
    /// <summary>
    /// field to pull from the database table and use as the id_acc 
    /// (if we’re adding rows or replacing rows based on the mode)
    /// </summary>
    [MTDataMember(Description = "field to pull from the database table and use as the id_acc", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string OutputField
    {
      get { return m_OutputField; }
      set
      {
          m_OutputField = value;
          isOutputFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsOutputFieldDirty
    {
      get { return isOutputFieldDirty; }
    }
    #endregion

    #region SourceField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSourceFieldDirty = false;
    private string m_SourceField;
    /// <summary>
    /// field from the MVM object that will be used to join on the match field in the TableToInclude
    /// </summary>
    [MTDataMember(Description = "field from the MVM object to be used to join on the MatchField in the TableToInclude", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SourceField
    {
      get { return m_SourceField; }
      set
      {
          m_SourceField = value;
          isSourceFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSourceFieldDirty
    {
      get { return isSourceFieldDirty; }
    }
    #endregion

    #region UniqueId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isUniqueIdDirty = false;
    private Guid m_UniqueId;
    /// <summary>
    /// A unique identifier assigned to this account qualification when
    /// it is inserted into the database.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the account qualification", Length = 40)]
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
