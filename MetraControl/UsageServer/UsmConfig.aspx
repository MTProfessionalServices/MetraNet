<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="UsmConfig.aspx.cs" Inherits="MetraControl_UsageServer_UsmConfig" meta:resourcekey="PageResource1" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTLabel ID="MTLabel1" runat="server" meta:resourcekey="MTLabel1Resource1" />

<asp:ValidationSummary ID="ValidationSummary1" runat="server" 
    CssClass="ErrorMessage" Width="100%" Height="16px" 
    meta:resourcekey="ValidationSummary1Resource1" />

<MT:MTTitle ID="MTTitle1" Text="Settings" runat="server" 
    meta:resourcekey="MTTitle1Resource1" />

  <div style="padding-top:.15in;"/>
  <MT:MTPanel ID="MTPanel1" runat="server" Font-Bold="True" Collapsed="False" 
    Collapsible="True" EnableChrome="True" meta:resourcekey="MTPanel1Resource1" Text="USM Configuration">

    
    <table style="width: 100%; fontweight: bold;">
      <tr>
        <td align="right">
              <asp:CheckBox ID="AutoSoftClose" runat="server" 
                meta:resourcekey="AutoSoftCloseResource1" />
        </td>
        <td style="font-weight: bold">
          <span style="width:100%;height:100%; fontweight: bold;">
          <asp:Label ID="LabelAutoSoftCloseTitle" runat="server" 
            Text="Automatically Soft Close the Billing Groups of Expired Usage Intervals." 
            meta:resourcekey="LabelAutoSoftCloseTitleResource1"></asp:Label>
          </span>
        </td>
        <td>
          &nbsp;
        </td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;
        </td>
        <td>
          <span style="width:100%;height:100%; fontweight: bold;">
          <asp:Label ID="LabelEachNight" runat="server" Text="Each night the platform will check for intervals that have ended and using the 
          grace period configuration below, automatically create billing groups and change 
          their state to &#39;Soft Closed&#39;." 
            meta:resourcekey="LabelEachNightResource1"></asp:Label>
          </span></td>
        <td>
          &nbsp;
        </td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          &nbsp;</td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;
        </td>
        <td>
          <asp:Label ID="LabelAutoSoftClose" runat="server" 
            Text="Automatically create and Soft Close Billing Groups for:" 
            meta:resourcekey="LabelAutoSoftCloseResource1"></asp:Label>
          &nbsp;</td>
        <td>
          &nbsp;
        </td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          <table style="width:100%;">
            <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="DailyCheckBox" runat="server" 
                  meta:resourcekey="DailyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelDaily" runat="server" Text="Daily" 
                  meta:resourcekey="LabelDailyResource1"></asp:Label></b> 
                <asp:Label ID="LabelIntervals" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="DailyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="DailyTextBoxResource1"></asp:TextBox>
                <asp:Label ID="LabelDaysAfter" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="WeeklyCheckBox" runat="server" 
                  meta:resourcekey="WeeklyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelWeekly" runat="server" Text="Weekly" 
                  meta:resourcekey="LabelWeeklyResource1"></asp:Label></b> 
                <asp:Label ID="Label2" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="WeeklyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="WeeklyTextBoxResource1"></asp:TextBox>
              <asp:Label ID="Label1" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
                          <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="BiWeeklyCheckBox" runat="server" 
                  meta:resourcekey="BiWeeklyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
                 <b><asp:Label ID="LabelBiWeekly" runat="server" Text="Bi-weekly" 
                   meta:resourcekey="LabelBiWeeklyResource1"></asp:Label></b> 
                <asp:Label ID="Label3" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="BiWeeklyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="BiWeeklyTextBoxResource1"></asp:TextBox>
              <asp:Label ID="Label9" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="SemiMonthlyCheckBox" runat="server" 
                  meta:resourcekey="SemiMonthlyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelSemiMonthly" runat="server" Text="Semi-monthly" 
                  meta:resourcekey="LabelSemiMonthlyResource1"></asp:Label></b> 
                <asp:Label ID="Label4" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="SemiMonthlyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="SemiMonthlyTextBoxResource1"></asp:TextBox>
              <asp:Label ID="Label10" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="MonthlyCheckBox" runat="server" 
                  meta:resourcekey="MonthlyCheckBoxResource2" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelMonthly" runat="server" Text="Monthly" 
                  meta:resourcekey="LabelMonthlyResource1"></asp:Label></b> 
                <asp:Label ID="Label5" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="MonthlyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="MonthlyTextBoxResource2"></asp:TextBox>
              <asp:Label ID="Label11" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="QuarterlyCheckBox" runat="server" 
                  meta:resourcekey="QuarterlyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
              <b><asp:Label ID="LabelQuarterly" runat="server" Text="Quarterly" 
                  meta:resourcekey="LabelQuarterlyResource1"></asp:Label></b> 
                <asp:Label ID="Label6" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="QuarterlyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="QuarterlyTextBoxResource1"></asp:TextBox>
              <asp:Label ID="Label12" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="SemiAnnuallyCheckBox" runat="server" 
                  meta:resourcekey="SemiAnnuallyCheckBoxResource1" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelSemiAnnually" runat="server" Text="Semi-annually" 
                  meta:resourcekey="LabelSemiAnnuallyResource1"></asp:Label></b> 
                <asp:Label ID="Label7" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="SemiAnnuallyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="SemiAnnuallyTextBoxResource1"></asp:TextBox>
              <asp:Label ID="Label13" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>
                        <tr>
              <td style="width: 15px" align="right">
                <asp:CheckBox ID="AnnuallyCheckBox" runat="server" 
                  meta:resourcekey="AnnuallyCheckBoxResource2" />
              </td>
              <td style="width: 493px">
                <b><asp:Label ID="LabelAnnually" runat="server" Text="Annually" 
                  meta:resourcekey="LabelAnnuallyResource1"></asp:Label></b> 
                <asp:Label ID="Label8" runat="server" Text="intervals" 
                  meta:resourcekey="LabelIntervalsResource1"></asp:Label>
              <asp:TextBox ID="AnnuallyTextBox" runat="server" Width="66px" MaxLength="9" 
                  meta:resourcekey="AnnuallyTextBoxResource2"></asp:TextBox>
              <asp:Label ID="Label14" runat="server" 
                  Text="day(s) after interval expires." 
                  meta:resourcekey="LabelDaysAfterResource1"></asp:Label>
              </td>
            </tr>

            </tr>
            <tr>
              <td style="width: 15px" align="right">
                &nbsp;</td>
              <td style="width: 493px">
                &nbsp;</td>
            </tr>
          </table>
        </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          <asp:CheckBox ID="BlockIntervalsCheckBox" runat="server" 
            meta:resourcekey="BlockIntervalsCheckBoxResource1" />
          <asp:Label ID="LabelBlockIntervals" runat="server"
              
            Text="When automatically closing intervals, block the intervals to new accounts." 
            meta:resourcekey="LabelBlockIntervalsResource1"></asp:Label>
          </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          &nbsp;</td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          <asp:CheckBox ID="AutoRunEopCheckBox" runat="server" 
            meta:resourcekey="AutoRunEopCheckBoxResource1" />
        </td>
        <td style="font-weight: bold">
          <asp:Label ID="LabelAutoRunEop" runat="server" 
            Text="Automatically Run End Of Period Adapters On Soft Closed Billing Groups" 
            meta:resourcekey="LabelAutoRunEopResource1"></asp:Label>
          </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          <asp:Label ID="LabelAutoRunEopInfo" runat="server" 
            Text="Once a Billing Group has been Soft Closed, either automatically or manually, the platform will automatically start running End Of Period adapters." 
            meta:resourcekey="LabelAutoRunEopInfoResource1"></asp:Label>
          </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          &nbsp;</td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          <asp:CheckBox ID="RunSchedAdaptersCheckBox" runat="server" 
            meta:resourcekey="RunSchedAdaptersCheckBoxResource1" />
        </td>
        <td style="font-weight: bold">
          <asp:Label ID="LabelRunScheduledAdapters" runat="server" 
            Text="Run Scheduled Adapters" 
            meta:resourcekey="LabelRunScheduledAdaptersResource1"></asp:Label>
          </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td>
          <asp:Label ID="LabelRunScheduledAdaptersInfo" runat="server" 
            Text="The platform will periodically run configured scheduled adapters.&nbsp; Note: If this setting is not selected, all scheduled adadaters will need to be run manually." 
            meta:resourcekey="LabelRunScheduledAdaptersInfoResource1"></asp:Label>
          </td>
        <td>
          &nbsp;</td>
      </tr>
      <tr>
        <td align="right">
          &nbsp;</td>
        <td align="center">
          <asp:Button ID="SaveConfigButton" OnClick="SaveConfigButton_Click" 
            runat="server" Text="Save Configuration" 
            meta:resourcekey="SaveConfigButtonResource1" />
          <asp:Button ID="CancelButton" OnClick="CancelButton_Click" runat="server" 
            Text="Cancel" meta:resourcekey="CancelButtonResource1" />
        </td>
        <td>
          &nbsp;</td>
      </tr>
    </table>
  </MT:MTPanel>


</asp:Content>

