-- INSERT DATA FRom sample counter types
delete  from t_counter_params
delete  from t_counter_params_metadata
delete  from t_counter
delete  from t_counter_metadata
delete  from t_counter_map
delete  from t_base_props

declare @id as int
declare @id_counter_instance as int
declare @param_id as int
declare @scratch as int

--ADD COUNTERMETADATA
exec AddCounterType 180, "SumOfOneProperty", "Summation over one product view property", "SUM(%%A%%)", @id output
--ADD COUNTER
exec AddCounterInstance 170, "TotalAudioConferencingUsage", "Total audioconferencing usage", @id, @id_counter_instance output

--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'A', @id, 'ProductViewProperty', 'NUMERIC', @param_id output
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall/Amount', @scratch


--ADD COUNTERMETADATA
exec AddCounterType 180, "SumOfTwoProperties", "Summation over two product view properties", "SUM(%%A%%)+SUM(%%B%%)", @id output
--ADD COUNTER
exec AddCounterInstance 170, "TotalPortCharges", "Total audioconferencing calls port charges: unused/overused", @id, @id_counter_instance output
--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'A', @id, 'ProductViewProperty', 'NUMERIC', @param_id output
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall/UnusedPortCharges', @scratch

--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'B', @id, 'ProductViewProperty', 'NUMERIC', @param_id output
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall/OverusedPortCharges', @scratch



--ADD COUNTERMETADATA
exec AddCounterType 180, "TotalUsageCounter", "Summation over total invoice amount", "SUM(t_acc_usage/Amount)", @id output
--ADD COUNTER
exec AddCounterInstance 170, "TotalUsage", "Total Bill - DiscountTarget Counter", @id, @id_counter_instance output

-- There is no parameters in this case

--ADD COUNTERMETADATA
exec AddCounterType 180, "DecrementingCounter", "Subtracting summation over one product view property from a constant", "%%A%% - SUM(%%B%%)", @id output

--ADD COUNTER
exec AddCounterInstance 170, "ReservationChargesDecrement From 1000 reservation charges", "Decrement From 1000 on reservation charges", @id, @id_counter_instance output

--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'A', @id, 'CONST', NULL, @param_id output
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, '1000', @scratch

--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'B', @id, 'ProductViewProperty', 'NUMERIC', @param_id output

--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall/ReservationCharges', @scratch


--ADD COUNTERMETADATA
exec AddCounterType 180, "CountPVRecords", "Count over a certain product view records", "COUNT(%%A%%)", @id OUTPUT
--ADD COUNTER
exec AddCounterInstance 170, "NumConfCalls", "Total number of audio conferences", @id, @id_counter_instance output
--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'A', @id, 'ProductView', NULL, @param_id OUTPUT
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall', @scratch

--ADD COUNTERMETADATA
exec AddCounterType 180, "SingleAverage", "Average PV Property Value", "AVG(%%A%%)", @id OUTPUT
--ADD COUNTER
exec AddCounterInstance 170, "AverageConferenceDuration", "Average Duration of a conference call", @id, @id_counter_instance output
--ADD COUNTERPARAMMETADATA
exec AddCounterParamType 190, 'A', @id, 'ProductViewProperty', 'NUMERIC', @param_id OUTPUT
--ADD COUNTERPARAM
exec AddCounterParam @id_counter_instance, @param_id, 'metratech.com/AudioConfCall/ActualDuration', @scratch


SELECT * from t_base_props bp, t_counter_metadata cm WHERE bp.id_prop=cm.id_prop
SELECT * from t_base_props bp, t_counter_params_metadata cm WHERE bp.id_prop=cm.id_prop

SELECT * from t_base_props bp, t_counter c WHERE bp.id_prop=c.id_prop
SELECT * from t_counter_params cp 

