using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;
using CloudController.Models.Optimization;
using DomainPro.Core.Models;

namespace CloudController.Models
{
    public class DeploymentInformation
    {
        public DeploymentInformation()
        {
            
        }
        public Guid Identifier { set; get; }
        public string Guid { get; set; }
        public string Hook { get; set; }
        public DateTime StartTime { set; get; }
        public DateTime FinishTime { set; get; }
        public Node Node { set; get; }
        public string SimulationPath { set; get; }

        public AnalysisSummary SimulatinoAnalysisSummary
        {
            get
            {
                var QAList = MonitorViewModel.ReadQAs(Guid);
                var r = ReadSingleResult(Path.Combine(SimulationPath, "results.xml"));
                var anal = new AnalysisSummary();
                foreach (var q in QAList)
                {
                    var w = (from items in r where items.WatchedTypeName == q.WatchedType select items).FirstOrDefault();
                    var data = w.Series[q.SerieType.Index()].Data;
                    var analInstance = new AnalysisSummaryAtom()
                    {
                        SerieName = q.SerieType.SerieName,
                        WatchetType = q.WatchedType,
                        Average = data.ContinuousAverage(),
                        Range = data.SeriesRange(),
                        Variance = data.StandardDeviation()
                    };
                    anal.List.Add(analInstance);
                }
                return anal;
            }
        }
        private List<DP_WatchedTypeOutput> ReadSingleResult(string path)
        {
            try
            {
                XmlSerializer deserializer = new XmlSerializer(typeof(List<DP_WatchedTypeOutput>));
                TextReader textReader = new StreamReader(path);
                List<DP_WatchedTypeOutput> simList =
                    (List<DP_WatchedTypeOutput>)deserializer.Deserialize(textReader);
                textReader.Close();
                return simList;
            }
            catch (Exception exception)
            {
                return null;
            }
        }
        public List<PropertyOverride> PropertyOverrides { set; get; }
        [XmlIgnore]
        public OptimizationAlgorithmBase Algorithm { set; get; }

    }
}