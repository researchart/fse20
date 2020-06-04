using Ionic.Zip;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Xml.Serialization;
using CloudController.DAL;
using CloudController.Models;
using DomainPro.Analyst;
using DomainPro.Analyst.Engine;
using DomainPro.Analyst.Types;
using DomainPro.Core.Types;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;


namespace CloudController.Controllers
{
    [System.Web.Mvc.Authorize]
    public class MainController : Controller
    {
        private EqualEntities entities = new EqualEntities();
        //
        // GET: /Main/
        public ActionResult Index(string guid = null)
        {
            
            ViewBag.guid = guid;
           
            return View();
        }

        [HttpPost]
        public ActionResult UploadModel(string guid)
        {

            UploadedFile file = RetrieveFileFromRequest();
            string virtualPath = SaveFile(file, guid, "Model");
            AddOrUpdateProject(guid,"Model",virtualPath);
            return Content(virtualPath);
        }

        [HttpPost]
        public ActionResult UploadLanguage(string guid)
        {
            UploadedFile file = RetrieveFileFromRequest();
            string virtualPath = SaveFile(file, guid, "Language");
            AddOrUpdateProject(guid, "Language", virtualPath);
            return Content(virtualPath);
        }

        private void AddOrUpdateProject(string guid,string type,string path)
        {
            var userId = User.Identity.GetUserId();
            var entities = new EqualEntities();
            var proj = entities.Projects.FirstOrDefault(s => s.SimGuid == guid && s.UserID == userId);
            if (proj != null)
            {
                switch (type)
                {
                    case "Model":
                        proj.ModelName =
                            path.Substring(path.LastIndexOf("\\", StringComparison.Ordinal) + 1).Replace(".zip", "");
                        proj.Status = StatusModel.UploadedModelFile(proj.Status);
                        break;
                    case "Language":
                        proj.LanguageName =
                            path.Substring(path.LastIndexOf("\\", StringComparison.Ordinal) + 1).Replace(".zip", "");
                        proj.Status = StatusModel.UploadedLanguageFile(proj.Status);
                        break;
                }
            }
            else
            {
                string name = path.Substring(path.LastIndexOf("\\", StringComparison.Ordinal) + 1).Replace(".zip", "");
                int stat = (type== "Language")?StatusModel.UploadedLanguageFile(1) : StatusModel.UploadedModelFile(1);
                entities.Projects.Add(new Project()
                {
                    UserID = userId,
                    DateAdded = DateTime.Now,
                    LanguageName = (type=="Language")?name :null,
                    ModelName =  (type=="Model")?name :null,
                    SimGuid =  guid,
                    Status =  stat
                });
            }
            entities.SaveChanges();


        }

        public ActionResult DeleteProject(int id)
        {

            try
            {
                var entities = new EqualEntities();
                var proj = entities.Projects.Find(id);
                entities.Projects.Remove(proj);
                entities.SaveChanges();
                return Json(true, JsonRequestBehavior.AllowGet);
            }
            catch (Exception)
            {
                return Json(false, JsonRequestBehavior.AllowGet);
                throw;
            }
        }
        private string SaveFile(UploadedFile file, string guid, string type)
        {
            System.IO.FileStream stream = null;
            string virtualPath;
            try
            {

                virtualPath = String.Format("{0}\\{1}\\{2}\\", Server.MapPath("~/SimulationFiles"), guid, type);
                if (!Directory.Exists(virtualPath))
                {
                    Directory.CreateDirectory(virtualPath);
                }
                var path = System.IO.Path.Combine(virtualPath, file.Filename);
                virtualPath = virtualPath + file.Filename;
                stream = new System.IO.FileStream(path, System.IO.FileMode.Create, System.IO.FileAccess.Write);
                if (stream.CanWrite)
                {
                    stream.Write(file.Contents, 0, file.Contents.Length);
                }
            }
            finally
            {
                if (stream != null)
                {
                    stream.Close();
                }
            }
            return virtualPath;
        }

        private UploadedFile RetrieveFileFromRequest()
        {
            string filename = null;
            string fileType = null;
            byte[] fileContents = null;

            if (Request.Files.Count > 0)
            {
                //we are uploading the old way
                var file = Request.Files[0];
                fileContents = new byte[file.ContentLength];
                file.InputStream.Read(fileContents, 0, file.ContentLength);
                fileType = file.ContentType;
                filename = file.FileName;
            }
            else if (Request.ContentLength > 0)
            {
                // Using FileAPI the content is in Request.InputStream!!!!
                fileContents = new byte[Request.ContentLength];
                Request.InputStream.Read(fileContents, 0, Request.ContentLength);
                filename = Request.Headers["X-File-Name"];
                fileType = Request.Headers["X-File-Type"];
            }

            return new UploadedFile()
            {
                Filename = filename,
                ContentType = fileType,
                FileSize = fileContents != null ? fileContents.Length : 0,
                Contents = fileContents
            };
        }

        //start simulation should be refactored to something else like extract model properties
        [HttpGet]
        public ActionResult ExtractModelInformation(string guid)
        {

            DomainProAnalyst app = new DomainProAnalyst(Server.MapPath("~/SimulationFiles"));
            app.LoadProjectForCloud(RetrieveModelDppFile(guid),
                RetrieveLanguageDplFile(guid));
            var sims = app.LoadedSimulations;
            app.LoadModelAssembly();

            RetrieveAndSaveModelWatchedTypes(guid,app);
            
            var retrievedProps = RetrieveAndSaveModelProperties(guid,app.ModelType);
            
            return Json(retrievedProps, JsonRequestBehavior.AllowGet);
        }

        private void RetrieveAndSaveModelWatchedTypes(string guid, DomainProAnalyst app)
        {
            List<QualityAttributeMappingModel> list = new   List<QualityAttributeMappingModel>();
            
            foreach (var item in app.SelectedSimulation.Watched)
            {
                DP_AbstractSemanticType type = app.ModelType.FindTypeByFullName(item.Type);
                WatchedTypeKinds kind=WatchedTypeKinds.Data;
                if(type is DP_ComponentType)
                {
                    kind = WatchedTypeKinds.Component;
                }
                else if (type is DP_DataType)
                {
                   kind = WatchedTypeKinds.Data;
                }
                else if (type is DP_ResourceType)
                {
                   kind=WatchedTypeKinds.Resource;
                }
                else if (type is DP_MethodType)
                {
                    kind = WatchedTypeKinds.Method;
                }
                else
                {
                    throw new Exception("Watched type is not recognizable");
                }
                list.Add(new QualityAttributeMappingModel()
                {
                    WatchedType = item.Type,
                    SerieType =  new SeriesType()
                    {
                        WatchedTypeKind = kind,
                        
                    },
                    QA = new  QualityAttribute(),
                    Relation = new QualityWatchedTypeRelationship()
                    {
                        RelationDirection = QualityWatchedTypeRelationship.Direction.Direct
                    },
                    ImportanceCoefficient = 1
                });
            }
            MonitorViewModel.SaveQAs(guid, list);

        }

        private void SaveProperties(string guid, List<PropertyModel> list)
        {
            XmlSerializer serializer = new XmlSerializer(typeof (List<PropertyModel>));
            string savePath = Server.MapPath("~/SimulationFiles") + "/" + guid + "/Properties/";
            if (!Directory.Exists(savePath))
            {
                Directory.CreateDirectory(savePath);
            }
            TextWriter textWriter = new StreamWriter(savePath + "Properties.xml");
            serializer.Serialize(textWriter, list);
            textWriter.Close();
        }

        private List<PropertyModel> ReadProperties(string guid)
        {
            string path = Server.MapPath("~/SimulationFiles") + "/" + guid + "/Properties/" + "Properties.xml";
            XmlSerializer deserializer = new XmlSerializer(typeof (List<PropertyModel>));
            TextReader textReader = new StreamReader(path);
            List<PropertyModel> simList = (List<PropertyModel>) deserializer.Deserialize(textReader);
            textReader.Close();
            return simList;
        }

        [HttpPost]
        public ActionResult UpdateProperties(string guid)
        {
            var req = Request.Params;
            //deserialize property
            var list = ReadProperties(guid);
            //read the params in lowerBound[i] upperBound[i] save to property[i] 
            for (int i = 0; i < list.Count; i++)
            {
                string lower = "lowerBound" + i, upper = "upperBound" + i, distribution = "distribution" + i;
                list[i].LowerBound = req[lower];
                list[i].Upperbound = req[upper];
                list[i].Distribution = req[distribution];
            }
            //serialize and save the new file
            SaveProperties(guid, list);
            GenerateSimulationOverrides(guid);
            //SendFilesToNodesPool(guid);
            return Content("success");
        }

        private List<PropertyModel> RetrieveAndSaveModelProperties(string guid, DP_ModelType model)
        {
            List<PropertyModel> results = new List<PropertyModel>();
            var properties = model.GetType().GetProperties();
            foreach (DP_ConcreteType type in model.Structure.Types)
            {
                RetrieveSubModelProperties(type, results);
            }
            //saveing the results to guid/Properties/Properties.xml
            SaveProperties(guid, results);
            //return results
            return results;
        }

        private void RetrieveSubModelProperties(DP_ConcreteType type, List<PropertyModel> results)
        {
            // find the properties in type and add them to list 
            var props = type.GetType().GetProperties();
            foreach (var prop in props)
            {
                var attrs = prop.GetCustomAttributes(true);
                object defaultValue = null;
                var cattAttrs = from attr in attrs where (attr as CategoryAttribute != null) select attr;
                var defValAttrs = from attr in attrs where (attr as DefaultValueAttribute != null) select attr;
                if (cattAttrs.Any() && (cattAttrs.First() as CategoryAttribute).Category == "Parameters")
                {
                    defaultValue = (defValAttrs.First() as DefaultValueAttribute).Value;
                    var property = prop.Name;
                    var typeFullName = type.FullName;
                    var primitiveType = prop.PropertyType;
                    results.Add(new PropertyModel()
                    {
                        PrimitiveType = primitiveType.ToString(),
                        Property = property,
                        Type = typeFullName,
                        DefaultValue = defaultValue
                    });
                }
            }
            foreach (DP_ConcreteType subtype in type.Structure.Types)
            {

                RetrieveSubModelProperties(subtype, results);
            }
        }

        private string RetrieveModelDppFile(string guid)
        {
            string modDirectory = String.Format("{0}\\{1}\\{2}", Server.MapPath("~/SimulationFiles"), guid, "Model");
            string[] modFiles = Directory.GetFiles(modDirectory, "*.zip");
            using (ZipFile zip = new ZipFile(modFiles[0]))
            {
                if (!Directory.Exists(modFiles[0].Substring(0, modFiles[0].IndexOf(".zip"))))
                    zip.ExtractAll(modDirectory, ExtractExistingFileAction.OverwriteSilently);

            }
            string modelDPPFile = Directory.GetFiles(modDirectory, "*.dpp")[0];

            //---- fixing the root folder for model file
            StringBuilder result = new StringBuilder();

            if (System.IO.File.Exists(modelDPPFile))
            {
                using (StreamReader streamReader = new StreamReader(modelDPPFile))
                {
                    String line;
                    while ((line = streamReader.ReadLine()) != null)
                    {
                        string newLine = line;
                        if (line.IndexOf("Root", StringComparison.Ordinal) == 0 && line.IndexOf("\\") != -1)
                        {
                            string name = line.Substring(line.LastIndexOf("\\") + 1);
                            newLine = "Root " + name;
                        }
                        result.AppendLine(newLine);
                    }
                }
            }
            using (FileStream fileStream = new FileStream(modelDPPFile, FileMode.Create, FileAccess.ReadWrite))
            {
                StreamWriter streamWriter = new StreamWriter(fileStream);
                streamWriter.Write(result);
                streamWriter.Close();
                fileStream.Close();
            }
            // -- endof fixing the root folder for model file

            return modelDPPFile;
        }

        private string RetrieveLanguageDplFile(string guid)
        {
            string langDirectory = String.Format("{0}\\{1}\\{2}", Server.MapPath("~/SimulationFiles"), guid, "Language");
            string[] langFiles = Directory.GetFiles(langDirectory, "*.zip");
            using (ZipFile zip = new ZipFile(langFiles[0]))
            {
                if (!Directory.Exists(langFiles[0].Substring(0, langFiles[0].IndexOf(".zip"))))
                    zip.ExtractAll(langDirectory, ExtractExistingFileAction.OverwriteSilently);
            }
            string dplDirectory = Directory.GetDirectories(langDirectory)[0];
            string langDPLFile = Directory.GetFiles(dplDirectory, "*.dpl")[0];
            return langDPLFile;

        }

        private void GenerateSimulationOverrides(string guid)
        {
            var res = new List<List<PropertyOverride>>();
            var list = ReadProperties(guid);
            GenerateCombinations(res, list, null, 0);
            //save combinations to folders
            SaveSimulationOverrides(res, guid);
            //return Json(res,JsonRequestBehavior.AllowGet);
        }

        private void GenerateCombinations(List<List<PropertyOverride>> combinations, List<PropertyModel> props,
            PropertyOverride parent, int level)
        {
            if (level >= props.Count)
            {
                // add the current path to the combinations list 
                var list = new List<PropertyOverride>();
                while (parent != null)
                {
                    list.Add(parent);
                    parent = parent.Parent;
                }
                combinations.Add(list);
                return;
            }

            var currentProp = props[level];
            var min = currentProp.LowerBound;
            var max = currentProp.Upperbound;
            var set = new object[] {min, max};
            foreach (var item in set)
            {
                var pom = new PropertyOverride()
                {
                    Parent = parent,
                    Property = currentProp.Property,
                    Type = currentProp.Type,
                    Value = ConvertValueToType(item,currentProp.PrimitiveType),
                    PrimitiveType = currentProp.PrimitiveType
                };
                GenerateCombinations(combinations, props, pom, level + 1);
            }
        }

        private void SaveSimulationOverrides(List<List<PropertyOverride>> list, string guid)
        {

            foreach (var item in list.Select((value, i) => new {i, value}))
            {
                XmlSerializer serializer = new XmlSerializer(typeof (List<PropertyOverride>));
                string savePath = Server.MapPath("~/SimulationFiles") + "/" + guid + "/Simulations/" + item.i + "/";
                if (!Directory.Exists(savePath))
                {
                    Directory.CreateDirectory(savePath);
                }
                using (TextWriter textWriter = new StreamWriter(savePath + "Properties.xml"))
                {
                    serializer.Serialize(textWriter, item.value);
                    textWriter.Close();
                }
            }
        }

        public class UploadedFile
        {
            public int FileSize { get; set; }
            public string Filename { get; set; }
            public string ContentType { get; set; }
            public byte[] Contents { get; set; }
        }

        public async Task<ViewResult> List()
        {
            var user = await (new UserManager<EqualUser>(new UserStore<EqualUser>(new EqualDbContext()))).FindByIdAsync( User.Identity.GetUserId());
            var projects = from items in entities.Projects where items.UserID == user.Id select items;
            return View(projects);
        }

        private object ConvertValueToType(object value, string type)
        {
            if (type.Contains("Double"))
                return Convert.ChangeType(value, TypeCode.Double);
            else
            {
                return Convert.ChangeType(value, TypeCode.Int32);
            }
        }
    }
}