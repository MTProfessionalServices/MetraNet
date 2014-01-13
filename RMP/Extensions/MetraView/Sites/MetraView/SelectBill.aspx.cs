using System;
using System.Web.UI.WebControls;

using MetraTech.Auth.Capabilities;
using MetraTech.DataAccess;
using MetraTech.UI.Common;

public partial class SelectBill : MTPage
{

  protected void Page_Load(object sender, EventArgs e)
  {
    // expire the page, so it doesn't cache it and mess up the session if the user hits the back button.
    Response.Expires = -1;
    Response.Cache.SetNoServerCaching();
    Response.Cache.SetAllowResponseInBrowserHistory(false);
    Response.CacheControl = "no-cache";
    Response.Cache.SetNoStore();

    Session[SiteConstants.ActiveMenu] = "Home";
    int ownerId = -1;
    string ownerName = UI.User.UserName;
    string ownerNameSpace = UI.User.NameSpace;

    // check to see if the account logging in is allowed to impersonate
    if (UI.SessionContext.SecurityContext.GetCapabilitiesOfType("Impersonation").Count > 0)
      ownerId = UI.User.AccountId;

    // build the links and set owner data in session
    if (ownerId != -1)
    {
      if (Session["IsOwner"] == null)
        Session.Add("IsOwner", String.Format("{0}:{1}", ownerName, ownerNameSpace));

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__GET_BILL_MANAGEMENT_DATA__"))
        {
          stmt.AddParam("%%ID_ACC%%", ownerId);
          stmt.AddParam("%%NM_SPACE%%", ownerNameSpace);
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            int i = 0;
            while (rdr.Read())
            {
              string login = rdr.GetString("nm_login");
              string nameSpace = rdr.GetString("nm_space");
              string link = String.Format("SelectBillEntryPoint.aspx?UserName={0}&NameSpace={1}",
                                          Server.HtmlEncode(login), Server.HtmlEncode(nameSpace));
              ListItem item = new ListItem(login, link);
              ddAccountLinks.Items.Add(item);
              i++;
            }
          }
        }
      }

      // grab the user name from the session in case we want to see our own bill
      string ownerBill = String.Format("SelectBillEntryPoint.aspx?UserName={0}&NameSpace={1}",
                                       Server.HtmlEncode(ownerName), Server.HtmlEncode(UI.User.NameSpace));
      ListItem owner = new ListItem(ownerName, ownerBill);
      ddAccountLinks.Items.Add(owner);
    }
    else
    {
      // hide the control if we don't have an owner
      ddAccountLinks.Visible = false;
      lblMsg.Text = GetLocalResourceObject("TEXT_REDIRECT_MESSAGE").ToString();
    }
  }
}