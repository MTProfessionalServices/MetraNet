<%@ Page Language="C#" AutoEventWireup="true" Inherits="Mobile_AccountInfo" CodeFile="AccountInfo.aspx.cs" %>
{
  "username" : "<%= Account.UserName %>",
  "accountId" : "<%= Account._AccountID %>",
  "firstName" : "<%= BillTo.FirstName %>",
  "middleInitial" : "<%= BillTo.MiddleInitial %>",
  "lastName" : "<%= BillTo.LastName %>",
  "address1" : "<%= BillTo.Address1%>",
  "address2" : "<%= BillTo.Address2%>",
  "address3" : "<%= BillTo.Address3%>",
  "city" : "<%= BillTo.City %>",
  "state" : "<%= BillTo.State %>",
  "zip" : "<%= BillTo.Zip %>",
  "phoneNumber" : "<%= BillTo.PhoneNumber %>",
  "email" : "<%= BillTo.Email %>"              
}
