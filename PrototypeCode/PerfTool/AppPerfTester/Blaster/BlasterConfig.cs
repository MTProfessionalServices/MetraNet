using System;
using System.Collections.Generic;


namespace BaselineGUI.Blaster
{
    public class BlasterConfig
    {
        public string connectionString
        {
            get { return _connectionString; }
            set { _connectionString = value; }
        }
        private string _connectionString;

        public Int32 numThreads
        {
            get { return _numThreads; }
            set { _numThreads = value; }
        }
        private Int32 _numThreads;

        public Int64 IndexSeed
        {
            get { return _IndexSeed; }
            set { _IndexSeed = value; }
        }
        private Int64 _IndexSeed;

        public Int32 totalRowsPerTable
        {
            get { return _totalRowsPerTable; }
            set { _totalRowsPerTable = value; }
        }
        private Int32 _totalRowsPerTable;

        public Int32 rowsPerInsert
        {
            get { return _rowsPerInsert; }
            set { _rowsPerInsert = value; }
        }
        private Int32 _rowsPerInsert;

        public List<TableDef> Tables
        {
            get { return _Tables; }
            set { _Tables = value; }
        }
        private List<TableDef> _Tables;
    }
}
