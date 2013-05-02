using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Persistence;

using MetraTech.BusinessEntity.DataAccess.Metadata;
using Microsoft.VisualStudio.TestTools.UnitTesting;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.MetadataTests /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestClass]
  public class MetadataTests
  {
    /*[TestMethod]
    public void Setup()
    {
      // Create BE directories for 'MetadataTest' extension.
      SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);

      // Clean BE directories for 'MetadataTest' extension.
      Name.CleanEntityDir(extensionName, entityGroupName);

    }

    [TestMethod]
    [TestCategory("CanCreateSaveAndGetEntity")]
    public void CanCreateSaveAndGetEntity()
    {
      // "MetadataTest.BusinessEntity.Common.A"
      var A = CreateEntity("A");

      MetadataAccess.Instance.SaveEntity(A);

      var currentEntityA = MetadataAccess.Instance.GetEntity(A.FullName);
      Assert.IsNotNull(currentEntityA);
      Assert.AreEqual(A, currentEntityA);

      var entities = MetadataAccess.Instance.GetEntities();
      Assert.IsTrue(entities.Contains(A));
    }

    [TestMethod]
    [TestCategory("CanCreateSaveAndGetEntitiesAndRelationships")]
    public void CanCreateSaveAndGetEntitiesAndRelationships()
    {
      // "MetadataTest.BusinessEntity.Common.B"
      var entityB = CreateEntity("B");
      var entityC = CreateEntity("C");

      // Create relationship
      MetadataAccess.Instance.CreateOneToManyRelationship(ref entityB, ref entityC);
      Assert.AreEqual(1, entityB.Relationships.Count);
      Assert.AreEqual(1, entityC.Relationships.Count);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { entityB, entityC });

      // Get B
      Entity currentEntityB = MetadataAccess.Instance.GetEntity(entityB.FullName);
      Assert.IsNotNull(currentEntityB);
      Assert.AreEqual(entityB, currentEntityB);

      List<RelatedEntity> relatedEntities =
        MetadataAccess.Instance.GetRelatedEntities(currentEntityB.FullName);
      Assert.AreEqual(1, relatedEntities.Count, "Mismatched entity count");
      Assert.AreEqual(entityC.FullName, relatedEntities[0].Entity.FullName);

      // Get C
      Entity currentEntityC = MetadataAccess.Instance.GetEntity(entityC.FullName);
      Assert.IsNotNull(currentEntityC);
      Assert.AreEqual(entityC, currentEntityC);

      relatedEntities = MetadataAccess.Instance.GetRelatedEntities(currentEntityB.FullName);
      Assert.AreEqual(1, relatedEntities.Count, "Mismatched entity count");
      Assert.AreEqual(entityC.FullName, relatedEntities[0].Entity.FullName);


      // Get B and C
      var entities = MetadataAccess.Instance.GetEntities();
      Assert.IsTrue(entities.Contains(entityB));
      Assert.IsTrue(entities.Contains(entityC));

      var entity = entities.Find(e => e.FullName == entityB.FullName);
      Assert.IsNotNull(entity);
      relatedEntities = MetadataAccess.Instance.GetRelatedEntities(entity.FullName);
      Assert.AreEqual(1, relatedEntities.Count, "Mismatched entity count");
      Assert.AreEqual(entityC.FullName, relatedEntities[0].Entity.FullName);

      entity = entities.Find(e => e.FullName == entityC.FullName);
      Assert.IsNotNull(entity);
      relatedEntities = MetadataAccess.Instance.GetRelatedEntities(entity.FullName);
      Assert.AreEqual(1, relatedEntities.Count, "Mismatched entity count");
      Assert.AreEqual(entityB.FullName, relatedEntities[0].Entity.FullName);

      //var errors = MetadataAccess.Instance.Synchronize(extensionName);
      //Assert.AreEqual(0, errors.Count);

    }

    [TestMethod]
    [TestCategory("CanDeleteEntities")]
    public void CanDeleteEntities()
    {
      var D = CreateEntity("D");
      var E = CreateEntity("E");
      var F = CreateEntity("F");


      MetadataAccess.Instance.CreateOneToManyRelationship(ref D, ref E);
      Assert.AreEqual(1, D.Relationships.Count);
      Assert.AreEqual(1, E.Relationships.Count);

      MetadataAccess.Instance.CreateOneToManyRelationship(ref E, ref F);
      Assert.AreEqual(2, E.Relationships.Count);
      Assert.AreEqual(1, F.Relationships.Count);


      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { D, E, F });

      // Get E
      Entity currentE = MetadataAccess.Instance.GetEntity(E.FullName);
      Assert.IsNotNull(currentE);
      Assert.AreEqual(E, currentE);

      // Delete E
      List<ErrorObject> errors;
      List<Entity> changedEntities = MetadataAccess.Instance.DeleteEntity(E, out errors);
      Assert.AreEqual(0, errors.Count);

      // Save changed entities
      MetadataAccess.Instance.SaveEntities(changedEntities);

      // Get E
      currentE = MetadataAccess.Instance.GetEntity(E.FullName);
      Assert.IsNull(currentE);

      // Get D
      Entity currentD = MetadataAccess.Instance.GetEntity(D.FullName);
      Assert.IsNotNull(currentD);
      Assert.AreEqual(0, currentD.Relationships.Count);

      // Get F
      Entity currentF = MetadataAccess.Instance.GetEntity(F.FullName);
      Assert.IsNotNull(currentF);
      Assert.AreEqual(0, currentF.Relationships.Count);
    }

    [TestMethod]
    [TestCategory("CanDeleteRelationship")]
    public void CanDeleteRelationship()
    {
      var G = CreateEntity("G");
      var H = CreateEntity("H");

      // Create relationship
      MetadataAccess.Instance.CreateOneToManyRelationship(ref G, ref H);
      Assert.AreEqual(1, G.Relationships.Count);
      Assert.AreEqual(1, H.Relationships.Count);

      // Delete relationship
      MetadataAccess.Instance.DeleteRelationship(ref G, ref H);
      Assert.AreEqual(0, G.Relationships.Count);
      Assert.AreEqual(0, H.Relationships.Count);

      // Create relationship again
      MetadataAccess.Instance.CreateOneToManyRelationship(ref G, ref H);
      Assert.AreEqual(1, G.Relationships.Count);
      Assert.AreEqual(1, H.Relationships.Count);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { G, H });

      // Retrieve and delete relationship
      var currentG = MetadataAccess.Instance.GetEntity(G.FullName);
      var currentH = MetadataAccess.Instance.GetEntity(H.FullName);
      MetadataAccess.Instance.DeleteRelationship(ref currentG, ref currentH);
      Assert.AreEqual(0, currentG.Relationships.Count);
      Assert.AreEqual(0, currentH.Relationships.Count);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { currentG, currentH });

      // Retrieve and make sure that relationship is deleted
      currentG = MetadataAccess.Instance.GetEntity(G.FullName);
      currentH = MetadataAccess.Instance.GetEntity(G.FullName);
      Assert.AreEqual(0, currentG.Relationships.Count);
      Assert.AreEqual(0, currentH.Relationships.Count);

    }

    [TestMethod]
    [TestCategory("CanSynchronizeCore")]
    public void CanSynchronizeCore()
    {
      //var errors = MetadataAccess.Instance.Synchronize("SmokeTest");
      //Assert.AreEqual(0, errors.Count);
    }

    [TestMethod]
    [TestCategory("CanGetOrders")]
    public void CanGetOrders()
    {
      // Get each entity separately
      Entity order = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order");
      Assert.IsNotNull(order);

      Entity orderItem = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.OrderItem");
      Assert.IsNotNull(orderItem);

      Entity product = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Product");
      Assert.IsNotNull(product);

      Entity contract = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Contract");
      Assert.IsNotNull(contract);


      // Get all of them at once
      var entities = MetadataAccess.Instance.GetEntities();

      // Find each entity
      var currentOrder = entities.Find(e => e.FullName == order.FullName);
      Assert.AreEqual(order, currentOrder);

      var currentOrderItem = entities.Find(e => e.FullName == orderItem.FullName);
      Assert.AreEqual(orderItem, currentOrderItem);

      var currentProduct = entities.Find(e => e.FullName == product.FullName);
      Assert.AreEqual(product, currentProduct);

      // Create one-to-many between currentOrder and currentProduct
      MetadataAccess.Instance.CreateOneToManyRelationship(ref currentOrder, ref currentProduct);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { currentOrder, currentProduct, orderItem, contract });

      // Synchronize
      // MetadataAccess.Instance.Synchronize(currentOrder.ExtensionName, currentOrder.EntityGroupName);

      // Get entities again
      entities = MetadataAccess.Instance.GetEntities();

      currentOrder = entities.Find(e => e.FullName == order.FullName);
      Assert.AreEqual(order, currentOrder);

      currentProduct = entities.Find(e => e.FullName == product.FullName);
      Assert.AreEqual(product, currentProduct);

      // Delete relationship between currentOrder and currentProduct
      MetadataAccess.Instance.DeleteRelationship(ref currentOrder, ref currentProduct);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { order, product });

      // Synchronize
      // MetadataAccess.Instance.Synchronize(currentOrder.ExtensionName, currentOrder.EntityGroupName);

      // Get entities again
      entities = MetadataAccess.Instance.GetEntities();

      currentOrder = entities.Find(e => e.FullName == order.FullName);
      Assert.AreEqual(order, currentOrder);

      currentProduct = entities.Find(e => e.FullName == product.FullName);
      Assert.AreEqual(product, currentProduct);
    }

    [TestMethod]
    [TestCategory("CanAssociateWithMetranetEntity")]
    public void CanAssociateWithMetranetEntity()
    {
      // Get AccountDef
      List<IMetranetEntity> metranetEntities = MetadataAccess.Instance.GetMetraNetEntities();
      Assert.IsTrue(metranetEntities.Count > 0);
      IMetranetEntity accountDef =
        metranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef");
      Assert.IsNotNull(accountDef);

      IMetranetEntity subscriptionDef =
        metranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.SubscriptionDef");
      Assert.IsNotNull(subscriptionDef);

      var I = CreateEntity("I");
      MetadataAccess.Instance.AddMetranetEntityAssociation(ref I, accountDef, Multiplicity.Many);
      MetadataAccess.Instance.AddMetranetEntityAssociation(ref I, subscriptionDef, Multiplicity.Many);

      I = MetadataAccess.Instance.GetEntity(I.FullName);
      List<IMetranetEntity> currentMetranetEntities = I.GetAssociatedMetranetEntities();
      accountDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef");
      Assert.IsNotNull(accountDef);

      foreach (MetranetEntityProperty metranetEntityProperty in accountDef.Properties)
      {
        Property property = I[metranetEntityProperty.Name];
        Assert.IsNotNull(property);
        Assert.IsTrue(property.IsAssociation);
        Assert.AreEqual(accountDef.MetraNetEntityConfig.TypeName, property.AssociationEntityName);
      }

      subscriptionDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.SubscriptionDef");
      Assert.IsNotNull(subscriptionDef);


      foreach (MetranetEntityProperty metranetEntityProperty in subscriptionDef.Properties)
      {
        Property property = I[metranetEntityProperty.Name];
        Assert.IsNotNull(property);
        Assert.IsTrue(property.IsAssociation);
        Assert.AreEqual(subscriptionDef.MetraNetEntityConfig.TypeName, property.AssociationEntityName);
      }

      // Save Entity
      MetadataAccess.Instance.SaveEntity(I);

      // Load I
      var currentI = MetadataAccess.Instance.GetEntity(I.FullName);
      currentMetranetEntities = currentI.GetAssociatedMetranetEntities();

      accountDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef");
      Assert.IsNotNull(accountDef);

      subscriptionDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.SubscriptionDef");
      Assert.IsNotNull(subscriptionDef);

      // Delete association with subscription
      MetadataAccess.Instance.DeleteMetranetEntityAssociation(ref currentI, subscriptionDef);
      currentI = MetadataAccess.Instance.GetEntity(currentI.FullName);
      currentMetranetEntities = currentI.GetAssociatedMetranetEntities();

      accountDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef");
      Assert.IsNotNull(accountDef);

      subscriptionDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.SubscriptionDef");
      Assert.IsNull(subscriptionDef);

      // Save and reload
      MetadataAccess.Instance.SaveEntity(currentI);
      currentI = MetadataAccess.Instance.GetEntity(currentI.FullName);
      currentMetranetEntities = currentI.GetAssociatedMetranetEntities();

      accountDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef");
      Assert.IsNotNull(accountDef);

      subscriptionDef =
        currentMetranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.SubscriptionDef");
      Assert.IsNull(subscriptionDef);
    }


    [TestMethod]
    public void CanCreateOneToManyRelationship()
    {
      var entityX = CreateEntity("X");
      var entityY = CreateEntity("Y");

      // Create relationship
      MetadataAccess.Instance.CreateOneToManyRelationship(ref entityX, ref entityY);
      Assert.AreEqual(1, entityX.Relationships.Count);
      Assert.AreEqual(1, entityY.Relationships.Count);

      Assert.AreEqual(entityX.FullName, entityX.Relationships[0].End1.EntityTypeName);
      Assert.AreEqual(entityY.FullName, entityX.Relationships[0].End2.EntityTypeName);

      Assert.AreEqual(entityX.FullName, entityY.Relationships[0].End2.EntityTypeName);
      Assert.AreEqual(entityY.FullName, entityY.Relationships[0].End1.EntityTypeName);

      Assert.AreEqual(entityX.FullName, entityX.Relationships[0].Source.EntityTypeName);
      Assert.AreEqual(entityY.FullName, entityX.Relationships[0].Target.EntityTypeName);

      Assert.AreEqual(entityX.FullName, entityY.Relationships[0].Source.EntityTypeName);
      Assert.AreEqual(entityY.FullName, entityY.Relationships[0].Target.EntityTypeName);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { entityX, entityY });

      var currentX = MetadataAccess.Instance.GetEntity(entityX.FullName);
      MetadataAccess.Instance.SaveEntities(new List<Entity> { currentX });

    }

    [TestMethod]
    [TestCategory("Test")]
    public void Test()
    {
      var entityP = CreateEntity("P");
      var entityQ = CreateEntity("Q");
      var entityR = CreateEntity("R");

      MetadataAccess.Instance.CreateOneToManyRelationship(ref entityP, ref entityQ);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref entityQ, ref entityR);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref entityP, ref entityR);

      var entityP_Q = MetadataAccess.Instance.GetEntity("MetadataTest.Common.P_Q");
      Assert.IsNotNull(entityP_Q);
      var entityQ_R = MetadataAccess.Instance.GetEntity("MetadataTest.Common.Q_R");
      Assert.IsNotNull(entityQ_R);

      MetadataAccess.Instance.SaveEntities(new List<Entity>() {entityP, entityQ, entityR});
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      List<ErrorObject> errors;
      List<Entity> changedEntities = MetadataAccess.Instance.DeleteEntity(entityQ, out errors);

      MetadataAccess.Instance.DeleteEntity(entityP_Q, out errors);
      MetadataAccess.Instance.DeleteEntity(entityQ_R, out errors);

      MetadataAccess.Instance.SaveEntities(changedEntities);
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);
    }
    
    #region Private Methods
    private Entity CreateEntity(string name)
    {
      return CreateEntity(name, extensionName, entityGroupName);
    }
    */
    internal static Entity CreateEntity(string name, string extensionName, string entityGroupName)
    {
      string entityName = Name.GetEntityFullName(extensionName, entityGroupName, name);
      var entity =
        new Entity(entityName)
        {
          Category = Category.ConfigDriven,
          Label = name + " Label",
          PluralName = name + "s",
          Description = name + " Description"
        };

      #region Properties

      var property1 = new Property("BooleanProp", "Boolean") {DefaultValue = "true"};

      var property2 = new Property("BooleanProp1", "bool");

      var property3 = new Property("BooleanProp2", "System.Boolean");

      var property4 = new Property("DateTimeProp", "DateTime");

      var property5 = new Property("DateTimeProp1", "System.DateTime");

      var property6 = new Property("DecimalProp", "Decimal");

      var property7 = new Property("DecimalProp1", "decimal");

      var property8 = new Property("DecimalProp2", "System.Decimal");

      var property9 = new Property("DoubleProp", "Double") { DefaultValue = "1234.567" };

      var property10 = new Property("DoubleProp1", "double");

      var property11 = new Property("DoubleProp2", "System.Double");

      var property12 = new Property("GuidProp", "System.Guid");

      var property13 = new Property("GuidProp1", "Guid");

      var property14 = new Property("Int32Prop", "System.Int32");
      property14.IsUnique = true;
      property14.IsSortable = true;

      var property15 = new Property("Int32Prop1", "Int32") { DefaultValue = "1234" };

      var property16 = new Property("Int32Prop2", "int");

      var property17 = new Property("Int64Prop", "System.Int64");

      var property18 = new Property("Int64Prop1", "Int64");

      var property19 =
        new Property("StringProp", "string")
        {
          IsBusinessKey = true
        };

      var property20 =
        new Property("StringProp1", "string")
        {
          IsSearchable = true,
          IsSortable = true
        };

      var property21 =
        new Property("StringProp2", "string")
        {
          IsSearchable = true,
          IsSortable = true
        };

      var property22 =
        new Property("EnumProp",
                     "MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek, MetraTech.DomainModel.Enums.Generated");

      entity.AddProperty(property1);
      entity.AddProperty(property2);
      entity.AddProperty(property3);
      entity.AddProperty(property4);
      entity.AddProperty(property5);
      entity.AddProperty(property6);
      entity.AddProperty(property7);
      entity.AddProperty(property8);
      entity.AddProperty(property9);
      entity.AddProperty(property10);
      entity.AddProperty(property11);
      entity.AddProperty(property12);
      entity.AddProperty(property13);
      entity.AddProperty(property14);
      entity.AddProperty(property15);
      entity.AddProperty(property16);
      entity.AddProperty(property17);
      entity.AddProperty(property18);
      entity.AddProperty(property19);
      entity.AddProperty(property20);
      entity.AddProperty(property21);
      entity.AddProperty(property22);

      #endregion

      MetadataAccess.Instance.SaveMetadata();
      MetadataAccess.Instance.Synchronize();

      entity = MetadataAccess.Instance.GetEntity(entityName);

      return entity;
    }/*
    #endregion
    
    #region Data
    private string extensionName = "MetadataTest";
    private string entityGroupName = "Common";
    #endregion*/
  }
}
