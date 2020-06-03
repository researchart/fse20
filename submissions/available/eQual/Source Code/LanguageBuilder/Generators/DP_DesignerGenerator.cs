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
    public class DP_DesignerGenerator : DP_IGenerator
    {
        private string path;
        private string fileList = "";
        private DP_Metamodel metamodel;
        private TextWriter writer;

        public string Generate(DP_AbstractModelType newMetamodel, string newPath)
        {
            if (newMetamodel.GetType() != typeof(DP_Metamodel))
            {
                return fileList;
            }
            else
            {
                metamodel = (DP_Metamodel) newMetamodel;
            }

            path = Path.Combine(newPath, "Designer");

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

            /*
            TextWriter genFactoryWriter = File.CreateText(path + "\\DP_Factories\\" + metamodel.Name + "GeneratorFactory.cs");

            genFactoryWriter.WriteLine("using System;");
            genFactoryWriter.WriteLine("using DomainPro.Interfaces;");
            genFactoryWriter.WriteLine();
            genFactoryWriter.WriteLine("namespace Designer.Factories");
            genFactoryWriter.WriteLine("{");
            genFactoryWriter.WriteLine("    class " + metamodel.Name + "GeneratorFactory : DP_IGeneratorFactory");
            genFactoryWriter.WriteLine("    {");
            genFactoryWriter.WriteLine("        public DP_IGenerator CreateGenerator()");
            genFactoryWriter.WriteLine("        {");
            genFactoryWriter.WriteLine("            return null;");
            genFactoryWriter.WriteLine("        }");
            genFactoryWriter.WriteLine("    }");
            genFactoryWriter.WriteLine("}");

            genFactoryWriter.Close();
             * */

            string modelFactoryFile = Path.Combine(path, "Factories\\" + metamodel.Name + "ModelFactory.cs");
            fileList += "\"" + modelFactoryFile + "\" ";
            TextWriter modelFactoryWriter = File.CreateText(modelFactoryFile);

            modelFactoryWriter.WriteLine("using System;");
            modelFactoryWriter.WriteLine("using System.IO;");
            modelFactoryWriter.WriteLine("using System.Xml.Serialization;");
            modelFactoryWriter.WriteLine("using DomainPro.Core.Types;");
            modelFactoryWriter.WriteLine("using DomainPro.Core.Interfaces;");
            modelFactoryWriter.WriteLine("using DomainPro.Designer.Types;");
            modelFactoryWriter.WriteLine("using DomainPro.Designer.Interfaces;");
            modelFactoryWriter.WriteLine("using Designer.Types;");
            modelFactoryWriter.WriteLine();
            modelFactoryWriter.WriteLine("namespace Designer.Factories");
            modelFactoryWriter.WriteLine("{");
            modelFactoryWriter.WriteLine("    public class " + metamodel.Name + "ModelFactory : DP_IModelFactory");
            modelFactoryWriter.WriteLine("    {");
            modelFactoryWriter.WriteLine("        public DP_AbstractModelType CreateModel()");
            modelFactoryWriter.WriteLine("        {");
            modelFactoryWriter.WriteLine("            return new " + metamodel.Name + "Model(\"New" + metamodel.Name + "\");");
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
            modelWriter.WriteLine("using DomainPro.Core.Types;");
            modelWriter.WriteLine("using DomainPro.Designer.Types;");
            modelWriter.WriteLine();
            modelWriter.WriteLine("namespace Designer.Types");
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
            modelWriter.WriteLine("        public " + metamodel.Name + "Model()");
            modelWriter.WriteLine("        {");
            modelWriter.WriteLine("        }");
            modelWriter.WriteLine();
            modelWriter.WriteLine("        public " + metamodel.Name + "Model(string newName)");
            modelWriter.WriteLine("        {");
            modelWriter.WriteLine("            name = newName;");
            modelWriter.WriteLine("            Diagram = new " + metamodel.Name + "Structure();");
            modelWriter.WriteLine("            Text = new DP_Text();");
            modelWriter.WriteLine("            DP_AbstractText.Instruction init = new DP_AbstractText.Instruction();");
            modelWriter.WriteLine("            init.Name = \"Initialize\";");
            modelWriter.WriteLine("            init.String = \"\";");
            modelWriter.WriteLine("            Text.Instructions.Add(init);");
            modelWriter.WriteLine();
            modelWriter.WriteLine("        }");
            modelWriter.WriteLine();
            modelWriter.WriteLine("    }");
            modelWriter.WriteLine("}");

            modelWriter.Close();

            string diagramFile = Path.Combine(path, "Types\\" + metamodel.Name + "Structure.cs");
            fileList += "\"" + diagramFile + "\" ";
            TextWriter diagramWriter = File.CreateText(diagramFile);

            diagramWriter.WriteLine("using System;");
            diagramWriter.WriteLine("using System.Drawing;");
            diagramWriter.WriteLine("using System.Xml.Serialization;");
            diagramWriter.WriteLine("using System.Windows.Forms;");
            diagramWriter.WriteLine("using DomainPro.Designer;");
            diagramWriter.WriteLine("using DomainPro.Designer.Types;");
            diagramWriter.WriteLine();
            diagramWriter.WriteLine("namespace Designer.Types");
            diagramWriter.WriteLine("{");
            diagramWriter.WriteLine("    public class " + metamodel.Name + "Structure : DP_Diagram");
            diagramWriter.WriteLine("    {");
            diagramWriter.WriteLine("        public " + metamodel.Name + "Structure()");
            diagramWriter.WriteLine("        {");

            //List<DP_AbstractSemanticType> rootShapes = FindAll(RootShapes);

            foreach (DP_MetaClass shape in metamodel.Diagram.Types[typeof(DP_MetaClass)])
            {
                if (
                    shape.InstanceIsRoot == true &&
                    shape.InstanceIsAbstract == false &&
                    shape.InstancePresentationType == DP_ConcreteType.DP_PresentationType.Shape
                    )
                {
                    diagramWriter.WriteLine("            availableShapes.Add(\"" + shape.Name + "\");");
                }
            }

            //List<DP_AbstractSemanticType> rootLines = metamodel.Diagram.Types.FindAll(RootLines);

            foreach (DP_MetaClass line in metamodel.Diagram.Types[typeof(DP_MetaClass)])
            {
                if (
                    line.InstanceIsRoot == true &&
                    line.InstanceIsAbstract == false &&
                    line.InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line
                    )
                {
                    diagramWriter.WriteLine("            availableLines.Add(\"" + line.Name + "\");");
                }
            }

            diagramWriter.WriteLine();


            /*
            diagramWriter.WriteLine("            availableShapes = new string[]");
            diagramWriter.WriteLine("            {");

            List<DP_ConcreteType> rootShapes = metamodel.rootDiagram.types.FindAll(RootShapes);

            if (rootShapes.Count > 0)
            {
                for (int i = 0; i < rootShapes.Count; i++)
                {
                    diagramWriter.Write("                \"" + rootShapes[i].Name + "\"");
                        
                    if (i < rootShapes.Count - 1)
                    {
                        diagramWriter.Write(",");
                    }

                    diagramWriter.WriteLine();
                }
            }

            diagramWriter.WriteLine("            };");
            */

            diagramWriter.WriteLine("        }");
            diagramWriter.WriteLine();
            diagramWriter.WriteLine("        public override DP_Shape CreateShape(string shapeType, Point startLocation)");
            diagramWriter.WriteLine("        {");

            foreach (DP_MetaClass shape in metamodel.Diagram.Types[typeof(DP_MetaClass)])
            {
                if (
                    shape.InstanceIsRoot == true &&
                    shape.InstanceIsAbstract == false &&
                    shape.InstancePresentationType == DP_ConcreteType.DP_PresentationType.Shape
                    )
                {
                    diagramWriter.WriteLine("            if (shapeType == \"" + shape.Name + "\")");
                    diagramWriter.WriteLine("            {");
                    diagramWriter.WriteLine("                " + shape.Name + " newShape = new " + shape.Name + "(startLocation);");
                    diagramWriter.WriteLine("                newShape.Initialize(this);");
                    //diagramWriter.WriteLine("                Add(newShape);");
                    diagramWriter.WriteLine("                return newShape;");
                    diagramWriter.WriteLine("            }");
                    diagramWriter.WriteLine();
                }
            }

            diagramWriter.WriteLine();
            diagramWriter.WriteLine("            return null;");
            diagramWriter.WriteLine("        }");
            diagramWriter.WriteLine();

            diagramWriter.WriteLine("        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)");
            diagramWriter.WriteLine("        {");

            foreach (DP_MetaClass line in metamodel.Diagram.Types[typeof(DP_MetaClass)])
            {
                if (
                    line.InstanceIsRoot == true &&
                    line.InstanceIsAbstract == false &&
                    line.InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line
                    )
                {
                    diagramWriter.WriteLine("            if (lineType == \"" + line.Name + "\")");
                    diagramWriter.WriteLine("            {");
                    diagramWriter.WriteLine("                if (" + line.Name + ".ValidRoles(src.Attached, dest.Attached))");
                    diagramWriter.WriteLine("                {");
                    diagramWriter.WriteLine("                    " + line.Name + " newLine = new " + line.Name + "(src, dest);");
                    diagramWriter.WriteLine("                    newLine.Initialize(this);");
                    //diagramWriter.WriteLine("                    Add(newLine);");
                    diagramWriter.WriteLine("                    return newLine;");
                    diagramWriter.WriteLine("                }");
                    diagramWriter.WriteLine("            }");
                    diagramWriter.WriteLine();
                }
            }

            diagramWriter.WriteLine();
            diagramWriter.WriteLine("            return null;");
            diagramWriter.WriteLine("        }");
            diagramWriter.WriteLine();

            diagramWriter.WriteLine("    }");
            diagramWriter.WriteLine("}");

            diagramWriter.Close();
                
        }

        protected void Generate(DP_MetaClass type)
        {
            string typeFile = Path.Combine(path, "Types\\" + type.Name + ".cs");
            fileList += "\"" + typeFile + "\" ";
            writer = File.CreateText(typeFile);

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Drawing;");
            writer.WriteLine("using System.Drawing.Drawing2D;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.ComponentModel;");
            writer.WriteLine("using System.Drawing.Design;");
            writer.WriteLine("using System.Windows.Forms;");
            writer.WriteLine("using System.Xml.Serialization;");
            writer.WriteLine("using DomainPro.Core.Types;");
            writer.WriteLine("using DomainPro.Designer;");
            writer.WriteLine("using DomainPro.Designer.Types;");
            writer.WriteLine("using DomainPro.Designer.Controls;");
            writer.WriteLine();
            writer.WriteLine("namespace Designer.Types");
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


            if (type.InstancePresentationType == DP_MetaClass.DP_PresentationType.Shape)
            {
               
                if (!hasBase)
                {
                    writer.WriteLine("DP_Shape");
                }
                writer.WriteLine("    {");
                writer.WriteLine();

                WritePropertyDecls(type);

                WriteSemanticsPropertyDecls(type);

                writer.WriteLine("        protected override void SetParams()");
                writer.WriteLine("        {");

                writer.WriteLine("            ShapeProperties.Shape = DP_ShapeType." + type.InstanceShapeProperties.Shape + ";");
                writer.WriteLine("            ShapeProperties.DefaultSize = new Size(100, 60);");
                writer.WriteLine("            ShapeProperties.IsResizable = " + type.InstanceShapeProperties.IsResizable.ToString().ToLower() + ";");
                writer.WriteLine("            ShapeProperties.BorderStyle = DashStyle." + type.InstanceShapeProperties.BorderStyle + ";");
                writer.WriteLine("            ShapeProperties.BorderColor = Color.FromArgb(" +
                    type.InstanceShapeProperties.BorderColor.A + ", " +
                    type.InstanceShapeProperties.BorderColor.R + ", " +
                    type.InstanceShapeProperties.BorderColor.G + ", " +
                    type.InstanceShapeProperties.BorderColor.B + ");");
                writer.WriteLine("            ShapeProperties.BorderWidth = " + type.InstanceShapeProperties.BorderWidth + ";");
                writer.WriteLine("            ShapeProperties.FillColor = Color.FromArgb(" +
                    type.InstanceShapeProperties.FillColor.A + ", " +
                    type.InstanceShapeProperties.FillColor.R + ", " +
                    type.InstanceShapeProperties.FillColor.G + ", " +
                    type.InstanceShapeProperties.FillColor.B + ");");
                writer.WriteLine("            ShapeProperties.GradientFill = " + type.InstanceShapeProperties.IsResizable.ToString().ToLower() + ";");
                writer.WriteLine("            ShapeProperties.GradientFillColor = Color.FromArgb(" +
                    type.InstanceShapeProperties.GradientFillColor.A + ", " +
                    type.InstanceShapeProperties.GradientFillColor.R + ", " +
                    type.InstanceShapeProperties.GradientFillColor.G + ", " +
                    type.InstanceShapeProperties.GradientFillColor.B + ");");
                writer.WriteLine("            ShapeProperties.CornerRounding = " + type.InstanceShapeProperties.CornerRounding + ";");
                writer.WriteLine("            ShapeProperties.DockStyle = DockStyle." + type.InstanceShapeProperties.DockStyle + ";");
                writer.WriteLine("            ShapeProperties.Alignment = ContentAlignment." + type.InstanceShapeProperties.Alignment + ";");
                writer.WriteLine("            ShapeProperties.Icon = \"" + type.InstanceShapeProperties.Icon.Replace("\\", "\\\\") + "\";");
                writer.WriteLine();
                writer.WriteLine("            Name = \"New" + type.Name + "\";");
                writer.WriteLine("            DisplayName = Name;");
                writer.WriteLine("            ShowName = " + type.InstanceShowName.ToString().ToLower() + ";");
                writer.WriteLine("            Hidden = " + type.InstanceHidden.ToString().ToLower() + ";");
                writer.WriteLine("            PresentationType = DP_PresentationType." + type.InstancePresentationType + ";");
                writer.WriteLine("            SimulationType = DP_SimulationType." + type.InstanceSimulationType + ";");
                writer.WriteLine(
                    "            Size = new Size(" + type.InstanceShapeProperties.DefaultSize.Width + ", " +
                    type.InstanceShapeProperties.DefaultSize.Height + ");");
                writer.WriteLine("            NameFont = new Font(\"" + type.InstanceNameFont.FontFamily.Name + "\", (float)" + type.InstanceNameFont.Size +", FontStyle." + type.InstanceNameFont.Style +");");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        public " + type.Name + "()");
                writer.WriteLine("        {");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        public " + type.Name + "(Point startLocation) :");
                writer.WriteLine("            base(startLocation)");
                writer.WriteLine("        {");
                if (!type.InstanceIsAbstract)
                {
                    writer.WriteLine("            Diagram = new " + type.Name + "Structure();");
                    writer.WriteLine("            Text = new DP_Text();");
                    WriteInstructions(type);

                }
                writer.WriteLine("        }");
                writer.WriteLine();

            }
            else if (type.InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line)
            {
                if (!hasBase)
                {
                    writer.WriteLine("DP_Line");
                }
                writer.WriteLine("    {");
                writer.WriteLine();

                WritePropertyDecls(type);

                WriteSemanticsPropertyDecls(type);

                WriteValidRoles(type);
                
                writer.WriteLine("        protected override void SetParams()");
                writer.WriteLine("        {");
                writer.WriteLine("            LineProperties.Form = DP_LineForm.Line;");
                writer.WriteLine("            LineProperties.LineWidth = " + type.InstanceLineProperties.LineWidth + ";");
                writer.WriteLine("            LineProperties.BorderStyle = DashStyle." + type.InstanceLineProperties.BorderStyle + ";");
                writer.WriteLine("            LineProperties.BorderColor = Color.FromArgb(" +
                    type.InstanceLineProperties.BorderColor.A + ", " +
                    type.InstanceLineProperties.BorderColor.R + ", " +
                    type.InstanceLineProperties.BorderColor.G + ", " +
                    type.InstanceLineProperties.BorderColor.B + ");");
                writer.WriteLine("            LineProperties.BorderWidth = " + type.InstanceLineProperties.BorderWidth + ";");
                writer.WriteLine("            LineProperties.FillStyle = DashStyle." + type.InstanceLineProperties.FillStyle + ";");
                writer.WriteLine("            LineProperties.FillColor = Color.FromArgb(" +
                    type.InstanceLineProperties.FillColor.A + ", " +
                    type.InstanceLineProperties.FillColor.R + ", " +
                    type.InstanceLineProperties.FillColor.G + ", " +
                    type.InstanceLineProperties.FillColor.B + ");");
                writer.WriteLine("            LineProperties.Role1.NameVisible = " + type.InstanceLineProperties.Role1.NameVisible.ToString().ToLower() + ";");
                writer.WriteLine("            LineProperties.Role1.Font = new Font(\"" + type.InstanceLineProperties.Role1.Font.FontFamily.Name + "\", (float)" + type.InstanceLineProperties.Role1.Font.Size + ", FontStyle." + type.InstanceLineProperties.Role1.Font.Style + ");");
                writer.WriteLine("            LineProperties.Role1.Icon = \"" + type.InstanceLineProperties.Role1.Icon.Replace("\\", "\\\\") + "\";");
                writer.WriteLine("            LineProperties.Role2.NameVisible = " + type.InstanceLineProperties.Role2.NameVisible.ToString().ToLower() + ";");
                writer.WriteLine("            LineProperties.Role2.Font = new Font(\"" + type.InstanceLineProperties.Role2.Font.FontFamily.Name + "\", (float)" + type.InstanceLineProperties.Role2.Font.Size + ", FontStyle." + type.InstanceLineProperties.Role2.Font.Style + ");");
                writer.WriteLine("            LineProperties.Role2.Icon = \"" + type.InstanceLineProperties.Role2.Icon.Replace("\\", "\\\\") + "\";");
                writer.WriteLine();
                writer.WriteLine("            Name = \"New" + type.Name + "\";");
                writer.WriteLine("            DisplayName = Name;");
                writer.WriteLine("            ShowName = " + type.InstanceShowName.ToString().ToLower() + ";");
                writer.WriteLine("            NameFont = new Font(\"" + type.InstanceNameFont.FontFamily.Name + "\", (float)" + type.InstanceNameFont.Size +", FontStyle." + type.InstanceNameFont.Style +");");
                writer.WriteLine("            PresentationType = DP_PresentationType." + type.InstancePresentationType + ";");
                writer.WriteLine("            SimulationType = DP_SimulationType." + type.InstanceSimulationType + ";");
                writer.WriteLine("            role1Name = \"" + type.InstanceRole1Name + "\";");
                writer.WriteLine("            role2Name = \"" + type.InstanceRole2Name + "\";");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        public " + type.Name + "()");
                writer.WriteLine("        {");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        public " + type.Name + "(DomainProDesigner.DP_ConnectionSpec newRole1, DomainProDesigner.DP_ConnectionSpec newRole2) :");
                writer.WriteLine("            base(newRole1, newRole2)");
                writer.WriteLine("        {");
                if (!type.InstanceIsAbstract)
                {
                    writer.WriteLine("            Diagram = new " + type.Name + "Structure();");
                    writer.WriteLine("            Text = new DP_Text();");
                    WriteInstructions(type);
                }
                writer.WriteLine("        }");
                writer.WriteLine();
            }

            WriteInitialize(type);

            if (type.InstanceIsAbstract == false)
            {
                WriteDuplicate(type);
            }

            WriteCopy(type);

            writer.WriteLine("    }");
            
            writer.WriteLine("}");

            writer.Close();

            WriteStructure(type);
        }

        protected void WriteInitialize(DP_MetaClass type)
        {
            writer.WriteLine("        public override void Initialize(DP_AbstractStructure parentDiagram)");
            writer.WriteLine("        {");
            writer.WriteLine("            base.Initialize(parentDiagram);");
            if (FindAllBaseTypes(type).Count == 0)
            {
                writer.WriteLine("            Diagram.Initialize(this);");

                /*
                if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Method)
                {
                    WriteInstructions(type);
                }
                 * */
            }
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        protected void WriteDuplicate(DP_MetaClass type)
        {
            writer.WriteLine("        public override DP_ConcreteType Duplicate()");
            writer.WriteLine("        {");
            writer.WriteLine("            " + type.Name + " newType = new " + type.Name + "();");
            writer.WriteLine("            newType.Diagram = new " + type.Name + "Structure();");
            writer.WriteLine("            newType.Text = new DP_Text();");
            writer.WriteLine("            newType.Copy(this);");
            writer.WriteLine("            return newType;");
            writer.WriteLine("        }");
            writer.WriteLine();

        }

        protected void WriteCopy(DP_MetaClass type)
        {
            writer.WriteLine("        protected override void Copy(DP_ConcreteType source)");
            writer.WriteLine("        {");
            writer.WriteLine("            if (source is " + type.Name + ")");
            writer.WriteLine("            {");
            writer.WriteLine("              base.Copy(source);");
            writer.WriteLine("              " + type.Name + " src" + type.Name + " = source as " + type.Name + ";");
            foreach (DP_ConcreteType propGroup in type.Diagram.Types[typeof(DP_MetaPropertyGroup)])
            {
                foreach (DP_SimpleMetaProperty prop in propGroup.Diagram.Types[typeof(DP_SimpleMetaProperty)])
                {
                    writer.WriteLine("              " + prop.Name + " = src" + type.Name + "." + prop.Name + ";");
                }
            }

            if (!type.InstanceIsAbstract)
            {
                if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Resource)
                {
                    writer.WriteLine("        Workers = src" + type.Name + ".Workers;");
                    writer.WriteLine("        Queues = src" + type.Name + ".Queues;");
                }
                else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Method)
                {
                    writer.WriteLine("        ResourceDependency = src" + type.Name + ".ResourceDependency;");
                    writer.WriteLine("        ResourceRequest = src" + type.Name + ".ResourceRequest;");

                }
                else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Data)
                {
                    writer.WriteLine("        ImplementationType = src" + type.Name + ".ImplementationType;");
                    writer.WriteLine("        InitialValue = src" + type.Name + ".InitialValue;");
                }
            }

            writer.WriteLine("            }");
            writer.WriteLine("        }");

        }

        private void WritePropertyDecls(DP_MetaClass type)
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
                    writer.WriteLine("        [DisplayName(\"" + prop.DisplayName + "\"),");
                    writer.WriteLine("        Category(\"" + propGroup.Name + "\"),");
                    if (prop.DefaultValue != null && prop.DefaultValue != "")
                    {
                        writer.WriteLine("        DefaultValue(" + prop.DefaultValue + "),");
                    }
                    if (prop.PropertyType.Contains("<string>") || prop.PropertyType.Contains("<String>") ||
                        prop.PropertyType.Contains("<System.String>"))
                    {
                        writer.WriteLine("        Editor(\"System.Windows.Forms.Design.StringCollectionEditor, System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a\", typeof(UITypeEditor)),");
                    }
                    writer.WriteLine("        Description(\"" + prop.PropertyDescription + "\")]");
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

        private void WriteInstructions(DP_MetaClass type)
        {
            if (type.InstanceIsAbstract)
            {
                return;
            }

            if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Component)
            {
                writer.WriteLine("            DP_AbstractText.Instruction startup = new DP_AbstractText.Instruction();");
                writer.WriteLine("            startup.Name = \"Startup\";");
                writer.WriteLine("            startup.String = \"\";");
                writer.WriteLine("            Text.Instructions.Add(startup);");
                writer.WriteLine();
            }
            else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Method)
            {
                writer.WriteLine("            DP_AbstractText.Instruction run = new DP_AbstractText.Instruction();");
                writer.WriteLine("            run.Name = \"Run\";");
                writer.WriteLine("            run.String = \"\";");
                writer.WriteLine("            Text.Instructions.Add(run);");
                writer.WriteLine();
                writer.WriteLine("            DP_AbstractText.Instruction duration = new DP_AbstractText.Instruction();");
                writer.WriteLine("            duration.Name = \"Duration\";");
                writer.WriteLine("            duration.String = \"return 0;\\n\";");
                writer.WriteLine("            Text.Instructions.Add(duration);");
                writer.WriteLine();
            }
            else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Flow)
            {
                writer.WriteLine("            DP_AbstractText.Instruction trigger = new DP_AbstractText.Instruction();");
                writer.WriteLine("            trigger.Name = \"Trigger\";");
                writer.WriteLine("            trigger.String = \"return false;\\n\";");
                writer.WriteLine("            Text.Instructions.Add(trigger);");
                writer.WriteLine();
                writer.WriteLine("            DP_AbstractText.Instruction transfer = new DP_AbstractText.Instruction();");
                writer.WriteLine("            transfer.Name = \"Transfer\";");
                writer.WriteLine("            transfer.String = \"\";");
                writer.WriteLine("            Text.Instructions.Add(transfer);");
                writer.WriteLine();
                writer.WriteLine("            DP_AbstractText.Instruction resolve = new DP_AbstractText.Instruction();");
                writer.WriteLine("            resolve.Name = \"Resolve\";");
                writer.WriteLine("            resolve.String = \"return Context;\";");
                writer.WriteLine("            Text.Instructions.Add(resolve);");
                writer.WriteLine();
            }
        }

        private void WriteSemanticsPropertyDecls(DP_MetaClass type)
        {
            if (type.InstanceIsAbstract)
            {
                return;
            }

            if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Resource)
            {
                writer.WriteLine("        private List<DP_Worker> workers = new List<DP_Worker>();");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Workers\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        Description(\"A list of workers provided by the resource.\")]");
                writer.WriteLine("        public List<DP_Worker> Workers");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return workers; }");
                writer.WriteLine("            set { workers = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        private List<DP_Queue> queues = new List<DP_Queue>();");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Queues\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        Description(\"A list of job categories handled by the resource.\")]");
                writer.WriteLine("        public List<DP_Queue> Queues");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return queues; }");
                writer.WriteLine("            set { queues = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
                /*
                writer.WriteLine("        private string capacity = \"1\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Capacity\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"1\"),");
                writer.WriteLine("        Description(\"Sets the capacity of the resource.\")]");
                writer.WriteLine("        public string Capacity");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return capacity; }");
                writer.WriteLine("            set { capacity = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();

                writer.WriteLine("        private string velocity = \"1.0\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Velocity\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"1.0\"),");
                writer.WriteLine("        Description(\"Sets the velocity of the resource.\")]");
                writer.WriteLine("        public string Velocity");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return velocity; }");
                writer.WriteLine("            set { velocity = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
                 * */
            }
            if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Method)
            {
                writer.WriteLine("        private string resourceDependency = \"\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Resource Dependency\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"\"),");
                writer.WriteLine("        Description(\"Sets the resource on which the type depends.\")]");
                writer.WriteLine("        public string ResourceDependency");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return resourceDependency; }");
                writer.WriteLine("            set { resourceDependency = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        private string resourceRequest = \"\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Resource Request\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"\"),");
                writer.WriteLine("        Description(\"Sets the type of work requested of the resource.\")]");
                writer.WriteLine("        public string ResourceRequest");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return resourceRequest; }");
                writer.WriteLine("            set { resourceRequest = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();

            }
            else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Data)
            {
                writer.WriteLine("        private string implementationType = \"\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Implementation Type\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"\"),");
                writer.WriteLine("        Description(\"Sets the type of implementation object used to store the data.\")]");
                writer.WriteLine("        public string ImplementationType");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return implementationType; }");
                writer.WriteLine("            set { implementationType = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
                writer.WriteLine("        private string initialValue = \"\";");
                writer.WriteLine();
                writer.WriteLine("        [DisplayName(\"Initial Value\"),");
                writer.WriteLine("        Category(\"Simulation\"),");
                writer.WriteLine("        DefaultValue(\"\"),");
                writer.WriteLine("        Description(\"Sets the initial value of the data.\")]");
                writer.WriteLine("        public string InitialValue");
                writer.WriteLine("        {");
                writer.WriteLine("            get { return initialValue; }");
                writer.WriteLine("            set { initialValue = value; }");
                writer.WriteLine("        }");
                writer.WriteLine();
            }
            else if (type.InstanceSimulationType == DP_AbstractSemanticType.DP_SimulationType.Flow)
            {

            }

            writer.WriteLine();
        }

        private void WriteAvailableShapes(DP_MetaClass type)
        {
            foreach (DP_MetaClass shape in FindContainedShapes(type))
            {
                if (!shape.InstanceIsAbstract)
                {
                    writer.WriteLine("            availableShapes.Add(\"" + shape.Name + "\");");
                }
            }

            writer.WriteLine();
        }

        private void WriteAvailableLines(DP_MetaClass type)
        {
            foreach (DP_MetaClass line in FindContainedLines(type))
            {
                writer.WriteLine("            availableLines.Add(\"" + line.Name + "\");");
            }

            writer.WriteLine();
        }

        private void WriteValidRoles(DP_MetaClass type)
        {
            writer.WriteLine("        public static new bool ValidRoles(DP_ConcreteType newSource, DP_ConcreteType newDest)");
            writer.WriteLine("        {");
            writer.WriteLine("            if (newSource == null || CanBeRole1(newSource))");
            writer.WriteLine("            {");
            writer.WriteLine("                if (newDest == null || CanBeRole2(newDest))");
            writer.WriteLine("                    return true;");
            writer.WriteLine("            }");
            writer.WriteLine("            if (newDest == null || CanBeRole1(newDest))");
            writer.WriteLine("            {");
            writer.WriteLine("                if (newSource == null || CanBeRole2(newSource))");
            writer.WriteLine("                    return true;");
            writer.WriteLine("            }");
            if (FindAllBaseTypes(type).Count == 0)
            {
                writer.WriteLine("            return false;");
            }
            else
            {
                writer.WriteLine("            bool validRoles = false;");
                foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
                {
                    if (line.Role2Attached == type)
                    {
                        writer.WriteLine("            validRoles = validRoles || " + line.Role1Attached.Name + ".ValidRoles(newSource, newDest);");
                    }
                }
                writer.WriteLine("            return validRoles;");
            }
            writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        private static bool CanBeRole1(DP_ConcreteType endpoint)");
            writer.WriteLine("        {");

            foreach (DP_Line role1Assoc in type.Lines.FindAll(delegate(DP_Line line)
            {
                if (line.GetType() == typeof(DP_MetaReference))
                {
                    return ((DP_MetaReference)line).Role == type.InstanceRole1Name;
                }
                else
                {
                    return false;
                }
            }))
            {
                writer.WriteLine("            if (endpoint is " + role1Assoc.Role1Attached.Name + ")");
                writer.WriteLine("            {");
                writer.WriteLine("                return true;");
                writer.WriteLine("            }");
            }

            writer.WriteLine("            return false;");
            writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        private static bool CanBeRole2(DP_ConcreteType endpoint)");
            writer.WriteLine("        {");

            foreach (DP_Line role1Assoc in type.Lines.FindAll(delegate(DP_Line line)
            {
                if (line.GetType() == typeof(DP_MetaReference))
                {
                    return ((DP_MetaReference)line).Role == type.InstanceRole2Name;
                }
                else
                {
                    return false;
                }
            }))
            {
                writer.WriteLine("            if (endpoint is " + role1Assoc.Role1Attached.Name + ")");
                writer.WriteLine("            {");
                writer.WriteLine("                return true;");
                writer.WriteLine("            }");
            }

            writer.WriteLine("            return false;");
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        private void WriteCreateLine(DP_MetaClass type)
        {
            writer.WriteLine("        public override DP_Line CreateLine(string lineType, DomainProDesigner.DP_ConnectionSpec src, DomainProDesigner.DP_ConnectionSpec dest)");
            writer.WriteLine("        {");

            foreach (DP_MetaClass line in FindContainedLines(type))
            {
                if (line.InstanceIsAbstract == false)
                {
                    writer.WriteLine("            if (lineType == \"" + line.Name + "\")");
                    writer.WriteLine("            {");
                    writer.WriteLine("                if (" + line.Name + ".ValidRoles(src.Attached, dest.Attached))");
                    writer.WriteLine("                {");
                    writer.WriteLine("                    " + line.Name + " newLine = new " + line.Name + "(src, dest);");
                    writer.WriteLine("                    newLine.Initialize(this);");
                    writer.WriteLine("                    return newLine;");
                    writer.WriteLine("                }");
                    writer.WriteLine("            }");
                    writer.WriteLine();
                }
            }

            bool hasBase = false;
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role2Attached == type)
                {
                    writer.WriteLine("            return base.CreateLine(lineType, src, dest);");
                    hasBase = true;
                    break;
                }
            }

            if (!hasBase)
            {
                writer.WriteLine("            return null;");
            }
            
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        private void WriteCreateShape(DP_MetaClass type)
        {
            writer.WriteLine("        public override DP_Shape CreateShape(string shapeType, Point startLocation)");
            writer.WriteLine("        {");

            foreach (DP_MetaClass containedShape in FindContainedShapes(type))
            {
                if (containedShape.InstanceIsAbstract == false)
                {
                    writer.WriteLine("            if (shapeType == \"" + containedShape.Name + "\")");
                    writer.WriteLine("            {");
                    writer.WriteLine("                " + containedShape.Name + " newShape = new " + containedShape.Name + "(startLocation);");
                    writer.WriteLine("                newShape.Initialize(this);");
                    writer.WriteLine("                return newShape;");
                    writer.WriteLine("            }");
                    writer.WriteLine();
                }
            }


            bool hasBase = false;
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role2Attached == type)
                {
                    writer.WriteLine("            return base.CreateShape(shapeType, startLocation);");
                    hasBase = true;
                    break;
                }
            }

            if (!hasBase)
            {
                writer.WriteLine("            return null;");
            }
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        private void WriteStructure(DP_MetaClass type)
        {
            string structureFile = Path.Combine(path, "Types\\" + type.Name + "Structure.cs");
            fileList += "\"" + structureFile + "\" ";
            writer = File.CreateText(structureFile);

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Drawing;");
            writer.WriteLine("using System.Xml.Serialization;");
            writer.WriteLine("using System.Windows.Forms;");
            writer.WriteLine("using DomainPro.Designer;");
            writer.WriteLine("using DomainPro.Designer.Types;");
            writer.WriteLine();
            writer.WriteLine("namespace Designer.Types");
            writer.WriteLine("{");
            writer.Write("    public class " + type.Name + "Structure : ");

            bool hasBase = false;
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role2Attached == type)
                {
                    writer.WriteLine(line.Role1Attached.Name + "Structure");
                    hasBase = true;
                    break;
                }
            }

            if (!hasBase)
            {
                writer.WriteLine("DP_Diagram");
            }

            writer.WriteLine("    {");
            writer.WriteLine("        public " + type.Name + "Structure()");
            writer.WriteLine("        {");

            WriteAvailableShapes(type);
            WriteAvailableLines(type);

            writer.WriteLine("        }");
            writer.WriteLine();

            WriteCreateShape(type);

            WriteCreateLine(type);

            writer.WriteLine("    }");
            writer.WriteLine("}");

            writer.Close();
        }

        private List<DP_MetaClass> FindAllBaseTypes(DP_MetaClass type)
        {
            List<DP_MetaClass> baseTypes = new List<DP_MetaClass>();
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role2Attached == type)
                {
                    baseTypes.Add((DP_MetaClass)line.Role1Attached);
                    baseTypes.AddRange(FindAllBaseTypes((DP_MetaClass)line.Role1Attached));
                }
            }
            return baseTypes;
        }

        private List<DP_MetaClass> FindAllSubtypes(DP_MetaClass type)
        {
            List<DP_MetaClass> subtypes = new List<DP_MetaClass>();
            foreach (DP_Line line in type.Lines.FindAll(InheritanceLines))
            {
                if (line.Role1Attached == type)
                {
                    subtypes.Add((DP_MetaClass)line.Role2Attached);
                    subtypes.AddRange(FindAllSubtypes((DP_MetaClass)line.Role2Attached));
                }
            }
            return subtypes;
        }

        // Returns all contained shapes and subtypes of contained shapes
        private List<DP_MetaClass> FindContainedShapes(DP_MetaClass type)
        {
            List<DP_MetaClass> shapes = new List<DP_MetaClass>();

            foreach (DP_Line line in type.Lines.FindAll(ContainmentLinesToShapes))
            {
                if (line.Role2Attached == type)
                {
                    if (((DP_MetaClass)line.Role1Attached).InstanceIsAbstract == false)
                    {
                        shapes.Add((DP_MetaClass)line.Role1Attached);
                    }
                    shapes.AddRange(FindAllSubtypes((DP_MetaClass)line.Role1Attached));
                }
            }

            return shapes;
        }

        // Returns all contained lines and subtypes of contained lines
        private List<DP_MetaClass> FindContainedLines(DP_MetaClass type)
        {
            List<DP_MetaClass> lines = new List<DP_MetaClass>();

            foreach (DP_Line line in type.Lines.FindAll(ContainmentLinesToLines))
            {
                if (line.Role2Attached == type)
                {
                    if (((DP_MetaClass)line.Role1Attached).InstanceIsAbstract == false)
                    {
                        lines.Add((DP_MetaClass)line.Role1Attached);
                    }
                    lines.AddRange(FindAllSubtypes((DP_MetaClass)line.Role1Attached));
                }
            }

            return lines;
        }

        // Returns all contained shapes, subtypes of contained shapes, contained shapes of base types, and subtypes of contained shapes of base types
        /*
        private List<DP_MetaClass> FindAllContainedShapes(DP_MetaClass type)
        {
            List<DP_MetaClass> shapes = new List<DP_MetaClass>();

            shapes.AddRange(FindContainedShapes(type));

            foreach (DP_MetaClass basetype in FindAllBaseTypes(type))
            {
                shapes.AddRange(FindContainedShapes(basetype));
            }

            return shapes;
        }
         * */

        private List<DP_MetaClass> FindReferencedLines(DP_MetaClass type)
        {
            List<DP_MetaClass> referencedLines = new List<DP_MetaClass>();

            foreach (DP_Line line in type.Lines.FindAll(ReferenceLinesToLines))
            {
                if (line.Role1Attached == type)
                {
                    if (((DP_MetaClass)line.Role2Attached).InstanceIsAbstract == false)
                    {
                        referencedLines.Add((DP_MetaClass)line.Role2Attached);
                    }
                    referencedLines.AddRange(FindAllSubtypes((DP_MetaClass)line.Role2Attached));
                }
            }

            return referencedLines;
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

        private static bool ReferenceLinesToLines(DP_Line line)
        {
            try
            {
                if (line is DP_MetaReference)
                {
                    if (((DP_MetaClass)line.Role2Attached).InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception e)
            {
                throw new Exception("Unable to process reference association \"" + line.Name + ".\" Make sure the association is connected at both ends.", e);
            }
        }

        private static bool InheritanceLines(DP_Line line)
        {
            if (line is DP_MetaInheritance)
            {
                return true;
            }

            return false;
        }

        private static bool ContainmentLinesToShapes(DP_Line line)
        {
            try
            {
                if (line is DP_MetaContainment)
                {
                    if (((DP_MetaClass)line.Role1Attached).InstancePresentationType == DP_ConcreteType.DP_PresentationType.Shape)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception e)
            {
                throw new Exception("Unable to process containment association \"" + line.Name + ".\" Make sure the association is connected at both ends.", e);
            }
        }

        private static bool ContainmentLinesToLines(DP_Line line)
        {
            try
            {
                if (line is DP_MetaContainment)
                {
                    if (((DP_MetaClass)line.Role1Attached).InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception e)
            {
                throw new Exception("Unable to process containment association \"" + line.Name + ".\" Make sure the association is connected at both ends.", e);
            }
        }

        private static bool RootShapes(DP_AbstractSemanticType type)
        {
            if (type is DP_MetaClass)
            {
                return ((DP_MetaClass)type).InstanceIsRoot == true &&
                    (((DP_MetaClass)type).InstancePresentationType == DP_ConcreteType.DP_PresentationType.Shape);
            }
            else
            {
                return false;
            }
        }

        private static bool RootLines(DP_AbstractSemanticType type)
        {
            if (type is DP_MetaClass)
            {
                return ((DP_MetaClass)type).InstanceIsRoot == true &&
                    ((DP_MetaClass)type).InstancePresentationType == DP_ConcreteType.DP_PresentationType.Line;
            }
            else
            {
                return false;
            }
        }
    }
}
