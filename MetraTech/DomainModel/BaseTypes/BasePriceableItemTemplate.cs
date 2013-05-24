using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    [KnownType("KnownTypes")]
    public abstract class BasePriceableItemTemplate : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier of the priceable item template.", Length = 40)]
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
    [MTDataMember(Description = "This is the name of the priceable item template. This is unique for all priceable item templates.", Length = 40)]
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
    [MTDataMember(Description = "This is the display name of the priceable item template.", Length = 40)]
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
    [MTDataMember(Description = "This is a collection of localized display names for the priceable item template.", Length = 40)]
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

        #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "This is the description of the priceable item template.", Length = 40)]
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
    private bool isLocalizedDescriptionDirty = false;
        private Dictionary<LanguageCode, string> m_LocalizedDescriptions = null;
    [MTDataMember(Description = "This is a collection of localized descriptions for the priceable item template. The collection is keyed by values from the LanguageCode enumeration.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public Dictionary<LanguageCode, string> LocalizedDescriptions
    {
      get { return m_LocalizedDescriptions; }
      set
      {
          m_LocalizedDescriptions = value;
          isLocalizedDescriptionDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsLocalizedDescriptionDirty
    {
      get { return isLocalizedDescriptionDirty; }
    }
    #endregion

        #region PIKind
        protected PriceableItemKinds m_PIKind;
        [MTDataMember(Description = "This specifies the kind of the priceable item template", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public PriceableItemKinds PIKind
    {
            get { return GetPIKind(); }
            set { }
      }
        #endregion

        public static Type[] KnownTypes()
    {
            return BaseObject.GetTypesFromAssemblyByAttribute(GENERATED_ASSEMBLY_NAME, typeof(MTPriceableItemTemplateAttribute));
    }

        protected abstract PriceableItemKinds GetPIKind();

        #region Private Data
        [NonSerialized]
        private const string GENERATED_ASSEMBLY_NAME = "MetraTech.DomainModel.ProductCatalog.Generated";
    #endregion
    }
}
