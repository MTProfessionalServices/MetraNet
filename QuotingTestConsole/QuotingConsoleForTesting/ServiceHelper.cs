using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.ServiceModel.Security;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;

namespace QuotingConsoleForTesting
{
  /// <summary>
  /// Class for service calls
  /// </summary>
  public class ServiceHelper
  {
    public static List<Account> GetAccounts(string gateway)
    {
      AccountServiceClient acs = null;
      var accounts = new MTList<Account>();
      try
      {
        acs = new AccountServiceClient(GetBinding("WSHttpBinding_IAccountService"), GetEndpoint(gateway, "AccountService"));
        SetCredantional(acs.ClientCredentials);
        acs.GetAccountList(DateTime.Now, ref accounts, false);
      }
      finally
      {
        if (acs != null)
        {
          if (acs.State == CommunicationState.Opened)
          {
            acs.Close();
          }
          else
          {
            acs.Abort();
          }
        }
      }

      return accounts.Items; //[TODO]: Return accounts of MT extensino only. (not System User or Auth)
    }
    
    public static List<ProductOffering> GetProductOfferings(string gateway)
    {
      ProductOfferingServiceClient poClient = null;
      var pos = new MTList<ProductOffering>();

      try
      {
        poClient = new ProductOfferingServiceClient(GetBinding("WSHttpBinding_IProductOfferingService"), GetEndpoint(gateway, "ProductOfferingService"));
        SetCredantional(poClient.ClientCredentials);
        poClient.GetProductOfferings(ref pos);
      }
      finally
      {
        if (poClient != null)
        {
          if (poClient.State == CommunicationState.Opened)
          {
            poClient.Close();
          }
          else
          {
            poClient.Abort();
          }
        }
      }

      return pos.Items;
    }
    
    public static List<BasePriceableItemInstance> GetPriceListsWithUdrcs(string gateway, int poId)
    {
      var resultPiList = new List<BasePriceableItemInstance>();

      var client = new ProductOfferingServiceClient(GetBinding("WSHttpBinding_IProductOfferingService"), GetEndpoint(gateway, "ProductOfferingService"));
      SetCredantional(client.ClientCredentials);

      var priceableItems = new MTList<BasePriceableItemInstance>();
      client.GetPIInstancesForPO(new PCIdentifier(poId), ref priceableItems);
      var udrcPiList = priceableItems.Items.Where(pi => pi.PIKind == PriceableItemKinds.UnitDependentRecurring);
      resultPiList.AddRange(udrcPiList);

      return resultPiList;
    }

    public static List<BasePriceableItemInstance> GetPIWithAllowICBs(string gateway, List<int> poIds)
    {
      var resultPiList = new List<BasePriceableItemInstance>();

      var client = new ProductOfferingServiceClient(GetBinding("WSHttpBinding_IProductOfferingService"), GetEndpoint(gateway, "ProductOfferingService"));
      SetCredantional(client.ClientCredentials);

      foreach (var poId in poIds)
      {
        var priceableItems = new MTList<BasePriceableItemInstance>();
        client.GetPIInstancesForPO(new PCIdentifier(poId), ref priceableItems);

        //var udrcPiList = priceableItems.Items.Where(pi => pi.PIKind == PriceableItemKinds.UnitDependentRecurring);
        //todo filter only PIs with allow ICBs
        resultPiList.AddRange(priceableItems.Items);
      }

      return resultPiList;
    }

    #region Prepare Client for Services

    private static WSHttpBinding GetBinding(string bindingName)
    {
      var binding = new WSHttpBinding(bindingName)
      {
        Security =
        {
          Mode = SecurityMode.Message,
          Message = { ClientCredentialType = MessageCredentialType.UserName, NegotiateServiceCredential = true, EstablishSecurityContext = true, AlgorithmSuite = SecurityAlgorithmSuite.Default}
        },
        BypassProxyOnLocal = false,
        TransactionFlow = false,
        HostNameComparisonMode = HostNameComparisonMode.StrongWildcard,
        MessageEncoding = WSMessageEncoding.Text,
        TextEncoding = Encoding.UTF8,
        UseDefaultWebProxy = true,
        AllowCookies = false,
        OpenTimeout = new TimeSpan(0, 3, 0),
        CloseTimeout = new TimeSpan(0, 3, 0),
        SendTimeout = new TimeSpan(0, 3, 0),
        ReceiveTimeout = new TimeSpan(0, 10, 0),
        MaxReceivedMessageSize = int.MaxValue
      };
      return binding;
    }

    private static EndpointAddress GetEndpoint(string gateway, string serviceName)
    {
      var uri = new Uri(String.Format(CultureInfo.InvariantCulture,
                                      @"http://{0}/{1}",
                                      gateway,
                                      serviceName));
      var identity = new DnsEndpointIdentity("ActivityServicesCert");
      var endpoint = new EndpointAddress(uri, identity);
      return endpoint;
    }

    private static void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
    {
      if (clientCredentials == null)
        throw new InvalidOperationException("Client credentials is null");

      clientCredentials.UserName.UserName = "su";
      clientCredentials.UserName.Password = "su123";
    }

    #endregion
  }
}
