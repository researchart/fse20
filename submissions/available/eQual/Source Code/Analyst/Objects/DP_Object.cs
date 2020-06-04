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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Xml.Serialization;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;


namespace DomainPro.Analyst.Objects
{
    public class DP_Object
    {
        private Guid id = Guid.NewGuid();

        public Guid Id
        {
            get { return id; }
            set { id = value; }
        }

        protected DP_ConcreteType type;

        public DP_ConcreteType Type
        {
            get { return type; }
            set { type = value; }
        }

        private DP_IModel model;

        [XmlIgnore]
        public DP_IModel Model
        {
            get { return model; }
            set { model = value; }
        }

        private DP_IObject context;

        [XmlIgnore]
        public DP_IObject Context
        {
            get { return context; }
            set { context = value; }
        }

        [XmlIgnore]
        public DP_Random Random
        {
            get { return Model.Simulation.Simulator.Random; }
        }

        [XmlIgnore]
        public double Time
        {
            get { return Model.Simulation.Simulator.Scheduler.Time; }
        }

        private Dictionary<Guid, DP_ILink> links = new Dictionary<Guid, DP_ILink>();

        [XmlIgnore]
        public Dictionary<Guid, DP_ILink> Links
        {
            get { return links; }
            set { links = value; }
        }

        private Dictionary<Guid, DP_IDependency> dependencies = new Dictionary<Guid, DP_IDependency>();

        [XmlIgnore]
        public Dictionary<Guid, DP_IDependency> Dependencies
        {
            get { return dependencies; }
            set { dependencies = value; }
        }

        public virtual void Initialize()
        {
        }
        public DP_IObject CreateForCloud(string typeName)
        {
            string typeFullName = Type.FullName.Replace(".", "Context.") + "Context." + typeName;

            // just uses the reference to get the model dll
            DP_IObject obj = (DP_IObject)ContextProvider.ModelAssembly.CreateInstance(
                "Simulation." + typeFullName);

            if (obj != null)
            {
                obj.Type = (DP_ConcreteType)Type.Structure.Types[typeName];
                obj.Context = (DP_IObject)this;
                obj.Model = Model;
                //Objects.Add(obj);
                //Objects.Add(obj.Id, obj);

                // Set the parent of the new object
                Type typeInfo = obj.GetType();
                FieldInfo fieldInfo = typeInfo.GetField(Type.Name);
                fieldInfo.SetValue(obj, this);

                if (obj is DP_Component ||
                    obj is DP_Resource ||
                    obj is DP_Link ||
                    obj is DP_Dependency)
                {
                    // Add the new object to the object list
                    PropertyInfo propertyInfo = GetType().GetProperty(typeName + "List");
                    ((IList)propertyInfo.GetValue(this, null)).Add(obj);
                }

                obj.Initialize();

                Model.Simulation.AttachListeners(obj);

            }

            return obj;
        }
        public DP_IObject Create(string typeName)
        {
            string typeFullName = Type.FullName.Replace(".", "Context.") + "Context." + typeName;

            // just uses the reference to get the model dll
            DP_IObject obj = (DP_IObject)DomainProAnalyst.Instance.ModelAssembly.CreateInstance(
                "Simulation." + typeFullName);
  
            if (obj != null)
            {
                obj.Type = (DP_ConcreteType)Type.Structure.Types[typeName];
                obj.Context = (DP_IObject)this;
                obj.Model = Model;
                //Objects.Add(obj);
                //Objects.Add(obj.Id, obj);

                // Set the parent of the new object
                Type typeInfo = obj.GetType();
                FieldInfo fieldInfo = typeInfo.GetField(Type.Name);
                fieldInfo.SetValue(obj, this);

                if (obj is DP_Component ||
                    obj is DP_Resource ||
                    obj is DP_Link ||
                    obj is DP_Dependency)
                {
                    // Add the new object to the object list
                    PropertyInfo propertyInfo = GetType().GetProperty(typeName + "List");
                    ((IList)propertyInfo.GetValue(this, null)).Add(obj);
                }

                obj.Initialize();

                Model.Simulation.AttachListeners(obj);
                
            }

            return obj;
        }
    }
}
