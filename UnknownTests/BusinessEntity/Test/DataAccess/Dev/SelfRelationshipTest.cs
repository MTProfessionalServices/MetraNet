using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Core.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using NUnit.Framework;
//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.SelfRelationshipTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class SelfRelationshipTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      MetadataAccess = MetadataAccess.Instance;
    }

    [Test]
    public void CreateSelfRelationship()
    {
      //Entity site = MetadataAccess.Instance.GetEntity("Core.UI.Site");
      //site.HasSelfRelationship = true;

      //var syncData = new SyncData();
      //syncData.AddModifiedEntity(site);

      //MetadataAccess.Instance.Synchronize(syncData);

      IStandardRepository repository = RepositoryAccess.Instance.GetRepository();
      var random = new Random();

      var parentSite = new Site();
      parentSite.SiteBusinessKey.SiteName = "Site - " + random.Next();
      parentSite = (Site)repository.SaveInstance(parentSite);

      var childSite = new Site();
      childSite.SiteBusinessKey.SiteName = "Site - " + random.Next();
      childSite = (Site)repository.CreateChild(parentSite.Id, childSite);

      MTList<DataObject> children = 
        repository.LoadChildren(typeof(Site).FullName, parentSite.Id, new MTList<DataObject>());
    }

    private MetadataAccess MetadataAccess { get; set; }
  }
}
