using System;
using System.Linq;
using System.Collections.Generic;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NUnit.Framework;

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  public sealed class SaveRestoreOrderMetadata : DataAccessTestCase
  {
    public SaveRestoreOrderMetadata()
    {
      TenantName = SystemConfig.DefaultTenant;
      CleanTenantDir = false;
    }

    public override ICollection<Entity> LoadEntities()
    {
      return MetadataAccess.Instance.GetEntities(TenantName);
    }

    public override bool UpdateEntities(ICollection<Entity> entities)
    {
      // Find Invoice
      Entity order = MetadataAccess.Instance.GetEntity("MetraTech", "MetraTech.BusinessEntity.OrderManagement.Order");
      Check.Require(order != null, "Expected to find entity with class name 'Order'", SystemConfig.CallerInfo);

      // Find ReferenceNumber Property
      Property property = order["ReferenceNumber"];
      Check.Require(property != null, "Expect to find property with name 'ReferenceNumber' on entity 'order'", SystemConfig.CallerInfo);
      // Update Label
      property.Label = "ReferenceNumber Label";

      Random random = new Random();
      // Add new property
      string propertyName = "Property3" + random.Next();
      order.Properties.Add(new Property(order) { Name = propertyName, QualifiedName = new QualifiedName("System.Double", TenantName) });

      // Add new enum property
      string enumPropertyName = "EnumProperty" + random.Next();
      order.Properties.Add(new Property(order)
                             {
                               Name = enumPropertyName,
                               QualifiedName =
                                 new QualifiedName("MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek",
                                                   "MetraTech.DomainModel.Enums.Generated",
                                                   TenantName)
                             });

      CreateEntityMetadataAndSchema(TenantName, new List<Entity> { order });

      // Retrieve the order and check that the new properties exist
      order = MetadataAccess.Instance.GetEntity("MetraTech", "MetraTech.BusinessEntity.OrderManagement.Order");
      Check.Require(order != null, "Expected to find entity with class name 'Order'", SystemConfig.CallerInfo);

      property = order[enumPropertyName];
      Assert.IsNotNull(property);
      Assert.AreEqual(PropertyType.Enum, property.PropertyType, "Expected Enum property type");

      property = order[propertyName];
      Assert.IsNotNull(property);
      Assert.AreEqual(PropertyType.Double, property.PropertyType, "Expected double property type");

      property = order["ReferenceNumber"];
      Assert.IsNotNull(property);
      Assert.AreEqual("ReferenceNumber Label", property.Label, "Mismatched labels");

      // Check related entities
      List<RelatedEntity> relatedEntities = 
        MetadataAccess.Instance.GetRelatedEntities(order.QualifiedName.NamespaceQualifiedTypeName);
      Assert.AreNotEqual(relatedEntities.Count, 0);

      return true;
    }

    #region Data

    #endregion
  }
}