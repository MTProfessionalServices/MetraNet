namespace MetraTech.Product.Hooks.Test
{
  using System;
  using System.Collections;
  using MetraTech.Product.Hooks;
  using NUnit.Framework;
  using MetraTech.Interop.MTProductCatalog;

  [TestFixture]
  [Category("NoAutoRun")]

  public class PriceableItemTypeHookTest 
  {
    private static String mPath="C:\\mainline\\development\\Source\\MetraTech\\Product\\Hooks\\test\\";

    [Test] public void TestRC()
    {
        PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
        // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
        // Local file path replaced with the environment variable
        writer.UpdatePriceableItemTypeFromFile(System.IO.Path.Combine(Environment.GetEnvironmentVariable("MTRMP"),
                                                                      "extensions\\core\\config\\PriceableItems\\FlatRateRecurringCharge.xml"));
    }


      [Test] public void TestFlatDiscountDeserialization()
      {
          MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc = new MTProductCatalog();

          XmlSerializer xml = new XmlSerializer(pc);
          // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
          // Local file path replaced with the environment variable
          PriceableItemType piType =
              xml.LoadPriceableItemTypeFromXML(System.IO.Path.Combine(Environment.GetEnvironmentVariable("MTRMP"),
                                                                      "extensions\\core\\config\\PriceableItems\\FlatDiscount.xml"));

          Assert.IsTrue(piType.Name == "Flat Discount");
          Assert.IsTrue(piType.Description == "Flat discount based on 1 qualifer");
          Assert.IsTrue(piType.EntityType == MTPCEntityType.PCENTITY_TYPE_DISCOUNT);
          Assert.IsTrue(piType.ServiceDefinition == "metratech.com/flatdiscount");
          Assert.IsTrue(piType.ProductView == "metratech.com/flatdiscount");
          Assert.IsTrue(piType.Children.Count == 0);
          Assert.IsTrue(piType.ParameterTables.Count == 1);
          ParameterTable pt = (ParameterTable) piType.ParameterTables[0];
          Assert.IsTrue(pt.Name == "metratech.com/flatdiscount");
          Assert.IsTrue(piType.CounterTypes.Count == 0);
          Assert.IsTrue(piType.CounterPropertyDefinitions.Count == 1);
          CounterPropertyDefinition cpd = (CounterPropertyDefinition) piType.CounterPropertyDefinitions[0];
          Assert.IsTrue(cpd.Name == "Qualifier");
          Assert.IsTrue(cpd.DisplayName == "Counter used to qualify for discount");
          Assert.IsTrue(cpd.ServiceProperty == "c_FlatRateQualifier");
          Assert.IsTrue(cpd.PreferredCounterTypeName == "SumOfOneProperty");
          Assert.IsTrue(cpd.ConfiguredCounter == null);
          Assert.IsTrue(piType.Charges.Count == 0);
          Assert.IsTrue(piType.AdjustmentTypes.Count == 0);
          Assert.IsTrue(piType.FileChecksum != "");
      }

      [Test] public void TestFlatDiscountCreation()
      {
          IMTProductCatalog pc =
              (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

          XmlSerializer xml = new XmlSerializer(pc);
          // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
          // Local file path replaced with the environment variable
          PriceableItemType piType =
              xml.LoadPriceableItemTypeFromXML(System.IO.Path.Combine(Environment.GetEnvironmentVariable("MTRMP"),
                                                                      "extensions\\core\\config\\PriceableItems\\FlatDiscount.xml"));

          // Disambiguate the name of the discount based on current date (don't run twice a day!)
          piType.Name = piType.Name + "_" + DateTime.Now.Date.ToString();

          PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
          writer.UpdatePriceableItemType(piType);
      }

      [Test] public void TestFlatDiscountRemoval()
      {
          IMTProductCatalog pc =
              (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

          XmlSerializer xml = new XmlSerializer(pc);
          // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
          // Local file path replaced with the environment variable
          PriceableItemType piType =
              xml.LoadPriceableItemTypeFromXML(System.IO.Path.Combine(Environment.GetEnvironmentVariable("MTRMP"),
                                                                      "extensions\\core\\config\\PriceableItems\\FlatDiscount.xml"));

          // Disambiguate the name of the discount based on current date 
          piType.Name = piType.Name + "_" + DateTime.Now.Date.ToString();

          PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
          writer.RemovePriceableItemType(piType);
      }

      [Test] public void TestFlatDiscountDiff()
      {
          IMTProductCatalog pc =
              (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

          XmlSerializer xml = new XmlSerializer(pc);
          // CORE-5016: FEAT-90: descriptions in DB aren't updated after chanding in ICE
          // Local file path replaced with the environment variable
          PriceableItemType piType =
              xml.LoadPriceableItemTypeFromXML(System.IO.Path.Combine(Environment.GetEnvironmentVariable("MTRMP"),
                                                                      "extensions\\core\\config\\PriceableItems\\FlatDiscount.xml"));

          // The version from the product catalog 
          IMTPriceableItemType pcPiType =
              pc.GetPriceableItemTypeByName(piType.Name);

          PriceableItemTypeDifference diff = new PriceableItemTypeDifference();
          ArrayList program = new ArrayList();
          diff.Calculate(pcPiType, piType, program);

          foreach (Instruction inst in program)
          {
              Console.WriteLine(inst.ToString());
          }

          foreach (Object obj in diff.Delete)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.Create)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.Charges.Delete)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.Charges.Create)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.ParameterTables.Delete)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.ParameterTables.Create)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.CounterPropertyDefinitions.Delete)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }
          foreach (Object obj in diff.CounterPropertyDefinitions.Create)
          {
              // This "if" statement is here to prevent the compiler from generating unneeded
              // "CS0168: The variable 'obj' is declared but never used" warning messages.
              if ((obj == null)
                  || (obj != null))
                  Assert.IsTrue(false);
          }

          // Add a new parameter table, remove all counter
          // property defintions and replace with a new one.
          ParameterTable pt = new ParameterTable();
          pt.Name = "metratech.com/percentdiscount";
          pt.WeightOnKey = "sdfsdf";
          pt.StartAt = "sdfsdf";
          pt.InSession = "sdfsdf";
          pt.HasIndexedProperty = false;
          pt.Extension = "core";
          piType.ParameterTables.Add(pt);

          piType.CounterPropertyDefinitions.Clear();
          CounterPropertyDefinition cpd = new CounterPropertyDefinition();
          cpd.Name = "NewCPD";
          cpd.DisplayName = "NewCPD";
          cpd.ServiceProperty = "ServiceProperty";
          cpd.PreferredCounterTypeName = "CounterType";
          piType.CounterPropertyDefinitions.Add(cpd);
          diff = new PriceableItemTypeDifference();
          program = new ArrayList();
          diff.Calculate(pcPiType, piType, program);
          program.Sort();
          foreach (Instruction inst in program)
          {
              Console.WriteLine(inst.ToString());
          }
      }

      [Test] public void TestRecurringChargeCreate()
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "RecurringChargeCopy.xml");
      // Check the adjustments collection has a couple of adjustments
      Assert.IsTrue(piType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 1);

      // Save this so we can get the PC object later.
      String rcName = piType.Name;

      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      IMTPriceableItemType pcPiType =
      pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }

      // Save the piType
      PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);
      
      // Validate that the recurring charge exists.
      // The version from the product catalog 
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);

      // TODO: Add more checks that we get the right thing back.
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 1);
      Assert.IsTrue(((IMTParamTableDefinition)pcPiType.GetParamTableDefinitions()[1]).Name == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).DisplayName == "Recurring Charge Flat Adjustment Copy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).SupportsBulk == true);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 1);
      Assert.IsTrue(pcPiType.ServiceDefinition == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(pcPiType.ProductView == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(pcPiType.Description == "Recurring charge with a flat rate");

      MetraTech.Interop.MTProductView.IProductViewCatalog pvCatalog = new MetraTech.Interop.MTProductView.ProductViewCatalogClass();
      MetraTech.Interop.MTProductView.IProductView pv = pvCatalog.GetProductViewByName(piType.ProductView);
      

      // Create some charges on the pi type
      Charge charge = new Charge("RCAmount", "RCAmount", pv.GetPropertyByName("RCAmount").ID);
      charge.AddChargeProperty("ProratedOnSubscription", pv.GetPropertyByName("ProratedOnSubscription").ID);
      charge.PIType = piType;
      piType.AddCharge(charge);
      
      // Update with new charge
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);     

      // Read back from the database and verify that a charge exists.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      IMTCollection pcCharges = pcPiType.GetCharges();
      Assert.IsTrue(1 == pcCharges.Count);
      foreach(IMTCharge pcCharge in pcCharges)
      {
        Assert.IsTrue(pcCharge.Name == "RCAmount");
        Assert.IsTrue(1 == pcCharge.GetChargeProperties().Count);
      }

      // Add a new charge property and save again
      charge.AddChargeProperty("ProratedOnUnsubscription", pv.GetPropertyByName("ProratedOnUnsubscription").ID);
      // Add a new parameter table as well
      ParameterTable pt = new ParameterTable();
      pt.Name = "metratech.com/udrctiered";
      pt.WeightOnKey = "";
      pt.StartAt = "";
      pt.InSession = "";
      pt.HasIndexedProperty = false;
      pt.Extension = "core";
      piType.ParameterTables.Add(pt);

      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);     
      
      // Read back from the database and verify that a charge exists.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 2);
      Assert.IsTrue(((IMTParamTableDefinition)pcPiType.GetParamTableDefinitions()[1]).Name == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(((IMTParamTableDefinition)pcPiType.GetParamTableDefinitions()[2]).Name == "metratech.com/udrctiered");
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(pcPiType != null);
      pcCharges = pcPiType.GetCharges();
      Assert.IsTrue(1 == pcCharges.Count);
      foreach(IMTCharge pcCharge in pcCharges)
      {
        Assert.IsTrue(pcCharge.Name == "RCAmount");
        Assert.IsTrue(2 == pcCharge.GetChargeProperties().Count);
      }

      // Delete the charge
      piType.Charges.Clear();

      // Get rid of the parameter table we added
      piType.ParameterTables.RemoveAt(1);

      // Update a few of the priceable item type properties
      piType.ServiceDefinition = "metratech.com/udrecurringcharge";
      piType.Description = "This is a copy of the flat rc used in PriceableItemTypeHook unit tests";

      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);     
      // Read back from the database and verify that the charges are gone.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      pcCharges = pcPiType.GetCharges();
      Assert.IsTrue(0 == pcCharges.Count);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 1);
      Assert.IsTrue(((IMTParamTableDefinition)pcPiType.GetParamTableDefinitions()[1]).Name == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(pcPiType.ServiceDefinition == "metratech.com/udrecurringcharge");
      Assert.IsTrue(pcPiType.ProductView == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(pcPiType.Description == "This is a copy of the flat rc used in PriceableItemTypeHook unit tests");

      // Put one of the charges back
      charge = new Charge("RCAmount", "RCAmount", pv.GetPropertyByName("RCAmount").ID);
      charge.AddChargeProperty("ProratedOnSubscription", pv.GetPropertyByName("ProratedOnSubscription").ID);
      charge.PIType = piType;
      piType.AddCharge(charge);

      // Update some of the adjustment type properties
      MetraTech.Adjustments.AdjustmentType adjType = (MetraTech.Adjustments.AdjustmentType) piType.AdjustmentTypes[1];
      adjType.SupportsBulk = false;
      adjType.DisplayName = "This is a modification to the display name";

      // Add a new adjustment type; make sure to add inputs and outputs,
      // adjustment persistence code doesn't seem to handle adjustments with
      // no inputs or outputs.
      adjType = new MetraTech.Adjustments.AdjustmentType();
      adjType.Name = "Adjustment Unit Test Name";
      adjType.Description = "Adjustment Unit Test Description";
      adjType.DisplayName = "Adjustment Unit Test Display Name";
      adjType.SupportsBulk = false;
      adjType.Kind = MetraTech.Adjustments.AdjustmentKind.FLAT;
      adjType.AdjustmentFormula.EngineType = MetraTech.Adjustments.EngineType.MTSQL;
      adjType.AdjustmentFormula.Text = "CREATE PROCEDURE DoAdjustmentCalc \n" +
      "@RCAdjustmentAmount DECIMAL, \n" +
      "@TotalAdjustmentAmount DECIMAL OUTPUT \n" +
      "as \n" +
      "set @TotalAdjustmentAmount = @RCAdjustmentAmount/2.0";
      adjType.AdjustmentTable = "t_aj_flatrecurringcharge";
      adjType.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)pc.GetSessionContext());
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = adjType.RequiredInputs.CreateMetaData("RCAdjustmentAmount");
      md.Name = "RCAdjustmentAmount";
      md.DisplayName = "Amount to adjust recurring charge";
      md.DataType = MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL;
      md = adjType.ExpectedOutputs.CreateMetaData("RCAdjustmentAmount");
      md.Name = "TotalAdjustmentAmount";
      md.DisplayName = "Total amount of the adjustment";
      md.DataType = MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL;
      piType.AdjustmentTypes.Add(adjType);

      // Save the sucker.
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);     
      // Read back from the database and verify that the new charge exists.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).DisplayName == "This is a modification to the display name");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).SupportsBulk == false);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).RequiredInputs.Count == 1);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).ExpectedOutputs.Count == 1);
      Assert.IsTrue(pcPiType.ProductView == "metratech.com/flatrecurringcharge");
      Assert.IsTrue(pcPiType.GetCharges().Count == 1);

      // Look at the charge and validate that it is bound to the
      // product view of the piType.
      Assert.IsTrue(pvCatalog.GetProductViewProperty(((IMTCharge)pcPiType.GetCharges()[1]).AmountPropertyID).ProductView.name == piType.ProductView);

      // Change the product view and check how the charges get modified.
      piType.ProductView = "metratech.com/udrecurringcharge";
      pv = pvCatalog.GetProductViewByName(piType.ProductView);
      charge = (Charge) piType.Charges[0];
      charge.AmountPropertyID = pv.GetPropertyByName(charge.Name).ID;
      ((ChargeProperty) charge.ChargeProperties[0]).ProductViewPropertyID = pv.GetPropertyByName(((ChargeProperty) charge.ChargeProperties[0]).Name).ID;

      // Add another input and save again
      // TODO: Add the code that supports this case
//      md = adjType.RequiredInputs.CreateMetaData("RCAdjustmentAmount2");
//      md.Name = "RCAdjustmentAmount2";
//      md.DisplayName = "Amount to adjust recurring charge2";
//      md.DataType = MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL;
//      // Save the sucker.
//      writer = new PriceableItemTypeWriter();
//      writer.UpdatePriceableItemType(piType);     
//      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
//      Assert.IsTrue(pcPiType != null);
//      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
//      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).RequiredInputs.Count == 2);
//      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).ExpectedOutputs.Count == 1);

      // TODO: Add an applicability rule test
      
      // Remove the adjustment type that we added, save and validate its gone
      piType.AdjustmentTypes.Remove(3);
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);     
      // Read back from the database and verify that the new charge exists.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(pcPiType.ProductView == "metratech.com/udrecurringcharge");
      // Verify that the charge now points to udrecurringcharge.
      Assert.IsTrue(pvCatalog.GetProductViewProperty(((IMTCharge)pcPiType.GetCharges()[1]).AmountPropertyID).ProductView.name == piType.ProductView);

      // Lastly, remove the piType
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);     
    }

    [Test] public void TestSongDownloadsDeserializeXml()
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "SongDownloadsCopy.xml");   
      Assert.IsTrue(piType.Name == "Song Downloads Copy");
      Assert.IsTrue(piType.Description == "Sample aggregate charge");
      Assert.IsTrue(piType.CounterPropertyDefinitions.Count == 2);
      Assert.IsTrue(piType.Template != null);
      Assert.IsTrue(piType.Template.GetType() == typeof(AggregateCharge));
      Assert.IsTrue(piType.Template.Name == "Song Downloads Copy");
      Assert.IsTrue(piType.Charges.Count == 1);
      Assert.IsTrue(((Charge)piType.Charges[0]).Name == "ConnectionFee");
      Assert.IsTrue(((Charge)piType.Charges[0]).DisplayName == "Connection Fee Charge");

      Assert.IsTrue(piType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[2]).Name == "ConnectionFeePercentAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 0);

      // TODO: Check applicability rules on the adj. type
      // Check that the adjustment templates got created.
      Assert.IsTrue(piType.Template.AdjustmentTemplates != null);
      Assert.IsTrue(piType.Template.AdjustmentTemplates.Count == 2);
      Assert.IsTrue(((AdjustmentTemplate)piType.Template.AdjustmentTemplates[0]).Template.Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((AdjustmentTemplate)piType.Template.AdjustmentTemplates[1]).Template.Name == "ConnectionFeePercentAdjustmentCopy");

      // Check reason codes on the template
      Assert.IsTrue(((AdjustmentTemplate)piType.Template.AdjustmentTemplates[0]).ReasonCodes.Count == 2);
      Assert.IsTrue(((AdjustmentTemplate)piType.Template.AdjustmentTemplates[1]).ReasonCodes.Count == 2);
      
      // Check that the counter got created on the template.
      Assert.IsTrue(piType.CounterPropertyDefinitions.Count == 2);
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[0]).Name == "TotalSongs");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[0]).DisplayName == "Total songs downloaded");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[0]).ConfiguredCounter != null);
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[0]).ConfiguredCounter.Name == "TotalSongs");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[0]).ConfiguredCounter.CounterType == "SumOfOneProperty");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[1]).Name == "TotalBytes");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[1]).DisplayName == "Total bytes downloaded");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[1]).ConfiguredCounter != null);
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[1]).ConfiguredCounter.Name == "TotalBytes");
      Assert.IsTrue(((CounterPropertyDefinition)piType.CounterPropertyDefinitions[1]).ConfiguredCounter.CounterType == "SumOfTwoProperties");
    }

    [Test] public void TestSongDownloadsCreateAndUpdate()
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "SongDownloadsCopy.xml");   

      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      IMTPriceableItemType pcPiType =
      pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }

      // Save the piType
      PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);


      // Open the type back up and validate that thing are as they should be....
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "Song Downloads Copy");
      Assert.IsTrue(pcPiType.Description == "Sample aggregate charge");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 2);
      Assert.IsTrue(pcPiType.GetCharges().Count == 1);
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).Name == "ConnectionFee");
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).DisplayName == "Connection Fee Charge");

      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      IMTAggregateCharge pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];      
      Assert.IsTrue(pcTemplate != null);
      Assert.IsTrue(pcTemplate.Name == "Song Downloads Copy");

      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).Name == "ConnectionFeePercentAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 0);

      // Check that the adjustment templates got created.
      IMTCollection adjTemplates = pcTemplate.GetAdjustments();
      Assert.IsTrue(adjTemplates != null);
      Assert.IsTrue(adjTemplates.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).Name == "ConnectionFeePercentAdjustmentCopy");

      // Check reason codes on the template
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).GetApplicableReasonCodes().Count == 2);
      
      // Check that the counter got created on the template.
      IMTCollection cpds = pcPiType.GetCounterPropertyDefinitions();
      Assert.IsTrue(cpds.Count == 2);
      IMTCounterPropertyDefinition pcCpd = (IMTCounterPropertyDefinition)cpds[1];
      IMTCounter pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "TotalSongs");
      Assert.IsTrue(pcCpd.DisplayName == "Total songs downloaded");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "TotalSongs");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfOneProperty");
      pcCpd = (IMTCounterPropertyDefinition)cpds[2];
      pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "TotalBytes");
      Assert.IsTrue(pcCpd.DisplayName == "Total bytes downloaded");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "TotalBytes");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfTwoProperties");

      // Create a new adjustment type and validate that it is
      // saved both on the type and template.
      // Add a new adjustment type; make sure to add inputs and outputs,
      // adjustment persistence code doesn't seem to handle adjustments with
      // no inputs or outputs.
      MetraTech.Adjustments.AdjustmentCatalog ac = new MetraTech.Adjustments.AdjustmentCatalog();
      ac.Initialize(pc.GetSessionContext());
      
      MetraTech.Adjustments.AdjustmentType adjType = new MetraTech.Adjustments.AdjustmentType();
      adjType.Name = "Song Downloads Adjustment Unit Test Name";
      adjType.Description = "Song Downloads Adjustment Unit Test Description";
      adjType.DisplayName = "Song Downloads Adjustment Unit Test Display Name";
      adjType.SupportsBulk = false;
      adjType.Kind = MetraTech.Adjustments.AdjustmentKind.FLAT;
      adjType.AdjustmentFormula.EngineType = MetraTech.Adjustments.EngineType.MTSQL;
      adjType.AdjustmentFormula.Text = "CREATE PROCEDURE DoAdjustmentCalc \n" +
      "@ConnectionFeeAdjustmentAmount DECIMAL, \n" +
      "@TotalAdjustmentAmount DECIMAL OUTPUT \n" +
      "as \n" +
      "set @TotalAdjustmentAmount = @ConnectionFeeAdjustmentAmount/2.0";
      adjType.AdjustmentTable = "t_aj_songdownloads";
      adjType.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)pc.GetSessionContext());
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData md = adjType.RequiredInputs.CreateMetaData("ConnectionFeeAdjustmentAmount");
      md.Name = "ConnectionFeeAdjustmentAmount";
      md.DisplayName = "Amount to adjust connection fee";
      md.DataType = MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL;
      md = adjType.ExpectedOutputs.CreateMetaData("ConnectionFeeAdjustmentAmount");
      md.Name = "TotalAdjustmentAmount";
      md.DisplayName = "Total amount of the adjustment";
      md.DataType = MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL;
      piType.AdjustmentTypes.Add(adjType);

      AdjustmentTemplate adjTemplate = new AdjustmentTemplate();
      adjTemplate.Template.AdjustmentType = adjType;
      adjTemplate.Template.Name = adjType.Name;
      adjTemplate.Template.DisplayName = adjType.DisplayName;
      adjTemplate.Template.Description = adjType.Description;
      adjTemplate.Template.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) pc.GetSessionContext());
      adjTemplate.ReasonCodes.Add(ac.GetReasonCodeByName("RateCorrection"));
      piType.Template.AdjustmentTemplates.Add(adjTemplate);

      // While we are at it, add an applicability rule to one of the existing 
      // adjustments.
      ((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).AddApplicabilityRule(ac.GetApplicabilityRuleByName("IsTransactionPrebill"));

      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).Name == "ConnectionFeePercentAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).Name == "Song Downloads Adjustment Unit Test Name");
      // Check that the applicability rule got added and that the others are empty
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 1);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[3]).GetApplicabilityRules().Count == 0);

      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      Assert.IsTrue(pcTemplate != null);
      Assert.IsTrue(pcTemplate.Name == "Song Downloads Copy");

      adjTemplates = pcTemplate.GetAdjustments();
      Assert.IsTrue(adjTemplates != null);
      
      Assert.IsTrue(adjTemplates.Count == 3);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).Name == "ConnectionFeePercentAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[3]).Name == "Song Downloads Adjustment Unit Test Name");

      // Check reason codes on the template
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[3]).GetApplicableReasonCodes().Count == 1);

      // Add two more reason codes to the template we created.
      ((AdjustmentTemplate)piType.Template.AdjustmentTemplates[2]).ReasonCodes.Add(ac.GetReasonCodeByName("Rebill"));
      ((AdjustmentTemplate)piType.Template.AdjustmentTemplates[2]).ReasonCodes.Add(ac.GetReasonCodeByName("Bankruptcy"));
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      adjTemplates = pcTemplate.GetAdjustments();
      Assert.IsTrue(adjTemplates != null);     
      Assert.IsTrue(adjTemplates.Count == 3);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[3]).GetApplicableReasonCodes().Count == 3);

      // Remove the first reason code on the template we created
      ((AdjustmentTemplate)piType.Template.AdjustmentTemplates[2]).ReasonCodes.RemoveAt(0);
      Assert.IsTrue(((AdjustmentTemplate)piType.Template.AdjustmentTemplates[2]).ReasonCodes.Count == 2);
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      adjTemplates = pcTemplate.GetAdjustments();
      Assert.IsTrue(adjTemplates != null);     
      Assert.IsTrue(adjTemplates.Count == 3);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).GetApplicableReasonCodes().Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[3]).GetApplicableReasonCodes().Count == 2);

      // Get rid of the adjustment type and template and update
      // Remember, the AdjustmentTypes are an MTCollection (1-based)
      // and the AdjustmentTemplates are an ArrayList (0-based).
      piType.AdjustmentTypes.Remove(3);
      piType.Template.AdjustmentTemplates.RemoveAt(2);
      // Remove the applicability rule from the first adjustment type.
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 1);
      ((MetraTech.Adjustments.AdjustmentType)piType.AdjustmentTypes[1]).GetApplicabilityRules().Remove(1);
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);

      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).Name == "ConnectionFeePercentAdjustmentCopy");
      // Check that the applicability rule was removed properly
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[1]).GetApplicabilityRules().Count == 0);
      Assert.IsTrue(((MetraTech.Adjustments.AdjustmentType)pcPiType.AdjustmentTypes[2]).GetApplicabilityRules().Count == 0);

      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      Assert.IsTrue(pcTemplate != null);
      Assert.IsTrue(pcTemplate.Name == "Song Downloads Copy");

      adjTemplates = pcTemplate.GetAdjustments();
      Assert.IsTrue(adjTemplates != null);
      
      Assert.IsTrue(adjTemplates.Count == 2);
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[1]).Name == "ConnectionFeeFlatAdjustmentCopy");
      Assert.IsTrue(((MetraTech.Adjustments.Adjustment)adjTemplates[2]).Name == "ConnectionFeePercentAdjustmentCopy");

      // Add a new counter property definition and its associated counter.
      CounterPropertyDefinition cpd = new CounterPropertyDefinition();
      cpd.Name = "NewCPD";
      cpd.DisplayName = "New CPD";
      cpd.ServiceProperty = "TotalSongs2";
      cpd.PreferredCounterTypeName = "SumOfOneProperty";
      piType.CounterPropertyDefinitions.Add(cpd);
      
      cpd.ConfiguredCounter = new Counter();
      cpd.ConfiguredCounter.Name = cpd.Name;
      cpd.ConfiguredCounter.CounterType = "SumOfOneProperty";
      cpd.ConfiguredCounter.Description = "This counter is only a test";
      cpd.ConfiguredCounter.AddCounterParameter("A", "metratech.com/songdownloads_temp/songs");

      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);

      // Read back and verify
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      cpds = pcPiType.GetCounterPropertyDefinitions();
      Assert.IsTrue(cpds.Count == 3);
      pcCpd = (IMTCounterPropertyDefinition)cpds[1];
      pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "TotalSongs");
      Assert.IsTrue(pcCpd.DisplayName == "Total songs downloaded");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "TotalSongs");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfOneProperty");
      pcCpd = (IMTCounterPropertyDefinition)cpds[2];
      pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "TotalBytes");
      Assert.IsTrue(pcCpd.DisplayName == "Total bytes downloaded");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "TotalBytes");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfTwoProperties");
      pcCpd = (IMTCounterPropertyDefinition)cpds[3];
      pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "NewCPD");
      Assert.IsTrue(pcCpd.DisplayName == "New CPD");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "NewCPD");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfOneProperty");

      // Delete two of the three CPD/counters
      piType.CounterPropertyDefinitions.RemoveAt(2);
      piType.CounterPropertyDefinitions.RemoveAt(1);
      Assert.IsTrue(piType.CounterPropertyDefinitions.Count == 1);
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      // Read back and verify
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      pcTemplate = (IMTAggregateCharge) pcPiType.GetTemplates()[1];     
      cpds = pcPiType.GetCounterPropertyDefinitions();
      Assert.IsTrue(cpds.Count == 1);
      pcCpd = (IMTCounterPropertyDefinition)cpds[1];
      pcCounter = pcTemplate.GetCounter(pcCpd.ID);
      Assert.IsTrue(pcCpd.Name == "TotalSongs");
      Assert.IsTrue(pcCpd.DisplayName == "Total songs downloaded");
      Assert.IsTrue(pcCounter != null);
      Assert.IsTrue(pcCounter.Name == "TotalSongs");
      Assert.IsTrue(pcCounter.Type.Name == "SumOfOneProperty");

      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);

      // Verify that it is gone.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType == null);
    }

    [Test] public void TestUpdateSongDownloadsFromFile()
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "SongDownloadsCopy.xml");   

      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      IMTPriceableItemType pcPiType =
      pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }

      PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);

      // Open the type back up and validate that thing are as they should be....
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "Song Downloads Copy");
      Assert.IsTrue(pcPiType.Description == "Sample aggregate charge");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 2);
      Assert.IsTrue(pcPiType.GetCharges().Count == 1);
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).Name == "ConnectionFee");
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).DisplayName == "Connection Fee Charge");
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).GetChargeProperties().Count == 0);

      // Load up the copy
      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "SongDownloadsCopy2.xml");    

      // Save the piType copy
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);

      // Open the type back up and validate that things are as they should be....
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "Song Downloads Copy");
      Assert.IsTrue(pcPiType.Description == "Sample aggregate charge");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 2);
      Assert.IsTrue(pcPiType.GetCharges().Count == 1);
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).Name == "ConnectionFee");
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).DisplayName == "Connection Fee Charge");
      Assert.IsTrue(((IMTCharge)pcPiType.GetCharges()[1]).GetChargeProperties().Count == 1);

      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);     
    }

    [Test] public void TestTestPICreateAndUpdate()
    {
      // Test a non aggregate usage charge.
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "TestService.xml");   

      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      IMTPriceableItemType pcPiType =
      pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }

      PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "TestServiceWithAdjustment.xml");   

      // Save the piType copy
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);     
      // TODO: Test a compound pitype
    }

    [Test] public void TestAudioConfUpgrade()
    {
      IMTProductCatalog pc = 
      (IMTProductCatalog) new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

      XmlSerializer xml = new XmlSerializer(pc);
      PriceableItemType piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfCall.3.0.xml");   

      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      IMTPriceableItemType pcPiType =
      pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        // Remove all templates
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }
      PriceableItemTypeWriter writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfCall.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 0);
      Assert.IsTrue(pcPiType.GetCharges().Count == 0);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 12);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      IMTPriceableItem pcPiTemplate =
      (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 0);

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfConn.3.0.xml");   
      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }
      writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfConn.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 0);
      Assert.IsTrue(pcPiType.GetCharges().Count == 0);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 8);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcPiTemplate = (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 0);

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfFeature.3.0.xml");    
      // First check if the type exists (maybe from a previous test failure).
      // If so delete it.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      if (pcPiType != null)
      {
        PriceableItemTypeWriter writer2 = new PriceableItemTypeWriter();
        writer2.RemovePriceableItemType(piType);      
      }
      writer = new PriceableItemTypeWriter();
      writer.CreatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfFeature.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 0);
      Assert.IsTrue(pcPiType.GetCharges().Count == 0);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 3);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcPiTemplate = (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 0);

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfCall.3.5.xml");   
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfCall.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
      Assert.IsTrue(pcPiType.GetCharges().Count == 4);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 12);
      pcPiTemplate = (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 3);
      // Save the call and delete after the conn and feature are processed
      PriceableItemType callType = piType;

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfConn.3.5.xml");   
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfConn.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
      Assert.IsTrue(pcPiType.GetCharges().Count == 2);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 8);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcPiTemplate = (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 3);
      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);     

      xml = new XmlSerializer(pc);
      piType = xml.LoadPriceableItemTypeFromXML(mPath + "AudioConfFeature.3.5.xml");    
      writer = new PriceableItemTypeWriter();
      writer.UpdatePriceableItemType(piType);
      // Load 'em up and check 'em out.
      pcPiType = pc.GetPriceableItemTypeByName(piType.Name);
      Assert.IsTrue(pcPiType != null);
      Assert.IsTrue(pcPiType.Name == "AudioConfFeature.3.0");
      Assert.IsTrue(pcPiType.GetCounterPropertyDefinitions().Count == 0);
      Assert.IsTrue(pcPiType.AdjustmentTypes.Count == 3);
      Assert.IsTrue(pcPiType.GetCharges().Count == 3);
      Assert.IsTrue(pcPiType.GetParamTableDefinitions().Count == 3);
      Assert.IsTrue(pcPiType.GetTemplates().Count == 1);
      pcPiTemplate = (IMTPriceableItem) pcPiType.GetTemplates()[1];
      Assert.IsTrue(pcPiTemplate.GetAdjustments().Count == 3);
      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(piType);     

      // Clean up after ourselves and delete the piType completely
      writer = new PriceableItemTypeWriter();
      writer.RemovePriceableItemType(callType);     
    }
  }
}
