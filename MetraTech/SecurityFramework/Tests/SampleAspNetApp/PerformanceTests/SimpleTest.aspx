<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="SimpleTest.aspx.cs" Inherits="SampleAspNetApp.PerformanceTests.SimpleTest" ValidateRequest="false" %>

<%@ Register src="../Controls/XssDecoderTest.ascx" tagname="XssDecoderTest" tagprefix="sf" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <sf:XssDecoderTest ID="xssDecoderTest" runat="server" TestForXss="false" />
</asp:Content>
