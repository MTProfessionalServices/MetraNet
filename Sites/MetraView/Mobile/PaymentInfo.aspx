<%@ Page Language="C#" AutoEventWireup="true" Inherits="Mobile_PaymentInfo" CodeFile="PaymentInfo.aspx.cs" %>
{
  "amountDue" : "<%= GetPreviousBalance() %>",
  "amountDueAsString" : "<%= GetPreviousBalanceAsString() %>",
  "paymentType" : "<%= PaymentType %>",
  "endingDigits" : "<%= EndingDigits %>",
  "piid" : "<%= PIID %>"
}