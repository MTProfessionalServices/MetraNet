using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.CascadeDeleteTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class CascadeDeleteTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      if (initialized)
      {
        return;
      }

      SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);
      Name.CleanEntityDir(extensionName, entityGroupName);


      orderEntity = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "Order")) { PluralName = "Orders" };
      orderEntity.AddProperty(new Property("Name", "string") {IsRequired = true});
      orderEntity.AddProperty(new Property("Description", "string") { IsRequired = true });
      
      orderItemEntity = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "OrderItem")) { PluralName = "OrderItems" };
      orderItemEntity.AddProperty(new Property("Name", "string") { IsRequired = true });
      orderItemEntity.AddProperty(new Property("Description", "string") { IsRequired = true });

      productEntity = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "Product")) { PluralName = "Products" };
      productEntity.AddProperty(new Property("Name", "string") { IsRequired = true });
      productEntity.AddProperty(new Property("Description", "string") { IsRequired = true });

      contractEntity = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "Contract")) { PluralName = "Contracts" };
      contractEntity.AddProperty(new Property("Name", "string") { IsRequired = true });
      contractEntity.AddProperty(new Property("Description", "string") { IsRequired = true });

      inventoryEntity = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "Inventory")) { PluralName = "Inventories" };
      inventoryEntity.AddProperty(new Property("Name", "string") { IsRequired = true });
      inventoryEntity.AddProperty(new Property("Description", "string") { IsRequired = true });


      MetadataAccess.Instance.CreateOneToManyRelationship(ref orderEntity, ref orderItemEntity);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref orderItemEntity, ref productEntity);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref orderEntity, ref productEntity);

      MetadataAccess.Instance.CreateOneToOneRelationship(ref productEntity, ref inventoryEntity);
      MetadataAccess.Instance.CreateOneToOneRelationship(ref orderEntity, ref contractEntity);

      MetadataAccess.Instance.SaveEntities(new List<Entity>() { orderEntity, orderItemEntity, productEntity, contractEntity, inventoryEntity });
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      repository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(repository);

      initialized = true;
      // See graph.png in RMP\Extensions\CascadeDeleteTest\BusinessEntity\Common\Entity (if GraphViz is installed)
    }

    [Test]
    [Category("TestCascadeDeleteFromRoot")]
    public void TestCascadeDeleteFromRoot()
    {
      SetupData();

      // Delete the first order
      var firstOrder = orders[0];
      repository.Delete(firstOrder.EntityFullName, firstOrder.Id);
       
      // Verify that the chain staring with the first order has been deleted.
      var orderLoad = repository.LoadEntityInstance(firstOrder.EntityFullName, firstOrder.Id);
      Assert.IsNull(orderLoad);

      // Load the order items for the first order. Should be empty.
      var mtList = repository.LoadEntityInstancesFor(orderItemEntity.FullName, 
                                                     orderEntity.FullName, 
                                                     firstOrder.Id,
                                                     new MTList<EntityInstance>());
      Assert.AreEqual(0, mtList.Items.Count);

      // Load the products for the order items. Should be empty.
      List<EntityInstance> deletedOrderItems = order_OrderItems[firstOrder];

      foreach(EntityInstance deletedOrderItem in deletedOrderItems)
      {
        mtList = repository.LoadEntityInstancesFor(productEntity.FullName, 
                                                   orderItemEntity.FullName, 
                                                   deletedOrderItem.Id, 
                                                   new MTList<EntityInstance>());
        Assert.AreEqual(0, mtList.Items.Count);

        // Load the inventory for the product. Should be empty.
        List<EntityInstance> deletedOrderItemProducts = orderItem_Products[deletedOrderItem];
        foreach (EntityInstance deletedOrderItemProduct in deletedOrderItemProducts)
        {
          var entityInstance = repository.LoadEntityInstanceFor(inventoryEntity.FullName,
                                                                productEntity.FullName,
                                                                deletedOrderItemProduct.Id);
          Assert.IsNull(entityInstance);
        }
      }

      // Load the products for the deleted order. Should be empty.
      var deletedOrderProducts = order_Products[firstOrder];
      foreach (EntityInstance deletedOrderProduct in deletedOrderProducts)
      {
        mtList = repository.LoadEntityInstancesFor(productEntity.FullName,
                                                      orderEntity.FullName,
                                                      deletedOrderProduct.Id,
                                                      new MTList<EntityInstance>());
        Assert.AreEqual(0, mtList.Items.Count);
      }

      // Verify that the chain starting with the second order is intact
      var secondOrder = orders[1];
      orderLoad = repository.LoadEntityInstance(secondOrder.EntityFullName, secondOrder.Id);
      Assert.IsNotNull(orderLoad);
      Assert.AreEqual(secondOrder["Name"].Value, orderLoad["Name"].Value);

      // Load the order items for the second order. Should not be empty.
      MTList<EntityInstance> loadOrderItems = 
        repository.LoadEntityInstancesFor(orderItemEntity.FullName,
                                          orderEntity.FullName,
                                          secondOrder.Id,
                                          new MTList<EntityInstance>());

      Assert.AreEqual(order_OrderItems[secondOrder].Count, loadOrderItems.Items.Count);

      // Load the products for the order items. Should not be empty.
      List<EntityInstance> existingOrderItems = order_OrderItems[secondOrder];

      // Load the products for the order item
      foreach (EntityInstance existingOrderItem in existingOrderItems)
      {
        MTList<EntityInstance> loadOrderItemProducts = 
          repository.LoadEntityInstancesFor(productEntity.FullName,
                                            orderItemEntity.FullName,
                                            existingOrderItem.Id,
                                            new MTList<EntityInstance>());
        Assert.AreEqual(orderItem_Products[existingOrderItem].Count, loadOrderItemProducts.Items.Count);

        // Load the inventory for the product. Should not be empty.
        List<EntityInstance> existingProducts = orderItem_Products[existingOrderItem];
        foreach (EntityInstance existingOrderItemProduct in existingProducts)
        {
          var entityInstance = repository.LoadEntityInstanceFor(inventoryEntity.FullName,
                                                                productEntity.FullName,
                                                                existingOrderItemProduct.Id);
          Assert.IsNotNull(entityInstance);
        }
      }
    }

    [Test]
    [Category("TestCascadeDeleteFromIntermediate")]
    public void TestCascadeDeleteFromIntermediate()
    {
      SetupData();

      // Delete the OrderItems for the first Order
      List<EntityInstance> orderItems = order_OrderItems[orders[0]];
      foreach(EntityInstance orderItem in orderItems)
      {
        repository.Delete(orderItem.EntityFullName, orderItem.Id);

        Assert.IsNull(repository.LoadEntityInstance(orderItemEntity.FullName, orderItem.Id));

        var deletedProducts = orderItem_Products[orderItem];

        foreach(EntityInstance deletedProduct in deletedProducts)
        {
          Assert.IsNull(repository.LoadEntityInstance(productEntity.FullName, deletedProduct.Id));

          var deletedInventory = product_Inventory[deletedProduct];

          Assert.IsNull(repository.LoadEntityInstance(inventoryEntity.FullName, deletedInventory.Id));
        }
      }
    }
    #region Private Methods
    private void CleanData()
    {
     
      // Delete Order_Contract
      var order_contract = MetadataAccess.Instance.GetEntity("CascadeDeleteTest.Common.Order_Contract");
      Assert.IsNotNull(order_contract);
      repository.Delete(order_contract.FullName);

      // Delete Order_OrderItem
      var order_orderItem = MetadataAccess.Instance.GetEntity("CascadeDeleteTest.Common.Order_OrderItem");
      Assert.IsNotNull(order_orderItem);
      repository.Delete(order_orderItem.FullName);

      // Delete OrderItem_Product
      var orderItem_product = MetadataAccess.Instance.GetEntity("CascadeDeleteTest.Common.OrderItem_Product");
      Assert.IsNotNull(orderItem_product);
      repository.Delete(orderItem_product.FullName);

      // Delete Order_Product
      var order_Product = MetadataAccess.Instance.GetEntity("CascadeDeleteTest.Common.Order_Product");
      Assert.IsNotNull(order_Product);
      repository.Delete(order_Product.FullName);

      // Delete Order_Product
      var product_Inventory = MetadataAccess.Instance.GetEntity("CascadeDeleteTest.Common.Product_Inventory");
      Assert.IsNotNull(product_Inventory);
      repository.Delete(product_Inventory.FullName);

      // Delete Order's
      repository.Delete(orderEntity.FullName);

      // Delete OrderItems's
      repository.Delete(orderItemEntity.FullName);

      // Delete Product's
      repository.Delete(productEntity.FullName);

      // Delete Contract's
      repository.Delete(contractEntity.FullName);

      // Delete Inventory's
      repository.Delete(inventoryEntity.FullName);
    }

    private void SetupData()
    {
      CleanData();

      orders = new List<EntityInstance>();
      order_OrderItems = new Dictionary<EntityInstance, List<EntityInstance>>();
      orderItem_Products = new Dictionary<EntityInstance, List<EntityInstance>>();
      order_Products = new Dictionary<EntityInstance, List<EntityInstance>>();
      product_Inventory = new Dictionary<EntityInstance, EntityInstance>();
      order_Contract = new Dictionary<EntityInstance, EntityInstance>();

      int orderCounter = 0;
      int orderItemCounter = 0;
      int productCounter = 0;
      int inventoryCounter = 0;
      int contractCounter = 0;

      // Create Orders
      for (int i = 0; i < 2; i++)
      {
        var order = orderEntity.GetEntityInstance();
        order["Name"].Value = "Order" + " - " + orderCounter++;
        order["Description"].Value = order["Name"].Value;

        var orderItems = new List<EntityInstance>();
        order = repository.SaveEntityInstance(order);
        order_OrderItems.Add(order, orderItems);
        orders.Add(order);

        // Create OrderItems for Order
        for (int j = 0; j < 2; j++)
        {
          var orderItem = orderItemEntity.GetEntityInstance();
          orderItem["Name"].Value = String.Format("OrderItem-{0}", orderItemCounter++);
          orderItem["Description"].Value = String.Format("OrderItem for {0}", order["Name"].Value);

          orderItem = repository.CreateEntityInstanceFor(order.EntityFullName, order.Id, orderItem);
          orderItems.Add(orderItem);

          var orderItemProducts = new List<EntityInstance>();
          orderItem_Products.Add(orderItem, orderItemProducts);

          // Create Products for OrderItem
          for (int k = 0; k < 2; k++)
          {
            var product = productEntity.GetEntityInstance();
            product["Name"].Value = String.Format("Product-{0}", productCounter++);
            product["Description"].Value = String.Format("Product for {0}", orderItem["Name"].Value);

            product = repository.CreateEntityInstanceFor(orderItem.EntityFullName, orderItem.Id, product);
            orderItemProducts.Add(product);

            // Create Inventory for Product
            var inventory = inventoryEntity.GetEntityInstance();
            inventory["Name"].Value = String.Format("Inventory-{0}", inventoryCounter++);
            inventory["Description"].Value = String.Format("Inventory for {0}", product["Name"].Value);
            inventory = repository.CreateEntityInstanceFor(product.EntityFullName, product.Id, inventory);
            product_Inventory.Add(product, inventory);

          }
        }

        // Create Products for Order
        var orderProducts = new List<EntityInstance>();
        order_Products.Add(order, orderProducts);

        for (int l = 0; l < 2; l++)
        {
          var product = productEntity.GetEntityInstance();
          product["Name"].Value = String.Format("Product-{0}", productCounter++);
          product["Description"].Value = String.Format("Product for {0}", order["Name"].Value);

          product = repository.CreateEntityInstanceFor(order.EntityFullName, order.Id, product);
          orderProducts.Add(product);
        }

        // Create Contract for Order
        var contract = contractEntity.GetEntityInstance();
        contract["Name"].Value = String.Format("Contract-{0}", contractCounter++);
        contract["Description"].Value = String.Format("Contract for {0}", order["Name"].Value);
        contract = repository.CreateEntityInstanceFor(order.EntityFullName, order.Id, contract);
        order_Contract.Add(order, contract);


      }
    }
    #endregion

    #region Data

    // private static readonly ILog logger = LogManager.GetLogger("CascadeDeleteTest");
    private IStandardRepository repository;
    private static bool initialized;
    private string extensionName = "CascadeDeleteTest";
    private string entityGroupName = "Common";
    private Entity orderEntity;
    private Entity orderItemEntity;
    private Entity productEntity;
    private Entity contractEntity;
    private Entity inventoryEntity;

    private List<EntityInstance> orders;
    private Dictionary<EntityInstance, List<EntityInstance>> order_OrderItems;
    private Dictionary<EntityInstance, List<EntityInstance>> orderItem_Products;
    private Dictionary<EntityInstance, List<EntityInstance>> order_Products;
    private Dictionary<EntityInstance, EntityInstance> product_Inventory;
    private Dictionary<EntityInstance, EntityInstance> order_Contract;

    #endregion
  }
}
