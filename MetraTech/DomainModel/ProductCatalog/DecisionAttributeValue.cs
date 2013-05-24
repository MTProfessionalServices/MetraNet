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
    /// Most decision attributes are defined by member variables
    /// within the Decision class.  However, to provide extensibility, 
    /// other decision attributes are held in a Dictionary(attributeName,DecisionAttributValue).
    /// This class defines the content of a DecisionAttributeValue.
    /// </summary>
  [DataContract]
  [Serializable]
  public class DecisionAttributeValue : BaseObject
  {

    #region HardCodedValue
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isHardCodedValueDirty = false;
    private string m_HardCodedValue;
    /// <summary>
    /// A hard coded value for this decision attribute.
    /// This value can be NULL.
    /// </summary>
    [MTDataMember(Description = "hard coded value for this decision attribute", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string HardCodedValue
    {
      get { return m_HardCodedValue; }
      set
      {
          m_HardCodedValue = value;
          isHardCodedValueDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsHardCodedValueDirty
    {
      get { return isHardCodedValueDirty; }
    }
    #endregion

    #region ColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isColumnNameDirty = false;
    private string m_ColumnName;
    /// <summary>
    /// A column name within the decision's parameter table where
    /// the value for this atttribute can be found.
    /// This value can be NULL.
    /// </summary>
    [MTDataMember(Description = "column name where decision attribute value can be found", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ColumnName
    {
      get { return m_ColumnName; }
      set
      {
          m_ColumnName = value;
          isColumnNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsColumnNameDirty
    {
      get { return isColumnNameDirty; }
    }
    #endregion
  }
}
