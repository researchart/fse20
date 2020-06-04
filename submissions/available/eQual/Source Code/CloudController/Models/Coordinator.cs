using DomainPro.Core.Models;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Xml.Serialization;
using CloudController.HttpHelper;
using CloudController.Models.Optimization;

namespace CloudController.Models
{
    
    public sealed class Coordinator
    {
        //Lazy loading the instance of the singleton class;
        private static readonly Lazy<Coordinator> lazy =
            new Lazy<Coordinator>(() => new Coordinator());
        public static Coordinator Instance { get { return lazy.Value; } }

        //Contains the available nodes initialized with the nodes in web.config file
        public ConcurrentQueue<Node> AvailablePool = new ConcurrentQueue<Node>();

        //This list contains the hooks that is deployed on each Node 
        //public ConcurrentBag<KeyValuePair<string, Node>> NodeHookList=new ConcurrentBag<KeyValuePair<string, Node>>();

        public ConcurrentBag<DeploymentInformation> DeploymentInfromationList = new ConcurrentBag<DeploymentInformation>();
        //Dictionary of Simulation Collections key is the guid of that collection, value is a list of simulation override directory instances of that
        public ConcurrentDictionary<string, ConcurrentQueue<string>> SimWaitingList = 
            new ConcurrentDictionary<string, ConcurrentQueue<string>>();
        //Keeping a list of simulations submitted by each guid (specifies model and language) and ready to be sent out to nodes to be run
        public ConcurrentQueue<DeploymentInformation> OptimizationWaitingList= new ConcurrentQueue<DeploymentInformation>();
        
        private object _lock = new object();
        private Coordinator()
        {
            foreach (var item in NodePool.Pool)
            {
                AvailablePool.Enqueue(item);
            }
            
        }

      
        public void CreateWaitingList(string guid)
        {
            if (!SimWaitingList.ContainsKey(guid))
            {
                SimWaitingList.TryAdd(guid, new ConcurrentQueue<string>());
            }
        }

        //Optimization
        /// <summary>
        /// Sends the simulation configuration provided to a slave node in the cloud in order to be ran
        /// Technically it just creates a deployment configuration and adds it to simulation waiting list queue
        /// </summary>
        /// <param name="propertyOverrides">List of property overrides</param>
        /// <param name="guid">Guid that specifies the model and language files</param>
        /// <param name="algorithm">The algorithm which made this request. It will be used to call it back with the results when received from node</param>
        /// <param name="identifier">The guid that uniquely specifies which genome/configuration in the optimization algorithm this deployment belongs to</param>
        public void  SubmitSimulationConfiguration(List<PropertyOverride> propertyOverrides, string guid,OptimizationAlgorithmBase algorithm,Guid identifier)
        {
            OptimizationWaitingList.Enqueue(new DeploymentInformation()
            {
                PropertyOverrides = propertyOverrides,
                Guid = guid,
                Algorithm = algorithm,
                Identifier = identifier
            });
            SimulationDeployerProcess();
        }

        //Optimization
        public void SimulationDeployerProcess()
        {
            lock (_lock)
            {
                while (!Coordinator.Instance.AvailablePool.IsEmpty &&
                       Coordinator.Instance.OptimizationWaitingList.Count > 0)
                {
                    Node node;
                    var dequedNodeSuccess = Coordinator.Instance.AvailablePool.TryDequeue(out node);
                    if (!dequedNodeSuccess)
                        continue;
                    DeploymentInformation depInfo;
                    var dequedSimSuccess = Coordinator.Instance.OptimizationWaitingList.TryDequeue(out depInfo);
                    if (!dequedSimSuccess)
                    {
                        Coordinator.Instance.AvailablePool.Enqueue(node);
                        continue;
                    }
                    try
                    {
                        depInfo.Node = node;
                        depInfo.StartTime = DateTime.Now;
                        //save the depInfo.PropertyOverrides to a file
                        depInfo.SimulationPath = SaveSimConfig(depInfo.Guid, depInfo.PropertyOverrides);
                        //save it to simulations with a folder name of datetime.now.miliseconds
                        var info = SendFilesToNode(depInfo.Guid, node, depInfo.SimulationPath);
                        depInfo.Hook = info.Hook.ToString().Replace("\"", "");
                        Coordinator.Instance.DeploymentInfromationList.Add(depInfo);
                        //Coordinator.Instance.NodeHookList.Add(new KeyValuePair<string, Node>(info.Hook.ToString().Replace("\"", ""), node));
                        //run the simulation on the node
                        HttpWebRequest request =
                            (HttpWebRequest)
                                WebRequest.Create(node.URL + "/RunSimulation?guid=" + depInfo.Guid + "&hook=" +
                                                  info.Hook.ToString().Replace("\"", ""));
                        HttpWebResponse response = (HttpWebResponse) request.GetResponse();
                    }
                    catch
                    {
                        Coordinator.Instance.AvailablePool.Enqueue(node);
                        continue;
                    }
                }
            }
        }
        /// <summary>
        /// Receives the simulation analyses results, saves it to corresponding deployment config and calls the algorithm and updates the results there.
        /// </summary>
        public void UpdateSimulationResults(DeploymentInformation info)
        {
            
            if (info.Algorithm is OptimizationByGenetic)
            {
                info.FinishTime = DateTime.Now;
                //SaveDeploymentInformation(info);
                (info.Algorithm as OptimizationByGenetic).UpdateGenomeFitnessInfo(info);
            }
            SimulationDeployerProcess();
        }

        private void SaveDeploymentInformation(DeploymentInformation info)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(DeploymentInformation));
            
            if (!Directory.Exists(info.SimulationPath))
            {
                Directory.CreateDirectory(info.SimulationPath);
            }
            using (TextWriter textWriter = new StreamWriter( Path.Combine( info.SimulationPath , "DeploymentInformation.xml")))
            {
                serializer.Serialize(textWriter, info);
                textWriter.Close();
            }
        }

        //Optimization
        private string SaveSimConfig(string guid, List<PropertyOverride> propertyOverrides)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(List<PropertyOverride>));
            string savePath = System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles") + "/" + guid + "/Simulations/" + DateTime.Now.Ticks + "/";
            if (!Directory.Exists(savePath))
            {
                Directory.CreateDirectory(savePath);
            }
            using (TextWriter textWriter = new StreamWriter(savePath + "Properties.xml"))
            {
                serializer.Serialize(textWriter, propertyOverrides);
                textWriter.Close();
            }
            return savePath;
        }

        private dynamic SendFilesToNode(string guid, Node node, string savePath)
        {
            string url = node.URL + "/UploadFiles";
            string t = String.Format("{0}\\{1}\\{2}\\", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), guid, "Simulations");
            HttpForm form = new HttpForm(url);
            string modDirectory = String.Format("{0}\\{1}\\{2}", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), guid, "Model");
            string[] modFiles = Directory.GetFiles(modDirectory, "*.zip");
            string langDirectory = String.Format("{0}\\{1}\\{2}", System.Web.Hosting.HostingEnvironment.MapPath("~/SimulationFiles"), guid, "Language");
            string[] langFiles = Directory.GetFiles(langDirectory, "*.zip");
            string properties = savePath + "\\Properties.xml";
            string nodeInfo = savePath + "\\ Node.xml";
            form.AttachFile("model", modFiles[0]);
            form.AttachFile("language", langFiles[0]);
            form.AttachFile("properties", properties);
            var response = form.Submit();
            using (Stream stream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(stream, Encoding.UTF8);
                String responseString = reader.ReadToEnd();
                SaveNodeInformation(nodeInfo, node.NodeID, responseString);
                return new
                {
                    NodeInfo = nodeInfo,
                    NodeID = node.NodeID,
                    Hook = responseString
                };
            }

        }
        private void SaveNodeInformation(string path, string nodeID, string hook)
        {
            string[] lines = { nodeID, hook };
            System.IO.File.WriteAllLines(path, lines);
        }

        public void DumpDeploymentInformation()
        {
            foreach (var item in Instance.DeploymentInfromationList)
            {
                SaveDeploymentInformation(item);
            }
        }
    }
   
}