using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI.Blaster
{
    public class WorkerArgs
    {

        public string connStr
        {
            get { return _connStr; }
            set { _connStr = value; }
        }
        private string _connStr;

        public Int64 CountDown;
        public List<TestTable> Tables
        {
            get { return _Tables; }
            set { _Tables = value; }
        }
        private List<TestTable> _Tables;

        //public DataBlaster Blaster
        //{
        //    get { return _Blaster; }
        //    set { _Blaster = value; }
        //}
        //private DataBlaster _Blaster;

        //int threadId;
        public int rows_per_insert;
        public Int64 total_inserts;

        public Int64 seed;
        public int TableConfig;

        public TestTable table1;
        public TestTable table2;

    }

}
