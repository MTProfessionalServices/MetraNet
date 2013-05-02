using System;
using System.Collections.Generic;
using System.ServiceModel;
using SmokeTest.OrderManagement;

using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.Service.OrderManagementTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.Service
{
  [TestFixture]
  public class OrderManagementTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      //if (synchronized)
      //{
      //  return;
      //}
      
      // Synchronize OrderManagement
      // MetadataAccess.Instance.Synchronize("Core", "OrderManagement");

      orderEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order");
      Assert.IsNotNull(orderEntity);

      orderItemEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.OrderItem");
      Assert.IsNotNull(orderItemEntity);

      productEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Product");
      Assert.IsNotNull(productEntity);

      contractEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Contract");
      Assert.IsNotNull(contractEntity);

      // synchronized = true;
    }

    #region EntityInstance
    [Test]
    [Category("SaveLoadUpdateAndDeleteOrderUsingEntityInstance")]
    public void SaveLoadUpdateAndDeleteOrderUsingEntityInstance()
    {
      CleanData();

      
      // Save
      var createEntityInstanceClient = new EntityInstanceService_GetNewEntityInstance_Client();
      createEntityInstanceClient.UserName = clientUserName;
      createEntityInstanceClient.Password = clientPassword;
      createEntityInstanceClient.In_entityName = orderEntity.FullName;
      createEntityInstanceClient.Invoke();
      EntityInstance order = createEntityInstanceClient.Out_entityInstance;
      Assert.IsNotNull(order);

      InitializeOrder(ref order);

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = order;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveClient.InOut_entityInstance.Id);
      CompareOrders(order, saveClient.InOut_entityInstance);

      // Load
      var loadClient = new EntityInstanceService_LoadEntityInstance_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = order.EntityFullName;
      loadClient.In_id = saveClient.InOut_entityInstance.Id;
      loadClient.Invoke();

      // Verify
      Assert.IsNotNull(loadClient.Out_entityInstance, "loadClient.Out_entityInstance cannot be null");
      Assert.AreEqual(saveClient.InOut_entityInstance.Id, loadClient.Out_entityInstance.Id);
      CompareOrders(saveClient.InOut_entityInstance, loadClient.Out_entityInstance);

      // Update
      string newDescription = "Updated Description";
      loadClient.Out_entityInstance["Description"].Value = newDescription;
      loadClient.Out_entityInstance["InvoiceMethod"].Value = InvoiceMethod.Detailed;
      saveClient.InOut_entityInstance = loadClient.Out_entityInstance;
      saveClient.Invoke();

      // Load
      loadClient.Out_entityInstance = null;
      loadClient.In_entityName = order.EntityFullName;
      loadClient.In_id = saveClient.InOut_entityInstance.Id;
      loadClient.Invoke();

      Assert.IsNotNull(loadClient.Out_entityInstance, "loadClient.Out_entityInstance cannot be null");
      Assert.AreEqual(newDescription, loadClient.Out_entityInstance["Description"].Value);
      Assert.AreEqual(InvoiceMethod.Detailed, loadClient.Out_entityInstance["InvoiceMethod"].Value);

      // Delete
      var deleteClient = new EntityInstanceService_DeleteEntityInstance_Client();
      deleteClient.UserName = clientUserName;
      deleteClient.Password = clientPassword;
      deleteClient.In_entityInstance = loadClient.Out_entityInstance;
      deleteClient.Invoke();

      // Load
      loadClient.Invoke();
      Assert.IsNull(loadClient.Out_entityInstance, "loadClient.Out_entityInstance should be null");
    }

    [Test]
    [Category("SaveLoadAndUpdateOrderItemsForOrderUsingEntityInstance")]
    public void SaveLoadAndUpdateOrderItemsForOrderUsingEntityInstance()
    {
      CleanData();

      // Create Order
      EntityInstance order = orderEntity.GetEntityInstance();
      InitializeOrder(ref order);

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = order;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveClient.InOut_entityInstance.Id);
      CompareOrders(order, saveClient.InOut_entityInstance);

      // Create OrderItems
      var orderItems = new List<EntityInstance>();
      var ordersItemsByReferenceNumber = new Dictionary<string, EntityInstance>();

      for (int i = 0; i < 10; i++)
      {
        EntityInstance orderItem = orderItemEntity.GetEntityInstance();
        InitializeOrderItem(ref orderItem);
        orderItems.Add(orderItem);
        ordersItemsByReferenceNumber.Add(orderItem["ReferenceNumber"].Value.ToString(), orderItem);
      }

      // Save OrderItems for Order
      var saveOrderItemsClient = new EntityInstanceService_CreateEntityInstancesFor_Client();

      saveOrderItemsClient.UserName = clientUserName;
      saveOrderItemsClient.Password = clientPassword;
      saveOrderItemsClient.In_forEntityName = orderEntity.FullName;
      saveOrderItemsClient.In_forEntityId = saveClient.InOut_entityInstance.Id;
      saveOrderItemsClient.InOut_entityInstances = orderItems;
      saveOrderItemsClient.Invoke();

      // Load OrderItems for Order
      var loadOrderItemsClient = new EntityInstanceService_LoadEntityInstancesFor_Client();
      loadOrderItemsClient.UserName = clientUserName;
      loadOrderItemsClient.Password = clientPassword;
      loadOrderItemsClient.In_entityName = orderItemEntity.FullName;
      loadOrderItemsClient.In_forEntityName = orderEntity.FullName;
      loadOrderItemsClient.In_forEntityId = saveClient.InOut_entityInstance.Id;
      loadOrderItemsClient.InOut_mtList = new MTList<EntityInstance>();
      loadOrderItemsClient.Invoke();

      // Verify
      Assert.IsNotNull(loadOrderItemsClient.InOut_mtList, "loadClient.InOut_mtList cannot be null");
      Assert.AreEqual(orderItems.Count, loadOrderItemsClient.InOut_mtList.Items.Count);

      foreach (EntityInstance entityInstance in loadOrderItemsClient.InOut_mtList.Items)
      {
        Assert.AreNotEqual(Guid.Empty, entityInstance.Id);
        EntityInstance orderItem;
        ordersItemsByReferenceNumber.TryGetValue(entityInstance["ReferenceNumber"].Value.ToString(), out orderItem);
        Assert.IsNotNull(order);
      }

      // Update OrderItem's
      var loadClient = new EntityInstanceService_LoadEntityInstance_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      
      foreach(EntityInstance entityInstance in loadOrderItemsClient.InOut_mtList.Items)
      {
        string updatedRef = "Updated Ref# - " + random.Next();
        entityInstance["ReferenceNumber"].Value = updatedRef;

        // Save
        saveClient.InOut_entityInstance = entityInstance;
        saveClient.Invoke();

        // Load
        loadClient.In_entityName = entityInstance.EntityFullName;
        loadClient.In_id = entityInstance.Id;
        loadClient.Invoke();

        Assert.AreEqual(updatedRef, loadClient.Out_entityInstance["ReferenceNumber"].Value);
      }
    }

    [Test]
    [Category("SaveAndLoadOrdersUsingEntityInstance")]
    public void SaveAndLoadOrdersUsingEntityInstance()
    {
      CleanData();

      var orders = new List<EntityInstance>();
      var ordersByReferenceNumber = new Dictionary<string, EntityInstance>();

      for (int i = 0; i < 10; i++)
      {
        EntityInstance order = orderEntity.GetEntityInstance();
        InitializeOrder(ref order);
        orders.Add(order);
        ordersByReferenceNumber.Add(order["ReferenceNumber"].Value.ToString(), order);
      }

      var saveClient = new EntityInstanceService_SaveEntityInstances_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstances = orders;
      saveClient.Invoke();

      // Load
      var loadClient = new EntityInstanceService_LoadEntityInstances_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = orderEntity.FullName;
      loadClient.InOut_entityInstances = new MTList<EntityInstance>();
      loadClient.Invoke();

      // Verify
      Assert.IsNotNull(loadClient.InOut_entityInstances, "loadClient.InOut_entityInstances cannot be null");
      Assert.AreEqual(orders.Count, loadClient.InOut_entityInstances.Items.Count);

      foreach(EntityInstance entityInstance in loadClient.InOut_entityInstances.Items)
      {
        Assert.AreNotEqual(Guid.Empty, entityInstance.Id);
        EntityInstance order;
        ordersByReferenceNumber.TryGetValue(entityInstance["ReferenceNumber"].Value.ToString(), out order);
        Assert.IsNotNull(order);
      }
    }

    [Test]
    [Category("SaveLoadAndUpdateContractForOrderUsingEntityInstance")]
    public void SaveLoadAndUpdateContractForOrderUsingEntityInstance()
    {
      CleanData();

      // Create Order
      EntityInstance order = orderEntity.GetEntityInstance();
      InitializeOrder(ref order);

      var saveOrderClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveOrderClient.UserName = clientUserName;
      saveOrderClient.Password = clientPassword;
      saveOrderClient.InOut_entityInstance = order;
      saveOrderClient.Invoke();

      Assert.IsNotNull(saveOrderClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveOrderClient.InOut_entityInstance.Id);
      CompareOrders(order, saveOrderClient.InOut_entityInstance);

      // Create Contract
      EntityInstance contract = contractEntity.GetEntityInstance();
      InitializeContract(ref contract);

      var saveContractClient = new EntityInstanceService_CreateEntityInstanceFor_Client();

      saveContractClient.UserName = clientUserName;
      saveContractClient.Password = clientPassword;
      saveContractClient.In_forEntityName = orderEntity.FullName;
      saveContractClient.In_forEntityId = saveOrderClient.InOut_entityInstance.Id;
      saveContractClient.InOut_entityInstance = contract;
      saveContractClient.Invoke();

      // Load Contract for Order
      var loadContractClient = new EntityInstanceService_LoadEntityInstanceFor_Client();
      loadContractClient.UserName = clientUserName;
      loadContractClient.Password = clientPassword;
      loadContractClient.In_entityName = contractEntity.FullName;
      loadContractClient.In_forEntityName = orderEntity.FullName;
      loadContractClient.In_forEntityId = saveOrderClient.InOut_entityInstance.Id;
      loadContractClient.Invoke();

      // Verify
      Assert.IsNotNull(loadContractClient.Out_entityInstance);
      Assert.AreEqual(saveContractClient.InOut_entityInstance.Id, loadContractClient.Out_entityInstance.Id);
      CompareContracts(saveContractClient.InOut_entityInstance, loadContractClient.Out_entityInstance);

      // Update Contract
      string updatedDescription = "Updated Contract Description";
      string updatedReference = "Updated Ref# - " + random.Next();

      saveContractClient.InOut_entityInstance["Description"].Value = updatedDescription;
      saveContractClient.InOut_entityInstance["ReferenceNumber"].Value = updatedReference;

      var updateContractClient = new EntityInstanceService_SaveEntityInstance_Client();

      updateContractClient.UserName = clientUserName;
      updateContractClient.Password = clientPassword;
      updateContractClient.InOut_entityInstance = saveContractClient.InOut_entityInstance;
      updateContractClient.Invoke();
      
      // Load Contract
      var loadClient = new EntityInstanceService_LoadEntityInstance_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = contractEntity.FullName;
      loadClient.In_id = saveContractClient.InOut_entityInstance.Id;
      loadClient.Invoke();

      // Verify
      Assert.IsNotNull(loadClient.Out_entityInstance);
      Assert.AreEqual(saveContractClient.InOut_entityInstance.Id, loadClient.Out_entityInstance.Id);
      CompareContracts(saveContractClient.InOut_entityInstance, loadClient.Out_entityInstance);

      // Try to create another Contract for Order. Should fail
      try
      {
        saveContractClient.InOut_entityInstance = contract;
        saveContractClient.Invoke();
        Assert.Fail("Expected 'FaultException<MASBasicFaultDetail>'");
      }
      catch (FaultException<MASBasicFaultDetail> e)
      {
        Assert.AreEqual(1, e.Detail.ErrorMessages.Count);
        Assert.IsTrue(e.Detail.ErrorMessages[0].StartsWith("Error creating entity instance of type '" + contractEntity.FullName + "' for type '" + orderEntity.FullName + "'"));
      }

    }

    [Test]
    [Category("TestPaging")]
    public void TestPaging()
    {
      CleanData();

      var orders = new List<EntityInstance>();
      var entityInstances = new SortedList<string, EntityInstance>();


      for (int i = 0; i < 10; i++)
      {
        EntityInstance order = orderEntity.GetEntityInstance();
        InitializeOrder(ref order);
        orders.Add(order);
        entityInstances.Add(order["ReferenceNumber"].Value.ToString(), order);
      }

      var saveClient = new EntityInstanceService_SaveEntityInstances_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstances = orders;
      saveClient.Invoke();

      // Retrieve first page with a page size of 3
      MTList<EntityInstance> mtList = new MTList<EntityInstance>();
      int pageSize = 3;
      mtList.PageSize = pageSize;
      mtList.CurrentPage = 1;

      var loadClient = new EntityInstanceService_LoadEntityInstances_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = orderEntity.FullName;
      loadClient.InOut_entityInstances = mtList;
      loadClient.Invoke();

      var firstPageInstances = loadClient.InOut_entityInstances;
      Assert.AreEqual(pageSize, firstPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in firstPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["ReferenceNumber"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareOrders(oldInstance, currentInstance);
      }

      // Retrieve second page 
      loadClient.InOut_entityInstances.CurrentPage = 2;
      loadClient.Invoke();

      var secondPageInstances = loadClient.InOut_entityInstances;
      Assert.AreEqual(pageSize, secondPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in secondPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["ReferenceNumber"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareOrders(oldInstance, currentInstance);

        // Second page instances cannot be the same as first page instances
        foreach (EntityInstance instance in firstPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }
      }

      // Retrieve third page
      loadClient.InOut_entityInstances.CurrentPage = 3;
      loadClient.Invoke();

      var thirdPageInstances = loadClient.InOut_entityInstances;
      Assert.AreEqual(pageSize, thirdPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in thirdPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["ReferenceNumber"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareOrders(oldInstance, currentInstance);

        // Third page instances cannot be the same as first page instances
        foreach (EntityInstance instance in firstPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }

        // Third page instances cannot be the same as second page instances
        foreach (EntityInstance instance in secondPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }
      }

      // Retrieve fourth page
      loadClient.InOut_entityInstances.CurrentPage = 4;
      loadClient.Invoke();

      var fourthPageInstances = loadClient.InOut_entityInstances;
      Assert.AreEqual(1, fourthPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in fourthPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["ReferenceNumber"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareOrders(oldInstance, currentInstance);

        // Fourth page instances cannot be the same as first page instances
        foreach (EntityInstance instance in firstPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }

        // Fourth page instances cannot be the same as second page instances
        foreach (EntityInstance instance in secondPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }

        // Fourth page instances cannot be the same as third page instances
        foreach (EntityInstance instance in thirdPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }
      }
    }
    #endregion

    #region Use Type
    #endregion

    #region Private Methods
    public static void InitializeOrder(ref Order order)
    {
      order.BusinessKey.ReferenceNumber = "Ref#-" + random.Next();
      order.Description = "Test Order";
      order.InvoiceMethod = InvoiceMethod.Standard;
    }

    public static void InitializeOrder(ref EntityInstance order)
    {
      order["ReferenceNumber"].Value = "Ref#-" + random.Next();
      order["Description"].Value = "Test Order";
      order["InvoiceMethod"].Value = InvoiceMethod.Standard;
    }

    public static void InitializeOrderItem(ref Order orderItem)
    {
      orderItem.BusinessKey.ReferenceNumber = "Ref#-" + random.Next();
      orderItem.Description = "Test OrderItem";
    }

    public static void InitializeOrderItem(ref EntityInstance orderItem)
    {
      orderItem["ReferenceNumber"].Value = "Ref#-" + random.Next();
      orderItem["Description"].Value = "Test OrderItem";
    }

    public static void InitializeContract(ref Contract contract)
    {
      contract.BusinessKey.ReferenceNumber = "Ref#-" + random.Next();
      contract.Description = "Test Contract";
    }

    public static void InitializeContract(ref EntityInstance contract)
    {
      contract["ReferenceNumber"].Value = "Ref#-" + random.Next();
      contract["Description"].Value = "Test Contract";
    }

    public static void CompareOrders(Order originalOrder, Order newOrder)
    {
      Assert.AreEqual(originalOrder.BusinessKey.ReferenceNumber, newOrder.BusinessKey.ReferenceNumber);
      Assert.AreEqual(originalOrder.Description, newOrder.Description);
      Assert.AreEqual(originalOrder.InvoiceMethod, newOrder.InvoiceMethod);
    }

    public static void CompareOrders(EntityInstance originalOrder, EntityInstance newOrder)
    {
      Assert.AreEqual(originalOrder["ReferenceNumber"].Value, newOrder["ReferenceNumber"].Value);
      Assert.AreEqual(originalOrder["Description"].Value, newOrder["Description"].Value);
      Assert.AreEqual(originalOrder["InvoiceMethod"].Value, newOrder["InvoiceMethod"].Value);
    }

    public static void CompareOrderItems(EntityInstance originalOrderItem, EntityInstance newOrderItem)
    {
      Assert.AreEqual(originalOrderItem["ReferenceNumber"].Value, newOrderItem["ReferenceNumber"].Value);
      Assert.AreEqual(originalOrderItem["Description"].Value, newOrderItem["Description"].Value);
    }

    public static void CompareContracts(EntityInstance originalContract, EntityInstance newContract)
    {
      Assert.AreEqual(originalContract["ReferenceNumber"].Value, newContract["ReferenceNumber"].Value);
      Assert.AreEqual(originalContract["Description"].Value, newContract["Description"].Value);
    }

    private void CleanData()
    {
      var deleteClient = new EntityInstanceService_DeleteAll_Client();
      deleteClient.UserName = clientUserName;
      deleteClient.Password = clientPassword;
      deleteClient.In_entityName = orderItemEntity.FullName;

      // Delete Order_Contract
      var order_contract = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order_Contract");
      Assert.IsNotNull(order_contract);
      deleteClient.In_entityName = order_contract.FullName;
      deleteClient.Invoke();

      // Delete Order_OrderItem
      var order_orderItem = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order_OrderItem");
      Assert.IsNotNull(order_orderItem);
      deleteClient.In_entityName = order_orderItem.FullName;
      deleteClient.Invoke();

      // Delete OrderItem_Product
      var orderItem_product = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.OrderItem_Product");
      Assert.IsNotNull(orderItem_product);
      deleteClient.In_entityName = orderItem_product.FullName;
      deleteClient.Invoke();


      // Delete Order's
      deleteClient.In_entityName = orderEntity.FullName;
      deleteClient.Invoke();

      // Delete OrderItems's
      deleteClient.In_entityName = orderItemEntity.FullName;
      deleteClient.Invoke();

      // Delete Product's
      deleteClient.In_entityName = productEntity.FullName;
      deleteClient.Invoke();

      // Delete Contract's
      deleteClient.In_entityName = contractEntity.FullName;
      deleteClient.Invoke();
    }
    #endregion

    #region Data
    private static Entity orderEntity;
    private static Entity orderItemEntity;
    private static Entity productEntity;
    private static Entity contractEntity;
    private static Random random = new Random();
    // private static bool synchronized;
    private static string clientUserName = "su";
    private static string clientPassword = "su123";
    #endregion
  }
}
