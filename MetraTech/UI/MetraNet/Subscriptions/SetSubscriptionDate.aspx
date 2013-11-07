<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_SetSubscriptionDate" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="SetSubscriptionDate.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script  type="text/javascript" language="javascript">
    function CheckEndDate() {
      var endDate = Ext.getCmp("EndDate");
      endDate.compareValue = this.value;
    }
  </script>
  
  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Subscription Details" meta:resourcekey="MTTitle1Resource1" />
  <div>
        <asp:Label ID="LblErrorMessage" runat="server" CssClass="ErrorMessage"></asp:Label>
  </div>
  <br />
  
  <!-- Details -->
  <MT:MTPanel ID="pnlMain" runat="server" Text="Details" Collapsible="false" meta:resourcekey="pnlMain">
  <div class="LeftColumn">
      <MT:MTLiteralControl ID="lblDisplayName" runat="server" Label="Subscription" AllowBlank="False"  ControlWidth="550" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
      <MT:MTLiteralControl ID="lblDescDispName" runat="server" Label="Description" AllowBlank="False" ControlWidth="550" meta:resourcekey="lblDescDispNameResource1" ReadOnly="False"  />
  
      <div class="InfoMessage" style="margin-left:120px;width:400px;">
        <asp:Label ID="LblMessage" runat="server"></asp:Label>
      </div>
      <br />
      <MT:MTDatePicker ID="StartDate" runat="server" Label="Start Date" ClientIDMode="Static" AllowBlank="False" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{'change' : CheckEndDate}" meta:resourcekey="StartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="0" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbStartNextBillingPeriod" runat="server" ControlWidth="500" BoxLabel="Next start of payer's billing period after this date" Text="c1" Value="c1" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbStartNextBillingPeriodResource1" Name="cbStartNextBillingPeriod" OptionalExtConfig="boxLabel:'Next start of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c1',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
      <br />
      <MT:MTDatePicker ID="EndDate" runat="server" Label="End Date"  ClientIDMode="Static" AllowBlank="true" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="EndDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="0" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbEndNextBillingPeriod" runat="server" ControlWidth="500" BoxLabel="Next end of payer's billing period after this date" Text="c2" Value="c2" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbEndNextBillingPeriodResource1" Name="cbEndNextBillingPeriod" OptionalExtConfig="boxLabel:'Next end of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c2',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
  </div>
  </MT:MTPanel>
  
  <!-- Properties -->
  <MT:MTPanel ID="pnlSubscriptionProperties" runat="server" Text="Properties" Collapsible="false" meta:resourcekey="pnlSubscriptionProperties">
 
  </MT:MTPanel>
  
  <!-- BUTTONS -->
  <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">
    <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true) {return ValidateForm();} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="500" />
          </td>
          <td  class="x-panel-btn-td">            
            <MT:MTButton ID="btnCancel"  Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" TabIndex="501" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
       </center>     
    </div>
  </div>
 
  <br />
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" BindingSource="SubscriptionInstance.ProductOffering" BindingSourceMember="DisplayName"
        ControlId="lblDisplayName" ErrorMessageLocation="None" BindingMetaDataAlias="SubscriptionInstance.ProductOffering">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="SubscriptionInstance.SubscriptionSpan"
        BindingSourceMember="StartDate" ControlId="StartDate" ErrorMessageLocation="None" BindingMetaDataAlias="SubscriptionInstance.SubscriptionSpan">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="SubscriptionInstance.SubscriptionSpan"
        BindingSourceMember="EndDate" ControlId="EndDate" ErrorMessageLocation="None" BindingMetaDataAlias="SubscriptionInstance.SubscriptionSpan">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="SubscriptionInstance.ProductOffering"
        BindingSource="SubscriptionInstance.ProductOffering" BindingSourceMember="Description"
        ControlId="lblDescDispName" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
    </DataBindingItems>
    <MetaDataMappings>
      <MT:MetaDataItem Alias="SubscriptionInstance.ProductOffering" AliasBaseType="Subscription.ProductOffering" AssemblyName="MetraTech.DomainModel.ProductCatalog.dll"
        MetaType="DomainModel" Value="Subscription" />
      <MT:MetaDataItem Alias="SubscriptionInstance.SubscriptionSpan" AliasBaseType="Subscription.SubscriptionSpan"
        AssemblyName="MetraTech.DomainModel.ProductCatalog.dll" MetaType="DomainModel"
        Value="Subscription" />
    </MetaDataMappings>
  </MT:MTDataBinder>

</asp:Content>

