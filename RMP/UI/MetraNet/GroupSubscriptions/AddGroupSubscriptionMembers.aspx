<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_AddGroupSubscriptionMembers"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="AddGroupSubscriptionMembers.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  
  <link rel="stylesheet" type="text/css" href="/Res/Styles/grid.css" />
  <MT:MTTitle ID="MTTitle1" runat="server" /><br />

  <div id="divLblMessage" runat="server" visible="false" >
    <b>
      <div class="InfoMessage" style="margin-left:120px;width:400px;">
        <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
      </div>
    </b>
  </div>

  <MT:MTPanel ID="MTPanel1" runat="server" Width="400">
    <MT:MTDatePicker ID="MTEffecStartDatePicker" runat="server" AllowBlank="False" Label="Effective Start Date"
      meta:resourcekey="EffectiveStartDate" TabIndex="220" ControlWidth="200" ControlHeight="18"
      HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" Width="300px" />
    <MT:MTDatePicker ID="MTEffecEndDatePicker" runat="server" AllowBlank="False" Label="Effective End Date"
      meta:resourcekey="EffectiveEndDate" TabIndex="230" ControlWidth="200" ControlHeight="18"
      HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
      ReadOnly="False" XType="DateField" XTypeNameSpace="form" Width="300px" />
  </MT:MTPanel>
  
  <div id="MembersDiv" style="margin:10px"></div>


  <div class="x-panel-btns-ct">
    <div style="width: 400px" class="x-panel-btns x-panel-btns-center">
    <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="return getAccountIds();" Width="50px" runat="server"
              Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" />
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

  <input id="HiddenAcctIdTextBox" runat="server" type="hidden" />
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>


  
  <script language="javascript" type="text/javascript">
  
  function getAccountIds()
    {
      var records = store.data.items; 
      
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
       if(i > 0)
       {
         ids += ",";
       }
       ids += records[i].data._AccountID + ":" + records[i].SelectionScope;      
      }  
      
                 
     Ext.get("<%=HiddenAcctIdTextBox.ClientID %>").dom.value = ids;  
 
        if(ValidateForm())
        {       
         if(ids.length <= 1)
         {
                 Ext.Msg.show({
                                title: TEXT_ERROR,
                                msg: TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
                                buttons: Ext.Msg.OK,               
                                icon: Ext.MessageBox.ERROR
                              });
            return false;          
          }
        }    
        else
        {
         return false;
        }
        
    }
    
    
  </script>
 
</asp:Content>
