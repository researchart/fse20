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
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Reflection;
using System.Reflection.Emit;
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Controls;
using DomainPro.Analyst.Interfaces;
using DomainPro.Core.Application;
using DomainPro.Core.Interfaces;

namespace DomainPro.Analyst.Engine
{
    public class DP_Simulation 
    {
        private string name;
            
        public string Name
        {
            get { return name; }
            set
            {
                name = value;
                simPanel.NameText = name;
                simTab.Text = name;
            }
        }

        private int position;

        public int Position
        {
            get { return position; }
            set
            {
                position = value;
                simPanel.Top = position * 105 + 28;
            }
        }

        private string status;

        public string Status
        {
            get { return status; }
            set
            {
                status = value;
                simTab.StatusText = value;
            }
        }

        private DateTime createdTime;

        public DateTime CreatedTime
        {
            get { return createdTime; }
            set
            {
                createdTime = value;
                simPanel.CreatedTimeText = createdTime.ToString();
            }
        }

        private DateTime lastRunTime;

        public DateTime LastRunTime
        {
            get { return lastRunTime; }
            set
            {
                lastRunTime = value;
                simPanel.LastRunTimeText = lastRunTime.ToString();
                simTab.StartedAtText = lastRunTime.ToShortTimeString();
                simTab.EstimatedCompletionText = lastRunTime.AddTicks(AverageRunningTime).ToShortTimeString();
            }
        }

        private TimeSpan runningTime;

        public TimeSpan RunningTime
        {
          get { return runningTime; }
          set
          {
              runningTime = value;
              simTab.RunningTimeText = runningTime.Hours.ToString("D2") + ":" + runningTime.Minutes.ToString("D2") + ":" + runningTime.Seconds.ToString("D2");
          }
        }

        private double simulationTime;

        public double SimulationTime
        {
            get { return simulationTime; }
            set
            {
                simulationTime = value;
                simTab.SimulationTimeText = simulationTime.ToString();
            }
        }

        private long averageRunningTime;

        public long AverageRunningTime
        {
            get { return averageRunningTime; }
            set { averageRunningTime = value; }
        }

        private double averageSimulationTime;

        public double AverageSimulationTime
        {
            get { return averageSimulationTime; }
            set { averageSimulationTime = value; }
        }

        private int progress;

        public int Progress
        {
            get { return progress; }
            set
            {
                progress = value;
                simPanel.ProgressBarValue = progress;
            }
        }

        private List<DP_SimulationRun> runs = new List<DP_SimulationRun>();

        public List<DP_SimulationRun> Runs
        {
            get { return runs; }
            set { runs = value; }
        }

        public DP_SimulationRun CurrentRun
        {
            get
            {
                if (Runs.Count > 0)
                {
                    return Runs[Runs.Count - 1];
                }
                return null;
            }
        }

        public DP_SimulationRun LastRun
        {
            get
            {
                if (Runs.Count > 1)
                {
                    return Runs[Runs.Count - 2];
                }
                return null;
            }
        }

        private List<DP_WatchedType> watched = new List<DP_WatchedType>();

        public List<DP_WatchedType> Watched
        {
            get { return watched; }
            set { watched = value; }
        }

        private Dictionary<string, int> propOverridesDict = new Dictionary<string, int>();

        private List<DP_PropertyOverride> propertyOverrides = new List<DP_PropertyOverride>();

        public List<DP_PropertyOverride> PropertyOverrides
        {
            get { return propertyOverrides; }
            set { propertyOverrides = value; }
        }

        private List<DP_StartInstance> startInstances = new List<DP_StartInstance>();

        public List<DP_StartInstance> StartInstances
        {
            get { return startInstances; }
            set { startInstances = value; }
        }

        private DP_TerminationConditions terminationConditions = new DP_TerminationConditions();

        public DP_TerminationConditions TerminationConditions
        {
            get { return terminationConditions; }
            set { terminationConditions = value; }
        }

        private DP_ModelType modelType;

        [XmlIgnore]
        public DP_ModelType ModelType
        {
            get { return modelType; }
            set { modelType = value; }
        }

        private DP_IModel modelInstance;

        [XmlIgnore]
        public DP_IModel ModelInstance
        {
            get
            {
                if (modelInstance == null)
                {
                    modelInstance = (DP_IModel)DomainProAnalyst.Instance.ModelAssembly.CreateInstance("Simulation." + ModelType.Name);
                    modelInstance.Type = ModelType;
                    modelInstance.Simulation = this;
                }
                return modelInstance;
            }
        }

        private DP_Simulator simulator;

        [XmlIgnore]
        public DP_Simulator Simulator
        {
            get { return simulator; }
            set { simulator = value; }
        }


        private DP_SimulationListPanel simPanel = new DP_SimulationListPanel();
        private DP_SimulationTab simTab = new DP_SimulationTab();
        private DP_WatchedType selectedWatchedType;

        public DP_Simulation()
        {
            Name = "NewSimulation";
            Status = "Idle";
            CreatedTime = DateTime.Now;
        }
        public void InitializeForCloud(Assembly modelAssemly, Assembly languageAssembly, DP_IModelFactory modelFactory, DP_Project project, DP_Language language)
        {

            ContextProvider.ModelAssembly = modelAssemly;
            ContextProvider.LanguageAssembly = languageAssembly;
            ContextProvider.ModelFactory = modelFactory;
            ContextProvider.Project = project;
            ContextProvider.Language = language;

            ModelType = (DP_ModelType)(ContextProvider.ModelFactory).LoadModel(@"D:\Projects\DomainPro\trunk\Models\SmartRedundancy\SmartRedundancy.xml");
            ModelType.Initialize();

            //simTab.NameText = Name;
            //DomainProAnalyst.Instance.simListPanel.Controls.Add(simPanel);
            //DomainProAnalyst.Instance.simulationTabControl.TabPages.Add(simTab);

            foreach (DP_PropertyOverride propOverride in PropertyOverrides)
            {
                DP_AbstractSemanticType type = ModelType.FindTypeByFullName(propOverride.Type);
                Type typeInfo = type.GetType();
                PropertyInfo propInfo = typeInfo.GetProperty(propOverride.Property);
                propInfo.SetValue(type, propOverride.Value, null);
                propOverridesDict.Add(propOverride.Property, PropertyOverrides.IndexOf(propOverride));
            }

            for (int i = Watched.Count - 1; i >= 0; i--)
            {
                if (ModelType.FindTypeByFullName(Watched[i].Type) == null)
                {
                    Watched.RemoveAt(i);
                }
            }

            //foreach (DP_WatchedType watched in Watched)
            //{
            //    simTab.WatchedTypeListItems.Add(watched.Type);
            //}

            //simPanel.Click += SimulationSelected;
            //simTab.Enter += SimulationSelected;
            //simTab.NameChanged += NameChanged;
            //simTab.WatchedTypeAdded += WatchedTypeAdded;
            //simTab.WatchedTypeChanged += WatchedTypeChanged;
            //simTab.WatchedTypeDeleted += WatchedTypeDeleted;
            //simTab.PropertyOverrideChanged += PropertyOverrideChanged;
            //simTab.StartInstancesSet += StartInstancesSet;
            //simTab.TerminationConditionsSet += TerminationConditionsSet;
            //simTab.ExportData += ExportData;
        }
        public void Initialize()
        {

            ModelType = (DP_ModelType)DomainProAnalyst.Instance.ModelFactory.LoadModel(
            Path.Combine(DomainProAnalyst.Instance.Project.RootFolder, DomainProAnalyst.Instance.Project.ModelFile));


            ModelType.Initialize();

            simTab.NameText = Name;
            DomainProAnalyst.Instance.simListPanel.Controls.Add(simPanel);
            DomainProAnalyst.Instance.simulationTabControl.TabPages.Add(simTab);

            foreach (DP_PropertyOverride propOverride in PropertyOverrides)
            {
                DP_AbstractSemanticType type = ModelType.FindTypeByFullName(propOverride.Type);
                Type typeInfo = type.GetType();
                PropertyInfo propInfo = typeInfo.GetProperty(propOverride.Property);
                propInfo.SetValue(type, propOverride.Value, null);
                propOverridesDict.Add(propOverride.Property, PropertyOverrides.IndexOf(propOverride));
            }

            for (int i = Watched.Count - 1; i >= 0; i--)
            {
                if (ModelType.FindTypeByFullName(Watched[i].Type) == null)
                {
                    Watched.RemoveAt(i);
                }
            }

            foreach (DP_WatchedType watched in Watched)
            {
                simTab.WatchedTypeListItems.Add(watched.Type);
            }

            simPanel.Click += SimulationSelected;
            simTab.Enter += SimulationSelected;
            simTab.NameChanged += NameChanged;
            simTab.WatchedTypeAdded += WatchedTypeAdded;
            simTab.WatchedTypeChanged += WatchedTypeChanged;
            simTab.WatchedTypeDeleted += WatchedTypeDeleted;
            simTab.PropertyOverrideChanged += PropertyOverrideChanged;
            simTab.StartInstancesSet += StartInstancesSet;
            simTab.TerminationConditionsSet += TerminationConditionsSet;
            simTab.ExportData += ExportData;
        }

        public void Destroy()
        {
           
            simTab.Dispose();
            simPanel.Dispose();
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }

        public void UpdateSimulationStats()
        {
            AverageRunningTime = (long)Math.Round(
                    (AverageRunningTime * (Runs.Count - 1) + Runs[Runs.Count - 1].RunningTime.Ticks) / (double)Runs.Count);
            AverageSimulationTime = (long)Math.Round(
                    (AverageSimulationTime * (Runs.Count - 1) + Runs[Runs.Count - 1].SimTime) / (double)Runs.Count);
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }
        public void InitializeNewListenersForCloud()
        {
           
            foreach (DP_WatchedType w in Watched)
            {
                DP_AbstractSemanticType type = ModelType.FindTypeByFullName(w.Type);
                if (type is DP_ComponentType)
                {
                    CurrentRun.WatchedDict.Add(w.Type, new DP_ComponentEventListener());
                }
                else if (type is DP_DataType)
                {
                    CurrentRun.WatchedDict.Add(w.Type, new DP_DataEventListener());
                }
                else if (type is DP_ResourceType)
                {
                    CurrentRun.WatchedDict.Add(w.Type, new DP_ResourceEventListener());
                }
                else if (type is DP_MethodType)
                {
                    CurrentRun.WatchedDict.Add(w.Type, new DP_MethodEventListener());
                }

                if (CurrentRun.WatchedDict.ContainsKey(w.Type))
                {
                    //CurrentRun.WatchedDict[watched.Type].Control.Size = new Size(simTab.Width - 600, simTab.Height - 20);
                    //if (ContextProvider.IsCloudSim)
                    //{
                    //    simTab.Controls.Add(CurrentRun.WatchedDict[watched.Type].Control);
                    //}
                    //else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                    //{
                    //    simTab.Controls.Add(CurrentRun.WatchedDict[watched.Type].Control);
                    //});
                }
            }

            if (selectedWatchedType != null)
            {
                //DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                //{
                //    CurrentRun.WatchedDict[selectedWatchedType.Type].Control.Visible = true;
                //});
            }
        }
        public void InitializeNewListeners()
        {
            if (LastRun != null)
            {
                foreach (KeyValuePair<string, DP_IEventListener> pair in LastRun.WatchedDict)
                {
                    if (ContextProvider.IsCloudSim)
                    {
                        simTab.Controls.Remove(pair.Value.Control);
                    }
                    else
                        DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                       {
                           simTab.Controls.Remove(pair.Value.Control);
                       });
                }
            }
            
            foreach (DP_WatchedType watched in Watched)
            {
                DP_AbstractSemanticType type = ModelType.FindTypeByFullName(watched.Type);
                if (type is DP_ComponentType)
                {
                    CurrentRun.WatchedDict.Add(watched.Type, new DP_ComponentEventListener());
                }
                else if (type is DP_DataType)
                {
                    CurrentRun.WatchedDict.Add(watched.Type, new DP_DataEventListener());
                }
                else if (type is DP_ResourceType)
                {
                    CurrentRun.WatchedDict.Add(watched.Type, new DP_ResourceEventListener());
                }
                else if (type is DP_MethodType)
                {
                    CurrentRun.WatchedDict.Add(watched.Type, new DP_MethodEventListener());
                }

                if (CurrentRun.WatchedDict.ContainsKey(watched.Type))
                {
                    CurrentRun.WatchedDict[watched.Type].Control.Size = new Size(simTab.Width - 600, simTab.Height - 20);
                    if (ContextProvider.IsCloudSim)
                    {
                            simTab.Controls.Add(CurrentRun.WatchedDict[watched.Type].Control);

                    }
                    else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                        {
                            simTab.Controls.Add(CurrentRun.WatchedDict[watched.Type].Control);
                        });
                }
            }

            if (selectedWatchedType != null)
            {
                if (ContextProvider.IsCloudSim)
                {
                    CurrentRun.WatchedDict[selectedWatchedType.Type].Control.Visible = true;

                }
                else
                    DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                   {
                       CurrentRun.WatchedDict[selectedWatchedType.Type].Control.Visible = true;
                   });
            }
        }

        public void AttachListeners(DP_IObject obj)
        {
            if (CurrentRun.WatchedDict.ContainsKey(obj.Type.FullName))
            {
                if (obj.Type is DP_ComponentType)
                {
                    ((DP_IComponent)obj).ComponentChanged += ((DP_ComponentEventListener)CurrentRun.WatchedDict[obj.Type.FullName]).ComponentChanged;
                }
                else if (obj.Type is DP_DataType)
                {
                    ((DP_IData)obj).DataChanged += ((DP_DataEventListener)CurrentRun.WatchedDict[obj.Type.FullName]).DataValueChanged;
                }
                else if (obj.Type is DP_ResourceType)
                {
                    ((DP_IResource)obj).ResourceChanged += ((DP_ResourceEventListener)CurrentRun.WatchedDict[obj.Type.FullName]).ResourceValueChanged;
                }
                else if (obj.Type is DP_MethodType)
                {
                    ((DP_IMethod)obj).MethodChanged += ((DP_MethodEventListener)CurrentRun.WatchedDict[obj.Type.FullName]).MethodChanged;
                }
            }
        }

        private void NameChanged(object sender, EventArgs e)
        {
            Name = simTab.NameText;
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }

        public void WatchedTypeAdded(object sender, EventArgs e)
        {
            string watchedFullName = ((DP_WatchedTypeDialog)sender).WatchedTypeText;
            if (ModelType.FindTypeByFullName(watchedFullName) == null)
            {
                return;
            }

            DP_WatchedType watched = new DP_WatchedType();
            watched.Type = watchedFullName;

            if (Watched.Any(w => w.Type == watched.Type))
            {
                Watched.Remove(Watched.First(w => w.Type == watched.Type));
                Watched.Add(watched);
            }
            else
            {
                Watched.Add(watched);
                simTab.WatchedTypeListItems.Add(watched.Type);
            }
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }

        private void WatchedTypeChanged(object sender, EventArgs e)
        {
            string watched = simTab.SelectedWatchedType;

            if (watched != null)
            {
                DP_WatchedType newSelectedWatchedType = Watched.First(w => w.Type == watched);
                if (newSelectedWatchedType != null)
                {
                    if (selectedWatchedType != null)
                    {
                        if (CurrentRun != null)
                        {
                            if (CurrentRun.WatchedDict.ContainsKey(selectedWatchedType.Type))
                            {
                                CurrentRun.WatchedDict[selectedWatchedType.Type].Control.Visible = false;
                            }
                        }
                    }

                    if (newSelectedWatchedType != selectedWatchedType)
                    {
                        if (CurrentRun != null)
                        {
                            if (CurrentRun.WatchedDict.ContainsKey(newSelectedWatchedType.Type))
                            {
                                CurrentRun.WatchedDict[newSelectedWatchedType.Type].Control.Visible = true;
                            }
                        }
                        selectedWatchedType = newSelectedWatchedType;
                    }
                    else
                    {
                        selectedWatchedType = null;
                        simTab.SelectedWatchedType = "";
                    }
                }
            }
        }

        private void WatchedTypeDeleted(object sender, EventArgs e)
        {
            if (selectedWatchedType != null)
            {
                Watched.Remove(selectedWatchedType);
                simTab.WatchedTypeListItems.Remove(selectedWatchedType.Type);
                if (CurrentRun.WatchedDict.ContainsKey(selectedWatchedType.Type))
                {
                    CurrentRun.WatchedDict[selectedWatchedType.Type].Control.Visible = false;
                }
                selectedWatchedType = null;
                simTab.SelectedWatchedType = "";
                DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
            }
        }

        public void PropertyOverrideChanged(object sender, PropertyValueChangedEventArgs e)
        {
            DP_PropertyOverride propOverride = new DP_PropertyOverride();
            propOverride.Type = ((DP_PropertyOverridesDialog)sender).Selected.Substring(((DP_PropertyOverridesDialog)sender).Selected.IndexOf('.') + 1);
            propOverride.Property = e.ChangedItem.PropertyDescriptor.Name;
            propOverride.Value = e.ChangedItem.Value;

            if (propOverridesDict.ContainsKey(propOverride.Property))
            {
                PropertyOverrides[propOverridesDict[propOverride.Property]] = propOverride;
            }
            else
            {
                PropertyOverrides.Add(propOverride);
                propOverridesDict.Add(propOverride.Property, PropertyOverrides.Count - 1);
            }
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }

        public void StartInstancesSet(object sender, EventArgs e)
        {
            // TODO: Allow methods at the top level to be started
            DP_InstanceTree instanceTree = (DP_InstanceTree)sender;
            StartInstances.Clear();
            AddStartInstancesFromTree((DP_InstanceTreeNode)instanceTree.Nodes[0], StartInstances);
            DomainProAnalyst.Instance.ModelState = DomainPro.Core.DP_Application.DP_ModelState.OpenChanged;
        }

        private void AddStartInstancesFromTree(DP_InstanceTreeNode parent, List<DP_StartInstance> instanceList)
        {
            foreach (DP_InstanceTreeNode instanceNode in parent.Nodes)
            {
                if (instanceNode.BoxText != "0")
                {
                    DP_StartInstance instance = new DP_StartInstance();
                    instance.Type = ((DP_AbstractSemanticType)instanceNode.Tag).Name;
                    instance.Count = int.Parse(instanceNode.BoxText);
                    foreach (TreeNode methodNode in instanceNode.methodTreeNode.Nodes)
                    {
                        if (methodNode.Tag.GetType().IsSubclassOf(typeof(DP_MethodType)) && methodNode.Checked)
                        {
                            instance.Methods.Add(((DP_MethodType)methodNode.Tag).Name);
                        }
                    }
                    instanceList.Add(instance);
                    AddStartInstancesFromTree(instanceNode, instance.Instances);
                }
            }
        }

        public void TerminationConditionsSet(object sender, DP_SimulationTab.DP_TerminationConditionsEventArgs e)
        {
            TerminationConditions.MaxSimTime = e.MaxSimTime;
            TerminationConditions.MaxRunTime = e.MaxRunTime;
            TerminationConditions.MaxCycles = e.MaxCycles;
            TerminationConditions.CustomCondition = e.CustomCondition;
        }

        public void SimulationSelected(object sender, EventArgs e)
        {
            Select();
        }

        private void ExportData(object sender, EventArgs e)
        {
            CurrentRun.WatchedDict[selectedWatchedType.Type].Export();
        }

        public void Select()
        {
            simPanel.Highlight();
            DomainProAnalyst.Instance.simulationTabControl.SelectedTab = simTab;
            DomainProAnalyst.Instance.SelectSim(this);
        }

        public void Deselect()
        {
            simPanel.Unhighlight();
        }
    }
}
