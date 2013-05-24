<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_ApplyTemplate" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="ApplyTemplate.aspx.cs" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Apply Account Template" meta:resourcekey="MTTitle1Resource1"/>
  <br />
  <div style="width:810px">
  
    <MTCDT:MTGenericForm ID="MTGenericFormAccountTemplate" runat="server" meta:resourcekey="MTGenericFormAccountTemplateResource1"></MTCDT:MTGenericForm>
    <MT:MTPanel ID="MTPanelApplyTo" runat="server" Text="Apply Template To" meta:resourcekey="ApplyToPanel" >    

        <MT:MTRadioControl ID="radAll" meta:resourcekey="radAll" runat="server" BoxLabel="All Descendants" Name="r1" Text="1" Value="1" Checked="true" TabIndex="20" /> 
        <MT:MTRadioControl ID="radDirect" meta:resourcekey="radDirect" runat="server" BoxLabel="Direct Descendants" Name="r1" Text="2" Value="2" TabIndex="30" />

    </MT:MTPanel>   
    <MT:MTFilterGrid ID="MTFilterGridProperties" runat="server" TemplateFileName="AccountTemplateApply" ExtensionName="Account"></MT:MTFilterGrid>    
    <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="AccountTemplateApplySubscriptions" ExtensionName="Account"></MT:MTFilterGrid>
            
    <MT:MTPanel ID="MTPanel1" runat="server" Text="Subscription Span" meta:resourcekey="SubscriptionSpanPanel" >
    <div id="leftColumn" style="float: left; width: 300px;padding-left:10px;">
      <MT:MTDatePicker ID="StartDate" runat="server" Label="Subscriptions Start Date" AllowBlank="True" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="StartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="0" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbStartNextBillingPeriod" runat="server" BoxLabel="Next start of payer's billing period after this date" Text="c1" Value="c1" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbStartNextBillingPeriodResource1" Name="cbStartNextBillingPeriod" OptionalExtConfig="boxLabel:'Next start of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c1',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
      <div style="height:20px">&nbsp;</div>
      <MT:MTDatePicker ID="EndDate" runat="server" Label="Subscriptions End Date" AllowBlank="true" ControlHeight="18" ControlWidth="120" HideLabel="False" LabelWidth="120" Listeners="{}" meta:resourcekey="EndDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;                             altFormats:DATE_TIME_FORMAT" ReadOnly="False" TabIndex="0" XType="DateField" LabelSeparator=":" XTypeNameSpace="form" />
      <MT:MTCheckBoxControl ID="cbEndNextBillingPeriod" runat="server" BoxLabel="Next end of payer's billing period after this date" Text="c2" Value="c2" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbEndNextBillingPeriodResource1" Name="cbEndNextBillingPeriod" OptionalExtConfig="boxLabel:'Next end of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c2',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
      <div style="height:20px">&nbsp;</div>
      <MT:MTCheckBoxControl ID="cbEndConflictingSubscriptions" runat="server" BoxLabel="End Conflicting Subscriptions" Text="c3" Value="c3" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbEndConflictingSubscriptions1" Name="cbEndConflictingSubscriptions" OptionalExtConfig="boxLabel:'End Conflicting Subscriptions', inputValue:'c1',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />   
    </div>
    </MT:MTPanel>    
    
  <!-- BUTTONS -->
 
  <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">
     <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true) {return onOK();} else {return false;}" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" />   
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table> 
       </center>    
    </div>
  </div>
 
    <br />  
  </div>

  <script type="text/javascript">
  
    // Remove Pager
    GetBottomBar_<%= MTFilterGridProperties.ClientID %> = function()
    {
      var bbar = new Ext.Toolbar({
        items:[ ]
      });

      return bbar;
    };
    
     // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Name'), NameRenderer);
      cm.setRenderer(cm.getIndexById('IsGroup'), IsGroupRenderer); 
    };
    
    NameRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupSubName != null)
      {
        str += record.data.GroupSubName;
      }
      else
      {
        str += record.data.PODisplayName;
      }
      
      return str;
    }; 
    
    IsGroupRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupID == "" || record.data.GroupID  == null)
      {
         return "--";
      }
      else
      {
        return "<img border='0' src='/Res/Images/Icons/tick.png'>";
      }
      return str;
    };
  
    function getDisplayName(record)
    {
      var name = "";
      if(record.data.GroupSubName != null)
      {
        name += record.data.GroupSubName;
      }
      else
      {
        name += record.data.PODisplayName;
      }
      return name;
    }

    // Remove Pager
    GetBottomBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var bbar = null;
      return bbar;
    };
    
    // HANDLE OK CLICK
    function onOK()
    {
      var subRecords = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
      var subIds = "";
      for(var i=0; i < subRecords.length; i++)
      {
        if(i > 0)
        {
          subIds += ",";
        }
        subIds += subRecords[i].data.ProductOfferingId + ":" + subRecords[i].data.GroupID;
      }

      var propertyRecords = grid_<%= MTFilterGridProperties.ClientID %>.getSelectionModel().getSelections();
      var propertyIds = "";
      for(var i=0; i < propertyRecords.length; i++)
      {
        if(i > 0)
        {
          propertyIds += ",";
        }
        propertyIds += propertyRecords[i].data.Key; 
      }
            
      var args = "ApplySubscriptionsString=" + subIds + "**";
      args += "ApplyPropertiesString=" + propertyIds + "**";
      args += "ApplyDefaultSecurityString=" + Ext.get("ctl00_ContentPlaceHolder1_cbApplyDefaultSecurityPolicy").dom.checked + "**";
      args += "ApplyAllDescendentsString=" + Ext.get("ctl00_ContentPlaceHolder1_radAll").dom.checked + "**";
      args += "ApplyStartDateString=" + Ext.get("ctl00_ContentPlaceHolder1_StartDate").dom.value + "**";
      args += "ApplyEndDateString=" + Ext.get("ctl00_ContentPlaceHolder1_EndDate").dom.value + "**";
      args += "ApplyStartNextBillingPeriodString=" + Ext.get("ctl00_ContentPlaceHolder1_cbStartNextBillingPeriod").dom.checked + "**";
      args += "ApplyEndNextBillingPeriodString=" + Ext.get("ctl00_ContentPlaceHolder1_cbEndNextBillingPeriod").dom.checked + "**";
      args += "ApplyEndConflictingSubscriptionsString=" + Ext.get("ctl00_ContentPlaceHolder1_cbEndConflictingSubscriptions").dom.checked;
      pageNav.Execute("TemplateEvents_OKApplyTemplate_Client", args, results);
      return false;
    }
    
    function results(response)
    {
      Ext.UI.msg(TEXT_ERROR, response);
    }

  </script>

  <MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>

</asp:Content>
