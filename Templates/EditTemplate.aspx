<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_EditTemplate" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="EditTemplate.aspx.cs" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server"> 
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Edit Account Template" meta:resourcekey="MTTitle1Resource1"/>

  <div style="width:810px">
    <br />  
    <MTCDT:MTGenericForm ID="MTGenericFormAccountTemplate" runat="server" meta:resourcekey="MTGenericFormAccountTemplateResource1" ></MTCDT:MTGenericForm>
    <div style="height:10px;">&nbsp;</div>
    <MTCDT:MTGenericForm ID="MTGenericFormProperties" runat="server" meta:resourcekey="MTGenericFormPropertiesResource1" ></MTCDT:MTGenericForm>
    <span style="display:none;">
      <asp:Button ID="btnAddSubscription" OnClientClick="return checkButtonClickCount();" runat="server" Text="Add Subscription" onclick="btnAddSubscription_Click" meta:resourcekey="btnAddSubscriptionResource1"/>
      <asp:Button ID="btnAddGroupSubscription" OnClientClick="return checkButtonClickCount();" runat="server" Text="Add Group Subscription" onclick="btnAddGroupSubscription_Click" meta:resourcekey="btnAddGroupSubscriptionResource1" />
    </span>
    <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="AccountTemplateSubscriptions" ExtensionName="Account" ></MT:MTFilterGrid>
    
  <!-- BUTTONS -->
 
  <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">
     <center>   
      <table cellspacing="0">
        <tr>
        <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnSaveAndApply" OnClientClick="if (checkButtonClickCount() == true) {return ValidateForm();} else {return false;}" Width="50px" runat="server" Text="Save And Apply" meta:resourcekey="btnSaveAndApplyResource1" OnClick="btnSaveAndApply_Click" TabIndex="0" />     
          </td>        
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true) {return ValidateForm();} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_SAVE%>" OnClick="btnOK_Click" TabIndex="0" />     
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" TabIndex="0" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table> 
       </center>    
    </div>
  </div>
 
      
    <br />  
  </div>


  
  <script type="text/javascript">
  
    GetTopBar_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function()
    {
      var tbar = new Ext.Toolbar([{text:TEXT_ADD_SUBSCRIPTION,handler:onNewSubClick,iconCls:'add'},'-',{text:TEXT_ADD_GROUP_SUBSCRIPTION,handler:onNewGroupSubAdd,iconCls:'add'},'-']);
      return tbar;
    };

    function onNewSubClick()
    {
      Ext.get("<%= btnAddSubscription.ClientID %>").dom.click();
    }

    function onNewGroupSubAdd()
    {
      Ext.get("<%= btnAddGroupSubscription.ClientID %>").dom.click();
    }
    
     // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Name'), NameRenderer);
      cm.setRenderer(cm.getIndexById('IsGroup'), IsGroupRenderer); 
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
    NameRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupSubName != null)
      {
        str += record.data.GroupSubName;
      }
      else
      {
        str += record.data.PODisplayName;
      }
      
      return str;
    }; 
    
    IsGroupRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupID == "" || record.data.GroupID  == null)
      {
         return "--";
      }
      else
      {
        return "<img border='0' src='/Res/Images/Icons/tick.png'>";
      }
      return str;
    };
    
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""
      var name = getDisplayName(record);
      str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:onDelete({0}, {1}, \"{2}\")'><img src='/Res/Images/icons/cross.png' title='{3}' alt='{3}'/></a>", record.data.ProductOfferingId, record.data.GroupID, String.escape(name.replace("'","")), TEXT_DELETE);
      return str;
    };  
    
    function onDelete(poId, groupId, name)
    {
      if(groupId == null)
        groupId = -1;
        
      if(poId == null)
        poId = -1;
      
      var message = String.format(TEXT_DELETE_TEMPLATE_SUB_MESSAGE, String.escape(name));

      top.Ext.MessageBox.show({
               title:TEXT_DELETE,
               msg: message,
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok') {
                   if (checkButtonClickCount() == true) {
                     //param1=value1**param2=value2**param3=value3
                     var args = "GroupID=" + groupId + "**";
                     args += "POID=" + poId;
                     pageNav.Execute("TemplateEvents_DeleteSubscription_Client", args, deleteResult);
                   }
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
      });

      var dlg = top.Ext.MessageBox.getDialog();
      var buttons = dlg.buttons;
      for (i = 0; i < buttons.length; i++) {
        buttons[i].addClass('custom-class');
      }
    }
    
    function getDisplayName(record)
    {
      var name = "";
      if(record.data.GroupSubName != null)
      {
        name += record.data.GroupSubName;
      }
      else
      {
        name += record.data.PODisplayName;
      }
      return name;
    }

    function deleteResult(responseText)
    {
      //refresh grid
      dataStore_<%= MTFilterGrid1.ClientID %>.reload();
    }
    
    // Remove Pager
    GetBottomBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var bbar = null;
      return bbar;
    };
    
  </script>

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="btnSaveAndApply" 
        ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>

  </MT:MTDataBinder>

</asp:Content>

