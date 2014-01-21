<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SetGroupSubscriptionDate"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="SetGroupSubscriptionDate.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript">
  function onCheck()
  {  
    if(Ext.get("<%=radSharedCounters.ClientID%>").dom.checked)
    {
     
       Ext.get("MyFormDiv_<%=PanelDiscountAccount.ClientID%>").dom.style.visibility = "visible"; 
       Ext.get("MyFormDiv_<%=PanelDiscountAccount.ClientID%>").dom.style.display = "block";        
    }
    else if(Ext.get("<%=radNoSharedCounters.ClientID%>").dom.checked)
    {
      Ext.get("MyFormDiv_<%=PanelDiscountAccount.ClientID%>").dom.style.visibility = "hidden"; 
      Ext.get("MyFormDiv_<%=PanelDiscountAccount.ClientID%>").dom.style.display = "none";
    }        
  }
  
  function onUsageCycleCheck()
  {      
      if(Ext.get("<%=cbUsageCycleEnforced.ClientID%>").dom.checked)
      {
         Ext.get("ctl00_ContentPlaceHolder1_MTBillingCycleControl1").dom.setAttribute('disabled' , true);
      }
      else
      {
         Ext.get("ctl00_ContentPlaceHolder1_MTBillingCycleControl1").dom.setAttribute('disabled' , false);
      }

  }
  function CheckEndDate() 
  {
    var endDate = Ext.getCmp("ctl00_ContentPlaceHolder1_tbSubscriptionSpan_EndDate");
    endDate.compareValue = this.value;
  }

  </script>

  <MT:MTTitle ID="MTTitle1" meta:resourcekey="MTTitle1Resource1" Text="Group Subscription Details"
    runat="server" />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="false" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <div style="width: 810px">
    <br />
    <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server">
    </MTCDT:MTGenericForm>
    <MT:MTPanel ID="PanelEBCRWarning" runat="server">
      <MT:MTMessage ID="lblEBCRWarning" runat="server" meta:resourcekey="lblEBCRWarningResource1"
        Text="Changing this start date may adversely affect billing cycle aligned charges contained in the associated Product Offering." />
    </MT:MTPanel>
    <MT:MTPanel ID="PanelSharedCounters" runat="server" meta:resourcekey="MTSection1Resource1"
      Text="Discount and Aggregate Rates Counter Configuration" Width="720">
      <MT:MTRadioControl ID="radSharedCounters" meta:resourcekey="SharedCountersBoxLabel"
        Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }" runat="server"
        BoxLabel="Use Shared Counters" Name="r1" Text="1" Value="1" />
      <MT:MTRadioControl ID="radNoSharedCounters" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="Do not use Shared Counters" meta:resourcekey="NoSharedCountersBoxLabel"
        Name="r1" Text="2" Value="2" Checked="true" />
    </MT:MTPanel>
    <MT:MTPanel ID="PanelDiscountAccount" runat="server" meta:resourcekey="MTSection2Resource1"
      Text="Discount Configuration" Direction="LeftToRight" Width="720">
       <MT:MTInlineSearch ID="tbAcctGrpDis" runat="server" meta:resourcekey="GrpDiscAcct" 
        AllowBlank="True" Label="Account for group discount" HideLabel="False" Width="195px"></MT:MTInlineSearch>
      <MT:MTLabel ID="MTDiscDist" meta:resourcekey="MTDiscDistResource1" Text="Discount Distribution:  Full amount to one account" runat="server" Style="margin-left: 30px; width: 400px;" />
       
      <!-- <MT:MTRadioControl ID="MTRadioControl1" Listeners="{ 'check' : { fn: this.onRadioCheck, scope: this, delay: 100 } }"
        runat="server" meta:resourcekey="DiscDisRadioButton1" BoxLabel="proportional" Name="r3"
        Text="3" Value="3" Disabled="true" />-->
      <MT:MTRadioControl ID="MTRadioControl2" Listeners="{ 'check' : { fn: this.onRadioCheck, scope: this, delay: 100 } }"
        runat="server" meta:resourcekey="DiscDisRadioButton2" BoxLabel="full amount to one account"
        Name="r3" Text="4" Value="4" Checked="true"  Visible="false"/>
     
      <input type="hidden" runat="server" id="ShowDiscConfigFlag" />
       <input type="hidden" runat="server" id="ShowUsageCyclePanelFlag" />
    </MT:MTPanel>   
    
    <MT:MTPanel ID="UsageCyclePanel" runat="server" Text="Prouct offering Usage Cycle Configuration" meta:resourcekey="MTUsageCyclePanel" Width="720"> 
     <MT:MTRadioControl ID="MTUsageCycleRadio" Listeners="{ 'check' : { fn: this.onUsageCycleCheck, scope: this, delay: 100 } }"
        runat="server" meta:resourcekey="DiscDisRadioButton2" BoxLabel="Use cycle enforced by the product offering"
        Name="r3" Text="4" Value="4" Checked="true"  Visible="false"/>
           <MT:MTCheckBoxControl ID="cbUsageCycleEnforced" runat="server" AllowBlank="True" BoxLabel="Use cycle enforced by the product offering"
        Text="UsageCycle" Value="UsageCycle" TabIndex="230" ControlWidth="200" Checked="True" HideLabel="True"
        LabelSeparator=":" Listeners="{ 'check': {fn: this.onUsageCycleCheck, scope: this, delay: 100} }" meta:resourcekey="cbEmailNotificationResource1"
        Name="cbUsageCycleEnforced" OptionalExtConfig="boxLabel:'Use cycle enforced by the product offering',&#13;&#10;                                            inputValue:'UsageCycle',&#13;&#10;                                            checked:false"
        ReadOnly="False" XType="Checkbox" XTypeNameSpace="form"  />
        <MT:MTLabel ID="LblEnforced" runat="server" Text="Use cycle enforced by the product offering" visible="false" meta:resourcekey="LblEnforced"/>
        <br />
       <MT:MTBillingCycleControl TabIndex="360" ID="MTBillingCycleControl1" runat="server"
        LabelWidth="120"  />      
    </MT:MTPanel>

    <MT:MTPanel ID="AccountsPanel" runat="server" Text="Select Account" Visible="true" meta:resourcekey="MTAccountsPanel" Width="720"> 
       <MT:MTInlineSearch ID="MTAccountSearch" runat="server" meta:resourcekey="SearchAccount" AllowBlank="True" Label="Account for usage cycle" HideLabel="False" Width="195px" onClientClick="showUsageCycle()"></MT:MTInlineSearch>        
    </MT:MTPanel>
    
    <!-- Properties -->
    <MT:MTPanel ID="pnlSubscriptionProperties" runat="server" Text="Properties" Collapsible="false" meta:resourcekey="pnlSubscriptionProperties" Width="720">
    </MT:MTPanel>
    
    <!-- Buttons -->
    <div class="x-panel-btns-ct">
      <div style="width: 725px" class="x-panel-btns x-panel-btns-center">
        <center>
        <table cellspacing="0">
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnOK" OnClientClick="return Validate();" Width="50px" runat="server"
                Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
                CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
            </td>
          </tr>
        </table>
        </center>
      </div>
    </div>
    </div>
    
    <MT:MTDataBinder ID="MTDataBinder1" runat="server">
      <DataBindingItems>
        <MT:MTDataBindingItem runat="server" ControlId="tbAcctGrpDis" BindingSource="GroupSubscriptionInstance"
          BindingProperty="AccountID" BindingSourceMember="DiscountAccountId" ErrorMessageLocation="None">
        </MT:MTDataBindingItem>
        <MT:MTDataBindingItem runat="server" ControlId="PanelDiscountAccount" 
          ErrorMessageLocation="RedTextAndIconBelow">
        </MT:MTDataBindingItem>          
         
       <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="CycleType" ControlId="MTBillingCycleControl1.CycleList"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="DayOfWeek" ControlId="MTBillingCycleControl1.Weekly" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="StartMonth" ControlId="MTBillingCycleControl1.Quarterly_Month"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem  runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="StartDay" ControlId="MTBillingCycleControl1.Quarterly_Day"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingSource="POCycleInstance" BindingSourceMember="StartYear"
        ControlId="MTBillingCycleControl1.StartYear" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="DayOfMonth" ControlId="MTBillingCycleControl1.Monthly" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="FirstDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_First"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem runat="server" BindingProperty="SelectedValue" BindingSource="POCycleInstance"
        BindingSourceMember="SecondDayOfMonth" ControlId="MTBillingCycleControl1.SemiMonthly_Second"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>  
       </DataBindingItems>

    </MT:MTDataBinder>

    <script type="text/javascript">
       function Validate()
       {       
           if(Ext.get("<%=tbAcctGrpDis.ClientID%>").dom.value != '')
           {                         
               var accIDregex = new RegExp('.*\\((\\d+)\\)');
               var acctID = Ext.get("<%=tbAcctGrpDis.ClientID%>").dom.value + '';
               var matches = acctID.match(accIDregex);
               if(matches == null)
               {
                  Ext.get("<%=tbAcctGrpDis.ClientID%>").dom.value = '';                        
                  return false;
               }
               else
               {             
                  return ValidateForm();
               }
           }
           else
           {
              return ValidateForm();
           }

      }
   
    
    </script>

    <script type="text/javascript" language="javascript">
      var showDiscConfig = <%=ShowDiscConfig.ToString().ToLower() %> ;
    
      if(!showDiscConfig){
        MyFormDiv_<%=PanelDiscountAccount.ClientID%>.style.visibility = "hidden"; 
        MyFormDiv_<%=PanelDiscountAccount.ClientID%>.style.display = "none";         
       }else{ 
        MyFormDiv_<%=PanelDiscountAccount.ClientID%>.style.visibility = "visible"; 
        MyFormDiv_<%=PanelDiscountAccount.ClientID%>.style.display = "block";  
       }     

    </script>
</asp:Content>
