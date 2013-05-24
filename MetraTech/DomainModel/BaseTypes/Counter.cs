using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    [KnownType("KnownTypes")]
    public class Counter : BaseObject
    {
      #region ID
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isIDDirty = false;
      private int? m_ID;
      [MTDataMember(Description = "This is the internal identifier of the counter instance", Length = 40)]
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
      [MTDataMember(Description = "This is the name of the counter.", Length = 40)]
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
      [MTDataMember(Description = "This is the description of the counter", Length = 40)]
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

      #region LocalizedDescriptions
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isLocalizedDescriptionsDirty = false;
      private Dictionary<LanguageCode, string> m_LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      [MTDataMember(Description = "This is the collection of localized descriptions", Length = 40)]
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      public Dictionary<LanguageCode, string> LocalizedDescriptions
      {
        get 
        {
            if (m_LocalizedDescriptions == null)
            {
                m_LocalizedDescriptions = new Dictionary<LanguageCode, string>();
            }

            return m_LocalizedDescriptions; 
        }
        set
        {
          m_LocalizedDescriptions = value;
          isLocalizedDescriptionsDirty = true;
        }
      }
      [ScriptIgnore]
      public bool IsLocalizedDescriptionsDirty
      {
        get { return isLocalizedDescriptionsDirty; }
      }
      #endregion

      #region DisplayName
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      private bool isDisplayNameDirty = false;
      private string m_DisplayName;
      [MTDataMember(Description = "This is the default name for the counter.", Length = 40)]
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
      private Dictionary<LanguageCode, string> m_LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      [MTDataMember(Description = "This is the collection of localized display names for the counter.", Length = 40)]
      [DataMember(IsRequired = false, EmitDefaultValue = false)]
      public Dictionary<LanguageCode, string> LocalizedDisplayNames
      {
        get 
        {
            if (m_LocalizedDisplayNames == null)
            {
                m_LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
            }

            return m_LocalizedDisplayNames; 
        }
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
          return BaseObject.GetTypesFromAssemblyByAttribute(GENERATED_ASSEMBLY_NAME, typeof(CounterTypeMetadataAttribute));
      }

      #region Private Data
      [NonSerialized]
      private const string GENERATED_ASSEMBLY_NAME = "MetraTech.DomainModel.ProductCatalog.Generated";
      #endregion

    }
}
