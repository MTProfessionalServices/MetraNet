<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="XssDecoderTest.ascx.cs" Inherits="SampleAspNetApp.Controls.XssDecoderTest" %>

<fieldset>
    <legend>Type some text into fields</legend>
    <p>
        <asp:Label ID="lblField1" runat="server" Text="Field 1" AssociatedControlID="txtField1"></asp:Label>
        <asp:TextBox ID="txtField1" runat="server"></asp:TextBox>
    </p>
    <p>
        <asp:Label ID="lblField2" runat="server" Text="Field 2" AssociatedControlID="txtField2"></asp:Label>
        <asp:TextBox ID="txtField2" runat="server"></asp:TextBox>
    </p>
    <p>
        <asp:Label ID="lblField3" runat="server" Text="Field 3" AssociatedControlID="txtField3"></asp:Label>
        <asp:TextBox ID="txtField3" runat="server"></asp:TextBox>
    </p>
    <asp:Button ID="btnTest" runat="server" Text="Test" OnClick="btnTest_Click" />
</fieldset>