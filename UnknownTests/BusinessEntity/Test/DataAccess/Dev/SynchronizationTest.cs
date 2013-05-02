using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using Core.Common;
using Core.UI;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using MetraTech.BusinessEntity.Service.ClientProxies;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.SynchronizationTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class SynchronizationTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      RepositoryAccess.Instance.Initialize();
      metadataAccess = MetadataAccess.Instance;
    }

    [Test]
    public void History()
    {
      var dbMetadataList =
       RepositoryAccess.Instance.GetDbMetadata
         ("NetMeter", new List<string>() { "t_be_cor_ui_Column", "t_be_cor_ui_Widget", "t_be_acc_arb_batch", "dummy" });

      MetadataRepository.Instance.GetAllPaths("AccountsReceivable.AROutgoingPayments.Refund",
                                              "AccountsReceivable.DebtExpression.DFP");

      BusinessEntityConfig.Instance.GetAssemblyCopyDirectories();

      IStandardRepository repository = RepositoryAccess.Instance.GetRepository();

      Entity parameterEntity = MetadataAccess.Instance.GetEntity("Core.UI.Parameter");
      parameterEntity.RecordHistory = true;

      Entity siteEntity = MetadataAccess.Instance.GetEntity("Core.UI.Site");
      siteEntity.RecordHistory = true;

     
      Entity billSettingEntity = MetadataAccess.Instance.GetEntity("Core.UI.BillSetting");
      billSettingEntity.RecordHistory = true;

      var syncData = new SyncData();
      syncData.AddModifiedEntity(siteEntity);
      syncData.AddModifiedEntity(billSettingEntity);
      syncData.AddModifiedEntity(parameterEntity);

      MetadataAccess.Instance.Synchronize(syncData);

      var random = new Random();

      Site site = null;
      for (int i = 0; i < 3; i++)
      {
        site = new Site();
        site.SiteBusinessKey.SiteName = "Site - " + random.Next();
        site = (Site) repository.SaveInstance(site);
      }

      site.Culture = "en-US";
      site = (Site)repository.SaveInstance(site);

      Thread.Sleep(100);
      DateTime dateTime = DateTime.Now.ToUniversalTime();
      Thread.Sleep(100);

      site.Description = "site description";
      site = (Site)repository.SaveInstance(site);

      site = (Site)repository.LoadInstanceHistory(siteEntity.FullName, site.Id, dateTime);

      BillSetting billSetting = null;
      for (int i = 0; i < 1; i++)
      {
        billSetting = new BillSetting();
        billSetting = (BillSetting)repository.SaveInstance(billSetting);
      }

      billSetting.AllowOnlinePayment = true;
      billSetting = (BillSetting)repository.SaveInstance(billSetting);

      billSetting.AllowSavedReports = true;
      billSetting = (BillSetting)repository.SaveInstance(billSetting);
    }

    [Test]
    public void Synchronize()
    {
      metadataAccess.Synchronize();
    }

    [Test]
    public void CreateNewEntity()
    {
      var entity = new Entity("BETest1.EG1.E1");
      entity.PluralName = "e1s";
      entity.TableName = MetadataAccess.Instance.CreateTableName(entity);

      entity.AddProperty(new Property("StringProp", "string"));

      var syncData = new SyncData();
      syncData.AddNewEntity(entity);

      metadataAccess.Synchronize(syncData);

      Assert.AreEqual(MetadataAccess.Instance.IsSynchronizedWithDb(entity.FullName), true);

      entity.AddProperty(new Property("IntProp", "int"));
      syncData.Clear();

      syncData.AddModifiedEntity(entity);
      metadataAccess.Synchronize(syncData);

      Assert.AreEqual(MetadataAccess.Instance.IsSynchronizedWithDb(entity.FullName), true);
    }

    [Test]
    public void TestRelationships()
    {
      var e1 = new Entity("BETest1.EG1.E1");
      e1.PluralName = "e1s";
      e1.TableName = MetadataAccess.Instance.CreateTableName(e1);
      e1.AddProperty(new Property("StringProp", "string"));

      var e2 = new Entity("BETest1.EG1.E2");
      e2.PluralName = "e2s";
      e2.TableName = MetadataAccess.Instance.CreateTableName(e2);
      e2.AddProperty(new Property("StringProp", "string"));

      var e3 = new Entity("BETest1.EG1.E3");
      e3.PluralName = "e3s";
      e3.TableName = MetadataAccess.Instance.CreateTableName(e3);
      e3.AddProperty(new Property("StringProp", "string"));

      var e4 = new Entity("BETest1.EG1.E4");
      e4.PluralName = "e4s";
      e4.TableName = MetadataAccess.Instance.CreateTableName(e4);
      e4.AddProperty(new Property("StringProp", "string"));

      var e5 = new Entity("BETest1.EG1.E5");
      e5.PluralName = "e5s";
      e5.TableName = MetadataAccess.Instance.CreateTableName(e5);
      e5.AddProperty(new Property("StringProp", "string"));

      var eg1E1 = new Entity("BETest2.EG1.E1");
      eg1E1.PluralName = "eg1E1s";
      eg1E1.TableName = MetadataAccess.Instance.CreateTableName(eg1E1);
      eg1E1.AddProperty(new Property("StringProp", "string"));


      var e1_e2 = MetadataAccess.Instance.CreateOneToManyRelationship(ref e1, ref e2);
      e1_e2.TableName = MetadataAccess.Instance.CreateTableName(e1_e2);

      var e2_e3 = MetadataAccess.Instance.CreateOneToManyRelationship(ref e2, ref e3);
      e2_e3.TableName = MetadataAccess.Instance.CreateTableName(e2_e3);

      var e3_e4 = MetadataAccess.Instance.CreateOneToManyRelationship(ref e3, ref e4);
      e3_e4.TableName = MetadataAccess.Instance.CreateTableName(e3_e4);

      var e4_e5 = MetadataAccess.Instance.CreateOneToManyRelationship(ref e4, ref e5);
      e4_e5.TableName = MetadataAccess.Instance.CreateTableName(e4_e5);

      MetadataAccess.Instance.GetRelationshipCandidates(e3, new List<Entity>() {e1, e2, e3, e4, e5, eg1E1});

      var syncData = new SyncData();
      syncData.AddNewEntity(e1);
      syncData.AddNewEntity(e2);
      syncData.AddNewEntity(e3);
      syncData.AddNewEntity(e4);
      syncData.AddNewEntity(e5);

      syncData.AddNewRelationship(e1_e2);
      syncData.AddNewRelationship(e2_e3);
      syncData.AddNewRelationship(e3_e4);
      syncData.AddNewRelationship(e4_e5);

      MetadataAccess.Instance.Synchronize(syncData);
    }

    [Test]
    public void TestRelationshipCandidates()
    {
      var e1 = new Entity("BETest1.EG1.E1");
      e1.PluralName = "e1s";
      e1.TableName = MetadataAccess.Instance.CreateTableName(e1);

      e1.AddProperty(new Property("StringProp", "string"));

      var syncData = new SyncData();
      syncData.AddNewEntity(e1);

      metadataAccess.Synchronize(syncData);

      var e2 = new Entity("BETest1.EG1.E2");
      e2.PluralName = "e2s";
      e2.TableName = MetadataAccess.Instance.CreateTableName(e2);

      e2.AddProperty(new Property("StringProp", "string"));

      List<Entity> relationshipCandidates =
        metadataAccess.GetRelationshipCandidates(e1, new List<Entity>() {e1, e2});
    }

    [Test]
    [Category("InitializeData")]
    public void InitializeData()
    {
      Entity l2g2_e2 = MetadataAccess.Instance.GetEntity("SmokeTest.L2G2.L2G2_E2");
      EntityInstance instance = l2g2_e2.GetEntityInstance();

      var saveClient = new EntityInstanceService_SaveEntityInstance_Client();

      instance["StringProp"].Value = "abc";
      instance["IntProp"].Value = 123;
      instance["BooleanProp"].Value = false;

      saveClient.UserName = "su";
      saveClient.Password = "su123";
      saveClient.InOut_entityInstance = instance;
      saveClient.Invoke();
    }

    [Test]
    [Category("TestSync")]
    public void TestSync()
    {
      var syncData = new SyncData();

      // Starting with this: The relationship lines between entities point upward.
      // 
      //                     L1G1_E1          L1G2_E1
      //                                           
      //                                            
      //                 L2G1_E1    L2G2_E1    L2G2_E2
      //                             /               
      //                            /               
      //                         L3G1_E1

      // Add a new entity (L1G1_E3)
      var l1g1_e3 = new Entity("BMETest1.L1G1.L1G1_E3");
      l1g1_e3.PluralName = "e3s";
      l1g1_e3.TableName = MetadataAccess.Instance.CreateTableName(l1g1_e3);

      l1g1_e3.AddProperty(new Property("StringProp", "string"));

      syncData.AddNewEntity(l1g1_e3);

      // Delete an existing entity (L2G1_E1)
      Entity l2g1_e1 = MetadataAccess.Instance.GetEntity("BMETest1.L2G1.L2G1_E1");
      syncData.AddDeletedEntity(l2g1_e1);

      // Modify an existing entity (L2G2_E2)
      // - add a property
      Entity l2g2_e2 = MetadataAccess.Instance.GetEntity("BMETest1.L2G2.L2G2_E2");
      l2g2_e2.AddProperty(new Property("StringProp1", "string"));
      syncData.AddModifiedEntity(l2g2_e2);

      // Create a new relationship between L2G2_E2 and L1G1_E1
      Entity l1g1_e1 = MetadataAccess.Instance.GetEntity("BMETest1.L1G1.L1G1_E1");
      RelationshipEntity relationshipEntity = 
        MetadataAccess.Instance.CreateOneToManyRelationship(ref l2g2_e2, ref l1g1_e1);
      
      relationshipEntity.TableName = MetadataAccess.Instance.CreateTableName(relationshipEntity);

      syncData.AddNewRelationship(relationshipEntity);

      // Synchronize
      metadataAccess.Synchronize(syncData);
    }

    #region Data

    private MetadataAccess metadataAccess;
    #endregion
  }
}
