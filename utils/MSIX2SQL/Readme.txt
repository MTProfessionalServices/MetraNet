README for MSIX2SQL
© 2005 by MetraTech Corp.



Purpose:
MSIX2SQL is an unsupported MetraConnect utility for generating the SQL
code for creating service definition tables based on the properties
defined in metering configuration files and service definition files.
The SQL can be executed to create service tables in the mediation
database for metering with MetraConnect-DB to a MetraNet server.



Inputs:
The preferred input for MSIX2SQL is a MetraConnect-DB metering
configuration file (identified in MetraConnect 3.7 and 4.0 as the
"sdkconfig" file). Using the parent and child services listed in the
configuration file, MSIX2SQL will parse the corresponding MSIXDEF files.
MSIX2SQL can also generate SQL for individual MSIXDEF files, with some
limitations (see below).



Output:
MSIX2SQL generates a <servicename>.sql file corresponding with each
<servicename>.msixdef. The content of these files is:
    - A DROP table statement.
    - A CREATE table statement, including <tableprefix>_><servicename> -
      with the columns to create, one for each PTYPE in the MSIXDEF file.
    - A PRIMARY key or FOREIGN key constraint statement (if found in the
      configuration file) for one or more columns.
    - Control columns (if found in the configuration file).

The SQL files are generated in the same location as the metering
configuration file if one is used.



Capabilities:
- Files can be selected by browsing, drag and drop, or typing.
- Shares can be accessed using mapped drive letters or UNCs.
- MSIX2SQL expects MSIXDEF files to be in the same folder as the
  metering configuration file unless a path is specified under the
  <servicedefinitionfile> tag.



Limitations:
- MSIXDEF files should be referenced using the include statement
  (<servicedefinitionfile>) in the metering configuration file. That is,
  any inline PTYPE tags are ignored under <ServiceProperties>.
- The DROP statement in the <parentservice>.sql will cause an error when
  you execute the code if the corresponding child service tables have not
  been dropped.
- When using an MSIXDEF directly as input (without a configuration file),
  the resulting SQL will not contain control columns and primary/foreign
  key data unless these properties are present in the MSIXDEF properties.
- All column data types and lengths should be checked for accuracy and
  suitability in the generated SQL code.
- Modifications to generated code will usually be required when not using
  a metering configuration file.



Additional Usage Notes:
-Column properties are determined by their MSIXDEF properties. These take
 precedence over the same <ptypes> if found in the configuration file.
 For example, if the <required> property is Y, the SQL will be generated
 with NOT NULL even if the configuration file says N.
-Properties found only in the configuration file's <ServicePrimaryKey> 
 section are added to the generated SQL after the columns for the MSIXDEF file properties and before the configuration file's control column properties.



Usage:
1. Run MSIX2SQL.exe from any location.
2. Click the upper Browse button to select a metering
   configuration file.
   The resulting message shows the found parent and child services.
3. Choose Yes to generate all service table files (recommended) or No to
   select the service definition files individually.
   If you choose Yes, the SQL files will be generated right away.
4. If you choose No, from the MSIXDEF drop-down you can select the
   service for which to generate SQL.

   Notes:
   - The Generate SQL Table(s) button will generate the selected service
     or all services depending on your selection in the Generate All
     Files checkbox.
   - Files are automatically opened for immediate viewing if the Open
     Files checkbox is selected.
   - Browse locations are remembered from previous use.



Sample Files (if provided):
The sample folder contains an atomic service example and a multipoint
service example. (The multipoint example consists of the metering
configuration sample file that is included with MetraConnect and the
corresponding service definition files that ship with MetraNet's
AudioConf extension.) You can use these samples to verify MSIX2SQL's
designed functionality before using on your own configuration and service
definition files.



Last Updated: September 8, 2005.





