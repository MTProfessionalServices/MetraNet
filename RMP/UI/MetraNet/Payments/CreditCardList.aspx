<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Payments_CreditCardList" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="CreditCardList.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="Label1" runat="server" meta:resourcekey="Label1Resource1"></asp:Label>
  </div>
 <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="Account" TemplateFileName="<%$ Code: GetCreditCardLayoutTemplate() %>" ></MT:MTFilterGrid>
  
  <script language="javascript" type="text/javascript">
  
  var metraPayIsInstalled = "<%=MetraPayIsInstalled%>";
  var creditCardsAreEditable = Boolean("<%=CreditCardsAreEditable%>");
  var achAccountsAreEditable = Boolean("<%=AchAccountsAreEditable%>");
  
  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('Options'), optionsColRenderer); 
    cm.setRenderer(cm.getIndexById('CreditCardTypeValueDisplayName'), cardTypeColRenderer); 
  }
  
  function optionsColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
    if(record.data.CreditCardTypeValueDisplayName == "") {
      //Some payment gateways nay not allow users to edit ACH information. Don't show the edit icon if we can't edit.
      if (achAccountsAreEditable == true) {
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_EDIT_ACH);
      }
      // Delete button  
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:deleteCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/cross.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_REMOVE_ACH);
    }
    else
    {
    
      //Some payment gateways don't allow users to edit credit card information.  (For example, WorldPay).  Don't show the edit icon if we can't edit.
      if (creditCardsAreEditable == true)
      {
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_EDIT_CARD);
      }
      // Delete button
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:deleteCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/cross.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_REMOVE_CARD); 
    }   
    return str;
  }
  
  function onAdd_<%=MyGrid1.ClientID %>()
  {
     location.href = '/MetraNet/Payments/<%=GetCreditCardPage()%>CreditCardAdd.aspx';
  }
  
  function onAddACH_<%=MyGrid1.ClientID %>()
  {
    location.href = '/MetraNet/Payments/ACHAdd.aspx';
  }
  
  function cardTypeColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
   var str= "";
   
   if(record.data.CreditCardTypeValueDisplayName == "")
    {   
      str = TEXT_ACH;  
    }
    else
    {
     str = record.data.CreditCardTypeValueDisplayName;
    }
   return str;
  
  }
    
  function editCard(paymentInstrumentID, expirationDate)
  {
    if(expirationDate != "")
    {
     location.href = '/MetraNet/Payments/CreditCardUpdate.aspx?piid=' + paymentInstrumentID;
    }
    else
    {
     location.href = '/MetraNet/Payments/ACHUpdate.aspx?piid=' + paymentInstrumentID;
    }
  }  
  
  function deleteCard(paymentInstrumentID, expirationDate)
  {
    if(expirationDate != "")
    {   
     location.href = '/MetraNet/Payments/CreditCardRemove.aspx?piid=' + paymentInstrumentID;  
    }
    else
    {
      location.href = '/MetraNet/Payments/ACHRemove.aspx?piid=' + paymentInstrumentID;  
    }
  }
  
  
  Ext.onReady(function() {
    // Hide toolbar (containing Add buttons) if MetraPay is not installed.
    var pmtMethodsGrid = Ext.getCmp('extGrid_ctl00_ContentPlaceHolder1_MyGrid1');
    if (pmtMethodsGrid != null)
    {
      if (metraPayIsInstalled == 1)
      {
        pmtMethodsGrid.getTopToolbar().show();
      }
      else
      {
        pmtMethodsGrid.getTopToolbar().hide();
      }
    }
  });

  </script>
</asp:Content>

