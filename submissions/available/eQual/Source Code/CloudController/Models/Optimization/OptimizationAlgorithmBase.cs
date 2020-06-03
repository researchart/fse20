using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;

namespace CloudController.Models.Optimization
{
    public abstract class OptimizationAlgorithmBase
    {

        protected OptimizationAlgorithmBase(string guid)
        {
            Guid = guid;
            ReadBoundaryList();
            QAList = MonitorViewModel.ReadQAs(guid);
        }
        public string Guid { set; get; }
        public List<PropertyOverride> BestSoFar { set; get; }
        public List<PropertyOverride> NextInLine { set; get; }
        public List<PropertyModel> BoundariesList { set; get; }
        public List<QualityAttributeMappingModel> QAList { set; get; }
        public double Progress { set; get; } 
        public abstract void RunOptimization();

        private void ReadBoundaryList()
        {
            string path = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + Guid + "/Properties/" + "Properties.xml";
            XmlSerializer deserializer = new XmlSerializer(typeof(List<PropertyModel>));
            TextReader textReader = new StreamReader(path);
            BoundariesList = (List<PropertyModel>)deserializer.Deserialize(textReader);
            textReader.Close();
        }


    }
}