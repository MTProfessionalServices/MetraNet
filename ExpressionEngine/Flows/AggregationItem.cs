using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.ExpressionEngine.Mvm.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class AggregationItem
    {
        #region properties
        /// <summary>
        /// The property to which the aggregation is targeted. Must be a numeric
        /// </summary>
        [DataMember]
        public string TargetProperty { get; set; }

        /// <summary>
        /// The type of aggregation
        /// </summary>
        [DataMember]
        public AggregateAction Action { get; set; }

        /// <summary>
        /// The property which is being aggregated. Must be a numeric
        /// </summary>
        [DataMember]
        public string Source { get; set; }

        [DataMember]
        public string Filter { get; set; }
        #endregion

        #region Constructor
        public AggregationItem(string targetProperrty, AggregateAction action, string source, string filter)
        {
            TargetProperty = targetProperrty;
            Action = action;
            Source = source;
            Filter = filter;
        }
        #endregion
    }
}
