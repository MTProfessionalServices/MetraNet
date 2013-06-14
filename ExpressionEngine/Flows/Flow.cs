using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class Flow
    {
        #region Properties 
        public Context Context { get; private set; }
        public PropertyCollection InitialProperties = new PropertyCollection(null);

        [DataMember]
        public FlowCollection FlowCollection { get; private set; }
        #endregion

        #region Constructor
        public Flow(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            Context = context;

            FlowCollection = new FlowCollection();
        }

        public void UpdateFlow()
        {
            FlowCollection.UpdateFlow(Context, InitialProperties);
        }
        #endregion
    }
}
