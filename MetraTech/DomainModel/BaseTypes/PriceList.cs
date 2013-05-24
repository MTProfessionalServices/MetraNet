using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    public class PriceList : BaseObject
    {
        #region ID
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isIDDirty = false;
        private int? m_ID;
        [MTDataMember(Description = "This is the internal identifier of the pricelist.", Length = 40)]
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
        [MTDataMember(Description = "This is the name for the pricelist", Length = 40)]
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
        [MTDataMember(Description = "This is the description of the pricelist.", Length = 40)]
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
        private Dictionary<LanguageCode, string> m_LocalizedDescriptions = null;
        [MTDataMember(Description = "This is a collection of localized description for the pricelist", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public Dictionary<LanguageCode, string> LocalizedDescriptions
        {
            get { return m_LocalizedDescriptions; }
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

        #region Currency
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private bool isCurrencyDirty = false;
        private SystemCurrencies m_Currency;
        [MTDataMember(Description = "This specifies the currency for the pricelist.", Length = 40)]
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        public SystemCurrencies Currency
        {
            get { return m_Currency; }
            set
            {
                m_Currency = value;
                isCurrencyDirty = true;
            }
        }
        [ScriptIgnore]
        public bool IsCurrencyDirty
        {
            get { return isCurrencyDirty; }
        }
        #endregion

        #region Currency Value Display Name
        public string CurrencyValueDisplayName
        {
            get
            {
                return GetDisplayName(this.Currency);
            }
            set
            {
                this.Currency = ((SystemCurrencies)(GetEnumInstanceByDisplayName(typeof(SystemCurrencies), value)));
            }
        }
        #endregion

        #region ParameterTables
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterTablesDirty = false;
        private List<PCIdentifier> m_ParameterTables = null;
        [MTDataMember(Description = "This is the collection of parameter tables on the pricelist", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<PCIdentifier> ParameterTables
    {
      get { return m_ParameterTables; }
      set
      {
          m_ParameterTables = value;
          isParameterTablesDirty = true;
      }
    }
        [ScriptIgnore]
        public bool IsParameterTablesDirty
    {
      get { return isParameterTablesDirty; }
    }
    #endregion

    }
}
