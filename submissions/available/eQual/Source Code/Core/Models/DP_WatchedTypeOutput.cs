using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace DomainPro.Core.Models
{
    [Serializable]
    public class Pair<T, Y>
    {
        public Pair()
        {

        }
        public Pair(T t,Y y)
        {
            Key = t;
            Value = y;
        }
        
        public T Key { set; get; }
        
        public Y Value { set; get; }
    }
    public class DP_WatchedTypeOutput
    {
        public class SeriesData
        {
            public string SeriesName { set; get; }
            public List<Pair<double, double>> Data = new List<Pair<double, double>>();
        }
        public string WatchedTypeName { set; get; }
        public List<SeriesData> Series = new List<SeriesData>();
    }
}
