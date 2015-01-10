<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SetUDRCValues" Title="<%$Resources:Resource,TEXT_TITLE%>"
  Culture="auto" UICulture="auto" CodeFile="SetUDRCValuesForGroupSubscription.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <!-- Title Bar -->
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Recurring Charge Accounts" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <MT:MTFilterGrid ID="UDRCGrid" runat="server" TemplateFileName="GroupSubscriptionUDRCTemplate"
    ExtensionName="Account">
  </MT:MTFilterGrid>
  <MT:MTFilterGrid ID="FlatRateRCGrid" runat="server" TemplateFileName="GroupSubscriptionFlatRateRCTemplate"
    ExtensionName="Account">
  </MT:MTFilterGrid>
  
  <div class="x-panel-btns-ct">
    <div style="width: 600px" class="x-panel-btns x-panel-btns-center">
    <center>
      <table cellspacing="0">
        <tr>
           <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_SAVE%>"
              OnClick="btnSave_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
              CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
       </center>
    </div>
  </div>
 
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>

  <script type="text/javascript">
    
    // Custom Renderers
   OverrideRenderer_<%=UDRCGrid.ClientID %> = function(cm)
    {           
      cm.setRenderer(cm.getIndexById('ChargeAccountSpan#StartDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('ChargeAccountSpan#EndDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('Actions'), optionsUDRCColRenderer);     
    };    
    
    OverrideRenderer_<%= FlatRateRCGrid.ClientID %> = function(cm2)
    {       
      cm2.setRenderer(cm2.getIndexById('ChargeAccountSpan#StartDate'), DateRenderer);
      cm2.setRenderer(cm2.getIndexById('ChargeAccountSpan#EndDate'), DateRenderer);
      cm2.setRenderer(cm2.getIndexById('Actions'), optionsFlatRateColRenderer);     
    };    
    
    function editChrgAcct(n)
    {        
    
     var args = "SelectedUDRCInstanceId=" + n;      
     pageNav.Execute("GroupSubscriptionsEvents_EditGroupSubscriptionUDRCChargeAccount_Client", args, null);
    }
    
    function editFlatRateChrgAcct(n)
    {   
     var args = "SelectedFlatRateRCInstanceId=" + n;   
     pageNav.Execute("GroupSubscriptionsEvents_EditGroupSubscriptionFlatRateRecChargeAccount_Client", args, null);
    }
    
    function UDRCValues(n, chargeAcctId, chargePerParti)
    {      
       if(!chargePerParti)
       {
          if(chargeAcctId == null)
          {
             Ext.Msg.show({
                                    title: TEXT_INFO,
                                    msg: TEXT_SETUP_CHARGE_ACCOUNT,
                                    buttons: Ext.Msg.OK,               
                                    icon: Ext.MessageBox.INFO
                                  });
          }
          else
          {
            var args = "SelectedUDRCInstanceId=" + n;
            pageNav.Execute("GroupSubscriptionsEvents_AddEditUDRCValues_Client", args, null);
          }
        }
        else
        {
          var args = "SelectedUDRCInstanceId=" + n;
          pageNav.Execute("GroupSubscriptionsEvents_AddEditUDRCValues_Client", args, null);
        }
      
    }   
            
    optionsUDRCColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";               
      
     if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
     {     
     
       if(!record.data.ChargePerParticipant)
       {
        // Edit UDRC charge account
        str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:editChrgAcct({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.ID, TEXT_EDIT_CHARGE_ACCOUNT);
        } 
                    
        //Add UDRC Values
        str += String.format("&nbsp;&nbsp;&nbsp;<a style='cursor:hand;' id='UDRCValues' href='javascript:UDRCValues({0},{2},{3});'><img src='/Res/Images/icons/table_refresh.png' title='{1}' alt='{1}'/></a>", record.data.ID, TEXT_UDRC_VALUES, record.data.ChargeAccountId, record.data.ChargePerParticipant);         
      }       
      return str;
    };      
    
     optionsFlatRateColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";               
     
     if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
     {  
       if(!record.data.ChargePerParticipant)
       {
       // Edit Flat Rate Charge Account
        str += String.format("&nbsp;<a style='cursor:hand;' id='EditChargeAcct' href='javascript:editFlatRateChrgAcct({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.ID, TEXT_EDIT_CHARGE_ACCOUNT);    
       }       
        
    }
     return str;
    };      
    
   
  </script>

</asp:Content>
