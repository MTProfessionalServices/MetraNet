<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="AddAccount" Title="<%$Resources:Resource,TEXT_TITLE%>"
  Culture="auto" UICulture="auto" CodeFile="AddAccount.aspx.cs" %>

<%@ Import Namespace="MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script language="javascript" type="text/javascript">
  
function filterPricelists()
{
//  var cur = Ext.get("ctl00$ContentPlaceHolder1$ddCurrency");  
//  var store = converted_ctl00_ContentPlaceHolder1_ddPriceList.store; 
//  
//  if(store.realSnapshot && (store.realSnapshot != store.snapshot))
//  {
//    store.snapshot = store.realSnapshot;
//    delete store.realSnapshot;
//    store.clearFilter();
//  }
//  
//  store.filter('text',cur.getValue(), false, false);
//  store.realSnapshot = store.snapshot;
//  store.snapshot = store.data;
}

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
      okBox.set
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
    if(el) {el.enable();}
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
    if (el) { el.disable(); }
  }
}

/// parses account display value and returns account identifier
function getIdFromAccStr(accStr) {
    return accStr.substring(accStr.lastIndexOf('(') + 1, accStr.lastIndexOf(')'));
}

/// Collection contains all available account properties with matched client-side controls
var ctlMap = Ext.util.JSON.decode("<%=JSControlMapping%>");

/// Contains references to all available Ext.ComboBox objects. It needed to use correct methods to get/set their values and fire appropriate events. 
var cBoxes = {};

/// Reads template data returned by AJAX service. Set values from template to appropriate controls on page and then disable them.
function processTemplate(tmplData) {
    for (var id in ctlMap) {
        var obj = Ext.getCmp(ctlMap[id]);
        if (obj != null) { obj.enable(); }
    }
    for (var el in tmplData) {
        if (el == 'Account.StartDay' && tmplData['Internal.UsageCycleType'] == 'Bi_weekly') {
            var cb = cBoxes['<%=MTBillingCycleControl1.BiWeekly.ClientID%>'];
            if (typeof (cb) != 'undefined') {
                cb.setValue(tmplData[el]);
                cb.fireEvent('select');
            }
            var cmp = Ext.getCmp('<%=MTBillingCycleControl1.BiWeekly.ClientID%>');
            if (cmp != null) { cmp.disable(); }
        }
        else {
            if (ctlMap[el] != null && typeof (ctlMap[el]) != "undefined") {
                var ctl = Ext.get(ctlMap[el]);
                if (ctl != null) {
                    var cb = cBoxes[ctlMap[el]];
                    if (typeof (cb) != 'undefined') {
                        cb.setValue(tmplData[el]);
                        cb.fireEvent('select');
                    }
                    else {
                        ctl.dom.value = tmplData[el];
                    }
                    var cmp = Ext.getCmp(ctlMap[el]);
                    if (cmp != null) { cmp.disable(); }
                }
            }
        }
    }
    onAuthTypeChange(null, Ext.get("<%=ddAuthenticationType.ClientID %>").dom.value);
}

/// Sends AJAX request to get template data for account if available.
function getTemplateData() {
    var parentId = 1;
    var ancestor = Ext.get("<%=tbAncestorAccount.ClientID%>");
    if (typeof (ancestor) != 'undefined' && ancestor != null) {
        parentId = getIdFromAccStr(Ext.get("<%=tbAncestorAccount.ClientID%>").dom.value);
    }
    Ext.Ajax.request({
        url: '<%=GetVirtualFolder()%>/AjaxServices/LoadDataFromAccTemplate.aspx',
        params: {
            AccountID: '<%=Account._AccountID%>',
            ParentID: parentId,
            AccType: '<%=Account.AccountType%>'
        },
        timeout: 10000,
        success: function (response) {
            processTemplate(Ext.util.JSON.decode(response.responseText));
        },
        failure: function (response) {
        }
    });
}

/// onSelected event handler to handle changes in account ancestor field
function ancestorChange(e, t) {
    getTemplateData();
}

/// Enables all controls, which were disabled by template settings before submitting data
function enableCtrls() {
  for (var id in ctlMap) {
    var obj = Ext.getCmp(ctlMap[id]);
    if (obj != null) { obj.enable(); }
  }
  onAuthTypeChange(null, Ext.get("<%=ddAuthenticationType.ClientID %>").dom.value);
}

/// Add all neccessary event listeners for account template activity
function addTemplateEvents() {
    var ancestor = cBoxes["<%=tbAncestorAccount.ClientID%>"];
    if (typeof (ancestor) != 'undefined' && ancestor != null) {
        ancestor.addEvents('selected');
        ancestor.addListener('selected', ancestorChange);
    }
}

  </script>

  <MT:MTTitle ID="MTTitle1" Text="Add Account" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

  <div style="width: 810px">
    
    <!-- BILLING INFORMATION -->
    <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server"></MTCDT:MTGenericForm>
    
    <!-- LOGIN INFORMATION -->  
    <MT:MTPanel ID="MTPanel2" runat="server" meta:resourcekey="MTSection2Resource1">
    
    <div id="leftColumn2" class="LeftColumn">
      <MT:MTDropDown ID="ddAuthenticationType" runat="server" AllowBlank="False" Label="Authentication type"
        TabIndex="140" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{ 'change' : { fn: this.onAuthTypeChange, scope: this } }"
        meta:resourcekey="ddAuthenticationTypeResource1" ReadOnly="False">
      </MT:MTDropDown>
      <table>
        <tr>
          <td style="width: 330px; height: 20px; white-space: nowrap;">
            <span id="divIsValidUsername" style="float: left; display: none; margin-left: 120px;">
              <asp:Label ID="lblIsValidUsername" runat="server" ForeColor="Red" Text="Invalid Username"
                meta:resourcekey="lblIsValidUsernameResource1"></asp:Label>
            </span><span id="divUsernameOK" style="float: left; display: none; margin-left: 120px;">
              <asp:Label ID="lblUsernameOK" runat="server" ForeColor="Green" Text="User Name OK"
                meta:resourcekey="lblUsernameOKResource1"></asp:Label>
            </span>
          </td>
        </tr>
      </table>
      <table>
        <tr>
          <td>
            <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name"
              TabIndex="150" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":"
              LabelWidth="120" Listeners="{}" meta:resourcekey="tbUserNameResource1" ReadOnly="False"
              XType="TextField" XTypeNameSpace="form" />
          </td>
          <td style="height: 20px">
            <MT:MTButton ID="btnValidate" runat="server" onClientClick="onValidateUsername()" ServerSide="false" Text="Validate"
              Tooltip="Validate User Name" TabIndex="190" MinWidth="90" meta:resourcekey="btnValidateResource1" />
          </td>
        </tr>
        <tr>
          <td>
            <MT:MTPasswordMeter ID="tbPassword" runat="server" AllowBlank="False" Label="Password"
              TabIndex="160" ControlWidth="120" ControlHeight="18" HideLabel="False" LabelSeparator=":"
              LabelWidth="120" Listeners="{}" meta:resourcekey="tbPasswordResource1" ReadOnly="False"
              XType="PasswordMeter" XTypeNameSpace="ux" />
          </td>
          <td style="height: 20px">
            <MT:MTButton ID="btnGeneratePassword" runat="server" onClientClick="onGeneratePassword();" ServerSide="false"
              Text="Generate" Tooltip="Generate Password" TabIndex="200" MinWidth="90" meta:resourcekey="btnGeneratePasswordResource1" />
          </td>
        </tr>
      </table>
      <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password"
        OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbPassword'"
        TabIndex="170" ControlWidth="120" ControlHeight="18" HideLabel="False"
        LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbConfirmPasswordResource1"
        ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
      <MT:MTDropDown ID="ddBrandedSite" runat="server" AllowBlank="True" Label="Branded Site"
        TabIndex="180" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddBrandedSiteResource1" ReadOnly="False">
      </MT:MTDropDown>
    </div>
    <div id="rightColumn2"  class="RightColumn">
      <MT:MTInlineSearch ID="tbAncestorAccount" runat="server" TabIndex="210" AllowBlank="False"
        Label="Parent Account" HideLabel="False" meta:resourcekey="tbAncestorAccountResource1"></MT:MTInlineSearch>
      <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="True" Label="Account Start Date"
        TabIndex="220" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="120" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
        ReadOnly="False" XType="DateField" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbEmailNotification" runat="server" AllowBlank="True" BoxLabel="E-Mail Notification"
        Text="email" Value="email" TabIndex="230" ControlWidth="200" Checked="False" HideLabel="True"
        LabelSeparator=":" Listeners="{}" meta:resourcekey="cbEmailNotificationResource1"
        Name="cbEmailNotification" OptionalExtConfig="boxLabel:'E-Mail Notification',&#13;&#10;                                            inputValue:'email',&#13;&#10;                                            checked:false"
        ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbApplyDefaultPolicy" runat="server" BoxLabel="Apply Default Policy"
        Text="policy" Value="policy" TabIndex="240" ControlWidth="200" AllowBlank="False"
        Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyDefaultPolicyResource1"
        Name="cbApplyDefaultPolicy" OptionalExtConfig="boxLabel:'Apply Default Policy',&#13;&#10;inputValue:'policy',&#13;&#10;checked:false"
        ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbApplyTemplate" runat="server" BoxLabel="Apply Template"
        Text="template" Value="template" TabIndex="245" ControlWidth="200" AllowBlank="False"
        Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyTemplateResource1"
        Name="cbApplyTemplate" OptionalExtConfig="boxLabel:'Apply Template',&#13;&#10;inputValue:'template',&#13;&#10;checked:false"
        ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />        
    </div>
    
    </MT:MTPanel>
    
    <div style="clear: both">
    </div>
    <!-- ACCOUNT INFORMATION -->
    <MT:MTPanel ID="MTPanel3" runat="server" meta:resourcekey="MTSection3Resource1">
    
    <div id="leftColumn3" class="LeftColumn">
      <MT:MTDropDown ID="ddCurrency" runat="server" AllowBlank="True" Label="Currency"
        TabIndex="250" Listeners="{select:filterPricelists}" ControlWidth="200" ListWidth="200" HideLabel="False"
        LabelSeparator=":" meta:resourcekey="ddCurrencyResource1" ReadOnly="False">
      </MT:MTDropDown>
      <MT:MTDropDown ID="ddPriceList" runat="server" AllowBlank="True" Label="Price List"
        ListWidth="200" TabIndex="260" ControlWidth="200" HideLabel="False" LabelSeparator=":"
        meta:resourcekey="ddPriceListResource1" ReadOnly="False">        
      </MT:MTDropDown>
      <MT:MTCheckBoxControl ID="cbBillable" runat="server" AllowBlank="True" BoxLabel="Billable"
        Text="billable" Value="billable" TabIndex="270" ControlWidth="200" ReadOnly="False"
        Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbBillableResource1"
        Name="cbBillable" OptionalExtConfig="boxLabel:'Billable',&#13;&#10;                                            inputValue:'billable',&#13;&#10;                                            checked:false"
        XType="Checkbox" XTypeNameSpace="form" />
      <MT:MTDropDown ID="ddStatusReason" runat="server" AllowBlank="True" Label="Status Reason"
        TabIndex="280" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddStatusReasonResource1" ReadOnly="False">
      </MT:MTDropDown>
      <MT:MTTextBoxControl ID="tbOther" runat="server" AllowBlank="True" Label="Other"
        TabIndex="290" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="120" Listeners="{}" meta:resourcekey="tbOtherResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" />
    </div>
    <div id="rightColumn3" class="RightColumn">
      <MT:MTDropDown ID="ddLanguage" runat="server" AllowBlank="True" HideLabel="False"
        Label="Language" TabIndex="320" ControlWidth="200"  ListWidth="200" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddLanguageResource1" ReadOnly="False">
      </MT:MTDropDown>
      <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone"
        TabIndex="330" ListWidth="340" ControlWidth="200" HideLabel="False" LabelSeparator=":"
        Listeners="{}" meta:resourcekey="ddTimeZoneResource1" ReadOnly="False">
      </MT:MTDropDown>
      <MT:MTInlineSearch ID="tbPayer" runat="server" AllowBlank="True" Label="Payer" TabIndex="340"
        HideLabel="False" meta:resourcekey="tbPayerResource1"></MT:MTInlineSearch>
      <MT:MTDropDown ID="ddPaperInvoice" runat="server" Label="Paper Invoice" AllowBlank="True"
        TabIndex="350" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddPaperInvoiceResource1" ReadOnly="False">
      </MT:MTDropDown>   
      <MT:MTBillingCycleControl TabIndex="360" ID="MTBillingCycleControl1" runat="server"
        LabelWidth="120" meta:resourcekey="ddBillingCycleControl1Resource1" Label="Billing Cycles"    
      />      
      <br />      
      <MT:MTDropDown ID="ddSecurityQuestion" runat="server" AllowBlank="True" Label="Security Question"
        TabIndex="370" ListWidth="200" ControlWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}"
        meta:resourcekey="ddSecurityQuestionResource1" ReadOnly="False">
      </MT:MTDropDown>
      <MT:MTTextBoxControl ID="tbSecurityQuestionText" runat="server" AllowBlank="true" Label="Custom Security Question" TabIndex="375" ControlHeight="18" ControlWidth="200" HideLabel="false" LabelSeparator=":" Listeners="{}" meta:resourcekey="tbSecurityQuestionTextResource1" ReadOnly="false" />
      <MT:MTTextBoxControl ID="tbSecurityAnswer" runat="server" AllowBlank="True" Label="Security Answer"
        TabIndex="380" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="120" Listeners="{}" meta:resourcekey="tbSecurityAnswerResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" />
    </div>
    
    
    </MT:MTPanel>
    
  <!-- TAX INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericFormTax" runat="server" DataBinderInstanceName="MTDataBinder1" TabIndex="1000"></MTCDT:MTGenericForm>

    <div style="clear: both">
    </div>
    
  <!-- BUTTONS -->
 
  <div class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
     <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if(Validate()) {/*enableCtrls();*/ return true;} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
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
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="Currency" ControlId="ddCurrency" ErrorMessageLocation="None"
        BindingProperty="SelectedValue">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="UserName" ControlId="tbUserName" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="Password_" ControlId="tbPassword" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AncestorAccountID" ControlId="tbAncestorAccount" ErrorMessageLocation="None"
        BindingProperty="AccountID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AccountStartDate" ControlId="tbStartDate" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingProperty="Checked"
        BindingSource="Account" BindingSourceMember="ApplyDefaultSecurityPolicy" ControlId="cbApplyDefaultPolicy"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingProperty="SelectedValue"
        BindingSource="Account" BindingSourceMember="Name_Space" ControlId="ddBrandedSite"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="Language" ControlId="ddLanguage"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="PayerID" ControlId="tbPayer" ErrorMessageLocation="None" BindingProperty="AccountID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="InvoiceMethod" ControlId="ddPaperInvoice"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="Checked"
        BindingSource="Internal" BindingSourceMember="Billable" ControlId="cbBillable"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" ControlId="ddTimeZone" ErrorMessageLocation="None" BindingSourceMember="TimezoneID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="StatusReason" ControlId="ddStatusReason"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="StatusReasonOther" ControlId="tbOther" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="SecurityQuestion" ControlId="ddSecurityQuestion"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
        BindingSource="Internal" BindingSourceMember="SecurityQuestionText" ControlId="tbSecurityQuestionText"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="SecurityAnswer" ControlId="tbSecurityAnswer" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="UsageCycleType" ControlId="MTBillingCycleControl1.CycleList"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="DayOfWeek" ControlId="MTBillingCycleControl1.Weekly" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="StartMonth" ControlId="MTBillingCycleControl1.Quarterly_Month"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="StartDay" ControlId="MTBillingCycleControl1.Quarterly_Day"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="Account" BindingSourceMember="StartYear"
        ControlId="MTBillingCycleControl1.StartYear" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="DayOfMonth" ControlId="MTBillingCycleControl1.Monthly" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="FirstDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_First"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="SecondDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_Second"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="PriceList" ControlId="ddPriceList" BindingProperty="SelectedValue" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnOK" ErrorMessageLocation="RedTextAndIconBelow">
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
  <script type="text/javascript" language="javascript">
    Ext.onReady(function() {
     // filterPricelists();
    });
    
    function Validate()
    {
     var username = Ext.get("<%= tbUserName.ClientID%>").dom.value;
     var passwd =  Ext.get("<%= tbPassword.ClientID%>").dom.value;
     var confpasswd =  Ext.get("<%= tbConfirmPassword.ClientID%>").dom.value;
     var authType = Ext.get("<%= ddAuthenticationType.ClientID%>").dom.value;

     if ((authType == '<%=AuthenticationType.MetraNetInternal.ToString()%>') && ((passwd == '') || (confpasswd == '')) || (username == ''))
      {
         Ext.Msg.show({
                             title: TEXT_ERROR,
                             msg: TEXT_VALIDATION_ERROR,
                             buttons: Ext.Msg.OK,               
                             icon: Ext.MessageBox.ERROR
                     });
        return false;
      } 
      else if(passwd != confpasswd)
      {
         Ext.Msg.show({
                                title: TEXT_ERROR,
                                msg: TEXT_PASSWORDS_DO_NOT_MATCH,
                                buttons: Ext.Msg.OK,               
                                icon: Ext.MessageBox.ERROR
                              });
         return false;         
      }     
      else
      {
        return ValidateForm(); 
      }
    }
    
    Ext.onReady(function () {
      onAuthTypeChange(null, Ext.get("<%=ddAuthenticationType.ClientID %>").dom.value);
    });
    Ext.onReady(function () {
      addTemplateEvents();
      getTemplateData();
    });
  </script>
</asp:Content>
