using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Xml;
using System.Runtime.Serialization;
using System.IO;
using System.Text.RegularExpressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.MTProperty;

[assembly: CLSCompliant(true)]
namespace MetraTech.ExpressionEngine.Expressions
{
    /// <summary>
    /// This is a place holder. Need to think through. We probably will want expression templates.
    /// </summary>
    [DataContract (Namespace="MetraTech")]
    public class Expression
    {
        #region Properties

        [DataMember]
        public int ExpressionId { get; private set; }

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string Description{get;set;}

        /// <summary>
        /// The type of expression
        /// </summary>
        [DataMember]
        public ExpressionType Type { get; private set; }

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
        public Expression(ExpressionType type, string contents, string name)
        {
            Type = type;
            Content = contents;
            Name = name;
            EntityParameters = new List<string>();
            DeclaredReturnType = Property.CreateBoolean("ReturnValue", true, "The value the expression returns.");
        }
        #endregion

        #region Methods
        /// <summary>
        /// Parses the contents and updates the ReturnType and Parameters properties. If successful, true is
        /// returned. Otherwise false is returned and the errorMsg, lineNumer and columnNumber are set.
        /// </summary>
        public ExpressionParseResults Parse()
        {
            var results = new ExpressionParseResults();

            //Emails are easy to handle (don't need MVM parse tree)
            if (Type == ExpressionType.Email)
            {

                //Parse the inputs
                MatchCollection matches = Regex.Matches(Content, "{[a-zA-Z][a-zA-Z0-9_.]*}");
                foreach (Match match in matches)
                {
                    foreach (Match capture in match.Captures)
                    {
                        var paramName = capture.Value.Substring(1, capture.Value.Length-2);
                        if (results.Parameters.Get(paramName) == null)
                        {
                            var property = Property.CreateUnknown(paramName, false, null);
                            results.Parameters.Add(property);
                        }
                    }
                }
                results.IsValid = true;
                return results;
            }

            //HACK -- since we aren't integrated with MVM parse engine, simulate some stuff!
            var prop = Property.CreateInteger32("USAGE.Hours", true, null);
            prop.Direction = Direction.InOut;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.CpuCount", true, null);
            prop.Direction = Direction.Input;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Snapshots", true, null);
            prop.Direction = Direction.Input;
            results.Parameters.Add(prop);

            prop = Property.CreateInteger32("USAGE.Amount", true, null);
            prop.Direction = Direction.Input;
            results.Parameters.Add(prop);

            prop = Property.CreateBoolean("<Result>", true, "The result of the boolean expression");
            prop.Direction = Direction.Output;
            results.Parameters.Add(prop);
            return results;
        }

        public ExpressionParseResults ParseAndBindResults(Context context)
        {
            var results = Parse();
            results.BindResultsToContext(context);
            return results;
        }
        public static Expression CreateFromFile(string file)
        {
            using (var fs = new FileStream(file, FileMode.Open))
            {
                using (var reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas()))
                {
                    var ser = new DataContractSerializer(typeof (Expression));
                    var expression = (Expression) ser.ReadObject(reader, true);
                    return expression;
                }
            }
        }

        public void Save(string dirPath)
        {
            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, Name);
            using (var writer = new FileStream(filePath, FileMode.Create))
            {
                var ser = new DataContractSerializer(typeof (Expression));
                ser.WriteObject(writer, this);
            }
        }

        //public static Expression CreateFromString(string xmlContent)
        //{
        //    return null;
        //}
        #endregion
    }
}
