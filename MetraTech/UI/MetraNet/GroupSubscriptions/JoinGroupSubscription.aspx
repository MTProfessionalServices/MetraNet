<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_JoinGroupSubscription"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="JoinGroupSubscription.aspx.cs" %>

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
    <asp:Label ID="lblJoinGroupSubscriptionsTitle" runat="server" Text="Join Group Subscription"
      meta:resourcekey="lblJoinGroupSubscriptionsTitleResource1"></asp:Label>
  </div>
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False"></asp:Label>
  
  </div>
  <MT:MTFilterGrid ID="JoinGroupSubGrid" runat="server" TemplateFileName="JoinGroupSubscriptionListLayoutTemplate"
    ExtensionName="Account">
  </MT:MTFilterGrid>
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript">
    OverrideRenderer_<%= JoinGroupSubGrid.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#StartDate'), DateRenderer); 
      cm.setRenderer(cm.getIndexById('SubscriptionSpan#EndDate'), DateRenderer); 
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };  
   
    
    function onOK_<%= JoinGroupSubGrid.ClientID %>()
    {
      var records = grid_<%= JoinGroupSubGrid.ClientID %>.getSelectionModel().getSelections();      
      var groupid = "";     
      if (records.length == 0) {
        return;
      }

      if (records.length == 0) {
        return;
      }

      for(var i=0; i < records.length; i++)
      {       
        groupid = records[i].data.GroupId;          
      }      
      var args = "GroupSubscriptionId=" + groupid;     
      pageNav.Execute("GroupSubscriptionsEvents_OKGroupSubscriptionJoin_Client", args, null);
    }  
    
    function onCancel_<%= JoinGroupSubGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_CancelGroupSubscriptionJoin_Client", null, null);
    } 
    
    function members(n)
    {   
      var args = "GroupSubscriptionId=" + n;              
      pageNav.Execute("GroupSubscriptionsEvents_MembersGroupSubscriptionJoin_Client", args, null);
    }
    
     optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";    
     
      // Members button
      if(<%= UI.CoarseCheckCapability("Modify groupsub membership").ToString().ToLower() %>)
      {
        str += String.format("&nbsp;<a style='cursor:hand;' id='members' href='javascript:members({0})'><img src='/Res/Images/icons/group_add.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_MEMBERS);
      }      
       
      return str;
      
    };    
    
  </script>

</asp:Content>
