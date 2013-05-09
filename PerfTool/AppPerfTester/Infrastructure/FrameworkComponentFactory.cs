using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public static class FrameworkComponentFactory
    {

        public static Dictionary<string, IFrameworkComponent> components;

        static FrameworkComponentFactory()
        {
            components = new Dictionary<string, IFrameworkComponent>();

            install<FCDatabaseServer>();
            install<FCActSvcClient>();
            install<FCNetMeter>();
            install<FCProductViewRepo>();
            install<FCSvcDefRepo>();
            install<FCEnumRepo>();
            install<FCProductOffers>();
            install<FCAccountLoadService>();
          install<FCSecurity>();
        }

        static public void init()
        {
        }

        static int getPriority( IFrameworkComponent comp)
        {
            return comp.priority;
        }

        public static ICollection<string> Keys { get { return components.Keys; } }
        public static IOrderedEnumerable<IFrameworkComponent> Values {
            get {
                return components.Values.OrderBy<IFrameworkComponent, int>(getPriority);
            } 
        }

        private static void install<T>() where T : IFrameworkComponent, new()
        {
            IFrameworkComponent comp;
            comp = new T();
            comp.msgLogger = MsgLoggerFactory.getLogger(comp.name);
            components.Add(comp.name.ToLower(), comp);
        }

        public static IFrameworkComponent find(string s)
        {
            return components[s.ToLower()];
        }

        public static T find<T>()
        {
            foreach (IFrameworkComponent comp in Values)         
            {
                if (comp is T)
                {
                    return (T)comp;
                }
            }
            return default(T);
        }

    }
}
