<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Validator.aspx.cs" Inherits="SampleAspNetApp.Validator" ValidateRequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <h2>
        Tests for validators</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>

            <fieldset>
                <legend>Basic Int</legend>
                <asp:Panel runat="server" ID="pnlBasicInt" DefaultButton="btnBasicInt">
                    <p>
                        <asp:TextBox ID="txtBasicInt" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbBasicIntNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutBasicInt" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnBasicInt" runat="server" Text="Validate" 
                        onclick="btnBasicIntValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Basic long</legend>
                <asp:Panel ID="pnlBasicLong" runat="server" DefaultButton="btnBasicLongValidate">
                    <p>
                        <asp:TextBox ID="txtBasicLong" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbBasicLongNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutBasicLong" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnBasicLongValidate" runat="server" Text="Validate" OnClick="btnBasicLongValidate_Click" />
                </asp:Panel>
            </fieldset>
            
            <fieldset>
                <legend>Basic double</legend>
                <asp:Panel ID="pnlBasicDouble" runat="server" DefaultButton="btnBasicDoubleValidate">
                    <p>
                        <asp:TextBox ID="txtBasicDouble" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbBasicDoubleNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutbasicDouble" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnBasicDoubleValidate" runat="server" Text="Validate" OnClick="btnBasicDoubleValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Basic String</legend>
                <asp:Panel runat="server" ID="pnlBasicString" DefaultButton="btnBasicString">
                    <p>
                        <asp:TextBox ID="txtBasicString" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbBasicStringNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutBasicString" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnBasicString" runat="server" Text="Validate" 
                        OnClick="btnBasicStringValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Credit Card Number</legend>
                <asp:Panel ID="pnlCcn" runat="server" DefaultButton="btnCcnValidate">
                    <p>
                        <asp:TextBox ID="txtCcn" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbCreditCardNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutCcn" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnCcnValidate" runat="server" Text="Validate" OnClick="btnCcnValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Hex String</legend>
                <asp:Panel ID="pnlHexString" runat="server" DefaultButton="btnHexStringValidate">
                    <p>
                        <asp:TextBox ID="txtHexString" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbHexNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutHex" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnHexStringValidate" runat="server" Text="Validate" OnClick="btnHexStringValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Printable String</legend>
                <asp:Panel ID="pnlPrintableString" runat="server" DefaultButton="btnPrintableStringValidate">
                    <p>
                        <asp:TextBox ID="txtPrintableString" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbPrintableNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutPrintable" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnPrintableStringValidate" runat="server" Text="Validate" OnClick="btnPrintableStringValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Date String</legend>
                <asp:Panel ID="pnlDateString" runat="server" DefaultButton="btnDateStringValidate">
                    <p>
                        <asp:TextBox ID="txtDateString" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbDateStringNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutDate" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnDateStringValidate" runat="server" Text="Validate" OnClick="btnDateStringValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>BASE 64 String</legend>
                <asp:Panel ID="pnlBase64String" runat="server" DefaultButton="btnBase64StringValidate">
                    <p>
                        <asp:TextBox ID="txtBase64String" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbBase64Null" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtBase64" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnBase64StringValidate" runat="server" Text="Validate" OnClick="btnBase64StringValidate_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>PatternString</legend>
                <asp:Panel runat="server" ID="pnlPatternString" DefaultButton="btnPatternString">
                    <p>
                        <asp:TextBox ID="txtPatternString" runat="server" TextMode="MultiLine" style="width:100%; height:55px;"></asp:TextBox>
                        <asp:CheckBox ID="chbPatternNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                        <asp:DropDownList ID="ddlPatterValidator" runat="server"></asp:DropDownList>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox runat="server" ID="txtOutPatternString" TextMode="MultiLine" ReadOnly="true" style="width:100%; height:55px;"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnPatternString" runat="server" Text="Validate" 
                        onclick="btnPatternStringValidate_Click" />
                </asp:Panel>
            </fieldset>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
