using Ionic.Zip;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
//using System.Net.Mime.MediaTypeNames;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;
using DomainPro.Analyst;
using System.Windows.Forms;

namespace SimulationTest
{
    class Program
    {
        static void Main(string[] args)
        {
            //DomainProAnalyst app = new DomainProAnalyst("D:\\Projects\\DomainPro\\trunk\\DomainPro");
            ////System.Windows.Forms.Application.Run(app);
            //app.LoadProjectForCloud(@"D:\Projects\DomainPro\trunk\SmartRedundancy.dpp", @"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\VolunteerComputing.dpl");
            //app.RunSimClick(null,null);
            string baseFolder =
                @"C:\Nodes\CloudController\SimulationFiles\9a7c7710-5cf0-46bc-b0b4-eba2a5c73d3b\Simulations";


            List<long> five = new List<long>();
            List<long> one = new List<long>();
            List<long> two = new List<long>();

            var dirs = Directory.GetDirectories(baseFolder);
            foreach (var path in dirs)
            {
                string[] filepaths = Directory.GetFiles(path);
                if(!filepaths.Any(s => s.Contains("Results.xml")))
                {
                    continue;
                }
                string properties = File.ReadAllText(path+"/Properties.xml");
                long length = (new System.IO.FileInfo(path+"/Results.xml")).Length;
                if(properties.Contains(">500<"))
                    five.Add(length);
                else if(properties.Contains(">1000<"))
                    one.Add(length);
                else if(properties.Contains(">2000<"))
                    two.Add(length);
                
            }
            System.IO.File.WriteAllLines("c:\\five.txt",five.Select(s=> s.ToString()));
            System.IO.File.WriteAllLines("c:\\one.txt",one.Select(s=> s.ToString()));
            System.IO.File.WriteAllLines("c:\\two.txt",two.Select(s=> s.ToString()));

        }
        static void Main_(string[] args)
        {
            //Uri baseAddress = new Uri("http://www.bartarinha.com:100/BartarinhaWebservice.BartarinhaService.svc");
            Uri baseAddress = new Uri("http://localhost:8733/Design_Time_Addresses/SimulationEngine/Service1");
            BasicHttpBinding binding = new BasicHttpBinding();
            binding.MaxReceivedMessageSize = 2147483647;
            binding.SendTimeout = new TimeSpan(1, 5, 0);
            binding.ReceiveTimeout = new TimeSpan(1, 5, 0);

            binding.MaxBufferSize = 2147483647;
            //WSHttpBinding binding = new WSHttpBiding();
            EndpointAddress endpoint = new EndpointAddress(baseAddress);

            var client = new SimulationEngineService.SimulationServiceClient(binding, endpoint);
            string modelDpp = @"D:\Projects\DomainPro\trunk\SmartRedundancy.dpp";
            string modelXML = @"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancy.xml";
            string modelSim = @"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancySimList.xml";
            string langDpl = @"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\VolunteerComputing.dpl";
            string langXML = @"D:\Projects\DomainPro\trunk\Languages\VolunteerComputing\VolunteerComputing.xml";

            client.Open();

            client.LoadProjectData(ReadFile(modelDpp), ReadFile(modelXML), ReadFile(modelSim), ReadFile(langDpl), ReadFile(langXML));
            client.Close();
        }
        static string ReadFile(string filePath)
        {
            return System.IO.File.ReadAllText(filePath);
        }
        static bool zipFile(string toZipDirectory, string savePath)
        {
            try
            {
                using (ZipFile zip = new ZipFile())
                {
                    zip.UseUnicodeAsNecessary = true;  // utf-8
                    zip.AddDirectory(toZipDirectory);
                    zip.Comment = "This zip was created at " + System.DateTime.Now.ToString("G");
                    zip.Save(savePath);
                }
            }
            catch
            {
                return false;
            }
            return true;

        }
    }
}
