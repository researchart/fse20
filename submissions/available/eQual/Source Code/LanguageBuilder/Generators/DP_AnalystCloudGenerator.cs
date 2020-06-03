/*
Copyright 2013 George Edwards

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. 
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using DomainPro.Core.Types;
using DomainPro.Designer.Types;
using DomainPro.Designer.Interfaces;
using LanguageBuilder.MetaTypes;

namespace LanguageBuilder.Generators
{
    public class DP_AnalystCloudGenerator : DP_IGenerator
    {
        protected string path;
        private string fileList = "";
        protected DP_Metamodel metamodel;
        protected TextWriter writer;

        
        public string Generate(DP_AbstractModelType newMetamodel, string newPath)
        {
            if (newMetamodel.GetType() != typeof(DP_Metamodel))
            {
                return fileList;
            }
            else
            {
                metamodel = (DP_Metamodel)newMetamodel;
            }

            path = Path.Combine(newPath, "Analyst");

            Generate((DP_Metamodel)metamodel);

            foreach (DP_ConcreteType type in metamodel.Diagram.Types)
            {
                if (type.GetType() == typeof(DP_MetaClass))
                {
                    Generate((DP_MetaClass)type);
                }
            };

            return fileList;
        }

        protected void Generate(DP_Metamodel metamodel)
        {
            Directory.CreateDirectory(Path.Combine(path, "Factories"));

            string modelFactoryFile = Path.Combine(path, "Factories\\" + metamodel.Name + "ModelFactory.cs");
            fileList += "\"" + modelFactoryFile + "\" ";
            TextWriter modelFactoryWriter = File.CreateText(modelFactoryFile);

            modelFactoryWriter.WriteLine("using System;");
            modelFactoryWriter.WriteLine("using System.IO;");
            modelFactoryWriter.WriteLine("using System.Xml.Serialization;");
            modelFactoryWriter.WriteLine("using DomainPro.Core.Types;");
            modelFactoryWriter.WriteLine("using DomainPro.Core.Interfaces;");
            modelFactoryWriter.WriteLine("using DomainPro.Analyst.Types;");
            modelFactoryWriter.WriteLine("using DomainPro.Analyst.Interfaces;");
            modelFactoryWriter.WriteLine("using Analyst.Types;");
            modelFactoryWriter.WriteLine();
            modelFactoryWriter.WriteLine("namespace Analyst.Factories");
            modelFactoryWriter.WriteLine("{");
            modelFactoryWriter.WriteLine("    public class " + metamodel.Name + "ModelFactory : DP_IModelFactory");
            modelFactoryWriter.WriteLine("    {");
            modelFactoryWriter.WriteLine("        public DP_AbstractModelType CreateModel()");
            modelFactoryWriter.WriteLine("        {");
            modelFactoryWriter.WriteLine("            return new " + metamodel.Name + "Model();");
            modelFactoryWriter.WriteLine("        }");
            modelFactoryWriter.WriteLine();
            modelFactoryWriter.WriteLine("        public void SaveModel(DP_AbstractModelType model, string path)");
            modelFactoryWriter.WriteLine("        {");
            modelFactoryWriter.WriteLine("            XmlSerializer serializer = new XmlSerializer(typeof(" + metamodel.Name + "Model));");
            modelFactoryWriter.WriteLine("            TextWriter textWriter = new StreamWriter(path);");
            modelFactoryWriter.WriteLine("            serializer.Serialize(textWriter, model);");
            modelFactoryWriter.WriteLine("            textWriter.Close();");
            modelFactoryWriter.WriteLine("        }");
            modelFactoryWriter.WriteLine();
            modelFactoryWriter.WriteLine("        public DP_AbstractModelType LoadModel(string path)");
            modelFactoryWriter.WriteLine("        {");
            modelFactoryWriter.WriteLine("            XmlSerializer deserializer = new XmlSerializer(typeof(" + metamodel.Name + "Model));");
            modelFactoryWriter.WriteLine("            TextReader textReader = new StreamReader(path);");
            modelFactoryWriter.WriteLine("            " + metamodel.Name + "Model model = (" + metamodel.Name + "Model)deserializer.Deserialize(textReader);");
            modelFactoryWriter.WriteLine("            textReader.Close();");
            modelFactoryWriter.WriteLine("            return model;");
            modelFactoryWriter.WriteLine("        }");
            modelFactoryWriter.WriteLine("    }");
            modelFactoryWriter.WriteLine("}");

            modelFactoryWriter.Close();

            Directory.CreateDirectory(Path.Combine(path, "Types"));

            string modelFile = Path.Combine(path, "Types\\" + metamodel.Name + "Model.cs");
            fileList += "\"" + modelFile + "\" ";
            TextWriter modelWriter = File.CreateText(modelFile);

            modelWriter.WriteLine("using System;");
            modelWriter.WriteLine("using System.Drawing;");
            modelWriter.WriteLine("using System.Xml.Serialization;");
            modelWriter.WriteLine("using System.Windows.Forms;");
            modelWriter.WriteLine("using SimulationEngine.Types;");
            modelWriter.WriteLine();
            modelWriter.WriteLine("namespace Analyst.Types");
            modelWriter.WriteLine("{");

            foreach (DP_ConcreteType type in metamodel.Diagram.Types)
            {
                if (type.GetType() == typeof(DP_MetaClass))
                {
                    modelWriter.WriteLine("    [XmlInclude(typeof(" + type.Name + "))]");
                    modelWriter.WriteLine("    [XmlInclude(typeof(" + type.Name + "Structure))]");
                }
            }

            modelWriter.WriteLine("    [XmlInclude(typeof(" + metamodel.Name + "Structure))]");
            modelWriter.WriteLine();
            modelWriter.WriteLine("    public class " + metamodel.Name + "Model : DP_ModelType");
            modelWriter.WriteLine("    {");
            modelWriter.WriteLine();
            /*
            modelWriter.WriteLine("        public " + metamodel.Name + "Model()");
            modelWriter.WriteLine("        {");
            modelWriter.WriteLine("        }");
            modelWriter.WriteLine();
            modelWriter.WriteLine("        public " + metamodel.Name + "Model(string newName) :");
            modelWriter.WriteLine("            base(newName)");
            modelWriter.WriteLine("        {");
            modelWriter.WriteLine("            Structure = new " + metamodel.Name + "Structure();");
            modelWriter.WriteLine("        }");
            modelWriter.WriteLine();
             * */
            modelWriter.WriteLine("    }");
            modelWriter.WriteLine("}");

            modelWriter.Close();

            string structureFile = Path.Combine(path, "Types\\" + metamodel.Name + "Structure.cs");
            fileList += "\"" + structureFile + "\" ";
            TextWriter structureWriter = File.CreateText(structureFile);

            structureWriter.WriteLine("using System;");
            structureWriter.WriteLine("using System.Drawing;");
            structureWriter.WriteLine("using System.Xml.Serialization;");
            structureWriter.WriteLine("using System.Windows.Forms;");
            structureWriter.WriteLine("using SimulationEngine.Types;");
            structureWriter.WriteLine();
            structureWriter.WriteLine("namespace Analyst.Types");
            structureWriter.WriteLine("{");
            structureWriter.WriteLine("    public class " + metamodel.Name + "Structure : DP_Structure");
            structureWriter.WriteLine("    {");
            structureWriter.WriteLine("    }");
            structureWriter.WriteLine("}");

            structureWriter.Close();
        }

        protected void Generate(DP_MetaClass type)
        {
            string typeFile = Path.Combine(path, "Types\\" + type.Name + ".cs");
            fileList += "\"" + typeFile + "\" ";
            writer = File.CreateText(typeFile);

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Xml.Serialization;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.ComponentModel;");
            writer.WriteLine("using DomainPro.Core.Types;");
            writer.WriteLine("using SimulationEngine.Types;");
            writer.WriteLine("using DomainPro.Analyst.Objects;");
            writer.WriteLine();
            writer.WriteLine("namespace Analyst.Types");
            writer.WriteLine("{");
            writer.Write("    public ");
            if (type.InstanceIsAbstract == true)
            {
                writer.Write("abstract ");
            }
            writer.Write("class " + type.Name + " : ");

            bool hasBase = false;
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role2Attached == type)
                {
                    writer.WriteLine(line.Role1Attached.Name);
                    hasBase = true;
                    break;
                }
            }

            if (!hasBase)
            {
                writer.WriteLine("DP_" + type.InstanceSimulationType + "Type");
            }
            writer.WriteLine("    {");
            writer.WriteLine();

            WritePropertyDecls(type);

           // WriteReferences(type);

            /*
            if (type.simTypeProp.Value == "Component")
            {

                if (!hasBase)
                {
                    writer.WriteLine("DP_Component");
                }
                writer.WriteLine("    {");
                writer.WriteLine();
            }
            else if (type.simTypeProp.Value == "Link")
            {
                if (!hasBase)
                {
                    writer.WriteLine("DP_Link");
                }
                writer.WriteLine("    {");
                writer.WriteLine();
            }
             * */

            WriteInitialize(type);

            writer.WriteLine("    }");

            writer.WriteLine("}");

            writer.Close();

            WriteStructure(type);
        }

        protected void WriteInitialize(DP_MetaClass type)
        {
            writer.WriteLine("        public override void Initialize(DP_AbstractStructure parentStructure)");
            writer.WriteLine("        {");
            writer.WriteLine("            SimulationType = DP_SimulationType." + type.InstanceSimulationType + ";");
            writer.WriteLine("            base.Initialize(parentStructure);");
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        protected void WritePropertyDecls(DP_MetaClass type)
        {
            foreach (DP_ConcreteType propGroup in type.Diagram.Types[typeof(DP_MetaPropertyGroup)])
            {
                foreach (DP_SimpleMetaProperty prop in propGroup.Diagram.Types[typeof(DP_SimpleMetaProperty)])
                {
                    if (prop.DefaultValue != null && prop.DefaultValue != "")
                    {
                        writer.WriteLine("        private " + prop.PropertyType + " " + prop.Name + "Value = " + prop.DefaultValue + ";");
                    }
                    else
                    {
                        writer.WriteLine("        private " + prop.PropertyType + " " + prop.Name + "Value;");
                    }
                    writer.WriteLine();
                    writer.WriteLine("        [DisplayNameAttribute(\"" + prop.DisplayName + "\"),");
                    writer.WriteLine("        CategoryAttribute(\"" + propGroup.Name + "\"),");
                    if (prop.DefaultValue != null && prop.DefaultValue != "")
                    {
                        writer.WriteLine("        DefaultValueAttribute(" + prop.DefaultValue + "),");
                    }
                    writer.WriteLine("        DescriptionAttribute(\"" + prop.PropertyDescription + "\")]");
                    writer.WriteLine("        public " + prop.PropertyType + " " + prop.Name);
                    writer.WriteLine("        {");
                    writer.WriteLine("            get { return " + prop.Name + "Value; }");
                    writer.WriteLine("            set { " + prop.Name + "Value = value; }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }

            writer.WriteLine();
        }

        protected void WriteProperties(DP_MetaClass type)
        {
            foreach (DP_ConcreteType propGroup in type.Diagram.Types[typeof(DP_MetaPropertyGroup)])
            {
                /*
                foreach (DP_ConcreteType prop in propGroup.Diagram.Types[typeof(DP_SimpleMetaProperty)])
                {
                    writer.WriteLine("            " + prop.Name + "Prop = (DP_TextProperty)Properties.Find(");
                    writer.WriteLine("              delegate(DP_Property p)");
                    writer.WriteLine("            {");
                    writer.WriteLine("                return p.Name == \"" + prop.Name + "\";");
                    writer.WriteLine("            });");       

                }
                 * */
            }
        }

        protected void WriteReferences(DP_MetaClass type)
        {
            foreach (DP_Line line in type.Lines.FindAll(ReferenceLines))
            {
                if (type == line.Role1Attached)
                {
                    DP_MetaReference reference = (DP_MetaReference)line;
                    writer.WriteLine("        public " + line.Role2Attached.Name + " " + reference.Name + ";");
                }
                else if (type == line.Role2Attached)
                {
                    DP_MetaReference reference = (DP_MetaReference)line;
                    writer.WriteLine("        public " + line.Role1Attached.Name + " " + reference.Role + ";");
                }
            }
        }

        protected void WriteStructure(DP_MetaClass type)
        {
            string structureFile = Path.Combine(path, "Types\\" + type.Name + "Structure.cs");
            fileList += "\"" + structureFile + "\" ";
            writer = File.CreateText(structureFile);

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Drawing;");
            writer.WriteLine("using System.Xml.Serialization;");
            writer.WriteLine("using System.Windows.Forms;");
            writer.WriteLine("using SimulationEngine.Types;");
            writer.WriteLine();
            writer.WriteLine("namespace Analyst.Types");
            writer.WriteLine("{");
            writer.WriteLine("    public class " + type.Name + "Structure : DP_Structure");
            writer.WriteLine("    {");
            writer.WriteLine("        public " + type.Name + "Structure()");
            writer.WriteLine("        {");

            writer.WriteLine("        }");
            writer.WriteLine();

            writer.WriteLine("    }");
            writer.WriteLine("}");

            writer.Close();
        }

        private static bool PropertyGroups(DP_AbstractSemanticType type)
        {
            if (type is DP_MetaPropertyGroup)
            {
                return true;
            }

            return false;
        }

        private static bool SimpleProperties(DP_AbstractSemanticType type)
        {
            if (type is DP_SimpleMetaProperty)
            {
                return true;
            }

            return false;
        }

        private static bool InheritanceLines(DP_Line line)
        {
            if (line is DP_MetaInheritance)
            {
                return true;
            }

            return false;
        }

        private static bool ReferenceLines(DP_Line line)
        {
            if (line is DP_MetaReference)
            {
                return true;
            }

            return false;
        }
        
    }
}
