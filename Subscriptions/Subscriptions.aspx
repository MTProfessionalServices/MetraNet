<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_Subscriptions" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="Subscriptions.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">


  <script type="text/javascript">    
    // Sometimes when we come back from old MAM or MetraView we may have an extra frame.
    // This code busts out of it.
    Ext.onReady(function () { 
      if (getFrameMetraNet().MainContentIframe) {
        if (getFrameMetraNet().MainContentIframe.location != document.location) {
          getFrameMetraNet().MainContentIframe.location.replace("../StartWorkFlow.aspx?WorkFlowName=SubscriptionsWorkflow");
        }
      }
    });
  </script>

  <div class="CaptionBar">
    <asp:Label ID="lblSubscriptionsTitle" runat="server" Text="Subscriptions" meta:resourcekey="lblSubscriptionsTitle"></asp:Label>
  </div>

  <MT:MTFilterGrid ID="MyGrid1" runat="server" TemplateFileName="SubscriptionListLayoutTemplate" ExtensionName="Account">
  </MT:MTFilterGrid>
  
  <script type="text/javascript">

    function dateWithin(beginDate,endDate,checkDate) {
      var b,e,c;
      b = beginDate;
      e = endDate;
      c = checkDate;
      if((c <= e && c >= b)) {
        return true;
      }
      return false;
    }

    // Event handlers
    function onAdd_<%=MyGrid1.ClientID %>()
    {
      //Execute: function(operation, args, callbackMethod)
      if (checkButtonClickCount() == true) {
        pageNav.Execute("SubscriptionsEvents_Subscribe_Client", null, null);
      }    
    }
    
    function edit(n) {
      if (checkButtonClickCount() == true) {
        var args = "SubscriptionId=" + n;
        pageNav.Execute("SubscriptionsEvents_Edit_Client", args, null);
      }
    }

    function rates(n) {
      if (checkButtonClickCount() == true) {
        var args = "SubscriptionId=" + n;
        document.location.href = "/MetraNet/TicketToMAM.aspx?URL=/mam/default/dialog/DefaultDialogRates.asp|id_sub=" + n + "**LinkColumnMode=TRUE**NewMetraCare=TRUE";
        pageNav.Execute("SubscriptionsEvents_Rates_Client", args, null);
      }
    }

    function unsubscribe(n) {
      if (checkButtonClickCount() == true) {
        var args = "SubscriptionId=" + n;
        pageNav.Execute("SubscriptionsEvents_Unsubscribe_Client", args, null);
      }
    }

    function deleteSub(n) {
      if (checkButtonClickCount() == true) {
        var args = "SubscriptionId=" + n;
        pageNav.Execute("SubscriptionsEvents_Delete_Client", args, null);
      }
    }

    function onCancel_<%= MyGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("SubscriptionsEvents_CancelManageSubscriptions_Client", null, null);
      }
    }

    // Custom Renderers
    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
    {   
      var internalId = cm.getIndexById('ProductOffering#InternalInformationURL');
      if(internalId != -1)
      {
        cm.setRenderer(cm.getIndexById('ProductOffering#InternalInformationURL'), internalColRenderer); //Subscription_InternalURL
      }
      
      var externalId = cm.getIndexById('ProductOffering#ExternalInformationURL');
      if(externalId != -1)
      {
        cm.setRenderer(cm.getIndexById('ProductOffering#ExternalInformationURL'), externalColRenderer); //Subscription_ExternalURL
      }
      cm.setRenderer(cm.getIndexById('ProductOffering#DisplayName'), EditLinkRenderer); //ProductOffering_DisplayName
      cm.setRenderer(cm.getIndexById('ProductOffering#HasRecurringCharges'), CheckRenderer); //ProductOffering_HasRecurringCharges
      cm.setRenderer(cm.getIndexById('ProductOffering#HasDiscounts'), CheckRenderer); //ProductOffering_HasDiscounts
      cm.setRenderer(cm.getIndexById('ProductOffering#HasPersonalRates'), CheckRenderer); //ProductOffering_HasPersonalRates
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#StartDate'), DateRenderer); //SubscriptionSpan_StartDate
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#EndDate'), DateRenderer); //SubscriptionSpan_EndDate
      cm.setRenderer(cm.getIndexById('Subscription_Status'), statusColRenderer); //SubscriptionSpan_StartDate
      cm.setRenderer(cm.getIndexById('Subscription_Options'), optionsColRenderer); //SubscriptionSpan_EndDate      
    };
    
   /* GetExpanderTemplate_<%= MyGrid1.ClientID %> = function()
    {
      var tpl = new Ext.XTemplate(TPL_SUBSCRIPTION_DETAILS);
      return tpl;
    };
    */
    
    statusColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      var beginDate = Date.parseDate(record.data.SubscriptionSpan.StartDate,DATE_TIME_RENDERER);
      var endDate = Date.parseDate(record.data.SubscriptionSpan.EndDate,DATE_TIME_RENDERER);

      var checkDate = JSMetraTime;
      
      var isCurrent = dateWithin(beginDate, endDate, checkDate);
      if(isCurrent == true)
      {
        str = "<span style=\"color:green\">" + TEXT_CURRENT + "</span>";
        return str;
      } 
      else
      {
        if(beginDate > checkDate)
        {
          str = "<span style=\"color:black\">" + TEXT_FUTURE + "</span>";
          return str;
        }
      
        if(checkDate > endDate)
        {
          str = "<span style=\"color:red\">" + TEXT_PAST + "</span>";
          return str;
        }
      }
    };
    
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""
      
      // Rates button
      str += String.format("&nbsp;<a style='cursor:hand;' id='rates' href='javascript:rates({0})'><img src='/Res/Images/icons/money.png' title='{1}' alt='{1}'/></a>", record.data.SubscriptionId, TEXT_RATES);
      
      // Unsubscribe button
      if(<%= UI.CoarseCheckCapability("Update subscription").ToString().ToLower() %>)
      {
        str += String.format("&nbsp;<a style='cursor:hand;' id='unsubscribe' href='javascript:unsubscribe({0})'><img src='/Res/Images/icons/table_row_delete.png' title='{1}' alt='{1}'/></a>", record.data.SubscriptionId, TEXT_UNSUBSCRIBE);
      }
      
      // Delete button
      if(<%= UI.CoarseCheckCapability("Delete Subscription").ToString().ToLower() %>)
      {
        var beginDate = Date.parseDate(record.data.SubscriptionSpan.StartDate,DATE_TIME_RENDERER);
        var checkDate = JSMetraTime;
        if(beginDate > checkDate)  // only allow delete if start date is in the future       
        {         
          str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:deleteSub({0})'><img src='/Res/Images/icons/cross.png' title='{1}' alt='{1}'/></a>", record.data.SubscriptionId, TEXT_DELETE);
        }
      }       
      return str;
    };
    
    internalColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // Display InternalInformationURL
      var internalUrl = record.data.ProductOffering.InternalInformationURL;
      if(internalUrl != null)
      {
        if(internalUrl.length > 1)
        {
          str += String.format("<a href=\"JavaScript:getFrameMetraNet().Ext.UI.NewWindow('{1}', 'InternalWin', '{0}');\"><img border='0' src='/Res/Images/Icons/information.png'></a>&nbsp;", internalUrl, TEXT_INTERNAL);
        }
      }
      return str;
    }
    
    externalColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";

      // Display ExternalInformationURL
      var externalUrl = record.data.ProductOffering.ExternalInformationURL;
      if(externalUrl != null)
      {
        if(externalUrl.length > 1)
        {
          str += String.format("<a href=\"JavaScript:getFrameMetraNet().Ext.UI.NewWindow('{1}', 'ExternalWin', '{0}');\"><img border='0' src='/Res/Images/Icons/world_go.png'></a>&nbsp;", externalUrl, TEXT_EXTERNAL);
        }
      }
      return str;
    }
    
    EditLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      
      // Edit Link
      if(<%= UI.CoarseCheckCapability("Update subscription").ToString().ToLower() %>)
      {
        str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.SubscriptionId, value);
      }
      else
      {
        str += value;
      }  
      return str;
    };        

  </script>   

</asp:Content>
