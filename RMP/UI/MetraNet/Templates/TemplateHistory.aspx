<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_TemplateHistory" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="TemplateHistory.aspx.cs" Culture="auto" UICulture="auto"%>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Template History" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="AccountTemplateSession" ExtensionName="Account" ></MT:MTFilterGrid>
   <style type="text/css">
     .x-progress-bar-red {
        height:18px;
        float:left;
        width:0;
        background:#880000 url( /Res/Ext/resources/images/default/progress/progress-bg-red.gif ) repeat-x left center;
        border-top:1px solid #D1E4FD;
        border-bottom:1px solid #7FA9E4;
        border-right:1px solid #7FA9E4;
    }
   </style>
 
 
  <script type="text/javascript">

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Progress'), progressRenderer); 
      cm.setRenderer(cm.getIndexById('SubmissionDate'), LongDateRenderer); 
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
    progressRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""; 
      var style = "";
      
      var NumAccounts = record.data.NumAccounts;
      var NumAccountsCompleted = record.data.NumAccountsCompleted;
      var NumAccountErrors = record.data.NumAccountErrors;

      var NumTemplates = record.json.NumTemplates;
      var NumTemplatesApplied = record.json.NumTemplatesApplied;

      var NumSubscriptions = record.data.NumSubscriptions;
      var NumSubscriptionsCompleted = record.data.NumSubscriptionsCompleted;
      var NumSubscriptionErrors = record.data.NumSubscriptionErrors;
      
      var percent = 0;
      
      /*
      if((NumAccounts + NumSubscriptions) > 0)
      {
        percent = Math.round(((NumAccountsCompleted + NumSubscriptionsCompleted) / (NumAccounts + NumSubscriptions)) * 100);
      }
      else
      {
        // No accounts or subscriptions to update, so just set the percent complete to 100 since there is no work to do. Otherwise, percent complete gets stuck at 0.
        percent = 100;
      }
      */
      if (NumTemplates > 0)
      {
        percent = Math.floor((NumTemplatesApplied / NumTemplates) * 100);
      }
      else
      {
        // No templates to apply, so just set the percent complete to 100 since there is no work to do. Otherwise, percent complete gets stuck at 0.
        percent = 100;
      }

      progressText = percent + "%";
      
      var numErrors = NumAccountErrors + NumSubscriptionErrors;
      if(numErrors > 0)
      {
        style = "-red";
      }
   		var text_front;
	  	var text_back;
     
      if(record.data.Status == 3)
      {
        style = "-red";
        if (percent == 0)
        {
         percent = 100;
  		 text_front = (percent <55)?'':"0%";
		 text_back = (percent >=55)?'':"0%";	
        }
        else
        {
 		  text_front = (percent <55)?'':percent + "%";
		  text_back = (percent >=55)?'':percent + "%";	
       }
     }
     else
     {
 		  text_front = (percent <55)?'':percent + "%";
		  text_back = (percent >=55)?'':percent + "%";	
     }

		
		  
		  var text_tooltip = String.format(TEXT_HISTORY_TOOLTIP, 
		                                   NumAccounts, NumAccountsCompleted, NumAccountErrors,
		                                   NumSubscriptions, NumSubscriptionsCompleted, NumSubscriptionErrors);
		  
      str = String.format('<div ext:qtip="{4}" class="x-progress-wrap"><div ext:qtip="{4}" class="x-progress-inner"><div ext:qtip="{4}" class="x-progress-bar{0}" style="width:{1}%;"><div ext:qtip="{4}" class="x-progress-text" style="width:100%;">{2}</div></div><div ext:qtip="{4}" class="x-progress-text x-progress-text-back" style="width:100%;">{3}</div></div></div>',style, percent, text_front, text_back, text_tooltip);		

      return str;
    };  
    
    // Event handlers
    function onViewDetails(n, retries) {
      if (checkButtonClickCount() == true) {
        var args = "SessionId=" + n + "**";
        args += "NumRetries=" + retries;
        pageNav.Execute("TemplateEvents_TemplateResults_Client", args, null);
      }
    }

    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // View Details
      str += String.format("&nbsp;<a style='cursor:hand;' id='apply' href='javascript:onViewDetails({0},{2})'><img src='/Res/Images/icons/vcard.png' title='{1}' alt='{1}'/></a>", record.data.SessionId, TEXT_VIEW_DETAILS, record.data.NumRetries);
   
      return str;
    };    

    function onBack_<%= MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_CancelTemplateHistory_Client", null, null);
      }
    }

    function onRefresh()
    {
      dataStore_<%= MTFilterGrid1.ClientID %>.reload();
    }
    
    GetTopBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var tbar = new Ext.Toolbar([{
                xtype: 'checkbox',
                boxLabel: TEXT_AUTO_REFRESH,
                id: 'cbRefresh',
                checked: false,
                name: 'cbRefresh'
            }]);
      return tbar;
    };

    function gridEvents() {
      this.refreshGrid = function() {
      if(Ext.get("cbRefresh").dom.checked)
      {
        onRefresh();
      }
      setTimeout("events.refreshGrid()", 25000); 
      }
    };

    // start event polling
    var events = new gridEvents();
    setTimeout("events.refreshGrid()", 25000);

  </script>
  
</asp:Content>

