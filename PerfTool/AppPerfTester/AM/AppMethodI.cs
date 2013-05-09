using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public delegate void AppCommand();

    public interface AppMethodBaseI
    {
        string group { get; set; }

        string name { get; set; }
        string fullName { get; set; }

        MsgLogger msgLogger { get; set; }

        string status1 { set; get; }
        string status2 { set; get; }

        event EventHandler<AppEventData> OnModelChangeEvent;
        Dictionary<string, AppCommand> commands { set; get; }
        List<Statistic> statistics { set; get; }

        bool runForever { set; get; }

        void executeOnce(string what);
        void executeCommand(string what);
    }


    public interface AppMethodI : AppMethodBaseI
    {
        void setup();
        void teardown();
        void dispose();
    }

}
