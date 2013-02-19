﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public class EnumValue : IExpressionEngineTreeNode
    {
        #region Properties

        /// <summary>
        /// The EnumType to which the value belongs
        /// </summary>
        public EnumType EnumType { get; private set; }

        /// <summary>
        /// The name of the enum value
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// MetraNet enums are repreesnted by an ID that will vary by installation
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// The description of the value. TODO: Localize
        /// </summary>
        public string Description { get; set; }
        #endregion

        #region GUI Support Properties (should be moved)
        /// <summary>
        /// TOGO Localize
        /// </summary>
        public string ToolTip
        {
            get
            {
                var toolTip = "EnumValue";
                if (!string.IsNullOrEmpty(Description))
                    toolTip += Environment.NewLine + Description;
                if (UserSettings.ShowActualMappings)
                    toolTip += string.Format(CultureInfo.InvariantCulture, "\r\n[DatabaseId={0}]", Id);
                return toolTip;
            }
        }

        public string TreeNodeLabel { get { return Name; } }

        /// <summary>
        /// The 16x16 image associated with the value
        /// </summary>
        public string Image { get { return "EnumValue.png"; } }

        #endregion 

        #region Constructor
        public EnumValue(EnumType parent, string value, int id)
        {
            EnumType = parent;
            Name = value;
            Id = id;
        }
        #endregion

        #region Methods
        /// <summary>
        /// Returns the value in a MTSQL format which is used by MVM, MTSQL Pipeline plug-ins and MetraFlow
        /// </summary>
        public string ToMtsql()
        {
            return string.Format(CultureInfo.InvariantCulture, "#{0}/{1}/{2}#", EnumType.Parent.Name, EnumType.Name, Name);
        }

        /// <summary>
        /// Returns the value in the proposed future MVM format
        /// </summary>
        public string ToExpressionSnippet
        {
            get
            {
                if (UserSettings.NewSyntax)
                {
                    var enumSpace = EnumType.Parent.Name.Replace('.', '_');
                    return string.Format(CultureInfo.InvariantCulture, "ENUM.{0}.{1}.{2}", enumSpace, EnumType.Name, Name);
                }
                else
                    return ToMtsql();
            }
        }

        #endregion
    }

}
