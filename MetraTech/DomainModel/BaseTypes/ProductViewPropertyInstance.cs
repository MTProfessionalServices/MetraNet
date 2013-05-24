using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
  /*
                SELECT
                prop.id_prod_view_prop as 'ID'
                prop.nm_name as 'NAME',
                prop.nm_column_name as 'COLUMN_NAME',
                prop.nm_data_type as 'DATA_TYPE',
                prop.nm_space as 'NM_SPACE',
                prop.nm_enum as 'NM_ENUM'
                FROM t_prod_view_prop prop,
                t_prod_view pv
                WHERE
                prop.nm_column_name LIKE 'c[_]%'
                and pv.id_prod_view = prop.id_prod_view
                and pv.nm_table_name = @tableName
  */
    [DataContract]
    [Serializable]
    public class ProductViewPropertyInstance   : BaseObject
    {
      #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier of the product view property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int? ID
    {
      get { return m_ID; }
      set
      {
          m_ID = value;
          isIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIDDirty
    {
      get { return isIDDirty; }
    }
    #endregion

      #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the product view property. This is unique across all product view properties in the same product view.", Length = 40)]
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

      #region ColumnName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isColumnNameDirty = false;
    private string m_ColumnName;
    [MTDataMember(Description = "This is the column name of the product view property.", Length = 40)]
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

      #region DataType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDataTypeDirty = false;
    private string m_DataType;
    [MTDataMember(Description = "This is the data type of the product view property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DataType
    {
      get { return m_DataType; }
      set
      {
        m_DataType = value;
        isDataTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDataTypeDirty
    {
      get { return isDataTypeDirty; }
    }
    #endregion

      #region NmSpace
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNmSpaceDirty = false;
    private string m_NmSpace;
    [MTDataMember(Description = "This is the enum name space of the product view property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string NmSpace
    {
      get { return m_NmSpace; }
      set
      {
        m_NmSpace = value;
        isNmSpaceDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNmSpaceDirty
    {
      get { return isNmSpaceDirty; }
    }
    #endregion

      #region NmEnum
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNmEnumDirty = false;
    private string m_NmEnum;
    [MTDataMember(Description = "This is the enum of the product view property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string NmEnum
    {
      get { return m_NmEnum; }
      set
      {
        m_NmEnum = value;
        isNmEnumDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNmEnumDirty
    {
      get { return isNmEnumDirty; }
    }
    #endregion

      #region NmEnumData
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNmEnumDataDirty = false;
    private string m_NmEnumData;
    [MTDataMember(Description = "This is the enum data of the product view property. It is used to look up the localized named for the product view property.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string NmEnumData
    {
      get { return m_NmEnumData; }
      set
      {
        m_NmEnumData = value;
        isNmEnumDataDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsNmEnumDataDirty
    {
      get { return isNmEnumDataDirty; }
    }
    #endregion

      #region LocalizedDisplayNames
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isLocalizedDisplayNamesDirty = false;
    private Dictionary<LanguageCode, string> m_LocalizedDisplayNames = null;
    [MTDataMember(Description = "This is a collection of localized display names for the product view.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDisplayNames
    {
      get { return m_LocalizedDisplayNames; }
      set
      {
        m_LocalizedDisplayNames = value;
        isLocalizedDisplayNamesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDisplayNamesDirty
    {
      get { return isLocalizedDisplayNamesDirty; }
    }
    #endregion

    }
}
