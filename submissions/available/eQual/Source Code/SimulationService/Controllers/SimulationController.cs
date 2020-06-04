using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

using SimulationService.Models;
using System.Text;
using System.Xml.Serialization;
using CloudController.HttpHelper;
using CloudController.Models;
using DomainPro.Analyst.Engine;
using Coordinator = SimulationService.Models.Coordinator;

namespace SimulationService.Controllers
{
    public class SimulationController : ApiController
    {
        [Route("UploadFiles")]
        public string UploadFiles()
        {
            string hook = Guid.NewGuid().ToString();
            var httpRequest = HttpContext.Current.Request;
            if (httpRequest.Files.Count > 0)
            {

                for (int i = 0; i < httpRequest.Files.Count; i++)
                {
                    var postedFile = httpRequest.Files[i];
                    string virtualPath = String.Format("{0}\\{1}\\{2}", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), hook, httpRequest.Files.Keys[i]);
                    if (!Directory.Exists(virtualPath))
                    {
                        Directory.CreateDirectory(virtualPath);
                    }

                    postedFile.SaveAs(virtualPath + postedFile.FileName.Substring(postedFile.FileName.LastIndexOf("\\", StringComparison.Ordinal)));
                }

            }
            else
            {
                return hook;
            }
            return hook;
        }
        [Route("RunSimulation"), HttpGet]
        public string RunSimulation(string guid, string hook)  
        {

            if(Coordinator.Instance.IsRunning)
            {
                Coordinator.Instance.RequestedHooks.Enqueue(new KeyValuePair<string, string>(guid, hook));
                return "queue position:" + Coordinator.Instance.RequestedHooks.Count;
            }
            Coordinator.Instance.IsRunning = true;
            SimulationRunner simRun = new SimulationRunner(guid,hook);
            simRun.Initialize();
            simRun.Run();
            return "simulation is running now";
        }

        [Route("RunSimulatedAnnealingSimulation"),HttpGet]
        public string RunSimulatedAnnealingSimulation(string guid, string hook)
        {
            if (Coordinator.Instance.IsRunning)
            {
                Coordinator.Instance.RequestedHooks.Enqueue(new KeyValuePair<string, string>(guid, hook));
                return "queue position:" + Coordinator.Instance.RequestedHooks.Count;
            }
            Coordinator.Instance.IsRunning = true;
            SimulationRunner simRun = new SimulationRunner(guid, hook);
            simRun.Initialize();
            simRun.Run();
            return "simulation is running now";
        }

        [Route("test"), HttpGet]
        public void RewriteSimulationFiles(string hook)
        {
            string path = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/Properties/" + "Properties.xml";
            XmlSerializer deserializer = new XmlSerializer(typeof(List<PropertyOverride>));
            TextReader textReader = new StreamReader(path);
            List<PropertyOverride> propList = (List<PropertyOverride>)deserializer.Deserialize(textReader);
            textReader.Close();
            List<DP_Simulation> simList=null;
            
            string path2 = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/model/SmartRedundancyModified/" + "SmartRedundancySimList.xml";
            //string path2 = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + hook + "/model/SmartRedundancyModified/" + "SmartRedundancySimList2.xml";
            //File.Copy(paths,path2,true);
            FileStream fileStream = new FileStream(
      path2, FileMode.OpenOrCreate,
      FileAccess.ReadWrite, FileShare.ReadWrite);
            XmlSerializer deserializer2 = new XmlSerializer(typeof (List<DP_Simulation>));
            
                TextReader textReader2 = new StreamReader(fileStream);
                simList = (List<DP_Simulation>) deserializer2.Deserialize(textReader2);
                //textReader2.Close();
                //textReader2.Dispose();
            
            
            simList[0].PropertyOverrides.Clear();
            
            foreach (var item in propList)
            {
                simList[0].PropertyOverrides.Add(new DP_PropertyOverride()
                {
                    Property = item.Property,
                    Value =  item.Value,
                    Type = item.Type
                });
            }
            
            XmlSerializer serializer = new XmlSerializer(typeof(List<DP_Simulation>));
            fileStream.Flush();
            fileStream.Seek(0, 0);
            //if (!Directory.Exists(path2))
            //{
            //    Directory.CreateDirectory(path2);
            //}
            TextWriter textWriter = new StreamWriter(fileStream);
            serializer.Serialize(textWriter, simList);
            textWriter.Close();
            fileStream.Close();
            fileStream.Dispose();
        }
    }
}