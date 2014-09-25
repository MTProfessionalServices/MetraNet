<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_GroupSubscriptions"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="GroupSubscriptions.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript">
    // Sometimes when we come back from old MAM or MetraView we may have an extra frame.
    // This code busts out of it.
    Ext.onReady(function(){
      if(getFrameMetraNet().MainContentIframe )
      {
        if(getFrameMetraNet().MainContentIframe.location != document.location)
        {
          getFrameMetraNet().MainContentIframe.location.replace("../StartWorkFlow.aspx?WorkFlowName=GroupSubscriptionsWorkflow");
        }
      }
    });
  </script>

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>

  <div class="CaptionBar">
    <asp:Label ID="lblGroupSubscriptionsTitle" runat="server" Text="Group Subscriptions"
      meta:resourcekey="lblGroupSubscriptionsTitleResource1"></asp:Label>
  </div>
  <br />
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  </div>
  <MT:MTFilterGrid ID="GroupSubGrid" runat="server" TemplateFileName="GroupSubscriptionListLayoutTemplate"
    ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
    FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    TotalProperty="TotalRows">
  </MT:MTFilterGrid>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  
  <script type="text/javascript">
    // Custom Renderers
    OverrideRenderer_<%= GroupSubGrid.ClientID %> = function(cm)
    {   
      //cm.setRenderer(cm.getIndexById('Name'), EditLinkRenderer);
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#StartDate'), DateRenderer); 
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#EndDate'), DateRenderer); 
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
    function onCancel_<%= GroupSubGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_CancelManageGroupSubscriptions_Client", null, null);
    }

    function edit(n)
    {
      var args = "GroupSubscriptionId=" + n;
      pageNav.Execute("GroupSubscriptionsEvents_Edit_Client", args, null);            
    }

    function rates(n)
    {
      var args = "GroupSubscriptionId=" + n;
      document.location.href = "/MetraNet/TicketToMAM.aspx?URL=/mam/default/dialog/DefaultDialogRates.asp|id_group=" + n + "**LinkColumnMode=TRUE**NewMetraCare=TRUE";          
    }
    
    function members(n)
    {   
      var args = "GroupSubscriptionId=" + n;         
      pageNav.Execute("GroupSubscriptionsEvents_Members_Client", args, null);
    }
       
    function deleteGroupSub(n)
    {
      var args = "GroupSubscriptionId=" + n;      
      pageNav.Execute("GroupSubscriptionsEvents_Delete_Client", args, null);
    }
    
    function unsubscribeFromGroupSub(n)
    {
      var args = "GroupSubscriptionId=" + n;      
      pageNav.Execute("", args, null);
    }   
      
    function removeGroupSubMembership(n)
    {
      var args = "GroupSubscriptionId=" + n;      
      pageNav.Execute("", args, null);
    }    
            
    function onAdd_<%=GroupSubGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_Add_Client", null, null);
    }
     function onJoin_<%=GroupSubGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_JoinGroupSubscription_Client", null, null);
    }
    
    
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";      
          
      // Edit Link
      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
      {     
         if(<%=IsCorporate.ToString().ToLower() %>)
         {
                //str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
                str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
         } 
      }


      // str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
      
        // Rates button
      str += String.format("&nbsp;<a style='cursor:hand;' id='rates' href='javascript:rates({0})'><img src='/Res/Images/icons/money.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_RATES);
      

      // Members button
      if(<%= UI.CoarseCheckCapability("Modify groupsub membership").ToString().ToLower() %>)
      {
        str += String.format("&nbsp;<a style='cursor:hand;' id='members' href='javascript:members({0})'><img src='/Res/Images/icons/group_add.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_MEMBERS);
      }
      
      // Delete button
      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
      {
        if(<%=IsCorporate.ToString().ToLower() %>)
        {
          str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:deleteGroupSub({0})'><img src='/Res/Images/icons/cross.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_DELETE);
        }
      }      
       

      return str;
    };    

    EditLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      
      // Edit Link
      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
      {     
         if(<%=IsCorporate.ToString().ToLower() %>)
         {
                str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
         }
         else
         {
            str += value;
         }  
      }
      
      
      return str;
    };      
  </script>

</asp:Content>
