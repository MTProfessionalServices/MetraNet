using System;
using System.Collections.Generic;

namespace MetraTech.BusinessEntity.Core.Model
{
  public interface IEntityInstance
  {
    Guid Id { get; }
    string ExtensionName { get; set; }
    string EntityGroupName { get; set; }
    string EntityFullName { get; set; }
    string EntityName { get; set; }

    string AssemblyQualifiedTypeName { get; set; }
    List<IPropertyInstance> Properties { get; }
    PropertyInstance this[string propertyName] { get; }
    List<Association> Associations { get; }
    List<CollectionAssociation> CollectionAssociations { get; }

    string GetKey();
    object GetValue(string qualifiedPropertyName);
    void SetValue(object value, string qualifiedPropertyName);
    void AddCollectionAssociation(CollectionAssociation collectionAssociation);
    void AddAssociation(Association association);
  }
}
