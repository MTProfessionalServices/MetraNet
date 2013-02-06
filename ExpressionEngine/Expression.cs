using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class Expression
    {
        #region Enums
        public enum ExpressionTypeEnum { 
            AQG,
            UQG,
            Message ///Merging of localized text (e.g., email templates, sms messages, etc.)
        }
        #endregion

        #region Properties

        /// <summary>
        /// The type of expression
        /// </summary>
        public readonly ExpressionTypeEnum Type;

        public ExpressionInfo Info { get { return ExpressionInfo.Items[Type]; } }

        /// <summary>
        /// The actual expression
        /// </summary>
        public string Content { get; set; }

        /// <summary>
        /// The data type that the Expression returns. You must invoke parse to update this.
        /// </summary>
        public Property ReturnType { get; private set; }

        /// <summary>
        /// The parameters that the Expression interacts with. Note that the Direction
        /// can be Input, Output, or InOut. You must invoke Parse() to update this.
        /// </summary>
        public PropertyCollection Parameters { get; private set; }
        #endregion

        #region Constructor
        public Expression(ExpressionTypeEnum type, string contents)
        {
            Type = type;
            Content = contents;
            Parameters = new PropertyCollection(this);
            _DemoLoader.LoadInputsOutputs(this);
        }
        #endregion

        #region Methods
        /// <summary>
        /// Parses the contents and updates the ReturnType and Parameters properties. If successful, true is
        /// returned. Otherwise false is returned and the errorMsg, lineNumer and columnNumber are set.
        /// </summary>
        public bool Parse(out string errorMsg, out int lineNumber, out int columnNumber)
        {
            throw new NotImplementedException();
        }
        #endregion

    }
}
