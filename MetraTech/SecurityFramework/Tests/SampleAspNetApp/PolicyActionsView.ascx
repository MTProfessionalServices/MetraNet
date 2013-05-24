<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PolicyActionsView.ascx.cs" Inherits="SampleAspNetApp.PolicyActionsView" %>

<asp:SqlDataSource ID="sdsActions" runat="server" ProviderName="System.Data.SQLite"
    SelectCommand="SELECT Name FROM SecurityPolicyAction a
        JOIN SecurityPolicyActionType at ON a.SecurityPolicyActionTypeID = at.ID
        WHERE a.SecurityEventID = @SecurityEventID">
        <SelectParameters>
            <asp:Parameter Name="@SecurityEventID" DbType="Int64" />
        </SelectParameters>
</asp:SqlDataSource>

<asp:BulletedList ID="BulletedList1" runat="server" DataSourceID="sdsActions" DataTextField="Name"></asp:BulletedList>
