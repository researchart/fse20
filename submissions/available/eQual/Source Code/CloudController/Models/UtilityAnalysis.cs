using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;
using CloudController.Controllers;
using DomainPro.Core.Models;

namespace CloudController.Models
{
    public class UtilityAnalysis
    {
        public string Guid { set; get; }

        private Dictionary<string, List<DP_WatchedTypeOutput>> ResultsSet= new Dictionary<string, List<DP_WatchedTypeOutput>>();

        public List<QualityAttributeMappingModel> QAList;
        public List<AnalysisSummary> AnalysisSummaries { set; get; }
        public UtilityAnalysis(string guid)
        {
            Guid = guid;
            AnalysisSummaries = new List<AnalysisSummary>();
            //go into that folder
            //read the QAList
            QAList = MonitorViewModel.ReadQAs(guid);

            //read all the results files and populate the dictionary
            //make sure to use usings to relaese memory afterwards
            ReadResultsSet();
            

        }

        public void RunAnalysis()
        {
            foreach (var r in ResultsSet)
            {
                var anal = new AnalysisSummary();
                foreach (var q in QAList)
                {
                    var w = (from items in r.Value where items.WatchedTypeName == q.WatchedType select items).FirstOrDefault();
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
                
                AnalysisSummaries.Add(anal);
            }

            List<Range> maxRanges = new List<Range>();
            foreach (var item in AnalysisSummaries)
            {
                for(int i=0;i<item.List.Count;i++)
                {
                    if (maxRanges.Count <= i)
                    {
                        maxRanges.Add(new   Range()
                        {
                            UpperBound = -Double.MaxValue,
                            LowerBound = Double.MaxValue
                        });
                    }
                    if (item.List[i].Range.UpperBound >=maxRanges[i].UpperBound)
                        maxRanges[i].UpperBound = item.List[i].Range.UpperBound;
                    if (item.List[i].Range.LowerBound < maxRanges[i].LowerBound)
                        maxRanges[i].LowerBound = item.List[i].Range.LowerBound;
                }
            }
            List<Range> utilityRanges = new    List<Range>();
            for (int i = 0;i<QAList.Count; i++)
            {
                utilityRanges.Add(new Range()
                {
                    UpperBound = -Double.MaxValue,
                    LowerBound = Double.MaxValue
                });
            }
            double max = Int32.MinValue;
            foreach (var item in AnalysisSummaries)
            {
                for (int i = 0; i < item.List.Count; i++)
                {
                    var qaInCurrentSimulation = item.List[i];
                    if (QAList[i].Relation.RelationDirection == QualityWatchedTypeRelationship.Direction.Direct)
                    {
                        qaInCurrentSimulation.OverallUtility = ( maxRanges[i].UpperBound- qaInCurrentSimulation.Average) /
                                                  (maxRanges[i].UpperBound - maxRanges[i].LowerBound);
                    }
                    else
                    {
                        qaInCurrentSimulation.OverallUtility = (qaInCurrentSimulation.Average - maxRanges[i].LowerBound) /
                                                 (maxRanges[i].UpperBound - maxRanges[i].LowerBound);
                    }
                    qaInCurrentSimulation.OverallUtility = QAList[i].ImportanceCoefficient*
                                                           qaInCurrentSimulation.OverallUtility;

                    if (utilityRanges[i].LowerBound > qaInCurrentSimulation.OverallUtility)
                        utilityRanges[i].LowerBound = qaInCurrentSimulation.OverallUtility;
                    if (utilityRanges[i].UpperBound < qaInCurrentSimulation.OverallUtility)
                        utilityRanges[i].UpperBound = qaInCurrentSimulation.OverallUtility;
                    if (max < qaInCurrentSimulation.OverallUtility)
                        max = qaInCurrentSimulation.OverallUtility;
                }
                item.OverallUtility = (from qas in item.List select qas.OverallUtility).Average();
            }
            foreach (var item in AnalysisSummaries)
            {
                for (int i = 0; i < item.List.Count; i++)
                {
                    item.List[i].OverallUtility /= max;
                    //item.List[i].OverallUtility = (item.List[i].OverallUtility - utilityRanges[i].LowerBound) / (utilityRanges[i].UpperBound - utilityRanges[i].LowerBound);
                }
            }
            AnalysisSummaries =
                (from items in AnalysisSummaries orderby items.OverallUtility descending select items).ToList();
        }


        private void ReadResultsSet()
        {
            string simPath = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + Guid +
                                  "/simulations/";
            DirectoryInfo dirInf = new DirectoryInfo(simPath);
            foreach (var item in dirInf.GetDirectories())
            {
                var singleRes = ReadSingleResult(Path.Combine(item.FullName, "Results.xml"));
                if(singleRes!=null)
                    ResultsSet.Add(item.Name,singleRes);
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
    }

    //Analysis Summary contains all the attributes for one simulation runtime
    //AnalysisSummaryAtom is the thing that describes each vertex 
    /// <summary>
    /// Contains all the attributes and simulation reulst for one simulation suntime
    /// List of Atoms is stored inside
    /// </summary>
    public class AnalysisSummary
    {
        public List<AnalysisSummaryAtom> List = new List<AnalysisSummaryAtom>();
        public string SimulationName { set; get; }
        public double OverallUtility { set; get; }
    }
    /// <summary>
    /// Atom is the simulation analyses summary for one of the watched types
    /// </summary>
    
    public class AnalysisSummaryAtom
    {
        public string WatchetType { set; get; }
        public string SerieName { set; get; }
        public Range Range { set; get; }
        public double Average { set; get; }
        public double Variance { set; get; }
        public double OverallUtility { set; get; }
    }
    public class Range
    {
        public double UpperBound { set; get; }
        public double LowerBound { set; get; }
    }
}