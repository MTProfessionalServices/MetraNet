using System;
using System.Collections.Generic;
using System.IO;

using SmokeTest.OrderManagement;

using MetraTech.Basic;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Rule;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.RuleTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class RuleTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {

      // Clean out the rules file for Order
      MetadataAccess.Instance.ClearRules(orderName);
      string fileName = RuleConfig.GetRuleFile(orderName);
      Assert.IsFalse(File.Exists(fileName));

      // Clean out the rules file for OrderItem
      MetadataAccess.Instance.ClearRules(orderItemName);
      fileName = RuleConfig.GetRuleFile(orderItemName);
      Assert.IsFalse(File.Exists(fileName));

    }

    [Test]
    [Category("UpdateRuleData")]
    public void UpdateRuleData()
    {
      // The 'Core.OrderManagement.Rule.dll' assembly contains rules with attributes for Order and OrderItem for the following
      // events: BeforeCreate, AfterCreate, BeforeLoad, AfterLoad, BeforeUpdate, AfterUpdate and BeforeDelete

      #region Order
      var ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderName);
      #endregion

      #region OrderItem
      ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderItemName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderItemName);
      #endregion

    }

    [Test]
    [Category("SaveRuleData")]
    public void SaveRuleData()
    {
      // The 'Core.OrderManagement.Rule.dll' assembly contains rules with attributes for Order and OrderItem for the following
      // events: BeforeCreate, AfterCreate, BeforeLoad, AfterLoad, BeforeUpdate, AfterUpdate and BeforeDelete

      #region Order
      // Get the rules
      var ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderName);

      // Save the rules
      MetadataAccess.Instance.SaveRuleData(orderName, ruleDataByEvent);

      // Check that the rules xml file exists
      string fileName = RuleConfig.GetRuleFile(orderName);
      Assert.IsTrue(File.Exists(fileName));

      VerifyXml(ruleDataByEvent, orderName);
      #endregion

      #region OrderItem
      // Get the rules
      ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderItemName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderItemName);

      // Save the rules
      MetadataAccess.Instance.SaveRuleData(orderItemName, ruleDataByEvent);

      // Check that the rules xml file exists
      fileName = RuleConfig.GetRuleFile(orderItemName);
      Assert.IsTrue(File.Exists(fileName));

      VerifyXml(ruleDataByEvent, orderItemName);
      #endregion
    }

    [Test]
    [Category("DeleteRuleData")]
    public void DeleteRuleData()
    {
      // The 'Core.OrderManagement.Rule.dll' assembly contains rules with attributes for Order and OrderItem for the following
      // events: BeforeCreate, AfterCreate, BeforeLoad, AfterLoad, BeforeUpdate, AfterUpdate and BeforeDelete

      #region Order
      var ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderName);

      MetadataAccess.Instance.DeleteRuleData(orderName, ruleAssemblyName, ref ruleDataByEvent);
      foreach(CRUDEvent crudEvent in ruleDataByEvent.Keys)
      {
        Assert.AreEqual(0, ruleDataByEvent[crudEvent].Count);
      }
      #endregion

    }

    [Test]
    [Category("VerifyRuleExecution")]
    public void VerifyRuleExecution()
    {
      // Get the rules
      var ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();
      MetadataAccess.Instance.UpdateRuleData(orderName, ruleAssemblyName, ref ruleDataByEvent);
      Assert.AreEqual(8, ruleDataByEvent.Keys.Count);

      VerifyRules(ruleDataByEvent, orderName);

      // Save the rules
      MetadataAccess.Instance.SaveRuleData(orderName, ruleDataByEvent);

      // Synchronize
      MetadataAccess.Instance.Synchronize("SmokeTest", "OrderManagement");

      // Create Order. This will cause BeforeCreate and AfterCreate to fire. Use LogSpy to check log messages.
      Random random = new Random();
      var order = new Order();
      order.BusinessKey.ReferenceNumber = "Ref-" + random.Next();
      order.InvoiceMethod = InvoiceMethod.Standard;
      order.Description = "Testing business rule execution";

      var repository = MetadataAccess.Instance.GetRepository();
      order = repository.SaveInstance(order) as Order;
      order.InvoiceMethod = InvoiceMethod.Detailed;

      // Will cause BeforeUpdate and AfterUpdate to fire.
      repository.SaveInstance(order);

      order = repository.LoadInstance(order.GetType().FullName, order.Id) as Order;

    }

    private void VerifyRules(Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent, string entityName)
    {
      List<RuleData> rules;
      rules = ruleDataByEvent[CRUDEvent.BeforeCreate];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(beforeCreateAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.AfterCreate];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(afterCreateAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.BeforeLoad];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(beforeLoadAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.AfterLoad];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(afterLoadAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.BeforeUpdate];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(beforeUpdateAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.AfterUpdate];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(afterUpdateAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.BeforeDelete];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(beforeDeleteAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);

      rules = ruleDataByEvent[CRUDEvent.AfterDelete];
      Assert.AreEqual(3, rules.Count);
      Assert.AreEqual(afterDeleteAssemblyQualifiedName, rules[0].AssemblyQualifiedTypeName);
      Assert.AreEqual(entityName, rules[0].EntityName);
    }

    private void VerifyXml(Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent, string entityName)
    {
      // Get the data in the xml file
      Dictionary<CRUDEvent, List<RuleData>> xmlRulesByEvent = RuleConfig.GetRulesByEvent(entityName);

      foreach (CRUDEvent crudEvent in ruleDataByEvent.Keys)
      {
        List<RuleData> xmlRuleList;
        xmlRulesByEvent.TryGetValue(crudEvent, out xmlRuleList);
        Assert.IsNotNull(xmlRuleList);
        Assert.AreEqual(3, xmlRuleList.Count);

        List<RuleData> inMemoryRuleList = ruleDataByEvent[crudEvent];
        Assert.IsNotNull(inMemoryRuleList);

        foreach(RuleData ruleData in inMemoryRuleList)
        {
          RuleData xmlRuleData =
            xmlRuleList.Find(r => r.AssemblyQualifiedTypeName == ruleData.AssemblyQualifiedTypeName);
          Assert.IsNotNull(xmlRuleData);
          Assert.AreEqual(ruleData.Name, xmlRuleData.Name);
          Assert.AreEqual(ruleData.Description, xmlRuleData.Description);
          Assert.AreEqual(ruleData.Event, xmlRuleData.Event);
          Assert.AreEqual(ruleData.Priority, xmlRuleData.Priority);
          Assert.AreEqual(ruleData.EntityName, xmlRuleData.EntityName);
        }
      }
    }
   
    #region Data

    private static readonly ILog logger = LogManager.GetLogger("RuleTest");

    // private LogSpy logSpy;
    private const string orderName = "SmokeTest.OrderManagement.Order";
    private const string orderItemName = "SmokeTest.OrderManagement.OrderItem";
    private const string ruleAssemblyName = @"O:\debug\bin\SmokeTest.OrderManagement.Rule.dll";

    private const string beforeCreateAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.BeforeCreate1, SmokeTest.OrderManagement.Rule";

    private const string afterCreateAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.AfterCreate1, SmokeTest.OrderManagement.Rule";

    private const string beforeLoadAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.BeforeLoad1, SmokeTest.OrderManagement.Rule";

    private const string afterLoadAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.AfterLoad1, SmokeTest.OrderManagement.Rule";

    private const string beforeUpdateAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.BeforeUpdate1, SmokeTest.OrderManagement.Rule";

    private const string afterUpdateAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.AfterUpdate1, SmokeTest.OrderManagement.Rule";

    private const string beforeDeleteAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.BeforeDelete1, SmokeTest.OrderManagement.Rule";

    private const string afterDeleteAssemblyQualifiedName =
      "SmokeTest.OrderManagement.Rule.AfterDelete1, SmokeTest.OrderManagement.Rule";

    #endregion
  }
}
