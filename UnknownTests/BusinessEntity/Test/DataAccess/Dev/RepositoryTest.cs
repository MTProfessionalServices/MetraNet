using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using SmokeTest.OrderManagement;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Persistence;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using NUnit.Framework;

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  public class RepositoryTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {

      if (initialized)
      {
        return;
      }

      // Create BE directories for 'RepositoryTest' extension.
      SystemConfig.CreateBusinessEntityDirectories(extensionName, firstEntityGroupName);
      SystemConfig.CreateBusinessEntityDirectories(extensionName, secondEntityGroupName);

      // Clean BE directories for 'RepositoryTest' extension.
      SystemConfig.CleanEntityDir(extensionName, firstEntityGroupName);
      SystemConfig.CleanEntityDir(extensionName, secondEntityGroupName);


      #region Create Entities, Relationship, Save

      #region FirstEntityGroup
      A = MetadataTests.CreateEntity("A", extensionName, firstEntityGroupName);
      B = MetadataTests.CreateEntity("B", extensionName, firstEntityGroupName);
      C = MetadataTests.CreateEntity("C", extensionName, firstEntityGroupName);
      D = MetadataTests.CreateEntity("D", extensionName, firstEntityGroupName);
      E = MetadataTests.CreateEntity("E", extensionName, firstEntityGroupName);

      // Create relationship A -< B (one-to-many)
      MetadataAccess.Instance.CreateOneToManyRelationship(ref A, ref B);

      // Create relationship B -< C (one-to-many)
      MetadataAccess.Instance.CreateOneToManyRelationship(ref B, ref C);

      // Create relationship A -- D (one-to-one)
      MetadataAccess.Instance.CreateOneToOneRelationship(ref A, ref D);

      // Create relationship A >-< E (many-to-many)
      MetadataAccess.Instance.CreateManyToManyRelationship(ref A, ref E);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity> { A, B, C, D, E });
      #endregion

      #region SecondEntityGroup
      //Z = MetadataTests.CreateEntity("Z", extensionName, secondEntityGroupName);

      //// Create relationship Z --< A (one-to-many)
      //MetadataAccess.Instance.CreateOneToManyRelationship(ref Z, ref A);

      //// Save
      //MetadataAccess.Instance.SaveEntities(new List<Entity> { Z });
      #endregion

      #endregion

      // Synchronize
      MetadataAccess.Instance.Synchronize(extensionName);

      // Synchronize OrderManagement
      MetadataAccess.Instance.Synchronize("SmokeTest", "OrderManagement");

      initialized = true;
    }

    [Test]
    public void TestOneToOneUsingType()
    {
      // Between Order and Contract
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Get Order, Contract, Order_Contract
      Entity orderEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order");
      Assert.IsNotNull(orderEntity);
      Entity contractEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Contract");
      Assert.IsNotNull(contractEntity);
      Entity order_ContractEntity = MetadataAccess.Instance.GetEntity("SmokeTest.OrderManagement.Order_Contract");
      Assert.IsNotNull(order_ContractEntity);

      // Clean Order_Contract
      standardRepository.Delete(order_ContractEntity.FullName);
      // Clean Order
      standardRepository.Delete(orderEntity.FullName);
      // Clean Contract
      standardRepository.Delete(contractEntity.FullName);

      // Create Order
      var order = new Order();
      order.BusinessKey = new OrderBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()};
      order.Description = "test order";
      order.InvoiceMethod = InvoiceMethod.Standard;

      // Save order
      var currentOrder = standardRepository.SaveInstance(order) as Order;
      Assert.IsNotNull(currentOrder);
      Assert.IsTrue(currentOrder.Id != Guid.Empty);
      
      // Create Contract
      var contract = new Contract();
      contract.BusinessKey = new ContractBusinessKey() { ReferenceNumber = "Ref#-" + random.Next() };
      contract.Description = "test contract";

      // Save contract
      var currentContract = 
        standardRepository.CreateInstanceFor(orderEntity.FullName, currentOrder.Id, contract) as Contract;
      Assert.IsNotNull(currentContract);
      Assert.IsTrue(currentContract.Id != Guid.Empty);

      // Save same contract. Expect to fail.
      try
      {
        standardRepository.CreateInstanceFor(orderEntity.FullName, currentOrder.Id, contract);
        Assert.Fail("Expected 'SaveDataException'");
      }
      catch (SaveDataException e)
      {
        Assert.IsNotNull(e.Errors);
        Assert.AreEqual(1, e.Errors.Count);
        Assert.IsTrue(e.Errors[0].Message.StartsWith("Cannot create a One-To-One relationship between"));
      }

      // Load Contract (for Order)
      var loadContract = standardRepository.LoadInstanceFor(contractEntity.FullName, orderEntity.FullName, currentOrder.Id) as Contract;
      Assert.IsNotNull(loadContract);
      Assert.AreEqual(currentContract.Id, loadContract.Id);
      Assert.AreEqual(currentContract.BusinessKey.ReferenceNumber, loadContract.BusinessKey.ReferenceNumber);

      // Load Order (for Contract)
      var loadOrder = standardRepository.LoadInstanceFor(orderEntity.FullName, contractEntity.FullName, currentContract.Id) as Order;
      Assert.IsNotNull(loadOrder);
      Assert.AreEqual(currentOrder.Id, loadOrder.Id);
      Assert.AreEqual(currentOrder.BusinessKey.ReferenceNumber, loadOrder.BusinessKey.ReferenceNumber);
    }

    [Test]
    public void TestOneToOneUsingEntityInstance()
    {
      // Between A and D

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Clean A_D
      RelationshipEntity relationshipEntity = A.GetRelationshipEntity(D.FullName);
      Assert.IsNotNull(relationshipEntity);
      standardRepository.Delete(relationshipEntity.FullName);

      // Clean A
      standardRepository.Delete(A.FullName);

      // Clean D
      standardRepository.Delete(D.FullName);

      // Create A
      var instanceA = A.GetEntityInstance();
      InitializeData(ref instanceA);

      // Save A
      var currentInstanceA = standardRepository.SaveEntityInstance(instanceA);
      Assert.IsTrue(currentInstanceA.Id != Guid.Empty);

      // Create D
      var instanceD = D.GetEntityInstance();
      InitializeData(ref instanceD);

      // Save D (for A)
      var currentInstanceD = standardRepository.CreateEntityInstanceFor(A.FullName, currentInstanceA.Id, instanceD);
      Assert.IsTrue(currentInstanceD.Id != Guid.Empty);

      // Save same D. Expect to fail.
      try
      {
        standardRepository.CreateEntityInstanceFor(A.FullName, currentInstanceA.Id, instanceD);
        Assert.Fail("Expected 'SaveDataException'");
      }
      catch (SaveDataException e)
      {
        Assert.IsNotNull(e.Errors);
        Assert.AreEqual(1, e.Errors.Count);
        Assert.IsTrue(e.Errors[0].Message.StartsWith("Cannot create a One-To-One relationship between"));
      }

      // Load D (for A)
      EntityInstance loadInstanceD = 
        standardRepository.LoadEntityInstanceFor(D.FullName, 
                                                 A.FullName, 
                                                 currentInstanceA.Id);
      Assert.IsNotNull(loadInstanceD);
      CompareEntityInstances(currentInstanceD, loadInstanceD);

      // Load A (for D)
      EntityInstance loadInstanceA =
        standardRepository.LoadEntityInstanceFor(A.FullName,
                                                 D.FullName,
                                                 loadInstanceD.Id);
      Assert.IsNotNull(loadInstanceD);
      CompareEntityInstances(currentInstanceA, loadInstanceA);

    }

    [Test]
    public void CanSaveEntityInstance()
    {

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      var instanceA = A.GetEntityInstance();
      instanceA["StringProp"].Value = "Ref#-" + random.Next();

      var currentInstanceA = standardRepository.SaveEntityInstance(instanceA);
      Assert.AreNotEqual(currentInstanceA.Id, Guid.Empty);
    }

    [Test]
    public void CanCreateLoadAndDeleteEntityInstance()
    {
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      var instanceA = A.GetEntityInstance();
      InitializeData(ref instanceA);

      var currentInstanceA = standardRepository.SaveEntityInstance(instanceA);
      Assert.IsTrue(currentInstanceA.Id != Guid.Empty);

      currentInstanceA = standardRepository.LoadEntityInstance(A.FullName, currentInstanceA.Id);

      CompareEntityInstances(instanceA, currentInstanceA);
     
      // Delete A
      standardRepository.Delete(A.FullName, currentInstanceA.Id);

      // Verify
      currentInstanceA = standardRepository.LoadEntityInstance(A.FullName, currentInstanceA.Id);
      Assert.IsNull(currentInstanceA);
    }

    [Test]
    public void CanLoadAndDeleteEntityInstances()
    {
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Delete any existing B's
      standardRepository.Delete(B.FullName);

      // Delete any existing A's
      standardRepository.Delete(A.FullName);

      // Sorted by StringProp value
      var entityInstances = new SortedList<string, EntityInstance>();
      
      for (int i = 0; i < 5; i++)
      {
        var instanceA = A.GetEntityInstance();
        InitializeData(ref instanceA);

        entityInstances.Add(instanceA["StringProp"].Value.ToString(), instanceA);
        standardRepository.SaveEntityInstance(instanceA);
      }

      // Retrieve all A's
      var currentInstances = standardRepository.LoadEntityInstances(A.FullName, new MTList<EntityInstance>());

      Assert.AreEqual(entityInstances.Count, currentInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in currentInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["StringProp"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);
      }

      // Delete all A's
      standardRepository.Delete(A.FullName);

      // Verify
      currentInstances =
        standardRepository.LoadEntityInstances(A.FullName, new MTList<EntityInstance>());
      Assert.AreEqual(0, currentInstances.Items.Count);

    }

    [Test]
    public void CanLoadEntityInstancesForMetranetEntity()
    {
      // Get AccountDef
      List<IMetranetEntity> metranetEntities = MetadataAccess.Instance.GetMetraNetEntities();
      Assert.IsTrue(metranetEntities.Count > 0);

      var accountDef =
        metranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef") as AccountDef;
      Assert.IsNotNull(accountDef);

      // Associate A with AccountDef
      MetadataAccess.Instance.AddMetranetEntityAssociation(ref A, accountDef, Multiplicity.Many);

      // Save A
      MetadataAccess.Instance.SaveEntity(A);

      // Create Schema
      MetadataAccess.Instance.CreateSchema(extensionName, firstEntityGroupName);

      // Create data
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Delete any existing A's
      standardRepository.Delete(A.FullName);

      // Sorted by StringProp value
      var entityInstances = new SortedList<string, EntityInstance>();

      // Create 2 instances without AccountId and 3 with AccountId
      var accountId = 123;
      var instancesWithAccountId = 3;
      var totalInstances = 5;

      for (int i = 0; i < totalInstances; i++)
      {
        var instanceA = A.GetEntityInstance();
        InitializeData(ref instanceA);

        // Should have 3 instances with account id
        if (i < instancesWithAccountId)
        {
          // AccountId: New property created because of the association with AccountDef
          instanceA["AccountId"].Value = accountId;
        }

        entityInstances.Add(instanceA["StringProp"].Value.ToString(), instanceA);
        standardRepository.SaveEntityInstance(instanceA);
      }

      // Load all instances, should be 5.
      var currentInstances = standardRepository.LoadEntityInstances(A.FullName, new MTList<EntityInstance>());
      Assert.AreEqual(totalInstances, currentInstances.Items.Count);

      // Load instances for account id: 123. Should get back only 3
      accountDef.AccountId = accountId;
      currentInstances =
        standardRepository.LoadEntityInstancesForMetranetEntity(A.FullName,
                                                                accountDef,
                                                                new MTList<EntityInstance>());
      Assert.AreEqual(instancesWithAccountId, currentInstances.Items.Count);

      foreach (EntityInstance currentInstance in currentInstances.Items)
      {
        EntityInstance oldInstance = entityInstances[currentInstance["StringProp"].Value.ToString()];
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);
      }
    }

    [Test]
    public void CanCreateSaveAndLoadEntityInstancesForParent()
    {
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Delete any existing A_B's
      standardRepository.Delete(B.Relationships[0].RelationshipEntity.FullName);

      // Delete any existing B's
      standardRepository.Delete(B.FullName);

      // Delete any existing A's
      standardRepository.Delete(A.FullName);

      // Create A
      var instanceA = A.GetEntityInstance();
      InitializeData(ref instanceA);

      // Save A
      var currentInstanceA = standardRepository.SaveEntityInstance(instanceA);

      // Create B's
      var entityInstancesB = new SortedList<string, EntityInstance>();
      int countB = 5;
      for (int i = 0; i < countB; i++)
      {
        var instanceB = B.GetEntityInstance();
        InitializeData(ref instanceB);
        entityInstancesB.Add(instanceB["StringProp"].Value.ToString(), instanceB);
      }

      // Save B's
      IList<EntityInstance> currentInstancesB =
        standardRepository.CreateEntityInstancesFor(currentInstanceA.EntityFullName, 
                                                    currentInstanceA.Id,
                                                    entityInstancesB.Values);
      Assert.AreEqual(countB, currentInstancesB.Count);
      foreach(EntityInstance currentInstance in currentInstancesB)
      {
        EntityInstance oldInstance = entityInstancesB[currentInstance["StringProp"].Value.ToString()];
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);
      }

      // Load B's for A.Id
      MTList<EntityInstance> mtList = 
        standardRepository.LoadEntityInstancesFor(B.FullName, 
                                                  A.FullName, 
                                                  currentInstanceA.Id, 
                                                  new MTList<EntityInstance>());

      Assert.AreEqual(countB, mtList.Items.Count);
      foreach (EntityInstance currentInstance in mtList.Items)
      {
        EntityInstance oldInstance = entityInstancesB[currentInstance["StringProp"].Value.ToString()];
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);
      }
    }

    [Test]
    public void CanPage()
    {
      CleanData();

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Create A's
      // Sorted by StringProp value
      var entityInstances = new SortedList<string, EntityInstance>();

      for (int i = 0; i < 10; i++)
      {
        var instanceA = A.GetEntityInstance();
        InitializeData(ref instanceA);

        entityInstances.Add(instanceA["StringProp"].Value.ToString(), instanceA);
        standardRepository.SaveEntityInstance(instanceA);
      }

      // Retrieve first page with a page size of 3
      MTList<EntityInstance> mtList = new MTList<EntityInstance>();
      mtList.PageSize = 3;
      mtList.CurrentPage = 1;

      var firstPageInstances = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(mtList.PageSize, firstPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in firstPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["StringProp"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);
      }

      // Retrieve second page 
      mtList.CurrentPage = 2;

      var secondPageInstances = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(mtList.PageSize, secondPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in secondPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["StringProp"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);

        // Second page instances cannot be the same as first page instances
        foreach(EntityInstance instance in firstPageInstances.Items)
        {
          Assert.AreNotEqual(instance.Id, currentInstance.Id);
        }
      }

      // Retrieve third page
      mtList.CurrentPage = 3;
      var thirdPageInstances = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(mtList.PageSize, thirdPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in thirdPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["StringProp"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);

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
      mtList.CurrentPage = 4;
      var fourthPageInstances = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, fourthPageInstances.Items.Count);

      // Verify
      foreach (EntityInstance currentInstance in fourthPageInstances.Items)
      {
        EntityInstance oldInstance;
        entityInstances.TryGetValue(currentInstance["StringProp"].Value.ToString(), out oldInstance);
        Assert.IsNotNull(oldInstance);
        CompareEntityInstances(oldInstance, currentInstance);

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

    [Test]
    public void CanFilter()
    {
      CleanData();

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      #region Create Data
      // Create instances 
      EntityInstance boolInstance = A.GetEntityInstance();
      InitializeData(ref boolInstance);
      bool boolValue = false;
      boolInstance["BooleanProp"].Value = boolValue;
      standardRepository.SaveEntityInstance(boolInstance);

      EntityInstance dateTimeInstance = A.GetEntityInstance();
      InitializeData(ref dateTimeInstance);
      DateTime dateTimeValue = DateTime.Now.AddDays(1);
      dateTimeInstance["DateTimeProp"].Value = dateTimeValue;
      standardRepository.SaveEntityInstance(dateTimeInstance);

      EntityInstance decimalInstance = A.GetEntityInstance();
      InitializeData(ref decimalInstance);
      decimal decimalValue = 3456.789M;
      decimalInstance["DecimalProp"].Value = decimalValue;
      standardRepository.SaveEntityInstance(decimalInstance);

      EntityInstance doubleInstance = A.GetEntityInstance();
      InitializeData(ref doubleInstance);
      double doubleValue = 5535.5678;
      doubleInstance["DoubleProp"].Value = doubleValue;
      standardRepository.SaveEntityInstance(doubleInstance);

      EntityInstance guidInstance = A.GetEntityInstance();
      InitializeData(ref guidInstance);
      Guid guidValue = Guid.NewGuid();
      guidInstance["GuidProp"].Value = guidValue;
      standardRepository.SaveEntityInstance(guidInstance);

      EntityInstance int32Instance = A.GetEntityInstance();
      InitializeData(ref int32Instance);
      int int32Value = 56789;
      int32Instance["Int32Prop"].Value = int32Value;
      standardRepository.SaveEntityInstance(int32Instance);

      EntityInstance int64Instance = A.GetEntityInstance();
      InitializeData(ref int64Instance);
      Int64 int64Value = 333344445555;
      int64Instance["Int64Prop"].Value = int64Value;
      standardRepository.SaveEntityInstance(int64Instance);

      EntityInstance stringInstance = A.GetEntityInstance();
      InitializeData(ref stringInstance);
      string stringValue = "Hello World! - йцукенгшщзхїфівапролджєячсмитьБЮбю";
      stringInstance["StringProp1"].Value = stringValue;
      standardRepository.SaveEntityInstance(stringInstance);

      EntityInstance enumInstance = A.GetEntityInstance();
      InitializeData(ref enumInstance);
      DayOfTheWeek enumValue = DayOfTheWeek.Monday;
      enumInstance["EnumProp"].Value = enumValue;
      standardRepository.SaveEntityInstance(enumInstance);

      #endregion

      #region Filter bool
      var mtList = new MTList<EntityInstance>();

      // Equal
      mtList.Filters.Add(new MTFilterElement("BooleanProp", MTFilterElement.OperationType.Equal, false));
      var filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(boolValue, filteredList.Items[0]["BooleanProp"].Value);
      #endregion

      #region Filter DateTime
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("DateTimeProp", MTFilterElement.OperationType.Less, dateTimeValue.Add(new TimeSpan(0, 0, 1))));
      mtList.Filters.Add(new MTFilterElement("DateTimeProp", MTFilterElement.OperationType.Greater, dateTimeValue.Subtract(new TimeSpan(0, 0, 1))));

      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      int i = (dateTimeValue.Subtract(new TimeSpan(0, 0, 1)).CompareTo(filteredList.Items[0]["DateTimeProp"].Value));
      Assert.AreEqual(-1, i);
      i = (dateTimeValue.Add(new TimeSpan(0, 0, 1)).CompareTo(filteredList.Items[0]["DateTimeProp"].Value));
      Assert.AreEqual(1, i);

      #endregion

      #region Filter Decimal
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("DecimalProp", MTFilterElement.OperationType.Equal, decimalValue));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(decimalValue, filteredList.Items[0]["DecimalProp"].Value);
      #endregion

      #region Filter Double
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("DoubleProp", MTFilterElement.OperationType.Equal, doubleValue));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(doubleValue, filteredList.Items[0]["DoubleProp"].Value);
      #endregion

      #region Filter Guid
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("GuidProp", MTFilterElement.OperationType.Equal, guidValue));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(guidValue, filteredList.Items[0]["GuidProp"].Value);
      #endregion

      #region Filter Int32
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("Int32Prop", MTFilterElement.OperationType.Equal, int32Value));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(int32Value, filteredList.Items[0]["Int32Prop"].Value);
      #endregion

      #region Filter Int64
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("Int64Prop", MTFilterElement.OperationType.Equal, int64Value));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(int64Value, filteredList.Items[0]["Int64Prop"].Value);
      #endregion

      #region Filter String

      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("StringProp1", MTFilterElement.OperationType.Equal, stringValue));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(stringValue, filteredList.Items[0]["StringProp1"].Value);

      // Like
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("StringProp1", MTFilterElement.OperationType.Like_W, "%" + stringValue + "%"));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(stringValue, filteredList.Items[0]["StringProp1"].Value);
      #endregion

      #region Filter Enum
      // Equal
      mtList.Filters.Clear();
      mtList.Filters.Add(new MTFilterElement("EnumProp", MTFilterElement.OperationType.Equal, enumValue));
      filteredList = standardRepository.LoadEntityInstances(A.FullName, mtList);
      Assert.AreEqual(1, filteredList.Items.Count);
      Assert.AreEqual(enumValue, filteredList.Items[0]["EnumProp"].Value);
      #endregion

    }

    [Test]
    public void CanSort()
    {
      CleanData();

      var standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      
    }

    [Test]
    public void CanCreateSaveAndLoadOrder()
    {
      List<Entity> entities = MetadataAccess.Instance.GetEntities();

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      #region Using Order
      MetadataAccess.Instance.CreateSchema("Core", "OrderManagement");
      Order order = new Order();
      order.BusinessKey.ReferenceNumber = "Ref1 - " + random.Next();
      order.Description = "Order Description";

      order = standardRepository.SaveInstance(order) as Order;

      Order order1 = new Order();
      order1.BusinessKey.ReferenceNumber = order.BusinessKey.ReferenceNumber;
      order1.Description = "Order Description";

      standardRepository.SaveInstance(order1);

      List<DataObject> orderItems =
        new List<DataObject>()
         {
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 1"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 2"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 3"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 4"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 5"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 6"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 7"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 8"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 9"},
           new OrderItem(){BusinessKey = new OrderItemBusinessKey() {ReferenceNumber = "Ref#-" + random.Next()}, Description = "Order Item 10"},
         };

      IList<DataObject> savedOrderItems =
        standardRepository.CreateInstancesFor(order.GetType().FullName, order.Id, orderItems);

      //int rowCount;
      //DataObject d = standardRepository.Load<Order>(new Guid("83FBD40F-3BEA-4F7A-9E49-9CA90176DC12"));


      //var mtList = new MTList<EntityInstance>();
      //// var orders = standardRepository.LoadAll<Order>(mtList);
      //var order = standardRepository.LoadEntityInstance("Core.OrderManagement.Order",
      //                                                  new Guid("83FBD40F-3BEA-4F7A-9E49-9CA90176DC12"));
      //var orderItems =
      //  standardRepository.LoadEntityInstancesForParent("Core.OrderManagement.OrderItem",
      //                                                  order.EntityFullName,
      //                                                  order.Id,
      //                                                  mtList);

      //orderItems.Items.RemoveRange(0, 3);
      //var selectedOrderItems = new List<EntityInstance>();
      //for (int i = 0; i < 3; i++)
      //{
      //  EntityInstance ei = orderItems.Items[i];
      //  ei["Description"].Value = "Updated " + i;
      //  selectedOrderItems.Add(ei);
      //}

      //selectedOrderItems = standardRepository.SaveEntityInstancesForParent(order.EntityFullName, order.Id, selectedOrderItems);




      standardRepository.Delete(typeof(Order).FullName, order.Id);
      #endregion

      #region Using EntityInstance
      //var order = MetadataAccess.Instance.GetEntity("Core.OrderManagement.Order");
      //Assert.IsNotNull(order, "Cannot find entity 'Core.OrderManagement.Order'");
      //var orderInstance = order.GetEntityInstance();

      //orderInstance["ReferenceNumber"].Value = "Ref#-" + random.Next();
      //orderInstance["Description"].Value = "Order description";

      //var currentOrderInstance = standardRepository.SaveEntityInstance(orderInstance);

      //Assert.AreNotEqual(orderInstance.Id, currentOrderInstance.Id);
      //Assert.AreEqual(orderInstance["ReferenceNumber"].Value, currentOrderInstance["ReferenceNumber"].Value);
      #endregion
    }



   
    

    
    #region Private Methods

    private static void InitializeData(ref EntityInstance entityInstance)
    {
      entityInstance["BooleanProp"].Value = true;
      entityInstance["DateTimeProp"].Value = DateTime.Now;
      entityInstance["DecimalProp"].Value = 123.456M;
      entityInstance["DoubleProp"].Value = 456.789;
      entityInstance["GuidProp"].Value = Guid.NewGuid();
      entityInstance["Int32Prop"].Value = random.Next();
      entityInstance["Int32Prop1"].Value = 12345;
      entityInstance["Int64Prop"].Value = Int64.MaxValue;
      entityInstance["StringProp"].Value = "Ref#-" + random.Next();
      entityInstance["StringProp1"].Value = "StringProp1-" + random.Next();
      entityInstance["StringProp2"].Value = "StringProp2-" + random.Next();
      entityInstance["EnumProp"].Value = DayOfTheWeek.Friday;
    }

    private static void CompareEntityInstances(EntityInstance entityInstanceA, EntityInstance entityInstanceB)
    {
      Assert.AreEqual(entityInstanceA["BooleanProp"].Value, entityInstanceB["BooleanProp"].Value);
      // Assert.IsTrue(entityInstanceA["DateTimeProp"].Value.Equals(entityInstanceB["DateTimeProp"].Value));
      Assert.AreEqual(entityInstanceA["DecimalProp"].Value, entityInstanceB["DecimalProp"].Value);
      Assert.AreEqual(entityInstanceA["DoubleProp"].Value, entityInstanceB["DoubleProp"].Value);
      Assert.AreEqual(entityInstanceA["GuidProp"].Value, entityInstanceB["GuidProp"].Value);
      Assert.AreEqual(entityInstanceA["Int32Prop"].Value, entityInstanceB["Int32Prop"].Value);
      Assert.AreEqual(entityInstanceA["Int64Prop"].Value, entityInstanceB["Int64Prop"].Value);
      Assert.AreEqual(entityInstanceA["StringProp"].Value, entityInstanceB["StringProp"].Value);
      Assert.AreEqual(entityInstanceA["EnumProp"].Value, entityInstanceB["EnumProp"].Value);
    }

    private void CleanData()
    {
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      Assert.IsNotNull(standardRepository);

      // Delete any existing C's
      standardRepository.Delete(C.FullName);

      // Delete any existing B's
      standardRepository.Delete(B.FullName);

      // Delete any existing A's
      standardRepository.Delete(A.FullName);
    }
    #endregion

    #region Data
    private static string extensionName = "RepositoryTest";
    private static string firstEntityGroupName = "First";
    private static string secondEntityGroupName = "Second";
    private static Entity A;
    private static Entity B;
    private static Entity C;
    private static Entity D;
    private static Entity E;
    // private static Entity Z;
    private static Random random = new Random();
    private static bool initialized = false;
    #endregion
  }
}
