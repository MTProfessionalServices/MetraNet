using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Collections.ObjectModel;

namespace MetraTech.ExpressionEngine.Test
{
    /// <summary>
    /// This is test for an expression which is configured and run by the end-user.
    /// We're not dealing with inouts at this time!
    /// </summary>
    [DataContract]
    public class TestInstance
    {
        #region Properties

        /// <summary>
        /// Identifes the Expression to which the test is associated
        /// </summary>
        [DataMember]
        public int ExpressionId { get; private set; }

        /// <summary>
        /// The name that the user associates with the test
        /// </summary>
        [DataMember]
        public string Name { get; set; }
        public PropertyCollection Properties { get; private set; }

        /// <summary>
        /// The description that the user assoicates with the test
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// Maps the input property names to their values
        /// </summary>
        [DataMember]
        public Collection<KeyValuePair<string, string>> Inputs { get; private set; }

        /// <summary>
        /// Maps the output property names to their expected values
        /// </summary>
        [DataMember]
        public Collection<KeyValuePair<string, string>> Outputs { get; private set; }
        #endregion

        #region Constructor 
        public TestInstance()
        {
            Properties = new PropertyCollection(this);
            Inputs = new Collection<KeyValuePair<string, string>>();
            Outputs = new Collection<KeyValuePair<string, string>>();
        }
        #endregion

        #region Methods
        public void StoreInputsAndOutputs()
        {
            Inputs.Clear();
            Outputs.Clear();
            foreach (var property in Properties)
            {
                var prop = (Property)property;
                switch (prop.Direction)
                {
                    case DirectionType.Input:
                        Inputs.Add(new KeyValuePair<string, string>(prop.Name, prop.Value));
                        break;
                    case DirectionType.Output:
                        Outputs.Add(new KeyValuePair<string, string>(prop.Name, prop.Value));
                        break;
                    default:
                        throw new NotImplementedException("InOuts are not supported yet");
                }
            }
        }

        public ValidationMessageCollection Compare()
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
