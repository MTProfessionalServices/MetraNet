<%@ Page Language="C#" AutoEventWireup="true" Inherits="Mobile_BillSummary" CodeFile="BillSummary.aspx.cs" %>
[
  {"Name" : "Last Payment Date", "Amount" : "<%= GetPaymentDate() %>"}
  {"Name" : "Payment Amount", "Amount" : "<%= GetPaymentAmount() %>"},
  {"Name" : "Payment Due Date", "Amount" : "<%= GetPaymentDueDate() %>"}
  {"Name" : "Total Amount Due", "Amount" : "<%= GetPreviousBalance() %>"}
]
