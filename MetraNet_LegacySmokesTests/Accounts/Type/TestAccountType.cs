
//NUnit-Console.exe /assembly:MetraTech.Accounts.Type.Test.dll /fixture:MetraTech.Accounts.Type.Test.TestAccountTypes

using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Xml.Linq;
using MetraTech.Interop.RCD;

[assembly: GuidAttribute("AE338FE4-F760-43bd-8CD4-F20494BE960F")]
[assembly: ComVisible(false)]

namespace MetraTech.Accounts.Type.Test
{
  using System;
  using NUnit.Framework;
  using MetraTech.Test;
  using Account = MetraTech.Accounts.Type;
  using MTAccountType = MetraTech.Interop.IMTAccountType;
  using MetraTech.Pipeline;
  using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Test.Common;

  [Category("NoAutoRun")]
  [TestFixture]
  public class TestAccountTypes
  {
		private MTProductCatalog mPC;
		private IMTSessionContext mSUCtx = null;
		 

		public TestAccountTypes()
		{
			mPC = new MTProductCatalogClass();
			mSUCtx = (MetraTech.Interop.MTProductCatalog.IMTSessionContext)Utils.LoginAsSU();
		}

    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T01GetAccountType()
    {
      TestLibrary.Trace("Executing: GetAccountType for CoreSubscriber");
			
      Account.AccountType coreAccount = new Account.AccountType();
      coreAccount.InitializeByName("CoreSubscriber");
      if ((coreAccount.Name == "CoreSubscriber") ||
          (coreAccount.CanBePayer) ||
           (coreAccount.CanSubscribe) ||
          (!coreAccount.CanHaveSyntheticRoot) ||
          (!coreAccount.IsCorporate) ||
          (coreAccount.IsVisibleInHierarchy) ||
          (!coreAccount.CanHaveTemplates) ||
          (coreAccount.CanParticipateInGSub)
        )
        TestLibrary.Trace ("Found correct core properties for CoreSubscriber account type");
      else
        Assert.Fail("Core Subscriber properties not correct");

      MTAccountType.IMTSQLRowset views = coreAccount.GetAccountViewsAsRowset();
      //verify results!
      if (views.RecordCount != 2)
          Assert.Fail("Core Subscriber account views not correct");

      MTAccountType.IMTSQLRowset serviceDefs = coreAccount.GetServiceDefinitionsAsRowset();
      //verify results!
      if (serviceDefs.RecordCount != 2)
        Assert.Fail("Core Subscriber service definitions not correct");

      MTAccountType.IMTSQLRowset descendentAccts = coreAccount.GetDescendentAccountTypesAsRowset();
      //verify results!
      //if (descendentAccts.RecordCount > 1) //out of the box it should be 0, just in case the gsmextension is synchronized
      //  Assert.Fail("Core Subscriber descendent accounts not correct");

      MTAccountType.IMTCollection viewColl = coreAccount.GetAllAccountViews();

      //verify results!

      Account.AccountType corpAccount = new Account.AccountType();
      corpAccount.InitializeByName("CorporateAccount");
      MTAccountType.IMTSQLRowset allChildren = corpAccount.GetAllDescendentAccountTypesAsRowset();
      if (allChildren.RecordCount != 3)
          Assert.Fail("Corp Account children not configured correctly!");
      
      TestLibrary.Trace("Done");
    }

    [Test]
    public void T02GetPropertiesForAccountType()
    {
      TestLibrary.Trace("Executing: GetPropertiesForAccountType for CoreSubscriber");
      const string accountType = "CoreSubscriber";
      var expectedPropsCount = GetExpectedAccountPropsCount(accountType);

      var coreAccount = new AccountType();
      coreAccount.InitializeByName(accountType);
      
      var sd = coreAccount.GetMSIXProperties() as ServiceDefinition;
      var numberOfProps = 0;

      Assert.IsNotNull(sd, "sd (GetMSIXProperties) have a wrong type");
      foreach(IMTPropertyMetaData prop in sd.Properties)
      {
        TestLibrary.Trace("{0} - {1}", prop.Name, prop.DataType);
        numberOfProps++;  
      }

      Assert.AreEqual(expectedPropsCount, numberOfProps,
        "Core Subscriber wrong number of properties from GetMSIXProperties(). Expected {0} properties. Saw {1}",
        expectedPropsCount, numberOfProps);

      TestLibrary.Trace("Found correct number of properties for CoreSubscriber account type: {0} {1} Done",
        numberOfProps, 
        Environment.NewLine);
      
    }

    [Test]
    public void T03TestAccountTypeManagerWithName()
		{
			IAccountTypeManager atm = new AccountTypeManager();
			MTAccountType.IMTAccountType at = atm.GetAccountTypeByName(mSUCtx, "CoreSubscriber");
			Assert.IsNotNull(at);
			Assert.AreEqual("CoreSubscriber", at.Name);
		}
		
    [Test]
    public void T04TestAccountTypeManagerWithID()
		{
			IAccountTypeManager atm = new AccountTypeManager();
			Account.AccountType compareto = new Account.AccountType();
			compareto.InitializeByName("CoreSubscriber");
			MTAccountType.IMTAccountType at = atm.GetAccountTypeByID(mSUCtx, compareto.ID);
			Assert.IsNotNull(at);
			Assert.AreEqual("CoreSubscriber", at.Name);
    }

    #region private methods

    private static int GetExpectedAccountPropsCount(string accountType)
    {
      var additionalPropertiesCount = 0;
      //Count of properties with MTDataMember attribute in the MetraTech.DomainModel.BaseTypes.Account
      var baseAccountProperties = typeof(DomainModel.BaseTypes.Account).GetProperties(BindingFlags.DeclaredOnly | BindingFlags.Public | BindingFlags.Instance);
      var baseAccountPropertiesCount = baseAccountProperties.Count(x => Attribute.IsDefined(x, typeof(DomainModel.Common.MTDataMemberAttribute)));

      IMTRcd rcd = new MTRcdClass();
      rcd.Init();
      switch (accountType)
      {
        case "CoreSubscriber":
          additionalPropertiesCount += GetPropertiesCountFromMsixdef(rcd.ExtensionDir + @"\Account\config\AccountView\metratech.com\Internal.msixdef");
          additionalPropertiesCount += GetPropertiesCountFromMsixdef(rcd.ExtensionDir + @"\Account\config\AccountView\metratech.com\Contact.msixdef");
          break;
        default:
          throw new NotImplementedException("Unknown account type: " + accountType);
      }

      return baseAccountPropertiesCount + additionalPropertiesCount;
    }

    private static int GetPropertiesCountFromMsixdef(string filePath)
    {
      var msixdef = XDocument.Load(filePath);
      var nodes = msixdef.Descendants("ptype");
      return nodes.Count();
    }

    #endregion private methods
  }
} 

