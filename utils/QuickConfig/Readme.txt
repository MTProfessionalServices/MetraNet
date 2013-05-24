README for QuickConfig
© 2006 by MetraTech Corp.



Purpose:
QuickConfig is an unsupported MetraConnect utility for creating new  MetraConnect-DB configuration (MeterConfig.xml) files. Such files contain the information required by MetraConnect-DB to meter usage from a mediation server and send it to a MetraNet server. QuickConfig provides a convenient means of modifying the most commonly required properties. 



Inputs:
QuickConfig requires a canonical configuration file to use as a template for new ones. It is distributed with a training template (TrainingTemplate.xml) that it will automatically open if left in the same folder as QuickConfig. If removed, you can browse for any other MetraConnect-DB configuration file. The default browse location is C:\Program Files\MetraTech\MetraConnect\Bin, where you can select and use MeterConfig.xml as your template. A Load Template on Startup option automatically loads the last-used template.



Output:
QuickConfig generates a completely new MeterConfig.xml file to the folder in which you are running QuickConfig.exe or another location that you browse for. QuickConfig will not let you overwrite the template you are using. Following generation, you must reload the template before generating again.



Usage:
QuickConfig organizes properties into several logical groups that can be easily edited:
     Parent Service (Rename)
          Name, Synchronous, Session Set, MSIXDEF file path
     Child Services (Add, Rename, or Delete)
          Name, Synchronous, Session Set, MSIXDEF file path
     Primary Key (Add, Rename, or Delete)
          Name, Type, Length, Required
     Log Filename
          Path
     Data Source
          DB Type, DB Name, Server Name (Pipeline), Username, Password,      Serialized Server Context
         
Note: DB Type and DB Name are for the mediation database. Server Name, Username, and Password are for the MetraNet primary pipeline server.

When you're ready, click Generate. A dialog confirms generation and the location of the new file. If Open Generated File is selected, the file will be opened automatically in your default XML editor.

After generating, you must reload the template. You cannot make further edits till you do this. If you need to modify the generated file, but do not wish to start over with the original template, simply open the generated file as your new configuration file.



Limitations:
The Advanced options are not implemented in this version.



Caution:
Always check the generated configuration file in a text editor to confirm that properties have been generated correctly. Then test thoroughly. Further manual edits may be required.



Last Updated: February 14, 2006.





