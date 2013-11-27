<%@ Page Language="C#" MasterPageFile="~/MasterPages/AccountPageExt.master" AutoEventWireup="true" Inherits="AccountInfo" CodeFile="AccountInfo.aspx.cs" Culture="auto" UICulture="auto"  meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

 
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <script type="text/javascript" src="/Res/JavaScript/Validators.js"></script>
  <h1><asp:Localize meta:resourcekey="AccountInformation" runat="server">Account Information</asp:Localize></h1>

  <div class="box500">
  <div class="box500top"></div>
  <div class="box">
    
      <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" EnableChrome="false"></MTCDT:MTGenericForm>
        
      <!-- BUTTONS -->
      <div class="clearer"></div>
      <div class="button">
        <div class="centerbutton">
          <span class="buttonleft"><!--leftcorner--></span>
          <asp:Button OnClick="btnOK_Click" OnClientClick="return Validate();" ID="btnOK"
            runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" />
          <span class="buttonright"><!--rightcorner--></span>
        </div>
        <span class="buttonleft"><!--leftcorner--></span>
        <asp:Button OnClick="btnCancel_Click" ID="btnCancel" runat="server" CausesValidation="false"
          meta:resourcekey="btnCancelResource1" Text="<%$Resources:Resource,TEXT_CANCEL%>" />
        <span class="buttonright"><!--rightcorner--></span>
      </div>

  </div>
  </div>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
  </MT:MTDataBinder>
  
  <script type="text/javascript">
    function Validate()
      {   
         var company = Ext.get("ctl00_ContentPlaceHolder1_tbCompany").dom.value;
         var add1 = Ext.get("ctl00_ContentPlaceHolder1_tbAddress1").dom.value;
         var add2 = Ext.get("ctl00_ContentPlaceHolder1_tbAddress2").dom.value;
         var add3 = Ext.get("ctl00_ContentPlaceHolder1_tbAddress3").dom.value;
         var city = Ext.get("ctl00_ContentPlaceHolder1_tbCity").dom.value;
         var state = Ext.get("ctl00_ContentPlaceHolder1_tbState").dom.value;
         var zip = Ext.get("ctl00_ContentPlaceHolder1_tbZip").dom.value;
              
         if((company.indexOf("\\") >= 0) ||
             (add1.indexOf("\\") >= 0) ||
             (add2.indexOf("\\") >= 0) ||
             (add3.indexOf("\\") >= 0) ||
             (city.indexOf("\\") >= 0) ||
             (state.indexOf("\\") >= 0) ||
             (zip.indexOf("\\") >= 0))
         {
           return false;
         }
         else
         { 
          return ValidateForm();
         }       
                 
      }
  </script>
</asp:Content>

