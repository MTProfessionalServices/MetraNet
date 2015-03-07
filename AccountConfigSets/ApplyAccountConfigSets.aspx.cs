using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;

namespace MetraNet.AccountConfigSets
{
  public partial class ApplyAccountConfigSets : MTPage
  {
    protected string AccountsFilterValue;
    protected void Page_Load(object sender, EventArgs e)
    {
      if(!IsPostBack)
        ParseRequest(); 
    }

    private void ParseRequest()
    {
      var mode = Request["mode"];
      switch (mode)
      {
        case "ASK":
          var message = GetLocalResourceObject("TEXT_QUESTION");
          if (message != null)
            MTtaText.Text = message.ToString();

          message = GetLocalResourceObject("TEXT_QUESTION_HEADER");
          if (message != null)
            PanelWithMessage.Text = message.ToString();          

          MTbtnContinue.Visible = true;
          MTbtnCancel.Visible = true;
          MTbtnClose.Visible = false;                    
          break;
        case "RUN":
          var header = GetLocalResourceObject("TEXT_RESULTS_HEADER");
          if (header != null)
            PanelWithMessage.Text = header.ToString();

          RunApplyAccountConfigSets();

          MTbtnContinue.Visible = false;
          MTbtnCancel.Visible = false;
          MTbtnClose.Visible = true;                    
          break;
        default:
          var redirectPath = string.Format(@"/MetraNet/Account/AccountLandingPage.aspx");
          Response.Redirect(redirectPath, false);
          break;
      }
    }

    protected void btnClose_Click(object sender, EventArgs e)
    {
      var redirectPath = string.Format(@"/MetraNet/Account/AccountLandingPage.aspx");
      Response.Redirect(redirectPath, false);
    }

    protected void btnContinue_Click(object sender, EventArgs e)
    {
      var redirectPath = string.Format(@"/MetraNet/AccountConfigSets/ApplyAccountConfigSets.aspx?mode=RUN");
      Response.Redirect(redirectPath, false);
    }

    protected void RunApplyAccountConfigSets()
    {
      try
      {        
        var res = InvokeAddAccountConfigSet();
        MTtaText.Text = String.Join("<br>", res);        
      }
      catch (MASBasicException exp)
      {
        SetError(exp.Message);
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
      }
    }

    private List<string> InvokeAddAccountConfigSet()
    {
      using (var client = new AccountConfigurationSetServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        var accountId = Convert.ToInt32(UI.Subscriber.SelectedAccount._AccountID);
        List<string> logMessage;
        client.ApplyAccountConfigSets(accountId, out logMessage);
        return logMessage;
      }
    }
  }
}
