using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;
using MetraTech.Interop.MTYAAC;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech;

using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;



using System.Collections;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.BaseTypes;
using IMTCompositeCapability = MetraTech.Interop.MTAuth.IMTCompositeCapability;
using IMTYAAC = MetraTech.Interop.MTAuth.IMTYAAC;


//
// To Run this fixture
// "c:\Program Files (x86)\NUnit 2.5.10\bin\net-2.0\nunit-console-x86.exe" /fixture:MetraTech.Core.Services.UnitTests.AmpServiceTest O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
// "c:\Program Files (x86)\NUnit 2.6\bin\nunit-console-x86.exe" /fixture:MetraTech.Core.Services.UnitTests.AmpServiceTest O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
namespace MetraTech.Core.Services.UnitTests
{
  [TestClass]
  public class AmpServiceTest
  {

    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
	  public static void InitTests(TestContext testContext)
    {
        // Add "ManageAmpDecisions" capability to user csr1
        IMTLoginContext loginContext = new MTLoginContextClass();
        MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
        IMTSecurity securityObject = new MTSecurityClass();
        IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
        accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)loginSessionContext);
          
        MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

        IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext)loginSessionContext, userCsr1.AccountID, DateTime.Now);
          
        IMTCompositeCapability manageAmpDecisionsCapability = securityObject.GetCapabilityTypeByName("ManageAmpDecisions").CreateInstance();

        Console.WriteLine("ID={0}", securityObject.GetCapabilityTypeByName("ManageAmpDecisions").ID);
        Console.WriteLine("GetTYpe={0}", manageAmpDecisionsCapability.GetType());
        Console.WriteLine("CapabilityTYpe={0}", manageAmpDecisionsCapability.CapabilityType);

        foreach (IMTCompositeCapability capability in csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Capabilities)
        {
            Console.WriteLine("Before " + capability.ToString());
        }

        csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).AddCapability(manageAmpDecisionsCapability);
        csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Save();

        foreach (IMTCompositeCapability capability in csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).Capabilities)
        {
            Console.WriteLine("After " + capability.ToString());
        }

        // Create a client for interacting with the AmpService
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Delete all decisions, so we start fresh
        MTList<Decision> decisionsToDelete = new MTList<Decision>();
        client.GetDecisions(ref decisionsToDelete);
        List<Decision> tmpDecisionsToDelete = decisionsToDelete.Items;
        Console.WriteLine("tmpDecisionsToDelete.Count={0}", tmpDecisionsToDelete.Count);
               
        foreach (var tmpDecision in tmpDecisionsToDelete)
        {
            Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}",
                tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue);
            client.DeleteDecision(tmpDecision.Name);
        }

        // Delete all usagequalificationgroups, so we start fresh
        MTList<UsageQualificationGroup> uqgs = new MTList<UsageQualificationGroup>();
        client.GetUsageQualificationGroups(ref uqgs);
        List<UsageQualificationGroup> tmpUqgs = uqgs.Items;
        Console.WriteLine("tmpUqgs.Count={0}", tmpUqgs.Count);
        foreach (var tmpUqg in tmpUqgs)
        {
            if (tmpUqg.Name == "ALL")
            {
                // don't delete this UQG
            }
            else
            {
                Console.WriteLine("deleting uqgName={0}",
                    tmpUqg.Name);
                client.DeleteUsageQualificationGroup(tmpUqg.Name);
            }
        }

        // Delete all GeneratedCharges, so we start fresh
        MTList<GeneratedCharge> gcs = new MTList<GeneratedCharge>();
        client.GetGeneratedCharges(ref gcs);
        List<GeneratedCharge> tmpGcs = gcs.Items;
        Console.WriteLine("tmpGcs.Count={0}", tmpGcs.Count);
        foreach (var tmpGc in tmpGcs)
        {
            Console.WriteLine("deleting gcName={0}",
                tmpGc.Name);
            client.DeleteGeneratedCharge(tmpGc.Name);
        }

        // Delete all AccountQualificationGroups except "self", so we start fresh
        MTList<AccountQualificationGroup> aqgs = new MTList<AccountQualificationGroup>();
        client.GetAccountQualificationGroups(ref aqgs);
        List<AccountQualificationGroup> tmpAqgs = aqgs.Items;
        Console.WriteLine("tmpAqgs.Count={0}", tmpAqgs.Count);
        foreach (var tmpAqg in tmpAqgs)
        {
            if (tmpAqg.Name.ToUpper() == "SELF")
            {
                Console.WriteLine("keeping aqgName={0}",
                    tmpAqg.Name);
            }
            else
            {
                Console.WriteLine("deleting aqgName={0}",
                    tmpAqg.Name);
                client.DeleteAccountQualificationGroup(tmpAqg.Name);
            }
        }

        // Delete all PvToAmountChainMappings, so we start fresh
        MTList<PvToAmountChainMapping> mappings = new MTList<PvToAmountChainMapping>();
        client.GetPvToAmountChainMappings(ref mappings);
        List<PvToAmountChainMapping> tmpMappings = mappings.Items;
        Console.WriteLine("tmpMappings.Count={0}", tmpMappings.Count);
        foreach (var tmpMapping in tmpMappings)
        {
            Console.WriteLine("deleting PvToAmountChainMapping={0}",
                tmpMapping.UniqueId);
            client.DeletePvToAmountChainMapping(tmpMapping.UniqueId);
        }

        // Delete all AmountChains, so we start fresh
        MTList<AmountChain> amountChains = new MTList<AmountChain>();
        client.GetAmountChains(ref amountChains);
        List<AmountChain> tmpAmountChains = amountChains.Items;
        Console.WriteLine("tmpAmountChains.Count={0}", tmpAmountChains.Count);
        foreach (var amountChain in tmpAmountChains)
        {
            Console.WriteLine("deleting AmountChain={0}",
                amountChain.Name);
            client.DeleteAmountChain(amountChain.Name);
        }
    }

    [TestMethod]
    [TestCategory("TestGetDecisions")]
    [TestCategory("AMPTest")]
    public void TestGetDecisions()
    {
        // just a test comment
      // just a test comment
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Create Decision
        Decision decision;
        client.CreateDecision("dansDecision", "my decision", "t_pt_TieredUnitRatesPT", out decision);
        Console.WriteLine("decision.TierStartValue={0}", decision.TierStartValue);
        Console.WriteLine("decision.TierEndValue={0}", decision.TierEndValue);
        Console.WriteLine("decision.ItemAggregatedValue={0}", decision.ItemAggregatedValue);
        Console.WriteLine("decision.CycleUnitTypeValue={0}", decision.CycleUnitTypeValue);
        Console.WriteLine("decision.IsActive={0}", decision.IsActive);
        Console.WriteLine("decision.IsEditable={0}", decision.IsEditable);
        Console.WriteLine("decision.ParameterTableName={0}", decision.ParameterTableName);
        Console.WriteLine("decision.ParameterTableDisplayName={0}", decision.ParameterTableDisplayName);
        //Assert.AreEqual(decision.TierStartValue, 0, "default tier start should be 0");
        Assert.AreEqual(decision.TierEndValue, null, "FAILdefault tier end should be null");
        Assert.AreEqual(decision.ItemAggregatedValue, Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE, 
            "default item aggregated should be units-of-usage");
        Assert.AreEqual(decision.CycleUnitTypeValue, Decision.CycleUnitTypeEnum.CYCLE_SAME_AS_BILLING_INTERVAL, 
            "default cycle unit type is interval");
        Assert.AreEqual(decision.ExecutionFrequency, Decision.ExecutionFrequencyEnum.DURING_EOP);

        // Update the values of tier start and tier end, and save the changes to the DB.
        decision.TierStartValue = 100;
        decision.TierEndValue = 500;
        decision.IsActive = true;
        decision.IsEditable = true;
        decision.Description = "my decision updated";
        decision.ExecutionFrequency = Decision.ExecutionFrequencyEnum.DURING_BOTH;
        decision.PvToAmountChainMapping = "TmpPvToAmountChainMapping";
        decision.GeneratedCharge = "TmpGeneratedCharge";
        client.SaveDecision(decision);

        // Retrieve the same decision from the DB.
        Decision sameDecision;
        client.GetDecision("dansDecision", out sameDecision);
        Console.WriteLine("sameDecision.TierStartValue={0}", sameDecision.TierStartValue);
        Console.WriteLine("sameDecision.TierEndValue={0}", sameDecision.TierEndValue);
        Console.WriteLine("sameDecision.AccountQualificationGroup={0}", sameDecision.AccountQualificationGroup);
        Console.WriteLine("sameDecision.ItemAggregatedValue={0}", sameDecision.ItemAggregatedValue);
        Console.WriteLine("sameDecision.IsActive={0}", sameDecision.IsActive);
        Console.WriteLine("sameDecision.IsEditable={0}", sameDecision.IsEditable);
        Console.WriteLine("sameDecision.ParameterTableName={0}", sameDecision.ParameterTableName);
        Console.WriteLine("sameDecision.ParameterTableDisplayName={0}", sameDecision.ParameterTableDisplayName);
        Assert.AreEqual(sameDecision.TierStartValue, 100, "tier start should be 100");
        Assert.AreEqual(sameDecision.TierEndValue, 500, "tier end should be 500");
        Assert.AreEqual(sameDecision.ItemAggregatedValue, Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE, 
            "default item aggregated should be units-of-usage");
        Assert.AreEqual(sameDecision.IsActive, true, "IsActive should be true");
        Assert.AreEqual(sameDecision.IsEditable, true, "IsEditable should be true");
        Assert.AreEqual(sameDecision.Description, "my decision updated", "Description should be 'my decision updated'");
        Assert.AreEqual(sameDecision.ExecutionFrequency, Decision.ExecutionFrequencyEnum.DURING_BOTH);
        Assert.AreEqual(sameDecision.PvToAmountChainMapping, "TmpPvToAmountChainMapping");
        Assert.AreEqual(sameDecision.GeneratedCharge, "TmpGeneratedCharge");
        Assert.AreEqual(sameDecision.ParameterTableName, decision.ParameterTableName);
        Assert.AreEqual(sameDecision.ParameterTableDisplayName, decision.ParameterTableDisplayName);

        // Set IsActive back to false, and validate the value
        sameDecision.IsActive = false;
        client.SaveDecision(sameDecision);
        client.GetDecision("dansDecision", out sameDecision);
        Console.WriteLine("sameDecision.IsActive={0}", sameDecision.IsActive);
        Assert.AreEqual(sameDecision.IsActive, false, "IsActive should be false");

        // Create 2nd Decision
        Decision decision2;
        client.CreateDecision("SecondDecision", "second decision", "t_pt_TieredUnitRatesPT", out decision2);
        Console.WriteLine("decision2.TierStartValue={0}", decision2.TierStartValue);
        Console.WriteLine("decision2.TierEndValue={0}", decision2.TierEndValue);

        // Update the values of tier start and tier end, and Save the changes to the DB.
        decision2.TierStartValue = 200;
        decision2.TierEndValue = 800;
        decision2.IsActive = true;
        decision2.IsEditable = true;
        client.SaveDecision(decision2);

        // Create 3rd Decision via cloning
        Decision decision3;
        client.CloneDecision(decision2.Name, "ThirdDecision", "third decision", out decision3);
        Console.WriteLine("decision3.Name={0}", decision3.Name);
        Console.WriteLine("decision3.Description={0}", decision3.Description);
        Console.WriteLine("decision3.TierStartValue={0}", decision3.TierStartValue);
        Console.WriteLine("decision3.TierEndValue={0}", decision3.TierEndValue);
        Console.WriteLine("decision2.Name={0}", decision2.Name);
        Console.WriteLine("decision2.Description={0}", decision2.Description);
        Console.WriteLine("decision2.TierStartValue={0}", decision2.TierStartValue);
        Console.WriteLine("decision2.TierEndValue={0}", decision2.TierEndValue);
        Console.WriteLine("decision2.ParameterTableName={0}", decision2.ParameterTableName);
        Console.WriteLine("decision2.ParameterTableDisplayName={0}", decision2.ParameterTableDisplayName);
        Assert.AreEqual(decision3.TierStartValue, 200, "tier start should be 200");
        Assert.AreEqual(decision3.TierEndValue, 800, "tier end should be 800");
        Assert.AreEqual(decision3.ItemAggregatedValue, Decision.ItemAggregatedEnum.AGGREGATE_UNITS_OF_USAGE,
            "default item aggregated should be units-of-usage");
        Assert.AreEqual(decision3.IsActive, true, "IsActive should be true");
        Assert.AreEqual(decision3.IsEditable, true, "IsEditable should be true");
        Assert.AreEqual(decision3.ParameterTableName, decision2.ParameterTableName);
        Assert.AreEqual(decision3.ParameterTableDisplayName, decision2.ParameterTableDisplayName);

        // Update the values of tier start and tier end, and Save the changes to the DB.
        decision3.TierStartValue = 299;
        decision3.TierEndValue = 899;
        decision3.IsActive = false;
        decision3.IsEditable = false;
        decision3.ItemAggregatedValue = Decision.ItemAggregatedEnum.AGGREGATE_USAGE_EVENTS;
        client.SaveDecision(decision3);
        client.GetDecision("ThirdDecision", out sameDecision);
        Assert.AreEqual(sameDecision.TierStartValue, 299, "tier start should be 299");
        Assert.AreEqual(sameDecision.TierEndValue, 899, "tier end should be 899");
        Assert.AreEqual(sameDecision.ItemAggregatedValue, Decision.ItemAggregatedEnum.AGGREGATE_USAGE_EVENTS);
        Assert.AreEqual(sameDecision.IsActive, false, "IsActive should be false");
        Assert.AreEqual(sameDecision.IsEditable, false, "IsEditable should be false");

        // Attempt to create decision with duplicate name
        try
        {
            Decision duplicateDecision;
            client.CreateDecision("SecondDecision", "second decision", "t_pt_TieredUnitRatesPT", out duplicateDecision);
            Console.WriteLine("No Exception thrown when we attempt to create a decision with the same name");
            Assert.Fail("No Exception thrown when we attempt to create a decision with the same name");
        }
        catch (Exception e)
        {
            Console.WriteLine("Exception thrown when we attempt to create a decision with the same name, {0}",
                e.Message);
        }

        // Change the Name of decision2, and then try to Save it
        try
        {
            decision2.Name = "shouldFail";
            client.SaveDecision(decision2);
            Console.WriteLine("No Exception thrown when we attempt to Save a decision that doesn't exist in the DB");
            Assert.Fail("No Exception thrown when we attempt to Save a decision that doesn't exist in the DB");
        }
        catch (Exception e)
        {
            Console.WriteLine("Exception thrown when we attempt to Save a decision that doesn't exist in the DB, {0}",
                e.Message);
            // change the name back
            decision2.Name = "SecondDecision";
        }

        // Attempt to retrieve a decision that doesn't exist
        try
        {
            Decision myDecision;
            client.GetDecision("foobar", out myDecision);
            Console.WriteLine("No exception thrown when retrieving a non-existent decision");
            Assert.Fail("No exception thrown when retrieving a non-existent decision");
        }
        catch (Exception e)
        {
            Console.WriteLine("Exception thrown when retrieving a non-existent decision, {0}",
                e);
        }

        // Retrieve the list of decisions, and print out the tierstart and tierend
        // No sorting applied
        MTList<Decision> listOfDecisions = new MTList<Decision>();
        
        client.GetDecisions(ref listOfDecisions);
        List<Decision> tmpListOfDecisions = listOfDecisions.Items;

        Console.WriteLine("Decisions with no sorting");
        foreach (var tmpDecision in tmpListOfDecisions)
        {
          Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}, ParameterTableName={3}, ParameterTableDisplayName={4}",
                              tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue, tmpDecision.ParameterTableName, tmpDecision.ParameterTableDisplayName);
        }

        // Retrieve the list of decisions, and print out the tierstart and tierend
        // sorted by "Name"
        MTList<Decision> listOfDecisions2 = new MTList<Decision>();
        listOfDecisions2.SortCriteria.Add(new SortCriteria( "Name", SortType.Ascending));
        
        client.GetDecisions(ref listOfDecisions2);
        tmpListOfDecisions = listOfDecisions2.Items;

        Console.WriteLine("Decisions sorted by name");
        foreach (var tmpDecision in tmpListOfDecisions)
        {
          Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}, ParameterTableName={3}, ParameterTableDisplayName={4}",
                              tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue, tmpDecision.ParameterTableName, tmpDecision.ParameterTableDisplayName);
        }

        // Retrieve the list of decisions, and print out the tierstart and tierend
        // sorted by "IsActive"
        MTList<Decision> listOfDecisions3 = new MTList<Decision>();
        listOfDecisions3.SortCriteria.Add(new SortCriteria( "IsActive", SortType.Descending));

        client.GetDecisions(ref listOfDecisions3);
        tmpListOfDecisions = listOfDecisions3.Items;

        Console.WriteLine("Decisions sorted by IsActive");
        foreach (var tmpDecision in tmpListOfDecisions)
        {
          Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}, IsActive={3}, ParameterTableName={4}, ParameterTableDisplayName={5}",
                              tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue, tmpDecision.IsActive, tmpDecision.ParameterTableName, tmpDecision.ParameterTableDisplayName);
        }

        // Create a decision and change the value of isActive
        // Create Decision
        Decision decisionForSettingIsActive;
        client.CreateDecision("DecisionForSettingIsActive", "DecisionForSettingIsActive", "t_pt_TieredUnitRatesPT", out decisionForSettingIsActive);

        decisionForSettingIsActive.IsActive = true;
        client.SaveDecision(decisionForSettingIsActive);

        // Retrieve the same decision from the DB.
        Decision decisionForSettingIsActive2;
        client.GetDecision("DecisionForSettingIsActive", out decisionForSettingIsActive2);
        Assert.AreEqual(decisionForSettingIsActive2.IsActive, true);
    }

    [TestMethod]
    [TestCategory("TestOtherAttributes")]
    [TestCategory("AMPTest")]
    public void TestOtherAttributes()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Create Decision
        Decision decisionWithOtherAttributes;
        client.CreateDecision("decisionWithOtherAttributes", "my decisionWithOtherAttributes", "t_pt_TieredUnitRatesPT", out decisionWithOtherAttributes);

        // Retrieve the same decision from the DB.
        Decision sameDecision;
        client.GetDecision("decisionWithOtherAttributes", out sameDecision);

        // Retrieve and print the "OtherAttributes"
        Console.WriteLine("OtherAttributes added because of defaults");
        foreach (KeyValuePair<string, DecisionAttributeValue> otherAttr in sameDecision.OtherAttributes)
        {
            Console.WriteLine("otherAttr.Key={0}, otherAttr.Value.HardCodedValue={1}, otherAttr.Value.ColumnName={2}",
                otherAttr.Key, otherAttr.Value.HardCodedValue, otherAttr.Value.ColumnName);
        }

        DecisionAttributeValue decisionAttributeValue = new DecisionAttributeValue();
        decisionAttributeValue.HardCodedValue = "77777";
        decisionAttributeValue.ColumnName = null;
        decisionWithOtherAttributes.OtherAttributes.Add("foo77777", decisionAttributeValue);

        DecisionAttributeValue decisionAttributeValue2 = new DecisionAttributeValue();
        decisionAttributeValue2.HardCodedValue = "88888";
        decisionAttributeValue2.ColumnName = null;
        decisionWithOtherAttributes.OtherAttributes.Add("foo88888", decisionAttributeValue2);
        client.SaveDecision(decisionWithOtherAttributes);

        client.GetDecision("decisionWithOtherAttributes", out sameDecision);

        Console.WriteLine("OtherAttributes after adding 77777 88888");
        // Retrieve and print the "OtherAttributes"
        bool found77777 = false;
        bool found88888 = false;
        foreach (KeyValuePair<string, DecisionAttributeValue> otherAttr in sameDecision.OtherAttributes)
        {
            Console.WriteLine("otherAttr.Key={0}, otherAttr.Value.HardCodedValue={1}, otherAttr.Value.ColumnName={2}",
                otherAttr.Key, otherAttr.Value.HardCodedValue, otherAttr.Value.ColumnName);
            if (otherAttr.Key == "foo77777")
            {
                found77777 = true;
                Assert.IsTrue(otherAttr.Value.HardCodedValue == "77777");

            }
            if (otherAttr.Key == "foo88888")
            {
                found88888 = true;
                Assert.IsTrue(otherAttr.Value.HardCodedValue == "88888");
            }
        }
        Assert.IsTrue(found77777);
        Assert.IsTrue(found88888);

      // Remove one attribute
      sameDecision.OtherAttributes.Remove("foo88888");
      client.SaveDecision(sameDecision);

      // Retrieve the same decision from the DB.
      Decision sameDecisionWithRemovedAttribute;
      client.GetDecision("decisionWithOtherAttributes", out sameDecisionWithRemovedAttribute);

      found88888 = sameDecisionWithRemovedAttribute.OtherAttributes.ContainsKey("foo88888");
      Assert.IsFalse(found88888);
    }

    [TestMethod]
    [TestCategory("TestChargeTypeStuff")]
    [TestCategory("AMPTest")]
    public void TestChargeTypeStuff()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Create Decision
        Decision decisionWithCharge;
        client.CreateDecision("decisionWithCharge", "my decisionWithCharge", "t_pt_TieredUnitRatesPT", out decisionWithCharge);

        // Update decision with a charge
        decisionWithCharge.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_INBOUND;
        decisionWithCharge.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_FLAT;
        decisionWithCharge.ChargeValue = 500;
        client.SaveDecision(decisionWithCharge);

        // Retrieve the same decision from the DB.
        Decision sameDecision;
        client.GetDecision("decisionWithCharge", out sameDecision);
        Assert.AreEqual(sameDecision.ChargeCondition, Decision.ChargeConditionEnum.CHARGE_ON_INBOUND);
        Assert.AreEqual(sameDecision.ChargeAmountType, Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_FLAT);
        Assert.AreEqual(sameDecision.ChargeValue, 500);

        // Update charge params
        decisionWithCharge.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_FINAL;
        decisionWithCharge.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_PERCENTAGE;
        decisionWithCharge.ChargeValue = 0.05M;
        client.SaveDecision(decisionWithCharge);

        // Retrieve the same decision from the DB.
        client.GetDecision("decisionWithCharge", out sameDecision);
        Assert.AreEqual(sameDecision.ChargeCondition, Decision.ChargeConditionEnum.CHARGE_ON_FINAL);
        Assert.AreEqual(sameDecision.ChargeAmountType, Decision.ChargeAmountTypeEnum.CHARGE_PERCENTAGE);
        Assert.AreEqual(sameDecision.ChargeValue, 0.05m);

        // Update charge params
        decisionWithCharge.ChargeCondition = Decision.ChargeConditionEnum.CHARGE_ON_FINAL;
        decisionWithCharge.ChargeAmountType = Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_PROPORTIONAL;
        decisionWithCharge.ChargeValue = 300.10M;
        client.SaveDecision(decisionWithCharge);

        // Retrieve the same decision from the DB.
        client.GetDecision("decisionWithCharge", out sameDecision);
        Assert.AreEqual(sameDecision.ChargeCondition, Decision.ChargeConditionEnum.CHARGE_ON_FINAL);
        Assert.AreEqual(sameDecision.ChargeAmountType, Decision.ChargeAmountTypeEnum.CHARGE_AMOUNT_PROPORTIONAL);
        Assert.AreEqual(sameDecision.ChargeValue, 300.10M);
    }

    [TestMethod]
    [TestCategory("TestGetParameterTableNames")]
    [TestCategory("AMPTest")]
    public void TestGetParameterTableNames()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> ptNames = new MTList<string>();

        client.GetParameterTableNames(ref ptNames);
        List<string> tmpPtNames = ptNames.Items;
        Assert.IsTrue(tmpPtNames.Count > 1, 
            "There should be more than 1 parameter table names, but got " + tmpPtNames.Count.ToString());

        bool foundFlatRecurringCharge = false;
        bool foundNonRecurringCharge = false;
        foreach (var tmpPtName in tmpPtNames)
        {
            Console.WriteLine("ptName={0}", tmpPtName);
            if (tmpPtName.ToUpper().Equals("T_PT_FLATRECURRINGCHARGE"))
            {
                foundFlatRecurringCharge = true;
            }
            if (tmpPtName.ToUpper().Equals("T_PT_NONRECURRINGCHARGE"))
            {
                foundNonRecurringCharge = true;
            }
        }
        Assert.IsTrue(foundFlatRecurringCharge, "didn't find t_pt_FlatRecurringCharge");
        Assert.IsTrue(foundNonRecurringCharge, "didn't find t_pt_NonRecurringCharge");
    }

    [TestMethod]
    [TestCategory("TestGetParameterTableId")]
    [TestCategory("AMPTest")]
    public void TestGetParameterTableId()
    {
      AmpServiceClient client = new AmpServiceClient();
      client.ClientCredentials.UserName.UserName = "csr1";
      client.ClientCredentials.UserName.Password = "csr123";

      MTList<string> ptNames = new MTList<string>();

      client.GetParameterTableNames(ref ptNames);
      List<string> tmpPtNames = ptNames.Items;

      var paramTableIds = new HashSet<int>();
      foreach (var tmpPtName in tmpPtNames)
      {
        int idParamTable = 0;
        client.GetParameterTableId(tmpPtName, ref idParamTable);
        Console.WriteLine("ptName={0}, idParamTable={1}", tmpPtName, idParamTable);
        Assert.IsTrue(idParamTable != 0, "The id for '" + tmpPtName + "' parameter table should not be 0");
        // make sure this id is not the same id as a previously retrieved parameter table
        Assert.IsFalse(paramTableIds.Contains(idParamTable), "Found a non-unique id for the '" + tmpPtName + "'parameter table");
        // add this unique id to the collection of parameter table id's already retrieved.
        paramTableIds.Add(idParamTable);
      }
    }

    [TestMethod]
    [TestCategory("TestGetProductViewTableNames")]
    [TestCategory("AMPTest")]
    public void TestGetProductViewTableNames()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> pvNames = new MTList<string>();

        client.GetProductViewNames(ref pvNames);
        List<string> tmpPvNames = pvNames.Items;
        Assert.IsTrue(tmpPvNames.Count > 10, 
            "There should be more than 10 product view table names, but got " + tmpPvNames.Count.ToString());

        bool foundFlatRecurringCharge = false;
        bool foundNonRecurringCharge = false;
        foreach (var tmpPvName in tmpPvNames)
        {
            Console.WriteLine("pvName={0}", tmpPvName);
            if (tmpPvName.ToUpper().Equals("T_PV_FLATRECURRINGCHARGE"))
            {
                foundFlatRecurringCharge = true;
            }
            if (tmpPvName.ToUpper().Equals("T_PV_NONRECURRINGCHARGE"))
            {
                foundNonRecurringCharge = true;
            }
        }
        Console.WriteLine("foundFlatRecurringCharge={0}", foundFlatRecurringCharge);
        Assert.IsTrue(foundFlatRecurringCharge, "didn't find t_pv_FlatRecurringCharge");
        Assert.IsTrue(foundNonRecurringCharge, "didn't find t_pv_NonRecurringCharge");
    }

    [TestMethod]
    [TestCategory("TestGetAccountQualificationGroups")]
    [TestCategory("AMPTest")]
    public void TestGetAccountQualificationGroups()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<AccountQualificationGroup> aqgs = new MTList<AccountQualificationGroup>();

        client.GetAccountQualificationGroups(ref aqgs);
        List<AccountQualificationGroup> tmpAqgs = aqgs.Items;
        Assert.IsTrue(tmpAqgs.Count >= 1, "need at least 1 account qualification group");

        foreach (var tmpAqg in tmpAqgs)
        {
            Console.WriteLine("aqg.Name={0}", tmpAqg.Name);
            Console.WriteLine("aqg.Description={0}", tmpAqg.Description);
            Console.WriteLine("aqg.UniqueId={0}", tmpAqg.UniqueId);
        }
    }

    [TestMethod]
    [TestCategory("TestCreateUsageQualificationGroup")]
    [TestCategory("AMPTest")]
    public void TestCreateUsageQualificationGroup()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Create a new UQG, add two filters to it, and then save it
        UsageQualificationGroup uqg;
        client.CreateUsageQualificationGroup("myTestUqg1", "myTestUqg1Description", out uqg);

        Console.WriteLine("uqg.Name={0}", uqg.Name);
        Console.WriteLine("uqg.Description={0}", uqg.Description);
        Console.WriteLine("uqg.UniqueId={0}", uqg.UniqueId);


        UsageQualificationFilter uqgFilter = new UsageQualificationFilter();
        uqgFilter.Filter = "isToll == true";
        uqgFilter.Priority = 77;
        uqg.UsageQualificationFilters.Add(uqgFilter);

        UsageQualificationFilter uqgFilter2 = new UsageQualificationFilter();
        uqgFilter2.Filter = "isToChina == true";
        uqgFilter2.Priority = 88;
        uqg.UsageQualificationFilters.Add(uqgFilter2);
        uqg.Description = "updated description";

        client.SaveUsageQualificationGroup(uqg);

        // Retrieve the same UQG and log the contents
        UsageQualificationGroup uqg2;
        client.GetUsageQualificationGroup("myTestUqg1", out uqg2);
        Assert.AreEqual(uqg2.Description, "updated description");
        Console.WriteLine("uqg2.Name={0}", uqg2.Name);
        Console.WriteLine("uqg2.Description={0}", uqg2.Description);
        Console.WriteLine("uqg2.UniqueId={0}", uqg2.UniqueId);
        List<UsageQualificationFilter> filters = uqg2.UsageQualificationFilters;
        Assert.AreEqual(filters.Count, 2, "There should be 2 filters");
        foreach (var filter in filters)
        {
            if (filter.Priority == 77)
            {
                Assert.AreEqual(filter.Filter, "isToll == true", "invalid filter");
            }
            else if (filter.Priority == 88)
            {
                Assert.AreEqual(filter.Filter, "isToChina == true", "invalid filter");
            }
            else
            {
                Assert.Fail("invalid priority");
            }
            Console.WriteLine("filter.Filter={0}", filter.Filter);
            Console.WriteLine("filter.Priority={0}", filter.Priority);
        }

        // Change one of the filters, save to DB, and then validate
        for (int i=0; i<uqg2.UsageQualificationFilters.Count; i++)
        {
            // change priority 88 to 66
            if (uqg2.UsageQualificationFilters[i].Priority == 88)
            {
                uqg2.UsageQualificationFilters[i].Priority = 66; 
                break;
            }
        }
        client.SaveUsageQualificationGroup(uqg2);

        // Retrieve the same UQG and log the contents
        UsageQualificationGroup uqg3;
        client.GetUsageQualificationGroup("myTestUqg1", out uqg3);
        Console.WriteLine("uqg3.Name={0}", uqg3.Name);
        Console.WriteLine("uqg3.Description={0}", uqg3.Description);
        Console.WriteLine("uqg3.UniqueId={0}", uqg3.UniqueId);
        filters = uqg3.UsageQualificationFilters;
        Assert.AreEqual(filters.Count, 2, "There should be 2 filters");
        foreach (var filter in filters)
        {
            Console.WriteLine("333 filter.Filter={0}", filter.Filter);
            Console.WriteLine("333 filter.Priority={0}", filter.Priority);
            if (filter.Priority == 77)
            {
                Assert.AreEqual(filter.Filter, "isToll == true", "invalid filter");
            }
            else if (filter.Priority == 66)
            {
                Assert.AreEqual(filter.Filter, "isToChina == true", "invalid filter");
            }
            else
            {
                Assert.Fail("invalid priority");
            }
        }

        // Delete the first filter, save to DB, and then validate
        for (int i=0; i<uqg3.UsageQualificationFilters.Count; i++)
        {
            // Remove the filter with priority 66
            if (uqg3.UsageQualificationFilters[i].Priority == 66)
            {
                uqg3.UsageQualificationFilters.RemoveAt(i);
                break;
            }
        }
        client.SaveUsageQualificationGroup(uqg3);

        // Retrieve the same UQG and log the contents
        UsageQualificationGroup uqg4;
        client.GetUsageQualificationGroup("myTestUqg1", out uqg4);
        Console.WriteLine("uqg4.Name={0}", uqg4.Name);
        Console.WriteLine("uqg4.Description={0}", uqg4.Description);
        Console.WriteLine("uqg4.UniqueId={0}", uqg4.UniqueId);
        filters = uqg4.UsageQualificationFilters;
        Assert.AreEqual(filters.Count, 1, "There should be 1 filter");
        foreach (var filter in filters)
        {
            Console.WriteLine("444 filter.Filter={0}", filter.Filter);
            Console.WriteLine("444 filter.Priority={0}", filter.Priority);
            if (filter.Priority == 77)
            {
                Assert.AreEqual(filter.Filter, "isToll == true", "invalid filter");
            }
            else
            {
                Assert.Fail("invalid priority");
            }
        }
    }

    [TestMethod]
    [TestCategory("TestGetUsageQualificationGroups")]
    [TestCategory("AMPTest")]
    public void TestGetUsageQualificationGroups()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        UsageQualificationGroup uqg1;
        UsageQualificationGroup uqg2;
        UsageQualificationGroup uqg3;
        UsageQualificationGroup uqg4;
        UsageQualificationGroup uqg5;
        UsageQualificationGroup uqg6;

        client.CreateUsageQualificationGroup("aaaaa", "aaaaaaaaaa", out uqg1);
        client.CreateUsageQualificationGroup("bbbbb", "bbbbbbbbbb", out uqg2);
        client.CreateUsageQualificationGroup("fffff", "ffffffffff", out uqg3);
        client.CreateUsageQualificationGroup("ccccc", "cccccccccc", out uqg4);
        client.CreateUsageQualificationGroup("ggggg", "gggggggggg", out uqg5);
        client.CreateUsageQualificationGroup("ddddd", "dddddddddd", out uqg6);

        // retrieve unsorted UQGs
        MTList<UsageQualificationGroup> uqgs = new MTList<UsageQualificationGroup>();
        client.GetUsageQualificationGroups(ref uqgs);
        List<UsageQualificationGroup> tmpUqgs = uqgs.Items;
        Console.WriteLine("UQGS unsorted");
        foreach (var tmpUqg in tmpUqgs)
        {
            Console.WriteLine("uqg.Name={0}", tmpUqg.Name);
            Console.WriteLine("uqg.Description={0}", tmpUqg.Description);
            Console.WriteLine("uqg.UniqueId={0}", tmpUqg.UniqueId);

            List<UsageQualificationFilter> filters = tmpUqg.UsageQualificationFilters;
            foreach (var filter in filters)
            {
                Console.WriteLine("filter.Filter={0}", filter.Filter);
                Console.WriteLine("filter.Priority={0}", filter.Priority);
            }
        }

        // retrieve UQGs sorted by name
        MTList<UsageQualificationGroup> uqgs2 = new MTList<UsageQualificationGroup>();
        uqgs2.SortCriteria.Add(new SortCriteria( "Name", SortType.Ascending));
        client.GetUsageQualificationGroups(ref uqgs2);
        tmpUqgs = uqgs2.Items;
        Console.WriteLine("UQGS sorted by name");
        foreach (var tmpUqg in tmpUqgs)
        {
            Console.WriteLine("uqg.Name={0}", tmpUqg.Name);
            Console.WriteLine("uqg.Description={0}", tmpUqg.Description);
            Console.WriteLine("uqg.UniqueId={0}", tmpUqg.UniqueId);

            List<UsageQualificationFilter> filters = tmpUqg.UsageQualificationFilters;
            foreach (var filter in filters)
            {
                Console.WriteLine("filter.Filter={0}", filter.Filter);
                Console.WriteLine("filter.Priority={0}", filter.Priority);
            }
        }
    }

    [TestMethod]
    [TestCategory("TestAccUsageColumnNames")]
    [TestCategory("AMPTest")]
    public void TestGetAccUsageColumnNames()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> columnNames = new MTList<string>();

        client.GetAccUsageColumnNames(ref columnNames);
        List<string> tmpColumnNames = columnNames.Items;
        Assert.IsTrue(tmpColumnNames.Count > 20, "t_acc_usage should have > 20 columns");

        foreach (var tmpColumnName in tmpColumnNames)
        {
            Console.WriteLine("columnName={0}", tmpColumnName);
        }
    }

    [TestMethod]
    [TestCategory("TestTableColumnNames")]
    [TestCategory("AMPTest")]
    public void TestGetTableColumnNames()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> columnNames = new MTList<string>();

        client.GetTableColumnNames("t_pt_NonRecurringCharge", ref columnNames);
        List<string> tmpColumnNames = columnNames.Items;

        foreach (var tmpColumnName in tmpColumnNames)
        {
            Console.WriteLine("columnName={0}", tmpColumnName);
        }
    }

    [TestMethod]
    [TestCategory("TestGetTableColumnNamesFail")]
    [TestCategory("AMPTest")]
    public void TestGetTableColumnNamesFail()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> columnNames = new MTList<string>();

        client.GetTableColumnNames("t_pt_foobarbaz", ref columnNames);
        List<string> tmpColumnNames = columnNames.Items;
        Console.WriteLine("numColumnNames={0}", tmpColumnNames.Count);
    }

    [TestMethod]
    [TestCategory("TestCreateGeneratedCharge")]
    [TestCategory("AMPTest")]
    public void TestCreateGeneratedCharge()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        GeneratedCharge gc1;
        client.CreateGeneratedCharge("myGc1", "myGc1Description", "t_pv_foo", "myAmountChain", out gc1);

        Console.WriteLine("gc1.Name={0}", gc1.Name);
        Console.WriteLine("gc1.Description={0}", gc1.Description);
        Console.WriteLine("gc1.UniqueId={0}", gc1.UniqueId);
        Console.WriteLine("gc1.AmountChainName={0}", gc1.AmountChainName);
        Console.WriteLine("gc1.ProductViewName={0}", gc1.ProductViewName);

        GeneratedChargeDirective directive1 = new GeneratedChargeDirective();
        directive1.FieldName = "FieldNameA";
        directive1.PopulationString = "x + 1";
        gc1.GeneratedChargeDirectives.Add(directive1);

        GeneratedChargeDirective directive2 = new GeneratedChargeDirective();
        directive2.FieldName = "FieldNameB";
        directive2.PopulationString = "y + 7";
        gc1.GeneratedChargeDirectives.Add(directive2);

        client.SaveGeneratedCharge(gc1);

        // Retrieve the same generated charge and log the contents
        GeneratedCharge gc2;
        client.GetGeneratedCharge("myGc1", out gc2);
        Console.WriteLine("gc2.Name={0}", gc2.Name);
        Console.WriteLine("gc2.Description={0}", gc2.Description);
        Console.WriteLine("gc2.UniqueId={0}", gc2.UniqueId);
        Console.WriteLine("gc2.AmountChainName={0}", gc2.AmountChainName);
        Console.WriteLine("gc2.ProductViewName={0}", gc2.ProductViewName);
        List<GeneratedChargeDirective> directives = gc2.GeneratedChargeDirectives;
        Assert.AreEqual(directives.Count, 2, "There should be 2 directives");
        foreach (var directive in directives)
        {
            if (directive.FieldName == "FieldNameA")
            {
                Assert.AreEqual(directive.PopulationString, "x + 1", 
                    "invalid directive");
            }
            else if (directive.FieldName == "FieldNameB")
            {
                Assert.AreEqual(directive.PopulationString, "y + 7", 
                    "invalid directive");
            }
            else
            {
                Assert.Fail("invalid directive");
            }
            Console.WriteLine("directive.FieldName={0}", 
                directive.FieldName);
            Console.WriteLine("directive.PopulationString={0}", 
                directive.PopulationString);
        }

        // Change one of the directives and the description, 
        // save to DB, and then validate
        gc2.Description = "updatedDescription";
        gc2.ProductViewName = "t_pv_bar";
        for (int i=0; i<gc2.GeneratedChargeDirectives.Count; i++)
        {
            if (gc2.GeneratedChargeDirectives[i].FieldName == "FieldNameB")
            {
                gc2.GeneratedChargeDirectives[i].PopulationString = "z + 999"; 
            }
            Console.WriteLine("after updating, FieldName={0}", 
                gc2.GeneratedChargeDirectives[i].FieldName);
            Console.WriteLine("after updating, PopulationString={0}", 
                gc2.GeneratedChargeDirectives[i].PopulationString);
        }
        client.SaveGeneratedCharge(gc2);

        // Retrieve the same generated charge and log the contents
        GeneratedCharge gc3;
        client.GetGeneratedCharge("myGc1", out gc3);
        Console.WriteLine("gc3.Name={0}", gc3.Name);
        Console.WriteLine("gc3.Description={0}", gc3.Description);
        Console.WriteLine("gc3.UniqueId={0}", gc3.UniqueId);
        Console.WriteLine("gc3.AmountChainName={0}", gc3.AmountChainName);
        Console.WriteLine("gc3.ProductViewName={0}", gc3.ProductViewName);
        directives = gc3.GeneratedChargeDirectives;
        Assert.AreEqual(directives.Count, 2, "There should be 2 directives");
        foreach (var directive in directives)
        {
            Console.WriteLine("333 directive.FieldName={0}", directive.FieldName);
            Console.WriteLine("333 directive.PopulationString={0}", directive.PopulationString);
            if (directive.FieldName == "FieldNameA")
            {
                Assert.AreEqual(directive.PopulationString, "x + 1", "invalid directive");
            }
            else if (directive.FieldName == "FieldNameB")
            {
                Assert.AreEqual(directive.PopulationString, "z + 999", "invalid directive");
            }
            else
            {
                Assert.Fail("invalid priority");
            }
        }

        // Delete the first directive, save to DB, and then validate
        for (int i=0; i<gc3.GeneratedChargeDirectives.Count; i++)
        {
            if (gc3.GeneratedChargeDirectives[i].FieldName == "FieldNameA")
            {
                gc3.GeneratedChargeDirectives.RemoveAt(i);
                break;
            }
        }
        client.SaveGeneratedCharge(gc3);

        // Retrieve the same generated charge and log the contents
        GeneratedCharge gc4;
        client.GetGeneratedCharge("myGc1", out gc4);
        Console.WriteLine("gc4.Name={0}", gc4.Name);
        Console.WriteLine("gc4.Description={0}", gc4.Description);
        Console.WriteLine("gc4.UniqueId={0}", gc4.UniqueId);
        directives = gc4.GeneratedChargeDirectives;
        Assert.AreEqual(directives.Count, 1, "There should be 1 directive");
        foreach (var directive in directives)
        {
            Console.WriteLine("444 directive.FieldName={0}", directive.FieldName);
            Console.WriteLine("444 directive.PopulationString={0}", directive.PopulationString);
            if (directive.FieldName == "FieldNameB")
            {
                Assert.AreEqual(directive.PopulationString, "z + 999", "invalid directive");
            }
            else
            {
                Assert.Fail("invalid field name");
            }
        }
    }

    [TestMethod]
    [TestCategory("TestGetGeneratedCharges")]
    [TestCategory("AMPTest")]
    public void TestGetGeneratedCharges()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<GeneratedCharge> generatedCharges = new MTList<GeneratedCharge>();

        client.GetGeneratedCharges(ref generatedCharges);
        List<GeneratedCharge> tmpGeneratedCharges = generatedCharges.Items;

        foreach (var tmpGeneratedCharge in tmpGeneratedCharges)
        {
            Console.WriteLine("generatedCharge.Name={0}", tmpGeneratedCharge.Name);
            Console.WriteLine("generatedCharge.Description={0}", tmpGeneratedCharge.Description);
            Console.WriteLine("generatedCharge.UniqueId={0}", tmpGeneratedCharge.UniqueId);

            List<GeneratedChargeDirective> directives = tmpGeneratedCharge.GeneratedChargeDirectives;
            foreach (var directive in directives)
            {
                Console.WriteLine("directive.UniqueId={0}", directive.UniqueId);
                Console.WriteLine("directive.Priority={0}", directive.Priority);
                Console.WriteLine("directive.IncludeTableName={0}", directive.IncludeTableName);
                Console.WriteLine("directive.SourceValue={0}", directive.SourceValue);
                Console.WriteLine("directive.TargetField={0}", directive.TargetField);
                Console.WriteLine("directive.IncludePredicate={0}", directive.IncludePredicate);
                Console.WriteLine("directive.IncludedFieldPrefix={0}", directive.IncludedFieldPrefix);
                Console.WriteLine("directive.FieldName={0}", directive.FieldName);
                Console.WriteLine("directive.PopulationString={0}", directive.PopulationString);
                Console.WriteLine("directive.MvmProcedure={0}", directive.MvmProcedure);
                Console.WriteLine("directive.Filter={0}", directive.Filter);
                Console.WriteLine("directive.DefaultValue={0}", directive.DefaultValue);
            }
        }
    }

    [TestMethod]
    [TestCategory("TestGetCurrencyNames")]
    [TestCategory("AMPTest")]
    public void TestGetGetCurrencyNames()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        MTList<string> currencyNames = new MTList<string>();

        client.GetCurrencyNames(ref currencyNames);
        List<string> tmpCurrencyNames = currencyNames.Items;

        foreach (var tmpCurrencyName in tmpCurrencyNames)
        {
            Console.WriteLine("currencyName={0}", tmpCurrencyName);
        }
    }

    [TestMethod]
    [TestCategory("TestPopulateAccountQualificationGroups")]
    [TestCategory("AMPTest")]
    public void TestPopulateAccountQualificationGroups()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        AccountQualificationGroup aqg1;
       

        client.CreateAccountQualificationGroup("aqgAAAAA", "AAAAA" , out aqg1);
        AccountQualification qual1 = new AccountQualification();
        qual1.MvmFilter = "MvmFilterAAAAA";
        qual1.DbFilter = "DbFilterAAAAA";
        qual1.TableToInclude = "TableToIncludeAAAAA";
        qual1.Mode = 777;
        qual1.Priority = 7;
        qual1.MatchField = "MatchFieldAAAAA";
        qual1.OutputField = "OutputFieldAAAAA";
        qual1.SourceField = "SourceFieldAAAAA";
        aqg1.AccountQualifications.Add(qual1);

        AccountQualification qual2 = new AccountQualification();
        qual2.MvmFilter = "MvmFilterBBBBB";
        qual2.DbFilter = "DbFilterBBBBB";
        qual2.TableToInclude = "TableToIncludeBBBBB";
        qual2.Mode = 444;
        qual2.Priority = 6;
        qual2.MatchField = "MatchFieldBBBBB";
        qual2.OutputField = "OutputFieldBBBBB";
        qual2.SourceField = "SourceFieldBBBBB";
        aqg1.AccountQualifications.Add(qual2);

        client.SaveAccountQualificationGroup(aqg1);

        MTList<AccountQualificationGroup> aqgs = new MTList<AccountQualificationGroup>();

        client.GetAccountQualificationGroups(ref aqgs);
        List<AccountQualificationGroup> tmpAqgs = aqgs.Items;

        foreach (var tmpAqg in tmpAqgs)
        {
            Console.WriteLine("tmpAqg.Name={0}", tmpAqg.Name);
            Console.WriteLine("tmpAqg.Description={0}", tmpAqg.Description);
            Console.WriteLine("tmpAqg.UniqueId={0}", tmpAqg.UniqueId);

            List<AccountQualification> qualifications = tmpAqg.AccountQualifications;
            foreach (var qualification in qualifications)
            {
                Console.WriteLine("qualification.UniqueId={0}", qualification.UniqueId);
                Console.WriteLine("qualification.Priority={0}", qualification.Priority);
                Console.WriteLine("qualification.TableToInclude={0}", qualification.TableToInclude);
                Console.WriteLine("qualification.Mode={0}", qualification.Mode);
                Console.WriteLine("qualification.MvmFilter={0}", qualification.MvmFilter);
                Console.WriteLine("qualification.DbFilter={0}", qualification.DbFilter);
                Console.WriteLine("qualification.MatchField={0}", qualification.MatchField);
                Console.WriteLine("qualification.OutputField={0}", qualification.OutputField);
                Console.WriteLine("qualification.SourceField={0}", qualification.SourceField);
            }
        }
    }

    [TestMethod]
    [TestCategory("TestSortByActive")]
    [TestCategory("AMPTest")]
    public void TestSortByActive()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        // Delete all decisions, so we start fresh
        MTList<Decision> decisionsToDelete = new MTList<Decision>();
        client.GetDecisions(ref decisionsToDelete);
        List<Decision> tmpDecisionsToDelete = decisionsToDelete.Items;
        Console.WriteLine("tmpDecisionsToDelete.Count={0}", tmpDecisionsToDelete.Count);
               
        foreach (var tmpDecision in tmpDecisionsToDelete)
        {
            Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}",
                tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue);
            client.DeleteDecision(tmpDecision.Name);
        }

        // Create Decision
        Decision d1;
        Decision d2;
        Decision d3;
        Decision d4;
        Decision d5;
        Decision d6;
        Decision d7;
        Decision d8;
        Decision d9;
        Decision d91;

        client.CreateDecision("d1", "d1Description", "t_pt_TieredUnitRatesPT", out d1);
        client.CreateDecision("d2", "d2Description", "t_pt_TieredUnitRatesPT", out d2);
        client.CreateDecision("d3", "d3Description", "t_pt_TieredUnitRatesPT", out d3);
        client.CreateDecision("d4", "d4Description", "t_pt_TieredUnitRatesPT", out d4);
        client.CreateDecision("d5", "d5Description", "t_pt_TieredUnitRatesPT", out d5);
        client.CreateDecision("d6", "d6Description", "t_pt_TieredUnitRatesPT", out d6);
        client.CreateDecision("d7", "d7Description", "t_pt_TieredUnitRatesPT", out d7);
        client.CreateDecision("d8", "d8Description", "t_pt_TieredUnitRatesPT", out d8);
        client.CreateDecision("d9", "d9Description", "t_pt_TieredUnitRatesPT", out d9);
        client.CreateDecision("d91", "d91Description", "t_pt_TieredUnitRatesPT", out d91);
        d4.IsActive = true;
        client.SaveDecision(d4);

        MTList<Decision> listOfDecisions = new MTList<Decision>();
        listOfDecisions.SortCriteria.Add(new SortCriteria( "IsActive", SortType.Descending));
        listOfDecisions.SortCriteria.Add(new SortCriteria( "Name", SortType.Ascending));

        client.GetDecisions(ref listOfDecisions);
        List<Decision> tmpListOfDecisions = listOfDecisions.Items;

        // order should be d4, d1, d2, d3, d5
        if ((tmpListOfDecisions[0].Name == "d4") &&
            (tmpListOfDecisions[1].Name == "d1") &&
            (tmpListOfDecisions[2].Name == "d2") &&
            (tmpListOfDecisions[3].Name == "d3") &&
            (tmpListOfDecisions[4].Name == "d5"))
        {
            Console.WriteLine("Decisions sorted correctly, d4, d1, d2, d3, d5");
        }
        else
        {
            Assert.Fail("invalid sorting by isActive/Name");
        }

        Console.WriteLine("Decisions sorted by IsActive/Name");
        foreach (var tmpDecision in tmpListOfDecisions)
        {
            Console.WriteLine("decisionName={0}, IsActive={1}",
                tmpDecision.Name, tmpDecision.IsActive);
        }

        d3.IsActive = true;
        client.SaveDecision(d3);

        MTList<Decision> listOfDecision2 = new MTList<Decision>();
        listOfDecision2.SortCriteria.Add(new SortCriteria( "IsActive", SortType.Descending));
        listOfDecision2.SortCriteria.Add(new SortCriteria( "Name", SortType.Ascending));

        client.GetDecisions(ref listOfDecision2);
        tmpListOfDecisions = listOfDecision2.Items;

        // Order should be d3, d4, d1, d2, d5
        if ((tmpListOfDecisions[0].Name == "d3") &&
            (tmpListOfDecisions[1].Name == "d4") &&
            (tmpListOfDecisions[2].Name == "d1") &&
            (tmpListOfDecisions[3].Name == "d2") &&
            (tmpListOfDecisions[4].Name == "d5"))
        {
            Console.WriteLine("Decisions sorted correctly, d3, d4, d1, d2, d5");
        }
        else
        {
            Assert.Fail("invalid sorting by isActive/Name");
        }

        Console.WriteLine("Decisions sorted by IsActive/Name");
        foreach (var tmpDecision in tmpListOfDecisions)
        {
            Console.WriteLine("decisionName={0}, IsActive={1}",
                tmpDecision.Name, tmpDecision.IsActive);
        }
    }

    [TestMethod]
    [TestCategory("TestSortByPriorityValue")]
    [TestCategory("AMPTest")]
    public void TestSortByPriorityValue()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

      // Delete all decisions, so we start fresh
      MTList<Decision> decisionsToDelete = new MTList<Decision>();
      client.GetDecisions(ref decisionsToDelete);
      List<Decision> tmpDecisionsToDelete = decisionsToDelete.Items;
      Console.WriteLine("tmpDecisionsToDelete.Count={0}", tmpDecisionsToDelete.Count);

      foreach (var tmpDecision in tmpDecisionsToDelete)
      {
        Console.WriteLine("decisionName={0}, tierStart={1}, tierEnd={2}",
            tmpDecision.Name, tmpDecision.TierStartValue, tmpDecision.TierEndValue);
        client.DeleteDecision(tmpDecision.Name);
      }

      // Create Decision
      Decision d1;
      Decision d2;
      Decision d3;
      Decision d4;
      Decision d5;

      client.CreateDecision("d1", "d1Description", "t_pt_TieredUnitRatesPT", out d1);
      client.CreateDecision("d2", "d2Description", "t_pt_TieredUnitRatesPT", out d2);
      client.CreateDecision("d3", "d3Description", "t_pt_TieredUnitRatesPT", out d3);
      client.CreateDecision("d4", "d4Description", "t_pt_TieredUnitRatesPT", out d4);
      client.CreateDecision("d5", "d5Description", "t_pt_TieredUnitRatesPT", out d5);

      MTList<Decision> listOfDecisions = new MTList<Decision>();
      listOfDecisions.SortCriteria.Add(new SortCriteria("PriorityValue", SortType.Ascending));
      listOfDecisions.SortCriteria.Add(new SortCriteria("Name", SortType.Ascending));

      client.GetDecisions(ref listOfDecisions);
      List<Decision> tmpListOfDecisions = listOfDecisions.Items;

      // order should be d1, d2, d3, d4, d5
      if ((tmpListOfDecisions[0].Name == "d1") &&
          (tmpListOfDecisions[1].Name == "d2") &&
          (tmpListOfDecisions[2].Name == "d3") &&
          (tmpListOfDecisions[3].Name == "d4") &&
          (tmpListOfDecisions[4].Name == "d5"))
        {
        Console.WriteLine("Decisions sorted correctly, d1, d2, d3, d4, d5");
      }
      else
            {
        Assert.Fail("invalid sorting by PriorityValue/Name");
      }

      Console.WriteLine("Decisions sorted by PriorityValue/Name");
      foreach (var tmpDecision in tmpListOfDecisions)
      {
        Console.WriteLine("decisionName={0}, PriorityValue={1}",
            tmpDecision.Name, tmpDecision.PriorityValue);
            }

      d3.PriorityValue = 500;
      client.SaveDecision(d3);

      MTList<Decision> listOfDecision2 = new MTList<Decision>();
      listOfDecision2.SortCriteria.Add(new SortCriteria("PriorityValue", SortType.Ascending));
      listOfDecision2.SortCriteria.Add(new SortCriteria("Name", SortType.Ascending));

      client.GetDecisions(ref listOfDecision2);
      tmpListOfDecisions = listOfDecision2.Items;

      // Order should be d1, d2, d4, d5, d3
      if ((tmpListOfDecisions[0].Name == "d1") &&
          (tmpListOfDecisions[1].Name == "d2") &&
          (tmpListOfDecisions[2].Name == "d4") &&
          (tmpListOfDecisions[3].Name == "d5") &&
          (tmpListOfDecisions[4].Name == "d3"))
            {
        Console.WriteLine("Decisions sorted correctly, d1, d2, d4, d5, d3");
            }
            else
            {
        Assert.Fail("invalid sorting by PriorityValue/Name");
            }

      Console.WriteLine("Decisions sorted by PriorityValue/Name");
      foreach (var tmpDecision in tmpListOfDecisions)
      {
        Console.WriteLine("decisionName={0}, PriorityValue={1}",
            tmpDecision.Name, tmpDecision.PriorityValue);
        }
    }

    [TestMethod]
    [TestCategory("TestPvToAmountChainMapping")]
    [TestCategory("AMPTest")]
    public void TestPvToAmountChainMapping()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";
        
        // Test creating/updating/deleting amount chains
        AmountChain ac1;
        client.CreateAmountChain("ac1", "ac1Description", "t_pv_ac1", false, out ac1);
        AmountChainField acf1 = new AmountChainField();
        acf1.FieldName = "myAmount";
        acf1.FieldRelationship = AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT;
        acf1.CurrencyValue = "USD";
        ac1.AmountChainFields.Add(acf1);
        client.SaveAmountChain(ac1);

        AmountChain ac1Copy;
        client.GetAmountChain("ac1", out ac1Copy);
        Assert.AreEqual(ac1Copy.Name, "ac1");
        Assert.AreEqual(ac1Copy.Description, "ac1Description");
        Assert.AreEqual(ac1Copy.ProductViewName, "t_pv_ac1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].FieldName, "myAmount");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].FieldRelationship, AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT);
        Assert.AreEqual(ac1Copy.AmountChainFields[0].CurrencyValue, "USD");

        // update AmountChainField
        ac1Copy.AmountChainFields[0].CurrencyValue = "EUR";
        ac1Copy.AmountChainFields[0].Rounding = AmountChain.RoundingOptionsEnum.ROUND_TO_CURRENCY;
        client.SaveAmountChain(ac1Copy);
        AmountChain ac1Copy2;
        client.GetAmountChain("ac1", out ac1Copy2);
        Assert.AreEqual(ac1Copy2.Name, "ac1");
        Assert.AreEqual(ac1Copy2.Description, "ac1Description");
        Assert.AreEqual(ac1Copy2.ProductViewName, "t_pv_ac1");
        Assert.AreEqual(ac1Copy2.AmountChainFields[0].FieldName, "myAmount");
        Assert.AreEqual(ac1Copy2.AmountChainFields[0].FieldRelationship, AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT);
        Assert.AreEqual(ac1Copy2.AmountChainFields[0].CurrencyValue, "EUR");


        // delete amount chain field
        ac1Copy2.AmountChainFields.RemoveAt(0);
        client.SaveAmountChain(ac1Copy2);
        AmountChain ac1Copy3;
        client.GetAmountChain("ac1", out ac1Copy3);
        Assert.AreEqual(ac1Copy3.Name, "ac1");
        Assert.AreEqual(ac1Copy3.Description, "ac1Description");
        Assert.AreEqual(ac1Copy3.ProductViewName, "t_pv_ac1");
        Assert.AreEqual(ac1Copy3.AmountChainFields.Count, 0);

        AmountChain ac2;
        client.CreateAmountChain("ac2", "ac2Description", "t_pv_ac2", false, out ac2);

        AmountChain ac3;
        client.CreateAmountChain("ac3", "ac3Description", "t_pv_ac3", false, out ac3);

        PvToAmountChainMapping mapping1;
        client.CreatePvToAmountChainMapping("mapping1", "mappingDescription1", 
            "myProductViewName1", ac1.UniqueId, out mapping1);

        PvToAmountChainMapping mapping2;
        client.CreatePvToAmountChainMapping("mapping2", "mappingDescription2", 
            "myProductViewName2", ac2.UniqueId, out mapping2);

        PvToAmountChainMapping mapping3;
        client.CreatePvToAmountChainMapping("mapping", "mappingDescription3", 
            "myProductViewName3", ac3.UniqueId, out mapping3);

        MTList<PvToAmountChainMapping> mappings = new MTList<PvToAmountChainMapping>();
        client.GetPvToAmountChainMappings(ref mappings);
        List<PvToAmountChainMapping> tmpMappings = mappings.Items;
        Assert.AreEqual(tmpMappings.Count, 3);
        MTList<DistinctNamedPvToAmountChainMapping> distinctNamedMappings = new MTList<DistinctNamedPvToAmountChainMapping>();
        client.GetDistinctNamedPvToAmountChainMappings(ref distinctNamedMappings);
        Assert.AreEqual(distinctNamedMappings.Items.Count, 3);

        client.DeletePvToAmountChainMapping(mapping2.UniqueId);
        MTList<PvToAmountChainMapping> mappings2 = new MTList<PvToAmountChainMapping>();
        client.GetPvToAmountChainMappings(ref mappings2);
        List<PvToAmountChainMapping> tmpMappings2 = mappings2.Items;
        Assert.AreEqual(tmpMappings2.Count, 2);

        mapping3.ProductViewName = "updatedPV";
        client.SavePvToAmountChainMapping(mapping3);
        PvToAmountChainMapping mapping3copy;
        client.GetPvToAmountChainMapping(mapping3.UniqueId, out mapping3copy);
        Assert.AreEqual(mapping3copy.ProductViewName, "updatedPV");

    }

    [TestMethod]
    [TestCategory("TestAmountChains")]
    [TestCategory("AMPTest")]
    public void TestAmountChains()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";
        
        // Test creating/updating/deleting amount chains
        AmountChain ac1;
        client.CreateAmountChain("myac1", "ac1Description", "t_pv_ac1", false, out ac1);
        AmountChainField acf1 = new AmountChainField();
        acf1.FieldName = "myAmount";
        acf1.FieldRelationship = AmountChainField.FieldRelationshipEnum.RELATIONSHIP_UNITS_OF_USAGE;
        acf1.Filter = "filter1";
        acf1.ContributingField = "ContributingField1";
        acf1.PercentageColumnName = "c_percentage1";
        acf1.Modifier = "modifier1";
        acf1.Rounding = AmountChain.RoundingOptionsEnum.ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS;
        acf1.Priority = 777;
        acf1.CurrencyColumnName = "c_currency";
        ac1.AmountChainFields.Add(acf1);
        client.SaveAmountChain(ac1);

        AmountChain ac1Copy;
        client.GetAmountChain("myac1", out ac1Copy);
        Assert.AreEqual(ac1Copy.Name, "myac1");
        Assert.AreEqual(ac1Copy.Description, "ac1Description");
        Assert.AreEqual(ac1Copy.ProductViewName, "t_pv_ac1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].FieldName, "myAmount");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].FieldRelationship, AmountChainField.FieldRelationshipEnum.RELATIONSHIP_UNITS_OF_USAGE);
        Assert.AreEqual(ac1Copy.AmountChainFields[0].CurrencyColumnName, "c_currency");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].Filter, "filter1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].ContributingField, "ContributingField1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].PercentageColumnName, "c_percentage1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].Modifier, "modifier1");
        Assert.AreEqual(ac1Copy.AmountChainFields[0].Rounding, AmountChain.RoundingOptionsEnum.ROUND_TO_SPECIFIED_NUMBER_OF_DIGITS);
        Assert.AreEqual(ac1Copy.AmountChainFields[0].Priority, 777);
    }

    [TestMethod]
    [TestCategory("TestThrowException")]
    [TestCategory("AMPTest")]
    public void TestThrowException()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";

        try
        {
            client.DeleteDecision("aaabbbaaa");
            Assert.Fail("expected DeleteDecision('aaabbbaaa') to throw an exception");
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            {
                err += ", " + msg;
            }
            Console.WriteLine("Exception thrown as expected, {0}",
                              err);
        }

        try
        {
            Decision decision;
            client.CreateDecision("foobar123", "foobar123", "t_pt_TieredUnitRatesPT", out decision);
            Decision decision2;
            client.CreateDecision("foobar123", "foobar123", "t_pt_TieredUnitRatesPT", out decision2);
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            {
                err += ", " + msg;
            }
            Console.WriteLine("Exception thrown as expected, {0}",
                              err);
        }
    }


    [TestMethod]
    [TestCategory("TestCapability")]
    [TestCategory("AMPTest")]
    public void TestCapability()
    {

        // Remove "ManageAmpDecisions" capability to user csr1
        IMTLoginContext loginContext = new MTLoginContextClass();
        MTSessionContext loginSessionContext = loginContext.Login("su", "system_user", "su123");
        IMTSecurity securityObject = new MTSecurityClass();
        IMTAccountCatalog accountCatalog = new MTAccountCatalogClass();
        accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext) loginSessionContext);

        MTYAAC userCsr1 = accountCatalog.GetAccountByName("csr1", "system_user", DateTime.Now);

        IMTYAAC csr1Account = securityObject.GetAccountByID((MTSessionContext) loginSessionContext, userCsr1.AccountID,
                                                            DateTime.Now);

        IMTCompositeCapability manageAmpDecisionsCapability =
            securityObject.GetCapabilityTypeByName("ManageAmpDecisions").CreateInstance();

        csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).RemoveCapabilitiesOfType(
            securityObject.GetCapabilityTypeByName("ManageAmpDecisions").ID);
        csr1Account.GetActivePolicy((MTSessionContext) loginSessionContext).Save();

        try
        {
            AmpServiceClient client1 = new AmpServiceClient();
            client1.ClientCredentials.UserName.UserName = "csr1";
            client1.ClientCredentials.UserName.Password = "csr123";
            MTList<Decision> listOfDecisions = new MTList<Decision>();
            client1.GetDecisions(ref listOfDecisions);
            Assert.Fail("expected GetDecisions() to fail because csr1 does not have ManageAmpDecisions capability");
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            {
                err += ", " + msg;
            }
            Console.WriteLine("Exception thrown as expected, {0}",
                              err);
        }

        // Add "ManageAmpDecisions" capability to user csr1
        csr1Account.GetActivePolicy((MTSessionContext)loginSessionContext).AddCapability(
            manageAmpDecisionsCapability);
        csr1Account.GetActivePolicy((MTSessionContext) loginSessionContext).Save();
    }


    [TestMethod]
    [TestCategory("TestCreateAndDeleteAmountChain")]
    [TestCategory("AMPTest")]
    public void TestCreateAndDeleteAmountChain()
    {
        AmpServiceClient client = new AmpServiceClient();
        client.ClientCredentials.UserName.UserName = "csr1";
        client.ClientCredentials.UserName.Password = "csr123";
        
        // Delete all AmountChains, so we start fresh
        MTList<AmountChain> amountChains = new MTList<AmountChain>();
        client.GetAmountChains(ref amountChains);
        List<AmountChain> tmpAmountChains = amountChains.Items;
        Console.WriteLine("tmpAmountChains.Count={0}", tmpAmountChains.Count);
        foreach (var amountChain in tmpAmountChains)
        {
            Console.WriteLine("deleting AmountChain={0}",
                amountChain.Name);
            client.DeleteAmountChain(amountChain.Name);
        }

        // create amountChain
        AmountChain amountChain1;
        client.CreateAmountChain("amountChain1", "amountChain1Description", "t_pv_amountChain1", false, out amountChain1);
        AmountChainField amountChainField1 = new AmountChainField();
        amountChainField1.FieldName = "myAmount";
        amountChainField1.FieldRelationship = AmountChainField.FieldRelationshipEnum.RELATIONSHIP_AMOUNT;
        amountChainField1.CurrencyValue = "USD";
        amountChain1.AmountChainFields.Add(amountChainField1);
        client.SaveAmountChain(amountChain1);

        // delete amountChain
        Console.WriteLine("deleting AmountChain=amountChain1");
        client.DeleteAmountChain("amountChain1");
    }

    [TestMethod]
    [TestCategory("GetProductViewNamesWithLocalizedNames")]
    public void GetProductViewNamesWithLocalizedNames()
    {
      AmpServiceClient client = new AmpServiceClient();
      client.ClientCredentials.UserName.UserName = "csr1";
      client.ClientCredentials.UserName.Password = "csr123";

      var names = new MTList<ProductViewNameInstance>();

      client.GetProductViewNamesWithLocalizedNames(ref names);
      var tmpNames = names.Items;

      foreach (var tmpName in tmpNames)
      {
        Console.WriteLine("productViewName={0}: There are {1} localized names for this product view:", tmpName.Name, tmpName.LocalizedDisplayNames.Count);
        foreach (var localizedDisplayName in tmpName.LocalizedDisplayNames)
        {
          Console.WriteLine("    languageCode {0}: {1}",localizedDisplayName.Key.ToString(),localizedDisplayName.Value.ToString());
        }
      }
    }

    [TestMethod]
    [TestCategory("GetProductViewColumnNamesWithTypes")]
    public void GetProductViewColumnNamesWithTypes()
    {
      AmpServiceClient client = new AmpServiceClient();
      client.ClientCredentials.UserName.UserName = "csr1";
      client.ClientCredentials.UserName.Password = "csr123";

      var names = new MTList<ProductViewNameInstance>();

      client.GetProductViewNamesWithLocalizedNames(ref names);
      var tmpNames = names.Items;

      foreach (var tmpName in tmpNames)
      {
        var columnNames = new MTList<ProductViewPropertyInstance>();
        client.GetProductViewColumnNamesWithTypes(tmpName.TableName, ref columnNames);
        foreach (var columnName in columnNames.Items)
        {
          Console.WriteLine("productViewTable {0}: column {1}", tmpName.TableName, columnName.Name);
          Console.WriteLine("column={0}: There are {1} localized names for this column:", columnName.Name, columnName.LocalizedDisplayNames.Count);
          foreach (var localizedDisplayName in columnName.LocalizedDisplayNames)
          {
            Console.WriteLine("    languageCode {0}: {1}", localizedDisplayName.Key.ToString(), localizedDisplayName.Value.ToString());
          }
        }
      }
    }

    [TestMethod]
    [TestCategory("TestGetDecisionInstances")]
    [TestCategory("AMPTest")]
    public void TestGetDecisionInstances()
    {
        try
        {
            // just a test comment
            // just a test comment
            AmpServiceClient client = new AmpServiceClient();
            client.ClientCredentials.UserName.UserName = "csr1";
            client.ClientCredentials.UserName.Password = "csr123";

            // Retrieve the list of decision instances
            // No sorting applied
            MTList<DecisionInstance> listOfDecisionInstances = new MTList<DecisionInstance>();
            listOfDecisionInstances.Filters = new List<MTBaseFilterElement>();
            listOfDecisionInstances.Filters.Add(new MTFilterElement("AccountId", MTFilterElement.OperationType.Equal, 123));

            client.GetDecisionInstances(ref listOfDecisionInstances);
            List<DecisionInstance> tmpListOfDecisionInstances = listOfDecisionInstances.Items;

            Console.WriteLine("DecisionInstances with no sorting");
            foreach (var tmpDecisionInstance in tmpListOfDecisionInstances)
            {
                Console.WriteLine("accountId={0}, decisionUniqueId={1}, tierEnd={2}, tierStart={3}, accountQualificationGroup={4}",
                                    tmpDecisionInstance.AccountId, tmpDecisionInstance.DecisionUniqueId, tmpDecisionInstance.TierEnd, tmpDecisionInstance.TierStart, tmpDecisionInstance.AccountQualificationGroup);
                if (tmpDecisionInstance.OtherDecisionAttributes != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherDecisionAttributes)
                    {
                        Console.WriteLine("Attribute: {0}={1}", k.Key, k.Value);
                    }
                }
                if (tmpDecisionInstance.OtherInstanceValues != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherInstanceValues)
                    {
                        Console.WriteLine("Instance: {0}={1}", k.Key, k.Value);
                    }
                }
            }

            // Retrieve the list of decisions, and print out the tierstart and tierend
            // sorted by "Name"
            MTList<DecisionInstance> listOfDecisionInstances2 = new MTList<DecisionInstance>();
            listOfDecisionInstances2.SortCriteria.Add(new SortCriteria("AccountId", SortType.Ascending));

            client.GetDecisionInstances(ref listOfDecisionInstances2);

            tmpListOfDecisionInstances = listOfDecisionInstances2.Items;

            Console.WriteLine("DecisionInstances sorted by name");
            foreach (var tmpDecisionInstance in tmpListOfDecisionInstances)
            {
                Console.WriteLine("accountId={0}, decisionUniqueId={1}, tierEnd={2}, tierStart={3}, accountQualificationGroup={4}",
                                    tmpDecisionInstance.AccountId, tmpDecisionInstance.DecisionUniqueId, tmpDecisionInstance.TierEnd, tmpDecisionInstance.TierStart, tmpDecisionInstance.AccountQualificationGroup);
                if (tmpDecisionInstance.OtherDecisionAttributes != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherDecisionAttributes)
                    {
                        Console.WriteLine("Attribute: {0}={1}", k.Key, k.Value);
                    }
                }
                if (tmpDecisionInstance.OtherInstanceValues != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherInstanceValues)
                    {
                        Console.WriteLine("Instance: {0}={1}", k.Key, k.Value);
                    }
                }
            }

            // Retrieve the list of decisions, and print out the tierstart and tierend
            // sorted by "IsActive"
            MTList<DecisionInstance> listOfDecisionInstances3 = new MTList<DecisionInstance>();
            listOfDecisionInstances3.SortCriteria.Add(new SortCriteria("NOrder", SortType.Descending));

            client.GetDecisionInstances(ref listOfDecisionInstances3);
            tmpListOfDecisionInstances = listOfDecisionInstances3.Items;

            Console.WriteLine("DecisionInstances sorted by IsActive");
            foreach (var tmpDecisionInstance in tmpListOfDecisionInstances)
            {
                Console.WriteLine("accountId={0}, decisionUniqueId={1}, tierEnd={2}, tierStart={3}, accountQualificationGroup={4}",
                                    tmpDecisionInstance.AccountId, tmpDecisionInstance.DecisionUniqueId, tmpDecisionInstance.TierEnd, tmpDecisionInstance.TierStart, tmpDecisionInstance.AccountQualificationGroup);
                if (tmpDecisionInstance.OtherDecisionAttributes != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherDecisionAttributes)
                    {
                        Console.WriteLine("Attribute: {0}={1}", k.Key, k.Value);
                    }
                }
                if (tmpDecisionInstance.OtherInstanceValues != null)
                {
                    foreach (var k in tmpDecisionInstance.OtherInstanceValues)
                    {
                        Console.WriteLine("Instance: {0}={1}", k.Key, k.Value);
                    }
                }
            }
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            string err = fe.Message;

            foreach (string msg in fe.Detail.ErrorMessages)
            {
                err += ", " + msg;
            }
            throw new ApplicationException(err, fe);
        }


    }

#if false
    // REMOVED THIS TEST BECAUSE ADMIN PASSWORD IS VARIABLE
    // This test shows that admin has all privileges/capabilities.
    [TestMethod]
    [TestCategory("TestAdmin")]
    [TestCategory("AMPTest")]
    public void TestAdmin()
    {
        try
        {
            AmpServiceClient client1 = new AmpServiceClient();
            client1.ClientCredentials.UserName.UserName = "admin";
            client1.ClientCredentials.UserName.Password = "123";
            MTList<Decision> listOfDecisions = new MTList<Decision>();
            client1.GetDecisions(ref listOfDecisions);
            
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {

            Assert.Fail("admin should have all privileges: {0}", fe.Message);
        }

    }
#endif

  }
}
