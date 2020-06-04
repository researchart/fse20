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
using System.Reflection;
using DomainPro.Core.Types;
using DomainPro.Analyst.Types;

namespace DomainPro.Analyst.Engine
{
    public class DP_ModelBuilder
    {
        private string root;

        private DP_ModelType model;

        private string fileList = "";

        public string Build(DP_ModelType newModel, string path)
        {
            root = path;
            model = newModel;
            string subpath = model.Name;

            string ns = "Simulation"; // model.Name + "Context";

            WriteAssemblyInfo();

            Directory.CreateDirectory(Path.Combine(root, "bin"));
            Directory.CreateDirectory(Path.Combine(root, subpath));

            WriteModel(model, subpath);

            foreach (DP_ConcreteType type in model.Structure.Types)
            {
                WriteObjectClass(type, subpath, ns);

                WriteChildren(type, subpath, ns);
            }

            return fileList;
        }

        private void WriteModel(DP_ModelType model, string path)
        {
            string file = model.Name + ".cs";
            fileList += file + " ";
            TextWriter writer = File.CreateText(Path.Combine(root, file));

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using DomainPro.Analyst;");
            writer.WriteLine("using DomainPro.Analyst.Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.Types;");
            writer.WriteLine("using DomainPro.Analyst.Objects;");
            writer.WriteLine("using Analyst.Types;");
            writer.WriteLine();
            writer.WriteLine("namespace Simulation");
            writer.WriteLine("{");
            foreach (DP_ConcreteType childType in model.Structure.Types)
            {
                if (childType is DP_ComponentType ||
                    childType is DP_ResourceType ||
                    childType is DP_LinkType ||
                    childType is DP_DependencyType)
                {
                    if (childType.Structure.Types.Count > 0)
                    {
                        writer.WriteLine("    using " + childType.Name + "Context;");
                    }
                }
            }
            writer.WriteLine();
            writer.WriteLine("    public class " + model.Name + " : DP_Model, DP_IModel");
            writer.WriteLine("    {");

            foreach (DP_ConcreteType childType in model.Structure.Types)
            {
                if (childType is DP_ComponentType ||
                    childType is DP_ResourceType ||
                    childType is DP_LinkType ||
                    childType is DP_DependencyType)
                {
                    writer.WriteLine("        private List<" + childType.Name + "> " + childType.Name + "Instances = new List<" + childType.Name + ">();");
                    writer.WriteLine();
                    writer.WriteLine("        public List<" + childType.Name + "> " + childType.Name + "List");
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.WriteLine("            return " + childType.Name + "Instances;");
                    writer.WriteLine("          }");
                    writer.WriteLine("          set");
                    writer.WriteLine("          {");
                    writer.WriteLine("            " + childType.Name + "Instances = value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }

            writer.WriteLine("        public void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine();
            DP_AbstractText.Instruction instruct = model.Text.Instructions.Find(i => i.Name == "Initialize");
            writer.Write(instruct.String);
            writer.WriteLine();
            writer.WriteLine("        }");
            writer.WriteLine();

            writer.WriteLine("    }");
            writer.WriteLine("}");
            writer.Close();
        }

        private void WriteChildren(DP_ConcreteType parent, string path, string ns)
        {
            path = Path.Combine(path, parent.Name);

            ns = ns + "." + parent.Name + "Context";

            Directory.CreateDirectory(Path.Combine(root, path));

            foreach (DP_ConcreteType type in parent.Structure.Types)
            {

                WriteObjectClass(type, path, ns);

                WriteChildren(type, path, ns);
            }
        }

        private void WriteObjectClass(DP_ConcreteType type, string path, string ns)
        {
            string file = Path.Combine(path, type.Name + ".cs");
            fileList += file + " ";
            TextWriter writer = File.CreateText(Path.Combine(root, file));

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Threading;");
            writer.WriteLine("using DomainPro.Core.Types;");
            writer.WriteLine("using DomainPro.Analyst;");
            writer.WriteLine("using DomainPro.Analyst.Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.Types;");
            writer.WriteLine("using DomainPro.Analyst.Objects;");
            writer.WriteLine("using DomainPro.Analyst.Engine;");
            writer.WriteLine("using Analyst.Types;");
            //writer.WriteLine("using Simulation;");

            string[] nsNames = ns.Split('.');
            string nextNs = nsNames[0];
            for (int i = 1; i < nsNames.Length; i++)
            {
                writer.WriteLine("using " + nextNs + ";");
                nextNs += "." + nsNames[i];
            }

            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");
            
            if (type.Structure.Types.Count > 0)
            {
                writer.WriteLine("    using " + type.Name + "Context;");
            }
            writer.WriteLine();
            //writer.WriteLine("    public class " + model.Name);
            //writer.WriteLine("    {");

            /*
            string[] parentNames = type.FullName.Split('.');
            for (int i = 0; i < parentNames.Length - 1; i++)
            {
                writer.WriteLine("    public partial class " + parentNames[i]);
                writer.WriteLine("    {");
            }
             * */

            writer.WriteLine("    public class " + type.Name + " : DP_" + type.SimulationType + ", DP_I" + type.SimulationType);
            writer.WriteLine("    {");

            if (type.Parent.Parent != null)
            {
                writer.WriteLine("        public " + type.Parent.Parent.Name + " " + type.Parent.Parent.Name + ";");
                writer.WriteLine();
            }

            WriteTypeProps(type, writer);

            if (type is DP_DataType)
            {
                WriteDataProps((DP_DataType)type, writer);
            }
            else if (type is DP_LinkType)
            {
                WriteLinkProps((DP_LinkType)type, writer);
            }
            else if (type is DP_DependencyType)
            {
                WriteDependencyProps((DP_DependencyType)type, writer);
            }

            foreach (DP_ConcreteType childType in type.Structure.Types)
            {
                if (childType is DP_ComponentType ||
                    childType is DP_ResourceType ||
                    childType is DP_LinkType ||
                    childType is DP_DependencyType)
                {
                    writer.WriteLine("        private List<" + childType.Name + "> " + childType.Name + "Instances = new List<" + childType.Name + ">();");
                    writer.WriteLine();
                    writer.WriteLine("        public List<" + childType.Name + "> " + childType.Name + "List");
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.WriteLine("            return " + childType.Name + "Instances;");
                    writer.WriteLine("          }");
                    writer.WriteLine("          set");
                    writer.WriteLine("          {");
                    writer.WriteLine("            " + childType.Name + "Instances = value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }

                if (childType is DP_MethodType)
                {
                    DP_MethodType method = childType as DP_MethodType;
                    writer.WriteLine("        public void " + method.Name + "(bool sync = false)");
                    writer.WriteLine("        {");
                    writer.WriteLine("          DP_IMethod method = (DP_IMethod)Create(\"" + method.Name + "\");");
                    //writer.WriteLine("          Thread thread = new Thread(new ThreadStart(method.Complete));");
                    writer.WriteLine("          DP_Schedulable schedulable = new DP_Schedulable(Model.Simulation.Simulator, method);");
                    writer.WriteLine("          schedulable.Schedule();");
                    writer.WriteLine("          if (sync)");
                    writer.WriteLine("          {");
                    writer.WriteLine("            Model.Simulation.Simulator.BlockedEvents[Thread.CurrentThread.ManagedThreadId].Set();");
                    writer.WriteLine("            method.Completed.WaitOne();");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }

                if (childType is DP_DataType)
                {
                    DP_DataType data = childType as DP_DataType;
                    writer.WriteLine("        private " + data.Name + " " + data.Name + "Instance;");
                    writer.WriteLine();
                    writer.WriteLine("        public " + data.Name + " " + data.Name + "Data");
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.WriteLine("            return " + data.Name + "Instance;");
                    writer.WriteLine("          }");
                    writer.WriteLine("          set");
                    writer.WriteLine("          {");
                    writer.WriteLine("            " + data.Name + "Instance = value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                    writer.WriteLine("        public " + data.ImplementationType + " " + data.Name);
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.WriteLine("            return "/*(" + data.ImplementationType + ")*/ + data.Name + "Instance.Value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("          set");
                    writer.WriteLine("          {");
                    writer.WriteLine("            " + data.Name + "Instance.Value = value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }

            foreach (DP_LinkType link in type.Links)
            {
                writer.WriteLine("        private " + link.Name + " " + link.Name + "Instance;");
                writer.WriteLine();
                writer.WriteLine("        public " + link.Name + " " + link.Name + "Link");
                writer.WriteLine("        {");
                writer.WriteLine("          get");
                writer.WriteLine("          {");
                writer.WriteLine("            return " + link.Name + "Instance;");
                writer.WriteLine("          }");

                string propName = (type == link.Role1Attached) ? "Role1" : "Role2";

                writer.WriteLine("          set");
                writer.WriteLine("          {");
                writer.WriteLine("            if (" + link.Name + "Instance == value)");
                writer.WriteLine("            {");
                writer.WriteLine("              return;");
                writer.WriteLine("            }");
                //writer.WriteLine("            " + link.Name + " old" + link.Name + "Instance = " + link.Name + "Instance;");
                writer.WriteLine("            " + link.Name + "Instance = value;");
                //writer.WriteLine("            if (old" + link.Name + "Instance != null && old" + link.Name + "Instance." + propName + " == this)");
                //writer.WriteLine("            {");
                //writer.WriteLine("              old" + link.Name + "Instance." + propName + " = null;");
                //writer.WriteLine("            }");
                writer.WriteLine("            if (" + link.Name + "Instance != null && " + link.Name + "Instance." + propName + " != this)");
                writer.WriteLine("            {");
                writer.WriteLine("              " + link.Name + "Instance." + propName + " = this;");
                writer.WriteLine("            }");
                writer.WriteLine("          }");
                writer.WriteLine("        }");
                writer.WriteLine();

                string counterpartName = (type == link.Role1Attached) ? link.Role2Attached.Name : link.Role1Attached.Name;

                string counterpartFullName = (type == link.Role1Attached) ? link.Role2Attached.FullName : link.Role1Attached.FullName;
                counterpartFullName = counterpartFullName.Replace(".", "Context.");

                writer.WriteLine("        public " + counterpartFullName + " " + link.Name);
                writer.WriteLine("        {");
                writer.WriteLine("          get");
                writer.WriteLine("          {");
                writer.WriteLine("            return " + link.Name + "Instance." + counterpartName + ";");
                writer.WriteLine("          }");
                writer.WriteLine("          set");
                writer.WriteLine("          {");
                writer.WriteLine("            " + link.Name + "Instance." + counterpartName + " = value;");
                writer.WriteLine("          }");
                writer.WriteLine("        }");
                writer.WriteLine();
            }

            foreach (DP_DependencyType dependency in type.Dependencies)
            {
                writer.WriteLine("        private " + dependency.Name + " " + dependency.Name + "Instance;");

                writer.WriteLine("        public " + dependency.Name + " " + dependency.Name);
                writer.WriteLine("        {");
                writer.WriteLine("          get");
                writer.WriteLine("          {");
                writer.WriteLine("            return " + dependency.Name + "Instance;");
                writer.WriteLine("          }");

                string propName = (type is DP_ResourceType) ? "Resource" : "Object";

                writer.WriteLine("          set");
                writer.WriteLine("          {");
                //writer.WriteLine("            " + dependency.Name + " old" + dependency.Name + "Instance = " + dependency.Name + "Instance;");
                writer.WriteLine("            " + dependency.Name + "Instance = value;");
                //writer.WriteLine("            if (old" + dependency.Name + "Instance != null && old" + dependency.Name + "Instance." + propName + " == this)");
                //writer.WriteLine("            {");
                //writer.WriteLine("              old" + dependency.Name + "Instance." + propName + " = null;");
                //writer.WriteLine("            }");
                writer.WriteLine("            if (" + dependency.Name + "Instance != null && " + dependency.Name + "Instance." + propName + " != this)");
                writer.WriteLine("            {");
                writer.WriteLine("              " + dependency.Name + "Instance." + propName + " = this;");
                writer.WriteLine("            }");
                writer.WriteLine("          }");
                writer.WriteLine("        }");
                writer.WriteLine();
            }

            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            writer.WriteLine();

            foreach (DP_ConcreteType childType in type.Structure.Types)
            {
                if (childType is DP_DataType)
                {
                    writer.WriteLine("          " + childType.Name + "Instance = (" + childType.Name + ")Create(\"" + childType.Name + "\");");
                    //writer.WriteLine("          " + childType.Name + "Instance." + type.Name + " = this;");
                }
            }

            writer.WriteLine();

            if (type is DP_ComponentType)
            {
                WriteComponentInitialize(type as DP_ComponentType, writer);
            }
            if (type is DP_ResourceType)
            {
                WriteResourceInitialize(type as DP_ResourceType, writer);
            }
            else if (type is DP_MethodType)
            {
                WriteMethodInitialize(type as DP_MethodType, writer);
            }
            else if (type is DP_DataType)
            {
                WriteDataInitialize(type as DP_DataType, writer);
            }
            
            writer.WriteLine("        }");
            writer.WriteLine();

            if (type is DP_ComponentType)
            {
                WriteComponentMethods(type as DP_ComponentType, writer);
            }
            if (type is DP_FlowType)
            {
                WriteFlowMethods(type as DP_FlowType, writer);
            }
            else if (type is DP_MethodType)
            {
                WriteMethodMethods(type as DP_MethodType, writer);
            }

            // Close the object class definitions
            /*
            foreach (string s in parentNames)
            {
                writer.WriteLine("    }");
            }
             * */

            writer.WriteLine("    }");
            writer.WriteLine("}");
            writer.Close();
        }

        private void WriteComponentInitialize(DP_ComponentType comp, TextWriter writer)
        {
            writer.WriteLine("            Startup();");
        }

        private void WriteDataInitialize(DP_DataType data, TextWriter writer)
        {
            if (data.InitialValue != "" && data.InitialValue != null)
            {
                //writer.WriteLine("          if (!(base.Value is DP_Object))");
                //writer.WriteLine("          {");
                writer.WriteLine("            Value = " + data.InitialValue + ";");
                //writer.WriteLine("          }");
            }
            else
            {
                if (data.ImplementationType == "int")
                {
                    writer.WriteLine("            Value = 0;");
                }
                else if (data.ImplementationType == "double")
                {
                    writer.WriteLine("            Value = 0;");
                }
                else if (data.ImplementationType == "float")
                {
                    writer.WriteLine("            Value = 0;");
                }
                else if (data.ImplementationType == "bool")
                {
                    writer.WriteLine("            Value = false;");
                }
            }
        }

        private void WriteResourceInitialize(DP_ResourceType rsrc, TextWriter writer)
        {
            /*
            writer.WriteLine("          Capacity = " + rsrc.Capacity + ";");
            writer.WriteLine();
            writer.WriteLine("          for (int i = 0; i < Capacity; i++)");
            writer.WriteLine("          {");
            writer.WriteLine("            idle.Enqueue(i);");
            writer.WriteLine("            running.Add(null);");
            writer.WriteLine("          }");
            writer.WriteLine();
            writer.WriteLine("          Velocity = " + rsrc.Velocity + ";");
             * */
            writer.WriteLine("          foreach (DP_Queue queue in Type.Queues)");
            writer.WriteLine("          {");
            writer.WriteLine("            if (queue.Ordering == DP_Queue.QueueOrdering.FIFO)");
            writer.WriteLine("            {");
            writer.WriteLine("              queues.Add(queue.Name, new Queue());");
            writer.WriteLine("            }");
            writer.WriteLine("            else if (queue.Ordering == DP_Queue.QueueOrdering.LIFO)");
            writer.WriteLine("            {");
            writer.WriteLine("              queues.Add(queue.Name, new Stack());");
            writer.WriteLine("            }");
            writer.WriteLine("          }");
            writer.WriteLine();

            for (int i = 0; i < rsrc.Workers.Count; i++)
            {
                writer.WriteLine("          for (int i = 0; i < " + rsrc.Workers[i].Capacity + "; i++)");
                writer.WriteLine("          {");
                writer.WriteLine("            Worker newWorker = new Worker();");
                writer.WriteLine("            newWorker.Id = " + i + ";");
                writer.WriteLine("            newWorker.Velocity = " + rsrc.Workers[i].Velocity + ";");
                writer.WriteLine("            idle.Enqueue(newWorker);");
                //writer.WriteLine("            running.Add(null);");
                writer.WriteLine("          }");
                writer.WriteLine();
            }
        }

        private void WriteMethodInitialize(DP_MethodType method, TextWriter writer)
        {
            /*
            if (method.ResourceDependency == null)
            {
                writer.WriteLine("          Resource = null;");
            }
            else
            {
                writer.WriteLine("          Resource = " + method.ResourceDependency + ";");
            }
            writer.WriteLine();
             * */
        }

        private void WriteTypeProps(DP_ConcreteType type, TextWriter writer)
        {
            Type nextType = type.GetType();
            while (nextType.BaseType != typeof(DP_ConcreteType))
            {
                foreach (PropertyInfo prop in nextType.GetProperties())
                {
                    //PropertyAttributes propAttrs = prop.Attributes;
                    if (prop.DeclaringType == nextType)
                    {
                        if (prop.PropertyType.IsGenericType)
                        {
                            //writer.WriteLine("        public " + prop.PropertyType.GetGenericTypeDefinition() + "<" + prop.PropertyType.GetGenericArguments() + ">" + prop.Name);
                            string genericString = prop.PropertyType.ToString();
                            int typeParamsPos = genericString.IndexOf("`");
                            int typeParamsCount = int.Parse(genericString[typeParamsPos + 1].ToString());
                            string typeParams = genericString.Substring(typeParamsPos + 3, genericString.Length - typeParamsPos - 4);
                            writer.Write("        public " + prop.PropertyType.ToString().Substring(0, typeParamsPos));
                            writer.WriteLine("<" + typeParams + "> " + prop.Name);
                        }
                        else
                        {
                            writer.WriteLine("        public " + prop.PropertyType + " " + prop.Name);
                        }
                        writer.WriteLine("        {");
                        writer.WriteLine("          get { return ((" + nextType.Name + ")Type)." + prop.Name + "; }");
                        writer.WriteLine("        }");
                        writer.WriteLine();
                    }
                }
                nextType = nextType.BaseType;
            }
        }

        private void WriteDataProps(DP_DataType data, TextWriter writer)
        {
            //writer.WriteLine("        private new " + data.ImplementationType + " val;");
            //writer.WriteLine();
            writer.WriteLine("        public new " + data.ImplementationType + " Value");
            writer.WriteLine("        {");
            writer.WriteLine("          get");
            writer.WriteLine("          {");
            writer.WriteLine("            return (" + data.ImplementationType + ")val;");
            writer.WriteLine("          }");
            writer.WriteLine("          set");
            writer.WriteLine("          {");
            writer.WriteLine("            OnDataChanged(new DP_DataChangedEventArgs(Id, Context.Id, Model.Simulation.Simulator.Scheduler.Time, value));");
            writer.WriteLine("            val = value;");
            writer.WriteLine("          }");
            writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public Double Size");
            writer.WriteLine("        {");
            writer.WriteLine("          get { return 0; }");
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        private void WriteLinkProps(DP_LinkType link, TextWriter writer)
        {
            string role1FullName = link.Role1Attached.FullName.Replace(".", "Context.");

            writer.WriteLine("        private " + role1FullName + " " + link.Role1Attached.Name + "Instance;");
            writer.WriteLine();
            writer.WriteLine("        public " + role1FullName + " " + link.Role1Attached.Name);
            writer.WriteLine("        {");
            writer.WriteLine("          get");
            writer.WriteLine("          {");
            writer.WriteLine("            return " + link.Role1Attached.Name + "Instance;");
            writer.WriteLine("          }");
            writer.WriteLine("          set");
            writer.WriteLine("          {");
            writer.WriteLine("            " + link.Role1Attached.Name + "Instance = (" + role1FullName + ")value;");
            writer.WriteLine("            if (Role1 != value)");
            writer.WriteLine("            {");
            writer.WriteLine("              Role1 = value;");
            writer.WriteLine("            }");
            writer.WriteLine("          }");
            writer.WriteLine("        }");
            writer.WriteLine();

            string role2FullName = link.Role2Attached.FullName.Replace(".", "Context.");

            writer.WriteLine("        private " + role2FullName + " " + link.Role2Attached.Name + "Instance;");
            writer.WriteLine();
            writer.WriteLine("        public " + role2FullName + " " + link.Role2Attached.Name);
            writer.WriteLine("        {");
            writer.WriteLine("          get");
            writer.WriteLine("          {");
            writer.WriteLine("            return " + link.Role2Attached.Name + "Instance;");
            writer.WriteLine("          }");
            writer.WriteLine("          set");
            writer.WriteLine("          {");
            writer.WriteLine("            " + link.Role2Attached.Name + "Instance = (" + role2FullName + ")value;");
            writer.WriteLine("            if (Role2 != value)");
            writer.WriteLine("            {");
            writer.WriteLine("              Role2 = value;");
            writer.WriteLine("            }");
            writer.WriteLine("          }");
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        private void WriteDependencyProps(DP_DependencyType dependency, TextWriter writer)
        {
            string role1FullName = dependency.Role1Attached.FullName.Replace(".", "Context.");

            writer.WriteLine("        private " + role1FullName + " " + dependency.Role1Attached.Name + "Instance;");
            writer.WriteLine();
            writer.WriteLine("        public " + role1FullName + " " + dependency.Role1Attached.Name);
            writer.WriteLine("        {");
            writer.WriteLine("          get");
            writer.WriteLine("          {");
            writer.WriteLine("            return " + dependency.Role1Attached.Name + "Instance;");
            writer.WriteLine("          }");
            writer.WriteLine("          set");
            writer.WriteLine("          {");
            writer.WriteLine("            " + dependency.Role1Attached.Name + "Instance = (" + role1FullName + ")value;");
            writer.WriteLine("            if (Object != value)");
            writer.WriteLine("            {");
            writer.WriteLine("              Object = value;");
            writer.WriteLine("            }");
            writer.WriteLine("          }");
            writer.WriteLine("        }");
            writer.WriteLine();

            string role2FullName = dependency.Role2Attached.FullName.Replace(".", "Context.");

            writer.WriteLine("        private " + role2FullName + " " + dependency.Role2Attached.Name + "Instance;");
            writer.WriteLine();
            writer.WriteLine("        public " + role2FullName + " " + dependency.Role2Attached.Name);
            writer.WriteLine("        {");
            writer.WriteLine("          get");
            writer.WriteLine("          {");
            writer.WriteLine("            return " + dependency.Role2Attached.Name + "Instance;");
            writer.WriteLine("          }");
            writer.WriteLine("          set");
            writer.WriteLine("          {");
            writer.WriteLine("            " + dependency.Role2Attached.Name + "Instance = (" + role2FullName + ")value;");
            writer.WriteLine("            if (Resource != value)");
            writer.WriteLine("            {");
            writer.WriteLine("              Resource = value;");
            writer.WriteLine("            }");
            writer.WriteLine("          }");
            writer.WriteLine("        }");
            writer.WriteLine();
        }

        /*
        private void WriteLinkMethods(DP_LinkType link, TextWriter writer)
        {
            writer.WriteLine("        public " + link. Trigger(DP_IMethod source)");
            writer.WriteLine("        {");
            writer.WriteLine("          return Trigger((" + flow.Role1Attached.Name + ")source);");
            writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public bool Trigger(DP_IMethod source)");
            writer.WriteLine("        {");
            writer.WriteLine("          return Trigger((" + flow.Role1Attached.Name + ")source);");
            writer.WriteLine("        }");
            writer.WriteLine();

        }
         * */

        private void WriteComponentMethods(DP_ComponentType comp, TextWriter writer)
        {
            foreach (DP_AbstractText.Instruction i in comp.Text.Instructions)
            {
                if (i.Name == "Startup")
                {
                    writer.WriteLine("        public void Startup()");
                    writer.WriteLine("        {");
                    writer.Write(i.String);
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }
        }

        private void WriteFlowMethods(DP_FlowType flow, TextWriter writer)
        {
            foreach (DP_AbstractText.Instruction i in flow.Text.Instructions)
            {
                if (i.Name == "Trigger")
                {
                    writer.WriteLine("        public bool Trigger(DP_IMethod source)");
                    writer.WriteLine("        {");
                    writer.WriteLine("          " + flow.Role1Attached.FullName.Replace(".", "Context.") + " " + flow.Role1Attached.Name + " = source as " + flow.Role1Attached.FullName.Replace(".", "Context.") + ";");
                    writer.Write(i.String);
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
                else if (i.Name == "Transfer")
                {
                    writer.WriteLine("        public void Transfer(DP_IMethod source, DP_IMethod target)");
                    writer.WriteLine("        {");
                    writer.WriteLine("          " + flow.Role1Attached.FullName.Replace(".", "Context.") + " " + flow.Role1Attached.Name + " = source as " + flow.Role1Attached.FullName.Replace(".", "Context.") + ";");
                    writer.WriteLine("          " + flow.Role2Attached.FullName.Replace(".", "Context.") + " " + flow.Role2Attached.Name + " = target as " + flow.Role2Attached.FullName.Replace(".", "Context.") + ";");
                    writer.Write(i.String);
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
                else if (i.Name == "Resolve")
                {
                    writer.WriteLine("        public DP_IObject Resolve(DP_IMethod source)");
                    writer.WriteLine("        {");
                    writer.WriteLine("          " + flow.Role1Attached.FullName.Replace(".", "Context.") + " " + flow.Role1Attached.Name + " = source as " + flow.Role1Attached.FullName.Replace(".", "Context.") + ";");
                    writer.Write(i.String);
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }
        }

        private void WriteMethodMethods(DP_MethodType method, TextWriter writer)
        {
            foreach (DP_AbstractText.Instruction i in method.Text.Instructions)
            {
                if (i.Name == "Run")
                {
                    writer.WriteLine("        public override void Run()");
                    writer.WriteLine("        {");
                    writer.Write(i.String);
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
                else if (i.Name == "Duration")
                {
                    writer.WriteLine("        public override double Duration");
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.Write(i.String);
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }
        }

        private void WriteAssemblyInfo()
        {
            Directory.CreateDirectory(Path.Combine(root, "Properties"));
            TextWriter writer = File.CreateText(Path.Combine(root, "Properties\\AssemblyInfo.cs"));

            writer.WriteLine("using System.Reflection;");
            writer.WriteLine("using System.Runtime.CompilerServices;");
            writer.WriteLine("using System.Runtime.InteropServices;");

            writer.WriteLine("[assembly: AssemblyTitle(\"" + model.Name + "\")]");
            writer.WriteLine("[assembly: AssemblyDescription(\"\")]");
            writer.WriteLine("[assembly: AssemblyConfiguration(\"\")]");
            writer.WriteLine("[assembly: AssemblyCompany(\"Blue Cell Software LLC\")]");
            writer.WriteLine("[assembly: AssemblyProduct(\"" + model.Name + "\")]");
            writer.WriteLine("[assembly: AssemblyCopyright(\"Copyright © Blue Cell Software LLC 2011\")]");
            writer.WriteLine("[assembly: AssemblyTrademark(\"\")]");
            writer.WriteLine("[assembly: AssemblyCulture(\"\")]");
            writer.WriteLine("[assembly: ComVisible(false)]");
            writer.WriteLine("[assembly: Guid(\"" + model.Id + "\")]");
            writer.WriteLine("[assembly: AssemblyVersion(\"0.0.0.0\")]");
            writer.WriteLine("[assembly: AssemblyFileVersion(\"0.0.0.0\")]");
            writer.WriteLine();
            writer.Close();
        }

        /*
        public void WriteComponentDef(DP_ComponentType comp, string path, string ns)
        {
            TextWriter writer = File.CreateText(path + comp.Name + ".cs");

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Linq;");
            writer.WriteLine("using System.Text;");
            writer.WriteLine("using DomainPro.Analyst.DP_Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.DP_Types;");
            writer.WriteLine("using DomainPro.Analyst.DP_Objects;");
            writer.WriteLine("using Analyst.DP_Types;");
            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");

            writer.WriteLine("    public class " + comp.Name + " : DP_Component, DP_IComponent");
            writer.WriteLine("    {");
            //writer.WriteLine("        private DP_Component component;");
            //writer.WriteLine();
            //writer.WriteLine("        public DP_Component Component");
            //writer.WriteLine("        {");
            //writer.WriteLine("            get { return component; }");
            //writer.WriteLine("            set { component = value; }");
            //writer.WriteLine("        }");
            //writer.WriteLine();

            if (comp.Parent.Parent != null)
            {
                writer.WriteLine("        public " + comp.Parent.Parent.Name + " " + comp.Parent.Parent.Name + ";");
                writer.WriteLine();
            }

            foreach (DP_ConcreteType type in comp.Structure.Types)
            {
                if (type.GetType().IsSubclassOf(typeof(DP_MethodType)))
                {
                    //writer.WriteLine("        public " + type.Name + " " + type.Name + "Instance;");
                }
                if (type.GetType().IsSubclassOf(typeof(DP_FlowType)))
                {
                    //writer.WriteLine("        public " + type.Name + " " + type.Name + "Instance;");
                }
                if (type.GetType().IsSubclassOf(typeof(DP_DataType)))
                {
                    DP_DataType data = (DP_DataType)type;
                    writer.WriteLine("        private " + data.Name + " " + data.Name + "Instance;");

                    writer.WriteLine("        public " + data.TypeProp.Value + " " + data.Name);
                    writer.WriteLine("        {");
                    writer.WriteLine("          get");
                    writer.WriteLine("          {");
                    writer.WriteLine("            return (" + data.TypeProp.Value + ")" + data.Name + "Instance.Value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("          set");
                    writer.WriteLine("          {");
                    writer.WriteLine("            " + data.Name + "Instance.Value = value;");
                    writer.WriteLine("          }");
                    writer.WriteLine("        }");
                    writer.WriteLine();
                }
            }

            //writer.WriteLine("        private " + comp.Parent.Parent.GetType().ToString() + " " + comp.Parent.Parent.Name + ";");
            //writer.WriteLine();
            //writer.WriteLine("        public " + comp.Name + "()");
            //writer.WriteLine("        {");
            //writer.WriteLine("        }");
            //writer.WriteLine();
            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            foreach (DP_ConcreteType type in comp.Structure.Types)
            {
                if (type.GetType().IsSubclassOf(typeof(DP_MethodType)))
                {
                    //writer.WriteLine("          " + type.Name + "Instance = (" + type.Name + ")Type.GetMethod(\"" + type.Name + "\").Create();");
                    //writer.WriteLine("          " + type.Name + "Instance." + comp.Name + " = this;");
                }
                if (type.GetType().IsSubclassOf(typeof(DP_FlowType)))
                {
                    //writer.WriteLine("          " + type.Name + "Instance = (" + type.Name + ")Type.GetFlow(\"" + type.Name + "\").Create();");
                    //writer.WriteLine("          " + type.Name + "Instance." + comp.Name + " = this;");
                }
                if (type.GetType().IsSubclassOf(typeof(DP_DataType)))
                {
                    writer.WriteLine("          " + type.Name + "Instance = (" + type.Name + ")Create(\"" + type.Name + "\");");
                    //writer.WriteLine("          " + type.Name + "Instance." + comp.Name + " = this;");
                }
            }
            //writer.WriteLine("            " + comp.Parent.Parent.Name + " = (" + comp.Parent.Parent.GetType().ToString() + ")Method.Parent.Parent;");
            writer.WriteLine("        }");
            writer.WriteLine();

            writer.Write(comp.Text);
            writer.WriteLine();

            
            //writer.WriteLine("        public double Duration()");
            //writer.WriteLine("        {");
            //writer.WriteLine("            return 0;");
            //writer.WriteLine("        }");
            //writer.WriteLine();
            //writer.WriteLine("        public void Run()");
            //writer.WriteLine("        {");
            //writer.WriteLine();
            //writer.WriteLine("        }");
            
            writer.WriteLine("    }");
            writer.WriteLine();


            writer.WriteLine("}");
            writer.Close();
        }

        public void WriteResourceDef(DP_ResourceType rsrc, string path, string ns)
        {
            TextWriter writer = File.CreateText(path + rsrc.Name + ".cs");

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Linq;");
            writer.WriteLine("using System.Text;");
            writer.WriteLine("using DomainPro.Analyst.DP_Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.DP_Types;");
            writer.WriteLine("using DomainPro.Analyst.DP_Objects;");
            writer.WriteLine("using Analyst.DP_Types;");
            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");

            writer.WriteLine("    public class " + rsrc.Name + " : DP_Resource, DP_IResource");
            writer.WriteLine("    {");

            if (rsrc.Parent.Parent != null)
            {
                writer.WriteLine("        public " + rsrc.Parent.Parent.Name + " " + rsrc.Parent.Parent.Name + ";");
                writer.WriteLine();
            }

            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            writer.WriteLine("          Capacity = " + rsrc.CapacityProp.Value + ";");
            writer.WriteLine();
            writer.WriteLine("          for (int i = 0; i < Capacity; i++)");
            writer.WriteLine("            {");
            writer.WriteLine("              idle.Enqueue(i);");
            writer.WriteLine("              running[i] = null;");
            writer.WriteLine("            }");
            writer.WriteLine("        }");
            writer.WriteLine();

            writer.WriteLine("    }");
            writer.WriteLine();

            writer.WriteLine("}");
            writer.Close();

        }

        public void WriteMethodDef(DP_MethodType method, string path, string ns)
        {
            TextWriter writer = File.CreateText(path + method.Name + ".cs");

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Linq;");
            writer.WriteLine("using System.Text;");
            writer.WriteLine("using DomainPro.Analyst.DP_Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.DP_Types;");
            writer.WriteLine("using DomainPro.Analyst.DP_Objects;");
            writer.WriteLine("using Analyst.DP_Types;");
            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");

            writer.WriteLine("    public class " + method.Name + " : DP_Method, DP_IMethod");
            writer.WriteLine("    {");
            //writer.WriteLine("        private DP_Method method;");
            //writer.WriteLine();
            //writer.WriteLine("        public DP_Method Method");
            //writer.WriteLine("        {");
            //writer.WriteLine("            get { return method; }");
            //writer.WriteLine("            set { method = value; }");
            //writer.WriteLine("        }");
            writer.WriteLine();

            if (method.Parent.Parent != null)
            {
                writer.WriteLine("        public " + method.Parent.Parent.Name + " " + method.Parent.Parent.Name + ";");
                writer.WriteLine();
            }

            //writer.WriteLine("        public " + method.Name + "()");
            //writer.WriteLine("        {");
            //writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            //writer.WriteLine("            " + method.Parent.Parent.Name + " = (" + method.Parent.Parent.Name + ")Type.Parent.Parent;");
            writer.WriteLine("        }");
            writer.WriteLine();

            writer.Write(method.Text);
            writer.WriteLine();

            
            //writer.WriteLine("        public double Duration()");
            //writer.WriteLine("        {");
            //writer.WriteLine("            return 0;");
            //writer.WriteLine("        }");
            //writer.WriteLine();
            //writer.WriteLine("        public void Run()");
            //writer.WriteLine("        {");
            //writer.WriteLine();
            //writer.WriteLine("        }");
            
            writer.WriteLine("    }");
            writer.WriteLine();


            writer.WriteLine("}");
            writer.Close();
        }

        public void WriteFlowDef(DP_FlowType flow, string path, string ns)
        {
            TextWriter writer = File.CreateText(path + flow.Name + ".cs");

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Linq;");
            writer.WriteLine("using System.Text;");
            writer.WriteLine("using DomainPro.Analyst.DP_Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.DP_Types;");
            writer.WriteLine("using DomainPro.Analyst.DP_Objects;");
            writer.WriteLine("using Analyst.DP_Types;");
            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");

            writer.WriteLine("    public class " + flow.Name + " : DP_Flow, DP_IFlow");
            writer.WriteLine("    {");
            //writer.WriteLine("        private DP_Flow flow;");
            //writer.WriteLine();
            //writer.WriteLine("        public DP_Flow Flow");
            //writer.WriteLine("        {");
            //writer.WriteLine("            get { return flow; }");
            //writer.WriteLine("            set { flow = value; }");
            //writer.WriteLine("        }");
            //writer.WriteLine();

            if (flow.Parent.Parent != null)
            {
                writer.WriteLine("        public " + flow.Parent.Parent.Name + " " + flow.Parent.Parent.Name + ";");
                writer.WriteLine();
            }
            //writer.WriteLine("        public " + flow.Name + "()");
            //writer.WriteLine("        {");
            //writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            //writer.WriteLine("            " + flow.Parent.Parent.Name + " = (" + flow.Parent.Parent.Name + ")Type.Parent.Parent;");
            writer.WriteLine("        }");
            writer.WriteLine();

            writer.Write(flow.Text);
            writer.WriteLine();

            writer.WriteLine("    }");
            writer.WriteLine();


            writer.WriteLine("}");
            writer.Close();
        }


        public void WriteDataDef(DP_DataType data, string path, string ns)
        {
            TextWriter writer = File.CreateText(path + data.Name + ".cs");

            writer.WriteLine("using System;");
            writer.WriteLine("using System.Collections;");
            writer.WriteLine("using System.Collections.Generic;");
            writer.WriteLine("using System.Linq;");
            writer.WriteLine("using System.Text;");
            writer.WriteLine("using DomainPro.Analyst.DP_Interfaces;");
            writer.WriteLine("using DomainPro.Analyst.DP_Types;");
            writer.WriteLine("using DomainPro.Analyst.DP_Objects;");
            writer.WriteLine("using Analyst.DP_Types;");
            writer.WriteLine();
            writer.WriteLine("namespace " + ns);
            writer.WriteLine("{");

            writer.WriteLine("    public class " + data.Name + " : DP_Data, DP_IData");
            writer.WriteLine("    {");
            //writer.WriteLine("        private DP_Data data;");
            //writer.WriteLine();
            //writer.WriteLine("        public DP_Data Data");
            //writer.WriteLine("        {");
            //writer.WriteLine("            get { return data; }");
            //writer.WriteLine("            set { data = value; }");
            //writer.WriteLine("        }");
            //writer.WriteLine();

            if (data.Parent.Parent != null)
            {
                writer.WriteLine("        public " + data.Parent.Parent.Name + " " + data.Parent.Parent.Name + ";");
                writer.WriteLine();
            }

            writer.WriteLine("        private " + data.TypeProp.Value + " val = new " + data.TypeProp.Value + "();");

            writer.WriteLine("        public object Value");
            writer.WriteLine("        {");
            writer.WriteLine("          get { return val; }");
            writer.WriteLine("          set { val = (" + data.TypeProp.Value + ")value; }");
            writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public Double Size");
            writer.WriteLine("        {");
            writer.WriteLine("          get { return 0; } //sizeof(" + data.TypeProp.Value + "); }");
            writer.WriteLine("        }");
            writer.WriteLine();

            //writer.WriteLine("        public " + data.Name + "()");
            //writer.WriteLine("        {");
            //writer.WriteLine("        }");
            writer.WriteLine();
            writer.WriteLine("        public override void Initialize()");
            writer.WriteLine("        {");
            writer.WriteLine("          base.Initialize();");
            //writer.WriteLine("            " + data.Parent.Parent.Name + " = (" + data.Parent.Parent.GetType().ToString() + ")Data.Parent.Parent;");
            writer.WriteLine("        }");
            writer.WriteLine();

            //writer.Write(data.Text);
            writer.WriteLine();

            writer.WriteLine("    }");
            writer.WriteLine();


            writer.WriteLine("}");
            writer.Close();
        }
         * */
    }
}
