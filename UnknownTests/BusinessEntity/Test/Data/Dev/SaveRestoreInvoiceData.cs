using System;
using System.Linq;
using System.Collections.Generic;

using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Test.DataAccess;
using Test.BusinessEntity.OrderManagement;

namespace MetraTech.BusinessEntity.Test.Data.Dev
{
  public sealed class SaveRestoreInvoiceData : DataAccessTestCase
  {
    public SaveRestoreInvoiceData()
    {
      TenantName = "Test";
      CleanTenantDir = false;
    }

    public override void CreateData(ICollection<Entity> entities)
    {
      Repository<Invoice> repository = new Repository<Invoice>(TenantName);
      Random random = new Random();
      Invoice invoice = new Invoice { Property1 = "abc" + random.Next(), Property2 = 32 };
      invoice.DemandForPayments.Add(new DemandForPayment { Invoice = invoice, Property1 = "abc" + random.Next(), Property2 = random.Next() });
      invoice.DemandForPayments.Add(new DemandForPayment { Invoice = invoice, Property1 = "pqr" + random.Next(), Property2 = random.Next() });

      repository.DbContext.BeginTransaction();
      repository.SaveOrUpdate(invoice);
      repository.DbContext.CommitTransaction();
    }
  }
}