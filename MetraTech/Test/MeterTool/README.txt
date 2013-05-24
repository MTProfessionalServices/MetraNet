What's new in MeterTool?
---------------------------------------

Resizing
Fixed non-random property selection
Fixed auto generate batch name - by default it is on now

Auth-Enabled Pipelines now Supported
Plugins.GetUsername - Returns a valid username from the MT namespace on locahost.
Plugins.EndTime     - Returns an end time based on the parents ScheduledStartTime and ScheduledDuration.
Property Strings support [now], [metratime], and [ticks] replacements - and can also pick randomly or iterate through
Equals Property supports [property], [parent.property], and [propertybag.TestID]


Command line usage: MeterTool meter /server:localhost /file:"t:\tools\MeterTool\test data\audioconfcall.xml" /close:true /synchronous:true         
