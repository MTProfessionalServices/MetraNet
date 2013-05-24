using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using System.Reflection;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
    [DataContract]
    [Serializable]
    [KnownType("KnownTypes")]
    public abstract class BaseRateSchedule : BaseObject
    {
        #region ID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isIDDirty = false;
    private int? m_ID;
    [MTDataMember(Description = "This is the internal identifier for the rate schedule.", Length = 40)]
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

        #region ParameterTableID
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterTableIDDirty = false;
    private int m_ParameterTableID;
    [MTDataMember(Description = "This is the internal identifier of the parameter table to which this rate schedule applies.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int ParameterTableID
    {
      get { return m_ParameterTableID; }
      set
      {
          m_ParameterTableID = value;
          isParameterTableIDDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterTableIDDirty
    {
      get { return isParameterTableIDDirty; }
    }
    #endregion

        #region ParameterTableName
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isParameterTableNameDirty = false;
    private string m_ParameterTableName;
    [MTDataMember(Description = "This is the name of the parameter table to which the rate schedule applies.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ParameterTableName
    {
      get { return m_ParameterTableName; }
      set
      {
          m_ParameterTableName = value;
          isParameterTableNameDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsParameterTableNameDirty
    {
      get { return isParameterTableNameDirty; }
    }
    #endregion

        #region EffectiveDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isEffectiveDateDirty = false;
    private ProdCatTimeSpan m_EffectiveDate;
    [MTDataMember(Description = "This is the effective date for the rate schedule.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public ProdCatTimeSpan EffectiveDate
    {
      get { return m_EffectiveDate; }
      set
      {
          m_EffectiveDate = value;
          isEffectiveDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsEffectiveDateDirty
    {
      get { return isEffectiveDateDirty; }
    }
    #endregion

        #region EffectiveDate Value Display Name
    public string EffectiveDateValueDisplayName
    {
      get
      {
        return GetDisplayName(this.EffectiveDate);
      }
      set
      {
        this.EffectiveDate = ((ProdCatTimeSpan)(GetEnumInstanceByDisplayName(typeof(ProdCatTimeSpan), value)));
      }
    }
    #endregion

        #region Description
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDescriptionDirty = false;
    private string m_Description;
    [MTDataMember(Description = "This is a description of the rate schedule", Length = 40)]
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

        public static Type[] KnownTypes()
        {
            List<Type> knownTypes = new List<Type>();

            //knownTypes.AddRange(BaseObject.GetTypesFromAssemblyByAttribute(PRODUCT_CATALOG_GENERATED_ASSEMBLY, typeof(MTRateScheduleAttribute)));
            Type[] rateEntryTypes = BaseObject.GetTypesFromAssemblyByAttribute(PRODUCT_CATALOG_GENERATED_ASSEMBLY, typeof(MTRateEntryAttribute));

            Type rsType = typeof(RateSchedule<,>);

            foreach (Type rateEntryType in rateEntryTypes)
            {
                string defaultRateEntryTypeName = rateEntryType.AssemblyQualifiedName.Replace("RateEntry", "DefaultRateEntry");
                Type defaultRateEntryType = Type.GetType(defaultRateEntryTypeName);

                Type rateScheduleType = rsType.MakeGenericType(new Type[] { rateEntryType, defaultRateEntryType });
                knownTypes.Add(rateScheduleType);
            }

            return knownTypes.ToArray();
        }
    }

    [DataContract]
    [Serializable]
    public class RateSchedule<R, D> : BaseRateSchedule
    {
        #region RateEntries
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isRateEntriesDirty = false;
        private List<R> m_RateEntries = new List<R>();
    [MTDataMember(Description = "This is the collection of rate entries in the rate schedule.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public List<R> RateEntries
    {
      get 
      {
          if (m_RateEntries == null)
          {
              m_RateEntries = new List<R>();
          }
          
          return m_RateEntries; 
      }
      set
      {
          m_RateEntries = value;
          isRateEntriesDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsRateEntriesDirty
    {
      get { return isRateEntriesDirty; }
    }
    #endregion

        #region DefaultRateEntry
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isDefaultRateEntryDirty = false;
    private D m_DefaultRateEntry;
    [MTDataMember(Description = "This property stores the default rate entry for the rate schedule.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public D DefaultRateEntry
    {
      get { return m_DefaultRateEntry; }
      set
      {
          m_DefaultRateEntry = value;
          isDefaultRateEntryDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsDefaultRateEntryDirty
    {
      get { return isDefaultRateEntryDirty; }
    }
    #endregion
    }
}