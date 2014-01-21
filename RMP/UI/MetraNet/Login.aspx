<%@ Page Language="C#" MasterPageFile="~/MasterPages/LoginPageExt.master" AutoEventWireup="true" Inherits="login" CodeFile="Login.aspx.cs" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="UserControls/ServerDescription.ascx" tagname="ServerDescription" tagprefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">

Ext.onReady(function() {

    top.clearTimeout(this.timer);
  
    if (getFrameMetraNet().frames.length > 0) getFrameMetraNet().location.replace(document.location);

    if(Ext.get('ctl00_ContentPlaceHolder1_Login1_UserName'))
    {
      setTimeout("Ext.get('ctl00_ContentPlaceHolder1_Login1_UserName').dom.focus();", 500);
    }
    
    if(Ext.get('<%=ShowPopup.ClientID %>') != null)
      {
      if(Ext.get('<%=ShowPopup.ClientID %>').dom.value == "true")
      {
        onDetails();
      }
    }
});    

function onDetails()
{
  var details = Ext.get('<%=reasonText.ClientID %>').dom.innerHTML;
          Ext.MessageBox.show({
             title:'Error',
             msg: details,
             buttons: Ext.MessageBox.OK,
             fn: function(btn){
               if (btn == 'ok')
               {
               }
             },
            
             icon: Ext.MessageBox.ERROR
          });
}
</script>
    
  <style type="text/css">
    #LoginDiv {
      background-image:url(/Res/Images/login/metranetlogin.png);
      width:495px;
      height:312px;
      top:10%;
  	  margin-left: auto;
	    margin-right: auto;
	    border: 1px solid #CCCCCC;
	    position: relative;
    }
    #bottom {
      width: 100%;
      position: absolute;
      bottom: 0px;
      background: #CCCCCC;
      text-align: center;
      
      }
      .aligned{
          position : relative;
          left : 5px;
          padding:0;
          }
      
   #aspnetForm input { 
     font:normal 12px tahoma, arial, helvetica, sans-serif;
     margin:2px;
   } 
  </style>  
    
  <div id="LoginDiv">  

    <div id="loginContainer" style="position:relative;top:120px;left:200px;">
   
      <asp:Panel ID="pnlLogin" runat="server" Width="252px">
        <asp:Login ID="Login1" runat="server" OnAuthenticate="Login1_Authenticate" DisplayRememberMe="False" TitleText="" meta:resourcekey="Login1Resource1">
          <LabelStyle Font-Bold="True" HorizontalAlign="Right" /> <LoginButtonStyle CssClass="button" />
        </asp:Login>
      </asp:Panel>
      
      <asp:Panel ID="pnlChangePassword" runat="server" Visible="false">
        <asp:Label ID="lblMessage" runat="server" Text="Your Password Expired" ForeColor="Red" meta:resourcekey="lblMessageResource1"></asp:Label>
        &nbsp;&nbsp;
        <a href="javascript:onDetails();"><asp:Label ID="lblDetails" runat="server" Text="details" meta:resourcekey="lblDetailsResource1"></asp:Label></a>
        <div id="reasonText" runat="server" style="display:none">
          <asp:Label ID="lblPleaseChange" runat="server" Text="Please change your password" meta:resourcekey="lblPleaseChangeResource1"></asp:Label>
        </div>
    <div id="boxes" style="position:relative;left:-25px;">
        <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name" TabIndex="100" ControlWidth="120" OptionalExtConfig="cls:'aligned'" ControlHeight="18" HideLabel="False" Listeners="{}" ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbUserNameResource1" />
        <MT:MTTextBoxControl ID="tbOldPassword" runat="server" AllowBlank="False" Label="Old Password" OptionalExtConfig="inputType:'password',cls:'aligned'" TabIndex="110" ControlWidth="120" ControlHeight="18" HideLabel="False" Listeners="{}"  ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbOldPasswordResource1" />
        <MT:MTPasswordMeter  ID="tbNewPassword" runat="server" AllowBlank="False" Label="New Password" OptionalExtConfig="inputType:'password',cls:'aligned'"  TabIndex="120" ControlWidth="120" ControlHeight="18" HideLabel="False" Listeners="{}" ReadOnly="False" XType="PasswordMeter" XTypeNameSpace="ux" LabelSeparator=":" meta:resourcekey="tbNewPasswordResource1" />
        <MT:MTTextBoxControl  ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password" OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbNewPassword',cls:'aligned'" TabIndex="130" VType="password"  ControlWidth="120" ControlHeight="18" HideLabel="False" Listeners="{}" ReadOnly="False" XType="TextField" XTypeNameSpace="form" LabelSeparator=":" meta:resourcekey="tbConfirmPasswordResource1" />
    </div>    
    <center>
        <div class="Buttons" style="text-align:left">
           <br />   
           <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" 
                Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" 
                OnClick="btnOK_Click" TabIndex="150" Height="20px" />&nbsp;&nbsp;&nbsp;
           <asp:Button CssClass="button" ID="btnCancel"  runat="server" 
                Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" 
                CausesValidation="False" TabIndex="160" Height="20px"/>
           <br />       
        </div>
     </center>
        <input id="ShowPopup" runat="server" type="hidden" />
      </asp:Panel>      
      
    </div>

  </div>

<div id="bottom"><uc1:ServerDescription ID="ServerDescription1" runat="server" /></div>

</asp:Content>