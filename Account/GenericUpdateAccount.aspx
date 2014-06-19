<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" 
AutoEventWireup="true" Inherits="GenericUpdateAccount" Title="MetraNet" meta:resourcekey="PageResource1" 
Culture="auto" UICulture="auto" CodeFile="GenericUpdateAccount.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
  function filterPricelists() {
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
</script>

<MT:MTTitle ID="MTTitle1" Text="Update Account" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
<div style="width:810px">
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    </b>
  </div>

  <!-- BILLING INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="MTGenericForm1Resource1"></MTCDT:MTGenericForm>
      <!-- LOGIN INFORMATION -->
    <MT:MTPanel ID="pnlLoginInfo" runat="server" Text="Login Information" meta:resourcekey="pnlLoginInfoResource1">
      <div id="leftColumn2" class="LeftColumn">
        <table>
          <tr>
            <td colspan="2">
              <span id="divIsValidUsername" style="float: left; display: none; margin-left: 120px;">
                <asp:Label ID="lblIsValidUsername" runat="server" ForeColor="Red" Text="Invalid Username"
                  meta:resourcekey="lblIsValidUsernameResource1"></asp:Label>
              </span><span id="divUsernameOK" style="float: left; display: none; margin-left: 120px;">
                <asp:Label ID="lblUsernameOK" runat="server" ForeColor="Green" Text="User Name OK"
                  meta:resourcekey="lblUsernameOKResource1"></asp:Label>
              </span>
            </td>
          </tr>
          <tr>
            <td>
              <MT:MTTextBoxControl ID="tbUserName" runat="server" AllowBlank="False" Label="User Name"
                ControlWidth="150" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120"
                Listeners="{}" meta:resourcekey="tbUserNameResource1" ReadOnly="True" XType="TextField"
                XTypeNameSpace="form" />
            </td>
<%-- 
            <td style="height: 20px">
              <MT:MTButton ID="btnValidate" runat="server" OnClientClick="onValidateUsername()"
                ServerSide="false" Text="Validate" ToolTip="Validate User Name" TabIndex="190"
                MinWidth="90" meta:resourcekey="btnValidateResource1" />
            </td>
--%>
          </tr>
<%-- 
           <tr>
            <td>
              <MT:MTPasswordMeter ID="tbPassword" runat="server" AllowBlank="False" Label="Password"
                TabIndex="160" ControlWidth="150" ControlHeight="18" HideLabel="False" LabelSeparator=":"
                LabelWidth="120" Listeners="{}" meta:resourcekey="tbPasswordResource1" ReadOnly="False"
                XType="PasswordMeter" XTypeNameSpace="ux" />
            </td>
            <td style="height: 20px">
              <MT:MTButton ID="btnGeneratePassword" runat="server" OnClientClick="onGeneratePassword();"
                ServerSide="false" Text="Generate" ToolTip="Generate Password" TabIndex="200" MinWidth="90"
                meta:resourcekey="btnGeneratePasswordResource1" />
            </td>
          </tr>
--%>
        </table>
<%--        <MT:MTTextBoxControl ID="tbPassword" runat="server" AllowBlank="False" Label="Password"
          ControlWidth="150" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120"
          meta:resourcekey="tbPasswordResource1" ReadOnly="False" OptionalExtConfig="inputType:'password'"
          XType="TextField" XTypeNameSpace="form" VType="password" />

        <MT:MTTextBoxControl ID="tbConfirmPassword" runat="server" AllowBlank="False" Label="Confirm Password"
          OptionalExtConfig="inputType:'password',initialPassField:'ctl00_ContentPlaceHolder1_tbPassword'"
          VType="password" ControlWidth="150" ControlHeight="18" HideLabel="False" LabelSeparator=":"
          LabelWidth="120"  meta:resourcekey="tbConfirmPasswordResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" TabIndex="170" />--%>
        <MT:MTDropDown ID="ddBrandedSite" runat="server" AllowBlank="True" Label="Branded Site"
          ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" meta:resourcekey="ddBrandedSiteResource1"
          ReadOnly="True" TabIndex="180">
          <asp:ListItem Value="MT" meta:resourcekey="ListItemResource1">MetraView</asp:ListItem>
        </MT:MTDropDown>
      </div>
      <div id="rightColumn2" class="RightColumn">
        <MT:MTInlineSearch ID="tbAncestorAccountID" runat="server" AllowBlank="False" Label="Parent Account"
          HideLabel="False" meta:resourcekey="tbAncestorAccountIDResource1" ReadOnly="False" TabIndex="190"></MT:MTInlineSearch>
        <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="True" Label="Account Start Date"
          ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120"
          meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT"
          ReadOnly="True" XType="DateField" XTypeNameSpace="form" />
<%--
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
        <MT:MTCheckBoxControl ID="MTCheckBoxControl1" runat="server" BoxLabel="Apply Template"
          Text="template" Value="template" TabIndex="245" ControlWidth="200" AllowBlank="False"
          Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyTemplateResource1"
          Name="cbApplyTemplate" OptionalExtConfig="boxLabel:'Apply Template',&#13;&#10;inputValue:'template',&#13;&#10;checked:false"
          ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
--%>
      </div>
      <div style="clear: both">
      </div>
    </MT:MTPanel>
    <!-- ACCOUNT INFORMATION -->
     <MT:MTPanel ID="pnlAccountInfo" runat="server" Text="Account Information" meta:resourcekey="MTSection3Resource1">
      <div id="leftColumn3" class="LeftColumn">
        <MT:MTDropDown ID="ddCurrency" runat="server" AllowBlank="True" Label="Currency"
          TabIndex="250" Listeners="{select:filterPricelists}" ControlWidth="200" ListWidth="200"
          HideLabel="False" LabelSeparator=":" meta:resourcekey="ddCurrencyResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTDropDown ID="ddPriceList" runat="server" AllowBlank="True" Label="Price List" 
          TabIndex="260" ControlHeight="18" ControlWidth="200" ListWidth="200" 
          HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddPriceListResource1" ReadOnly="False" >
          <asp:ListItem meta:resourcekey="ListItemResource1" Text="None"></asp:ListItem>
        </MT:MTDropDown>
        <MT:MTCheckBoxControl ID="cbBillable" runat="server" AllowBlank="True" BoxLabel="Billable"
          Text="billable" Value="billable" TabIndex="270" ControlWidth="200" ReadOnly="False"
          Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbBillableResource1"
          Name="cbBillable" OptionalExtConfig="boxLabel:'Billable',&#13;&#10;                                            inputValue:'billable',&#13;&#10;                                            checked:false"
          XType="Checkbox" XTypeNameSpace="form" />
        <MT:MTDropDown ID="ddStatusReason" runat="server" AllowBlank="True" Label="Status Reason"
          TabIndex="280" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":"
          Listeners="{}" meta:resourcekey="ddStatusReasonResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTTextBoxControl ID="tbOther" runat="server" AllowBlank="True" Label="Other"
          TabIndex="290" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
          LabelWidth="120" Listeners="{}" meta:resourcekey="tbOtherResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" />
        <MT:MTCheckBoxControl ID="cbTaxExempt" runat="server" BoxLabel="Tax Exempt" Text="tax"
          Value="tax" TabIndex="300" ControlWidth="200" AllowBlank="False" Checked="False"
          HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbTaxExemptResource1"
          Name="cbTaxExempt" OptionalExtConfig="boxLabel:'Tax Exempt',&#13;&#10;                                            inputValue:'tax',&#13;&#10;                                            checked:false"
          ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
        <MT:MTTextBoxControl ID="tbTaxExemptID" runat="server" AllowBlank="True" Label="Tax Exempt ID"
          TabIndex="310" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
          LabelWidth="120" Listeners="{}" meta:resourcekey="tbTaxExemptIDResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" />
        &nbsp;&nbsp;
      </div>
      <div id="rightColumn3" class="RightColumn">
        <MT:MTDropDown ID="ddLanguage" runat="server" AllowBlank="True" HideLabel="False"
          Label="Language" TabIndex="320" ControlWidth="200" ListWidth="200" LabelSeparator=":"
          Listeners="{}" meta:resourcekey="ddLanguageResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone"
          TabIndex="330" ListWidth="340" ControlWidth="200" HideLabel="False" LabelSeparator=":"
          Listeners="{}" meta:resourcekey="ddTimeZoneResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTInlineSearch ID="tbPayer" runat="server" AllowBlank="True" Label="Payer" TabIndex="340"
          HideLabel="False" meta:resourcekey="tbPayerResource1"></MT:MTInlineSearch>
        <MT:MTDropDown ID="ddPaperInvoice" runat="server" Label="Paper Invoice" AllowBlank="True"
          TabIndex="350" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":"
          Listeners="{}" meta:resourcekey="ddPaperInvoiceResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTBillingCycleControl TabIndex="360" ID="MTBillingCycleControl1" runat="server"
          LabelWidth="120" meta:resourcekey="ddBillingCycleControl1Resource1" Label="Billing Cycles" />
        <br />
        <MT:MTDropDown ID="ddSecurityQuestion" runat="server" AllowBlank="True" Label="Security Question"
          TabIndex="370" ListWidth="200" ControlWidth="200" HideLabel="False" LabelSeparator=":"
          Listeners="{}" meta:resourcekey="ddSecurityQuestionResource1" ReadOnly="False">
        </MT:MTDropDown>
        <MT:MTTextBoxControl ID="tbSecurityQuestionText" runat="server" AllowBlank="true" Label="Custom Security Question" TabIndex="375" ControlHeight="18" ControlWidth="200" HideLabel="false" LabelSeparator=":" Listeners="{}" meta:resourcekey="tbSecurityQuestionTextResource1" ReadOnly="false" />
        <MT:MTTextBoxControl ID="tbSecurityAnswer" runat="server" AllowBlank="True" Label="Security Answer"
          TabIndex="380" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
          LabelWidth="120" Listeners="{}" meta:resourcekey="tbSecurityAnswerResource1" ReadOnly="False"
          XType="TextField" XTypeNameSpace="form" />
      </div>
    </MT:MTPanel>

  <MT:MTCheckBoxControl ID="cbApplyTemplate" runat="server" BoxLabel="Apply Template"
    Text="template" Value="template" TabIndex="95" ControlWidth="200" AllowBlank="False"
    Checked="False" Visible="false" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyTemplateResource1"
    Name="cbApplyTemplate" OptionalExtConfig="boxLabel:'Apply Template',&#13;&#10;inputValue:'template',&#13;&#10;checked:false"
    ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />  
       
  <!-- BUTTONS -->
  <center>
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" OnClick="btnCancel_Click" TabIndex="110" />
     <br />       
  </div>
  </center>

</div>
  
<br />

 <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem20" runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="Currency" ControlId="ddCurrency" ErrorMessageLocation="None"
        BindingProperty="SelectedValue">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="Account" BindingSourceMember="username"
        ControlId="tbUserName" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="Account" BindingSourceMember="AncestorAccountID"
        ControlId="tbAncestorAccountID" BindingProperty="AccountID" BindingMetaDataAlias="Account"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="Account" BindingSourceMember="Password_"
        ControlId="tbPassword" BindingMetaDataAlias="Account" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="Name_Space" ControlId="ddBrandedSite" BindingMetaDataAlias="Account"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="Language" ControlId="ddLanguage" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="TimeZoneID" ControlId="ddTimeZone" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AccountStartDate" ControlId="tbStartDate" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
        BindingSource="Internal" BindingSourceMember="SecurityQuestionText" ControlId="tbSecurityQuestionText"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
        BindingSource="Internal" BindingSourceMember="SecurityAnswer" ControlId="tbSecurityAnswer"
        ErrorMessageLocation="None" >
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="PriceList" ControlId="ddPriceList"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
       <MT:MTDataBindingItem ID="MTDataBindingItem11" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="InvoiceMethod" ControlId="ddPaperInvoice"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
            <MT:MTDataBindingItem ID="MTDataBindingItem12" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="SecurityQuestion" ControlId="ddSecurityQuestion"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem13" runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="StatusReason" ControlId="ddStatusReason"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem14" runat="server" BindingProperty="SelectedValue" BindingSource="Internal"
        BindingSourceMember="UsageCycleType" ControlId="MTBillingCycleControl1.CycleList"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
       <MT:MTDataBindingItem ID="MTDataBindingItem15" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="DayOfWeek" ControlId="MTBillingCycleControl1.Weekly" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem16" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="StartMonth" ControlId="MTBillingCycleControl1.Quarterly_Month"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem17" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="StartDay" ControlId="MTBillingCycleControl1.Quarterly_Day"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
            <MT:MTDataBindingItem ID="MTDataBindingItem18" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="FirstDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_First"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem19" runat="server" BindingProperty="SelectedValue" BindingSource="Account"
        BindingSourceMember="SecondDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_Second"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
    </DataBindingItems>
    <MetaDataMappings>
      <MT:MetaDataItem Alias="Account" AliasBaseType="CoreSubscriber" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
      <MT:MetaDataItem Alias="Internal" AliasBaseType="CoreSubscriber.Internal" AssemblyName="MetraTech.DomainModel.AccountTypes.Generated.dll"
        MetaType="DomainModel" Value="CoreSubscriber" />
    </MetaDataMappings>
  </MT:MTDataBinder>
    <script type="text/javascript" language="javascript">
      Ext.onReady(function () {
        //      filterPricelists();
      });
  </script>
</asp:Content>




