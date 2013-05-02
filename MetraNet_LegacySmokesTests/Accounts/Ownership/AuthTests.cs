namespace MetraTech.Accounts.Ownership.Test
{
  using System;
  using System.Runtime.InteropServices;
  using System.Collections;

  using NUnit.Framework;
  using YAAC = MetraTech.Interop.MTYAAC;
  using MetraTech.Interop.MTAuth;
  using ServerAccess = MetraTech.Interop.MTServerAccess;
  using MetraTech.Interop.MTEnumConfig;
  using MetraTech.Localization;
  using MetraTech.Test;


  //
  // To run the this test fixture:
  // nunit-console /fixture:MetraTech.Accounts.Ownership.Tests /assembly:O:\debug\bin\MetraTech.Accounts.Ownership.Test.dll
  //
  [Category("NoAutoRun")]
  [TestFixture]
  [ComVisible(false)]
  public class AuthTests 
  {
    const string mTestDir = "t:\\Development\\Core\\AccountHierarchies\\";
    private IEnumConfig mEnumConfig = new EnumConfigClass();

    /// <summary>
    /// Tests Manage Owned Accounts capability
    /// </summary>
    [Test]
    public void T01TestManageOwnedAccountsCapability()
    {
      Utils.Trace("starting TestManageOwnedAccountsCapability");
      IMTSessionContext ctx = Utils.LoginAsSU();
      IMTSecurity sec = new MTSecurityClass();
      YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
      cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
      YAAC.IMTYAAC scott1 = cat.GetAccountByName("scottsales" + Utils.GetTestId(), "system_user", MetraTime.Now);
      YAAC.IMTYAAC doug1 = cat.GetAccountByName("dougsales" + Utils.GetTestId(), "system_user", MetraTime.Now);
      YAAC.IMTYAAC bagha1 = cat.GetAccountByName("DharminderSales" + Utils.GetTestId(), "system_user", MetraTime.Now);
      YAAC.IMTYAAC vlad1 = cat.GetAccountByName("VladSales" + Utils.GetTestId(), "system_user", MetraTime.Now);

      IMTYAAC scott = sec.GetAccountByID((MTSessionContext)ctx, scott1.AccountID, MetraTime.Now);
      IMTYAAC doug = sec.GetAccountByID((MTSessionContext)ctx, doug1.AccountID, MetraTime.Now);
      IMTYAAC bagha = sec.GetAccountByID((MTSessionContext)ctx, bagha1.AccountID, MetraTime.Now);
      IMTYAAC vlad = sec.GetAccountByID((MTSessionContext)ctx, vlad1.AccountID, MetraTime.Now);


      IMTCompositeCapability scott_moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      scott_moa.GetAtomicEnumCapability().SetParameter("WRITE");
      scott_moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      IMTCompositeCapability bagha_moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      bagha_moa.GetAtomicEnumCapability().SetParameter("WRITE");
      bagha_moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      IMTCompositeCapability doug_moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      doug_moa.GetAtomicEnumCapability().SetParameter("WRITE");
      doug_moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      IMTCompositeCapability vlad_moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      vlad_moa.GetAtomicEnumCapability().SetParameter("WRITE");
      vlad_moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.RECURSIVE);
      
      
      //only give Scott, Doug and Bagha capability to view their directly owned accounts
      scott.GetActivePolicy((MTSessionContext)ctx).AddCapability(scott_moa);
      scott.GetActivePolicy((MTSessionContext)ctx).Save();
      doug.GetActivePolicy((MTSessionContext)ctx).AddCapability(doug_moa);
      doug.GetActivePolicy((MTSessionContext)ctx).Save();
      bagha.GetActivePolicy((MTSessionContext)ctx).AddCapability(bagha_moa);
      bagha.GetActivePolicy((MTSessionContext)ctx).Save();
      

      //Give Vlad capability to manage owned accounts for him and all of his descendents
      vlad.GetActivePolicy((MTSessionContext)ctx).AddCapability(vlad_moa);
      vlad.GetActivePolicy((MTSessionContext)ctx).Save();
 
      //login as Scott
      IMTSessionContext scott_ctx = Utils.Login("kevinsales", "system_user", "123");
      IMTYAAC acc = Utils.GetAccountAsResource("Marketing", "mt", scott_ctx);

    }

    [Test]
    public void T01TestImplyMAH()
    {
      /*
      IMTSecurity sec = new MTSecurityClass();
      IMTCompositeCapability mah = sec.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
      mah.GetAtomicEnumCapability().SetParameter("WRITE");
      mah.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      IMTCompositeCapability moa = sec.GetCapabilityTypeByName("Manage Owned Accounts").CreateInstance();
      moa.GetAtomicEnumCapability().SetParameter("WRITE");
      moa.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      IMTCompositeCapability msfh = sec.GetCapabilityTypeByName("Manage Sales Force Hierarchies").CreateInstance();
      msfh.GetAtomicEnumCapability().SetParameter("WRITE");
      msfh.GetAtomicPathCapability().SetParameter("/", MTHierarchyPathWildCard.SINGLE);

      bool msfh_implies_coarse = msfh.Implies(mah, false);
      Assertion.AssertEquals(true, msfh_implies_coarse);

      bool msfh_implies_param = msfh.Implies(mah, true);
      Assertion.AssertEquals(false, msfh_implies_param);
      
      bool moa_implies_coarse = moa.Implies(mah, false);
      Assertion.AssertEquals(false, moa_implies_coarse);

      bool moa_implies_param = moa.Implies(mah, true);
      Assertion.AssertEquals(true, moa_implies_param);
      */
      
    }


  }
}
