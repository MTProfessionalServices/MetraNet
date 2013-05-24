using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Rule;
using MetraTech.Security.Crypto;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Criterion;
using NHibernate.Mapping;
using Property = MetraTech.BusinessEntity.DataAccess.Metadata.Property;
using MetaAttribute = MetraTech.BusinessEntity.DataAccess.Metadata.MetaAttribute;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Events
{
  public class BaseEventListener
  {
    #region Public Properties
    public virtual Configuration Configuration { get; set; }
    #endregion

    #region Internal Methods
    internal void CheckRequiredProperties(DataObject dataObject)
    {
      var missingProperties = new List<string>();
      var metaAttributes = 
        new List<MetaAttribute>()
          {
            new MetaAttribute() {Name = Property.RequiredAttribute, Value = "true"}
          };

      var requiredProperties = GetProperties(dataObject, metaAttributes);
      foreach(InternalProperty internalProperty in requiredProperties)
      {
        if (internalProperty.Value == null)
        {
          missingProperties.Add(internalProperty.Name);
        }
      }

      if (missingProperties.Count > 0)
      {
        throw new MissingRequiredPropertyException
          (String.Format("Found null values for the following required properties '{0}' on type '{1}' ",
                         String.Join(",", missingProperties.ToArray()),
                         dataObject.GetType().FullName));
      }
    }

    internal List<InternalProperty> GetProperties(DataObject dataObject, List<MetaAttribute> metaAttributes)
    {
      var internalProperties = new List<InternalProperty>();
      PersistentClass persistentClass = Configuration.GetClassMapping(dataObject.GetType().FullName);
      Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", dataObject.GetType().FullName));
      foreach(NHibernate.Mapping.Property property in persistentClass.PropertyIterator)
      {
        foreach(MetaAttribute metaAttribute in metaAttributes)
        {
          NHibernate.Mapping.MetaAttribute nhMetaAttribute = property.GetMetaAttribute(metaAttribute.Name);

          if (nhMetaAttribute == null) continue;
          if (nhMetaAttribute.Value.ToLower() != metaAttribute.Value.ToLower()) continue;
          // Don't create duplicates
          if (internalProperties.Find(i => i.Name == property.Name) != null) continue;

          var internalProperty = new InternalProperty();
          internalProperty.Name = property.Name;
          internalProperty.PropertyType = Property.GetPropertyType(property.Type.Name);
          internalProperty.Value = dataObject.GetValue(property.Name);
          internalProperties.Add(internalProperty);
        }
      }

      return internalProperties;
    }

    internal void FireBusinessRules(DataObject dataObject, ISession session, CRUDEvent crudEvent)
    {
      logger.Debug(String.Format("Firing business rules for entity '{0}' and event '{1}'", dataObject.GetType().FullName, crudEvent));

      try
      {
        List<RuleData> ruleDataList = RuleConfig.GetRules(dataObject.GetType().FullName, crudEvent);
        if (ruleDataList.Count == 0)
        {
          logger.Debug(String.Format("No business rules found for entity '{0}' and event '{1}'", dataObject.GetType().FullName, crudEvent));
          return;
        }

        foreach (RuleData ruleData in ruleDataList)
        {
          if (!ruleData.Enabled)
          {
            logger.Debug(String.Format("Rule implementation '{0}' is not enabled. Not firing rule for entity '{1}' and event '{2}",
                                       ruleData.AssemblyQualifiedTypeName, dataObject.GetType().FullName, crudEvent));
            continue;
          }

          Type type = Type.GetType(ruleData.AssemblyQualifiedTypeName);
          if (type == null)
          {
            throw new RuleException(String.Format("Cannot create rule type '{0}'",
                                                  ruleData.AssemblyQualifiedTypeName));
          }

          if (!type.IsSubclassOf(typeof(BusinessRule)))
          {
            throw new RuleException(String.Format("Cannot execute rule implementation '{0}' " +
                                                  "for entity '{1}' and event '{2}' " +
                                                  "because it does not inherit from '{3}'",
                                                  ruleData.AssemblyQualifiedTypeName,
                                                  dataObject.GetType().FullName, 
                                                  crudEvent,
                                                  typeof(BusinessRule).FullName));
          }

          var rule = Activator.CreateInstance(type) as IBusinessRule;
          Check.Require(rule != null, 
                        String.Format("Cannot instantiate rule implementation '{0}'", 
                                       ruleData.AssemblyQualifiedTypeName), 
                        SystemConfig.CallerInfo);

          logger.Debug(String.Format("Executing rule implementation '{0}'", ruleData.AssemblyQualifiedTypeName));

          // Execute
          List<ErrorObject> errors = rule.Execute(dataObject, session);

          if (errors != null && errors.Count > 0)
          {
            string message = String.Format("Cannot execute rule implementation '{0}' " +
                                           "for entity '{1}' and event '{2}' due to the following errors:",
                                           ruleData.AssemblyQualifiedTypeName,
                                           dataObject.GetType().FullName,
                                           crudEvent);
            throw new RuleException(message, errors, SystemConfig.CallerInfo);
          }
        }
      }
      catch(RuleException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message =
          String.Format("Cannot execute rule(s) for entity '{0}' and event '{1}'",
                        dataObject.GetType().FullName, crudEvent);
        throw new RuleException(message, e);
      }
    }

    /// <summary>
    ///    The properties on the compound BME table which are primary keys 
    ///    (legacy primary keys) in the underlying NetMeter table cannot have 
    ///    foreign key relationships to the NetMeter table.
    /// 
    ///    Hence, it's up to the code to check that the legacy primary key values 
    ///    exist in the NetMeter table.
    /// </summary>
    /// <param name="dataObject"></param>
    /// <param name="session"></param>
    internal void CheckCompoundLegacyPrimaryKeyValues(DataObject dataObject, ISession session)
    {
      if (!(dataObject is ICompound))
      {
        return;
      }

      string legacyTableName;
      Dictionary<Property, object> legacyPrimaryKeyValues = 
        dataObject.GetLegacyPrimaryKeyValues(out legacyTableName);

      var filterValues = new List<string>();
      ICriteria criteria = session.CreateCriteria(Name.GetLegacyFullName(dataObject.GetType().FullName));

      legacyPrimaryKeyValues.ForEach(kvp => 
        {
          filterValues.Add(kvp.Key.ColumnName + " = " + kvp.Value);
          if (kvp.Key.IsEnum)
          {
            criteria.Add(new EnumFilterCriteria(kvp.Key.Name, 
                                                kvp.Key.GetDbEnumValue((int)kvp.Value), 
                                                " = ", 
                                                kvp.Key.ColumnName,
                                                String.Empty));
          }
          else
          {
            criteria.Add(Expression.Eq(kvp.Key.Name, kvp.Value)); 
          }
          
        });

      IList results = criteria.List();

      if (results.Count == 0)
      {
        throw new DataAccessException
          (String.Format("Expected to find a row in table '{0}' with filter criteria: '{1}'",
                         legacyTableName, String.Join(", ", filterValues.ToArray())));
      }
    }

    internal void ProcessComputedProperties(DataObject dataObject, ISession session)
    {
      try
      {
        Entity entity = MetadataRepository.Instance.GetEntity(dataObject.GetType().FullName);
        if (entity == null || entity.EntityType == EntityType.History)
        {
          return;
        }

        List<Property> properties = entity.Properties.FindAll(p => p.IsComputed);

        foreach (Property property in properties)
        {
          if (String.IsNullOrEmpty(property.ComputationTypeName))
          {
            logger.Debug(String.Format("Compuation type has not been specified for computed property '{0}' and entity '{1}'",
                                       property.Name, dataObject.GetType().FullName));
            continue;
          }

          Type type = Type.GetType(property.ComputationTypeName);
          if (type == null)
          {
            throw new ComputedPropertyException
              (String.Format("Cannot create computation type '{0}'", property.ComputationTypeName));
          }

          if (!type.IsSubclassOf(typeof(ComputedProperty)))
          {
            throw new RuleException(String.Format("Cannot compute property '{0}' " +
                                                  "for entity '{1}' using computation type '{2}' " +
                                                  "because it does not inherit from '{3}'",
                                                  property.Name,
                                                  property.Entity.FullName,
                                                  property.ComputationTypeName,
                                                  typeof(ComputedProperty).FullName));
          }

          var computation = Activator.CreateInstance(type) as IComputedProperty;
          Check.Require(computation != null,
                        String.Format("Cannot instantiate computation type '{0}'",
                                       property.ComputationTypeName),
                        SystemConfig.CallerInfo);

          logger.Debug(String.Format("Computing property '{0}' " +
                                     "for entity '{1}' using computation type '{2}'.",
                                     property.Name,
                                     property.Entity.FullName,
                                     property.ComputationTypeName));

          // Execute
          List<ErrorObject> errors = computation.Compute(dataObject,
                                                         property.Name, 
                                                         session);

          if (errors != null && errors.Count > 0)
          {
            string message = String.Format("Error computing property '{0}' " +
                                           "for entity '{1}' using computation type '{2}'.",
                                           property.Name,
                                           property.Entity.FullName,
                                           property.ComputationTypeName);

            throw new ComputedPropertyException(message, errors, SystemConfig.CallerInfo);
          }
        }
      }
      catch(ComputedPropertyException)
      {
        throw;
      }
      catch (System.Exception e)
      {
        string message =
          String.Format("Failed computing properties for entity '{0}'",
                        dataObject.GetType().FullName);
        throw new ComputedPropertyException(message, e);
      }
     
    }

    /// <summary>
    ///   Convert all enum properties on dataObject to their corresponding database values (i.e. id_enum_data in t_enum_data)
    /// </summary>
    /// <param name="dataObject"></param>
    /// <param name="propertyNames"></param>
    /// <param name="state"></param>
    internal void ConvertEnumToDbValue(DataObject dataObject, string[] propertyNames, object[] state)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(dataObject.GetType().FullName);
      Check.Require(entity != null, String.Format("Cannot find entity of type '{0}'", dataObject.GetType().FullName));

      List<Property> enumProperties = entity.GetEnumProperties();

      foreach(Property property in enumProperties)
      {
        if (property.IsCompound) continue;

        object enumInstance = dataObject.GetValue(property.Name);
        if (enumInstance == null) continue;

        int index = System.Array.IndexOf(propertyNames, property.Name);
        Check.Require(index != -1 && state.Length > index,
                      String.Format("Cannot find property name '{0}' for entity '{1}' in metadata",
                                    property.Name, entity.FullName));

        int cSharpEnumValue = (int)state[index];
        Check.Require(cSharpEnumValue == (int) enumInstance,
                      String.Format("The value of property '{0}' for entity '{1}' in NHibernate state does not match the value in DataObject",
                                    property.Name, entity.FullName));

        int dbEnumValue = property.GetDbEnumValue(cSharpEnumValue);

        state[index] = dbEnumValue;
      }
    }

    /// <summary>
    ///   Convert all enum properties on dataObject from their database values (i.e. id_enum_data in t_enum_data)
    ///   to the corresponding C# enum value
    /// </summary>
    /// <param name="dataObject"></param>
    internal void ConvertDbValueToEnum(DataObject dataObject)
    {
      Entity entity = MetadataRepository.Instance.GetEntity(dataObject.GetType().FullName);
      Check.Require(entity != null, String.Format("Cannot find entity for type '{0}'", dataObject.GetType().FullName));

      List<Property> enumProperties = entity.GetEnumProperties();

      foreach (Property property in enumProperties)
      {
        if (property.IsCompound) continue;

        object enumInstance = dataObject.GetValue(property.Name);
        if (enumInstance == null) continue;

        object cSharpEnumValue = property.GetCSharpEnumValue((int) enumInstance);
        dataObject.SetValue(cSharpEnumValue, property.Name);
      }
    }

    internal void EncryptProperties(DataObject dataObject, string[] propertyNames, object[] state)
    {
      List<string> encryptedPropertyNames = 
        RuntimeMetadata.GetEncryptedPropertyNames(dataObject.GetType().FullName, Configuration);

      if (encryptedPropertyNames.Count == 0)
      {
        return;
      }

      var cryptoManager = new CryptoManager();

      foreach(string encryptedPropertyName in encryptedPropertyNames)
      {
        var plainText = dataObject.GetValue(encryptedPropertyName) as String;
        if (plainText == null)
        {
          continue;
        }

        int index = System.Array.IndexOf(propertyNames, encryptedPropertyName);
        Check.Require(index != -1, 
                      String.Format("Cannot find property name '{0}' for entity '{1}' in metadata",
                                    encryptedPropertyName, dataObject.GetType().FullName),
                      SystemConfig.CallerInfo);

        Check.Require(state.Length > index, 
                      String.Format("Cannot find property value '{0}' for entity '{1}'",
                                    encryptedPropertyName, dataObject.GetType().FullName),
                      SystemConfig.CallerInfo);

        string stateValue = state[index] as String;

        Check.Require(stateValue == plainText, 
                      String.Format("The value of property '{0}' for entity '{1}' in NHibernate state does not match the value in DataObject",
                                    encryptedPropertyName, dataObject.GetType().FullName),
                      SystemConfig.CallerInfo);

        string encryptedText = cryptoManager.Encrypt(CryptKeyClass.DatabasePassword, plainText);
        state[index] = encryptedText;
      }
    }
    
    internal void DecryptProperties(DataObject dataObject)
    {
      List<string> encryptedPropertyNames = 
        RuntimeMetadata.GetEncryptedPropertyNames(dataObject.GetType().FullName, Configuration);

      if (encryptedPropertyNames.Count == 0)
      {
        return;
      }

      var cryptoManager = new CryptoManager();

      foreach (string encryptedPropertyName in encryptedPropertyNames)
      {
        var encryptedText = dataObject.GetValue(encryptedPropertyName) as String;
        if (encryptedText == null)
        {
          continue;
        }

        string plainText = cryptoManager.Decrypt(CryptKeyClass.DatabasePassword, encryptedText);
        dataObject.SetValue(plainText, encryptedPropertyName);
      }
    }

    internal void UpdateState(DataObject dataObject, string[] propertyNames, object[] state)
    {
      int index = 0;
      foreach (string propertyName in propertyNames)
      {
        if (propertyName.ToLower() == "_version" || propertyName == Name.GetBusinessKeyPropertyName(dataObject.GetType().FullName))
        {
          index++;
          continue;
        }

        object value = state[index];
        if (value != null && value.GetType().Name == "PersistentGenericBag`1")
        {
          index++;
          continue;
        }

        state[index] = dataObject.GetValue(propertyName);
        index++;
      }
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BaseEventListener");
    #endregion
  }
  
}
