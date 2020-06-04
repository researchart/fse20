using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace CloudController.Models
{
    public class MonitorViewModel
    {
        public MonitorViewModel(string guid)
        {
            this.Guid = guid;
        }
        public string Guid { set; get; }
        private static object _lockobj = new object();

        private List<QualityAttributeMappingModel> _qaList; 
        public List<QualityAttributeMappingModel> QAList
        {
            get
            {
                if (_qaList == null)
                {
                    _qaList =  ReadQAs(this.Guid);
                }
                return _qaList;
            }
        }

        public static void CreateQA(QualityAttributeMappingModel model, string guid)
        {
            
        }

        public static void DeleteQA(QualityAttributeMappingModel model, string guid)
        {
            
        }

        public static void UpdateQA(QualityAttributeMappingModel model, string guid)
        {
            lock (_lockobj)
            {
                var list = ReadQAs(guid);
                var item = (from items in list where items.WatchedType == model.WatchedType select items).First();
                item.SerieType = model.SerieType;
                item.ImportanceCoefficient = model.ImportanceCoefficient;
                item.QA = model.QA;
                item.Relation = model.Relation;
                SaveQAs(guid, list);
            }

        }

        public static void SaveQAs(string guid, List<QualityAttributeMappingModel> list )
        {
            lock (_lockobj)
            {
                XmlSerializer serializer = new XmlSerializer(typeof (List<QualityAttributeMappingModel>));
                string savePath = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + guid +
                                  "/WatchedTypes/";
                if (!Directory.Exists(savePath))
                {
                    Directory.CreateDirectory(savePath);
                }
                TextWriter textWriter = new StreamWriter(savePath + "Types.xml");
                serializer.Serialize(textWriter, list);
                textWriter.Close();
            }
        }
        public static List<QualityAttributeMappingModel> ReadQAs(string guid)
        {
            lock (_lockobj)
            {
                string path = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + guid +
                              "/WatchedTypes/" + "Types.xml";
                XmlSerializer deserializer = new XmlSerializer(typeof (List<QualityAttributeMappingModel>));
                TextReader textReader = new StreamReader(path);
                List<QualityAttributeMappingModel> simList =
                    (List<QualityAttributeMappingModel>) deserializer.Deserialize(textReader);
                textReader.Close();
                return simList;
            }
        } 
    }
}