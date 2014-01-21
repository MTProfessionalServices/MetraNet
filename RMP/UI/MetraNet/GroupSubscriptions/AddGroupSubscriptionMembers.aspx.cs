using System;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.PageNav.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.Approvals;
using System.Collections.Generic;
using MetraTech.Core.Services.ClientProxies;

public partial class GroupSubscriptions_AddGroupSubscriptionMembers : MTPage
{
  //Approval Framework Code Starts Here 
  public int? bGroupSubAddMemberHierarchiesApprovalsEnabled
  {
    get { return ViewState["bGroupSubAddMemberHierarchiesApprovalsEnabled"] as int?; }
    set { ViewState["bGroupSubAddMemberHierarchiesApprovalsEnabled"] = value; }
  }

  //so we can read it any time in the session

  public bool bAllowMoreThanOnePendingChange { get; set; }
  public bool bGroupSubHasPendingChange { get; set; }
  public string strChangeType { get; set; }
  //Approval Framework Code Ends Here 


  #region JavaScript

  public string JAVASCRIPT = @"
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
        //renderTo:Ext.get('MembersDiv'),
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
    grid.render(Ext.get('MembersDiv'));
  });
  </script>
    ";

  #endregion

  public GroupSubscription CurrentGroupSubscription
  {
    get { return ViewState["CurrentGroupSubscription"] as GroupSubscription; }
    set { ViewState["CurrentGroupSubscription"] = value; }
  }


  protected void Page_Load(object sender, EventArgs e)
  {
    FixJavascript();
    if (!ClientScript.IsClientScriptBlockRegistered("gridScript"))
    {
      ClientScript.RegisterStartupScript(this.GetType(), "gridScript", JAVASCRIPT);
    }

    CurrentGroupSubscription = PageNav.Data.Out_StateInitData["CurrentGroupSubscription"] as GroupSubscription;

    if (CurrentGroupSubscription.Name != "")
    {
      // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
      // Added JavaScript encoding
      //MTTitle1.Text = Server.HtmlEncode(String.Format((string)GetLocalResourceObject("MTTitle1.Text"), CurrentGroupSubscription.Name.Replace("'", "\\'")));
      MTTitle1.Text =
        String.Format((string) GetLocalResourceObject("MTTitle1.Text"),
                      CurrentGroupSubscription.Name.EncodeForJavaScript()).EncodeForHtml();
      MTPanel1.Text = GetLocalResourceObject("lblAddGroupSubMembersTitleResource1").ToString();

      if (!Page.IsPostBack)
      {
        MTEffecStartDatePicker.Text = CurrentGroupSubscription.SubscriptionSpan.StartDate.Value.ToShortDateString();
        MTEffecEndDatePicker.Text = CurrentGroupSubscription.SubscriptionSpan.EndDate.Value.ToShortDateString();
      }
    }

    string gsid = "";
    gsid = CurrentGroupSubscription.GroupId.ToString();
    CheckPendingChanges(gsid);

    if (!this.MTDataBinder1.DataBind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }

  }

  protected void FixJavascript()
  {
    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
    // Added JavaScript encoding
    /*
    JAVASCRIPT = JAVASCRIPT.Replace("[%CURRENT_NODE%]", GetLocalResourceObject("CURRENT_NODE").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%DIRECT_DESCENDANTS%]", GetLocalResourceObject("DIRECT_DESCENDANTS").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%ALL_DESCENDANTS%]", GetLocalResourceObject("ALL_DESCENDANTS").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%SELECT_ACCOUNTS%]", GetLocalResourceObject("SELECT_ACCOUNTS").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%USERNAME%]", GetLocalResourceObject("USERNAME").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%SELECTION%]", GetLocalResourceObject("SELECTION").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%ACTIONS%]", GetLocalResourceObject("ACTIONS").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%GRID_TITLE%]", GetLocalResourceObject("GRID_TITLE").ToString().Replace("'", "\\'"));
    JAVASCRIPT = JAVASCRIPT.Replace("[%REMOVE_ACCOUNT%]", GetLocalResourceObject("REMOVE_ACCOUNT").ToString().Replace("'", "\\'"));
    */
    JAVASCRIPT = JAVASCRIPT.Replace("[%CURRENT_NODE%]",
                                    GetLocalResourceObject("CURRENT_NODE").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%DIRECT_DESCENDANTS%]",
                                    GetLocalResourceObject("DIRECT_DESCENDANTS").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%ALL_DESCENDANTS%]",
                                    GetLocalResourceObject("ALL_DESCENDANTS").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%SELECT_ACCOUNTS%]",
                                    GetLocalResourceObject("SELECT_ACCOUNTS").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%USERNAME%]", GetLocalResourceObject("USERNAME").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%SELECTION%]",
                                    GetLocalResourceObject("SELECTION").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%ACTIONS%]", GetLocalResourceObject("ACTIONS").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%GRID_TITLE%]",
                                    GetLocalResourceObject("GRID_TITLE").ToString().EncodeForJavaScript());
    JAVASCRIPT = JAVASCRIPT.Replace("[%REMOVE_ACCOUNT%]",
                                    GetLocalResourceObject("REMOVE_ACCOUNT").ToString().EncodeForJavaScript());

  }

  protected void CheckPendingChanges(string groupsubid)
  {
    ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

    strChangeType = "GroupSubscription.AddMemberHierarchies";
    bGroupSubHasPendingChange = false;
    bGroupSubAddMemberHierarchiesApprovalsEnabled = 0;

    MTList<ChangeTypeConfiguration> mactc = new MTList<ChangeTypeConfiguration>();

    client.RetrieveChangeTypeConfiguration(strChangeType, ref mactc);

    if (mactc.Items[0].Enabled)
    {
      bGroupSubAddMemberHierarchiesApprovalsEnabled = 1; // mactc.Items[0].Enabled; 
    }

    if (bGroupSubAddMemberHierarchiesApprovalsEnabled == 1)
    {
      bAllowMoreThanOnePendingChange = mactc.Items[0].AllowMoreThanOnePendingChange;

      List<int> pendingchangeids;
      client.GetPendingChangeIdsForItem(strChangeType, groupsubid, out pendingchangeids);

      if (pendingchangeids.Count != 0)
      {
        bGroupSubHasPendingChange = true;
      }

      if (!bAllowMoreThanOnePendingChange)
      {
        if (bGroupSubHasPendingChange)
        {
          SetError(
            "This Group Subscription has Add Membership Hierarchy type pending change. This type of change does not allow more than one pending changes.");
          this.Logger.LogError(
            string.Format(
              "The item {0} already has a pending change of the type {1} and this type of change does not allow more than one pending change.",
              groupsubid, strChangeType));
        }

      }

      if (bGroupSubHasPendingChange)
      {
        string approvalframeworkmanagementurl =
          "<a href='/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING'</a>";
        string strPendingChangeWarning = "This Group Subscription has Add Membership Hierarchy type pending change." +
                                         approvalframeworkmanagementurl + " Click here to view pending changes.";

        divLblMessage.Visible = true;
        lblMessage.Text = strPendingChangeWarning;
      }
    }
    //Approval Framework Code Ends Here 

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    try
    {
      Page.Validate();
      string ses = "";
      ses = HiddenAcctIdTextBox.Value;
      MTDataBinder1.Unbind();

      //Moving this to page load event
      //string gsid = "";
      //gsid = CurrentGroupSubscription.GroupId.ToString();
      //CheckPendingChanges(gsid);

      GroupSubscriptionMember gsm = new GroupSubscriptionMember();
      gsm.MembershipSpan.StartDate = Convert.ToDateTime(this.MTEffecStartDatePicker.Text);
      gsm.MembershipSpan.EndDate = Convert.ToDateTime(this.MTEffecEndDatePicker.Text);

      GroupSubscriptionsEvents_OKAddGroupSubscriptionMembers_Client add =
        new GroupSubscriptionsEvents_OKAddGroupSubscriptionMembers_Client();

      add.In_AccountId = new AccountIdentifier(UI.User.AccountId);
      add.In_GroupSubscriptionMember = gsm;
      add.In_MemberIdColl = HiddenAcctIdTextBox.Value;

      //Approval Framework related code starts here
      if (bGroupSubAddMemberHierarchiesApprovalsEnabled == 1)
      {
        add.In_IsApprovalEnabled = true;
      }
      else
      {
        add.In_IsApprovalEnabled = false;
      }
      //Approval Framework related code ends here


      PageNav.Execute(add);

      // Show the change submitted confirmation page if this change is submitted to the approval framework
      if (bGroupSubAddMemberHierarchiesApprovalsEnabled == 1)
      {
        Session["RedirectLoc"] = Response.RedirectLocation;
        Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
      }


    }
    catch (Exception ex)
    {
      string Message = GetLocalResourceObject("ErrorAddGroupSubMember").ToString();
      SetError(Message);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    GroupSubscriptionsEvents_CancelAddGroupSubscriptionMembers_Client cancel =
      new GroupSubscriptionsEvents_CancelAddGroupSubscriptionMembers_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    PageNav.Execute(cancel);
  }

  protected void btnAdd_Click(object sender, EventArgs e)
  {

  }

  protected void btnRemove_Click(object sender, EventArgs e)
  {

  }
}