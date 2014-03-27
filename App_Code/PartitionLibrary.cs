using System;
using System.Globalization;
using System.Linq;
using System.Web;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;

public struct PartitionData
{
    public bool isPartitionUser;
    public int  POPartitionId;
    public int  PLPartitionId;
    public string PartitionUserName;
    public string PartitionNameSpace;
    public string PartitionName;
    public string PartitionDisplayName;
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
    get { return (PartitionData) UI.User.GetData("PartitionData"); }
  }

  public static bool IsPartition
  {
    get { return PartitionData.isPartitionUser; }
  }

  public static PartitionData RetrievePartitionInformation()
  {
    var partitionData = new PartitionData();
    var topLevelAncestorId = MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.User.AccountId,
                                                                                        MetraTech.MetraTime.Now);

    if (topLevelAncestorId != 0)
    {
      if (topLevelAncestorId == UI.User.AccountId)
      {
        // The user account is at the top, which means it is not a Partition Admin
        partitionData.isPartitionUser = false;
        partitionData.POPartitionId = 1;
        partitionData.PLPartitionId = 1;
        partitionData.PartitionUserName = "root";
        partitionData.PartitionNameSpace = "mt";
        partitionData.PartitionName = "root";
      }
      else
      {
        partitionData.isPartitionUser = true;
        partitionData.POPartitionId = topLevelAncestorId;
        partitionData.PLPartitionId = topLevelAncestorId;

        // Retrieve the rest of the top level account information
        var topLevelAncestorIdentifier = new AccountIdentifier(topLevelAncestorId);
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
          var firstLdap = ((MetraTech.DomainModel.AccountTypes.Partition) userAccount).LDAP.FirstOrDefault();
          partitionData.PartitionName = firstLdap == null || string.IsNullOrEmpty(firstLdap.Company)
                                          ? userAccount.UserName
                                          : firstLdap.Company;
        }
      }
    }
    else
    {
      // There were issues retrieving the top level account. Set Partition to an invalid number
      partitionData.isPartitionUser = true;
      partitionData.POPartitionId = -1;
      partitionData.PLPartitionId = -1;
      partitionData.PartitionUserName = "N/A";
      partitionData.PartitionNameSpace = "N/A";
      partitionData.PartitionName = "N/A";
    }

    partitionData.PartitionDisplayName = string.Format(
      "{0} ({1})",
      partitionData.PartitionUserName,
      partitionData.POPartitionId);

    return partitionData;
  }

  public static void SetupFilterGridForPartition(MetraTech.UI.Controls.MTFilterGrid grid, string filtertype)
  {
    var partitionData = (PartitionData) UI.User.GetData("PartitionData");

    if (filtertype.ToUpper() == "PO")
    {
      MetraTech.UI.Controls.MTGridDataElement gdel = grid.FindElementByID("POPartitionId");
      if (gdel == null)
      {
        throw new ApplicationException(
          string.Format(
            "Can't find element named 'POPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?",
            grid.TemplateFileName));
      }

      if (partitionData.isPartitionUser)
      {
        grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, partitionData.PartitionName);
        gdel.ElementValue = partitionData.POPartitionId.ToString(CultureInfo.CurrentCulture);
        gdel.FilterReadOnly = true;
        gdel.FilterHideable = false;
      }
      else
      {
        gdel.FilterReadOnly = false;
        gdel.FilterHideable = true;
      }
    }
    else
    {
      MetraTech.UI.Controls.MTGridDataElement gdel = grid.FindElementByID("PLPartitionId");
      if (gdel == null)
      {
        throw new ApplicationException(
          string.Format(
            "Can't find element named 'PLPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?",
            grid.TemplateFileName));
      }

      if (partitionData.isPartitionUser)
      {
        grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, partitionData.PartitionName);
        gdel.ElementValue = partitionData.PLPartitionId.ToString(CultureInfo.CurrentCulture);
        gdel.FilterReadOnly = true;
        gdel.FilterHideable = false;

      }
      else
      {
        gdel.FilterReadOnly = false;
        gdel.FilterHideable = true;
      }
    }
  }

  public static void SetupFilterGridForMaster(MetraTech.UI.Controls.MTFilterGrid grid)
  {
    var gdel = grid.FindElementByID("POPartitionId");

    if (gdel == null)
    {
      throw new ApplicationException(
        string.Format(
          "Can't find element named 'POPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?",
          grid.TemplateFileName));
    }

    grid.Title = string.Format("Master {0}", grid.Title);
    gdel.ElementValue = "0";
    gdel.FilterReadOnly = true;
    gdel.FilterHideable = false;
  }


  public static void PopulatePriceListDropdown(DropDownList ddPriceList)
  {
    ddPriceList.Items.Clear();

    var plitemNone = new ListItem {Text = "", Value = ""};
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

      foreach (var plitem in items.Items.Select(pl => new ListItem {Text = string.Format("[{0}] {1}", pl.Currency, pl.Name), Value = pl.ID.ToString()}))
      {
        ddPriceList.Items.Add(plitem);
      }
    }
  }
}