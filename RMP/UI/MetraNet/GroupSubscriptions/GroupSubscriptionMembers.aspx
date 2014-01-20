<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_GroupSubscriptionMembers"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="GroupSubscriptionMembers.aspx.cs" %>

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
    <asp:Label ID="lblGroupSubMembersTitle" runat="server" Text="Group Subscription Members"
      meta:resourcekey="lblGroupSubMembersTitleResource1"></asp:Label>
  </div>
  <MT:MTFilterGrid ID="GroupSubMemGrid" runat="server" TemplateFileName="GroupSubscriptionMemberListLayoutTemplate"
    ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
    FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    MultiSelect="False" 
    PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    TotalProperty="TotalRows">
  </MT:MTFilterGrid>

  <script type="text/javascript">
    
    // Custom Renderers
   OverrideRenderer_<%= GroupSubMemGrid.ClientID %> = function(cm)
    {      
      cm.setRenderer(cm.getIndexById('MembershipSpan#StartDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('MembershipSpan#EndDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer);
     
    };      
 
   function onAdd_<%=GroupSubMemGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_AddGroupSubscriptionMembers_Client", null, null);
    }
 
   function onCancel_<%= GroupSubMemGrid.ClientID %>()
    {       
      pageNav.Execute("GroupSubscriptionsEvents_CancelGroupSubscriptionMembers_Client", null, null);    
    }
  
    function onDelete_<%= GroupSubMemGrid.ClientID %>()
    {
      var records = grid_<%= GroupSubMemGrid.ClientID %>.getSelectionModel().getSelections();    
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
       if(i > 0)
       {
         ids += ",";
       }
       ids += records[i].data.AccountId;      
      }
      if(ids.length > 1)
      {
        var args = "MemberIdColl=" + ids;
        pageNav.Execute("GroupSubscriptionsEvents_DeleteGroupSubscriptionMembers_Client", args, null);
      }
      else
      {
         Ext.Msg.show({
                         title:'Error',
                         msg: TEXT_GRPSUBMEM_DEL,
                         buttons: Ext.Msg.OK,               
                         icon: Ext.MessageBox.ERROR
                     });
            return false;        
      }
    }
    
    function onUnsubscribe_<%= GroupSubMemGrid.ClientID %>()
    {
      var records = grid_<%= GroupSubMemGrid.ClientID %>.getSelectionModel().getSelections();      
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
       if(i > 0)
       {
          ids += ",";
       }
       ids += records[i].data.AccountId;      
      }
     
     if(ids.length > 1)
     {
      var args = "MemberIdColl=" + ids;
      pageNav.Execute("GroupSubscriptionsEvents_UnsubscribeGroupSubscriptionMembers_Client", args, null);
     }
     else
      {
         Ext.Msg.show({
                         title:'Error',
                         msg: TEXT_GRPSUBMEM_UNSUB,
                         buttons: Ext.Msg.OK,               
                         icon: Ext.MessageBox.ERROR
                     });
            return false;        
      }
     
    }
    
    function edit(n)
    {
     var args = "SelectedAccountId=" + n;     
     pageNav.Execute("GroupSubscriptionsEvents_EditGroupSubscriptionMembers_Client", args, null);
    }        
     
     optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";       
        
      // Delete button
     if(<%= UI.CoarseCheckCapability("Modify groupsub membership").ToString().ToLower() %>)
      {
        str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.AccountId, TEXT_EDIT_GRPSUB_MEMBER);        
      }       
      return str;
    };    
          
 
  </script>

</asp:Content>
