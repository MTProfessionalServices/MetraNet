<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="AddSystemUser" Title="MetraNet - Add System Account" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="AddSystemUser.aspx.cs" %>


<%@ Import Namespace="MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

function onGeneratePassword()
{
  //Execute: function(operation, args, binding, callbackMethod)
  pageNav.Execute("AddAccountEvents_GeneratePassword_Client", null, UpdatePassword);
}

function UpdatePassword(data)
{
  var passwordBox = Ext.get("<%=tbPassword.ClientID %>");
  passwordBox.dom.value = data.Out_Password;
  Ext.get("<%=tbConfirmPassword.ClientID %>").dom.value = data.Out_Password;
}

function onValidateFailure()
{
    var errBox = document.getElementById("divIsValidUsername");
    var okBox = document.getElementById("divUsernameOK");
    
    //exit if cannot get handle, exit
    if(errBox == null) 
    {
      return;
    }
    if(!okBox)
    {
      return;
    }
    errBox.style.display = "block";
    okBox.style.display = "none";
}

function onValidateUsername()
{
  var username = Ext.get("<%= tbUserName.ClientID%>").dom.value;
  if(username.length > 255)
  {
    onValidateFailure();
    return;
  }
  
  var url = "/MetraNet/AjaxServices/FindAccountSvc.aspx";
  var conn = new Ext.data.Connection();
  conn.request({
    url: url,
    method: 'POST',
    params:{
      query:username,
      start:0,
      limit:10
    },
      
    failure: onValidateFailure,
    
    success: function(responseObject){

      var responseText = responseObject.responseText;
      
      var isUsernameUnique = false;
      
      if ((responseText != "") && (responseText == "{\"TotalRows\":\"0\",\"Items\":[]}"))
      {
        isUsernameUnique = true;
      }
      
      var errBox = document.getElementById("divIsValidUsername");
      var okBox = document.getElementById("divUsernameOK");
      
      //exit if cannot get handle, exit
      if((errBox == null) || (okBox == null))
      {
        return;
      }
           
      //check the output from the service call
      if (!isUsernameUnique)
      {
        errBox.style.display = "block";
        okBox.style.display = "none";
      }
      else
      {
        errBox.style.display = "none";
        okBox.style.display = "block";
      }
    }
  });
  
}

function onAuthTypeChange(selectField, value) {
  var el,
      ext = window.Ext;
  if (value == '<%=AuthenticationType.MetraNetInternal.ToString()%>') {
    el = ext.getCmp("<%=tbPassword.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=tbConfirmPassword.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=btnGeneratePassword.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=ddSecurityQuestion.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=tbSecurityQuestionText.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=tbSecurityAnswer.ClientID%>");
    if (el) { el.enable(); }
    el = ext.getCmp("<%=btnValidate.ClientID%>");
    if(el) { el.enable(); }
  } else {
    el = ext.getCmp("<%=tbPassword.ClientID%>");
    if (el) { el.el.dom.value = ""; el.disable(); }
    el = ext.getCmp("<%=tbConfirmPassword.ClientID%>");
    if (el) { el.el.dom.value = ""; el.disable(); }
    el = ext.getCmp("<%=btnGeneratePassword.ClientID%>");
    if (el) { el.disable(); }
    el = ext.getCmp("<%=ddSecurityQuestion.ClientID%>");
    if (el) { el.disable(); }
    el = ext.getCmp("<%=tbSecurityQuestionText.ClientID%>");
    if (el) { el.disable(); }
    el = ext.getCmp("<%=tbSecurityAnswer.ClientID%>");
    if (el) { el.disable(); }
    el = ext.getCmp("<%=btnValidate.ClientID%>");
    if(el) { el.disable(); }
  }
}

</script>
<MT:MTTitle ID="MTTitle1" Text="Add System User" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

<div style="width:810px">

  <!-- BILLING INFORMATION -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server"></MTCDT:MTGenericForm>

 <!-- LOGIN INFORMATION -->
  <MT:MTPanel ID="pnlLoginInfo" runat="server" meta:resourcekey="MTSection2Resource1">
  <div id="leftColumn2" class="LeftColumn">
    <MT:MTDropDown ID="ddAuthenticationType" runat="server" AllowBlank="False" Label="Authentication type"
      TabIndex="140" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{ 'change' : { fn: this.onAuthTypeChange, scope: this } }"
      meta:resourcekey="ddAuthenticationTypeResource1" ReadOnly="False">
    </MT:MTDropDown>
    <table>
      <tr>
        <td style="width: 300px; height: 20px; white-space:nowrap;"><span id="divIsValidUsername" style="float:left;display:none;margin-left:120px;">
              <asp:Label ID="lblIsValidUsername" runat="server" ForeColor="Red" Text="Invalid Username" meta:resourcekey="lblIsValidUsernameResource1"></asp:Label>      
            </span>  
            <span id="divUsernameOK" style="float:left;display:none;margin-left:120px;">
              <asp:Label ID="lblUsernameOK" runat="server" ForeColor="Green" Text="User Name OK" meta:resourcekey="lblUsernameOKResource1"></asp:Label>
            </span>
        </td>
      </tr>
    </table>
    <table>
      <tr>
        <td><MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name" TabIndex="150" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbUserNameResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" /></td>
        <td style="height: 20px"><MT:MTButton ID="btnValidate" runat="server" ServerSide="false" onClientClick="onValidateUsername()" Text="Validate" Tooltip="Validate User Name" TabIndex="190" MinWidth="90" meta:resourcekey="btnValidateResource1" /></td>
      </tr>
      <tr>
        <td><MT:MTPasswordMeter ID="tbPassword" runat="server" AllowBlank="False" Label="Password" TabIndex="160" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbPasswordResource1" ReadOnly="False" XType="PasswordMeter" XTypeNameSpace="ux" /></td>
        <td style="height: 20px">
        <MT:MTButton ID="btnGeneratePassword" runat="server" ServerSide="false" OnClientClick="onGeneratePassword()" Text="Generate" Tooltip="Generate Password" TabIndex="200" MinWidth="90" meta:resourcekey="btnGeneratePasswordResource1" /></td>
      </tr>
    </table>
    <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password" OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbPassword'" TabIndex="170" VType="password" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbConfirmPasswordResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddBrandedSite" runat="server" AllowBlank="True" Label="Branded Site" ListWidth="200" TabIndex="180" ControlWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddBrandedSiteResource1" ReadOnly="False">
      <asp:ListItem Value="MT" meta:resourcekey="ListItemResource1">MetraView</asp:ListItem>
    </MT:MTDropDown>
  </div>
  <div id="rightColumn2" class="RightColumn">
    <MT:MTInlineSearch ID="tbAncestorAccount" runat="server" TabIndex="210" AllowBlank="True" Label="Parent Account" HideLabel="False" meta:resourcekey="tbAncestorAccountResource1"></MT:MTInlineSearch>
    <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="True" Label="Account Start Date" TabIndex="220" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
    <MT:MTCheckBoxControl ID="cbEmailNotification" runat="server" AllowBlank="True" BoxLabel="E-Mail Notification" Text="email" Value="email" TabIndex="230" ControlWidth="200" Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbEmailNotificationResource1" Name="cbEmailNotification" OptionalExtConfig="boxLabel:'E-Mail Notification',&#13;&#10;                                            inputValue:'email',&#13;&#10;                                            checked:false" ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
    <MT:MTCheckBoxControl ID="cbApplyDefaultPolicy" runat="server" BoxLabel="Apply Default Policy" Text="policy" Value="policy" TabIndex="240" ControlWidth="200" AllowBlank="False" Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyDefaultPolicyResource1" Name="cbApplyDefaultPolicy" OptionalExtConfig="boxLabel:'Apply Default Policy',&#13;&#10;                                            inputValue:'policy',&#13;&#10;                                            checked:false" ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
  </div>
  <div style="clear:both"></div>
   </MT:MTPanel>
  <!-- ACCOUNT INFORMATION -->   
  <MT:MTPanel ID="pnlAccountInfo" Width="720" runat="server" meta:resourcekey="MTSection3Resource1" Text="Account Information">
  <div id="leftColumn3" class="LeftColumn">
    <MT:MTDropDown ID="ddLanguage" runat="server" AllowBlank="True" HideLabel="False" Label="Language" TabIndex="320" ControlWidth="200" ListWidth="200" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddLanguageResource1" ReadOnly="False">
      <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">US English</asp:ListItem>
    </MT:MTDropDown>
  </div>
  <div id="rightColumn3" class="RightColumn">
    <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone" TabIndex="330" ListWidth="340" ControlWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddTimeZoneResource1" ReadOnly="False"></MT:MTDropDown>
    <br />
    <MT:MTDropDown ID="ddSecurityQuestion" runat="server" AllowBlank="True" Label="Security Question" TabIndex="370" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddSecurityQuestionResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTTextBoxControl ID="tbSecurityQuestionText" runat="server" AllowBlank="true" Label="Custom Security Question" TabIndex="375" ControlHeight="18" ControlWidth="200" HideLabel="false" LabelSeparator=":" Listeners="{}" meta:resourcekey="tbSecurityQuestionTextResource1" ReadOnly="false" />
    <MT:MTTextBoxControl ID="tbSecurityAnswer" runat="server" AllowBlank="True" Label="Security Answer" TabIndex="380" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbSecurityAnswerResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
  </div>
  <div style="clear:both"></div>
  </MT:MTPanel>
  
  <!-- BUTTONS -->

 
    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
     <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="Button1" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" meta:resourcekey="btnOKResource1" OnClick="btnOK_Click" TabIndex="500" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" meta:resourcekey="btnCancelResource1" TabIndex="501" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>  
      </center>
    </div>
  </div>
</div>
  
  <br />

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="Account" BindingSourceMember="username"
        ControlId="tbUserName" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="Account" BindingSourceMember="AncestorAccountID"
        ControlId="tbAncestorAccount" BindingProperty="AccountID" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="Account" BindingSourceMember="Password_"
        ControlId="tbPassword" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>      
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="Name_Space" ControlId="ddBrandedSite" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="Checked" BindingSource="Account"
        BindingSourceMember="ApplyDefaultSecurityPolicy" ControlId="cbApplyDefaultPolicy" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="Language" ControlId="ddLanguage" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="TimeZoneID" ControlId="ddTimeZone" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>      
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AccountStartDate" ControlId="tbStartDate" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="SecurityQuestion" ControlId="ddSecurityQuestion"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
        BindingSource="Internal" BindingSourceMember="SecurityQuestionText" ControlId="tbSecurityQuestionText"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityAnswer" ControlId="tbSecurityAnswer" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>      
    </DataBindingItems>
    <MetaDataMappings>
      <MT:MetaDataItem Alias="Account" AliasBaseType="CoreSubscriber" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="Internal" AliasBaseType="CoreSubscriber.Internal" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="BillTo" AliasBaseType="CoreSubscriber.LDAP.Item" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
    </MetaDataMappings>
   </MT:MTDataBinder>

<script language="javascript" type="text/javascript">
Ext.onReady(function () {
  onAuthTypeChange(null, Ext.get("<%=ddAuthenticationType.ClientID %>").dom.value);
});
</script>
</asp:Content>




