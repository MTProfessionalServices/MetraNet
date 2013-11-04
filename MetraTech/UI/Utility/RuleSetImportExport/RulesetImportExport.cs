using System;
using MetraTech;
using MetraTech.Interop.MTRuleSet;
using MetraTech.Interop.RCD;
using System.IO;
using System.Collections;
using System.Text;
using System.Xml;
using ProdCat = MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Diagnostics;
using Enum = MetraTech.Interop.MTEnumConfig;


[assembly: Guid("F5DF70E6-B272-4b14-B985-BB789DA6788A")]

namespace MetraTech.UI.Utility
{
    [Guid("1081DD16-677C-4582-9EA2-BE95BEE519A7")]
    public interface IRuleSetImportExport
    {
        ArrayList ExportToExcel(string sParamTableName, IMTRuleSet srcRuleset, ref string outBuffer);
        ArrayList ExportToExcelFile(string sParamTableName, IMTRuleSet srcRuleset, string sExcelXmlFilePath);

        ArrayList ImportFromExcel(string sExcelXml, ref IMTRuleSet outRuleset);
        ArrayList ImportFromExcelFile(string sExcelXmlFilePath, ref IMTRuleSet outRuleset);
    }

    [ClassInterface(ClassInterfaceType.None)]
    [Guid("303A11B5-C98A-4103-AA2A-02049060A255")]
    public class RuleSetImportExport : IRuleSetImportExport
    {
        private const string OfficeSpreadsheetNamespace = "urn:schemas-microsoft-com:office:spreadsheet";

        protected string mParamTableName = "";
        protected string mParamTableDisplayName = "";
        protected ProdCat.IMTParamTableDefinition mParamTableDefinition;

        protected string mRulesetImportExportConfigDir;

        protected Logger mLogger = new Logger("[RuleSetImportExport]");

        //For export
        protected string mDataValidationRuleBuffer = "";
        protected Hashtable mEnumListForExport = new Hashtable();

        //For import
        protected XmlNamespaceManager mXmlNamespaceManager;


        public RuleSetImportExport()
        {
        }

        public string GetConfigDir()
        {
            if (mRulesetImportExportConfigDir == null)
            {
                IMTRcd rcd = (IMTRcd)new MTRcd();
                string sConfigDir = rcd.ConfigDir;
                mRulesetImportExportConfigDir = sConfigDir + @"\RateImportExport\";
            }

            return mRulesetImportExportConfigDir;
        }

        public ArrayList ImportFromExcelFile(string sExcelXmlFilePath, ref IMTRuleSet outRuleset)
        {
            string sExcelXml;

            try
            {
                System.IO.StreamReader sr = new System.IO.StreamReader(sExcelXmlFilePath);
                sExcelXml = sr.ReadToEnd();
                sr.Close();
            }
            catch (Exception e)
            {
                ArrayList outUserErrorList = new ArrayList();
                // SECENG: Fixing information disclosure thru exceptions.
                //string sMessage = String.Format("Error Reading XML File:{0}",e.Message);
                string sMessage = "Error Reading XML File";
                mLogger.LogWarning("{0}:{1}", sMessage, e.Message);
                outUserErrorList.Add(sMessage);
                return outUserErrorList;
            }

            return ImportFromExcel(sExcelXml, ref outRuleset);
        }

        public ArrayList ImportFromExcel(string sExcelXml, ref IMTRuleSet outRuleset)
        {
            ArrayList outUserErrorList = new ArrayList();
            try
            {
                // SECENG: Fixing performance problem.
                // System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                System.Xml.XPath.XPathDocument xmldoc;
                System.Xml.XPath.XPathNavigator navigator;
                try
                {
                    //xmldoc.LoadXml(sExcelXml);
                    using (StringReader reader = new StringReader(sExcelXml))
                    {
                        XmlReaderSettings settings = new XmlReaderSettings();
                        settings.ProhibitDtd = true;
                        settings.IgnoreProcessingInstructions = true;
                        settings.ValidationFlags =
                            System.Xml.Schema.XmlSchemaValidationFlags.AllowXmlAttributes |
                            System.Xml.Schema.XmlSchemaValidationFlags.ReportValidationWarnings |
                            System.Xml.Schema.XmlSchemaValidationFlags.ProcessIdentityConstraints;

                        mXmlNamespaceManager = new XmlNamespaceManager(new NameTable());
                        mXmlNamespaceManager.AddNamespace("ns", OfficeSpreadsheetNamespace);
                        mXmlNamespaceManager.AddNamespace("o", "urn:schemas-microsoft-com:office:office");
                        mXmlNamespaceManager.AddNamespace("x", "urn:schemas-microsoft-com:office:excel");
                        mXmlNamespaceManager.AddNamespace("ss", OfficeSpreadsheetNamespace);
                        mXmlNamespaceManager.AddNamespace("html", "http://www.w3.org/TR/REC-html40");

                        settings.NameTable = mXmlNamespaceManager.NameTable;
                        
                        using (XmlReader xml = XmlReader.Create(reader, settings))
                        {
                            xmldoc = new System.Xml.XPath.XPathDocument(xml);
                            navigator = xmldoc.CreateNavigator();
                        }
                    }
                }
                catch (Exception e)
                {
                    // SECENG: Fixing information disclosure thru exceptions.
                    //string sTemp = string.Format("Error Reading File as XML. Are you sure the file is an Excel XML file? Error: {0}", e.Message);
                    string sTemp = "Error Reading File as XML. Are you sure the file is an Excel XML file?";
                    mLogger.LogWarning("{0} Error: {1}", sTemp, e.Message);
                    outUserErrorList.Add(sTemp);
                    return outUserErrorList;
                }

                // SECENG: Fixing performance problem.
                //mXmlNamespaceManager = new XmlNamespaceManager(xmldoc.NameTable);

                //map namespaces to prefixes for querying purposes 
                //mXmlNamespaceManager.AddNamespace("ns", "urn:schemas-microsoft-com:office:spreadsheet");

                //System.Xml.XmlElement Workbook = xmldoc.DocumentElement;
                //System.Xml.XmlNodeList Worksheets = Workbook.SelectNodes("ns:Worksheet",mXmlNamespaceManager);

                // Retrieve Workbook/Worksheet nodes.
                //mXmlNamespaceManager = new XmlNamespaceManager(navigator.NameTable);
                //mXmlNamespaceManager.AddNamespace("ns", OfficeSpreadsheetNamespace);

                System.Xml.XPath.XPathNodeIterator Worksheets = SelectNodes(navigator, "/ns:Workbook/ns:Worksheet");

                if (Worksheets.Count == 0)
                {
                    outUserErrorList.Add("Unable to locate Worksheet tags within the Workbook. Document not formatted properly");
                    return outUserErrorList;
                }

                int iRulesetFoundCount = 0;
                //Use an XmlNode object to iterate through the XmlNodeList that SelectNodes returns.
                // SECENG: Fixing performance problem.
                //foreach (System.Xml.XmlNode Worksheet in Worksheets)
                foreach (System.Xml.XPath.XPathNavigator Worksheet in Worksheets)
                {
                    // SECENG: Fixing performance problem.
                    //Worksheet.Attributes.GetNamedItem(
                    //string sWorksheetName = Worksheet.Attributes.GetNamedItem("ss:Name").Value;
                    string sWorksheetName = Worksheet.GetAttribute("Name", Worksheet.LookupNamespace("ss"));

                    mLogger.LogDebug("Processing worksheet {0}...", sWorksheetName);

                    //ToDo: Different way to check if this worksheet is a ruleset worksheet
                    if (sWorksheetName.CompareTo("ParamTable") == 0)
                    {
                        iRulesetFoundCount++;
                        ProcessWorksheet(Worksheet, ref outUserErrorList, ref outRuleset);
                    }
                    /*Console.WriteLine("Display all the attributes for this book...");
                    IEnumerator ienum = Worksheet.Attributes.GetEnumerator();
                    while (ienum.MoveNext())
                    {
                      XmlAttribute attr = (XmlAttribute)ienum.Current;
                      Console.WriteLine("{0} = {1}", attr.Name, attr.Value);
                    }   */

                    //System.Diagnostics.Debug.WriteLine(Worksheet.InnerText);
                }

            }
            // SECENG: Fixing information disclosure thru exceptions.
            catch (ImportExportException e)
            {
                string sTemp = string.Format("Error Processing Excel File: {0}", e.Message);
                mLogger.LogDebug(sTemp);
                outUserErrorList.Add(sTemp);
            }
            catch (Exception e)
            {
                string sTemp = string.Format("Error Processing Excel File: {0}", e.Message);
                // SECENG: Fixing information disclosure thru exceptions.
                //outUserErrorList.Add(sTemp);
                mLogger.LogWarning(sTemp);
                outUserErrorList.Add("Error Processing Excel File");
            }

            return outUserErrorList;
        }

        // SECENG: Fixing performance problem.
        public void ProcessWorksheet(System.Xml.XPath.XPathNavigator Worksheet, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset)
        {
            //Locate rules and what paramtable this is
            mParamTableName = "";
            mParamTableDefinition = null;

            Regex regex = new Regex(@"Parameter Table\[(.+)\]");
            Match match;

            int iRuleFoundCount = 0;
            bool bRulesFound = false;
            System.Xml.XPath.XPathNodeIterator Rows = SelectNodes(Worksheet, "ns:Table//ns:Row");

            mLogger.LogDebug("Found {0} row(s) to process.", Rows.Count);

            foreach (System.Xml.XPath.XPathNavigator Row in Rows)
            {
                //Need to locate the start of the rules
                //Advance through the rows until we get to the one where the first cell is 'Rule'
                if (!bRulesFound)
                {
                    //Check first cell to see if it says 'Rule'
                    System.Xml.XPath.XPathNavigator firstCellData = Row.SelectSingleNode(BuildExpression(Row, "ns:Cell//ns:Data"));
                    string sData = firstCellData.Value;

                    mLogger.LogDebug("Row type is {0}.", sData);

                    //Is this our param table name?
                    match = regex.Match(sData);
                    if (match.Groups.Count == 2)
                    {
                        mParamTableName = match.Groups[1].Value;
                        //Retrieve the paramtable defintion
                        ProdCat.IMTProductCatalog pc = null;
                        pc = new ProdCat.MTProductCatalogClass();
                        mParamTableDefinition = pc.GetParamTableDefinitionByName(mParamTableName);
                    }


                    //Is this the marker for the start of the rules?
                    if (sData.CompareTo("Rule") == 0)
                    {
                        bRulesFound = true;
                        //TODO: Sanity check on columns or type of paramtable to make sure we match?
                    }
                }
                else
                {
                    //Process this row which should be a rule
                    iRuleFoundCount++;
                    ProcessRule(Row, iRuleFoundCount.ToString(), ref outUserErrorList, ref outRuleset);
                }
            }
        }

        // SECENG: Fixing performance problem.
        [Obsolete("Use public void ProcessWorksheet(System.Xml.XPath.XPathNavigator Worksheet, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset) instead.")]
        public void ProcessWorksheet(System.Xml.XmlNode Worksheet, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset)
        {
            //Locate rules and what paramtable this is
            mParamTableName = "";
            mParamTableDefinition = null;

            Regex regex = new Regex(@"Parameter Table\[(.+)\]");
            Match match;

            int iRuleFoundCount = 0;
            bool bRulesFound = false;
            System.Xml.XmlNodeList Rows = Worksheet.SelectNodes("ns:Table//ns:Row", mXmlNamespaceManager);
            foreach (System.Xml.XmlNode Row in Rows)
            {
                //Need to locate the start of the rules
                //Advance through the rows until we get to the one where the first cell is 'Rule'
                if (!bRulesFound)
                {
                    //Check first cell to see if it says 'Rule'
                    System.Xml.XmlNode firstCellData = Row.SelectSingleNode("ns:Cell//ns:Data", mXmlNamespaceManager);
                    string sData = firstCellData.InnerText;

                    //Is this our param table name?
                    match = regex.Match(sData);
                    if (match.Groups.Count == 2)
                    {
                        mParamTableName = match.Groups[1].Value;
                        //Retrieve the paramtable defintion
                        ProdCat.IMTProductCatalog pc = null;
                        pc = new ProdCat.MTProductCatalogClass();
                        mParamTableDefinition = pc.GetParamTableDefinitionByName(mParamTableName);
                    }


                    //Is this the marker for the start of the rules?
                    if (sData.CompareTo("Rule") == 0)
                    {
                        bRulesFound = true;
                        //TODO: Sanity check on columns or type of paramtable to make sure we match?
                    }
                }
                else
                {
                    //Process this row which should be a rule
                    iRuleFoundCount++;
                    //Console.WriteLine("RULE[{0}]:{1}", iRuleFoundCount, Row.InnerText);
                    ProcessRule(Row, iRuleFoundCount.ToString(), ref outUserErrorList, ref outRuleset);
                }
                //Worksheet.Attributes.GetNamedItem(
                //string sWorksheetName = Worksheet.Attributes.GetNamedItem("ss:Name").Value;

                //To Do: Different way to check if this worksheet is a ruleset worksheet
                //if (sWorksheetName.CompareTo("ParamTable")==0)
                //{
                //  iRuleFoundCount++;
                //  ProcessWorksheet(Worksheet,ref outUserErrorList);
                // }
                /*Console.WriteLine("Display all the attributes for this book...");
                  IEnumerator ienum = Worksheet.Attributes.GetEnumerator();
                  while (ienum.MoveNext())
                  {
                    XmlAttribute attr = (XmlAttribute)ienum.Current;
                    Console.WriteLine("{0} = {1}", attr.Name, attr.Value);
                  }   */

                //System.Diagnostics.Debug.WriteLine(Worksheet.InnerText);
            }
        }

        // SECENG: Fixing performance problem.
        protected void CheckCellAttributeAndAdvanceCellIndex(System.Xml.XPath.XPathNavigator Cell, ref int iCurrentValue, ref string[] values)
        {
            /* If there are missing cells in a row without data, then the cell is left out of the Excel XML and the next cell with data
               data as an attribute indicating the new index. For the case of missing values that are not required we need to check
               for this attribute and advance our value counter appropriately (updating the skipped values to blank) */
            string attribIndex = Cell.GetAttribute("Index", OfficeSpreadsheetNamespace);
            if (!string.IsNullOrEmpty(attribIndex))
            {
                int iIndex = int.Parse(attribIndex);
                int iJump = (iIndex - 1) - iCurrentValue; //Excel index is 1 based, our array is 0 based
                for (int i = 0; i < iJump; i++)
                    values[iCurrentValue + i] = "";

                iCurrentValue += iJump;
            }
        }

        // SECENG: Fixing performance problem.
        [Obsolete("Use protected void CheckCellAttributeAndAdvanceCellIndex(System.Xml.XPath.XPathNavigator Cell, ref int iCurrentValue, ref string[] values) instead.")]
        protected void CheckCellAttributeAndAdvanceCellIndex(System.Xml.XmlNode Cell, ref int iCurrentValue, ref string[] values)
        {
            /* If there are missing cells in a row without data, then the cell is left out of the Excel XML and the next cell with data
               data as an attribute indicating the new index. For the case of missing values that are not required we need to check
               for this attribute and advance our value counter appropriately (updating the skipped values to blank) */
            System.Xml.XmlNode attribIndex = Cell.Attributes.GetNamedItem("ss:Index");
            if (attribIndex != null)
            {
                int iIndex = int.Parse(attribIndex.InnerText);
                int iJump = (iIndex - 1) - iCurrentValue; //Excel index is 1 based, our array is 0 based
                for (int i = 0; i < iJump; i++)
                    values[iCurrentValue + i] = "";

                iCurrentValue += iJump;
            }

            return;
        }

        // SECENG: Fixing performance problem.
        public void ProcessRule(System.Xml.XPath.XPathNavigator Row, string ruleIdentifier, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset)
        {
            if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ProcessRule: {0}", ruleIdentifier));

            //Read all the values into an array
            string[] values = new String[255]; //TODO: Create appropriate size array or use a list
            int iValueCount = 0;

            bool bRowIsBlank = true;
            try
            {
                System.Xml.XPath.XPathNodeIterator Cells = SelectNodes(Row, "ns:Cell");
                foreach (System.Xml.XPath.XPathNavigator Cell in Cells)
                {
                    CheckCellAttributeAndAdvanceCellIndex(Cell, ref iValueCount, ref values);
                    System.Xml.XPath.XPathNavigator CellText = Cell.SelectSingleNode(BuildExpression(Cell, "ns:Data"));
                    if (CellText == null)
                    {
                        values[iValueCount] = "";
                    }
                    else
                    {
                        values[iValueCount] = CellText.Value.Trim();
                        if (values[iValueCount].Length > 0)
                        {
                            bRowIsBlank = false; //There is now at least one none null or blank entry on this row
                        }
                    }
                    iValueCount++;
                }
            }
            // SECENG: Fixing information disclosure thru exceptions.
            catch (ImportExportException e)
            {
                string sTemp = string.Format("Error Reading Values From Rule[{0}]: {1}", ruleIdentifier, e.Message);
                mLogger.LogDebug(sTemp);
                outUserErrorList.Add(sTemp);
            }
            catch (Exception e)
            {
                // SECENG: Fixing information disclosure thru exceptions.
                //string sTemp = string.Format("Error Reading Values From Rule[{0}]: {1}", ruleIdentifier, e.Message);
                //if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ProcessRule: {0}", sTemp));
                string sTemp = string.Format("Error Reading Values From Rule[{0}]", ruleIdentifier);
                mLogger.LogWarning("ProcessRule: {0}: {1}", sTemp, e.Message);
                outUserErrorList.Add(sTemp);
            }

            if (bRowIsBlank)
            {
                //Row is blank so skip this row
                return;
            }

            //TODO: Do error checking on number of values read against what we expect

            //Check for default rule
            if (values[0].CompareTo("Default") == 0)
            {
                //Process default rule
                try
                {
                    AddDefaultActionsFromListOfValues(values, ref outRuleset);
                }
                // SECENG: Fixing information disclosure thru exceptions.
                catch (ImportExportException e)
                {
                    string sTemp = string.Format("Error Processing Rule[{0}] as Default Rule: {1}", ruleIdentifier, e.Message);
                    mLogger.LogDebug(sTemp);
                    outUserErrorList.Add(sTemp);
                }
                catch (Exception e)
                {
                    // SECENG: Information disclosure thru exceptions fix
                    //string sTemp = string.Format("Error Processing Rule[{0}] as Default Rule: {1}", ruleIdentifier, e.Message);
                    string sTemp = string.Format("Error Processing Rule[{0}] as Default Rule", ruleIdentifier);
                    mLogger.LogWarning("ProcessRule: {0}: {1}, {2}", sTemp, e.Message, e.StackTrace);
                    outUserErrorList.Add(sTemp);
                }
            }
            else
            {
                try
                {
                    MTRule rule = CreateRuleFromListOfValues(values);
                    outRuleset.Add(rule);
                }
                // SECENG: Fixing information disclosure thru exceptions.
                catch (ImportExportException e)
                {
                    string sTemp = string.Format("Error Processing Rule[{0}]: {1}", ruleIdentifier, e.Message);
                    mLogger.LogDebug(sTemp);
                    outUserErrorList.Add(sTemp);
                }
                catch (Exception e)
                {
                    // SECENG: Information disclosure thru exceptions fix
                    //string sTemp = string.Format("Error Processing Rule[{0}]: {1}", ruleIdentifier, e.Message);
                    string sTemp = string.Format("Error Processing Rule[{0}]", ruleIdentifier);
                    mLogger.LogWarning("ProcessRule: {0}: {1}, {2}", sTemp, e.Message, e.StackTrace);
                    outUserErrorList.Add(sTemp);
                }
            }
        }

        // SECENG: Fixing performance problem.
        [Obsolete("Use public void ProcessRule(System.Xml.XPath.XPathNavigator Row, string ruleIdentifier, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset) instead.")]
        public void ProcessRule(System.Xml.XmlNode Row, string ruleIdentifier, ref ArrayList outUserErrorList, ref IMTRuleSet outRuleset)
        {
            //Console.WriteLine("RULE[{0}]:{1}", ruleIdentifier, Row.InnerText);
            if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ProcessRule: {0} {1}", ruleIdentifier, Row.InnerText));

            //Read all the values into an array
            string[] values = new String[255]; //TODO: Create appropriate size array or use a list
            int iValueCount = 0;

            bool bRowIsBlank = true;
            try
            {
                System.Xml.XmlNodeList Cells = Row.SelectNodes("ns:Cell", mXmlNamespaceManager);
                foreach (System.Xml.XmlNode Cell in Cells)
                {
                    CheckCellAttributeAndAdvanceCellIndex(Cell, ref iValueCount, ref values);
                    System.Xml.XmlNode CellText = Cell.SelectSingleNode("ns:Data", mXmlNamespaceManager);
                    if (CellText == null)
                    {
                        values[iValueCount] = "";
                    }
                    else
                    {
                        values[iValueCount] = CellText.InnerText.Trim();
                        if (values[iValueCount].Length > 0)
                        {
                            bRowIsBlank = false; //There is now at least one none null or blank entry on this row
                        }
                    }
                    iValueCount++;
                }
            }
            // SECENG: Fixing information disclosure thru exceptions.
            catch (ImportExportException e)
            {
                string sTemp = string.Format("Error Reading Values From Rule[{0}]: {1}", ruleIdentifier, e.Message);
                mLogger.LogDebug(sTemp);
                outUserErrorList.Add(sTemp);
            }
            catch (Exception e)
            {
                // SECENG: Fixing information disclosure thru exceptions.
                //string sTemp = string.Format("Error Reading Values From Rule[{0}]: {1}", ruleIdentifier, e.Message);
                //if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ProcessRule: {0}",sTemp));
                string sTemp = string.Format("Error Reading Values From Rule[{0}]", ruleIdentifier);
                mLogger.LogWarning(String.Format("ProcessRule: {0}: {1}", sTemp, e.Message));
                outUserErrorList.Add(sTemp);
            }

            if (bRowIsBlank)
            {
                //Row is blank so skip this row
                return;
            }

            //TODO: Do error checking on number of values read against what we expect

            //Check for default rule
            if (values[0].CompareTo("Default") == 0)
            {
                //Process default rule
                try
                {
                    AddDefaultActionsFromListOfValues(values, ref outRuleset);
                }
                // SECENG: Fixing information disclosure thru exceptions.
                catch (ImportExportException e)
                {
                    string sTemp = string.Format("Error Processing Rule[{0}] as Default Rule: {1}", ruleIdentifier, e.Message);
                    outUserErrorList.Add(sTemp);
                }
                catch (Exception e)
                {
                    // SECENG: Fixing information disclosure thru exceptions.
                    //string sTemp = string.Format("Error Processing Rule[{0}] as Default Rule: {1}", ruleIdentifier, e.Message);
                    string sTemp = string.Format("Error Processing Rule[{0}]", ruleIdentifier);
                    mLogger.LogWarning(String.Format("ProcessRule: {0} as Default Rule: {1}", sTemp, e.Message));
                    outUserErrorList.Add(sTemp);
                }
            }
            else
            {
                try
                {
                    MTRule rule = CreateRuleFromListOfValues(values);
                    outRuleset.Add(rule);
                }
                // SECENG: Fixing information disclosure thru exceptions.
                catch (ImportExportException e)
                {
                    string sTemp = string.Format("Error Processing Rule[{0}]: {1}", ruleIdentifier, e.Message);
                    outUserErrorList.Add(sTemp);
                }
                catch (Exception e)
                {
                    // SECENG: Fixing information disclosure thru exceptions.
                    //string sTemp = string.Format("Error Processing Rule[{0}]: {1}",ruleIdentifier,e.Message);
                    string sTemp = string.Format("Error Processing Rule[{0}]", ruleIdentifier);
                    mLogger.LogWarning(String.Format("ProcessRule: {0}: {1}", sTemp, e.Message));
                    outUserErrorList.Add(sTemp);
                }
            }
        }

        public ArrayList ExportToExcelFile(string sParamTableName, IMTRuleSet srcRuleset, string sExcelXmlFilePath)
        {
            string sOutputBuffer = "";

            ArrayList outUserErrorList;

            outUserErrorList = ExportToExcel(sParamTableName, srcRuleset, ref sOutputBuffer);

            if (outUserErrorList.Count > 0)
                return outUserErrorList;

            try
            {
                //Save Excel File
                StreamWriter SW;
                SW = File.CreateText(sExcelXmlFilePath);
                SW.Write(sOutputBuffer);
                SW.Close();
            }
            catch (Exception e)
            {
                // SECENG: Fixing information disclosure thru exceptions.
                //string sMessage = String.Format("Error Saving File:{0}", e.Message);
                string sMessage = "Error Saving File";
                mLogger.LogWarning(String.Format("{0}:{1}", sMessage, e.Message));
                outUserErrorList.Add(sMessage);
            }

            return outUserErrorList;
        }

        public ArrayList ExportToExcel(string sParamTableName, IMTRuleSet srcRuleset, ref string outBuffer)
        {
            if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ExportToExcel of Parameter Table[{0}] and Ruleset containing {1} rules", sParamTableName, srcRuleset.Count));
            ArrayList outUserErrorList = new ArrayList();

            try
            {
                string sTemplateFilePath = GetConfigDir() + @"Excel\BaseTemplate.xml";

                mParamTableName = sParamTableName;
                mParamTableDisplayName = sParamTableName;
                mDataValidationRuleBuffer = "";
                mEnumListForExport = new Hashtable();

                //Retrieve the paramtable defintion
                ProdCat.IMTProductCatalog pc = null;
                pc = new ProdCat.MTProductCatalogClass();
                ProdCat.IMTParamTableDefinition tabledef = pc.GetParamTableDefinitionByName(mParamTableName);
                if (tabledef == null)
                {
                    string sMsg = String.Format("Unable to get parameter table definition for {0} from the product catalog", mParamTableName);
                    mLogger.LogWarning(sMsg);
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception(sMsg);
                    throw new ImportExportException(sMsg);
                }

                mParamTableDisplayName = tabledef.DisplayName;

                //Load Excel Template File
                StreamReader SR;
                string sBaseTemplate;
                SR = File.OpenText(sTemplateFilePath);
                sBaseTemplate = SR.ReadToEnd();
                SR.Close();

                string sOutputBuffer = sBaseTemplate;

                //Inject the worksheet header
                sOutputBuffer = sOutputBuffer.Replace("<!--%%INSERT_WORKSHEET_HEADER%%-->", GenerateWorkSheetHeader(ref srcRuleset));

                //Inject the rows
                //string sRulesetBuffer = "\n";
                StringBuilder sRulesetBuffer = new StringBuilder("\n");
                sRulesetBuffer.Capacity = 2048;

                MTRule rule;

                //Write the column headers
                //TODO: Calculate and format column widths as we go through

                bool[] ConditionOperatorPerRuleInfo = new bool[tabledef.ConditionMetaData.Count];
                int iCurrentExcelColumn = 0;
                sRulesetBuffer.Append("<Row>");
                sRulesetBuffer.Append("<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + "Rule" + "</Data></Cell>");
                iCurrentExcelColumn++;
                sRulesetBuffer.Append("<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + " " + "</Data></Cell>");
                iCurrentExcelColumn++;


                //Write condition headers
                int iCurrentCondition = -1;
                foreach (ProdCat.IMTConditionMetaData conditiondef in tabledef.ConditionMetaData)
                {

                    iCurrentCondition++;
                    string sDisplayName = EscapeXMLSpecialCharacters(conditiondef.DisplayName);
                    ConditionOperatorPerRuleInfo[iCurrentCondition] = conditiondef.OperatorPerRule;
                    if (conditiondef.OperatorPerRule)
                    {

                        sRulesetBuffer.Append("<Cell ss:MergeAcross=\"1\" ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + sDisplayName + "</Data></Cell>");
                        //sRulesetBuffer += "<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + "" + "</Data></Cell>";
                        iCurrentExcelColumn++;
                        if ((conditiondef.DataType == ProdCat.PropValType.PROP_TYPE_STRING) || (conditiondef.DataType == ProdCat.PropValType.PROP_TYPE_ENUM) || (conditiondef.DataType == ProdCat.PropValType.PROP_TYPE_BOOLEAN))
                            AddDataValidationListRule("EnumOperatorBasic", iCurrentExcelColumn); //Strings, Enums and booleans have a limited number of operators
                        else
                            AddDataValidationListRule("EnumOperator", iCurrentExcelColumn);
                        iCurrentExcelColumn++;
                    }
                    else
                    {
                        sRulesetBuffer.Append("<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + sDisplayName + " (" + GetDisplayNameForOperatorType(conditiondef.Operator) + ")" + "</Data></Cell>");
                        iCurrentExcelColumn++;
                    }

                    if (conditiondef.DataType == ProdCat.PropValType.PROP_TYPE_ENUM)
                    {
                        //Add this as a needed enum type for validation
                        string sExcelEnumName = AddEnumToListNeededForExport(conditiondef.EnumSpace, conditiondef.EnumType);
                        AddDataValidationListRule(sExcelEnumName, iCurrentExcelColumn);
                    }

                    if (conditiondef.DataType == ProdCat.PropValType.PROP_TYPE_BOOLEAN)
                    {
                        AddDataValidationListRule("EnumBoolean", iCurrentExcelColumn);
                    }

                }

                int iNumberOfExcelConditionColumns = iCurrentExcelColumn - 3;

                sRulesetBuffer.Append("<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + " " + "</Data></Cell>");
                iCurrentExcelColumn++;

                //Write action headers
                foreach (ProdCat.IMTActionMetaData actiondef in tabledef.ActionMetaData)
                {
                    string sDisplayName = EscapeXMLSpecialCharacters(actiondef.DisplayName);
                    sRulesetBuffer.Append("<Cell ss:StyleID=\"sRulesetColumnHeader\"><Data ss:Type=\"String\">" + sDisplayName + "</Data></Cell>");
                    iCurrentExcelColumn++;
                    if (actiondef.DataType == ProdCat.PropValType.PROP_TYPE_ENUM)
                    {
                        //Add this as a needed enum type for validation
                        string sExcelEnumName = AddEnumToListNeededForExport(actiondef.EnumSpace, actiondef.EnumType);
                        AddDataValidationListRule(sExcelEnumName, iCurrentExcelColumn);
                    }

                    if (actiondef.DataType == ProdCat.PropValType.PROP_TYPE_BOOLEAN)
                    {
                        AddDataValidationListRule("EnumBoolean", iCurrentExcelColumn);
                    }

                }
                sRulesetBuffer.Append("</Row>\n");


                int iRuleCount = srcRuleset.Count;
                int iEstimatedBufferLength = 0;
                for (int i = 1; i <= iRuleCount; i++)
                {
                    //These lines added to estimate and set our initial string buffer capacity
                    //  First pass... just get the current buffer length
                    //  Second pass... determine how big the first rule was; set capacity based on this plus a fudge factor of "+10" rules
                    if (i == 1) { iEstimatedBufferLength = sRulesetBuffer.Length; }
                    if (i == 2) { sRulesetBuffer.Capacity = iEstimatedBufferLength + ((iRuleCount + 10) * (sRulesetBuffer.Length - iEstimatedBufferLength)); }

                    if (mLogger.WillLogDebug) mLogger.LogDebug(String.Format("ExportToExcel: Exporting rule [{0}]", i));
                    rule = (MTRule)srcRuleset[i];
                    sRulesetBuffer.Append("<Row>");
                    sRulesetBuffer.Append("<Cell><Data ss:Type=\"String\">" + "" + "</Data></Cell>");
                    sRulesetBuffer.Append("<Cell ss:StyleID=\"sIfThenColumn\"><Data ss:Type=\"String\">" + "if" + "</Data></Cell>");

                    //Write out the rule conditions
                    iCurrentCondition = -1;
                    MTSimpleCondition condition;
                    MTAssignmentAction action;

                    //Because some of the values may not be specified if they are optional, we cannot iterate over the contents of the rule.
                    //We have to iterate over the definition data and then look up the condition or action in the rulset.
                    foreach (ProdCat.IMTConditionMetaData conditiondef in tabledef.ConditionMetaData)
                    {
                        iCurrentCondition++;
                        //string sDisplayName = conditiondef.DisplayName;
                        //ConditionOperatorPerRuleInfo[iCurrentCondition] = conditiondef.OperatorPerRule;
                        condition = RetrieveNamedConditionFromConditionSet(conditiondef.PropertyName, rule.Conditions);
                        if (conditiondef.OperatorPerRule)
                        {
                            //This condition has a operator for each rule
                            sRulesetBuffer.Append("<Cell><Data ss:Type=\"String\">" + GetDisplayNameFromTestString(condition.Test) + "</Data></Cell>");
                        }
                        sRulesetBuffer.Append("<Cell><Data ss:Type=\"" + GetExcelTypeFromPropType(conditiondef.DataType, condition.Value) + "\">" + GetExcelDisplayValue(condition.Value, conditiondef.DataType) + "</Data></Cell>");
                    }

                    //Add the separator 'then' between conditions and actions
                    sRulesetBuffer.Append("<Cell ss:StyleID=\"sIfThenColumn\"><Data ss:Type=\"String\">" + "then" + "</Data></Cell>");

                    //Now, write out the actions
                    foreach (ProdCat.IMTActionMetaData actiondef in tabledef.ActionMetaData)
                    {
                        action = RetrieveNamedActionFromActionSet(actiondef.PropertyName, rule.Actions);
                        sRulesetBuffer.Append("<Cell><Data ss:Type=\"" + GetExcelTypeFromPropType((ProdCat.PropValType)action.PropertyType, action.PropertyValue) + "\">" + GetExcelDisplayValue(action.PropertyValue, (ProdCat.PropValType)action.PropertyType) + "</Data></Cell>");
                    }

                    sRulesetBuffer.Append("</Row>\n");
                }

                //Inject default rule information
                MTActionSet defaultActionSet = srcRuleset.DefaultActions;
                MTAssignmentAction actionDefault;
                if (defaultActionSet != null)
                {
                    if (mLogger.WillLogDebug) mLogger.LogDebug("ExportToExcel: Exporting default rule");
                    //Write default rule
                    sRulesetBuffer.Append("<Row>");
                    sRulesetBuffer.Append("<Cell><Data ss:Type=\"String\">" + "Default" + "</Data></Cell>");
                    sRulesetBuffer.Append("<Cell ss:StyleID=\"sIfThenColumn\"><Data ss:Type=\"String\">" + "if" + "</Data></Cell>");

                    sRulesetBuffer.Append("<Cell ss:MergeAcross=\"" + iNumberOfExcelConditionColumns + "\" ss:StyleID=\"sDefaultRule\"><Data ss:Type=\"String\">" + "Default Rule" + "</Data></Cell>");

                    sRulesetBuffer.Append("<Cell ss:StyleID=\"sIfThenColumn\"><Data ss:Type=\"String\">" + "then" + "</Data></Cell>");

                    foreach (ProdCat.IMTActionMetaData actiondef in tabledef.ActionMetaData)
                    {
                        actionDefault = RetrieveNamedActionFromActionSet(actiondef.PropertyName, defaultActionSet);
                        sRulesetBuffer.Append("<Cell><Data ss:Type=\"" + GetExcelTypeFromPropType((ProdCat.PropValType)actionDefault.PropertyType, actionDefault.PropertyValue) + "\">" + GetExcelDisplayValue(actionDefault.PropertyValue, (ProdCat.PropValType)actionDefault.PropertyType) + "</Data></Cell>");
                    }
                    sRulesetBuffer.Append("</Row>\n");
                }

                sOutputBuffer = sOutputBuffer.Replace("<!--%%INSERT_RULESET%%-->", sRulesetBuffer.ToString());
                InjectWorksheetDataValidationInformation(ref sOutputBuffer);

                InjectWorkbookEnumInformation(ref sOutputBuffer);

                outBuffer = sOutputBuffer;
            }
            // SECENG: Fixing information disclosure thru exceptions.
            catch (ImportExportException e)
            {
                string sMsg = String.Format("Error Exporting Ruleset: {0}", e.Message);
                outUserErrorList.Add(sMsg);
            }
            catch (Exception e)
            {
                // SECENG: Fixing information disclosure thru exceptions.
                //string sMsg = String.Format("Error Exporting Ruleset: {0}",e.Message);
                string sMsg = "Error Exporting Ruleset";
                mLogger.LogWarning("{0}: {0}", sMsg, e.Message);
                outUserErrorList.Add("Error happend. Please try to repeat your activity. Contact the administrator if the error happens again.");
            }

            return outUserErrorList;
        }

        protected string GetExcelTypeFromPropType(ProdCat.PropValType propType, object Value)
        {
            if ((propType == ProdCat.PropValType.PROP_TYPE_DECIMAL) || (propType == ProdCat.PropValType.PROP_TYPE_INTEGER))
            {
                if ((Value == null) || (Value.ToString().Length == 0))
                    return "String"; //Blank values for decimals need to be formatted as strings. Excel converts 'Number' blank values to 0.0
                else
                    return "Number"; //"Number"
            }
            else
                return "String";
        }

        protected string GetExcelDisplayValue(object Value, ProdCat.PropValType propType)
        {
            //If this ruleset value is a boolean, we need to convert the particular type of the Value object
            //to the display strings used for booleans (enum values)
            //In the future, we would also need to special case for enums if we wanted to use the enum display name
            //instead of the enum value
            if (propType == ProdCat.PropValType.PROP_TYPE_BOOLEAN)
            {
                if (Value.ToString().Equals(""))
                {
                    return Value.ToString();
                }
                else
                {
                    if (Value.GetType().Equals(System.Type.GetType("System.Boolean")))
                    {
                        if ((bool)Value)
                            return "True";
                        else
                            return "False";
                    }
                    else
                    {
                        if ((Value.ToString().Equals("-1")) || (Value.ToString().Equals("1")))
                            return "True";
                        else
                            return "False";
                    }
                }
            }
            else
            {
                //Otherwise, just return the value converted to a string
                if (Value == null)
                    return "";
                else
                    return EscapeXMLSpecialCharacters(Value.ToString());
            }
        }

        protected string EscapeXMLSpecialCharacters(string sInput)
        {
            sInput = sInput.Replace("&", "&amp;");
            sInput = sInput.Replace("\"", "&quot;");
            sInput = sInput.Replace("<", "&lt;");
            sInput = sInput.Replace(">", "&gt;");
            sInput = sInput.Replace("'", "&apos;");

            return sInput;
        }

        protected string GenerateWorkSheetHeader(ref IMTRuleSet srcRuleset)
        {
            StreamReader SR;
            string sHeaderTemplate;
            SR = File.OpenText(GetConfigDir() + @"Excel\WorksheetHeaderTemplate.xml");
            sHeaderTemplate = SR.ReadToEnd();
            SR.Close();

            sHeaderTemplate = sHeaderTemplate.Replace("<!--%%INSERT_RULESET_NAME%%-->", mParamTableName);
            sHeaderTemplate = sHeaderTemplate.Replace("<!--%%INSERT_RULESET_DISPLAY_NAME%%-->", EscapeXMLSpecialCharacters(mParamTableDisplayName));

            return sHeaderTemplate;

        }

        protected void InjectWorkbookEnumInformation(ref string sWorkbookTemplate)
        {
            //Inject named ranges information
            string sNamedRanges = "";

            //Inject enum worksheet
            Enum.IEnumConfig mtEnumConfig = new Enum.EnumConfigClass();
            //mtEnumConfig.Initialize();
            string sBuffer = "";
            int iEnumIndex = 10;
            foreach (string key in mEnumListForExport.Keys)
            {
                EnumInfo enumInfo = (EnumInfo)mEnumListForExport[key];
                string sName = EscapeXMLSpecialCharacters(key);
                sBuffer += "<Row ss:Index=\"" + iEnumIndex + "\"><Cell><Data ss:Type=\"String\">" + sName + "</Data></Cell>";

                int iEnumValueCount = 0;
                foreach (Enum.IMTEnumerator mtEnum in mtEnumConfig.GetEnumerators(enumInfo.Space, enumInfo.Type))
                {
                    sBuffer += "<Cell><Data ss:Type=\"String\">" + EscapeXMLSpecialCharacters(mtEnum.name) + "</Data><NamedCell ss:Name=\"" + EscapeXMLSpecialCharacters(sName) + "\"/></Cell>";
                    iEnumValueCount++;
                }
                sBuffer += "</Row>\n";

                //Add a named range for this enum
                sNamedRanges += "<NamedRange ss:Name=\"" + sName + "\" ss:RefersTo=\"=EnumData!R" + iEnumIndex + "C2:R" + iEnumIndex + "C" + (iEnumValueCount + 2) + "\"/>";
                //Temporary Fix for #12702: The +2 above adds blank as a possible value to all enums
                iEnumIndex++;
            }

            sWorkbookTemplate = sWorkbookTemplate.Replace("<!--%%INSERT_WORKBOOK_NAMES%%-->", sNamedRanges);
            sWorkbookTemplate = sWorkbookTemplate.Replace("<!--%%INSERT_WORKBOOK_ENUMS%%-->", sBuffer);
        }

        protected string AddEnumToListNeededForExport(string sEnumSpace, string sEnumType)
        {
            string sExcelEnumName = sEnumSpace.Replace("/", "_");
            sExcelEnumName = "Enum_" + sExcelEnumName + "_" + sEnumType;
            //mEnumListForExport.Add(sExcelEnumName,new EnumInfo(sEnumSpace,sEnumType));
            mEnumListForExport[sExcelEnumName] = new EnumInfo(sEnumSpace, sEnumType);

            return sExcelEnumName;
        }

        protected void AddDataValidationListRule(string sName, int iColumn)
        {
            string sDataValidation = "<DataValidation xmlns=\"urn:schemas-microsoft-com:office:excel\"><Range>R7C" + iColumn + ":R100C" + iColumn + "</Range><Type>List</Type><UseBlank/><Value>" + sName + "</Value></DataValidation>";
            mDataValidationRuleBuffer += sDataValidation;
        }

        protected void InjectWorksheetDataValidationInformation(ref string sWorksheetTemplate)
        {
            //Inject the data validation rules from the buffer that has been built up
            sWorksheetTemplate = sWorksheetTemplate.Replace("<!--%%INSERT_WORKSHEET_DATAVALIDATION%%-->", mDataValidationRuleBuffer);
        }

        protected string GetDisplayNameForOperatorType(ProdCat.MTOperatorType operatorType)
        {
            switch (operatorType)
            {
                case ProdCat.MTOperatorType.OPERATOR_TYPE_EQUAL:
                    return "=";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_NOT_EQUAL:
                    return "!=";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_LESS:
                    return "&lt;";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_LESS_EQUAL:
                    return "&lt;=";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_GREATER:
                    return "&gt;";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL:
                    return "&gt;=";
                case ProdCat.MTOperatorType.OPERATOR_TYPE_NONE:
                    return "";
                default:
                    Debug.Assert(false, "Unknown Operator Encountered [" + operatorType + "]");
                    return "UNKNOWN OPERATOR[" + operatorType + "]";

            }
        }

        protected string GetTestStringFromDisplayName(string sOperatorDisplayName)
        {
            switch (sOperatorDisplayName.Trim())
            {
                case "=":
                    return "equals";
                case "!=":
                    return "not_equals";
                case "&lt;":
                case "<":
                    return "less_than";
                case "&lt;=":
                case "<=":
                    return "less_equal";
                case "&gt;":
                case ">":
                    return "greater_than";
                case "&gt;=":
                case ">=":
                    return "greater_equal";
                case "":
                    return "";
                default:
                    Debug.Assert(false, "Unknown Operator Encountered [" + sOperatorDisplayName + "]");
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception("Unknown Operator Encountered [" + sOperatorDisplayName + "]");
                    throw new ImportExportException("Unknown Operator Encountered [" + sOperatorDisplayName + "]");
            }
        }

        protected string GetDisplayNameFromTestString(string sTest)
        {
            switch (sTest)
            {
                case "equals":
                    return "=";
                case "not_equals":
                    return "!=";
                case "less_than":
                    return "&lt;";
                case "less_equal":
                    return "&lt;=";
                case "greater_than":
                    return "&gt;";
                case "greater_equal":
                    return "&gt;=";
                case "not_equal":
                    return "!=";
                case "":
                    return "";
                default:
                    Debug.Assert(false, "Unknown Test Operator Encountered [" + sTest + "]");
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception("Unknown Test Operator Encountered [" + sTest + "]");
                    throw new ImportExportException("Unknown Test Operator Encountered [" + sTest + "]");
            }
        }

        //Because some of the values may not be specified because they are optional, we cannot iterate over the contents of the rule.
        //We have to iterate over the definition data and then look up the condition or action in the rulset.
        //The two methods below RetrieveNamedConditionFromConditionSet and RetrieveNamedActionFromActionSet iterate over the collection
        //of items to find the named item we are looking for. If it is not found (because it is optional and has been left blank), then
        //the methods return an empty condition or action with the named.
        //The approach is not very efficient; eventually may wish to modify the ruleset object to return a 'named' item from one of the
        //collections.
        protected MTSimpleCondition RetrieveNamedConditionFromConditionSet(string sName, MTConditionSet conditionSet)
        {
            foreach (MTSimpleCondition condition in conditionSet)
            {
                if (condition.PropertyName.CompareTo(sName) == 0)
                {
                    return condition;
                }
            }

            MTSimpleCondition emptyCondition = new MTSimpleConditionClass();
            emptyCondition.PropertyName = sName;
            emptyCondition.Value = "";
            emptyCondition.Test = "";
            return emptyCondition;

        }

        protected MTAssignmentAction RetrieveNamedActionFromActionSet(string sName, MTActionSet actionSet)
        {
            foreach (MTAssignmentAction action in actionSet)
            {
                if (action.PropertyName.CompareTo(sName) == 0)
                {
                    return action;
                }
            }

            MTAssignmentAction emptyAction = new MTAssignmentActionClass();
            emptyAction.PropertyName = sName;
            emptyAction.PropertyValue = "";

            return emptyAction;
        }


        protected void AddDefaultActionsFromListOfValues(string[] values, ref IMTRuleSet outRuleset)
        {
            MTActionSet actionSet = new MTActionSetClass();

            int iCurrentValue = 0;

            //TODO: Add more resilient parsing to find 'then'
            string sRule = values[iCurrentValue++];
            Debug.Assert(sRule.CompareTo("Default") == 0, "Expected 'Default' as first cell of default rule");
            string sIf = values[iCurrentValue++];
            string sDefault = values[iCurrentValue++];
            string sThen = values[iCurrentValue++];
            Debug.Assert(sThen.CompareTo("then") == 0, "Expected 'then' as fourth cell of default rule");

            // SECENG: check for null.
            CheckParamTable();

            //Create the default actions
            foreach (ProdCat.IMTActionMetaData actiondef in mParamTableDefinition.ActionMetaData)
            {
                MTAssignmentAction action = new MTAssignmentActionClass();
                action.PropertyName = actiondef.PropertyName;
                action.PropertyType = (MetraTech.Interop.MTRuleSet.PropValType)actiondef.DataType;

                object tempValue = CheckAndConvertValueToRulesetType(values[iCurrentValue++], action.PropertyType, actiondef.Required, action.PropertyName);
                if (tempValue != null)
                {
                    action.PropertyValue = tempValue;
                    if ((action.PropertyType == PropValType.PROP_TYPE_ENUM) && (action.PropertyValue.ToString().Length > 0))
                    {
                        action.EnumSpace = actiondef.EnumSpace;
                        action.EnumType = actiondef.EnumType;
                    }

                    actionSet.Add(action);
                }
                else
                {
                    //If the value is null, then no action should be added. Essentially throw this action away.
                }
            }

            outRuleset.DefaultActions = actionSet;

        }

        protected MTRule CreateRuleFromListOfValues(string[] values)
        {
            MTRule rule = new MTRuleClass();
            MTConditionSet conditionSet;
            MTActionSet actionSet;

            conditionSet = new MTConditionSetClass();
            actionSet = new MTActionSetClass();

            int iCurrentValue = 0;

            string sRule = values[iCurrentValue++];
            string sIf = values[iCurrentValue++];

            Debug.Assert(sIf.CompareTo("if") == 0, "Expected 'if' as second column");

            //Create the conditions
            // SECENG: check for null.
            CheckParamTable();

            foreach (ProdCat.IMTConditionMetaData conditiondef in mParamTableDefinition.ConditionMetaData)
            {
                MTSimpleCondition condition = new MTSimpleConditionClass();

                condition.PropertyName = conditiondef.PropertyName;
                if (conditiondef.OperatorPerRule)
                {
                    condition.Test = GetTestStringFromDisplayName(values[iCurrentValue++]);
                }
                else
                {
                    //We still need to set the test based on the one defined in the param table
                    condition.Test = GetTestStringFromDisplayName(GetDisplayNameForOperatorType(conditiondef.Operator)); //Lazy way to cast to string
                }

                //TODO: Handle blank enum values
                condition.ValueType = (MetraTech.Interop.MTRuleSet.PropValType)conditiondef.DataType;
                /*if (condition.ValueType == PropValType.PROP_TYPE_DECIMAL)
                {
                  string sTemp = values[iCurrentValue];
                  string sTemp2 = "";
                }*/

                object tempValue = CheckAndConvertValueToRulesetType(values[iCurrentValue++], condition.ValueType, conditiondef.Required, condition.PropertyName);
                if (tempValue != null)
                {
                    condition.Value = tempValue;

                    if ((condition.ValueType == PropValType.PROP_TYPE_ENUM) && (condition.Value.ToString().Length > 0))
                    {
                        condition.EnumSpace = conditiondef.EnumSpace;
                        condition.EnumType = conditiondef.EnumType;
                    }

                    conditionSet.Add(condition);
                }
                else
                {
                    //If the value is null, then no condition should be added. Essentially throw this condition away.
                }
            }

            //TODO: decide what to do about confirming the 'then'
            string sThen = values[iCurrentValue++];

            // SECENG: check for null.
            CheckParamTable();
            
            //Create the actions
            foreach (ProdCat.IMTActionMetaData actiondef in mParamTableDefinition.ActionMetaData)
            {
                MTAssignmentAction action = new MTAssignmentActionClass();
                action.PropertyName = actiondef.PropertyName;
                action.PropertyType = (MetraTech.Interop.MTRuleSet.PropValType)actiondef.DataType;

                object tempValue = CheckAndConvertValueToRulesetType(values[iCurrentValue++], action.PropertyType, actiondef.Required, action.PropertyName);
                if (tempValue != null)
                {
                    action.PropertyValue = tempValue;

                    if ((action.PropertyType == PropValType.PROP_TYPE_ENUM) && (action.PropertyValue.ToString().Length > 0))
                    {
                        action.EnumSpace = actiondef.EnumSpace;
                        action.EnumType = actiondef.EnumType;
                    }

                    actionSet.Add(action);
                }
                else
                {
                    //If the value is null, then no action should be added. Essentially throw this action away.
                }

            }

            rule.Conditions = conditionSet;
            rule.Actions = actionSet;

            return rule;
        }

        protected object CheckAndConvertValueToRulesetType(string sValue, PropValType propType, bool bRequired, string sNameForErrorMessage)
        {
            //Check for blank value and return immediately
            if ((sValue == null) || (sValue.Length == 0))
            {
                if (bRequired)
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception(String.Format("{0} is required and no value was specified",sNameForErrorMessage));
                    throw new ImportExportException(String.Format("{0} is required and no value was specified", sNameForErrorMessage));
                else
                    return null; //Blank value is ok because value is not required
            }

            //Test to make decimal can be converted correctly
            if (propType == PropValType.PROP_TYPE_DECIMAL)
            {
                //Decimal values get set as a string value currently but this is an early check
                //to make sure it will be converted correctly downstream
                try
                {
                    //System.Convert.ToDecimal(sValue);
                    Double dblTemp = System.Convert.ToDouble(sValue);
                    decimal decTemp = decimal.Round((decimal)dblTemp, 10);
                    return decTemp;
                }
                catch (Exception e)
                {
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception(String.Format("Unable to convert the value of [{0}] for {1} to a decimal value:{2}",sValue,sNameForErrorMessage,e.Message));
                    throw new ImportExportException(String.Format("Unable to convert the value of [{0}] for {1} to a decimal value:{2}", sValue, sNameForErrorMessage, e.Message));
                }
            }

            //Test to make integer can be converted correctly
            if (propType == PropValType.PROP_TYPE_INTEGER)
            {
                //Integer values get set as a string value currently but this is an early check
                //to make sure it will be converted correctly downstream
                try
                {
                    System.Convert.ToInt32(sValue);
                }
                catch (Exception e)
                {
                    // SECENG: Fixing information disclosure thru exceptions.
                    //throw new Exception(String.Format("Unable to convert the value of [{0}] for {1} to a Int32 value: {2}",sValue,sNameForErrorMessage,e.Message));
                    throw new ImportExportException(String.Format("Unable to convert the value of [{0}] for {1} to a Int32 value: {2}", sValue, sNameForErrorMessage, e.Message));
                }
            }


            //Test and actually convert BOOLEAN type to integer
            if (propType == PropValType.PROP_TYPE_BOOLEAN)
            {
                if (sValue.ToUpper().Equals("FALSE"))
                {
                    return 0;
                }
                else
                {
                    if (sValue.ToUpper().Equals("TRUE"))
                        return -1;
                    else
                        // SECENG: Fixing information disclosure thru exceptions.
                        //throw new Exception(String.Format("Unable to convert the value of [{0}] for {1} to a boolean value. Value should be TRUE or FALSE",sValue,sNameForErrorMessage));
                        throw new ImportExportException(String.Format("Unable to convert the value of [{0}] for {1} to a boolean value. Value should be TRUE or FALSE", sValue, sNameForErrorMessage));
                }
            }

            return sValue;
        }

        // SECENG: Fixing performance problem.
        private System.Xml.XPath.XPathNodeIterator SelectNodes(System.Xml.XPath.XPathNavigator navigator, string expression)
        {
            System.Xml.XPath.XPathExpression worksheetsQuery = BuildExpression(navigator, expression);
            System.Xml.XPath.XPathNodeIterator Worksheets = navigator.Select(worksheetsQuery);
            return Worksheets;
        }

        // SECENG: Fixing performance problem.
        private System.Xml.XPath.XPathExpression BuildExpression(System.Xml.XPath.XPathNavigator navigator, string expression)
        {
            System.Xml.XPath.XPathExpression query = navigator.Compile(expression);
            query.SetContext(mXmlNamespaceManager);
            return query;
        }

        // SECENG: check for null.            
        private void CheckParamTable()
        {
            if (mParamTableDefinition == null)
            {
                throw new ImportExportException("Parameter table not found.");
            }
        }
    }

    // SECENG: Fixing information disclosure thru exceptions.
    /// <summary>
    /// Uses to path validation information.
    /// </summary>
    [Serializable]
    [Guid("0258AEF3-DD9D-4dca-ADF2-D903F7775446")]
    public class ImportExportException : Exception
    {
        public ImportExportException(string message)
            : base(message)
        {
        }

        protected ImportExportException(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
            : base(info, context)
        {
        }
    }

    [ComVisible(false)]
    public class EnumInfo
    {
        public EnumInfo()
        {
        }

        public EnumInfo(string sEnumSpace, string sEnumType)
        {
            mEnumSpace = sEnumSpace;
            mEnumType = sEnumType;
        }

        public string Space
        {
            get { return mEnumSpace; }
            set { mEnumSpace = value; }
        }

        public string Type
        {
            get { return mEnumType; }
            set { mEnumType = value; }
        }

        protected string mEnumSpace;
        protected string mEnumType;

    }

}
