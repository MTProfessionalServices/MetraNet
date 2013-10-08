using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using AccHierarchy;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;


public partial class AjaxServices_Hierarchy : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
   Logger.LogDebug("======================* START HIERARCHY FIND *=======================");
    var service = new AccHierarchy.MAMHierarchyWebSvc();

    if (Request.ServerVariables["HTTPS"].ToLower() == "on")
    {
       service.Url = service.Url.Replace("http:", "https:");

       // CORE-5922: SSL certificate name mismatch error should not be supressed. 
       // Suppressing is commented out
       //var certManager = new CertManager();
       //certManager.EnableDeveloperCert(ConfigurationManager.AppSettings["FullyQualifiedMachineName"]);
    }
    if (Request["DropID"] != null)
    {
      string dropID = Request["DropID"];

      if (dropID.Contains("(") && dropID.Contains(")"))
      {
        int start = dropID.LastIndexOf("(");
        int end = dropID.LastIndexOf(")");
        dropID = dropID.Substring(start + 1, (end - start)-1);
      }
      else
      {
        int index = dropID.LastIndexOf("=");
        if (index > 0)
        {
          dropID = dropID.Substring(index + 1);
        }
      }

      string str = service.GetFieldIDFromAccountID(int.Parse(dropID), ReadDateFromURL(), UI.User.SessionContext.SecurityContext.ToXML());
      Response.Write(str);
      Response.End();
      return;
    }

    int id = 1;
    int pageNumber = 1;

    string startAccountNameInPage = Request["startAccountNameInPage"] ?? string.Empty;
    if(Request["node"] != null)
      id = int.Parse(Request["node"]);
    int.TryParse(Request["pageNumber"], out pageNumber);
    if (pageNumber == 0)
    {
        pageNumber++;
    }

    object[] nodes;
    object[] visibleAccounts = new object[0];
    bool showAllNodes = true;

    // ESR-5472 Nested search doesn’t work. Search is only working for first level - should work for nested levels. Deprecated from 5.0 
    // Added two additional parameters into hierarchy level retrival service.
    string companyFilter = Request["companyFilter"] != "Corp. Company Name" ? Request["companyFilter"] : string.Empty;
    string usernameFilter = Request["usernameFilter"] != "Corp. Company Username" ? Request["usernameFilter"] : string.Empty;

 // Get companies that mach search if we are at the top level
	/*
    if (id == 1)
    {
      AccountServiceClient client = null;
      try
      {
        client = new AccountServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        MTList<MetraTech.DomainModel.BaseTypes.Account> items = new MTList<MetraTech.DomainModel.BaseTypes.Account>();

        items.Items.Clear();
        items.PageSize = 1000;
        items.CurrentPage = 1;

        var ancestorFilter = new MTFilterElement("AncestorAccountID", MTFilterElement.OperationType.Equal, 1);
        items.Filters.Add(ancestorFilter);

				if (!String.IsNullOrEmpty(companyFilter))
        if (!String.IsNullOrEmpty(companyFilter))
        {
		  MTFilterElement fe = new MTFilterElement("company", MTFilterElement.OperationType.Like_W, companyFilter.AppendWildcard());
          items.Filters.Add(fe);
        }

        if (!String.IsNullOrEmpty(usernameFilter))
        {
          MTFilterElement fe1 = new MTFilterElement("username", MTFilterElement.OperationType.Like_W, usernameFilter.AppendWildcard());
          items.Filters.Add(fe1);
        }

        client.GetAccountList(ReadDateFromURL(), ref items, false);

        var count = items.Items.Count;
        visibleAccounts = new object[items.Items.Count];
        if(count == 0)
        {
          visibleAccounts = null;
        }
        else
        {
          int i = 0;
          foreach (var itm in items.Items)
          {
            visibleAccounts[i] = itm._AccountID.ToString();
			Logger.LogDebug ("Visible Account: " + itm._AccountID.ToString());
            i++;
          }
        }

        showAllNodes = false;
      }
      catch (Exception ex)
      {
        Logger.LogException("No company found", ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }
    }*/
  Logger.LogDebug("==========================* DONE WITH FIRST *=============================");


    // Get a max number of nodes (accounts) displayed per a page
    int maxAccountsInPage = service.GetNestedNodePageSize();
    int rootNodeCapacity = service.GetRootNodeCapacity();

    // Get tree that match nodes
    nodes = service.GetHierarchyLevel(
      Request["type"],
      id,
      ReadDateFromURL(),
      UI.User.SessionContext.SecurityContext.ToXML(),
      showAllNodes,
      visibleAccounts,
      companyFilter.AppendWildcard(),
      usernameFilter.AppendWildcard(),
      pageNumber);

    Response.Write("[");
    bool bFirst = true;
    int countNodes = 0;
    if (nodes != null)
    {
	 object lastNodeId = "";
      foreach (AccHierarchy.MAMHierarchyItem node in nodes)
      {
        lastNodeId = node.ItemID;
        countNodes++;
        if (!bFirst)
        {
          Response.Write(",");
        }
        else
        {
          bFirst = false;
        }
        if (String.IsNullOrEmpty(node.Owner))
        {
          Response.Write("{'text':'");
          Response.Write(FixString(node.HierarchyName));
        }
        else
        {
          Response.Write("{'text':'");
          Response.Write(FixString(node.HierarchyName));
          Response.Write(" [" + FixString(node.Owner) + "]");
        }
        Response.Write("','qtip':'"); Response.Write(node.ItemID);
        Response.Write("','accType':'"); Response.Write(node.AccountType);
        Response.Write("','href':'/MetraNet/ManageAccount.aspx?id="); Response.Write(node.ItemID);

        Response.Write("','listeners':{contextmenu:function(node,e){Account.ShowHCMenu(node,e);}}");

/*
        Response.Write(string.Format(",'HasLogonCapability':{0}", (node.HasLogonCapability == 1 ? true : false).ToString().ToLower()));
*/

		Response.Write(string.Format(",'pageNumber':'{0}", pageNumber));

        Response.Write("','hrefTarget':'MainContentIframe");
        Response.Write("','id':'"); Response.Write(node.ItemID);
        Response.Write("','leaf':");
        Response.Write((!(node.HasChildren)).ToString().ToLower());

        StringBuilder imageURLPath = new StringBuilder();

        imageURLPath.Append(@"/ImageHandler/images/Account/");
        imageURLPath.Append(node.AccountType);
        imageURLPath.Append(@"/");
        imageURLPath.Append("account.gif");
        imageURLPath.Append("?Payees=");
        imageURLPath.Append(node.NumberOfPayees.ToString());
        imageURLPath.Append("&State=");
        imageURLPath.Append(node.AccountState);
        if (node.HasChildren)
        {
            imageURLPath.Append("&Folder=TRUE");
            imageURLPath.Append("&FolderOpen=FALSE");
        }

        Response.Write(",'icon':'"); Response.Write(imageURLPath.ToString());
        Response.Write("','canBeManaged':'");
        Response.Write(node.CanWrite.ToString());
		
        // Response.Write(",'cls':'");  Response.Write(node.ItemType.ToString());
        Response.Write("'}");

        if (id != 1 && countNodes >= maxAccountsInPage && pageNumber == 1)
        {
          Response.Write(string.Format(",{{'text':'Click here to view next {0} accounts.','id':'-111','leaf':true}}", maxAccountsInPage));
          break;
        }
      }

      // If there are too many accounts to display then return a search node
      if (id == 1 && nodes.Length >= rootNodeCapacity && pageNumber == 1)
      {
        Response.Write(string.Format(",{{'text':'Click here to view new {0} accounts.','id':'-111','leaf':true}}", rootNodeCapacity));
      }
    }

    Response.Write("]");

    //Response.Write("[{'text':'ext-core.js','id':'ext-core.js','leaf':true,'cls':'file'},{'text':'ext-all-debug.js','id':'ext-all-debug.js','leaf':true,'cls':'file'},{'text':'ext-core-debug.js','id':'ext-core-debug.js','leaf':true,'cls':'file'},{'text':'resources','id':'resources','cls':'folder'},{'text':'source','id':'source','cls':'folder'},{'text':'build','id':'build','cls':'folder'},{'text':'ext-all.js','id':'ext-all.js','leaf':true,'cls':'file'},{'text':'adapter','id':'adapter','cls':'folder'},{'text':'dev','id':'dev','leaf':true,'cls':'file'},{'text':'examples','id':'examples','cls':'folder'},{'text':'LICENSE.txt','id':'LICENSE.txt','leaf':true,'cls':'file'},{'text':'docs','id':'docs','cls':'folder'},{'text':'INCLUDE_ORDER.txt','id':'INCLUDE_ORDER.txt','leaf':true,'cls':'file'}]");
	 Logger.LogDebug("==============================* END HIERARCHY FIND *==================================");
    Response.End();
  }

  protected string FixString(string input)
  {
      // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
      // Added JavaScript encoding
      //return input.Replace("'", "\\'");
      return input.EncodeForJavaScript();
  }

  protected DateTime ReadDateFromURL()
  {
    DateTime dt = ApplicationTime;

    if (!String.IsNullOrEmpty(Request["day"]) && !String.IsNullOrEmpty(Request["month"]) && !String.IsNullOrEmpty(Request["year"]))
    {
      dt = new DateTime(int.Parse(Request["year"]), int.Parse(Request["month"]), int.Parse(Request["day"]), 23, 59, 59);
    }

    ApplicationTime = dt;

    return dt;
  }
}
