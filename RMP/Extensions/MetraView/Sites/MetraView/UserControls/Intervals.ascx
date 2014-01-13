<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Intervals" CodeFile="Intervals.ascx.cs" %>
<asp:Localize ID="Localize1" meta:resourcekey="SelectInterval" runat="server">Select Interval</asp:Localize>:
<asp:DropDownList AutoPostBack="true" ID="ddIntervals" OnSelectedIndexChanged="OnIntervalChange" runat="server"></asp:DropDownList>