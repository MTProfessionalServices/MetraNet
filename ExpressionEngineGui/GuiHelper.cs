using System;
using System.Collections.Generic;
using System.Drawing;
using MetraTech.ExpressionEngine;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public static class GuiHelper
    {
        public static Font ExpressionFont = new Font("Courier New", 8.5f);

        public static void LoadEnum<T>(ComboBox comboBox)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            foreach (var item in Enum.GetValues(typeof(T)))
            {
                comboBox.Items.Add(item);
            }
            comboBox.EndUpdate();
        }

        public static void LoadCurrencies(ComboBox comboBox, Context context)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DisplayMember = "Name";
            var currencies = context.EnumManager.GetCurrencyCategory();
            if (currencies != null)
            {
                foreach (var currency in currencies.Items)
                {
                    comboBox.Items.Add(currency);
                }
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static void LoadUnitOfMeasureCategories(ComboBox comboBox, Context context)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DisplayMember = "FullNameReversed";
            var categories = context.EnumManager.GetUnitOfMeasureCategories();
            if (categories != null)
            {
                foreach (var category in categories)
                {
                    comboBox.Items.Add(category);
                }
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static void LoadUnitsOfMeasure(ComboBox comboBox, EnumCategory uomCategory)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DisplayMember = "Name";
            if (uomCategory != null)
            {
                foreach (var item in uomCategory.Items)
                {
                    comboBox.Items.Add(item);
                }
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static void LoadProperties(ComboBox comboBox, MetraTech.ExpressionEngine.TypeSystem.Type typeFilter, PropertyCollection properties)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DisplayMember = "Name";
            var filteredProperties = properties.GetFilteredProperties(typeFilter);
            foreach (var property in filteredProperties)
            {
                comboBox.Items.Add(property);
            }
            comboBox.EndUpdate();
        }

        public static void LoadMetraNetBaseTypes(ComboBox comboBox, bool includeAny=false, bool includeNumeric=false)
        {
            comboBox.BeginUpdate();
            comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            if (includeAny)
                comboBox.Items.Add(BaseType.Any);
            if (includeNumeric)
                comboBox.Items.Add(BaseType.Numeric);
            foreach (var baseType in TypeHelper.MetraNetBaseTypes)
            {
                comboBox.Items.Add(baseType);
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static void LoadBaseTypes(ComboBox comboBox)
        {
            comboBox.BeginUpdate();
            comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            foreach (var baseType in Enum.GetValues(typeof(BaseType)))
            {
                comboBox.Items.Add(baseType);
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static List<object> GetAllNodeTags(this TreeView tree)
        {
            var nodes = new List<object>();
            _getAllNodeTags(nodes, tree.Nodes);
            return nodes;
        }
        private static void _getAllNodeTags(List<object> nodeList, TreeNodeCollection nodes)
        {
            foreach (TreeNode node in nodes)
            {
                nodeList.Add(node);
                _getAllNodeTags(nodeList, node.Nodes);
            }
        }
        public static List<TreeNode> GetAllNodes(this TreeView tree)
        {
            var nodes = new List<TreeNode>();
            _getAllNodes(nodes, tree.Nodes);
            return nodes;
        }

        private static void _getAllNodes(List<TreeNode> nodeList, TreeNodeCollection nodes)
        {
            foreach (TreeNode node in nodes)
            {
                nodeList.Add(node);
                _getAllNodes(nodeList, node.Nodes);
            }
        }

    }
}
