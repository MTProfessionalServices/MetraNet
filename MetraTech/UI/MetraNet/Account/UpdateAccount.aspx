<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" 
AutoEventWireup="true" Inherits="Account_UpdateAccount" Title="MetraNet" 
Culture="auto" UICulture="auto" CodeFile="UpdateAccount.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
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

/// Parses account display value and returns account identifier
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
        if (obj != null) {obj.enable();}
    }
    for (var el in tmplData) {
        if (ctlMap[el] != null && typeof (ctlMap[el]) != "undefined") {
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
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1"></MTCDT:MTGenericForm>
  <!-- LOGIN INFORMATION -->
  <MT:MTPanel ID="MTPanel2" runat="server" meta:resourcekey="MTSection2Resource1">
  <div id="leftColumn2" class="LeftColumn">
    <MT:MTTextBoxControl ID="tbAuthenticationType" runat="server" ReadOnly="True" AllowBlank="True" Label="Authentication Type" TabIndex="150" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbAuthenticationTypeResource1" XType="TextField" XTypeNameSpace="form" />
    &nbsp;&nbsp;
    <MT:MTTextBoxControl ID="tbUserName" runat="server" ReadOnly="True" AllowBlank="True" Label="User Name" TabIndex="150" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbUserNameResource1" XType="TextField" XTypeNameSpace="form" />
    &nbsp;&nbsp;
    <MT:MTDropDown ID="ddBrandedSite" runat="server" AllowBlank="True" ListWidth="200" Label="Branded Site" TabIndex="180" ControlHeight="18" ControlWidth="200"  HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddBrandedSiteResource1" ReadOnly="True">
    </MT:MTDropDown>
  </div>
  <div id="rightColumn2" class="RightColumn">
    <MT:MTInlineSearch ID="tbAncestorAccount" runat="server" TabIndex="210" AllowBlank="True" Label="Parent Account" HideLabel="False" meta:resourcekey="tbAncestorAccountResource1"></MT:MTInlineSearch>
    &nbsp; &nbsp; &nbsp; &nbsp;
    <MT:MTTextBoxControl ID="tbStartDate" runat="server" AllowBlank="True" Label="Account Start Date"
      ReadOnly="True" ControlHeight="18" ControlWidth="200" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbStartDateResource1" TabIndex="0" XType="TextField" XTypeNameSpace="form" />
  </div>
  
  </MT:MTPanel>
  
  <div style="clear:both"></div>
  <!-- ACCOUNT INFORMATION --> 
  <MT:MTPanel ID="MTPanel3" runat="server" meta:resourcekey="MTSection3Resource1">
  <div id="leftColumn3" class="LeftColumn">
    <MT:MTDropDown ID="ddCurrency" runat="server" AllowBlank="True" Label="Currency" Listeners="{select:filterPricelists}" TabIndex="250" ControlHeight="18" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" meta:resourcekey="ddCurrencyResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTDropDown ID="ddPriceList" runat="server" AllowBlank="True" Label="Price List" TabIndex="260" ControlHeight="18" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddPriceListResource1" ReadOnly="False" >
      <asp:ListItem meta:resourcekey="ListItemResource1" Text="None"></asp:ListItem>
    </MT:MTDropDown>
    <MT:MTCheckBoxControl ID="cbBillable" runat="server" AllowBlank="True" BoxLabel="Billable" Text="billable" Value="billable" TabIndex="270" ControlHeight="18" ControlWidth="200" Checked="False" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbBillableResource1" Name="cbBillable" OptionalExtConfig="boxLabel:'Billable',&#13;&#10;                                            inputValue:'billable',&#13;&#10;                                            checked:false" ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />
    <MT:MTDropDown ID="ddStatusReason" runat="server" AllowBlank="True" Label="Status Reason" TabIndex="280" ControlHeight="18" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddStatusReasonResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTTextBoxControl ID="tbOther" runat="server" AllowBlank="True" Label="Other" TabIndex="290" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbOtherResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
  </div>
  <div id="rightColumn3" class="RightColumn">
    <MT:MTDropDown ID="ddLanguage" runat="server" AllowBlank="True" HideLabel="False" Label="Language" TabIndex="320" ControlHeight="18" ControlWidth="200" ListWidth="200" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddLanguageResource1" ReadOnly="False">
      <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="US English"></asp:ListItem>
    </MT:MTDropDown>
    <MT:MTDropDown ID="ddTimeZone" runat="server" AllowBlank="True" Label="Time Zone" TabIndex="330" ListWidth="340" ControlWidth="200" CssClass="18" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddTimeZoneResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTInlineSearch ID="tbPayer" runat="server" AllowBlank="True" Label="Payer" TabIndex="340" HideLabel="False" meta:resourcekey="tbPayerResource1"></MT:MTInlineSearch>
    <MT:MTDropDown ID="ddPaperInvoice" runat="server" Label="Paper Invoice" AllowBlank="True" TabIndex="350" ControlHeight="18" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddPaperInvoiceResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTBillingCycleControl TabIndex="360" ID="MTBillingCycleControl1" runat="server" LabelWidth="120" meta:resourcekey="ddBillingCycleControl1Resource1" Label="Billing Cycles"/> 
    <br />
    <MT:MTDropDown ID="ddSecurityQuestion" runat="server" AllowBlank="True" Label="Security Question" TabIndex="370" ControlHeight="18" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{}" meta:resourcekey="ddSecurityQuestionResource1" ReadOnly="False"></MT:MTDropDown>
    <MT:MTTextBoxControl ID="tbSecurityQuestionText" runat="server" AllowBlank="true" Label="Custom Security Question" TabIndex="375" ControlHeight="18" ControlWidth="200" HideLabel="false" LabelSeparator=":" Listeners="{}" meta:resourcekey="tbSecurityQuestionTextResource1" ReadOnly="false" />
    <MT:MTTextBoxControl ID="tbSecurityAnswer" runat="server" AllowBlank="True" Label="Security Answer" TabIndex="380" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":" LabelWidth="120" Listeners="{}" meta:resourcekey="tbSecurityAnswerResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
  </div>
  </MT:MTPanel>
  
  <!-- TAX INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericFormTax" runat="server" DataBinderInstanceName="MTDataBinder1" TabIndex="1000"></MTCDT:MTGenericForm>

  <div style="clear:both"></div>
  
  <!-- BUTTONS -->
  
    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">  
    <center> 
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
     <MT:MTButton ID="btnOk" OnClientClick="if(ValidateForm()) {/*enableCtrls();*/ return true;} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390"/>
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
        BindingSourceMember="Currency" ControlId="ddCurrency" ErrorMessageLocation="None" BindingProperty="SelectedValue">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="UserName" ControlId="tbUserName" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>     
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AncestorAccountID" ControlId="tbAncestorAccount" ErrorMessageLocation="None" BindingProperty="AccountID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="AccountStartDate" ControlId="tbStartDate" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Account" BindingProperty="SelectedValue"
        BindingSource="Account" BindingSourceMember="Name_Space" ControlId="ddBrandedSite"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="Language" ControlId="ddLanguage"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Account" BindingSource="Account"
        BindingSourceMember="PayerID" ControlId="tbPayer" ErrorMessageLocation="None" BindingProperty="AccountID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="InvoiceMethod" ControlId="ddPaperInvoice"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingProperty="Checked"
        BindingSource="Internal" BindingSourceMember="Billable" ControlId="cbBillable"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" ControlId="ddTimeZone" ErrorMessageLocation="None" BindingSourceMember="TimezoneID">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="StatusReason" ControlId="ddStatusReason"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingSource="Internal"
        BindingSourceMember="StatusReasonOther" ControlId="tbOther" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="SecurityQuestion" ControlId="ddSecurityQuestion"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="Text"
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
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="Internal" BindingProperty="SelectedValue"
        BindingSource="Internal" BindingSourceMember="PriceList" ControlId="ddPriceList"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" ControlId="btnOk" ErrorMessageLocation="RedTextAndIconBelow">
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
//      filterPricelists();
    });
    Ext.onReady(function () {
        addTemplateEvents();
        getTemplateData();
    });
  </script>
</asp:Content>

