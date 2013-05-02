using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using SmokeTest.OrderManagement;
using log4net;
using log4net.Core;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Rule;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.GraphTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class GraphTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      #region Uncomment Later
      /*
      //                           L1G1 (L1G1_E1)
      //                      /                     \
      //                     /                       \ 
      //              L2G1(L2G1_E1)       L2G2 (L2G2_E1, L2G2_E2)
      //                     \                       /
      //                      \                     /
      //                           L3G1 (L3G1_E1)
      
      // Create the Entity group directories (EGXX) shown above in extension "GraphTest".

      SystemConfig.CreateBusinessEntityDirectories(extensionName, "EG11");
      SystemConfig.CreateBusinessEntityDirectories(extensionName, "EG21");
      SystemConfig.CreateBusinessEntityDirectories(extensionName, "EG22");
      SystemConfig.CreateBusinessEntityDirectories(extensionName, "EG31");

      // Clean BE directories.
      SystemConfig.CleanEntityDir(extensionName, "EG11");
      SystemConfig.CleanEntityDir(extensionName, "EG21");
      SystemConfig.CleanEntityDir(extensionName, "EG22");
      SystemConfig.CleanEntityDir(extensionName, "EG31");

      // Create Entities
      var e11_1 = new Entity("GraphTest.EG11.E11_1");
      var e21_1 = new Entity("GraphTest.EG21.E21_1");
      var e22_1 = new Entity("GraphTest.EG22.E22_1");
      var e31_1 = new Entity("GraphTest.EG31.E31_1");

      // Create relationships
      MetadataAccess.Instance.CreateOneToManyRelationship(ref e21_1, ref e11_1);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref e22_1, ref e11_1);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref e31_1, ref e21_1);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref e31_1, ref e22_1);

      // Save
      MetadataAccess.Instance.SaveEntities(new List<Entity>() {e11_1, e21_1, e22_1, e31_1});
       */
      #endregion

      /*
      string entityGroupName = "Common";
      SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);
      SystemConfig.CleanEntityDir(extensionName, entityGroupName);

      var A = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "A")) { PluralName = "As" };
      var B = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "B")) { PluralName = "Bs" };
      var C = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "C")) { PluralName = "Cs" };
      var D = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "D")) { PluralName = "Ds" };
      var E = new Entity(Name.GetEntityFullName(extensionName, entityGroupName, "E")) { PluralName = "Es" };

      MetadataAccess.Instance.CreateOneToManyRelationship(ref A, ref B);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref B, ref C);
      MetadataAccess.Instance.CreateOneToManyRelationship(ref A, ref C);

      MetadataAccess.Instance.CreateOneToManyRelationship(ref D, ref E);
      MetadataAccess.Instance.SaveEntities(new List<Entity>() { A, B, C, D, E });
      */
    }

    [Test]
    [Category("RetrieveEdges")]
    public void RetrieveEdges()
    {
      var edges = MetadataRepository.Instance.GetCascadeRelationships("GraphTest.Common.A");
    }




    #region Data

    private static readonly ILog logger = LogManager.GetLogger("GraphTest");

    // private string extensionName = "GraphTest";

    #endregion
  }
}
