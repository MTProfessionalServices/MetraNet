<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Subscriptions_Unsubscribe" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="Unsubscribe.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <!-- Title Bar -->
 <MT:MTTitle ID="MTTitle1" runat="server" Text="Unsubscribe" meta:resourcekey="MTTitle1Resource1" />
 <br />
  <div>
        <asp:Label ID="LblErrorMessage" runat="server" CssClass="ErrorMessage"></asp:Label>
  </div>
  
  <!-- Main Form -->
  <MT:MTPanel ID="pnlMain" runat="server" Text="Unsubscribe from subscription" meta:resourcekey="pnlMain" Width="500">
    <div id="leftColumn" class="LeftColumn">
      <MT:MTLiteralControl ID="lblDisplayName" runat="server" Label="Subscription" AllowBlank="False" ControlHeight="36" ControlWidth="240" HideLabel="False" LabelWidth="120" Listeners="{}" ReadOnly="False" TabIndex="0" XType="MiscField" meta:resourcekey="lblDisplayNameResource1" />
      <MT:MTLiteralControl ID="StartDate" runat="server" Label="Start Date" AllowBlank="False" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" ReadOnly="False" TabIndex="0" XType="MiscField" meta:resourcekey="StartDateResource1" />
      <MT:MTDatePicker ID="EndDate" runat="server" Label="End Date" AllowBlank="False" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="EndDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="0" XType="DateField" />
      <MT:MTCheckBoxControl ID="cbEndNextBillingPeriod" runat="server" 
            BoxLabel="Next end of payer's billing period after this date" Text="c2" 
            Value="c2" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" 
            meta:resourcekey="cbEndNextBillingPeriodResource1" 
            Name="cbEndNextBillingPeriod" 
            OptionalExtConfig="boxLabel:'Next end of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c2',&#13;&#10;                                            checked:false" 
            ReadOnly="False" TabIndex="0" XType="Checkbox" ControlWidth="280" />
    </div>
  </MT:MTPanel>

  <!-- BUTTONS -->
  
    <div  class="x-panel-btns-ct">
    <div style="width:500px" class="x-panel-btns x-panel-btns-center">  
    <center> 
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true) {return ValidateForm();} else {return false;}" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="17" meta:resourcekey="btnOKResource1" />
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="18" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table>   
       </center>  
    </div>
  </div>
 
  <br />
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="SubscriptionInstance.ProductOffering" BindingSourceMember="DisplayName"
        ControlId="lblDisplayName" ErrorMessageLocation="None" BindingMetaDataAlias="SubscriptionInstance.ProductOffering">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="SubscriptionInstance.SubscriptionSpan"
        BindingSourceMember="EndDate" ControlId="EndDate" ErrorMessageLocation="None" BindingMetaDataAlias="SubscriptionInstance.SubscriptionSpan">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingMetaDataAlias="SubscriptionInstance.SubscriptionSpan"
        BindingSource="SubscriptionInstance.SubscriptionSpan" BindingSourceMember="StartDate"
        ControlId="StartDate" ErrorMessageLocation="None">
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


