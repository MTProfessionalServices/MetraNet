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
      
      
      PoRenderGrid();

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
          QuoteIdentifier =  MTtbQuoteIdentifier.Text,
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
      if (!string.IsNullOrEmpty(HiddenAccountIds.Value))
        Accounts = HiddenAccountIds.Value.Split(',').Select(int.Parse).ToList();
      
      //todo read Account Id for group subscription
      //if (!string.IsNullOrEmpty(HiddenGroupId.Value))
        

      if (!string.IsNullOrEmpty(HiddenPoIdTextBox.Value))
        Pos = HiddenPoIdTextBox.Value.Split(',').Select(int.Parse).ToList();

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
      accountJavaScript = ReplaceString(accountJavaScript, "[%SELECT_ACCOUNTS%]", "SELECT_ACCOUNTS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%USERNAME%]", "USERNAME");
      accountJavaScript = ReplaceString(accountJavaScript, "[%ISGROUP%]", "ISGROUP");
      accountJavaScript = ReplaceString(accountJavaScript, "[%ACTIONS%]", "ACTIONS");
      accountJavaScript = ReplaceString(accountJavaScript, "[%GRID_TITLE%]", "GRID_TITLE");
      accountJavaScript = ReplaceString(accountJavaScript, "[%REMOVE_ACCOUNT%]", "REMOVE_ACCOUNT");

      if (!ClientScript.IsClientScriptBlockRegistered("accountGridScript"))
      {
        ClientScript.RegisterStartupScript(GetType(), "accountGridScript", accountJavaScript);
      }
    }

    protected void PoRenderGrid()
    {
      poJavaScript = ReplaceString(poJavaScript, "[%SELECT_POS%]", "SELECT_POS");
      poJavaScript = ReplaceString(poJavaScript, "[%POID%]", "POID");
      poJavaScript = ReplaceString(poJavaScript, "[%PONAME%]", "PONAME");
      poJavaScript = ReplaceString(poJavaScript, "[%ACTIONS%]", "ACTIONS");
      poJavaScript = ReplaceString(poJavaScript, "[%PO_GRID_TITLE%]", "PO_GRID_TITLE");
      poJavaScript = ReplaceString(poJavaScript, "[%REMOVE_PO%]", "REMOVE_PO");


      if (!ClientScript.IsClientScriptBlockRegistered("poGridScript"))
      {
        ClientScript.RegisterStartupScript(GetType(), "poGridScript", poJavaScript);
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
  
  var accountData = {accounts:[]};
  
   // create the data store
  var accountStore = new Ext.data.JsonStore({
    root:'accounts',
    fields: [
      {name: 'IsGroup'},
      {name: 'UserName'},
      {name: '_AccountID'},
      {name: 'AccountType'},
      {name: 'AccountStatus'},     
      {name: 'Internal#Folder'}
    ]
  });
  accountStore.loadData(accountData);
  
  var accountToolBar = new Ext.Toolbar([{iconCls:'add',id:'Add',text:'[%SELECT_ACCOUNTS%]',handler:onAccountAdd}]); 

  // create the Grid
  var accountGrid = new Ext.grid.EditorGridPanel({
    ds: accountStore,
    columns: [
      {id: '_AccountID', header: '[%USERNAME%]', width: 150, sortable: true, renderer: usernameRenderer, dataIndex: '_AccountID'},
      {header: '[%ISGROUP%]', width: 120, sortable: false, dataIndex: 'IsGroup', renderer: isGroupSubscriptionRenderer},
      {header: '[%ACTIONS%]', width: 50, sortable: false, dataIndex: '', renderer: accountActionsRenderer}
    ],
    tbar: accountToolBar, 
    stripeRows: true,
    height: 300,
    width: 350,
    iconCls: 'icon-grid',
    frame:true,
    title: '[%GRID_TITLE%]'
  });
   
  //this will be called when accts are selected
  function accountCallback(ids, records, target)
  {    
    for (var i = 0; i < records.length; i++)
    {
      var accID = records[i].data._AccountID;
      var found = accountStore.find('_AccountID', accID);
      if(found == -1)
      {
        records[i].IsGroup = 0;
        accountStore.add(records[i]);
      }
    }
    accountSelectorWin2.hide();
  }

  //add account button handler
  function onAccountAdd()
  {
    Ext.UI.ShowMultiAccountSelector('accountCallback', 'Frame');
  }

  function accountActionsRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = String.format(""<a style='cursor:hand;' id='remove_{0}' title='{1}' href='JavaScript:removeAcct({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>"", record.data._AccountID, '[%REMOVE_ACCOUNT%]'); 
    return str;
  }

  function usernameRenderer(value, meta, record, rowIndex, colIndex, store)
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
  
  function isGroupSubscriptionRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = '';
    if (record.data.AccountType == 'CorporateAccount') {
      str = '<input ' + (record.data['IsGroup']==1 ? 'checked=checked' : '') + 'onchange=""setDefaultChecked(' + rowIndex + ');"" type=radio name=""radioButton' + record.data._AccountID + '"">'
    }
    return str;
  }

  function setDefaultChecked(rowIndex) 
  { 
    for(var index = 0; index < accountStore.data.items.length; index++) 
    { 
      if (accountStore.data.items[index].data.IsGroup == 1) 
        accountStore.data.items[index].set('IsGroup', 0);    
    } 
    accountStore.data.items[rowIndex].set('IsGroup', 1);
    accountStore.commitChanges();
  }
  
  function removeAcct(accId)
  {
    var idx = accountStore.find('_AccountID', accId);
    accountStore.remove(accountStore.getAt(idx));
  }

  Ext.onReady(function(){
    accountGrid.render(Ext.get('PlaceHolderAccountsGrid'));
  });
  </script>
    ";
    #endregion

    #region JavaScript PO

    public string poJavaScript = @"
  <script type='text/javascript'>
  
  var poData = {pos:[]};
  
  // create the data store
  var poStore = new Ext.data.JsonStore({
      root:'pos',
      fields: [
          {name: 'Name'},
          {name: 'ProductOfferingId'}           
      ]
  });
  poStore.loadData(poData);
  
  var poToolBar = new Ext.Toolbar([{iconCls:'add', id: 'Add',text: '[%SELECT_POS%]',handler: onPoAdd}]); 

  // create the Grid
  var poGrid = new Ext.grid.EditorGridPanel({
      ds: poStore,
      columns: [
          {id:'ProductOfferingId',header: '[%POID%]', width: 50, sortable: true, dataIndex: 'ProductOfferingId'},
          {header:'[%PONAME%]', width: 220, sortable:true,dataIndex:'Name'},
          {header:'[%ACTIONS%]', width: 50, sortable:false,dataIndex:'',renderer: poActionsRenderer}
      ],
      tbar: poToolBar, 
      stripeRows: true,
      height: 300,
      width: 350,
      iconCls:'icon-grid',
		  frame:true,
      title:'[%PO_GRID_TITLE%]'
  });

  //this will be called when accts are selected
  function addPoCallback(ids, records, target)
  {    
    for (var i = 0; i < records.length; i++)
    {
      var ProductOfferingId = records[i].data.ProductOfferingId;
      var found = poStore.find('ProductOfferingId', ProductOfferingId);
      if(found == -1)
      {
        poStore.add(records[i]);
      }
    }    
    poSelectorWin2.hide();
  }

  //add account button handler
  function onPoAdd()
  {
    ShowMultiPoSelector('addPoCallback', 'Frame');
  }

  function poActionsRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = String.format(""<a style='cursor:hand;' id='remove_{0}' title='{1}' href='JavaScript:removePo({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>"", record.data.ProductOfferingId, '[%REMOVE_PO%]'); 
    return str;
  }
  
  function removePo(poId)
  {
    var idx = poStore.find('ProductOfferingId', poId);
    poStore.remove(poStore.getAt(idx));
  }

  Ext.onReady(function(){
    poGrid.render(Ext.get('PlaceHolderProductOfferingsGrid'));
  });
  </script>
    ";

    #endregion

    #endregion    
  }
}
