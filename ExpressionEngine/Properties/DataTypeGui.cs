using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ICE;
using System.Collections;
using Xceed.Grid.Editors;
using Xceed.Editors;

namespace MetraTech.ICE
{
    public class DataTypeGui
    {
        /// <summary>
        /// Loads a combobox with all of the supported MSIX data types. Unistring is not loaded
        /// </summary>
        /// <param name="theComboBox"></param>
        public static void LoadComboBoxWithMsixDataTypes(ComboBox theComboBox)
        {
            theComboBox.BeginUpdate();

            theComboBox.DisplayMember = "UserString";
            theComboBox.Items.Clear();
            foreach (DataTypeInfo dtInfo in DataTypeInfo.MSIXDataTypeInfos)
            {
                if (dtInfo.Type != DataType._unistring) //unistring shouldn't be added to Combo box
                {
                    theComboBox.Items.Add(dtInfo.Copy());
                }
            }

            theComboBox.EndUpdate();
        }

        /// <summary>
        /// Loads a combobox with all of the supported MSIX data types. Unistring is not loaded
        /// </summary>
        /// <param name="theComboBox"></param>
        public static void LoadGridComboEditorWithMsixDataTypes(Xceed.Grid.Editors.ComboBoxEditor theEditor)
        {
            theEditor.Items.Clear();
            foreach (DataTypeInfo dtInfo in DataTypeInfo.MSIXDataTypeInfos)
            {
                if (dtInfo.Type != DataType._unistring) //unistring shouldn't be added to Combo box
                {
                    theEditor.Items.Add(dtInfo.ToUserString(false));
                }
            }
        }


        public static void LoadGridComboEditorWithDatabaseDataTypes(Xceed.Grid.Editors.ComboBoxEditor theEditor)
        {
            //theEditor.Items.Clear();
            foreach (var dtInfo in DataTypeInfo.DatabaseDataTypeInfos)
            {
               theEditor.Items.Add(dtInfo.ToUserString(false));
            }
        }

        public static void LoadComboBoxWithEnumSpaces(ComboBoxEditor comboBox)
        {
            comboBox.Items.Clear();
            foreach (KeyValuePair<string, EnumerationNamespace> kvp in Config.Instance.EnumerationConfig.EnumNamespaces)
            {
                comboBox.Items.Add(kvp.Value.Name);
            }
        }
        public static void LoadComboBoxWithEnumTypes(WinComboBox comboBox, string enumSpace)
        {
            comboBox.AllowFreeText = true;
            comboBox.Items.Clear();
            if (string.IsNullOrEmpty(enumSpace) || !Config.Instance.EnumerationConfig.EnumNamespaces.ContainsKey(enumSpace))
                return;

            foreach (KeyValuePair<string, EnumerationType> kvp in (Config.Instance.EnumerationConfig.EnumNamespaces[enumSpace].EnumTypes))
            {
                comboBox.Items.Add(kvp.Value.Name);
            }
        }
        public static void LoadComboBoxWithEnumTypes(ComboBoxEditor comboBox, string enumSpace)
        {
            LoadComboBoxWithEnumTypes((WinComboBox)comboBox.TemplateControl, enumSpace);
        }

        public static void LoadComboWithElements(ComboBox comboBox, DataTypeInfo dtInfo)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            foreach (DictionaryEntry de in Config.Instance.GetElementList((ElementType)dtInfo.ElementType))
            {
                comboBox.Items.Add(((ElementBase)de.Value).Name);
            }
            comboBox.EndUpdate();
        }


    }
}
