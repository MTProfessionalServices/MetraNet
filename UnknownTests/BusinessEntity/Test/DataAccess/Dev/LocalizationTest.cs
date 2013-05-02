using System;
using System.Collections.Generic;

using Core.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;

using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.LocalizationTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class LocalizationTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
     
    }

    [Test]
    [Category("GetLocalizedLabelForEntity")]
    public void GetLocalizedLabelForEntity()
    {
      MetadataRepository.Instance.InitializeFromFileSystem();
      MetadataRepository.Instance.InitLocalizationData();
      
    }

    #region Data

    // private static readonly ILog logger = LogManager.GetLogger("LocalizationTest");

    #endregion
  }
}
