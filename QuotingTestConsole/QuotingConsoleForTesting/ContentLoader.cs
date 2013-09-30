using System;
using System.Collections.Generic;
using System.Diagnostics;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;

namespace QuotingConsoleForTesting
{

  /// <summary>
  /// Class for retrieving formatted items for UI controls
  /// </summary>
  public class ContentLoader
  {
    public static KeyValuePair<int, string> GetAccountListBoxItem(Account account)
    {
      var formattedDisplayString = String.Format("{0} - {1}",
                                                 account.UserName,
                                                 account.AccountType); // [TODO] Display Usage cycle

      Debug.Assert(account._AccountID != null, "Error: AccountID is null.");
      return new KeyValuePair<int, string>(account._AccountID.Value, formattedDisplayString);
    }

    public static KeyValuePair<int, string> GetProductOfferingListBoxItem(ProductOffering po)
    {
      Debug.Assert(po.ProductOfferingId != null, "Error: ProductOfferingId is null.");
      var formattedDisplayString = String.Format("{0}", po.Name);
      return new KeyValuePair<int, string>(po.ProductOfferingId.Value, formattedDisplayString);
    }

    public static KeyValuePair<int, string> GetPriceListItem(BasePriceableItemInstance priceableItem)
    {
      Debug.Assert(priceableItem.ID != null, "Error: Priceable Item Id is null.");

      var formattedDisplayString = String.Format("{0}", priceableItem.Name);
      return new KeyValuePair<int, string>(priceableItem.ID.Value, formattedDisplayString);
    }
  }
}
