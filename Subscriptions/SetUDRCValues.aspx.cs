using System;
using System.Collections.Generic;
using System.ServiceModel;
using System.Web.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.Approvals.ChangeTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.PageNav.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

public partial class Subscriptions_SetUDRCValues : MTPage
{
    #region Dynamic JavaScript / UDRC Grids / Edit Window
    public string UDRCGridJS = @"
    <script type=""text/javascript"" src=""/Res/JavaScript/RowSelectionModelOverride.js""></script>
    <script type=""text/javascript"">
      Ext.onReady(function(){

          Ext.state.Manager.setProvider(new Ext.state.CookieProvider());

          var myData_%%ID%% = [ %%DATA%% ];
         
          // create the data store
          var store_%%ID%% = new Ext.data.SimpleStore({
              fields: [
                 {name: 'StartDate', type :'date', dateFormat:DATE_TIME_RENDERER},
                 {name: 'EndDate', type:'date', dateFormat:DATE_TIME_RENDERER},
                 {name: 'Name'},
                 {name: 'Value'}
              ]
          });
          store_%%ID%%.loadData(myData_%%ID%%);


          var dropDownValues_%%ID%% = [ %%DROP_DOWN%% ]; 
          var ddStore_%%ID%% = new Ext.data.SimpleStore({
		          fields:['name', 'value'],
		          data: dropDownValues_%%ID%%,
		          storeId:'dropDownValues_%%ID%%_store'
          });

          var valueText = TEXT_VALUE + '<br/>' + TEXT_MIN + ' %%MIN_VALUE%% <br/>' + TEXT_MAX + ' %%MAX_VALUE%%'
          var form_%%ID%% = new Ext.form.FormPanel({
            baseCls: 'x-plain',
            labelWidth: 55,
            defaultType: 'textfield',

            items: [{
                xtype: 'datefield',
                fieldLabel: TEXT_START_DATE,
                format:DATE_FORMAT,
                altFormats:DATE_TIME_FORMAT,
                value: '%%MIN_DATE%%', 
                id: 'StartDate',
                name: 'StartDate',
                allowBlank:true,
                disabled:%%FIRST_ITEM%%,
                anchor:'100%'  
            },{
                xtype: 'datefield',
                fieldLabel: TEXT_END_DATE,
                format:DATE_FORMAT,
                altFormats:DATE_TIME_FORMAT,
                value: '%%MAX_DATE%%', 
                id: 'EndDate',
                name: 'EndDate',
                allowBlank:true,
                disabled:%%FIRST_ITEM%%,
                anchor: '100%'  
            },{
                readOnly: true,
                fieldLabel: TEXT_NAME,
                id: 'Name',   
                name: 'Name',
                value: '%%NAME%%',
                allowBlank:false,
                anchor: '100%'  
            },{
                xtype: 'combo',               
                fieldLabel: valueText,
                id: 'Value',
                name: 'Value',
                allowBlank: false,
		            editable:true,
                forceSelection: false,
                typeAhead: true,
                triggerAction: 'all',
                mode: 'local',
                store: ddStore_%%ID%%,
                valueField: 'value',
                displayField: 'name',
                anchor: '100%',
	            	labelSeparator: ''           
            },{
                xtype: 'hidden',
                hideLabel: true,
                name: 'IsInteger',
                value: '%%IS_INTEGER%%'
            },{
                xtype: 'hidden',
                hideLabel: true,
                name: 'ID',
                value: '%%ID%%', 
                anchor: '100% -53'  // anchor width by percentage and height by raw adjustment
            }]
          });

          var window_%%ID%% = new Ext.Window({              
              title: TEXT_ADD + ' %%NAME%%',
              width: 400,
              height:250,
              minWidth: 100,
              minHeight: 100,
              layout: 'fit',
              plain:true,
              bodyStyle:'padding:5px;',
              buttonAlign:'center',
              items: form_%%ID%%,
              closable:false,

              buttons: [{
                  text: TEXT_OK, handler:onOK_%%ID%%
              },{
                  text: TEXT_CANCEL, handler:onCancel_%%ID%%
              }]
          });

          function onAdd_%%ID%%()
          {
            window_%%ID%%.show();
          }

          function onOK_%%ID%%()
          { 
                  // Construct regular expressions for thousand separator and decimal separator.
                  var reThouSep;
                  if (THOUSAND_SEPARATOR == '.')
                  {
                    reThouSep = new RegExp('\\.', 'g');
                  }
                  else
                  {
                    reThouSep = new RegExp(THOUSAND_SEPARATOR, 'g');
                  }
                  var reDecimalSep;
                  if (DECIMAL_SEPARATOR == '.')
                  {
                    reDecimalSep = new RegExp('\\.', 'g');
                  }
                  else
                  {
                    reDecimalSep = new RegExp(DECIMAL_SEPARATOR, 'g');
                  }

                  //code added on 07/08/08 to prevent users from entering values outside of UDRC enum range
                  var selectval;

                  // Remove any thousand separators and convert decimal separator
                  // to a period before calling isNaN().
                  var noThousSepValue = Ext.get('Value').getValue().replace(reThouSep, '');
                  var tmpValue = noThousSepValue.replace(reDecimalSep, '.');
                  if (isNaN(tmpValue))
                  { 
                    Ext.getCmp('Value').reset();
                  }
                  else
                  {
                    selectval = Number(tmpValue);
                  }

                  // MIN_VALUE and MAX_VALUE may contain commas as separators, so put in quotes.
                  var minval = '%%MIN_VALUE%%';           
                  var maxval = '%%MAX_VALUE%%';
                 
                  // Strip out thousand separators and convert decimal separators
                  // for minval and maxval before doing mathematical comparison.
                  minval = minval.replace(reThouSep, '');
                  minval = minval.replace(reDecimalSep, '.');
                  minval = Number(minval);
                  maxval = maxval.replace(reThouSep, '');
                  maxval = maxval.replace(reDecimalSep, '.');
                  maxval = Number(maxval);
                 
                  if((selectval < minval) || (selectval > maxval))
                  {                        
                    Ext.getCmp('Value').reset();                       
                  }    

                  if (form_%%ID%%.form.isValid()) {

                    var startDate  = Ext.get('StartDate').getValue();
                    var endDate = Ext.get('EndDate').getValue();
                  
                    if(new Date(startDate) > new Date(endDate))
                    {
                      Ext.MessageBox.alert(TEXT_ERROR, TEXT_INVALID_DATES);
                    }                 
                    else             
                    {  // Submit the form.

                      // Don't include thousand separators in value sent to server.
                      Ext.get('Value').dom.value = noThousSepValue;
                    
                      form_%%ID%%.getForm().submit({                
                        waitMsg:TEXT_ADDING_UDRC,
                        url:'/MetraNet/Subscriptions/SetUDRCValues.aspx?UPDATE=TRUE',
                        failure: function(form, action) {                
                          //Ext.MessageBox.alert('Error Message', 'Error processing form on server.');
                        },
                        success: function(form, action) {
                          //Ext.MessageBox.alert('Confirm', action.result.info);
                          //window.hide();
                          //dataStore.load({params:{start:0, limit:10}});
                        }
                      });    
                    } 

                  } 
                  else {
                    Ext.MessageBox.alert(TEXT_ERROR, TEXT_PLEASE_FIX);
                  } 
          }
        
          function onCancel_%%ID%%()
          {
            window_%%ID%%.hide();
          }

          var tbar_%%ID%% = new Ext.Toolbar([{text:TEXT_ADD, handler:onAdd_%%ID%%, tooltip:TEXT_ADD_VALUE,iconCls:'add'},'-']);

          // create the Grid
          var grid_%%ID%% = new Ext.grid.GridPanel({
              store: store_%%ID%%,
              columns: [
                  {header: TEXT_START_DATE, width: 75, sortable: true,renderer: Ext.util.Format.dateRenderer(DATE_FORMAT), dataIndex: 'StartDate'},
                  {header: TEXT_END_DATE, width: 75, sortable: true,renderer: Ext.util.Format.dateRenderer(DATE_FORMAT) , dataIndex: 'EndDate'},
                  {id:""Name"",header: TEXT_NAME, width: 275, sortable: true, dataIndex: 'Name'},
                  {header: TEXT_VALUE, width: 75, sortable: true, dataIndex: 'Value'}
              ],
              stripeRows: true,
              autoExpandColumn: 'Name',
              height:150,
              width:600,
              tbar:tbar_%%ID%%,
              title:'%%NAME%%'
          });

          grid_%%ID%%.render('UDRCGrid__%%ID%%');

          grid_%%ID%%.getSelectionModel().selectFirstRow();
      });
     </script>";
    #endregion

    #region Public Members
    // TODO:  It may be possible to go back to the WF to get this on an Ajax call instead of storing it in Session
    public Subscription SubscriptionInstance
    {
        get { return Session["SubscriptionInstance"] as Subscription; }
        set { Session["SubscriptionInstance"] = value; }
    }

    public List<UDRCInstance> UDRCs
    {
        get { return Session["UDRCs"] as List<UDRCInstance>; }
        set { Session["UDRCs"] = value; }
    }

    public Dictionary<string, MTTemporalList<UDRCInstanceValue>> UDRCDictionary
    {
        get { return Session["UDRCDictionary"] as Dictionary<string, MTTemporalList<UDRCInstanceValue>>; }
        set { Session["UDRCDictionary"] = value; }
    }

    public string State
    {
        get { return Session["udrc_State"] as string; }
        set { Session["udrc_State"] = value; }
    }

    public string InterfaceName
    {
        get { return Session["udrc_InterfaceName"] as string; }
        set { Session["udrc_InterfaceName"] = value; }
    }

    public string ProcessorId
    {
        get { return Session["udrc_ProcessorId"] as string; }
        set { Session["udrc_ProcessorId"] = value; }
    }
    #endregion

    #region Events
    protected void Page_Load(object sender, EventArgs e)
    {
        //TODO: Save and pass original subscription object through WorkFlow to Approval Framework

        if (!IsPostBack)
        {
            if (Request["UPDATE"] == null)
            {
                try
                {
                    SubscriptionInstance = PageNav.Data.Out_StateInitData["SubscriptionInstance"] as Subscription;
                    UDRCs = PageNav.Data.Out_StateInitData["UDRCInstances"] as List<UDRCInstance>;

                    // Place existing Subscription UDRC values into UDRCDictionary for page rendering
                    UDRCDictionary = new Dictionary<string, MTTemporalList<UDRCInstanceValue>>();
                    if (SubscriptionInstance != null)
                    {
                        if (SubscriptionInstance.UDRCValues != null)
                        {
                            foreach (KeyValuePair<string, List<UDRCInstanceValue>> kvp in SubscriptionInstance.UDRCValues)
                            {
                                MTTemporalList<UDRCInstanceValue> temporalList = new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");
                                foreach (UDRCInstanceValue udrcInstanceValue in kvp.Value)
                                {
                                    temporalList.Add(udrcInstanceValue);
                                }

                                UDRCDictionary.Add(kvp.Key, temporalList);
                            }
                        }
                    }

                    // I need to store these values so we can fire WF events after json request and redirect
                    State = PageNav.State;
                    InterfaceName = PageNav.InterfaceName;
                    ProcessorId = PageNav.ProcessorId.ToString();
                }
                catch (Exception exp)
                {
                    Logger.LogException("Error in UDRC load", exp);
                }
            }

            else if (Request["UPDATE"].ToUpper() == "TRUE")
            {
                try
                {
                    // Handle Ajax update (Add UDRC Value)
                    string id = Request["ID"];
                    //string name = Request["Name"];

                    DateTime? start;
                    if (string.IsNullOrEmpty(Request["StartDate"]))
                    {
                        start = SubscriptionInstance.SubscriptionSpan.StartDate ?? MetraTech.MetraTime.Min;
                    }
                    else
                    {
                        start = DateTime.Parse(Request["StartDate"]);
                    }

                    DateTime? end;
                    if (string.IsNullOrEmpty(Request["EndDate"]))
                    {
                        end = SubscriptionInstance.SubscriptionSpan.EndDate ?? MetraTech.MetraTime.Max;
                    }
                    else
                    {
                        end = DateTime.Parse(Request["EndDate"]);
                    }

                    bool isInteger = bool.Parse(Request["IsInteger"]);
                    decimal value;
                    if (isInteger)
                    {
                        value = (int)decimal.Parse(Request["Value"]);
                    }
                    else
                    {
                        value = decimal.Parse(Request["Value"]);
                    }

                    // Add new item to UDRC list
                    UDRCInstanceValue addValue = new UDRCInstanceValue();
                    addValue.Value = value;
                    addValue.StartDate = (DateTime)start;
                    addValue.EndDate = (DateTime)end;
                    addValue.UDRC_Id = int.Parse(id);
                    if (!UDRCDictionary.ContainsKey(id))
                    {
                        UDRCDictionary.Add(id, new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate"));
                    }
                    UDRCDictionary[id].Add(addValue);
                }
                catch (Exception ex)
                {
                    Logger.LogException("Error in UDRC load", ex);
                }

                // Refresh page
                Response.Write(String.Format("document.location.href = '/MetraNet/Subscriptions/SetUDRCValues.aspx?UPDATE=POSTBACK_FOR_REFRESH&State={0}&InterfaceName={1}&ProcessorId={2}'", State, InterfaceName, ProcessorId)); // OK - Refresh        
                Response.End();
                return;
            }
        }

        try
        {
            RenderUDRCGrids();
        }
        catch (Exception exp)
        {
            Logger.LogException("Error in UDRC load", exp);
        }

    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            var sub = SubscriptionInstance;
            
            // Update Subscription Instance with UDRC values in UDRCDictionary
            sub.UDRCValues = new Dictionary<string, List<UDRCInstanceValue>>();
            foreach (var kvp in UDRCDictionary)
            {
                sub.UDRCValues.Add(kvp.Key, kvp.Value.Items);
            }

            var isNewSubscription = sub.SubscriptionId == null;
            var changeTypeName = isNewSubscription
                                   ? SubscriptionChangeType.AddSubscriptionChangeTypeName
                                   : SubscriptionChangeType.UpdateSubscriptionChangeTypeName;
            var isApprovalsEnabled = IsApprovalsEnabled(changeTypeName);

            var update = new SubscriptionsEvents_OKSetUDRCValues_Client
            {
                In_SubscriptionInstance = sub,
                In_AccountId = new AccountIdentifier(UI.User.AccountId),
                In_IsApprovalEnabled = isApprovalsEnabled
            };
            
            PageNav.Execute(update);

            if (isApprovalsEnabled)
            {
              Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ChangeSubmittedConfirmation.aspx", false);
            }
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        SubscriptionsEvents_CancelSubscriptions_Client cancel = new SubscriptionsEvents_CancelSubscriptions_Client();
        cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        PageNav.Execute(cancel);
    }

    protected void btnBack_Click(object sender, EventArgs e)
    {
        SubscriptionsEvents_BackSetUDRCValues_Client cancel = new SubscriptionsEvents_BackSetUDRCValues_Client();
        cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
        PageNav.Execute(cancel);
    }
    #endregion

    #region Render UDRC Grids
    private void RenderUDRCGrids()
    {
        // Render a grid for each UDRC type in UDRC Instances
        foreach (UDRCInstance udrcType in UDRCs)
        {
            string str = UDRCGridJS;

            // Fill our grid with any existing data
            MTTemporalList<UDRCInstanceValue> values = new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");
            if (UDRCDictionary != null)
            {
                if (UDRCDictionary.ContainsKey(udrcType.ID.ToString()))
                {
                    values = UDRCDictionary[udrcType.ID.ToString()];
                    str = str.Replace("%%FIRST_ITEM%%", "false");
                }
                else
                {
                    str = str.Replace("%%FIRST_ITEM%%", "true");
                    // CR15605
                    // Here we are just adding a udrc value of 0 from infinity to infinity to make
                    // the temporal list look better if there are no items.
                    // But then we decided just forcing the first add to be from infinity to infinity was better
                    /* MTTemporalList<UDRCInstanceValue> tmpList = new MTTemporalList<UDRCInstanceValue>("StartDate", "EndDate");
                     UDRCInstanceValue udrcInstanceValue = new UDRCInstanceValue();
                     udrcInstanceValue.StartDate = MetraTech.MetraTime.Min;
                     udrcInstanceValue.EndDate = MetraTech.MetraTime.Max;
                     udrcInstanceValue.Value = 0;
                     udrcInstanceValue.UDRC_Id = int.Parse(udrcType.ID.ToString());
                     tmpList.Add(udrcInstanceValue);
                     UDRCDictionary.Add(udrcType.ID.ToString(), tmpList);
                     values = UDRCDictionary[udrcType.ID.ToString()];*/
                }
            }
            string gridData = "";
            foreach (UDRCInstanceValue value in values.Items)
            {
                // CORE-4306 Put single quotes around the format for value.Value so that JavaScript treats it
                // as a string instead of a number, which would get truncated to the size of a float.
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //gridData += String.Format("['{0}','{1}','{2}','{3}'],", value.StartDate, value.EndDate, udrcType.DisplayName.Replace("'", "\\'"), value.Value);
                gridData += String.Format("['{0}','{1}','{2}','{3}'],", value.StartDate, value.EndDate, udrcType.DisplayName.EncodeForJavaScript(), value.Value);
            }
            gridData = gridData.Trim(new char[] { ',' });


            string ddData = "";
            if (udrcType.UnitValueEnumeration != null)
            {
                foreach (decimal ddVal in udrcType.UnitValueEnumeration)
                {
                    if (udrcType.IsIntegerValue)
                    {
                        ddData += String.Format("['{0}','{0}'],", (int)ddVal);
                    }
                    else
                    {
                        ddData += String.Format("['{0}','{0}'],", ddVal);
                    }
                }
                ddData = ddData.Trim(new char[] { ',' });
            }


            // Replace values in grid JS
            str = str.Replace("%%DATA%%", gridData);
            str = str.Replace("%%ID%%", udrcType.ID.ToString());
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //str = str.Replace("%%NAME%%", udrcType.DisplayName.Replace("'", "\\'"));
            str = str.Replace("%%NAME%%", udrcType.DisplayName.EncodeForJavaScript());
            str = str.Replace("%%MIN_VALUE%%",
                    udrcType.MinValue.ToString(Constants.NUMERIC_FORMAT_STRING_DECIMAL_NO_TRAILING_ZEROS));
            str = str.Replace("%%MAX_VALUE%%",
                    udrcType.MaxValue.ToString(Constants.NUMERIC_FORMAT_STRING_DECIMAL_NO_TRAILING_ZEROS));
            str = str.Replace("%%DROP_DOWN%%", ddData);
            str = str.Replace("%%IS_INTEGER%%", udrcType.IsIntegerValue.ToString().ToLower());
            str = str.Replace("%%MIN_DATE%%", "");
            str = str.Replace("%%MAX_DATE%%", "");

            // Add Grid container and JS to page
            string udrcDiv = String.Format(@"<div id=""UDRCGrid__{0}"" style=""padding:10px;""></div>", udrcType.ID);
            LiteralControl grid = new LiteralControl(udrcDiv);
            PlaceHolderUDRCs.Controls.Add(grid);

            LiteralControl gridJS = new LiteralControl(str);
            PlaceHolderJavaScript.Controls.Add(gridJS);
        }
    }
    #endregion
    
    #region Private Methods
    
    private bool IsApprovalsEnabled(string changeType)
    {
        bool isEnabled;

      var client = new ApprovalManagementServiceClient();
      try
        {
            SetCredantional(client.ClientCredentials);
            client.ApprovalEnabledForChangeType(changeType, out isEnabled);
        }
      finally
      {
        if (client.State == CommunicationState.Faulted)
          client.Abort();
        else
          client.Close();
      }

        return isEnabled;
    }

    private void SetCredantional(System.ServiceModel.Description.ClientCredentials clientCredentials)
    {
        if (clientCredentials == null)
            throw new InvalidOperationException("Client credentials is null");

        clientCredentials.UserName.UserName = UI.User.UserName;
        clientCredentials.UserName.Password = UI.User.SessionPassword;
    }

    #endregion
}