using System;
using System.Collections.Generic;
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
            return HttpContext.Current.Session[Constants.UI_MANAGER] as UIManager; // Session information with current user credentials
        }
    }

    public static PartitionData PartitionData
    {
        get
        {
            return (PartitionData)UI.User.GetData("PartitionData");
        }
    }

    public static bool IsPartition
    {
        get
        {
            return PartitionData.isPartitionUser;
        }
    }

    public static PartitionData RetrievePartitionInformation()
    {
        PartitionData PartitionData = new PartitionData();

        int topLevelAncestorId = MetraTech.UI.Tools.Utils.GetCorporateAccountOfChildAccount(UI.User.AccountId, MetraTech.MetraTime.Now);

        if (topLevelAncestorId != 0)
        {
            if (topLevelAncestorId == UI.User.AccountId) /* The user account is at the top, which means it is not a Partition Admin */
            {
                PartitionData.isPartitionUser = false;
                PartitionData.POPartitionId = 1;
                PartitionData.PLPartitionId = 1;
                PartitionData.PartitionUserName = "root";
                PartitionData.PartitionNameSpace = "mt";
                PartitionData.PartitionName = "root";
            }
            else
            {
                PartitionData.isPartitionUser = true;
                PartitionData.POPartitionId = topLevelAncestorId;
                PartitionData.PLPartitionId = topLevelAncestorId;

                // Retrieve the rest of the top level account information
                MetraTech.ActivityServices.Common.AccountIdentifier topLevelAncestorIdentifier = new MetraTech.ActivityServices.Common.AccountIdentifier(topLevelAncestorId);
                MetraTech.DomainModel.BaseTypes.Account userAccount = null;
                MetraTech.Core.Services.ClientProxies.AccountServiceClient accountServiceClient = new MetraTech.Core.Services.ClientProxies.AccountServiceClient();
                accountServiceClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                accountServiceClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
                accountServiceClient.LoadAccountWithViews(topLevelAncestorIdentifier, MetraTech.MetraTime.Now, out userAccount);

                PartitionData.PartitionUserName = userAccount.UserName;
                PartitionData.PartitionNameSpace = userAccount.Name_Space;
                PartitionData.PartitionName = ((MetraTech.DomainModel.AccountTypes.Partition)userAccount).LDAP[0].Company;
            }
        }
        else /* There were issues retrieving the top level account. Set Partition to an invalid number */
        {
            PartitionData.isPartitionUser = true;
            PartitionData.POPartitionId = -1;
            PartitionData.PLPartitionId = -1;
            PartitionData.PartitionUserName = "N/A";
            PartitionData.PartitionNameSpace = "N/A";
            PartitionData.PartitionName = "N/A";
        }

        PartitionData.PartitionDisplayName = string.Format("{0} ({1})", PartitionData.PartitionUserName, PartitionData.POPartitionId);

        return PartitionData;
    }

    public static void SetupFilterGridForPartition(MetraTech.UI.Controls.MTFilterGrid grid, string filtertype)
    {
        PartitionData PartitionData = (PartitionData)UI.User.GetData("PartitionData");

        if (filtertype.ToUpper() == "PO")
        {
            MetraTech.UI.Controls.MTGridDataElement gdel = grid.FindElementByID("POPartitionId");
            if (gdel == null)
            {
                throw new ApplicationException(string.Format("Can't find element named 'POPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?", grid.TemplateFileName));
            }

            if (PartitionData.isPartitionUser)
            {
                grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, PartitionData.PartitionName);
                gdel.ElementValue = PartitionData.POPartitionId.ToString();
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
                throw new ApplicationException(string.Format("Can't find element named 'PLPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?", grid.TemplateFileName));
            }

            if (PartitionData.isPartitionUser)
            {
                grid.Title = string.Format("{0} <i>({1})</i>", grid.Title, PartitionData.PartitionName);
                gdel.ElementValue = PartitionData.PLPartitionId.ToString();
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
        MetraTech.UI.Controls.MTGridDataElement gdel = grid.FindElementByID("POPartitionId");

        if (gdel == null)
        {
            throw new ApplicationException(string.Format("Can't find element named 'POPartitionId' on the FilterGrid layout. Has the layout '{0}' been tampered with?", grid.TemplateFileName));
        }

        grid.Title = string.Format("Master {0}", grid.Title);
        gdel.ElementValue = "0";
        gdel.FilterReadOnly = true;
        gdel.FilterHideable = false;
    }


    public static void PopulatePriceListDropdown(DropDownList ddPriceList)
    {
        PriceListServiceClient client = null;

        try
        {
            ddPriceList.Items.Clear();

            ListItem plitemNone = new ListItem();
            plitemNone.Text = "";
            plitemNone.Value = "";
            ddPriceList.Items.Add(plitemNone);

            client = new PriceListServiceClient();
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }
            
            MTList<PriceList> items = new MTList<PriceList>();

            // Setup Filters
            //MTFilterElement currencyFilterElement = new MTFilterElement("Currency", MTFilterElement.OperationType.Equal, );
            //items.Filters.Add(currencyFilterElement);

            if (IsPartition)
            {
                MTFilterElement PartitionfilterElement = new MTFilterElement("PLPartitionId", MTFilterElement.OperationType.Equal, PartitionData.PLPartitionId);
                items.Filters.Add(PartitionfilterElement);
            }

            client.GetSharedPriceLists(ref items);

            foreach (PriceList pl in items.Items)
            {
                ListItem plitem = new ListItem();
                plitem.Text = string.Format("[{0}] {1}", pl.Currency, pl.Name);
                plitem.Value = pl.ID.ToString();
                ddPriceList.Items.Add(plitem);
            }



        }       
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }

    }
}