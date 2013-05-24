<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Events.aspx.cs" Inherits="SampleAspNetApp.Events" %>

<%@ Register src="PolicyActionsView.ascx" tagname="PolicyActionsView" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:SqlDataSource ID="sdsEvents" runat="server" 
        ProviderName="System.Data.SQLite" SelectCommand="SELECT
 e.ID
,s.Name Subsystem
,sc.Name Category
,e.Message
,e.InputData
,Reason
,e.TimeStamp
,e.Path
,e.HostName
,e.ClientAddress
,e.UserIdentity
,e.InputDataSize
--,e.StackTrace
FROM SecurityEvent e
    LEFT JOIN SubsystemCategory sc ON e.SubsystemCategoryID = sc.ID
    LEFT JOIN Subsystem s ON sc.SubsystemID = s.ID
ORDER BY e.ID DESC" EnableViewState="False"></asp:SqlDataSource>
    <asp:GridView ID="gvEvents" runat="server" AllowPaging="True" 
        AllowSorting="True" DataKeyNames="ID" DataSourceID="sdsEvents">
        <EmptyDataTemplate>
            <i>There are no events logged yet.</i>
        </EmptyDataTemplate>
        <Columns>
            <asp:TemplateField HeaderText="Actions">
                <ItemTemplate>
                    <uc1:PolicyActionsView ID="PolicyActionsView1" runat="server" EventId='<%# Eval("ID") %>' />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>
