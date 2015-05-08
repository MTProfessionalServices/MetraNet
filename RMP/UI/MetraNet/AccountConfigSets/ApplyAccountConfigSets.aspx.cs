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
          var questionMessage = GetLocalResourceObject("TEXT_QUESTION");
          if (questionMessage != null)
            MTquestionText.Text = questionMessage.ToString();

          var analyzeStream = RunAnalyzeAccountConfigSetsImpact();

          MTapiOutputText.Text = String.Join("<br>", analyzeStream);

          MTbtnContinue.Visible = (analyzeStream.Count > 1);
          if (analyzeStream.Count > 1)
          {
            var analyzeHeader = GetLocalResourceObject("TEXT_ANALYSE_HEADER");
            if (analyzeHeader != null)
              PanelWithMessage.Text = analyzeHeader.ToString();
          }
          PanelWithQuestion.Visible = MTbtnContinue.Visible;
          MTbtnCancel.Visible = true;
          MTbtnClose.Visible = false;
          break;
        case "RUN":
          var applyHeader = GetLocalResourceObject("TEXT_RESULTS_HEADER");
          if (applyHeader != null)
            PanelWithMessage.Text = applyHeader.ToString();

          PanelWithQuestion.Visible = false;

          var applyStream = RunApplyAccountConfigSets();

          MTapiOutputText.Text = String.Join("<br>", applyStream);  

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

    protected List<string> RunApplyAccountConfigSets()
    {
      try
      {        
        return InvokeAddAccountConfigSet();      
      }
      catch (MASBasicException exp)
      {
        SetError(exp.Message);
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
      }
      return new List<string>();
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

    protected List<string> RunAnalyzeAccountConfigSetsImpact()
    {
      try
      {
        return InvokeAnalyzeAccountConfigSetsImpact();
      }
      catch (MASBasicException exp)
      {
        SetError(exp.Message);
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
      }
      return new List<string>();
    }

    private List<string> InvokeAnalyzeAccountConfigSetsImpact()
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
        client.AnalyzeApplyAccountConfigSetsImpact(accountId, out logMessage);
        return logMessage;
      }
    }
  }
}
