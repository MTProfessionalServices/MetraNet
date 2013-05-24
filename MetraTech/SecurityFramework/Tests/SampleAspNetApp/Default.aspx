<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Master.Master" CodeBehind="Default.aspx.cs" Inherits="SampleAspNetApp._Default" ValidateRequest="false" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div>
    
    </div>
    <p>
        <asp:Label ID="Label1" runat="server" Text="Enter Something:"></asp:Label>
    </p>
    <p>
        <asp:TextBox ID="TextBoxInputData" runat="server" ValidationGroup="SF_VGROUP"></asp:TextBox>
        <asp:CustomValidator ID="InputTextCustomValidator" runat="server" 
            ControlToValidate="TextBoxInputData" ErrorMessage=" Bad Input!!!"
            onservervalidate="InputTextCustomValidator_ServerValidate" 
            ValidationGroup="SF_VGROUP" EnableClientScript="False"></asp:CustomValidator>
        <hr />
        <asp:CustomValidator ID="custPolicy" runat="server" ValidationGroup=""
            EnableViewState="false" EnableClientScript="false"></asp:CustomValidator>
        <hr />
        <asp:Label ID="lblPolicyActions" runat="server" EnableViewState="false"></asp:Label>
    </p>
    <p>
        <asp:Button ID="ButtonProcessData" runat="server" onclick="OnProcessData" 
            Text="Process Data" ValidationGroup="SF_VGROUP" />
    </p>
    
    <p>
    <asp:Label ID="Label2" runat="server" Text="Results:"></asp:Label>
    </p>  
    <p>
        <asp:Label ID="LabelOutputField" runat="server"></asp:Label>
    </p>      
    <p>
        <asp:Label ID="LabelRequestUrl" runat="server"></asp:Label>
    </p>
    <fieldset>
        <legend>Throw an exception</legend>
        <asp:Button ID="btnThrow" runat="server" Text="Throw" OnClick="btnThrow_Click" />
    </fieldset>
    <fieldset>
        <legend>Generate event</legend>
        <asp:Button ID="btnGenerateEvent" runat="server" Text="Generate" OnClick="btnGenerateEvent_Click" />
    </fieldset>
</asp:Content>