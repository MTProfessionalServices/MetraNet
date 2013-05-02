dim ac
Dim pc
Dim ajtype
Dim pitype

Set ac = CreateObject("MetraTech.Adjustments.AdjustmentCatalog")
Set pc = CreateObject("MetraTech.MTProductCatalog")

Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")
Set ajtype = pitype.CreateAdjustmentType()
Dim login
Set login = CreateObject("Metratech.MTLoginContext")
Dim ctx
set ctx = login.Login("su", "system_user", "su123")

dim prop
dim outprop

ac.Initialize(ctx)
pc.SetSessionContext(ctx)


'create adjustment types for the conf call record
'UnusedPortCharges, OverusedPortCharges, CancelCharges, ReservationCharges
Set pitype = pc.GetPriceableItemTypeByName("AudioConfCall")
Set ajtype = pitype.CreateAdjustmentType()



'Call flat adjustment

Set ajtype = pitype.CreateAdjustmentType()
ajtype.SetSessionContext(ctx)
ajtype.Description = "Audio Conference Call Flat Adjustment"
ajtype.Name = "CallFlatAdjustment"
ajtype.DisplayName = "Audio Conference Call Flat Adjustment DisplayName"
ajtype.SupportsBulk = true
ajtype.AdjustmentFormula.EngineType = 1 'MTSQL
ajtype.AdjustmentFormula.Text = "Create Procedure DoAdjustmentCalc" & vbNewLine &_
          "-- required inputs " & vbNewLine &_
          "@UnusedPortChargesAdjustmentAmount DECIMAL," & vbNewLine &_
          "@OverusedPortChargesAdjustmentAmount DECIMAL," & vbNewLine &_
          "@CancelChargesAdjustmentAmount DECIMAL," & vbNewLine &_
          "@ReservationChargesAdjustmentAmount DECIMAL," & vbNewLine &_
          "-- non required inputs " & vbNewLine &_
          "@UnusedPortCharges DECIMAL," & vbNewLine &_
          "@OverusedPortCharges DECIMAL," & vbNewLine &_
          "@CancelCharges DECIMAL," & vbNewLine &_
          "@ReservationCharges DECIMAL," & vbNewLine &_
          "-- outputs" & vbNewLine &_
          "@AJ_UnusedPortCharges DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_OverusedPortCharges DECIMAL OUTPUT" & vbNewLine &_
          "@AJ_CancelCharges DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_ReservationCharges DECIMAL OUTPUT" & vbNewLine &_
          "as" & vbNewLine &_
          "set @AJ_UnusedPortCharges = @UnusedPortChargesAdjustmentAmount" & vbNewLine &_
          "set @AJ_OverusedPortCharges = @OverusedPortChargesAdjustmentAmount" & vbNewLine &_
          "set @AJ_CancelCharges = @CancelChargesAdjustmentAmount" & vbNewLine &_
          "set @AJ_ReservationCharges = @ReservationChargesAdjustmentAmount"
ajtype.Kind = 1 'Flat
ajtype.PriceableItemTypeID = pitype.ID

'add input properties
Set prop = ajtype.RequiredInputs.CreateMetaData("UnusedPortChargesAdjustmentAmount")
prop.DisplayName = "Adjustment Amount for Unused Port Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("OverusedPortChargesAdjustmentAmount")
prop.DisplayName = "Adjustment Amount for Overused Port Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("CancelChargesAdjustmentAmount")
prop.DisplayName = "Adjustment Amount for Cancellation Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("ReservationChargesAdjustmentAmount")
prop.DisplayName = "Adjustment Amount for Reservation Charges"
prop.DataType = 11 'decimal


'add output properties
Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_UnusedPortCharges")
outprop.DisplayName = "Adjustment For Unused Port Charge"
outprop.DataType = 11'decimal
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_OverusedPortCharges")
outprop.DisplayName = "Adjustment For Overused Port Charge"
outprop.DataType = 11'decimal
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_CancelCharges")
outprop.DisplayName = "Adjustment For Cancellation Charges"
outprop.DataType = 11'decimal
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_ReservationCharges")
outprop.DisplayName = "Adjustment For Reservation Charges"
outprop.DataType = 11'decimal
outprop.Required = false 'output props are not required

ajtype.Save


'Call percentage adjustment

Set ajtype = pitype.CreateAdjustmentType()
ajtype.SetSessionContext(ctx)
ajtype.Description = "Audio Conference Call Percentage Adjustment"
ajtype.Name = "CallPercentAdjustment"
ajtype.DisplayName = "Audio Conference Call Percentage Adjustment DisplayName"
ajtype.SupportsBulk = true
ajtype.AdjustmentFormula.EngineType = 1 'MTSQL
ajtype.AdjustmentFormula.Text = "Create Procedure DoAdjustmentCalc" & vbNewLine &_
          "-- required inputs " & vbNewLine &_
          "@UnusedPortChargesPercent DECIMAL," & vbNewLine &_
          "@OverusedPortChargesPercent DECIMAL," & vbNewLine &_
          "@CancelChargesPercent DECIMAL," & vbNewLine &_
          "@ReservationChargesPercent DECIMAL," & vbNewLine &_
          "-- non required inputs " & vbNewLine &_
          "@UnusedPortCharges DECIMAL," & vbNewLine &_
          "@OverusedPortCharges DECIMAL," & vbNewLine &_
          "@CancelCharges DECIMAL," & vbNewLine &_
          "@ReservationCharges DECIMAL," & vbNewLine &_
          "-- outputs" & vbNewLine &_
          "@AJ_UnusedPortCharges DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_OverusedPortCharges DECIMAL OUTPUT" & vbNewLine &_
          "@AJ_CancelCharges DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_ReservationCharges DECIMAL OUTPUT" & vbNewLine &_
          "as" & vbNewLine &_
          "set @AJ_UnusedPortCharges = @UnusedPortCharges * (@UnusedPortChargesPercent * 0.01)" & vbNewLine &_
          "set @AJ_OverusedPortCharges = @OverusedPortCharges * (@OverusedPortChargesPercent * 0.01)" & vbNewLine &_
          "set @AJ_CancelCharges = @CancelCharges * (@CancelChargesPercent * 0.01)" & vbNewLine &_
          "set @AJ_ReservationCharges = @ReservationCharges * (@ReservationChargesPercent * 0.01)"
          
ajtype.Kind = 2 'Percent
ajtype.PriceableItemTypeID = pitype.ID

'add input properties
Set prop = ajtype.RequiredInputs.CreateMetaData("UnusedPortChargesPercent")
prop.DisplayName = "Adjustment Percent for Unused Port Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("OverusedPortChargesPercent")
prop.DisplayName = "Adjustment Percent for Overused Port Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("CancelChargesPercent")
prop.DisplayName = "Adjustment Percent for Cancellation Charges"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("ReservationChargesPercent")
prop.DisplayName = "Adjustment Percent for Reservation Charges"
prop.DataType = 11 'decimal


'add output properties
Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_UnusedPortCharges")
outprop.DisplayName = "Adjustment For Unused Port Charge"
outprop.DataType = 11'integer
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_OverusedPortCharges")
outprop.DisplayName = "Adjustment For Overused Port Charge"
outprop.DataType = 11'integer
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_CancelCharges")
outprop.DisplayName = "Adjustment For Cancellation Charges"
outprop.DataType = 11'integer
outprop.Required = false 'output props are not required

Set outprop = ajtype.ExpectedOutputs.CreateMetaData("AJ_ReservationCharges")
outprop.DisplayName = "Adjustment For Reservation Charges"
outprop.DataType = 11'integer
outprop.Required = false 'output props are not required

ajtype.Save







'create adjustment types for the conf connection record
'BridgeAmount, TransportAmount
Set ajtype = nothing
Set pitype = pc.GetPriceableItemTypeByName("AudioConfConn")
Set ajtype = pitype.CreateAdjustmentType()

'create adjustment types for the conf connection record
'BridgeAmount, TransportAmount


'Connection Minutes Adjustment

ajtype.SetSessionContext(ctx)
ajtype.Description = "Audio Conference Connection Minutes Adjustment"
ajtype.Name = "ConnectionMinutesAdjustment"
ajtype.DisplayName = "Audio Conference Connection Minutes Adjustment DisplayName"
ajtype.SupportsBulk = true
ajtype.AdjustmentFormula.EngineType = 1 'MTSQL
ajtype.AdjustmentFormula.Text = "Create Procedure DoAdjustmentCalc" & vbNewLine &_
          " -- inputs " & vbNewLine &_
         "@Minutes INTEGER, " & vbNewLine &_
         "@ConnectionMinutes DECIMAL, " & vbNewLine &_
         "@BridgeAmount DECIMAL, " & vbNewLine &_
         "@TransportAmount DECIMAL, " & vbNewLine &_
         "-- outputs " & vbNewLine &_
         "@AJ_BridgeAmount DECIMAL OUTPUT, " & vbNewLine &_
         " @AJ_TransportAmount DECIMAL OUTPUT " & vbNewLine &_
         "as " & vbNewLine &_
         "set @AJ_BridgeAmount = CAST(@Minutes as DECIMAL) * round(@BridgeAmount/@ConnectionMinutes,2) " & vbNewLine &_
         "set @AJ_TransportAmount = CAST(@Minutes as DECIMAL) * round(@TransportAmount/@ConnectionMinutes,2)"
ajtype.Kind = 3 'Minutes
ajtype.PriceableItemTypeID = pitype.ID

'add input properties
dim minuteprop
Set minuteprop = ajtype.RequiredInputs.CreateMetaData("Minutes")
minuteprop.DisplayName = "Adjustment Minutes"
minuteprop.DataType = 2'integer
minuteprop.Required = true 'input props are required

'add output properties
dim ajbridge
dim ajtransport
Set ajbridge = ajtype.ExpectedOutputs.CreateMetaData("AJ_BridgeAmount")
ajbridge.DisplayName = "Adjustment For Bridge Charge"
ajbridge.DataType = 11'integer
ajbridge.Required = false 'output props are not required
Set ajtransport = ajtype.ExpectedOutputs.CreateMetaData("AJ_TransportAmount")
ajtransport.DisplayName = "Adjustment For Transport Charge"
ajtransport.DataType = 11'integer
ajtransport.Required = false 'output props are not required



ajType.Save

'Connection Flat Adjustment

Set ajtype = pitype.CreateAdjustmentType()
ajtype.SetSessionContext(ctx)
ajtype.Description = "Audio Conference Connection Flat Adjustment"
ajtype.Name = "ConnectionFlatAdjustment"
ajtype.DisplayName = "Audio Conference Connection Flat Adjustment DisplayName"
ajtype.SupportsBulk = true
ajtype.AdjustmentFormula.EngineType = 1 'MTSQL
ajtype.AdjustmentFormula.Text = "Create Procedure DoAdjustmentCalc" & vbNewLine &_
          "-- inputs " & vbNewLine &_
          "@BridgeAdjustmentAmount DECIMAL," & vbNewLine &_
          "@TransportAdjustmentAmount DECIMAL," & vbNewLine &_
          "@BridgeAmount DECIMAL," & vbNewLine &_
          "@TransportAmount DECIMAL," & vbNewLine &_
          "-- outputs" & vbNewLine &_
          "@AJ_BridgeAmount DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_TransportAmount DECIMAL OUTPUT" & vbNewLine &_
          "as" & vbNewLine &_
          "set @AJ_BridgeAmount = @BridgeAdjustmentAmount" & vbNewLine &_
          "set @AJ_TransportAmount = @TransportAdjustmentAmount"
ajtype.Kind = 1 'Flat
ajtype.PriceableItemTypeID = pitype.ID

'add input properties
Set prop = ajtype.RequiredInputs.CreateMetaData("BridgeAdjustmentAmount")
prop.DisplayName = "Bridge Amount"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("TransportAdjustmentAmount")
prop.DisplayName = "Transport Amount"
prop.DataType = 11 'decimal

'add output properties
Set ajbridge = ajtype.ExpectedOutputs.CreateMetaData("AJ_BridgeAmount")
ajbridge.DisplayName = "Adjustment For Bridge Amount Charge"
ajbridge.DataType = 11'integer
ajbridge.Required = false 'output props are not required
Set ajtransport = ajtype.ExpectedOutputs.CreateMetaData("AJ_TransportAmount")
ajtransport.DisplayName = "Adjustment For Transport Amount Charge"
ajtransport.DataType = 11'integer
ajtransport.Required = false 'output props are not required



'Connection Percent Adjustment

Set ajtype = pitype.CreateAdjustmentType()
ajtype.SetSessionContext(ctx)
ajtype.Description = "Audio Conference Connection Percent Adjustment"
ajtype.Name = "ConnectionPercentAdjustment"
ajtype.DisplayName = "Audio Conference Connection Percent Adjustment DisplayName"
ajtype.SupportsBulk = true
ajtype.AdjustmentFormula.EngineType = 1 'MTSQL
ajtype.AdjustmentFormula.Text = "Create Procedure DoAdjustmentCalc" & vbNewLine &_
          "-- inputs " & vbNewLine &_
          "@BridgeAdjustmentPercent DECIMAL," & vbNewLine &_
          "@TransportAdjustmentPercent DECIMAL," & vbNewLine &_
          "@BridgeAmount DECIMAL," & vbNewLine &_
          "@TransportAmount DECIMAL," & vbNewLine &_
          "-- outputs" & vbNewLine &_
          "@AJ_BridgeAmount DECIMAL OUTPUT," & vbNewLine &_
          "@AJ_TransportAmount DECIMAL OUTPUT" & vbNewLine &_
          "as" & vbNewLine &_
          "set @AJ_BridgeAmount = @BridgeAmount * (@BridgeAdjustmentPercent * 0.01)" & vbNewLine &_
          "set @AJ_TransportAmount = @TransportAmount * (@TransportAdjustmentPercent * 0.01)"
          
ajtype.Kind = 2 'Flat
ajtype.PriceableItemTypeID = pitype.ID

'add input properties
Set prop = ajtype.RequiredInputs.CreateMetaData("BridgeAdjustmentPercent")
prop.DisplayName = "Bridge Amount"
prop.DataType = 11 'decimal

Set prop = ajtype.RequiredInputs.CreateMetaData("TransportAdjustmentPercent")
prop.DisplayName = "Transport Amount"
prop.DataType = 11 'decimal

'add output properties
Set ajbridge = ajtype.ExpectedOutputs.CreateMetaData("AJ_BridgeAmount")
ajbridge.DisplayName = "Adjustment For Bridge Amount Charge"
ajbridge.DataType = 11'integer
ajbridge.Required = false 'output props are not required
Set ajtransport = ajtype.ExpectedOutputs.CreateMetaData("AJ_TransportAmount")
ajtransport.DisplayName = "Adjustment For Transport Amount Charge"
ajtransport.DataType = 11'integer
ajtransport.Required = false 'output props are not required



'Connection adjustment template

wscript.echo "Configure adjustment template"
dim id
id = ajType.Save
Dim pi
Set pi = pitype.GetTemplates(1)

dim ajtemplate
id = ac.getAdjustmentTypeByName("ConnectionMinutesAdjustment").ID
set ajtemplate = pi.CreateAdjustment(id)
wscript.echo ajtemplate.Properties.Count
for each prop in ajtemplate.Properties
      wscript.echo prop.Name
      wscript.echo prop.Value
    
 Next
 
 ajtemplate.Save

