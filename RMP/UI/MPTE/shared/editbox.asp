<%
Dim gbAddRowEven
Dim gstrClass

gbAddRowEven = True
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub OpenEditBoxTable(strDivID, strFormAction, strCaption, strWidth)
	if strCaption = "" then
		strCaption = "Edit"
	end if
	
	response.write "<DIV class=""clsMagicEdit"" id=""" & strDivID & """>" & vbNewLine
	response.write "	<FORM action=""" & strFormAction & """ method=""POST"">" & vbNewLine
	
	if strWidth = "" then
		response.write "		<table border=""0"" cellpadding=""1"" cellspacing=""0"">" & vbNewLine
	else
		response.write "		<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""" & strWidth & """>" & vbNewLine
	end if
	
	response.write "			<tr>" & vbNewLine
	response.write "				<td nowrap class=""clsCaptionBar"">" & strCaption & "</td>" & vbNewLine
	response.write "			</tr>" & vbNewLine
	response.write "			<tr>" & vbNewLine
	response.write "				<td nowrap>" & vbNewLine
	response.write "					<table border=""0"">" & vbNewLine
	response.write "						<tr>" & vbNewLine
	response.write "							<td nowrap>" & vbNewLine
	response.write "								<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=100% id=""EditTable"">" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub OpenEditBoxTableNoDiv(strFormID, strFormAction) 'designed for opening in separate window
	
	response.write "	<FORM name=""" & strFormID & """ action=""" & strFormAction & """ method=""POST"">" & vbNewLine
	
	response.write "		<table border=""0"" cellpadding=""1"" cellspacing=""0"">" & vbNewLine
	response.write "			<tr>" & vbNewLine
	response.write "				<td nowrap>" & vbNewLine
	response.write "					<table border=""0"">" & vbNewLine
	response.write "						<tr>" & vbNewLine
	response.write "							<td nowrap>" & vbNewLine
	response.write "								<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=100% id=""EditTable"">" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub OpenEditBoxTableNoDivWithExtra(strFormID, strFormAction, strExtra) 'designed for opening in separate window
	
	response.write "	<FORM name=""" & strFormID & """ action=""" & strFormAction & """ method=""POST"" " & strExtra & ">" & vbNewLine
	
	response.write "		<table border=""0"" cellpadding=""1"" cellspacing=""0"">" & vbNewLine
	response.write "			<tr>" & vbNewLine
	response.write "				<td nowrap>" & vbNewLine
	response.write "					<table border=""0"">" & vbNewLine
	response.write "						<tr>" & vbNewLine
	response.write "							<td nowrap>" & vbNewLine
	response.write "								<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=100% id=""EditTable"">" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddInputTextArea(strCaption, strName, strValue, intWidth)
  Dim intRows
  
  intRows = CLng(len(strValue)/intWidth + 1)

  if intRows < 5 then
    intRows = 5 
  elseif intRows > 15 then
    intRows = 15
  end if
  
	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><textarea class=""clsInputBox"" name=""" & strName & """ cols=""" & intWidth & """ rows=""" & intRows & """>" & strValue & "</textarea></td>" & vbNewLine
	response.write "								</tr>" & vbNewLine

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddInputTextAreaWithExtra(strCaption, strName, strValue, intWidth, strExtra)
  Dim intRows
  
  intRows = CLng(intWidth) /(len(strValue) + 1)
  
  if intRows < 5 then
    intRows = 5 
  elseif intRows > 15 then
    intRows = 15
  end if

	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><textarea class=""clsInputBox"" name=""" & strName & """ cols=""" & intWidth & """ rows=""" & intRows & "" & strExtra & ">" & strValue & "</textarea></td>" & vbNewLine
	response.write "								</tr>" & vbNewLine

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddInputTextBox(strCaption, strName, strValue, intLen)

	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><input class=""clsInputBox"" type=""text"" size=" & intLen & " name=""" & strName & """ value=""" & strValue & """></td>" & vbNewLine
	response.write "								</tr>" & vbNewLine

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddInputTextBoxWithExtra(strCaption, strName, strValue, intLen, strExtra)

	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><input class=""clsInputBox"" type=""text"" size=" & intLen & " name=""" & strName & """ value=""" & strValue & """ " & strExtra & "></td>" & vbNewLine
	response.write "								</tr>" & vbNewLine

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddInputTextBoxTD(strCaption, strName, strValue, intLen)

	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><input class=""clsInputBox"" type=""text"" size=" & intLen & " name=""" & strName & """ value=""" & strValue & """></td>" & vbNewLine

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddComboBox(strCaption, strName, arrValues, strSelected)

	Dim i
	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><select class=""clsInputBox"" name=""" & strName &  """>" & vbNewLine
	
	for i = 0 to Ubound(arrValues)
	 if UCASE(arrValues(i)) = UCASE(strSelected) then
			response.write "									<option selected value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		else
			response.write "									<option value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		end if
	next
	
	response.write "								</select></td></tr>" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddComboBoxWithExtra(strCaption, strName, arrValues, strSelected, strExtra) ''add extra capability, such as onchange, onclick, etc.

	Dim i
	response.write "								<tr>" & vbNewLine	
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><select class=""clsInputBox"" name=""" & strName &  """ " & strExtra & ">" & vbNewLine
	
	for i = 0 to Ubound(arrValues)
	 if UCASE(arrValues(i)) = UCASE(strSelected) then
			response.write "									<option selected value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		else
			response.write "									<option value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		end if
	next
	
	response.write "								</select></td></tr>" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddComboBoxTD(strCaption, strName, arrValues, strSelected)

	Dim i
	response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewLine
	response.write "									<td nowrap class=""clsTableText"" align=""left""><select class=""clsInputBox"" name=""" & strName &  """>" & vbNewLine
	
	for i = 0 to Ubound(arrValues)
	 if arrValues(i) = strSelected then
			response.write "									<option selected value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		else
			response.write "									<option value=""" & arrValues(i) & """>" & arrValues(i) & "</option>" & vbNewLine
		end if
	next
	
	response.write "								</select></td>" & vbNewLine
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub AddRadioButtonTD(strCaption, strName)

response.write "									<td nowrap class=""clsTableText"" align=""right"">" & strCaption & "</td>" & vbNewline
response.write "									<td nowrap class=""clsTableText"" align=""left""><input type=""radio"" name=""" & strName & """></td>" & vbNewline

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub CloseEditBoxTable()
	response.write "								</table>" & vbNewLine
	response.write "							<br>" & vbNewLine
	response.write "							</td>" & vbNewLine
	response.write "						</tr>" & vbNewLine
	response.write "" & vbNewLine
	response.write "						<tr>" & vbNewLine
	response.write "							<td class=""clsTableText"" align=""center"" nowrap>" & vbNewLine
	response.write "							<input type=""submit"" class=""clsButtonSmall"" value=""OK"" name=""OK"">" & vbNewLine
	response.write "							<input type=""button"" class=""clsButtonSmall"" value=""Cancel"" name=""Cancel"" onClick=""javascript:HideVisible();"">" & vbNewLine
	response.write "	  					</td>" & vbNewLine
	response.write " 						</tr>" & vbNewLine
	response.write " 					</table>" & vbNewLine
	response.write "				</td>" & vbNewLine
	response.write "			</tr>" & vbNewLine
	response.write "		</table>" & vbNewLine
	response.write "	</FORM>" & vbNewLine
	response.write "</DIV>" & vbNewLine
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub CloseEditBoxTableNoDiv()
	response.write "								</table>" & vbNewLine
	response.write "							<br>" & vbNewLine
	response.write "							</td>" & vbNewLine
	response.write "						</tr>" & vbNewLine
	response.write "" & vbNewLine
	response.write "						<tr>" & vbNewLine
	response.write "							<td class=""clsTableText"" align=""center"" nowrap>" & vbNewLine
	response.write "							<input type=""submit"" class=""clsButtonSmall"" value=""OK"" name=""OK"">" & vbNewLine
	response.write "							<input type=""button"" class=""clsButtonSmall"" value=""Cancel"" name=""Cancel"" onClick=""javascript:window.close();"">" & vbNewLine
	response.write "							</td>" & vbNewLine
	response.write " 						</tr>" & vbNewLine
	response.write " 					</table>" & vbNewLine
	response.write "				</td>" & vbNewLine
	response.write "			</tr>" & vbNewLine
	response.write "		</table>" & vbNewLine
	response.write "	</FORM>" & vbNewLine
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub CloseEditBoxTableNoForm()	'close the table, but not the form
	response.write "							</table>" & vbNewLine
	response.write "							<br>" & vbNewLine
	response.write "						</td>" & vbNewLine
	response.write "					</tr>" & vbNewLine
	response.write "" & vbNewLine
	response.write "					<tr>" & vbNewLine
	response.write "							<td class=""clsTableText"" align=""center"" nowrap>" & vbNewLine
	response.write "							<input type=""submit"" class=""clsButtonSmall"" value=""OK"" name=""OK"">" & vbNewLine
	response.write "							<input type=""button"" class=""clsButtonSmall"" value=""Cancel"" name=""Cancel"" onClick=""javascript:HideVisible();"">" & vbNewLine
	response.write "						</td>" & vbNewLine
	response.write " 					</tr>" & vbNewLine
	response.write " 				</table>" & vbNewLine
	response.write "			</td>" & vbNewLine
	response.write "		</tr>" & vbNewLine
	response.write "	</table>" & vbNewLine
	response.write "</DIV>" & vbNewLine
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteEditHeader(arrHeaderValues)
	Dim i
		
	response.write "		<tr>" & vbNewLine
	
	response.write "				<th class=""TableHeader"">Edit</th>" & vbNewline
	
	for i = 0 to UBound(arrHeaderValues)
		response.write "			<th class=""TableHeader"">" & arrHeaderValues(i) & "</th>" & vbNewLine
	next
	
	response.write "		</tr>" & vbNewLine
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteEditRow(arrRowValues, strDivName)
	Dim i
	
	if gbAddRowEven = True then
		gstrClass = "clsTableTextEven"
	else
		gstrClass = "clsTableTextOdd"
	end if
	
	gbAddRowEven = Not gbAddRowEven
	
	response.write "		<tr>" & vbNewline
	
	response.write "			<td class=""" & gstrClass & """ align=""center""><a href=""javascript:ShowEdit('" & strDivName & "')""><img src=""/us/images/edit.gif"" border=0 alt=""edit""></a></td>" & vbNewLine
	
	for i = 0 to UBound(arrRowValues)
		response.write "				<td class=""" & gstrClass & """>" & arrRowValues(i) & "</td>" & vbNewline
	next
	
	response.write "		</tr>" & vbNewline
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteEditRowTD(arrRowValues, strDivName)
	Dim i

	response.write "			<td class=""" & gstrClass & """ align=""center""><a href=""javascript:ShowEdit('" & strDivName & "')""><img src=""/mpte/us/images/edit.gif"" border=0 alt=""edit""></a></td>" & vbNewLine
	
	for i = 0 to UBound(arrRowValues)
		response.write "				<td class=""" & gstrClass & """>" & arrRowValues(i) & "</td>" & vbNewline
	next
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteRemoveHeader(arrHeaderValues, strHeaderID)
	Dim i
		
	response.write "		<tr>" & vbNewLine
	
	for i = 0 to UBound(arrHeaderValues)
		response.write "			<th class=""RuleEditorTableHeader"">" & arrHeaderValues(i) & "</th>" & vbNewLine
	next
	
	if strHeaderID <> "" then
		response.write "			<th class=""RuleEditorTableHeader""><img src=""/mpte/us/images/check.gif""></th>" & vbNewline
	else
		response.write "			<th class=""RuleEditorTableHeader"">Remove</th>" & vbNewline
	end if
	
	response.write "		</tr>" & vbNewLine
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteRemoveRow(arrRowValues, strRowID)
	Dim i
	Dim strClass
	
	if gbAddRowEven = True then
		gstrClass = "clsTableTextEven"
	else
		gstrClass = "clsTableTextOdd"
	end if
	
	gbAddRowEven = Not gbAddRowEven
	
	response.write "		<tr>" & vbNewline
	
	for i = 0 to UBound(arrRowValues)
		response.write "				<td class=""" & gstrClass & """>" & arrRowValues(i) & "</td>" & vbNewline
	next
	
	response.write "				<td class=""" & gstrClass & """ align=center><input type=""checkbox"" name=""" & strRowID & """></td>" & vbNewline
	
	
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub OpenBlankRow()

	response.write "			</tr>" & vbNewline
	if gbAddRowEven = True then
		gstrClass = "clsTableTextEven"
	else
 		gstrClass = "clsTableTextOdd"
	end if
	
	gbAddRowEven = Not gbAddRowEven

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub CloseBlankRow()

	response.write "			</tr>" & vbNewline

End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

%>
