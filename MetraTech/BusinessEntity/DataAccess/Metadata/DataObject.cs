using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Persistence;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
    /// <summary>
    /// Provides a base class for your objects which will be persisted to the database.
    /// Benefits include the addition of an Id property along with a consistent manner for comparing
    /// entities.
    /// 
    /// Since nearly all of the entities you create will have a type of Guid Id, this 
    /// base class leverages this assumption.  If you want an entity with a type other 
    /// than Guid, such as string, then use <see cref="DataObjectWithTypedId{IdT}" /> instead.
    /// </summary>
    [Serializable]
    [DataContract(IsReference = true)]
    [KnownType("GetKnownTypes")]
    public abstract class DataObject : DataObjectWithTypedId<Guid>, IDataObject
    {
      #region Public Properties
      [DataMember]
      public abstract int _Version { get; set; }
      [DataMember]
      public abstract DateTime? CreationDate { get; set; }
      [DataMember]
      public abstract DateTime? UpdateDate { get; set; }
      #endregion

      #region Public Methods
      public virtual BusinessKey GetBusinessKey()
      {
        PropertyInfo propertyInfo =
          GetType().GetProperties()
                .Where(p => Attribute.IsDefined(p, typeof(BusinessKeyAttribute), true)).SingleOrDefault();

        Check.Require(propertyInfo != null,
                      String.Format("Cannot find business key property for type '{0}'", GetType().FullName),
                      SystemConfig.CallerInfo);

        var businessKey = propertyInfo.GetValue(this, null) as BusinessKey;

        Check.Require(businessKey != null,
                      String.Format("The business key property for type '{0}' cannot be converted to 'BusinessKey'", GetType().FullName),
                      SystemConfig.CallerInfo);

        return businessKey;
      }

      /// <summary>
      ///   Implemented by derived classes
      /// </summary>
      //public virtual object Clone();

      /// <summary>
      ///   Implemented by derived classes to 
      ///    - set the businesskey properties for single ended associations
      ///    - set the id property for single ended associations
      ///    - null out the proxy for single ended associations
      /// </summary>
      public virtual void SetupRelationships()
      {
      }

      /// <summary>
      ///   Update the properties on this from the specified dataObject
      /// </summary>
      public virtual void CopyPropertiesFrom(DataObject dataObject)
      {
      }

      public virtual object GetValue(string propertyName)
      {
        object value = null;
        if (String.IsNullOrEmpty(propertyName))
        {
          return value;
        }

        PropertyInfo propertyInfo = GetType().GetProperty(propertyName);

        if (propertyInfo != null)
        {
          value = propertyInfo.GetValue(this, null);
        }

        return value;
      }

      public virtual void SetValue(object value, string propertyName)
      {
        Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty", SystemConfig.CallerInfo);

        PropertyInfo propertyInfo = GetType().GetProperty(propertyName);
        if (propertyInfo != null)
        {
          propertyInfo.SetValue(this, value, null);
        }
      }

      public virtual object GetBusinessKeyPropertyValue(string businessKeyPropertyName)
      {
        BusinessKey businessKey = GetBusinessKey();
        return businessKey.GetValue(businessKeyPropertyName);
      }

      public virtual void SetBusinessKeyPropertyValue(string businessKeyPropertyName, object value)
      {
        BusinessKey businessKey = GetBusinessKey();
        businessKey.SetValue(businessKeyPropertyName, value);
      }

      public virtual Dictionary<Guid, string> SetInternalBusinessKey()
      {
        var keyByPropertyName = new Dictionary<Guid, string>();

        Type type = GetType();

        Guid key;
        do
        {
          Entity entity = MetadataRepository.Instance.GetEntity(type.FullName);
          if (entity == null)
          {
            break;
          }

          // Set the internal key for all base types upto DataObject
          key = SetInternalBusinessKey(type, entity.BusinessKeyPropertyName);
          if (key != Guid.Empty)
          {
            keyByPropertyName.Add(key, entity.BusinessKeyPropertyName);
          }

          if (type.BaseType == typeof(DataObject) || type.BaseType == typeof(BaseHistory))
          {
            break;
          }

          type = type.BaseType;

        } while (true);

        return keyByPropertyName;
      }

      public virtual Guid GetInternalBusinessKey()
      {
        Type type = GetType();
        PropertyInfo businessKeyPropertyInfo = GetType().GetProperty(type.Name + "BusinessKey");
        Check.Require(businessKeyPropertyInfo != null, String.Format("Cannot find 'BusinessKey' property for type '{0}'", GetType().FullName));

        PropertyInfo internalKeyPropertyInfo = businessKeyPropertyInfo.PropertyType.GetProperty("InternalKey");
        if (internalKeyPropertyInfo == null)
        {
          return Guid.Empty;
        }

        // Set InternalKey
        object businessKey = businessKeyPropertyInfo.GetValue(this, null);
        Check.Require(businessKey != null, String.Format("Cannot obtain 'BusinessKey' instance for type '{0}'", GetType().FullName));

        Guid key = (Guid)internalKeyPropertyInfo.GetValue(businessKey, null);

        return key;
      }

      public virtual Dictionary<string, object> GetBusinessKeyPropertyNameValues()
      {
        BusinessKey businessKey = GetBusinessKey();
        return businessKey.GetPropertyNameValues();
      }

      public virtual bool IsBusinessKeyProperty(string propertyName)
      {
        bool isBusinessKeyProperty = false;

        BusinessKey businessKey = GetBusinessKey();

        List<PropertyInfo> propertyInfos = businessKey.GetProperties();

        foreach(PropertyInfo businessKeyPropertyInfo in propertyInfos)
        {
          if (businessKeyPropertyInfo.Name == propertyName)
          {
            isBusinessKeyProperty = true;
            break;
          }
        }

        return isBusinessKeyProperty;
      }

      public virtual Dictionary<string, string> GetBusinessKeyPropertyColumnNames()
      {
        BusinessKey businessKey = GetBusinessKey();
        return businessKey.GetPropertyColumnNames();
      }

      public virtual List<PropertyInstance> GetForeignKeyData()
      {
        Entity entity = MetadataRepository.Instance.GetEntity(GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", GetType().FullName));

        var foreignKeyData = new List<PropertyInstance>();

        List<Property> foreignKeyProperties = entity.GetForeignKeyProperties(true);
        foreach (Property property in foreignKeyProperties)
        {
          object value = GetValue(property.Name);
          if (value != null && value is Guid && (Guid)value != Guid.Empty)
          {
            foreignKeyData.Add(new PropertyInstance(property.Name, typeof(Guid).AssemblyQualifiedName, false, value));
          }
        }

        return foreignKeyData;
      }

      public virtual void SetForeignKeyData(List<PropertyInstance> foreignKeyData)
      {
        foreach (PropertyInstance propertyInstance in foreignKeyData)
        {
          SetValue(propertyInstance.Value, propertyInstance.Name);
        }
      }

      public static Type[] GetKnownTypes()
      {
        Check.Require(dataObjectKnownTypes != null, "dataObject known types has not been initialized");
        return dataObjectKnownTypes.ToArray();
      }

      public override string ToString()
      {
        return String.Format("DataObject: Type = '{0}', Id = '{1}'", GetType().FullName, Id);
      }
      #endregion

      #region Internal Methods
      static DataObject()
      {
        InitializeKnownTypes();
      }

      /// <summary>
      ///   Return a dictionary of column name to value pairs for each legacy primary
      ///   key for this compound data object.
      /// </summary>
      /// <param name="legacyTableName"></param>
      /// <returns></returns>
      protected internal virtual Dictionary<Property, object> GetLegacyPrimaryKeyValues(out string legacyTableName)
      {
        Check.Require(this is ICompound, "'GetLegacyPrimaryKeyValues' can only be called on Compounds");
        var legacyPrimaryKeyValues = new Dictionary<Property, object>();

        Entity entity = MetadataRepository.Instance.GetEntity(GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", GetType().FullName));
        var compoundEntity = entity as CompoundEntity;
        Check.Require(compoundEntity != null, String.Format("Expected entity '{0}' to be a compound", entity.FullName));

        legacyTableName = compoundEntity.LegacyTableName;

        List<Property> legacyPrimaryKeyProperties = compoundEntity.GetLegacyPrimaryKeyProperties();

        foreach(Property property in legacyPrimaryKeyProperties)
        {
          object propertyValue = GetValue(property.Name);
          Check.Require(propertyValue != null, 
                        String.Format("Legacy primary key property '{0}' for compound entity '{1}' cannot have a null value",
                                      property.Name, entity.FullName));
          legacyPrimaryKeyValues.Add(property, propertyValue);
        }

        return legacyPrimaryKeyValues;
      }

      
      #endregion

      #region Internal Properties
      internal static Type[] BusinessKeyKnownTypes
      {
        get { return businessKeyKnownTypes.ToArray(); }
      }

      internal static Type[] EnumKnownTypes
      {
        get { return enumKnownTypes.ToArray(); }
      }
      #endregion

      #region Protected Methods
      protected int? ConvertCSharpEnumToDbValue(object cSharpEnumInstance, string propertyName)
      {
        if (cSharpEnumInstance == null)
        {
          return null;
        }

        Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty");

        Entity entity = MetadataRepository.Instance.GetEntity(GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", GetType().FullName));
        
        return entity.GetDbEnumValue(propertyName, (int)cSharpEnumInstance);
      }

      protected object ConvertDbValueToCSharpEnum(int? dbEnumValue, string propertyName)
      {
        if (dbEnumValue == null)
        {
          return null;
        }

        Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty");

        Entity entity = MetadataRepository.Instance.GetEntity(GetType().FullName);
        Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", GetType().FullName));

        return entity.GetCSharpEnumInstance(propertyName, dbEnumValue.Value);
      }
      #endregion

      #region Private Methods
      private static void InitializeKnownTypes()
      {
        dataObjectKnownTypes = new List<Type>();
        businessKeyKnownTypes = new List<Type>();
        enumKnownTypes = new List<Type>();

        List<string> entityAssemblyNames = Name.GetEntityAssemblyNames();
        
        foreach (string assemblyName in entityAssemblyNames)
        {
          Assembly assembly = LoadAssembly(assemblyName);
          
          if (assembly == null)
          {
            continue;
          }

          try
          {
            Type[] types = assembly.GetTypes();
            
            foreach (Type type in types)
            {
              dataObjectKnownTypes.Add(type);

              if (type.GetMethod("GetKnownTypes") != null)
              {
                Type[] entityContainedTypes =
                  type.InvokeMember("GetKnownTypes",
                                      BindingFlags.InvokeMethod,
                                      null,
                                      type,
                                      new object[0]) as Type[];

                if (entityContainedTypes == null) continue;

                foreach (Type containedType in entityContainedTypes)
                {
                  if (containedType.IsSubclassOf(typeof(BusinessKey)))
                  {
                    businessKeyKnownTypes.Add(containedType);
                  }
                  else if (containedType.IsEnum)
                  {
                    enumKnownTypes.Add(containedType);
                  }
                  else
                  {
                    logger.Warn(String.Format("Cannot recognize type '{0}' as either BusinessKey or Enum", 
                                                containedType.ToString()));
                  }
                }
              }
            }
          }
          catch (ReflectionTypeLoadException rtle)
          {
            logger.Warn(String.Format("Cannot load types from assembly {0}:", assemblyName));
            foreach (System.Exception exception in rtle.LoaderExceptions)
            {
              logger.Warn(String.Format("Exception loading type: {0}", exception.Message));
            }
          }
        }

        // Hack: Add ARItem and ARSubItem 
        // This will be fixed later
        /*string arItem = "MetraTech.DomainModel.BaseTypes.AR.ARItem, MetraTech.DomainModel.BaseTypes";
        Type arType = Type.GetType(arItem);
        Check.Require(arType != null, String.Format("Cannot find type '{0}'", arItem));
        dataObjectKnownTypes.Add(arType);
        */
        //string arSubItem = "MetraTech.DomainModel.BaseTypes.AR.ARSubItem, MetraTech.DomainModel.BaseTypes";
        //Type arType = Type.GetType(arSubItem);
        //Check.Require(arType != null, String.Format("Cannot find type '{0}'", arSubItem));
        //dataObjectKnownTypes.Add(arType);
      }

      private Guid SetInternalBusinessKey(Type type, string businessKeyPropertyName)
      {

        PropertyInfo businessKeyPropertyInfo = type.GetProperty(businessKeyPropertyName);
        Check.Require(businessKeyPropertyInfo != null, String.Format("Cannot find 'BusinessKey' property for type '{0}'", GetType().FullName));

        var businessKey = businessKeyPropertyInfo.GetValue(this, null) as BusinessKey;
        Check.Require(businessKey != null, String.Format("Cannot obtain 'BusinessKey' instance for type '{0}'", GetType().FullName));

        var key = Guid.Empty;
        if (businessKey.IsInternal())
        {
          key = Guid.NewGuid();
          businessKey.SetInternalKey(key);
        }
       
        return key;
      }

      private static Assembly LoadAssembly(string assemblyName)
      {
        Assembly result = null;
        string localName = assemblyName;
        bool tryLoadWithPrefix = false;

        //Load assembly if his name not contains custom prefix.
        try 
        {
          result = Assembly.Load(localName);
          Check.Require(result != null, String.Format("Cannot load assembly '{0}'", localName));
        }
        catch (FileLoadException)
        {
          logger.Warn(String.Format("File that was found could not be loaded assembly '{0}'", localName));
        }
        catch
        {
          // Since we're getting the assembly names based on the directory structure 
          // it's possible that some directories may not correspond to a currently valid entity assembly
          tryLoadWithPrefix = true;
        }

        //Load assembly if his name contains custom prefix.
        if (tryLoadWithPrefix)
        {
          try
          {
            localName = string.Concat(BMEConstants.BMERootNameSpace, ".", localName);
            result = Assembly.Load(localName);
            Check.Require(result != null, String.Format("Cannot load assembly '{0}'", localName));
          }
          catch (FileLoadException)
          {
            logger.Warn(String.Format("File that was found could not be loaded assembly '{0}'", localName));
          }
          catch
          {
            logger.Warn(String.Format("Cannot load assembly '{0}'", localName));
          }
        }

        return result;
      }
      #endregion

      #region Data

      private static List<Type> dataObjectKnownTypes;
      private static List<Type> businessKeyKnownTypes;
      private static List<Type> enumKnownTypes;

      #region Data
      private static readonly ILog logger = LogManager.GetLogger("DataObject");
      #endregion
      #endregion

    }


    /// <summary>
    /// For a discussion of this object, see 
    /// http://devlicio.us/blogs/billy_mccafferty/archive/2007/04/25/using-equals-gethashcode-effectively.aspx
    /// </summary>
    [Serializable]
    [DataContract(IsReference = true)]
    public abstract class DataObjectWithTypedId<IdT> : BaseBmeObject, IDataObjectWithTypedId<IdT>
    {
        #region IDataObjectWithTypedId Members

        /// <summary>
        /// Id may be of type string, int, custom type, etc.
        /// It's virtual to allow NHibernate-backed objects to be lazily loaded.
        /// </summary>
        [DataMember]
        public virtual IdT Id { get; set; }

        /// <summary>
        /// Transient objects are not associated with an item already in storage.  For instance,
        /// a Customer is transient if its Id is 0.  It's virtual to allow NHibernate-backed 
        /// objects to be lazily loaded.
        /// </summary>
        public virtual bool IsTransient() {
            return Id == null || Id.Equals(default(IdT));
        }

        #endregion

        #region Entity comparison support

        /// <summary>
        /// The property getter for BusinessKeyProperties should ONLY compare the properties which make up 
        /// the "domain businessKey" of the object.
        /// 
        /// If you choose NOT to override this method (which will be the most common scenario), 
        /// then you should decorate the appropriate property(s) with [BusinessKey] and they 
        /// will be compared automatically.  This is the preferred method of managing the domain
        /// businessKey of entity objects.
        /// </summary>
        /// <remarks>
        /// This ensures that the entity has at least one property decorated with the 
        /// [BusinessKey] attribute.
        /// </remarks>
        protected override Dictionary<string, IEnumerable<PropertyInfo>> GetTypeSpecificBusinessKeyProperties()
        {
          var businessKeyPropertyInfoMap = new Dictionary<string, IEnumerable<PropertyInfo>>();

          // This will pick up all [BusinessKey] properties in the inheritance hierarchy
          List<PropertyInfo> businessKeyProperties = 
            GetType().GetProperties()
                     .Where(p => Attribute.IsDefined(p, typeof(BusinessKeyAttribute), true)).ToList();

          Check.Require(businessKeyProperties.Count != 0,
                        String.Format("Cannot find business key property for type '{0}'", GetType().FullName),
                        SystemConfig.CallerInfo);

          foreach(PropertyInfo businessKeyPropertyInfo in businessKeyProperties)
          {
            var businessKey = businessKeyPropertyInfo.GetValue(this, null) as BusinessKey;

            Check.Require(businessKey != null,
                          String.Format("The business key property for type '{0}' cannot be converted to 'BusinessKey'", 
                                        GetType().FullName));

            Check.Require(!businessKeyPropertyInfoMap.ContainsKey(businessKeyPropertyInfo.Name),
                          String.Format("Found duplicate business key property with name '{0}' for type '{1}'", 
                                        businessKeyPropertyInfo.Name, GetType().FullName));

            businessKeyPropertyInfoMap.Add(businessKeyPropertyInfo.Name, businessKey.GetProperties());
          }


          return businessKeyPropertyInfoMap;
        }

        public override bool Equals(object obj) {
            DataObjectWithTypedId<IdT> compareTo = obj as DataObjectWithTypedId<IdT>;

            if (ReferenceEquals(this, compareTo))
                return true;

            if (compareTo == null || !GetType().Equals(compareTo.GetTypeUnproxied()))
                return false;

            if (HasSameNonDefaultIdAs(compareTo))
                return true;

            // Since the Ids aren't the same, both of them must be transient to 
            // compare domain businessKeys; because if one is transient and the 
            // other is a persisted entity, then they cannot be the same object.
            return IsTransient() && compareTo.IsTransient() &&
                HasSameObjectBusinessKeyAs(compareTo);
        }

        public override int GetHashCode() {
            if(cachedHashcode.HasValue)
                return cachedHashcode.Value;

            if (IsTransient()) {
                cachedHashcode = base.GetHashCode();
            }
            else {
                unchecked {
                    // It's possible for two objects to return the same hash code based on 
                    // identically valued properties, even if they're of two different types, 
                    // so we include the object's type in the hash calculation
                    int hashCode = GetType().GetHashCode();
                    cachedHashcode = (hashCode * HASH_MULTIPLIER) ^ Id.GetHashCode();
                }
            }

            return cachedHashcode.Value;
        }

        /// <summary>
        /// Returns true if self and the provided entity have the same Id values 
        /// and the Ids are not of the default Id value
        /// </summary>
        private bool HasSameNonDefaultIdAs(DataObjectWithTypedId<IdT> compareTo) {
            return !IsTransient() &&
                   !compareTo.IsTransient() &&
                   Id.Equals(compareTo.Id);
        }

        private int? cachedHashcode;

        /// <summary>
        /// To help ensure hashcode uniqueness, a carefully selected random number multiplier 
        /// is used within the calculation.  Goodrich and Tamassia's Data Structures and
        /// Algorithms in Java asserts that 31, 33, 37, 39 and 41 will produce the fewest number
        /// of collissions.  See http://computinglife.wordpress.com/2008/11/20/why-do-hash-functions-use-prime-numbers/
        /// for more information.
        /// </summary>
        private const int HASH_MULTIPLIER = 31;

        #endregion
    }
}
