using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.SecurityFramework;
using MTAuth = MetraTech.Interop.MTAuth;
using MTYAAC = MetraTech.Interop.MTYAAC;
using Rowset = MetraTech.Interop.Rowset;
using MTCol  = MetraTech.Interop.GenericCollection;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Suggest
{

	public class Suggest : System.Web.UI.Page
	{
    //private Logger mLogger = new Logger("[Suggest]");

		private void Page_Load(object sender, System.EventArgs e)
		{
      try
      {
        string keyword = Request["Keyword"];
        string method = Request["Method"];
        string parameters = Request["Parameters"];
        string field = Request["Field"];
        string serializedContext = Request["SerializedContext"];
        MTYAAC.IMTAccountCatalog accountCatalog = null;
        MTYAAC.IMTSessionContext sessionContext = null;

        if((serializedContext != null) && (!serializedContext.Equals(String.Empty)))
        {
          sessionContext = (MTYAAC.IMTSessionContext)new MTAuth.MTSessionContext();
          try
          {
            sessionContext.FromXML(serializedContext.Replace(" ", "+"));
          }
          catch(Exception exp)
          {
            Response.Write(exp.ToString());
          }

          accountCatalog = new MTYAAC.MTAccountCatalog();
          accountCatalog.Init(sessionContext);
        }

        switch(method.ToUpper())
        {
          case "QUERY":
            ExecuteQuery(field, parameters, keyword);  
            break;

          case "ACCOUNT_FINDER":
            FindAccount(field, parameters, keyword, accountCatalog);
            break;

          case "PRODUCT_CATALOG":
          default:
      	    // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
            // Added Encoding
            Response.Write("Invalid method: " + Utils.EncodeForHtml(method));
            break;
        }
      }
      catch(Exception exp)
      {
        Response.Write(exp.ToString());
      }

      Response.End();
		}

    private void FindAccount(string field, string parameters, string keyword, MTYAAC.IMTAccountCatalog accountCatalog)
    {
      bool includeAccountID = false;
      bool ignoreNamespaceTypeForExternal = false;

      // Setup search filter, name/value pairs in parameters string
      Rowset.IMTDataFilter filter = new Rowset.MTDataFilter(); 
      string[] props = parameters.Split(',');
      
      for(int i=0; i < props.Length; i=i+2)
      {
        switch(props[i].ToUpper())
        {
          case "INCLUDEACCOUNTID":
            if( (props[i+1].ToUpper() == "TRUE") || ( props[i+1].ToUpper() == "T"))
            {
              includeAccountID = true;
            }
            break;

          case "ACCOUNTTYPENAME":
            string accountTypes = props[i+1].Replace("|", ",");
            filter.Add("AccountTypeName", Rowset.MTOperatorType.OPERATOR_TYPE_IN, accountTypes);
            break;

          case "_NAMESPACETYPE":
            if(!ignoreNamespaceTypeForExternal)
            {
              filter.Add("_NameSpaceType", Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, props[i+1]);
            }
            break;

          default:
            // Look for:  metratech.com/external:QuickFindSearchOnMapping
            if(props[i].IndexOf(":") > -1)
            {
              string[] external = props[i].Split(':');
              string newNamespace = external[0];
              string newProp = external[1];
              props[0] = newProp;

              filter.Add("name_space", Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, newNamespace);
              filter.Add(newProp, Rowset.MTOperatorType.OPERATOR_TYPE_LIKE_W, props[i+1]);
              filter.Add("_NameSpaceType", Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, "metered");
              ignoreNamespaceTypeForExternal = true;
            }
            else
            {
              // Remove any trailing * from value
              string val = props[i+1];
              if(val.EndsWith("*"))
              {
                val = val.Substring(0, val.Length-1);
              }
              filter.Add(props[i], Rowset.MTOperatorType.OPERATOR_TYPE_LIKE_W, val);
            }
            break;
        }
      }
      
      // Show only 1 match even if multiple contact types
      Rowset.IMTDataFilter joinFilter = new Rowset.MTDataFilterClass(); 
      joinFilter.Add("ContactType", Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, 0);

      // Execute find
      object moreRows;
      try
      {
        MTYAAC.IMTCollection columns = (MTYAAC.IMTCollection)new MTCol.MTCollectionClass();

        columns.Add(props[0]);
        if(includeAccountID)
        {
          columns.Add("_AccountID");
        }
        Rowset.IMTRowSet rs = (Rowset.IMTRowSet)accountCatalog.FindAccountsAsRowset(System.DateTime.Now, columns, (MTYAAC.IMTDataFilter)filter, null, null, 10, out moreRows, null);

        // Write out suggest div using first property specified, plus account id if IncludeAccountID = true
        WriteSuggestDiv(rs, props[0], field, includeAccountID);
      }
      catch(Exception)
      {
        Response.Write("No data found.");
      }
      

    }

    private void ExecuteQuery(string field, string queryTag, string keyword)
    {
      if(keyword != null && keyword.Trim() != "")
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UI\\Suggest", queryTag))
              {
                  stmt.AddParam("%%KEYWORD%%", keyword);

                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      WriteSuggestDiv(reader, field);
                  }

              }
          }
      }
    }

    private void WriteSuggestDiv(Rowset.IMTRowSet rs, string col, string field, bool includeAccountID)
    {
      int count = 0;
      
      if(rs == null) throw new ApplicationException("No data found");
      if(rs.RecordCount == 0) throw new ApplicationException("No data found");

      rs.MoveFirst();
      while(!Convert.ToBoolean(rs.EOF))
      {

        string desc = rs.get_Value(col).ToString();
        string accID = "";
        if(includeAccountID)
        {
          accID =  " (" + rs.get_Value("_AccountID").ToString() + ")";
        }
   	    // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
        // Added Encoding
        Response.Write("<div onmouseover='_highlightResult(this);' onmouseout='_unhighlightResult(this);' onmousedown='_selectResult(this);' id=s" + Utils.EncodeForHtmlAttribute(field) + count + " class='clsSuggest'>" + Utils.EncodeForHtml(desc) + accID + "</div>");
        count++;
        rs.MoveNext();
      }
    }

    private void WriteSuggestDiv(IMTDataReader reader, string field)
    {
      int count = 0;
      while(reader.Read())
      {
        string desc = reader.GetString("desc");
  	    // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
        // Added Encoding
        Response.Write("<div onmouseover='_highlightResult(this);' onmouseout='_unhighlightResult(this);' onmousedown='_selectResult(this);' id=s" + Utils.EncodeForHtmlAttribute(field) + count + " class='clsSuggest'>" + Utils.EncodeForHtml(desc) + "</div>");
        count++;
      }
    }

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}
