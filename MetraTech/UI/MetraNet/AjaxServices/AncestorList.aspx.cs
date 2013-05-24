using System;
using MetraTech.UI.Common;
using MetraTech;
using MTYAAC = MetraTech.Interop.MTYAAC;
using Rowset = MetraTech.Interop.Rowset;
using MetraTech.UI.Tools;
using MetraTech.Accounts.Type;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTProductCatalog;

public partial class AjaxServices_AncestorList : MTPage
{
  private const string EMPTY_JSON = "{\"TotalRows\":\"0\",\"records\":[]}";

  protected bool IsVisibleInHierarchy(int id)
  {
      AccountTypeManager accountTypeManager = new AccountTypeManager();
      MTYAAC.MTYAAC yaac = new MTYAAC.MTYAAC();
      yaac.InitAsSecuredResource(id,
                                 (MetraTech.Interop.MTYAAC.IMTSessionContext) UI.SessionContext,
                                 ApplicationTime);
      IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext) UI.SessionContext,
                                                                     yaac.AccountTypeID);

      //yaac.LoginName

      return accType.IsVisibleInHierarchy;
  }

  protected void Page_Load(object sender, EventArgs e)
  {
      int id = 1;
      if (!String.IsNullOrEmpty(Request["id"]))
      {
        id = int.Parse(Request["id"]);
      }

      if (id == 1)
      {
        Response.Write(EMPTY_JSON);
        Response.End();
        return;
      }

      if (!IsVisibleInHierarchy(id))
      {
        Response.Write("{VisibleInHierarchy:false,\"TotalRows\":\"0\",\"records\":[]}");
        Response.End();
        return;
      }

      MTYAAC.IMTAccountCatalog accountCatalog = new MTYAAC.MTAccountCatalog();
      MTYAAC.IMTSessionContext sessionContext = (MTYAAC.IMTSessionContext) UI.User.SessionContext;
      accountCatalog.Init(sessionContext);
      MTYAAC.MTYAAC yaac = accountCatalog.GetAccount(id, ApplicationTime);
      MTYAAC.IMTSQLRowset rs = yaac.GetAncestorMgr().HierarchySlice(id, ApplicationTime).GetAncestorList();
    
      if ((rs == null) || (rs.RecordCount == 0))
      {
        Response.Write(EMPTY_JSON);
        Response.End();
        return;
      }

      //id_ancestor, nm_login
      string json = Converter.GetRowsetAsJson((Rowset.MTSQLRowset) rs, 0, 1000);
      Response.Write("{" + json + "}");
      Response.End();
    }

}