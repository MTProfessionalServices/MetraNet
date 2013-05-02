using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Global;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.Service.EntityInstanceServiceTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.Service
{
  [TestFixture]
  public class EntityInstanceServiceTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      //#region Uncomment after testing
      //if (initialized)
      //{
      //  return;
      //}

      //// Create BE directories for extension.
      //SystemConfig.CreateBusinessEntityDirectories(extensionName, firstEntityGroupName);
      //// SystemConfig.CreateBusinessEntityDirectories(extensionName, secondEntityGroupName);

      //// Clean BE directories for extension.
      //Name.CleanEntityDir(extensionName, firstEntityGroupName);
      //// SystemConfig.CleanEntityDir(extensionName, secondEntityGroupName);

      //#region Create Entities, Relationship, Save

      //#region FirstEntityGroup
      //A = MetadataTests.CreateEntity("A", extensionName, firstEntityGroupName);
      //B = MetadataTests.CreateEntity("B", extensionName, firstEntityGroupName);
      //C = MetadataTests.CreateEntity("C", extensionName, firstEntityGroupName);
      //D = MetadataTests.CreateEntity("D", extensionName, firstEntityGroupName);
      //E = MetadataTests.CreateEntity("E", extensionName, firstEntityGroupName);

      //// Create relationship A -< B (one-to-many)
      //MetadataAccess.Instance.CreateOneToManyRelationship(ref A, ref B);

      //// Create relationship B -< C (one-to-many)
      //MetadataAccess.Instance.CreateOneToManyRelationship(ref B, ref C);

      //// Create relationship A -- D (one-to-one)
      //MetadataAccess.Instance.CreateOneToOneRelationship(ref A, ref D);

      //// Create relationship A >-< E (many-to-many)
      //MetadataAccess.Instance.CreateManyToManyRelationship(ref A, ref E);

      //// Get MetranetEntities
      //List<IMetranetEntity> metranetEntities = MetadataAccess.Instance.GetMetraNetEntities();
      //Assert.IsTrue(metranetEntities.Count > 0);

      //// Get AccountDef
      //accountDef =
      //  metranetEntities.Find(m => m.MetraNetEntityConfig.TypeName == "MetraTech.BusinessEntity.Core.Model.AccountDef") as AccountDef;
      //Assert.IsNotNull(accountDef);

      //// Associate A with AccountDef
      //MetadataAccess.Instance.AddMetranetEntityAssociation(ref A, accountDef, Multiplicity.Many);

      //// Save
      //MetadataAccess.Instance.SaveEntities(new List<Entity> { A, B, C, D, E });
      //#endregion

      //#region SecondEntityGroup
      ////Z = MetadataTests.CreateEntity("Z", extensionName, secondEntityGroupName);

      ////// Create relationship Z --< A (one-to-many)
      ////MetadataAccess.Instance.CreateOneToManyRelationship(ref Z, ref A);

      ////// Save
      ////MetadataAccess.Instance.SaveEntities(new List<Entity> { Z });
      //#endregion

      //#endregion

      //// Synchronize
      //MetadataAccess.Instance.Synchronize(extensionName);

      //// Synchronize OrderManagement
      //// MetadataAccess.Instance.Synchronize("SmokeTest", "OrderManagement");

      //initialized = true;
      //#endregion

      //#region Remove after testing

      //A = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.A");
      //B = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.B");
      //C = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.C");
      //D = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.D");
      //E = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.E");

      //#endregion
    }

    [Test]
    [Category("TestSynchronizeOrderManagement")]
    public void TestSynchronizeOrderManagement()
    {
      Entity site = MetadataAccess.Instance.GetEntity("Core.UI.Site");
      EntityInstance instance = site.GetEntityInstance();

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      instance["SiteName"].Value = "Site - " + random.Next();
      instance["Description"].Value = "the Site";
      instance["RootUrl"].Value = "http:\\localhost";
      instance["Theme"].Value = "Some theme";
      instance["Timezone"].Value = TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

      saveClient.UserName = "su";
      saveClient.Password = "su123";
      saveClient.InOut_entityInstance = instance;
      saveClient.Invoke();

      Entity dashboard = MetadataAccess.Instance.GetEntity("Core.UI.Dashboard");
      EntityInstance dashboardInstance = dashboard.GetEntityInstance();

      dashboardInstance["Name"].Value = "Dashboard - " + random.Next();
      dashboardInstance["Description"].Value = "the Dashboard";
      dashboardInstance["Title"].Value = "Title";

      var createForClient = new EntityInstanceService_CreateEntityInstanceFor_Client();
      createForClient.In_forEntityId = saveClient.InOut_entityInstance.Id;
      createForClient.In_forEntityName = site.FullName;
      createForClient.InOut_entityInstance = dashboardInstance;
      createForClient.UserName = "su";
      createForClient.Password = "su123";
      createForClient.Invoke();
    }

    [Test]
    [Category("TestSaveAndLoadAndDeleteEntityInstance")]
    public void TestSaveAndLoadAndDeleteEntityInstance()
    {
      CleanData();

      EntityInstance instanceA = A.GetEntityInstance();
      InitializeData(instanceA);

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = instanceA;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveClient.InOut_entityInstance.Id);
      CompareEntityInstances(instanceA, saveClient.InOut_entityInstance);

      saveClient.InOut_entityInstance["Int32Prop"].Value = 22222;
      saveClient.InOut_entityInstance["StringProp"].Value = "Ref-#" + random.Next();

      saveClient.Invoke();

      // Load
      var loadClient = new EntityInstanceService_LoadEntityInstance_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = saveClient.InOut_entityInstance.EntityFullName;
      loadClient.In_id = saveClient.InOut_entityInstance.Id;
      loadClient.Invoke();

      // Verify
      Assert.IsNotNull(loadClient.Out_entityInstance, "loadClient.InOut_entityInstance cannot be null");
      Assert.AreEqual(saveClient.InOut_entityInstance.Id, loadClient.Out_entityInstance.Id);
      CompareEntityInstances(saveClient.InOut_entityInstance, saveClient.InOut_entityInstance);

      // Delete
      var deleteClient = new EntityInstanceService_DeleteEntityInstanceUsingEntityName_Client();
      deleteClient.UserName = clientUserName;
      deleteClient.Password = clientPassword;
      deleteClient.In_entityName = saveClient.InOut_entityInstance.EntityFullName;
      deleteClient.In_id = saveClient.InOut_entityInstance.Id;
      deleteClient.Invoke();

      // Verify
      loadClient.Invoke();
      Assert.IsNull(loadClient.Out_entityInstance);
    }

    [Test]
    [Category("TestSaveAndLoadEntityInstances")]
    public void TestSaveAndLoadEntityInstances()
    {
      CleanData();

      var entityInstances = new List<EntityInstance>();

      for (int i = 0; i < 50; i++)
      {
        EntityInstance instanceA = A.GetEntityInstance();
        InitializeData(instanceA);
        entityInstances.Add(instanceA);
      }

      // Save
      var saveClient = new EntityInstanceService_SaveEntityInstances_Client();
      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstances = entityInstances;
      saveClient.Invoke();

      foreach (EntityInstance entityInstance in saveClient.InOut_entityInstances)
      {
        Assert.AreNotEqual(Guid.Empty, entityInstance.Id);
      }

      // Load
      var loadClient = new EntityInstanceService_LoadEntityInstances_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = A.FullName;
      loadClient.InOut_entityInstances = new MTList<EntityInstance>();
      loadClient.Invoke();

      // Verify
      Assert.IsNotNull(loadClient.InOut_entityInstances.Items);
      Assert.AreEqual(50, loadClient.InOut_entityInstances.Items.Count);


    }

    [Test]
    [Category("TestSaveAndLoadEntityInstancesForMetranetEntity")]
    public void TestSaveAndLoadEntityInstancesForMetranetEntity()
    {
      CleanData();

      // Sorted by StringProp value
      var entityInstances = new SortedList<string, EntityInstance>();

      // Create 3 instances with AccountId and 2 without AccountId
      var accountId = 123;
      var instancesWithAccountId = 3;
      var totalInstances = 5;

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;

      for (int i = 0; i < totalInstances; i++)
      {
        var instanceA = A.GetEntityInstance();
        InitializeData(instanceA);

        // Should have 3 instances with account id
        if (i < instancesWithAccountId)
        {
          // AccountId: New property created because of the association with AccountDef
          instanceA["AccountId"].Value = accountId;
        }

        entityInstances.Add(instanceA["StringProp"].Value.ToString(), instanceA);
        saveClient.InOut_entityInstance = instanceA;
        saveClient.Invoke();
      }

      // Load all instances, should be 5.
      var loadClient = new EntityInstanceService_LoadEntityInstances_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = A.FullName;
      loadClient.InOut_entityInstances = new MTList<EntityInstance>();
      loadClient.Invoke();

      Assert.AreEqual(5, loadClient.InOut_entityInstances.Items.Count);

      // Load instances for account id: 123. Should get back only 3
      ((AccountDef)accountDef).AccountId = accountId;

      var loadForMetranetEntityClient = new EntityInstanceService_LoadEntityInstancesForMetranetEntity_Client();
      loadForMetranetEntityClient.UserName = clientUserName;
      loadForMetranetEntityClient.Password = clientPassword;
      loadForMetranetEntityClient.In_entityName = A.FullName;
      loadForMetranetEntityClient.In_metranetEntity = (MetranetEntity)accountDef;
      loadForMetranetEntityClient.InOut_mtList = new MTList<EntityInstance>();
      loadForMetranetEntityClient.Invoke();

      Assert.AreEqual(3, loadForMetranetEntityClient.InOut_mtList.Items.Count);
      foreach (EntityInstance entityInstance in loadForMetranetEntityClient.InOut_mtList.Items)
      {
        Assert.AreEqual(accountId, entityInstance["AccountId"].Value);
      }
    }

    [Test]
    [Category("TestCreateEntityInstanceFor")]
    public void TestCreateEntityInstanceFor()
    {
      CleanData();

      // Create A
      EntityInstance instanceA = A.GetEntityInstance();
      InitializeData(instanceA);

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = instanceA;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveClient.InOut_entityInstance.Id);
      CompareEntityInstances(instanceA, saveClient.InOut_entityInstance);

      // Create D for A
      EntityInstance instanceD = D.GetEntityInstance();
      InitializeData(instanceD);

      var createClient = new EntityInstanceService_CreateEntityInstanceFor_Client();

      createClient.UserName = clientUserName;
      createClient.Password = clientPassword;
      createClient.In_forEntityName = A.FullName;
      createClient.In_forEntityId = saveClient.InOut_entityInstance.Id;
      createClient.InOut_entityInstance = instanceD;
      createClient.Invoke();

      Assert.IsNotNull(createClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, createClient.InOut_entityInstance.Id);
      CompareEntityInstances(instanceD, createClient.InOut_entityInstance);
    }

    [Test]
    [Category("TestCreateEntityInstancesFor")]
    public void TestCreateEntityInstancesFor()
    {
      CleanData();

      // Create A
      EntityInstance instanceA = A.GetEntityInstance();
      InitializeData(instanceA);

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = instanceA;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);
      Assert.AreNotEqual(Guid.Empty, saveClient.InOut_entityInstance.Id);
      CompareEntityInstances(instanceA, saveClient.InOut_entityInstance);

      // Create B's
      var Bs = new List<EntityInstance>();

      for (int i = 0; i < 10; i++)
      {
        EntityInstance instanceB = B.GetEntityInstance();
        InitializeData(instanceB);
        Bs.Add(instanceB);
      }

      var createClient = new EntityInstanceService_CreateEntityInstancesFor_Client();

      createClient.UserName = clientUserName;
      createClient.Password = clientPassword;
      createClient.In_forEntityName = A.FullName;
      createClient.In_forEntityId = saveClient.InOut_entityInstance.Id;
      createClient.InOut_entityInstances = Bs;
      createClient.Invoke();

      Assert.IsNotNull(createClient.InOut_entityInstances);

      // Load B's, should be 10.
      var loadClient = new EntityInstanceService_LoadEntityInstances_Client();
      loadClient.UserName = clientUserName;
      loadClient.Password = clientPassword;
      loadClient.In_entityName = B.FullName;
      loadClient.InOut_entityInstances = new MTList<EntityInstance>();
      loadClient.Invoke();

      Assert.AreEqual(10, loadClient.InOut_entityInstances.Items.Count);

    }

    [Test]
    [Category("TestLoadEntityInstanceByBusinessKey")]
    public void TestLoadEntityInstanceByBusinessKey()
    {
      Entity orderEntity = MetadataRepository.Instance.GetEntity("SmokeTest.OrderManagement.Order");
      EntityInstance orderInstance = orderEntity.GetEntityInstance();

      orderInstance["ReferenceNumber"].Value = "Ref#-" + random.Next();

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      saveClient.UserName = clientUserName;
      saveClient.Password = clientPassword;
      saveClient.InOut_entityInstance = orderInstance;
      saveClient.Invoke();

      Assert.IsNotNull(saveClient.InOut_entityInstance);

      // Get the business key properties for A
      var getBusinessKeyPropertiesClient = new EntityInstanceService_GetEntityInstanceBusinessKeyProperties_Client();
      getBusinessKeyPropertiesClient.UserName = clientUserName;
      getBusinessKeyPropertiesClient.Password = clientPassword;
      getBusinessKeyPropertiesClient.In_entityName = orderEntity.FullName;
      getBusinessKeyPropertiesClient.Invoke();

      
      List<PropertyInstance> businessKeyProperties = getBusinessKeyPropertiesClient.Out_propertyInstances;

      // Initialize the business key properties with the data from the original business entity
      foreach(PropertyInstance propertyInstance in businessKeyProperties)
      {
        propertyInstance.Value = orderInstance[propertyInstance.Name].Value;
      }

      // Load the the entity instance using business key
      var loadEntityInstanceByBusinessKeyClient = new EntityInstanceService_LoadEntityInstanceByBusinessKey_Client();
      loadEntityInstanceByBusinessKeyClient.UserName = clientUserName;
      loadEntityInstanceByBusinessKeyClient.Password = clientPassword;
      loadEntityInstanceByBusinessKeyClient.In_entityName = orderEntity.FullName;
      loadEntityInstanceByBusinessKeyClient.In_businessKeyProperties = businessKeyProperties;
      loadEntityInstanceByBusinessKeyClient.Invoke();

      Assert.IsNotNull(loadEntityInstanceByBusinessKeyClient.Out_entityInstance);
      Assert.AreEqual(saveClient.InOut_entityInstance.Id, loadEntityInstanceByBusinessKeyClient.Out_entityInstance.Id);
    }

    #region Private Methods
    public static void InitializeData(EntityInstance entityInstance)
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

    public static void CompareEntityInstances(EntityInstance entityInstanceA, EntityInstance entityInstanceB)
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

      // The following deletes will not be necessary once cascade delete is implemented.
      // Delete the root (A) should delete all the related entities.

      // Delete A_B
      var a_b = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.A_B");
      Assert.IsNotNull(a_b);
      standardRepository.Delete(a_b.FullName);

      // Delete B_C
      var b_c = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.B_C");
      Assert.IsNotNull(b_c);
      standardRepository.Delete(b_c.FullName);

      // Delete A_D
      var a_d = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.A_D");
      Assert.IsNotNull(a_d);
      standardRepository.Delete(a_d.FullName);

      // Delete A_E
      var a_e = MetadataAccess.Instance.GetEntity("EntityInstanceServiceTest.First.A_E");
      Assert.IsNotNull(a_e);
      standardRepository.Delete(a_e.FullName);

      // Delete A's
      standardRepository.Delete(A.FullName);

      // Delete B's
      standardRepository.Delete(B.FullName);

      // Delete C's
      standardRepository.Delete(C.FullName);

      // Delete D's
      standardRepository.Delete(D.FullName);

      // Delete E's
      standardRepository.Delete(E.FullName);
    }
    #endregion

    #region Data
    // private static string extensionName = "EntityInstanceServiceTest";
    // private static string firstEntityGroupName = "First";
    // private static string secondEntityGroupName = "Second";
    private static Entity A = null;
    private static Entity B = null;
    private static Entity C = null;
    private static Entity D = null;
    private static Entity E = null;
    // private static Entity Z;
#pragma warning disable 649
    private static IMetranetEntity accountDef;
#pragma warning restore 649
    private static Random random = new Random();
    private static readonly string clientUserName = "su";
    private static readonly string clientPassword = "su123";
    // private static bool initialized;
    #endregion
  }
}
