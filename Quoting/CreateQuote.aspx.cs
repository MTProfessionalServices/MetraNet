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
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Common;

namespace MetraNet.Quoting
{
  public partial class CreateQuote : MTPage, ICallbackEventHandler
  {
    public List<int> Accounts { get; set; }
    public List<int> Pos { get; set; }
    public List<UDRCInstance> UDRCs
    {
      get { return Session["UDRCs"] as List<UDRCInstance>; }
      set { Session["UDRCs"] = value; }
    }
    public Subscription SubscriptionInstance
    {
      get { return Session["SubscriptionInstance"] as Subscription; }
      set { Session["SubscriptionInstance"] = value; }
    }
    public Dictionary<string, MTTemporalList<UDRCInstanceValue>> UDRCDictionary
    {
      get { return Session["UDRCDictionary"] as Dictionary<string, MTTemporalList<UDRCInstanceValue>>; }
      set { Session["UDRCDictionary"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
      var cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
      var callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
      Page.ClientScript.RegisterClientScriptBlock(GetType(), "CallServer", callbackScript, true);

      MTdpStartDate.Text = MetraTime.Now.Date.ToString();
      MTdpEndDate.Text = MetraTime.Now.Date.AddMonths(1).ToString();

      #region render Accounts grid

      AccountRenderGrid();
      
      #endregion

      #region render product offerings grid
      //todo Create code to render product offerings grid dynamically
      Pos = new List<int> { 123, 543 };
      SetupPOGrid();

      #endregion
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
        Response.Redirect(@"/MetraNet/Quoting/QuoteList.aspx", false);

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

    #region Render Grids   
    protected void AccountRenderGrid()
    {
      accountJavaScript = ReplaceString(accountJavaScript, "[%CURRENT_NODE%]", "CURRENT_NODE");
      accountJavaScript = ReplaceString(accountJavaScript, "[%DIRECT_DESCENDANTS%]", "DIRECT_DESCENDANTS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%ALL_DESCENDANTS%]", "ALL_DESCENDANTS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%SELECT_ACCOUNTS%]", "SELECT_ACCOUNTS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%USERNAME%]", "USERNAME");
      accountJavaScript = ReplaceString(accountJavaScript, "[%SELECTION%]", "SELECTION");
      accountJavaScript = ReplaceString(accountJavaScript, "[%ACTIONS%]", "ACTIONS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%GRID_TITLE%]", "GRID_TITLE");
      accountJavaScript = ReplaceString(accountJavaScript, "[%REMOVE_ACCOUNT%]", "REMOVE_ACCOUNT");

      if (!ClientScript.IsClientScriptBlockRegistered("accountGridScript"))
      {
        ClientScript.RegisterStartupScript(GetType(), "accountGridScript", accountJavaScript);
      }
    }

    private string ReplaceString(string source, string key, string value)
    {
      return source.Replace(key, ((string)GetLocalResourceObject(value)).EncodeForJavaScript());
    }
    #endregion

    #region Dynamic JavaScript / UDRC Grid / Account Grid / Edit Window

    #region JavaScript Account

    public string accountJavaScript = @"
  <script type='text/javascript'>
  
  var myData = {accounts:[]};
  
  var selectionScopeValues = [[0, '[%CURRENT_NODE%]'],[1, '[%DIRECT_DESCENDANTS%]'],[2, '[%ALL_DESCENDANTS%]']] ;
  
   // create the data store
    var store = new Ext.data.JsonStore({
        root:'accounts',
        fields: [
           {name: 'UserName'},
           {name: '_AccountID'},
           {name: 'AccountType'},
           {name: 'AccountStatus'},     
           {name: 'Internal#Folder'}, 
           {name: 'SelectionScope'}                   
        ]
    });
    store.loadData(myData);
  
    var toolBar = new Ext.Toolbar([{iconCls:'add',id:'Add',text:'[%SELECT_ACCOUNTS%]',handler:onAdd}]); 

    // create the Grid
    var grid = new Ext.grid.EditorGridPanel({
        ds: store,
        columns: [
            {id:'_AccountID',header: '[%USERNAME%]', width: 160, sortable: true, renderer:UsernameRenderer, dataIndex: '_AccountID'},
            {header:'[%SELECTION%]',sortable:false,dataIndex:'SelectionScope',renderer:selectionScopeRenderer},
            {header:'[%ACTIONS%]',sortable:false,dataIndex:'',renderer:actionsRenderer}
        ],
        tbar: toolBar, 
        stripeRows: true,
        height:350,
        width:400,
        iconCls:'icon-grid',
		    frame:true,
        title:'[%GRID_TITLE%]'
    });
   
    function processClick(myGrid, rowIndex,columnIndex, eventObj)
    {
      var columnID = myGrid.getColumnModel().getColumnId(columnIndex);
      if( myGrid.getColumnModel().getColumnById(columnID).dataIndex != 'SelectionScope')
      {
        return;
      }
    
      var record = grid.getStore().getAt(rowIndex);
      
      //skip for non-folders
      if (!record.data['Internal#Folder'])
      {
        return;
      }
      
      if (record != null)
      {
        record.SelectionScope = (record.SelectionScope + 1) % 3;
      }
      
      var cell = myGrid.getView().getCell(rowIndex, columnIndex);
      
      cell.innerHTML = ""<a href='#'><img border='0' src='/Res/Images/toggle.gif'>&nbsp;"" +  selectionScopeValues[record.SelectionScope][1] + ""</a>"";

    }

    grid.on('celldblclick',function(myGrid, rowIndex, columnIndex, eventObj)
    {
      processClick(myGrid, rowIndex,columnIndex, eventObj)
    });
    
    grid.on('cellclick',function(myGrid, rowIndex, columnIndex, eventObj)
    {
      processClick(myGrid, rowIndex,columnIndex, eventObj)
    });

  //this will be called when accts are selected
  function addCallback(ids, records, target)
  {    
    for (var i = 0; i < records.length; i++)
    {
      var accID = records[i].data._AccountID;
      var found = store.find('_AccountID', accID);
      if(found == -1)
      {
        records[i].SelectionScope = 0; //assume 0=current node, 1=direct descendants, 2=all descendants
        store.add(records[i]);
      }
    }
    
    accountSelectorWin2.hide();
  }

  //add account button handler
  function onAdd()
  {
    Ext.UI.ShowMultiAccountSelector('addCallback', 'Frame');
  }

  function actionsRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = String.format(""<a style='cursor:hand;' id='remove_{0}' title='{1}' href='JavaScript:removeAcct({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>"", record.data._AccountID, '[%REMOVE_ACCOUNT%]'); 
    return str;
  }

  function selectionScopeRenderer(value, meta, record, rowIndex, colIndex, store)
  {   
    //if not a folder, return empty string
    if (!record.data['Internal#Folder'])
    {
      return '';
    }
    
    var scope = record.SelectionScope; 
    var displayHTML = ""<a href='#'><img border='0' src='/Res/Images/toggle.gif'>&nbsp;"" + selectionScopeValues[scope][1] + ""</a>"";
    
    return displayHTML;
  } 
  
  function UsernameRenderer(value, meta, record, rowIndex, colIndex, store)
  {
  
    var folder = 'False' ;
    if (record.data['Internal#Folder'] == true) 
    { 
        folder = 'True' ;
    } 

    var str = String.format(""<span title='{2} ({1}) - {0}'><img src='/ImageHandler/images/Account/{0}/account.gif?State={3}&Folder={4}'> {2} ({1})</span>"",
                                  record.data.AccountType,
                                  record.data._AccountID,
                                  record.data.UserName,
                                  record.data.AccountStatus,
                                  folder);
    return str;
  }
  
  function removeAcct(accID)
  {
    var idx = store.find('_AccountID', accID);
    store.remove(store.getAt(idx));
  }

  Ext.onReady(function(){
    grid.render(Ext.get('PlaceHolderAccountsGrid'));
  });
  </script>
    ";

    #endregion

    #endregion    
  }
}
