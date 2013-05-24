Sub TestProgids()
  wscript.echo "Testing progid correctness..."
   wscript.echo "Creating Metratech.MTCounterParameter"
  Set o = CreateObject("Metratech.MTCounterParameter")
  wscript.echo "Creating Metratech.MTCollection"
  Set o = CreateObject("Metratech.MTCollection")
  wscript.echo "Creating Metratech.MTCounter"
  Set o = CreateObject("Metratech.MTCounter")
  wscript.echo "Creating Metratech.MTCounterType"
  Set o = CreateObject("Metratech.MTCounterType")
  
  
  	
End Sub

Sub TestGetCounterTypes()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  wscript.echo "Created Metratech.MTProductCatalog object, getting counter types"
  Set types = pc.GetCounterTypes
  wscript.echo "found " & types.Count & " counter types"
  For each ct in types
  	'Set ct = types.Item(i)
  	ID = ct.ID
  	Name = ct.Name
  	Desc = ct.Description
  	FormulaTemplate = ct.FormulaTemplate
  	wscript.echo "ID: " & ID
  	wscript.echo "Name: " & Name
  	wscript.echo "Description: " & Desc
  	wscript.echo "FormulaTemplate: " & FormulaTemplate
  	Set params = ct.Parameters
  	wscript.echo "Found " & params.Count & " parameters:"
  	For j=1 To params.Count
  		Set param = params.Item(j)
  		param_name = param.Name
  		param_kind = param.Kind
  		param_dbtype = param.DBType
  		wscript.echo "Parameter Name: " & param_name
  		wscript.echo "Parameter Kind: " & param_kind
  		wscript.echo "Parameter Database type: " & param_dbtype
  		wscript.echo "---------------------------------------"
  	Next
  	wscript.echo "---------------------------------------"
  Next
  wscript.echo "Done getting all counter types"
  wscript.echo ""
  	
End Sub

Sub TestGetCounterType()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set types = pc.GetCounterTypes
  wscript.echo "Getting all types..."
  wscript.echo "found " & types.Count & " counter types"
  wscript.echo "Obtaining ID from first element..."
  Set ct = types.Item(i)
  ID = ct.ID
  wscript.echo "ID is " & ID
  wscript.echo "Creating new MTCounterType object given db id"
  Set ct = pc.GetCounterType(ID)
  wscript.echo "ID: " & ct.ID
  wscript.echo "Name: " & ct.Name
  wscript.echo "Description: " & ct.Description
  wscript.echo "FormulaTemplate: " & ct.FormulaTemplate
  wscript.echo "Done getting one counter type by database id"
  wscript.echo "---------------------------------------"
  	
End Sub

Sub TestGetCounterTypeByName()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set types = pc.GetCounterTypes
  wscript.echo "Getting all types..."
  wscript.echo "found " & types.Count & " counter types"
  wscript.echo "Obtaining Name from first element..."
  Set ct = types.Item(i)
  Name = ct.Name
  wscript.echo "Name is " & Name
  wscript.echo "Creating new MTCounterType object by given Name"
  Set ct = pc.GetCounterTypeByName(Name)
  wscript.echo "ID: " & ct.ID
  wscript.echo "Name: " & ct.Name
  wscript.echo "Description: " & ct.Description
  wscript.echo "FormulaTemplate: " & ct.FormulaTemplate
  wscript.echo "Done getting one counter type by Name"
  wscript.echo "---------------------------------------"
  
End Sub


Sub TestFindCountersAsRowset()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  Set rowset = pc.FindCountersAsRowset
  wscript.echo "found" & rowset.RecordCount & " counter instances"
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
  wscript.echo "Done retrieving counter instances as rowset"
  wscript.echo ""
  	
End Sub

Sub TestGetCountersOfType()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  wscript.echo "Created Metratech.MTProductCatalog object, getting counter types"
  Set types = pc.GetCounterTypes
  wscript.echo "found " & types.Count & " counter types"
  For each ct in types
  	ID = ct.ID
  	Name = ct.Name
  	wscript.echo "Counter Type Name: " & Name & "ID = (" & ID & ")"
  	wscript.echo "---------------------------------------"
  	Set counters = pc.GetCountersOfType(ID)
  	wscript.echo "Found " & counters.Count & " instances of this type"
  	wscript.echo "---------------------------------------"
  	
  	For each c in counters
  		c_id = c.ID
  		c_name = c.Name
  		c_description = c.Description
  		c_formula = c.Formula(0) ' 0 For expanded
  		
  		wscript.echo "ID: " & c_id
  		wscript.echo "Name: " & c_name
  		wscript.echo "Description: " & c_description
  		wscript.echo "Formula: " & c_formula
  		
  		Set params = c.Parameters
  				wscript.echo "Found " & params.Count & " parameters:"
  				For j=1 To params.Count
  					Set param = params.Item(j)
  					param_name = param.Name
  					param_value = param.Value
  					param_kind = param.Kind
  					param_dbtype = param.DBType
  					wscript.echo "Parameter Name: " & param_name
  					wscript.echo "Parameter Value: " & param_value
  					wscript.echo "Parameter Kind: " & param_kind
  					wscript.echo "Parameter Database type: " & param_dbtype
  					wscript.echo "---------------------------------------"
  		Next
  		
  	
  Next
 	wscript.echo "---------------------------------------" 
  Next
  	
End Sub


Sub TestGetCounter()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  wscript.echo "Testing ProductCatalog::GetCounter(DBID) method"
  wscript.echo "Calling ProductCatalog::FindCountersAsRowset() first to get DB ids"
  Set rowset = pc.FindCountersAsRowset
  wscript.echo "found " & rowset.RecordCount & " counter instances"
  rowset.MoveFirst
  While Not rowset.EOF
		Count = rowset.Count
		For i = 0 To Count - 1
				Name = rowset.Name(i)
				Value = rowset.Value(i)
				If Name = "id_prop" Then
					wscript.echo "Loading MTCounter object state for database id " & Value
					Set c = pc.GetCounter(Value)
					wscript.echo "ID: " & c.ID
  				wscript.echo "Name: " & c.Name
  				wscript.echo "Description: " & c.Description
  				wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  				Set params = c.Parameters
  				wscript.echo "Found " & params.Count & " parameters:"
  				For j=1 To params.Count
  					Set param = params.Item(j)
  					param_name = param.Name
  					param_value = param.Value
  					param_kind = param.Kind
  					param_dbtype = param.DBType
  					wscript.echo "Parameter Name: " & param_name
  					wscript.echo "Parameter Value: " & param_value
  					wscript.echo "Parameter Kind: " & param_kind
  					wscript.echo "Parameter Database type: " & param_dbtype
  					wscript.echo "---------------------------------------"
  				Next
  				wscript.echo "---------------------------------------"
				End If
		Next
		rowset.MoveNext
  Wend
  wscript.echo "Done loading MTCounter instances by db ids"
  wscript.echo "---------------------------------------"
  	
End Sub

Sub TestSetParam()
  Set pc = CreateObject("Metratech.MTProductCatalog")
  wscript.echo "Testing ProductCatalog::GetCounter(DBID) method"
  wscript.echo "Calling ProductCatalog::FindCountersAsRowset() first to get DB ids"
  Set rowset = pc.FindCountersAsRowset
  wscript.echo "found " & rowset.RecordCount & " counter instances"
  rowset.MoveFirst
  While Not rowset.EOF
		Count = rowset.Count
		For i = 0 To Count - 1
				Name = rowset.Name(i)
				Value = rowset.Value(i)
				If Name = "id_prop" Then
					wscript.echo "Loading MTCounter object state for database id " & Value
					Set c = pc.GetCounter(Value)
					wscript.echo "ID: " & c.ID
  				wscript.echo "Name: " & c.Name
  				wscript.echo "Description: " & c.Description
  				wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  				wscript.echo "Formula Template: " & c.Formula(1) '0 For expanded form, 1 for template
  				Set params = c.Parameters
  				wscript.echo "Found " & params.Count & " parameters:"
  				For j=1 To params.Count
  					Set param = params.Item(j)
  					param_name = param.Name
  					param_value = param.Value
  					param_kind = param.Kind
  					param_dbtype = param.DBType
  					wscript.echo "Parameter Name: " & param_name
  					wscript.echo "Parameter Value: " & param_value
  					wscript.echo "Parameter Kind: " & param_kind
  					wscript.echo "Parameter Database type: " & param_dbtype
  					wscript.echo "Replacing Value for " & param_name & " With ChangedValue" 
  					c.SetParameter param_name, "ChangedValue"
  					wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  					wscript.echo "---------------------------------------"
  				Next
  				wscript.echo "---------------------------------------"
				End If
		Next
		rowset.MoveNext
  Wend
  wscript.echo "Done loading MTCounter instances by db ids"
  wscript.echo "---------------------------------------"
  	
End Sub


Function TestCreateNewCounter()
	Set pc = CreateObject("Metratech.MTProductCatalog")
  Set ct = CreateObject("Metratech.MTCounterType")
  wscript.echo "Testing CMTProductCatalog::GetCounterTypeByName() method"
  Set ct = pc.GetCounterTypeByName("SumOfTwoProperties")
  wscript.echo "Testing CMTCounterType::GetCounters() method"
  Set counters = ct.GetCounters
  wscript.echo "Found " & counters.Count & " instances of this type"
  wscript.echo "Testing CMTCounterType::CreateCounter() method"
  Set c = ct.CreateCounter
  
  c.Name = "TestHarness"
  c.Description = "TestHarness instance of SumOfTwoProperties counter type"
  wscript.echo  "Setting all parameters..."
  Set params = c.Parameters
  For each param in params
 	 c.SetParameter param.Name, "TestHarnessParamValue"
  Next
  wscript.echo "Saving counter instance"
  dbid =  c.Save
  wscript.echo "Creating Counter instance with database id " & dbid
  wscript.echo "Testing CMTCounterType::GetCounters() method"
  Set counters = ct.GetCounters
  wscript.echo "Found " & counters.Count & " instances of this type"
  
  wscript.echo "---------------------------------------"
  
  TestCreateNewCounter = dbid
End Function

Function TestCreateNewCounterErrorMessage()
	Set pc = CreateObject("Metratech.MTProductCatalog")
  Set ct = CreateObject("Metratech.MTCounterType")
  wscript.echo "Testing CMTProductCatalog::GetCounterTypeByName(SumOfTwoProperties) method"
  Set ct = pc.GetCounterTypeByName("SumOfTwoProperties")
  wscript.echo "Testing CMTCounterType::GetCounters() method"
  Set counters = ct.GetCounters
  wscript.echo "Found " & counters.Count & " instances of this type"
  wscript.echo "Testing CMTCounterType::CreateCounter() method"
  Set c = ct.CreateCounter
  wscript.echo "Testing incomplete params error message"
  c.Name = "TestHarnessWithError"
  c.Description = "TestHarness With Error"
  wscript.echo  "Setting partial parameters..."
  Set params = c.Parameters
  Set param = params.Item(1)
  c.SetParameter param.Name, "PartialParamValue"
  wscript.echo "Saving counter instance"
  dbid =  c.Save
  wscript.echo "Creating Counter instance with database id " & dbid
  wscript.echo "Testing CMTCounterType::GetCounters() method"
  Set counters = ct.GetCounters
  wscript.echo "Found " & counters.Count & " instances of this type"
  
  wscript.echo "---------------------------------------"
End Function 


Sub TestCounterCreateAndExecute (CounterTypeName)

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  For j=1 To params.Count
  	Set param = params.Item(j)
  		param_name = param.Name
  		param_value = param.Value
  		param_kind = param.Kind
  		param_dbtype = param.DBType
  		wscript.echo "Parameter Name: " & param_name
  		wscript.echo "Parameter Value: " & param_value
  		wscript.echo "Parameter Kind: " & param_kind
  		wscript.echo "Parameter Database type: " & param_dbtype
  		c.SetParameter param_name, "metratech.com/AudioConfConnection/tax_federal"
  		wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  		wscript.echo "---------------------------------------"
  Next
  wscript.echo "Testing Counter::Save"
  c.Name = "PersentageBasedDiscountTarget"
  c.Description = "This target calculates a total bill usage"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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

Sub TestSumOfOnePropertyCounter

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "SumOfOneProperty"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  
  If params.Count <> 1 Then
  	wscript.echo "Number of parameters has to be 1"
  	Return
  End If
  	
  Set param = params.Item(1)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, "metratech.com/AudioConfCall/OverusedPortCharges"
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  
  wscript.echo "Testing Counter::Save"
  c.Name = "Test 1 parameter counter"
  c.Description = "This counter has two parameters"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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

Sub TestTotalUsageCounter

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "TotalUsageCounter"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  
  If params.Count <> 0 Then
  	wscript.echo "Number of parameters has to be 0"
  	Return
  End If
  
  
  wscript.echo "Testing Counter::Save"
  c.Name = "Test TotalUsage counter"
  c.Description = "This counter has two parameters"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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


Sub TestSumOfTwoPropertiesCounter

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "SumOfTwoProperties"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  
  If params.Count <> 2 Then
  	wscript.echo "Number of parameters has to be 2"
  	Return
  End If
  	
  Set param = params.Item(1)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, "metratech.com/AudioConfConnection/tax_federal"
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  Set param = params.Item(2)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, "metratech.com/AudioConfCall/amount"
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  wscript.echo "Testing Counter::Save"
  c.Name = "Test 2 parameter counter"
  c.Description = "This counter has two parameters"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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

Sub TestDecrementingCounter

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "DecrementingCounter"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  
  If params.Count <> 2 Then
  	wscript.echo "Number of parameters has to be 2"
  	Return
  End If
  	
  Set param = params.Item(1)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, 1000
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  Set param = params.Item(2)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, "metratech.com/AudioConfCall/amount"
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  wscript.echo "Testing Counter::Save"
  c.Name = "Test 2 parameter counter"
  c.Description = "This counter has two parameters"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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

Sub TestOneProductViewCountCounter

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "CountPVRecords"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  wscript.echo "Testing Counter::Parameters"
  Set params = c.Parameters
  wscript.echo "Testing Counter::SetParameter"
  wscript.echo "Found " & params.Count & " parameters:"
  
  If params.Count <> 1 Then
  	wscript.echo "Number of parameters has to be 1"
  	Return
  End If
  	
  Set param = params.Item(1)
  param_name = param.Name
  param_value = param.Value
  param_kind = param.Kind
  param_dbtype = param.DBType
  wscript.echo "Parameter Name: " & param_name
  wscript.echo "Parameter Value: " & param_value
  wscript.echo "Parameter Kind: " & param_kind
  wscript.echo "Parameter Database type: " & param_dbtype
  c.SetParameter param_name, "metratech.com/audioConfPlaybackSetup"
  wscript.echo "Formula: " & c.Formula(0) '0 For expanded form, 1 for template
  wscript.echo "---------------------------------------"
  
  
  wscript.echo "Testing Counter::Save"
  c.Name = "Test 1 parameter counter"
  c.Description = "This counter has one parameter"
  dbid = c.Save()
  wscript.echo "Testing Counter::Execute"
  Set rowset = c.Execute(0, #1/1/2001#, #4/1/2001#, coll)
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

Sub TestProperties

	Set pc = CreateObject("Metratech.MTProductCatalog")
	Set coll = CreateObject("Metratech.MTCollection")
	CounterTypeName = "CountPVRecords"
	'set accounts
	coll.Add(123)
	coll.Add(124)
	coll.Add(125)
  Dim ct
  Dim c
  wscript.echo "Testing Counter Execution for type name: " & CounterTypeName
  
  wscript.echo "Testing ProductCatalog::GetCounterTypeByName"
  Set ct = pc.GetCounterTypeByName(CounterTypeName)
  wscript.echo "Testing CounterType::CreateCounter"
  Set c = ct.CreateCounter()
  
  c.Name = "Test 1 parameter counter"
  c.Description = "This counter has one parameter"
	
	Set props = c.Properties
  wscript.echo prop("Name")
  wscript.echo c.Properties("Description")
  
  

End Sub

Dim logger, strStartTime, strEndTime, boolResult
strStartTime = CStr(Now())

Set logger = CreateObject("MTTestAPI.TestAPI")




'TestProgids
'TestGetCounterTypes
'TestGetCounterType
'TestGetCounterTypeByName
'TestFindCountersAsRowset
'TestGetCountersOfType
'TestGetCounter
'TestSetParam
'TestCreateNewCounter
'TestCreateNewCounterErrorMessage

'TestSumOfOnePropertyCounter
'TestSumOfTwoPropertiesCounter
'TestTotalUsageCounter
'TestDecrementingCounter
'TestOneProductViewCountCounter
TestProperties
