Sub TestFindPO(id)
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set po = pc.GetProductOffering(id)
  wscript.echo "found po: " & po.ID & ", " & po.Name
End Sub

Sub TestFindFilteredPO
  Set pc = CreateObject("Metratech.MTProductCatalog")
  wscript.echo "FindProductOfferingsAsRowset"
  Set rowset = pc.FindProductOfferingsAsRowset
	rowset.MoveFirst
  While Not rowset.EOF
		Count = rowset.Count
		For i = 0 To Count - 1
				Name = rowset.Name(i)
				Value = rowset.Value(i)
				wscript.echo Name & " = " & Value
		Next
		wscript.echo "---------------------------------------"
		rowset.MoveNext
  Wend
End Sub


Function TestCreatePO()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set po = pc.CreateProductOffering
  po.Name = "PO Name"
  po.Description = "PO Description"
  po.SelfSubscribable = 1
  po.SelfUnsubscribable = 0
  po.EffectiveDate.StartDateType = 1
  po.EffectiveDate.StartDate = #4/1/2001#
  po.Save    
  wscript.echo "created po: " & po.ID & ", " & po.Name
  TestCreatePO = po.ID
End Function

Sub TestModifyPO(id)
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set po = pc.GetProductOffering(id)
  po.Name = "New Name"
  po.EffectiveDate.StartDate = #4/2/2001#
  po.Save
  wscript.echo "modified po: " & po.ID & ", " & po.Name

  'check for effect of modification
  Set po = pc.GetProductOffering(id)
  if po.Name = "New Name" then
	  wscript.echo "Name modification OK"
  else
	  wscript.echo "Name modification ERROR"
  end if

  if po.EffectiveDate.StartDate = #4/2/2001# then
    wscript.echo "EffectiveDate.StartDate  modification OK"
  else
    wscript.echo "EffectiveDate.StartDate  modification ERROR"
  end if

End Sub

Sub TestRemovePO(id)
	Set pc = CreateObject("Metratech.MTProductCatalog")
	pc.RemoveProductOffering(id)
	wscript.echo "removed po: " & id
End Sub

Sub TestPOProperties(id)
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set po = pc.GetProductOffering(id)
	
  Set props = po.Properties
  wscript.echo "po: " & po.ID & " has " & props.Count & " Properties"

  Set prop = props.Item(1)
  wscript.echo "props.Item(1) =" & prop.Value

  wscript.echo "---all properties of po:---" 
  For each prop in props
    wscript.echo prop.Name & "=" & prop.Value & " (" & prop.DataType & ")"
    if prop.DataType = "object" then 
      Set props = prop.Value.Properties
      For each prop2 in props
        wscript.echo prop.Name & "." & prop2.Name & "=" & prop2.Value & " (" & prop2.DataType & ")"
      next
    end if
  next

End Sub

id = TestCreatePO
TestPOProperties(id)
TestFindPO(id)
TestModifyPO(id)
TestRemovePO(id)

'TestFindFilteredPO
