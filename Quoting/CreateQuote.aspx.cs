using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Web.Script.Serialization;
using System.Web.UI;
using MetraTech;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;

namespace MetraNet.Quoting
{
  public partial class CreateQuote : MTPage, ICallbackEventHandler
  {
    public List<int> Accounts { get; set; }
    public List<int> Pos { get; set; }
    public List<UDRCInstanceValue> UDRCs { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      MTdpStartDate.Text = MetraTime.Now.Date.ToString();
      MTdpEndDate.Text = MetraTime.Now.Date.AddMonths(1).ToString();

      #region render Accounts grid
      //todo Create code to render Accounts grid dynamically
      #endregion

      #region render product offerings grid
      //todo Create code to render product offerings grid dynamically
      Pos = new List<int> { 123, 543 };
      SetupPOGrid();

      #endregion
    }

    private void RenderUDRCGrid()
    {
      //todo Create code to render UDRC grid dynamically
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      //var accountsFilterValue = Request["Accounts"];
      //if (String.IsNullOrEmpty(accountsFilterValue)) return;

      //if (accountsFilterValue == "ALL")
      //  QuoteListGrid.DataSourceURL = @"../AjaxServices/LoadQuotesList.aspx?Accounts=ALL";
    }

    #region Implementation of ICallbackEventHandler

    private string _callbackResult = string.Empty;

    /// <summary>
    /// Processes a callback event that targets a control.
    /// </summary>
    /// <param name="eventArgument">A string that represents an event argument to pass to the event handler.</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
      object result;
      var serializer = new JavaScriptSerializer();
      var value = serializer.Deserialize<Dictionary<string, string>>(eventArgument);
      var action = value["action"];

      try
      {
        var entityIds = new List<int>();
        switch (action)
        {
          case "deleteOne":
            {
              entityIds.Add(int.Parse(value["entityId"], CultureInfo.InvariantCulture));
              break;
            }
          case "deleteBulk":
            {
              var ids = value["entityIds"].Split(new[] { ',' });
              entityIds.AddRange(ids.Select(s => int.Parse(s, CultureInfo.InvariantCulture)));
              break;
            }
        }
        result = DeleteQuote(entityIds);
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.Message);
        result = new { result = "error", errorMessage = ex.Message };
      }

      if (result != null)
      {
        _callbackResult = serializer.Serialize(result);
      }
    }

    /// <summary>
    /// Returns the results of a callback event that targets a control.
    /// </summary>
    /// <returns>
    /// The result of the callback.
    /// </returns>
    public string GetCallbackResult()
    {
      return _callbackResult;
    }

    private object DeleteQuote(IEnumerable<int> entityIds)
    {
      object result;
      try
      {
        using (var client = new QuotingServiceClient())
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.DeleteQuotes(entityIds);
          result = new { result = "ok" };
        }
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        result = new { result = "error", errorMessage = ex.Detail.ErrorMessages[0] };
      }
      return result;
    }
    #endregion

    protected void btnGenerateQuote_Click(object sender, EventArgs e)
    {
      try
      {
        Page.Validate();
        InvokeCreateQuote(RequestForCreateQuote);
        Response.Redirect("/MetraNet/Quoting/QuoteList.aspx", false);

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

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }

    private QuoteRequest RequestForCreateQuote { get; set; }

    private void SetQuoteRequestInput()
    {
      RequestForCreateQuote = new QuoteRequest
        {
          QuoteDescription = MTtbQuoteDescription.Text,
          EffectiveDate = Convert.ToDateTime(MTdpStartDate.Text),
          EffectiveEndDate = Convert.ToDateTime(MTdpStartDate.Text),
          ReportParameters = { PDFReport = MTcbPdf.Checked },
          Accounts = Accounts,
          ProductOfferings = Pos
        };

      //RequestForCreateQuote.SubscriptionParameters.UDRCValues = UDRCs;

    }

    public override void Validate()
    {
      SetQuoteRequestInput();

      using (var client = new QuotingServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.ValidateRequest(RequestForCreateQuote);
      }
    }


    private void InvokeCreateQuote(QuoteRequest request)
    {
      using (var client = new QuotingServiceClient())
      {
        QuoteResponse response;
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.CreateQuoteWithoutValidation(request, out response);
      }
    }

    private void SetupPOGrid()
    {
      //todo Add code to setup POGrid
      //var str = POsGridJS;

      //if (Pos != null)
      //{
      //  string gridData = Pos.Aggregate("", (current, poId) => current + String.Format("['{0}'],", poId));
      //  gridData = gridData.Trim(new char[] { ',' });

      //  // Replace values in grid JS
      //  str = str.Replace("%%DATA%%", gridData);
      //}

      //var gridJS = new LiteralControl(str);
      //PlaceHolderPOJavaScript.Controls.Add(gridJS);
    }


  }
}
