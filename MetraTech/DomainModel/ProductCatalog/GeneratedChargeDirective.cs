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
    /// AMP has the ability to generate a new charge when criteria are met.
    /// To perform this task, a user must specify an ordered list of commands.
    /// This class holds a single directive to perform while creating a generated
    /// charge.
    ///
    /// There are currently 3 types of directives:
    ///     <list type="bullet">
    ///         <item>
    ///             <description>Table Inclusion - This directive tells AMP to join another table.</description>
    ///         </item>
    ///         <item>
    ///             <description>MVM Procedure - This directive tells AMP to execute a specified MVM procedure.</description>
    ///         </item>
    ///         <item>
    ///             <description>Field Population - Fill the specified field within the PV using the specified value.</description>
    ///         </item>
    ///     </list>
    /// 
    /// A single directive can contain more than one type of directive.
    /// </summary>
  [DataContract]
  [Serializable]
  public class GeneratedChargeDirective : BaseObject
  {
#region TABLE_INCLUSION_DIRECTIVE

    #region IncludeTableName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIncludeTableNameDirty = false;
    private string m_IncludeTableName;
    /// <summary>
    /// The name of a table or view in the database that will be joined to and extracted from
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string IncludeTableName
    {
      get { return m_IncludeTableName; }
      set
      {
          m_IncludeTableName = value;
          isIncludeTableNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIncludeTableNameDirty
    {
      get { return isIncludeTableNameDirty; }
    }
    #endregion

    #region SourceValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSourceValueDirty = false;
    private string m_SourceValue;
    /// <summary>
    /// The field name from the object in memory that will be used as part of the join predicate 
    /// (source_value = target_field) when joining to the included table
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string SourceValue
    {
      get { return m_SourceValue; }
      set
      {
          m_SourceValue = value;
          isSourceValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsSourceValueDirty
    {
      get { return isSourceValueDirty; }
    }
    #endregion

    #region TargetField
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTargetFieldDirty = false;
    private string m_TargetField;
    /// <summary>
    /// The field name from the include_table_name that will be used as part of the join 
    /// predicate (source_value = target_field) when joining to the included table
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TargetField
    {
      get { return m_TargetField; }
      set
      {
          m_TargetField = value;
          isTargetFieldDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTargetFieldDirty
    {
      get { return isTargetFieldDirty; }
    }
    #endregion

    #region IncludePredicate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIncludePredicateDirty = false;
    private string m_IncludePredicate;
    /// <summary>
    /// Any additional join predicate that should be added when joining to the included table. 
    /// If this is set to "num_generations = 1", then the full join predicate would be: 
    /// "where source_value = target_field and num_generations = 1".
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string IncludePredicate
    {
      get { return m_IncludePredicate; }
      set
      {
          m_IncludePredicate = value;
          isIncludePredicateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIncludePredicateDirty
    {
      get { return isIncludePredicateDirty; }
    }
    #endregion

    #region IncludedFieldPrefix
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIncludedFieldPrefixDirty = false;
    private string m_IncludedFieldPrefix;
    /// <summary>
    /// Since all fields from the identified row in include_table_name will be added 
    /// as fields to the object in memory, there is a chance of namespace overlap. 
    /// If the table has a field named X and the object in memory already has a 
    /// field named X, the existing value in X would be overwritten when the table 
    /// is joined to. To alleviate this problem, the user may define a prefix that 
    /// will be appended to the fieldname of every field in the include_table_name 
    /// when that field is added to the object in memory. So if the 
    /// included_field_prefix is set to "bogus_" and the include_table_name 
    /// has fields x and y, the object in memory would end up with fields 
    /// bogus_x and bogus_y.  
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string IncludedFieldPrefix
    {
      get { return m_IncludedFieldPrefix; }
      set
      {
          m_IncludedFieldPrefix = value;
          isIncludedFieldPrefixDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIncludedFieldPrefixDirty
    {
      get { return isIncludedFieldPrefixDirty; }
    }
    #endregion
#endregion

#region MVM_PROCEDURE_DIRECTIVE
    #region MvmProcedure
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isMvmProcedureDirty = false;
    private string m_MvmProcedure;
    /// <summary>
    /// The name of any mvm_procedure that should be executed at this point in the 
    /// execution path of any generated charge of this type.  Note: This field 
    /// represents the third unit of work available to a given row. It is simply 
    /// a hook to execute an mvm procedure. If the procedure referenced does 
    /// not exist, we will get an error at run-time. The procedure 
    /// accomplishes its work via side-effects and can do anything. 
    /// This provides the mechanism to do anything not supported by the 
    /// structural operations allowed by the row (table inclusion and field population)
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string MvmProcedure
    {
      get { return m_MvmProcedure; }
      set
      {
          m_MvmProcedure = value;
          isMvmProcedureDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsMvmProcedureDirty
    {
      get { return isMvmProcedureDirty; }
    }
    #endregion
#endregion

#region FIELD_POPULATION_DIRECTIVE

    #region FieldName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFieldNameDirty = false;
    private string m_FieldName;
    /// <summary>
    /// The field name for the object in memory that will be populated by the population_string.
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string FieldName
    {
      get { return m_FieldName; }
      set
      {
          m_FieldName = value;
          isFieldNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsFieldNameDirty
    {
      get { return isFieldNameDirty; }
    }
    #endregion

    #region PopulationString
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPopulationStringDirty = false;
    private string m_PopulationString;
    /// <summary>
    /// A freeform expression that will be evaluated to set the appropriate 
    /// value for the field_name above
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string PopulationString
    {
      get { return m_PopulationString; }
      set
      {
          m_PopulationString = value;
          isPopulationStringDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsPopulationStringDirty
    {
      get { return isPopulationStringDirty; }
    }
    #endregion

    #region DefaultValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDefaultValueDirty = false;
    private string m_DefaultValue;
    /// <summary>
    /// A scalar value that will be used if the population_string results 
    /// in an empty string (or if no population_string is specified). 
    /// The population_string could also be set to a scalar value, 
    /// but best practice would be to only use the population_string 
    /// when an actual expression is required (i.e. reading from 
    /// other fields in the object etc.)
    /// </summary>
    [MTDataMember(Description = "YYYYY", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DefaultValue
    {
      get { return m_DefaultValue; }
      set
      {
          m_DefaultValue = value;
          isDefaultValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDefaultValueDirty
    {
      get { return isDefaultValueDirty; }
    }
    #endregion
#endregion

    #region Filter
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isFilterDirty = false;
    private string m_Filter;
    /// <summary>
    /// A freeform MVM expression that will be evaluated at this 
    /// point in the execution path to determine if the given 
    /// step of the charge generation should be executed. This filter 
    /// applies to table inclusion, field population and procedure 
    /// execution (the 3 basic units of work that a given row 
    /// in this table can accomplish). If the filter fails, the 
    /// row will end up being a no-op for this generated charge.
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
    /// Integer used to order the directives.  Lower numbered directivess are processed first.
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
    /// A unique identifier assigned to this GeneratedCharge when
    /// it is inserted into the databse.
    /// </summary>
    [MTDataMember(Description = "Unique identifier of the GeneratedCharge", Length = 40)]
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
