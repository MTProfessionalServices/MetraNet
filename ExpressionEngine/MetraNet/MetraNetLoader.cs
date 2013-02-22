using System;

namespace MetraTech.ExpressionEngine.MetraNet
{
    class MetraNetLoader
    {
        public static void AppendCommonAccountViewProperties(PropertyCollection props)
        {
            if (props == null)
                throw new ArgumentNullException("props");

            props.AddInteger32("AccountId", "The account associated with the event", true);
        }

        public static void AppendCommonProductViewProperties(PropertyCollection props)
        {
            if (props == null)
                throw new ArgumentNullException("props");

            props.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            props.AddInteger32("AccountId", "The account associated with the event", true);

            var name = UserSettings.NewSyntax ? "EventCharge" : "Amount";
            props.AddCharge(name, "The charge assoicated with the event which may summarize other charges within the event", true);
        }
    }
}
