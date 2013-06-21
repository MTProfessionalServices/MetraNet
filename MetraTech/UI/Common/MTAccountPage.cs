using System;
using System.Collections.Generic;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Tools;
using MetraTech.DomainModel.AccountTypes;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.UI.Common
{
  public class MTAccountPage : MTPage
  {
    public Account Account
    {
      get { return ViewState["Account"] as Account; }
      set { ViewState["Account"] = value; }
    }

    public InternalView Internal
    {
      get { return Utils.GetProperty(Account, "Internal") as InternalView; }
      set { Internal = value; }
    }

    public ContactView BillTo
    {
      get
      {
        foreach (ContactView v in (List<ContactView>)Utils.GetProperty(Account, "LDAP"))
        {
          if (v.ContactType == ContactType.Bill_To)
          {
            return v;
          }
        }

        return null;
      }
      set
      {
        foreach (ContactView v in (List<ContactView>)Utils.GetProperty(Account, "LDAP"))
        {
          if (v.ContactType == ContactType.Bill_To)
          {
            BillTo = value;
            return;
          }
        }
      }
    }
    
    public List<PriceList> PriceListCol
    {
      get { return ViewState["PriceListCol"] as List<PriceList>; }
      set { ViewState["PriceListCol"] = value; }
    }

    /// <summary>
    /// Populates a list of namespaces that are of type system_mps.  IE. branded sites.
    /// </summary>
    /// <returns></returns>
    public void PopulatePresentationNameSpaceList(DropDownList ddNameSpace)
    {
      try
      {
        ddNameSpace.Items.Clear();
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\mam\sql"))
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\mam\sql",
                                                                   "__GET_PRESENTATION_NAME_SPACE_LIST__"))
            {
                using (IMTDataReader dataReader = stmt.ExecuteReader())
                {
                    while (dataReader.Read())
                    {
                        ListItem item = new ListItem();
                        item.Text = dataReader.GetString("tx_desc");
                        item.Value = dataReader.GetString("nm_space");
                        ddNameSpace.Items.Add(item);
                    }
                }
            }
        }
      }
      catch (Exception exp)
      {
        Logger.LogException("Unable to get presentation namespace list.", exp);
      }
    }


    /// <summary>
    /// Populate a list of available price lists
    /// </summary>
    /// <param name="ddPriceList"></param>
    public void PopulatePriceList(DropDownList ddPriceList)
    {
      try
      {
        ddPriceList.Items.Clear();

        ListItem plitemNone = new ListItem();
        plitemNone.Text = Resources.TEXT_NONE;
        plitemNone.Value = "";
        ddPriceList.Items.Add(plitemNone);

        foreach (PriceList pl in PriceListCol)
        {
          ListItem plitem = new ListItem();
          plitem.Text = pl.Currency.ToString() + ": " + pl.Name;
          plitem.Value = pl.ID.ToString();
          ddPriceList.Items.Add(plitem);
        }
      }
      catch (Exception exp)
      {
        Logger.LogException("Unable to populate pricelist", exp);
      }
    }

    /// <summary>
    /// Returns MetraNet virtual folder name
    /// </summary>
    /// <returns>String contains MetraNet virtual folder name</returns>
    protected string GetVirtualFolder()
    {
      string path = AppDomain.CurrentDomain.FriendlyName;
      path = path.Substring(path.LastIndexOf("/"));
      path = path.Substring(0, path.IndexOf("-"));
      return path;
    }

  }
}
