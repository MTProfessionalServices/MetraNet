using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;
using System.IO;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// This is a place holder. Need to think through. We probably will want expression templates.
    /// </summary>
    [DataContract]
    public class Expression
    {
        #region Enums
        public enum ExpressionTypeEnum { 
            AQG,
            UQG,
            Logic,
            Email,
            Message ///Merging of localized text (e.g., email templates, sms messages, etc.)
        }
        #endregion

        #region Static Properties
        public static readonly string[] EqualityOperators = new string[] { "==", "eq" };
        public static readonly string[] InequalityOperators = new string[] { "!=", "nq" };
        #endregion

        #region Properties

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string Description{get;set;}

        /// <summary>
        /// The type of expression
        /// </summary>
        [DataMember]
        public ExpressionTypeEnum Type { get; private set; }

        /// <summary>
        /// This probably belongs in a expression template as opposed to an instance
        /// </summary>
        [DataMember]
        public List<string> EntityParameters { get; private set; }

        public ExpressionInfo Info { get { return ExpressionInfo.Items[Type]; } }

        /// <summary>
        /// The actual expression
        /// </summary>
        [DataMember]
        public string Content { get; set; }

        /// <summary>
        /// The declared data type (which may be different that what's returned by the the Parse() method.
        /// </summary>
        [DataMember]
        public Property DeclaredReturnType { get; set; }

        #endregion

        #region Constructor
        public Expression(ExpressionTypeEnum type, string contents, string name)
        {
            Type = type;
            Content = contents;
            Name = name;
            EntityParameters = new List<string>();
            DeclaredReturnType = Property.CreateBoolean("ReturnValue", "The value the expression returns.");
        }
        #endregion

        #region Methods
        /// <summary>
        /// Parses the contents and updates the ReturnType and Parameters properties. If successful, true is
        /// returned. Otherwise false is returned and the errorMsg, lineNumer and columnNumber are set.
        /// </summary>
        public ExpressionParseResults Parse()
        {

            //HACK -- since we aren't integrated with MVM parse engine, simulate some stuff!
            var results = new ExpressionParseResults();
            var prop = Property.CreateInteger32("USAGE.Hours", null);
            prop.Direction = Property.DirectionType.InOut;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.CpuCount", null);
            prop.Direction = Property.DirectionType.Input;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Snapshots", null);
            prop.Direction = Property.DirectionType.Input;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Amount", null);
            prop.Direction = Property.DirectionType.Input;
            results.Parameters.Add(prop);

            var entity = ComplexType.CreateProductView("ParameterTable.CloudRates", null);
            prop.Direction = Property.DirectionType.Input;
            results.Parameters.Add(entity);

            prop = Property.CreateBoolean("<Result>", "The result of the boolean expression");
            prop.Direction = Property.DirectionType.Output;
            results.Parameters.Add(prop);
            return results;
        }

        public static Expression CreateFromFile(string file)
        {
            var fs = new FileStream(file, FileMode.Open);
            var reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(Expression));
            var expression = (Expression)ser.ReadObject(reader, true);
            fs.Close();
            reader.Close();

            return expression;
        }

        public void Save(string dirPath)
        {
            var filePath = string.Format(@"{0}\{1}.xml", dirPath, Name);
            var writer = new FileStream(filePath, FileMode.Create);
            var ser = new DataContractSerializer(typeof(Expression));
            ser.WriteObject(writer, this);
            writer.Close();
        }

        public static Expression CreateFromString(string xmlContent)
        {
            return null;
        }
        #endregion

    }
}
