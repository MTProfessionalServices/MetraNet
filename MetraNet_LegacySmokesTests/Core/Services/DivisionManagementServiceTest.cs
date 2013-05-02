using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using Core.Core;
using MetraTech.ActivityServices.Common;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.DivisionManagementServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//

namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    class DivisionManagementServiceTest
    {
        [Test]
        public void AddDivision()
        {
            DivisionManagementServiceClient client = new DivisionManagementServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            Division div = new Division();
            div.Currency = DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.GBP;
            div.DivisionBusinessKey.Name = Guid.NewGuid().ToString("B");

            client.CreateDivision(ref div);            
        }

        [Test]
        public void GetDivisions()
        {
            DivisionManagementServiceClient client = new DivisionManagementServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            Division div = new Division();
            div.Currency = DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.GBP;
            div.DivisionBusinessKey.Name = Guid.NewGuid().ToString("B");

            client.CreateDivision(ref div);

            MTList<Division> divisions = new MTList<Division>();
            divisions.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, div.DivisionBusinessKey.Name));

            client.GetDivisions(ref divisions);

            Assert.AreEqual(1, divisions.Items.Count);
        }
    }
}
