using System;
using System.Collections.Generic;
using System.ServiceModel;

using NUnit.Framework;
using log4net;

using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.Test.CoreService
{
  public class DataAccessServiceTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // log4net
      // Log4NetConfig.Configure();

      // Create the schema
      metadataAccess = new MetadataAccess();
      metadataAccess.CreateSchema(SystemConfig.DefaultTenant);
      logger.Debug(String.Format("Successfully created schema for tenant '{0}'", SystemConfig.DefaultTenant));
    }

    // [Test]
    [Ignore]
    public void CanSave()
    {
      // Create an order
      DataObject orderDataObject =
        new Order()
          {
            Description = "First Description",
            ReferenceNumber = "123",
            PlacementDate = DateTime.Now
          };

      ((Order)orderDataObject).OrderItems = new List<OrderItem>() { new OrderItem() { Description = "Desc1", Order = (Order)orderDataObject } };

      Using<DataAccessServiceClient>(client => { client.Save(ref orderDataObject); });

      ((Order)orderDataObject).Description = "Second Description";

      Using<DataAccessServiceClient>(client => { client.Save(ref orderDataObject); });

      logger.Debug(String.Format("Saved Order from tenant '{0}'", SystemConfig.DefaultTenant));
    }

    /// <summary>
    /// WCF proxys do not clean up properly if they throw an exception. This method ensures that the service proxy is handled correctly.
    /// Do not call TService.Close() or TService.Abort() within the action lambda.
    /// </summary>
    /// <typeparam name="TService">The type of the service to use</typeparam>
    /// <param name="action">Lambda of the action to performwith the service</param>
     
    public static void Using<TService>(Action<TService> action)
        where TService : ICommunicationObject, IDisposable, new()
    {
        var service = new TService();
        bool success = false;
        try
        {
            action(service);
            if (service.State != CommunicationState.Faulted)
            {
                service.Close();
                success = true;
            }
        }
        finally
        {
            if (!success)
            {
                service.Abort();
            }
        }
    }

    #region Data
    private readonly ILog logger = LogManager.GetLogger("DataAccessServiceTest");
    private MetadataAccess metadataAccess;
    #endregion
  }
}
