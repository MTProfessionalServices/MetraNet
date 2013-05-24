using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [KnownType("GetKnownTypes")]
  [DataContract(IsReference = true)]
  [Serializable]
  public class EntityInstance
  {
    #region Public Methods
    public EntityInstance()
    {
      Id = Guid.Empty;
      Properties = new List<PropertyInstance>();
      Associations = new List<Association>();
      CollectionAssociations = new List<CollectionAssociation>();
      ForeignKeyProperties = new List<PropertyInstance>();
    }

    public object GetValue(string qualifiedPropertyName)
    {
      Check.Require(!String.IsNullOrEmpty(qualifiedPropertyName),
                    "qualifiedPropertyName cannot be null or empty",
                    SystemConfig.CallerInfo);

      PropertyInstance propertyInstance = this[qualifiedPropertyName];
      Check.Require(propertyInstance != null, 
                    String.Format("Cannot find PropertyInstance for qualifiedPropertyName '{0}'", qualifiedPropertyName),
                    SystemConfig.CallerInfo);

      return propertyInstance.Value;
    }

    public void SetValue(object value, string qualifiedPropertyName)
    {
      Check.Require(!String.IsNullOrEmpty(qualifiedPropertyName),
                    "qualifiedPropertyName cannot be null or empty",
                    SystemConfig.CallerInfo);

      PropertyInstance propertyInstance = this[qualifiedPropertyName];
      Check.Require(propertyInstance != null,
                    String.Format("Cannot find PropertyInstance for qualifiedPropertyName '{0}'", qualifiedPropertyName),
                    SystemConfig.CallerInfo);

      propertyInstance.Value = value;
    }

    public List<PropertyInstance> GetBusinessKeyProperties()
    {
      return Properties.Where(propertyInstance => propertyInstance.IsBusinessKey).ToList();
    }

    public string GetKey()
    {
      if (Id != Guid.Empty)
      {
        return Id.ToString();
      }

      StringBuilder businessKey = new StringBuilder();

      var businessKeyProperties = Properties.Where(p => p.IsBusinessKey).ToList();
      foreach(var businessKeyProperty in businessKeyProperties)
      {
        businessKey.Append(businessKeyProperty.Value);
      }

      Check.Ensure(!String.IsNullOrEmpty(businessKey.ToString()), "businessKey cannot be null or empty", SystemConfig.CallerInfo);
      return businessKey.ToString();
    }

    public void AddAssociation(Association association)
    {
      Check.Require(association != null, "association cannot be null", SystemConfig.CallerInfo);
      Check.Require(association.EntityInstance != null, "cannot add a association with a null EntityInstance", SystemConfig.CallerInfo);


      association.EntityInstance.Associations.Add
        (new Association()
           {
             EntityInstance = this,
             EntityTypeName = EntityFullName,
             PropertyName = association.OtherPropertyName
           });

      Associations.Add(association);
    }

    public void AddCollectionAssociation(CollectionAssociation collectionAssociation)
    {
      Check.Require(collectionAssociation != null, "collectionAssociation cannot be null", SystemConfig.CallerInfo);
      Check.Require(collectionAssociation.EntityInstances.Count != 0, "cannot add a collectionAssociation with no EntityInstances", SystemConfig.CallerInfo);
      
      foreach(EntityInstance entityInstance in collectionAssociation.EntityInstances)
      {
        entityInstance.Associations.Add
          (new Association()
             {
               EntityInstance = this,
               EntityTypeName = EntityFullName,
               PropertyName = collectionAssociation.OtherPropertyName
             });
      }

      CollectionAssociations.Add(collectionAssociation);
    }

    public static Type[] GetKnownTypes()
    {
      return DataObject.EnumKnownTypes;
    } 

    public DataObject CreateDataObject()
    {
      var dataObject = Activator.CreateInstance(Type.GetType(AssemblyQualifiedTypeName, true)) as DataObject;
      Check.Require(dataObject != null, String.Format("Cannot create DataObject instance from type '{0}'", AssemblyQualifiedTypeName));

      dataObject.Id = Id;

      foreach(PropertyInstance propertyInstance in Properties)
      {
        if (propertyInstance.IsBusinessKey) continue;
        dataObject.SetValue(propertyInstance.Value, propertyInstance.Name);
      }

      string businessKeyAssemblyQualifiedName = Name.GetEntityBusinessKeyAssemblyQualifiedName(EntityFullName);

      // Create the BusinessKey object
      var businessKey =
        Activator.CreateInstance(Type.GetType(businessKeyAssemblyQualifiedName, true)) as BusinessKey;
      Check.Require(businessKey != null, String.Format("Cannot create BusinessKey instance from type '{0}'", businessKeyAssemblyQualifiedName));

      // Populate it with the business key properties
      List<PropertyInstance> businessKeyProperties = GetBusinessKeyProperties();
      foreach(PropertyInstance propertyInstance in businessKeyProperties)
      {
        businessKey.SetValue(propertyInstance.Name, propertyInstance.Value);
      }

      // Set the 'BusinessKey' property on dataObject
      dataObject.SetValue(businessKey, Name.GetBusinessKeyPropertyName(dataObject.GetType().FullName));

      dataObject.SetForeignKeyData(ForeignKeyProperties);

      return dataObject;
    }

    #endregion

    #region Public Properties
    public PropertyInstance this[string propertyName]
    {
      get
      {
        return Properties.Where(p => p.Name == propertyName).SingleOrDefault();
      }
    }

    [DataMember]
    public virtual Guid Id { get; set; }
    [DataMember]
    public virtual string ExtensionName { get; set; }
    [DataMember]
    public virtual string EntityGroupName { get; set; }
    [DataMember]
    public virtual string EntityFullName { get; set; }
    [DataMember]
    public virtual string EntityName { get; set; }
    [DataMember]
    public virtual string AssemblyQualifiedTypeName { get; set; }
    [DataMember]
    public virtual List<PropertyInstance> Properties { get; set; }
    [DataMember]
    public virtual List<Association> Associations { get; set; }
    [DataMember]
    public virtual List<CollectionAssociation> CollectionAssociations { get; set; }
    [DataMember]
    public virtual List<PropertyInstance> ForeignKeyProperties { get; set; }
    #endregion
  }

}
