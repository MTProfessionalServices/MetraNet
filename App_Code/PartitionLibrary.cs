using System;
using System.Collections.Generic;
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

  public static Dictionary<string, Int32> RetrieveAllPartitions()
  {
    return AccountIdentifierResolver.GetAllPartitions();
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

  public static void SetupFilterGridForPartition(MetraTech.UI.Controls.MTFilterGrid grid, string filtertype, bool forSubscription = false)
  {
    PartitionData partitionData;
    if (forSubscription)
      partitionData = (UI.Subscriber.SelectedAccount == null)? RetrievePartitionInformation(null) : RetrievePartitionInformation(UI.Subscriber.SelectedAccount._AccountID);
    else
      partitionData = (PartitionData) UI.User.GetData("PartitionData");

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
    }

    gdel.FilterHideable = true;

    if (partitionData.isPartitionUser || forSubscription)
    {
      gdel.FilterReadOnly = true;
      gdel.FilterOperation = MTFilterOperation.Equal;
      gdel.ElementValue = filtertype.ToUpper() == "PL"
                            ? partitionData.PLPartitionId.ToString(CultureInfo.CurrentCulture)
                            : (filtertype.ToUpper() != "PO"
                                 ? partitionData.POPartitionId.ToString(CultureInfo.CurrentCulture)
                                 : partitionData.PLPartitionId.ToString(CultureInfo.CurrentCulture));
    }
    else
    {
      gdel.FilterReadOnly = false;
      // List all (partition and non-partition) product offerings except Master PO for non-partition system user
      gdel.FilterOperation = MTFilterOperation.NotEqual;
      gdel.ElementValue = "0";
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

  public static void SetupFilterGridForPartitionSystemUser(MetraTech.UI.Controls.MTFilterGrid grid,
                                                           string partitionElement, bool filterByPartitionId = true)
  {
    var gdel = grid.FindElementByID(partitionElement);
    if (gdel == null)
    {
      // let us not thru exception for now, there might be a case where gridlayout might not have partition id as a column
      //throw new ApplicationException(
      //  string.Format("Can't find element named {0} on the FilterGrid layout '{1}'", filterElementName,
      //                grid.TemplateFileName));
      return;
    }

    Dictionary<string, Int32> partitions = RetrieveAllPartitions();
    partitions = partitions.OrderByDescending(x => x.Value).ToDictionary(x => x.Key, x => x.Value);
    
    gdel.FilterHideable = true;
    if (partitions.Count == 0)
    {
      // If there is no partition in the system, then remove partition column from the grid
      gdel.IsColumn = false;
      gdel.Filterable = false;
    }
    else
    {
      if (PartitionData.isPartitionUser)
      {
        grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, PartitionData.PartitionName);
        gdel.FilterOperation = MTFilterOperation.Equal;
        gdel.ElementValue = filterByPartitionId
                              ? PartitionData.PartitionId.ToString(CultureInfo.CurrentCulture)
                              : PartitionData.PartitionUserName;
        gdel.FilterReadOnly = true;
      }
      else
      {
        gdel.DataType = MTDataType.List;

        // Add an entry for Non-Partition (root)
        partitions.Add("Non-Partitioned", 1);
        
        foreach (string pname in partitions.Keys)
        {
          int pId;
          partitions.TryGetValue(pname, out pId);
          var dropDownItem = new MTFilterDropdownItem();
          dropDownItem.Key = filterByPartitionId
                               ? pId.ToString(CultureInfo.CurrentCulture)
                               : pname;
          dropDownItem.Value = string.Format("{0} ({1})", pname, pId.ToString(CultureInfo.CurrentCulture));
          gdel.FilterDropdownItems.Add(dropDownItem);
        }
      }
    }
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