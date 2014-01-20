using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using MetraTech.Interop.MTYAAC;
using MetraTech.Security;

public partial class MetraControl_FailedTransactions_AjaxServices_CheckRerunComplete : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      // Check for MetraControl Login
      var auth = new Auth();
      auth.Initialize(UI.User.UserName, UI.User.NameSpace);
      if (!auth.HasAppLoginCapability(UI.SessionContext as IMTSessionContext, "MOM")) return;

      var s = new AjaxResponse();

      try
      {
        s.Success = FailedTransactions.CheckIsComplete(int.Parse(Request["ID"]), UI.SessionContext);
        s.Message = s.Success ? "Rerun process is complete." : "Rerun is still processing...";
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        s.Success = false;
        s.Message = ex.Detail.ErrorMessages[0];
        Logger.LogException("Error ", ex);
      }
	    catch (Exception ex)
	    {
        s.Success = false;
		    s.Message = ex.Message;
        Logger.LogException("Error ", ex);
	    }
    
      Response.Write(s.ToJson());
      Response.End();
    }
}