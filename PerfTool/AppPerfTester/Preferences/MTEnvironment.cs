using System;

namespace BaselineGUI
{
    public static class MTEnvironment
    {
        public static string MtRmp;
        public static string IntDir;

        static MTEnvironment()
        {
            MtRmp = Environment.GetEnvironmentVariable("MTRMP");
            IntDir = Environment.GetEnvironmentVariable("INTDIR");
        }

    }
}
