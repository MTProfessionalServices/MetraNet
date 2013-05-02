using System;
using System.Collections.Generic;
using NUnit.Framework;

using MetraTech.ActivityServices.Common;
using MetraTech.Basic;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Core.Persistence;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class RepositoryTests
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Create 'RepositoryTest' tenant. If 'RepositoryTest' exists, it will do nothing.
      MetadataAccess.Instance.CreateNewTenant(tenantName);

      // Clean 'RepositoryTest' tenant
      MetadataAccess.Instance.CleanTenant(tenantName);
    }

    

    [Test]
    public void TestEndtoEnd()
    {
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();

      #region Create entities

      IList<Entity> entities = new List<Entity>();

      // Order
      Entity order = new Entity()
      {
        ClassName = tenantName + "_Order",
        Namespace = tenantName + ".BusinessEntity.OrderManagement",
        AssemblyName = tenantName + ".BusinessEntity",
        Category = Category.ConfigDriven,
        Tenant = tenantName,
        Label = "Order Label",
        PluralName = "Orders",
        Description = "Order Description"
      };
      entities.Add(order);

      Property refProperty = new Property(order)
      {
        Name = "ReferenceNumber",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Ref# Label",
        Description = "Ref# Description",
        DefaultValue = "abc",
        IsBusinessKey = true
      };
      order.Properties.Add(refProperty);

      Property descProperty = new Property(order)
      {
        Name = "Description",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Description",
        Description = "Description",
      };
      order.Properties.Add(descProperty);

      // LineItem
      Entity lineItem = new Entity()
      {
        ClassName = tenantName + "_LineItem",
        Namespace = tenantName + ".BusinessEntity.OrderManagement",
        AssemblyName = tenantName + ".BusinessEntity",
        Category = Category.ConfigDriven,
        Tenant = tenantName,
        Label = "LineItem Label",
        PluralName = "LineItems",
        Description = "LineItem Description"
      };
      entities.Add(lineItem);

      refProperty = new Property(lineItem)
      {
        Name = "ReferenceNumber",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Ref# Label",
        Description = "Ref# Description",
        DefaultValue = "abc",
        IsBusinessKey = true
      };
      lineItem.Properties.Add(refProperty);

      descProperty = new Property(lineItem)
      {
        Name = "Description",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Description",
        Description = "Description",
      };
      lineItem.Properties.Add(descProperty);

      // Product
      Entity product = new Entity()
      {
        ClassName = tenantName + "_Product",
        Namespace = tenantName + ".BusinessEntity.OrderManagement",
        AssemblyName = tenantName + ".BusinessEntity",
        Category = Category.ConfigDriven,
        Tenant = tenantName,
        Label = "Product Label",
        PluralName = "Products",
        Description = "Product Description"
      };
      entities.Add(product);

      refProperty = new Property(product)
      {
        Name = "ReferenceNumber",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Ref# Label",
        Description = "Ref# Description",
        DefaultValue = "abc",
        IsBusinessKey = true
      };
      product.Properties.Add(refProperty);

      descProperty = new Property(product)
      {
        Name = "Description",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Description",
        Description = "Description",
      };
      product.Properties.Add(descProperty);

      #endregion

      #region Create Relationships
      MetadataAccess.Instance.CreateOneToManyRelationship(ref order, ref lineItem);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref lineItem, ref product);
      #endregion

      #region Save Entities
      MetadataAccess.Instance.SaveEntities(tenantName, entities);
      #endregion

      #region Create Schema
      MetadataAccess.Instance.CreateSchema(tenantName);
      #endregion

      #region Create Data
    
      // Create the order instance
      IEntityInstance orderInstance = order.GetEntityInstance();
      Random random = new Random();

      string orderReference = "Ref#-" + random.Next();
      orderInstance["ReferenceNumber"].Value = orderReference;
      orderInstance["Description"].Value = "Order description";

      // Save the orderInstance
      Tenant tenant = TenantManager.Instance.GetTenant(tenantName);
      IStandardRepository repository = tenant.GetStandardRepository();
      IEntityInstance updatedOrderInstance = repository.SaveEntityInstance(orderInstance);

      Assert.IsNotNull(updatedOrderInstance, "Expected non-null updatedOrderInstance");

      // Check that updatedOrderInstance has a valid Id
      Assert.AreNotEqual(Guid.Empty, updatedOrderInstance.Id, "Expected non-empty Guid as Id");

      #region Check LoadEntityInstances For DemoOrder
      AssemblyQualifiedName assemblyQualifiedName =
        new AssemblyQualifiedName(order.QualifiedName.NamespaceQualifiedTypeName, order.QualifiedName.AssemblyName);

      MTList<IEntityInstance> mtList = new MTList<IEntityInstance>();
      mtList.CurrentPage = -1;
      mtList.PageSize = -1;

      MTList<IEntityInstance> orders = repository.LoadEntityInstances(assemblyQualifiedName, mtList);
      Assert.AreEqual(1, orders.Items.Count);
      IEntityInstance currentOrderInstance = orders.Items[0];
      Assert.AreEqual(order.QualifiedName.NamespaceQualifiedTypeName, currentOrderInstance.AssemblyQualifiedName.NamespaceQualifiedTypeName);
      #endregion

      // Load the orderInstance
      currentOrderInstance =
        repository.LoadEntityInstance(updatedOrderInstance.Id, updatedOrderInstance.AssemblyQualifiedName);

      Assert.IsNotNull(currentOrderInstance, "Expected non-null currentOrderInstance");
      Assert.AreNotEqual(Guid.Empty, currentOrderInstance.Id, "Expected non-empty Guid as Id");
      
      // Check property values
      Assert.AreEqual(orderReference, currentOrderInstance["ReferenceNumber"].Value);
      Assert.AreEqual("Order description", currentOrderInstance["Description"].Value);

      string lineItemReference = "Ref#-" + random.Next();
      string lineItemDescription = "Line Item description";
      string productReference = "Ref#-" + random.Next();
      string productDescription = "Product description";

      // Add one LineItem to the Order and one Product to the LineItem.
      IList<ICollectionAssociation> orderCollectionAssociations = order.GetCollectionAssociations();
      foreach(ICollectionAssociation lineItemCollectionAssociation in orderCollectionAssociations)
      {
        // Create a line item instance
        IEntityInstance lineItemInstance = lineItem.GetEntityInstance();
        lineItemInstance["ReferenceNumber"].Value = lineItemReference;
        lineItemInstance["Description"].Value = lineItemDescription;

        // Add it to the collectionAssociation (or we can create a new collectionAssociation)
        lineItemCollectionAssociation.EntityInstances.Add(lineItemInstance);

        // Add the collectionAssociation to the order
        currentOrderInstance.AddCollectionAssociation(lineItemCollectionAssociation);

        // Create a product for the line item
        IList<ICollectionAssociation> lineItemCollectionAssociations = lineItem.GetCollectionAssociations();
        foreach(ICollectionAssociation productCollectionAssociation in lineItemCollectionAssociations)
        {
          // Create a product instance
          IEntityInstance productInstance = product.GetEntityInstance();
          productInstance["ReferenceNumber"].Value = productReference;
          productInstance["Description"].Value = productDescription;

          // Add it to the collectionAssociation 
          productCollectionAssociation.EntityInstances.Add(productInstance);
          lineItemInstance.AddCollectionAssociation(productCollectionAssociation);
        }
      }

      // Save the orderInstance with a new reference number
      orderReference = "Ref#-" + random.Next();
      currentOrderInstance["ReferenceNumber"].Value = orderReference;
      repository.SaveEntityInstance(currentOrderInstance);

      // Load the orderInstance
      currentOrderInstance =
        repository.LoadEntityInstance(currentOrderInstance.Id, currentOrderInstance.AssemblyQualifiedName);
      
      Assert.IsNotNull(currentOrderInstance, "Expected non-null currentOrderInstance");
      // Check the order reference
      Assert.AreEqual(orderReference, currentOrderInstance["ReferenceNumber"].Value);

      // Expect the order to have one collection association for line item
      Assert.AreEqual(1, currentOrderInstance.CollectionAssociations.Count, "Mismatched collection association count");
      // Expect one entity instance (line item) to be in the collection
      Assert.AreEqual(1, currentOrderInstance.CollectionAssociations[0].EntityInstances.Count,
                      "Missing entity instance for line item");

      // Get the line item entity instance
      IEntityInstance currentLineItemInstance = currentOrderInstance.CollectionAssociations[0].EntityInstances[0];
      Assert.IsNotNull(currentLineItemInstance);

      // Expect the currentLineItemInstance to have a ReferenceNumber property with the specified value
      Assert.AreEqual(lineItemReference, currentLineItemInstance["ReferenceNumber"].Value,
                      "Mismatched reference number value for line item entity instance");

      // Expect the entity instance (line item) to have a Description property with the specified value
      Assert.AreEqual(lineItemDescription, currentLineItemInstance["Description"].Value,
                      "Mismatched description value for line item entity instance");


      // Expect the line item entity instance  to have one collection association for product
      Assert.AreEqual(1, currentLineItemInstance.CollectionAssociations.Count, "Mismatched collection association count");
      // Expect one entity instance (product) to be in the collection
      Assert.AreEqual(1, currentLineItemInstance.CollectionAssociations[0].EntityInstances.Count,
                      "Missing entity instance for product");

      // Get the product entity instance
      IEntityInstance currentProductInstance = currentLineItemInstance.CollectionAssociations[0].EntityInstances[0];
      Assert.IsNotNull(currentProductInstance);

      // Expect the currentProductInstance to have a ReferenceNumber property with the specified value
      Assert.AreEqual(productReference,
                      currentProductInstance["ReferenceNumber"].Value,
                      "Mismatched reference number value for product entity instance");
      // Expect the currentProductInstance to have a Description property with the specified value
      Assert.AreEqual(productDescription,
                      currentProductInstance["Description"].Value,
                      "Mismatched description value for product entity instance");

      #region TODO Check LoadEntityInstances For LineItems
      //assemblyQualifiedName =
      //  new AssemblyQualifiedName(lineItem.QualifiedName.NamespaceQualifiedTypeName, lineItem.QualifiedName.AssemblyName);
      //MTList<IEntityInstance> lineItems = repository.LoadEntityInstances(assemblyQualifiedName);
      //Assert.AreEqual(1, lineItems.Items.Count);
      //currentLineItemInstance = lineItems.Items[0];
      //Assert.AreEqual(lineItem.QualifiedName.NamespaceQualifiedTypeName, currentLineItemInstance.AssemblyQualifiedName.NamespaceQualifiedTypeName);
      #endregion
      #endregion
    }

    [Test]
    public void TestEnum()
    {
      List<Entity> entities = new List<Entity>();

      #region Create Entity
      Entity orderWithEnum = new Entity()
      {
        ClassName = "OrderWithEnum",
        Namespace = tenantName + ".BusinessEntity.OrderManagement",
        AssemblyName = tenantName + ".BusinessEntity",
        Category = Category.ConfigDriven,
        Tenant = tenantName,
        Label = "OrderWithEnum Label",
        PluralName = "OrderWithEnum",
        Description = "OrderWithEnum Description"
      };
      entities.Add(orderWithEnum);

      Property refProperty = new Property(orderWithEnum)
      {
        Name = "ReferenceNumber",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Ref# Label",
        Description = "Ref# Description",
        DefaultValue = "abc",
        IsBusinessKey = true
      };
      orderWithEnum.Properties.Add(refProperty);

      Property enumProperty = new Property(orderWithEnum)
      {
        Name = "DayOfTheWeek",
        QualifiedName =
          new QualifiedName("MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek",
                            "MetraTech.DomainModel.Enums.Generated",
                            tenantName),
        Label = "Description",
        Description = "Description",
      };

      orderWithEnum.Properties.Add(enumProperty);
      #endregion

      #region Save Entities
      MetadataAccess.Instance.SaveEntities(tenantName, entities);
      #endregion

      #region Create Schema
      MetadataAccess.Instance.CreateSchema(tenantName);
      #endregion

      #region Create and Save Data
      //MetadataAccess.Instance.RefreshDataSource(tenantName);

      IEntityInstance entityInstance = orderWithEnum.GetEntityInstance();
      entityInstance["ReferenceNumber"].Value = "123";
      entityInstance["DayOfTheWeek"].Value = DayOfTheWeek.Monday;

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository(tenantName);
      IEntityInstance currentInstance = standardRepository.SaveEntityInstance(entityInstance);

      currentInstance = standardRepository.LoadEntityInstance(currentInstance.Id, currentInstance.AssemblyQualifiedName);
      Assert.AreEqual(DayOfTheWeek.Monday, currentInstance["DayOfTheWeek"].Value, "Mismatched DayOfTheWeekValue");
      #endregion
    }

    [Test]
    public void TestAssociatingBusinessEntityWithMetranetEntity()
    {
      #region Create Entity
      Entity orderWithEnum = new Entity()
      {
        ClassName = "OrderWithAccount",
        Namespace = tenantName + ".BusinessEntity.OrderManagement",
        AssemblyName = tenantName + ".BusinessEntity",
        Category = Category.ConfigDriven,
        Tenant = tenantName,
        Label = "OrderWithAccount Label",
        PluralName = "OrderWithAccount",
        Description = "OrderWithAccount Description"
      };

      Property refProperty = new Property(orderWithEnum)
      {
        Name = "ReferenceNumber",
        QualifiedName = new QualifiedName("System.String", tenantName),
        Label = "Ref# Label",
        Description = "Ref# Description",
        DefaultValue = "abc",
        IsBusinessKey = true
      };
      orderWithEnum.Properties.Add(refProperty);

      Property enumProperty = new Property(orderWithEnum)
      {
        Name = "DayOfTheWeek",
        QualifiedName =
          new QualifiedName("MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek",
                            "MetraTech.DomainModel.Enums.Generated",
                            tenantName),
        Label = "Description",
        Description = "Description",
      };

      orderWithEnum.Properties.Add(enumProperty);
      #endregion

      // Get MetraNetEntities (currently, just AccountDef)
      List<IMetranetEntity> metranetEntities = MetadataAccess.Instance.GetMetraNetEntities();

      // Associate with AccountDef. We're saying that one account can have many OrderWithEnum's.
      AccountDef accountDef = metranetEntities[0] as AccountDef;
      Assert.IsNotNull(accountDef);
      MetadataAccess.Instance.AddMetranetEntityAssociation(orderWithEnum, accountDef, Multiplicity.Many);

      // Save Entity
      MetadataAccess.Instance.SaveEntity(orderWithEnum);

      // Create Schema
      MetadataAccess.Instance.CreateSchema(tenantName);

      // Create and Save Data
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository(tenantName);
      int numItems = 10;
      for (int i = 0; i < numItems; i++)
      {
        IEntityInstance entityInstance = orderWithEnum.GetEntityInstance();
        
        entityInstance["ReferenceNumber"].Value = i;
        entityInstance["DayOfTheWeek"].Value = DayOfTheWeek.Monday;
        entityInstance["AccountId"].Value = 123;

        standardRepository.SaveEntityInstance(entityInstance);
      }

      #region Test Paging
      MTList<IEntityInstance> entityInstances = new MTList<IEntityInstance>();
      entityInstances.PageSize = 3;
      entityInstances.CurrentPage = 1;

      accountDef.AccountId = 123;

      // Load the first batch of 3
      MTList<IEntityInstance> loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);

      Assert.AreEqual(3, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("0", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      Assert.AreEqual("1", loadedEntityInstances.Items[1]["ReferenceNumber"].Value);
      Assert.AreEqual("2", loadedEntityInstances.Items[2]["ReferenceNumber"].Value);

      // Load the second batch of 3
      entityInstances.CurrentPage = 4;

      loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);

      Assert.AreEqual(3, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("3", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      Assert.AreEqual("4", loadedEntityInstances.Items[1]["ReferenceNumber"].Value);
      Assert.AreEqual("5", loadedEntityInstances.Items[2]["ReferenceNumber"].Value);

      // Load the third batch of 3
      entityInstances.CurrentPage = 7;

      loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);

      Assert.AreEqual(3, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("6", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      Assert.AreEqual("7", loadedEntityInstances.Items[1]["ReferenceNumber"].Value);
      Assert.AreEqual("8", loadedEntityInstances.Items[2]["ReferenceNumber"].Value);

      // Load the last batch of 1
      entityInstances.CurrentPage = 10;
      loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);

      Assert.AreEqual(1, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("9", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      #endregion

      #region Test Filter
      entityInstances.PageSize = -1;
      entityInstances.CurrentPage = -1;

      entityInstances.Filters.Add(new MTFilterElement("ReferenceNumber", MTFilterElement.OperationType.Equal, "1"));
      loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);
      Assert.AreEqual(1, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("1", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      #endregion

      #region Test Sort
      entityInstances.Filters.Clear();
      entityInstances.SortProperty = "ReferenceNumber";
      entityInstances.SortDirection = SortType.Descending;
      loadedEntityInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(orderWithEnum.AssemblyQualifiedName,
                                                                entityInstances,
                                                                accountDef);
      Assert.AreEqual(10, loadedEntityInstances.Items.Count, "Mismatched counts");
      Assert.AreEqual("9", loadedEntityInstances.Items[0]["ReferenceNumber"].Value);
      #endregion
    }

    #region Data
    private string tenantName = "RepositoryTest";
    #endregion
  }
}
