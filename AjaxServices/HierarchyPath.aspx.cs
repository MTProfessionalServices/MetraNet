using System;
using System.Text;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
// ReSharper disable SpecifyACultureInStringConversionExplicitly

public partial class AjaxServices_HierarchyPath : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var id = 0;
    var type = "'system_mps'";
    if (Request["node"] != null)
      id = int.Parse(Request["node"]);
    if (Request["type"] != null)
      type = Request["type"];
    GetHierarchy(id, type);
    Response.End();
  }

  protected void GetTxPath(int idAcc)
  {
    using (var conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement("Queries\\AccHierarchies", "__HIERARCHY_BROWSER_TXPATH__"))
      {
        stmt.AddParam("%%ID_ACC%%", idAcc);
        stmt.AddParam("%%REF_DATE%%", "GETDATE()");
        using (var crsr = stmt.ExecuteReader())
        {
          while (crsr.Read())
          {
            Response.Write(crsr.GetString("tx_path"));
          }
        }
      }
    }
  }

  protected void GetHierarchy(int idAcc, string nmtype)
  {
    using (var conn = ConnectionManager.CreateConnection())
    {
      using (var stmt = conn.CreateAdapterStatement("Queries\\AccHierarchies", "__HIERARCHY_BROWESER_LEVELS__"))
      {
        stmt.AddParam("%%DESCENDENT%%", idAcc);
        stmt.AddParam("%%TYPE_SPACE%%", nmtype, true);
        stmt.AddParam("%%REF_DATE%%", MetraTech.MetraTime.Now);
        using (var crsr = stmt.ExecuteReader())
        {
          Response.Write("[");
          var first = true;
          while (crsr.Read())
          {
            Logger.LogDebug("Found one: " + crsr.GetInt32("parent_id"));
            if (!first)
            {
              Response.Write(",");
            }
            first = false;
            var owner = crsr.GetValue("folder_owner").ToString();
            if (String.IsNullOrEmpty(owner))
            {
              Response.Write("{'text':'");
              Response.Write(FixString(crsr.GetValue("hierarchyname").ToString()));
            }
            else
            {
              Response.Write("{'text':'");
              Response.Write(FixString(crsr.GetValue("hierarchyname").ToString()));
              Response.Write(" [" + FixString(crsr.GetValue("folder_owner").ToString()) + "]");
            }
            var id = crsr.GetInt32("parent_id");
            Response.Write("','qtip':'"); Response.Write(id);
            Response.Write("','accType':'"); Response.Write(crsr.GetString("account_type"));
            Response.Write("','href':'/MetraNet/ManageAccount.aspx?id="); Response.Write(id);
            Response.Write("','listeners':{contextmenu:function(node,e){Account.ShowHCMenu(node,e);}}");
            //					Response.Write(string.Format(",'pageNumber':'{0}'", pageNumber));
            Response.Write(",'hrefTarget':'MainContentIframe");
            Response.Write("','id':'"); Response.Write(id);
            Response.Write("','leaf':");
            Response.Write((!(crsr.GetBoolean("children"))).ToString().ToLower());

            var imageURLPath = new StringBuilder();

            imageURLPath.Append(@"/ImageHandler/images/Account/");
            imageURLPath.Append(crsr.GetString("account_type"));
            imageURLPath.Append(@"/");
            imageURLPath.Append("account.gif");
            imageURLPath.Append("?Payees=");
            imageURLPath.Append(crsr.IsDBNull("id_payee") ? "0" : crsr.GetInt32("numpayees").ToString());
            imageURLPath.Append("&State=");
            imageURLPath.Append(crsr.GetString("status"));
            if (crsr.GetBoolean("children"))
            {
              imageURLPath.Append("&Folder=TRUE");
              imageURLPath.Append("&FolderOpen=FALSE");
              //                      Response.Write(",'loaded':"); Response.Write(true.ToString().ToLower());
            }

            Response.Write(",'icon':'"); Response.Write(imageURLPath.ToString());
            Response.Write("','parentid':'"); Response.Write(crsr.GetInt32("id_parent").ToString());
            Response.Write("','n_folder':'"); Response.Write(crsr.GetInt32("folder").ToString());
            Response.Write("','nm_name':'"); Response.Write(FixString(crsr.GetString("hierarchyname")));
            Response.Write("','nm_type':'"); Response.Write(crsr.GetString("account_type"));
            Logger.LogDebug(string.Format("Folder: {0} Hierarchy: {1} Type: {2}", crsr.GetInt32("folder").ToString(), crsr.GetString("hierarchyname"), crsr.GetString("account_type")));
            Response.Write("'}");
          }
          Response.Write("]");
        }
      }
    }
  }

  protected string FixString(string input)
  {
    return input.Replace("'", "\\'");
  }
}