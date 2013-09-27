using System.Diagnostics;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;

namespace QuotingConsoleForTesting
{
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;

  public class ListBoxLoader
  {
    public static List<Account> GetAccounts()
    {
      AccountServiceClient acs = null;
      var accounts = new MTList<Account>();
      try
      {
        acs = new AccountServiceClient();
        acs.ClientCredentials.UserName.UserName = "su";
        acs.ClientCredentials.UserName.Password = "su123";
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

      return accounts.Items; //[TODO]: Where type not System User?
    }

    public static KeyValuePair<int, string> GetAccountListBoxItem(Account account)
    {
      /*
      var tabs = "";
      if (account.UserName.Length < 8)
      {
        tabs = "\t\t\t";
      }
      else if (account.UserName.Length < 16)
      {
        tabs = "\t\t";
      }
      else if (account.UserName.Length < 32)
      {
        tabs = "\t";
      }
      */
      var formattedDisplayString = String.Format("{0} - {1}",
                                                 account.UserName,
                                              // tabs,
                                                 account.AccountType); // [TODO] Display Usage cycle

      Debug.Assert(account._AccountID != null, "Error: AccountID is null.");
      return new KeyValuePair<int, string>(account._AccountID.Value, formattedDisplayString);
    }
    
    public static List<ProductOffering> GetProductOfferings()
    {
      ProductOfferingServiceClient poClient = null;
      var pos = new MTList<ProductOffering>();

      try
      {
        poClient = new ProductOfferingServiceClient();
        poClient.ClientCredentials.UserName.UserName = "su";
        poClient.ClientCredentials.UserName.Password = "su123";
        poClient.GetProductOfferings(ref pos);
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        // [TODO] Exceptions handling
        // pos.Items.Add(new ProductOffering {Name = String.Format("Exception was occured '{0}'", fe.Message)});
        throw;
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

    public static KeyValuePair<int, string> GetProductOfferingListBoxItem(ProductOffering po)
    {
      Debug.Assert(po.ProductOfferingId != null, "Error: ProductOfferingId is null.");
      var formattedDisplayString = String.Format("{0}", po.Name);
      return new KeyValuePair<int, string>(po.ProductOfferingId.Value, formattedDisplayString);
    }

    public static List<BasePriceableItemInstance> GetPriceListsWithUdrcs(List<int> poIds)
    {
      var resultPiList = new List<BasePriceableItemInstance>();

      var client = new ProductOfferingServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      foreach (var poId in poIds)
      {
        var priceableItems = new MTList<BasePriceableItemInstance>();
        client.GetPIInstancesForPO(new PCIdentifier(poId), ref priceableItems);
        var udrcPiList = priceableItems.Items.Where(pi => pi.PIKind == PriceableItemKinds.UnitDependentRecurring);
        resultPiList.AddRange(udrcPiList);
      }

      return resultPiList;
    }

    public static KeyValuePair<int, string> GetPriceListItem(BasePriceableItemInstance priceableItem)
    {
      Debug.Assert(priceableItem.ID != null, "Error: Priceable Item Id is null.");

      var formattedDisplayString = String.Format("{0}", priceableItem.Name);
      return new KeyValuePair<int, string>(priceableItem.ID.Value, formattedDisplayString);
    }

    public static List<BasePriceableItemInstance> GetPIWithAllowICBs(List<int> poIds)
    {
      var resultPiList = new List<BasePriceableItemInstance>();

      var client = new ProductOfferingServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

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
  }
}
