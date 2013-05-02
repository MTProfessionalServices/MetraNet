using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.FunctionalTest.DataAccess.Common
{
  [TestClass]
  public class CommonTest
  {
    public CommonTest()
    {
    }

    private TestContext testContextInstance;

    /// <summary>
    ///Gets or sets the test context which provides
    ///information about and functionality for the current test run.
    ///</summary>
    public TestContext TestContext
    {
      get
      {
        return testContextInstance;
      }
      set
      {
        testContextInstance = value;
      }
    }

    [TestMethod]
    public void GetRmpDir()
    {
      string rmpDir = SystemConfig.GetRmpDir();
      Assert.IsNotNull(rmpDir);
      Assert.IsTrue(Directory.Exists(rmpDir));
    }
  }
}
