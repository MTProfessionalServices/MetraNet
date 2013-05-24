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
    [DataContract]
    [Serializable]
    [KnownType("KnownTypes")]
    public class ProductViewNameInstance : BaseObject
    {
      #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier of the product view.", Length = 40)]
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

      #region TableName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isTableNameDirty = false;
    private string m_TableName;
    [MTDataMember(Description = "This is the name of the product view table. This is unique across all product views.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string TableName
    {
      get { return m_TableName; }
      set
      {
        m_TableName = value;
        isTableNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsTableNameDirty
    {
      get { return isTableNameDirty; }
    }
    #endregion

      #region Name
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isNameDirty = false;
    private string m_Name;
    [MTDataMember(Description = "This is the name of the product view. This is unique across all product views.", Length = 40)]
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

      #region DisplayName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDisplayNameDirty = false;
    private string m_DisplayName;
    [MTDataMember(Description = "This is the display name of the product view.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string DisplayName
    {
      get { return m_DisplayName; }
      set
      {
          m_DisplayName = value;
          isDisplayNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDisplayNameDirty
    {
      get { return isDisplayNameDirty; }
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

        public static Type[] KnownTypes()
        {
          return BaseObject.GetTypesFromAssemblyByAttribute(GENERATED_ASSEMBLY_NAME, typeof(MTProductViewAttribute));
        }

        #region Private Data
        [NonSerialized]
        private const string GENERATED_ASSEMBLY_NAME = "MetraTech.DomainModel.ProductCatalog.Generated";
        #endregion
    }
}
