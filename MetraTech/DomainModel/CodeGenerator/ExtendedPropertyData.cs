using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using System.Configuration;
using MetraTech.Interop.RCD;

namespace MetraTech.DomainModel.CodeGenerator
{
    public class ExtendedPropertyData
    {
        public string TableName { get; set; }
        public List<ConfigPropertyData> Properties { get; set; }
    }

    public class ExtendedPropertyProvider
    {
        public static List<FileData> ExtendedPropertyFiles
        {
            get
            {
                if (extendedPropertyFiles == null)
                {
                    List<FileData> fileDataList = new List<FileData>();

                    IMTRcdFileList fileList = BaseCodeGenerator.RCD.RunQuery(@"config\ExtendedProp\*.msixdef", true);

                    foreach (string file in fileList)
                    {
                        if (File.Exists(file))
                        {
                            FileData fileDataPITEmplate = new FileData();
                            fileDataPITEmplate.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
                            fileDataPITEmplate.FileName = Path.GetFileName(file);
                            fileDataPITEmplate.FullPath = file;

                            fileDataList.Add(fileDataPITEmplate);
                        }
                    }

                    extendedPropertyFiles = fileDataList;
                }

                return extendedPropertyFiles;
            }
        }

        public static Dictionary<string, List<ExtendedPropertyData>> ExtendedProperties
        {
            get
            {
                if (extendedProperties == null)
                {
                    extendedProperties = new Dictionary<string, List<ExtendedPropertyData>>();

                    foreach (FileData fileData in PriceableItemData.ExtendedPropertyFiles)
                    {
                        XmlDocument doc = new XmlDocument();
                        doc.Load(fileData.FullPath);

                        XmlNode nameNode = doc.SelectSingleNode("//name");
                        if (nameNode == null)
                        {
                            BaseCodeGenerator.Logger.LogError(String.Format("Extended propery error - bad xml: <name/> element is missing in file {0}", fileData.FullPath));
                            throw new ConfigurationErrorsException(String.Format("Extended propery error - bad xml: <name/> element is missing in file {0}", fileData.FullPath));
                        }

                        string table_name = nameNode.InnerText.Trim().ToLower();
                        if (String.IsNullOrEmpty(table_name))
                        {
                            BaseCodeGenerator.Logger.LogError(String.Format("Extended propery error - bad xml: cannot discern 'name' from </name> node in file {0}", fileData.FullPath));
                            throw new ConfigurationErrorsException(String.Format("Extended propery error - bad xml: cannot discern 'name' from </name> node in file {0}", fileData.FullPath));
                        }

                        string kind = nameNode.Attributes["kind"].Value;
                        if (string.IsNullOrEmpty(kind))
                        {
                            BaseCodeGenerator.Logger.LogError(String.Format("Extended propery error - bad xml: cannot discern 'kind' from </name> node in file {0}", fileData.FullPath));
                            throw new ConfigurationErrorsException(String.Format("Extended propery error - bad xml: cannot discern 'kind' from </name> node in file {0}", fileData.FullPath));
                        }

                        XmlNodeList ptypeNodes = doc.SelectNodes("//ptype");
                        if (ptypeNodes.Count == 0)
                        {
                            BaseCodeGenerator.Logger.LogWarning(String.Format("Extended propery: none found in file {0} ", fileData.FullPath));
                            continue;
                        }

                        List<ConfigPropertyData> configProps = new List<ConfigPropertyData>();

                        foreach (XmlNode ptypeNode in ptypeNodes)
                        {
                            ConfigPropertyData configPropertyData = null;

                            if (!BaseCodeGenerator.GetPropertyData(ptypeNode, out configPropertyData))
                            {
                                BaseCodeGenerator.Logger.LogError(String.Format("Extended propery: error getting config propery data in file {0} ", fileData.FullPath));
                                throw new ConfigurationErrorsException(String.Format("Extended propery: error getting config propery data in file {0} ", fileData.FullPath));
                            }

                            configProps.Add(configPropertyData);
                        }

                        ExtendedPropertyData data = new ExtendedPropertyData();
                        data.TableName = string.Format("t_ep_{0}", table_name);
                        data.Properties = configProps;

                        // 'kind' may have aliases (e.g. nonrecurring, non-recurring, non_recurring)
                        if (!extendedProperties.ContainsKey(kind))
                        {
                            extendedProperties[kind] = new List<ExtendedPropertyData>();
                        }

                        extendedProperties[kind].Add(data);
                    }
                }

                return extendedProperties;
            }
        }

        #region Members
        private static List<FileData> extendedPropertyFiles = null;
        private static Dictionary<string, List<ExtendedPropertyData>> extendedProperties = null;
        #endregion
    }
}