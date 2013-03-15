using System;
using MetraTech.ExpressionEngine;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public static class GuiHelper
    {
        public static void LoadCurrencies(ComboBox comboBox, Context context)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            var currencies = context.GetCurrencyCategory();
            foreach (var currency in currencies.Items)
            {
                comboBox.Items.Add(currency);
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public static void LoadProperties(ComboBox comboBox, MetraTech.ExpressionEngine.TypeSystem.Type typeFilter, PropertyCollection properties)
        {
            comboBox.BeginUpdate();
            comboBox.Items.Clear();
            comboBox.DisplayMember = "Name";
            foreach (var property in properties.GetFilteredProperties(typeFilter))
            {
                comboBox.Items.Add(property);
            }
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

    }
}
