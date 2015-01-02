using System;
using System.Globalization;
using System.Linq;
using System.Web;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Controls;

public struct PartitionData
{
  public bool isPartitionUser;
  public int POPartitionId;
  public int PLPartitionId;
  public string PartitionUserName;
  public string PartitionNameSpace;
  public string PartitionName;
  public string PartitionDisplayName;
  public int PartitionId;
}

/// <summary>
/// Summary description for PartitionLibrary
/// </summary>
public class PartitionLibrary
{
  private static UIManager UI
  {
    get
    {
      return HttpContext.Current.Session[Constants.UI_MANAGER] as UIManager;
      // Session information with current user credentials
    }
  }

  public static PartitionData PartitionData
  {
    get { return (PartitionData)UI.User.GetData("PartitionData"); }
  }

  public static bool IsPartition
  {
    get { return PartitionData.isPartitionUser; }
  }

  public static PartitionData RetrievePartitionInformation(int? accId = 0)
  {
    if (accId == 0 || accId == null)
      accId = UI.User.AccountId;
    var partitionData = new PartitionData();

    var partitionId = AccountIdentifierResolver.GetPartitionIdOfAccount((int)accId);

    partitionData.isPartitionUser = partitionId != 1;
    partitionData.PartitionId = partitionId;
    partitionData.POPartitionId = partitionData.PartitionId;
    partitionData.PLPartitionId = partitionData.PartitionId;

    if (partitionId == 1)
    {
      partitionData.PartitionUserName = "root";
      partitionData.PartitionNameSpace = "mt";
      partitionData.PartitionName = "root";
    }
    else
    {
      // Retrieve the rest of the top level account information
      var topLevelAncestorIdentifier = new AccountIdentifier(partitionId);
      using (var accountServiceClient = new AccountServiceClient())
      {
        if (accountServiceClient.ClientCredentials != null)
        {
          accountServiceClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          accountServiceClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        Account userAccount;
        accountServiceClient.LoadAccountWithViews(topLevelAncestorIdentifier, MetraTech.MetraTime.Now, out userAccount);

        partitionData.PartitionUserName = userAccount.UserName;
        partitionData.PartitionNameSpace = userAccount.Name_Space;
        ContactView firstLdap;
        try
        {
          firstLdap = ((Partition)userAccount).LDAP.FirstOrDefault();
        }
        catch (Exception)
        {
          firstLdap = null;
        }
        partitionData.PartitionName = firstLdap == null || string.IsNullOrEmpty(firstLdap.Company)
                                        ? userAccount.UserName
                                        : firstLdap.Company;
      }
    }

    partitionData.PartitionDisplayName = string.Format("{0} ({1})",
                                                        partitionData.PartitionUserName,
                                                        partitionData.POPartitionId);

    return partitionData;
  }

  public static void SetupFilterGridForPartition(MTFilterGrid grid, string filtertype, bool forSubscription = false, bool clearFilter = false)
  {
    PartitionData partitionData;
    if (forSubscription)
      partitionData = RetrievePartitionInformation(UI.Subscriber.SelectedAccount._AccountID);
    else
      partitionData = (PartitionData)UI.User.GetData("PartitionData");

    var filterElementName = "POPartitionId";
    if (filtertype.ToUpper() != "PO")
      filterElementName = "PLPartitionId";

    var gdel = grid.FindElementByID(filterElementName);
    if (gdel == null)
    {
      throw new ApplicationException(
        string.Format("Can't find element named {1} on the FilterGrid layout. Has the layout '{0}' been tampered with?",
          grid.TemplateFileName, filterElementName));
    }

    if (partitionData.isPartitionUser)
    {
      grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, partitionData.PartitionName);
      gdel.FilterReadOnly = true;
    }
    else
      gdel.FilterReadOnly = false;

    gdel.FilterHideable = true;
    gdel.ElementValue = filtertype.ToUpper() == "PL"? partitionData.PLPartitionId.ToString(CultureInfo.CurrentCulture)
                                                    : (filtertype.ToUpper() != "PO" ? partitionData.POPartitionId.ToString(CultureInfo.CurrentCulture)
                                                                                    : partitionData.PLPartitionId.ToString(CultureInfo.CurrentCulture));
    if (clearFilter)
    {
      gdel.ElementValue = String.Empty;
    }
  }

  public static void SetupFilterGridForMaster(MetraTech.UI.Controls.MTFilterGrid grid, string masterLocalizedText)
  {
    var gdel = grid.FindElementByID("POPartitionId");

    if (gdel == null)
    {
      throw new ApplicationException(
        string.Format(
          "Can't find element named 'POPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?",
          grid.TemplateFileName));
    }

    grid.Title = masterLocalizedText;
    gdel.FilterOperation = MTFilterOperation.Equal;
    gdel.ElementValue = "0";
    gdel.FilterReadOnly = true;
    gdel.FilterHideable = false;
  }


  public static void PopulatePriceListDropdown(DropDownList ddPriceList)
  {
    ddPriceList.Items.Clear();

    var plitemNone = new ListItem { Text = "", Value = "" };
    ddPriceList.Items.Add(plitemNone);

    using (var client = new PriceListServiceClient())
    {
      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      var items = new MTList<PriceList>();
      if (IsPartition)
      {
        var partitionfilterElement = new MTFilterElement("PLPartitionId",
                                                         MTFilterElement.OperationType.Equal,
                                                         PartitionData.PLPartitionId);
        items.Filters.Add(partitionfilterElement);
      }

      client.GetSharedPriceLists(ref items);

      foreach (var plitem in items.Items.Select(pl => new ListItem { Text = string.Format("[{0}] {1}", pl.Currency, pl.Name), Value = pl.ID.ToString() }))
      {
        ddPriceList.Items.Add(plitem);
      }
    }
  }
}