<%@ Page Language="C#" MasterPageFile="~/MasterPages/PaymentPageExt.master" AutoEventWireup="true" Inherits="Payments_ViewPaymentMethods" Culture="auto"
  meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ViewPaymentMethods.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <h1>
    <asp:Localize ID="Localize1" meta:resourcekey="ViewPaymentMethods" runat="server">Payment Methods</asp:Localize></h1>
  <MT:MTFilterGrid runat="Server" ID="PaymentMethodsGrid" ExtensionName="MetraView" TemplateFileName="PaymentMethodsListLayoutTemplate" >
  </MT:MTFilterGrid>
  <div id="buttonDiv" class="button">
    <div class="centerbutton">
      <span class="buttonleft">
        <!--leftcorner-->
      </span>
       <asp:Button OnClick="OnAddCreditCard_Click" ID="btnCC" runat="server" CausesValidation="false"
      meta:resourcekey="btnAddCC" Text="Add Credit Card" />
      <span class="buttonright">
        <!--rightcorner-->
      </span>
    </div>
    <span class="buttonleft">
      <!--leftcorner-->
    </span>
     <asp:Button OnClick="OnAddACH_Click" ID="btnACH" CausesValidation="false" runat="server"
        Text="Add ACH" meta:resourcekey="btnAddACH" />
  
    <span class="buttonright">
      <!--rightcorner-->
    </span>
  </div>

  <script language="javascript" type="text/javascript">

  var metraPayIsInstalled = "<%=MetraPayIsInstalled%>";
  var creditCardsAreEditable = Boolean("<%=CreditCardsAreEditable%>");
  var achAccountsAreEditable = Boolean("<%=AchAccountsAreEditable %>");

  OverrideRenderer_<%= PaymentMethodsGrid.ClientID %> = function(cm) {
    cm.setRenderer(cm.getIndexById('Options'), optionsColRenderer);
    cm.setRenderer(cm.getIndexById('CreditCardTypeValueDisplayName'), cardTypeColRenderer);
  };
  
  function optionsColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
    if(record.data.PaymentMethodType == "1")
    {   
      //Some payment gateways nay not allow users to edit ACH information. Don't show the edit icon if we can't edit.
      if (achAccountsAreEditable == true) {
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_EDIT_ACH);
      }
      // Delete button
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:deleteCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/cross.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_REMOVE_ACH);    
    }
    else
    {
      //Some payment gateways don't allow users to edit credit card information.  (For example, WorldPay).  Don't show the edit icon if we can't edit.
      if (creditCardsAreEditable == true) {
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_EDIT_CARD);
      }
      // Delete button
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:deleteCard(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/cross.png' alt='{2}' /></a>", record.data.PaymentInstrumentID, record.data.ExpirationDate, TEXT_REMOVE_CARD);    
    }
    return str;
  } 
  
  function cardTypeColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
   var str= "";
   
   if(record.data.PaymentMethodType == "1")
    {   
      str = TEXT_ACH ;  
    }
    else if(record.data.PaymentMethodType == "0")
    {
     str = record.data.CreditCardTypeValueDisplayName;
     if (str == "None") {
       str = "";
     }
    }
    else{
      str = "...";
    }
   return str;
  
  }
  
  function editCard(paymentInstrumentID, expirationDate)
  { 
   if(expirationDate != "")
    {
     location.href = '<%=Request.ApplicationPath%>/Payments/CreditCardUpdate.aspx?piid=' + paymentInstrumentID;
    }
    else
    {
     location.href = '<%=Request.ApplicationPath%>/Payments/ACHUpdate.aspx?piid=' + paymentInstrumentID;     
    }
  }  
  
  function deleteCard(paymentInstrumentID, expirationDate)
  {
   if(expirationDate != "")
   {
    location.href = '<%=Request.ApplicationPath%>/Payments/CreditCardRemove.aspx?piid=' + paymentInstrumentID;
   }
   else
   {
    location.href = '<%=Request.ApplicationPath%>/Payments/ACHRemove.aspx?piid=' + paymentInstrumentID;
   }
      
  }


  Ext.onReady(function() {
    var buttonDiv = document.getElementById("buttonDiv");
    if (buttonDiv != null)
    {
      if (metraPayIsInstalled == 1)
      {
        document.getElementById("buttonDiv").style.display = "block";
      }
      else
      {
        document.getElementById("buttonDiv").style.display = "none";
      }
    }
  });

  
  </script>

</asp:Content>
