using System;
using System.Runtime.InteropServices;
using System.EnterpriseServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using MetraTech.Test;
using MetraTech.Test.Common;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using Account = MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

[assembly: GuidAttribute ("5c04331c-59d7-45dd-9cfa-a073bab8df9b")]

namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

	
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.ImportExportTests /assembly:O:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ImportExportTests 
	{

		private PC.MTProductCatalog mPC;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
		private string mFileName;
		private int offset;
	
		public ImportExportTests()
		{
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();
			mFileName = string.Format(@"t:\development\core\MTProductCatalog\ScratchBoard\{0}.xml", Utils.GeneratePOName());
			offset = 0;
		}

		/// <summary>
		/// Tests operations on constrained product offerings
		/// </summary>
		/// 
		[Test]
		public void T01_CreateProductOffering()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.CreateProductOffering();
			po.Name = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			po.DisplayName = po.Name;
			po.Description = po.Name;
			po.SelfSubscribable = true;
			po.SelfUnsubscribable = false;
			po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
			po.EffectiveDate.StartDate = MetraTime.Now;
			po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
			po.EffectiveDate.SetEndDateNull();
			//Find Usage Charge
			PC.MTPriceableItem usage = mPC.GetPriceableItemByName("Test Usage Charge");
			int piinstanceid = po.AddPriceableItem(usage).ID;
			/*
			PC.IMTPriceList pl = mPC.CreatePriceList();
			pl.Name = Utils.GeneratePriceListName();
			pl.Description = Utils.GeneratePriceListName();
			pl.CurrencyCode = "USD";
			pl.Shareable = true;
			pl.Save();
			int idPL = pl.ID;

			PC.IMTPriceableItem piinstance = mPC.GetPriceableItem(piinstanceid);

			foreach(PC.IMTParamTableDefinition ptd in piinstance.PriceableItemType.GetParamTableDefinitions())
			{
				piinstance.SetPriceListMapping(ptd.ID, idPL);

			}

			po.AvailabilityDate.StartDate = MetraTime.Now;
			po.AvailabilityDate.SetEndDateNull();
			*/
			po.SetCurrencyCode("USD");

			

			po.Save();
		}

		[Test]
		public void T02_TestExportWideOpenPO()
		{
			//Create product offering
			PCExportWrapper ex = new PCExportWrapper();
			string poname = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(poname);
			ex.ExportProductOffering(mFileName, poname);
		}

		[Test]
		public void T03_TestRemoveProductOffering()
		{
			string poname = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(poname);
			mPC.RemoveProductOffering(po.ID);
		}

		[Test]
		public void T04_TestImportAndCheckWideOpenPO()
		{

      //IPCImportCOMPlusWrapper wrapper = new PCImportCOMPlusWrapper();
      //wrapper.ImportAndCheckWideOpenProductOffering(mFileName, offset);
      ImportAndCheckWideOpenProductOffering(mFileName, offset);
		}

		[Test]
    public void T05_CreateProductOffering1()
		{
			offset++;

			//Create product offering
			PC.IMTProductOffering po = mPC.CreateProductOffering();
			po.Name = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			po.DisplayName = po.Name;
			po.Description = po.Name;
			po.SelfSubscribable = true;
			po.SelfUnsubscribable = false;
			po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
			po.EffectiveDate.StartDate = MetraTime.Now;
			po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
			po.EffectiveDate.SetEndDateNull();
			//Find Usage Charge
			PC.MTPriceableItem usage = mPC.GetPriceableItemByName("Test Usage Charge");
			int piinstanceid = po.AddPriceableItem(usage).ID;
			/*
			PC.IMTPriceList pl = mPC.CreatePriceList();
			pl.Name = Utils.GeneratePriceListName();
			pl.Description = Utils.GeneratePriceListName();
			pl.CurrencyCode = "USD";
			pl.Shareable = true;
			pl.Save();
			int idPL = pl.ID;

			PC.IMTPriceableItem piinstance = mPC.GetPriceableItem(piinstanceid);

			foreach(PC.IMTParamTableDefinition ptd in piinstance.PriceableItemType.GetParamTableDefinitions())
			{
				piinstance.SetPriceListMapping(ptd.ID, idPL);

			}

			po.AvailabilityDate.StartDate = MetraTime.Now;
			po.AvailabilityDate.SetEndDateNull();
			*/
			po.SetCurrencyCode("USD");

			

			po.Save();
		}
		
		
		[Test]
    public void T06_TestAddConstraintToPO()
		{
			string poname = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(poname);
			po.SubscribableAccountTypes.Add("CoreSubscriber");
			po.Save();
		}

		[Test]
    public void T07_TestExportPOWithConstrains()
		{

			//Create product offering
			PCExportWrapper ex = new PCExportWrapper();
			string poname = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(poname);
			//string newname = string.Format("{0}_ImportExportUnitTest", Utils.GeneratePOName());
			ex.ExportProductOffering(mFileName, poname);
		}

		[Test]
    public void T08_TestRemoveProductOffering1()
		{
			string poname = string.Format("{0}_{1}", Utils.GeneratePOName(), offset);
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(poname);
			mPC.RemoveProductOffering(po.ID);
		}


		[Test]
    public void T09_TestImportAndCheckPOWithConstrains()
		{

      //IPCImportCOMPlusWrapper wrapper = new PCImportCOMPlusWrapper();
      //wrapper.ImportAndCheckProductOffering(mFileName, offset);
      ImportAndCheckProductOffering(mFileName, offset);
		}

    /// <summary>
    ///    Testing CR 13677. The data for the test was on GATSBY.
    ///    pcimportexport -egs 
    ///                   -file "C:\groups.xml" 
    ///                   -corp "WorldTeleport_USD" 
    ///                   -corpNameSpace mt 
    ///                   -groupsubscription "*" 
    ///                   -username su 
    ///                   -password su123
    /// </summary>
    [Test]
    [Category("GroupSubscription")]
    [Ignore("")]
    public void T10_TestExportGroupSubscriptions()
    {
      PCExportWrapper pcExportWrapper = new PCExportWrapper();
      // The data is dependent on GATSBY
      string fileName = @"C:\groups.xml";
      pcExportWrapper.ExportGroupSubscription(fileName,
                                              "InterMED", // "WorldTeleport_USD",
                                              "mt",
                                              "su",
                                              "su123");
      
    }

    public void ImportAndCheckProductOffering(string filename, int offset)
    {
      //Create product offering
      PCImportWrapper ex = new PCImportWrapper();
      string newname = Utils.GeneratePOName(); //string.Format("{0}_ImportExportUnitTest", Utils.GeneratePOName());
      ex.ImportProductOffering(filename, Utils.GeneratePOName());
      //make sure it's there now and
      //make sure that account type restrictions were correctly imported
      PC.MTProductCatalog pc = new PC.MTProductCatalogClass();
      PC.IMTProductOffering po = pc.GetProductOfferingByName(string.Format("{0}_{1}", Utils.GeneratePOName(), offset));
      PC.IMTCollection sat = po.SubscribableAccountTypes;

      Assert.AreEqual(1, sat.Count, "SubscribableAccountTypes were not imported correctly");
      foreach (string str in sat)
      {
        Assert.AreEqual("CoreSubscriber", str);
      }
    }

    public void ImportAndCheckWideOpenProductOffering(string filename, int offset)
    {
      //Create product offering
      PCImportWrapper ex = new PCImportWrapper();
      string newname = Utils.GeneratePOName(); //string.Format("{0}_ImportExportUnitTest", Utils.GeneratePOName());
      ex.ImportProductOffering(filename, Utils.GeneratePOName());
      //make sure it's there now and
      //make sure that account type restrictions were correctly imported
      PC.MTProductCatalog pc = new PC.MTProductCatalogClass();
      PC.IMTProductOffering po = pc.GetProductOfferingByName(string.Format("{0}_{1}", Utils.GeneratePOName(), offset));
      PC.IMTCollection sat = po.SubscribableAccountTypes;
      Assert.AreEqual(0, sat.Count, "SubscribableAccountTypes were not imported correctly");
    }
  }
	
	[Guid("306c077b-82c3-4ef5-b4f1-3744c07ea49c")]
	public interface IPCImportCOMPlusWrapper
	{
		void ImportAndCheckProductOffering(string name, int offset);
		void ImportAndCheckWideOpenProductOffering(string name, int offset);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
	[Guid("303625b7-18b9-42ba-82fc-61338034ba36")]
	public class PCImportCOMPlusWrapper : ServicedComponent,  IPCImportCOMPlusWrapper
	{
		public PCImportCOMPlusWrapper(){}

		[AutoComplete]
		public void ImportAndCheckProductOffering(string filename, int offset)
		{
			//Create product offering
			PCImportWrapper ex = new PCImportWrapper();
			string newname = Utils.GeneratePOName(); //string.Format("{0}_ImportExportUnitTest", Utils.GeneratePOName());
			ex.ImportProductOffering(filename, Utils.GeneratePOName());
			//make sure it's there now and
			//make sure that account type restrictions were correctly imported
			PC.MTProductCatalog pc = new PC.MTProductCatalogClass();
			PC.IMTProductOffering po = pc.GetProductOfferingByName(string.Format("{0}_{1}", Utils.GeneratePOName(), offset));
			PC.IMTCollection sat = po.SubscribableAccountTypes;
			
			Assert.AreEqual(1, sat.Count, "SubscribableAccountTypes were not imported correctly");
			foreach(string str in sat)
			{
				Assert.AreEqual("CoreSubscriber", str);
			}
		}

		[AutoComplete]
		public void ImportAndCheckWideOpenProductOffering(string filename, int offset)
		{
			//Create product offering
			PCImportWrapper ex = new PCImportWrapper();
			string newname = Utils.GeneratePOName(); //string.Format("{0}_ImportExportUnitTest", Utils.GeneratePOName());
			ex.ImportProductOffering(filename, Utils.GeneratePOName());
			//make sure it's there now and
			//make sure that account type restrictions were correctly imported
			PC.MTProductCatalog pc = new PC.MTProductCatalogClass();
			PC.IMTProductOffering po = pc.GetProductOfferingByName(string.Format("{0}_{1}", Utils.GeneratePOName(), offset));
			PC.IMTCollection sat = po.SubscribableAccountTypes;
			Assert.AreEqual(0, sat.Count, "SubscribableAccountTypes were not imported correctly");
		}
	}
  

}

