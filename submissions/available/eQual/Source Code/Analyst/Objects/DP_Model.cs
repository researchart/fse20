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
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Objects
{
    public class DP_Model
    {
        private DP_ModelType type;

        public DP_ModelType Type
        {
            get { return type; }
            set { type = value; }
        }

        private DP_Simulation simulation;

        public DP_Simulation Simulation
        {
            get { return simulation; }
            set { simulation = value; }
        }

        public DP_IObject CreateForCloud(string typeName)
        {
            
            if (ContextProvider.ModelAssembly == null) throw new ArgumentNullException("modelAssembly");
            DP_IObject obj = ContextProvider.ModelAssembly.CreateInstance("Simulation." + typeName) as DP_IObject;

            if (obj != null)
            {
                if (obj is DP_Component ||
                    obj is DP_Resource ||
                    obj is DP_Link ||
                    obj is DP_Dependency)
                {
                    // Add the new object to the object list
                    PropertyInfo propertyInfo = GetType().GetProperty(typeName + "List");
                    ((IList)propertyInfo.GetValue(this, null)).Add(obj);
                }

                /*
                obj.Type = Type.Root.Types.Find(
                    delegate(DP_ConcreteType c)
                    {
                        return (c.Name == typeName || c.Name == typeName);
                    });
                 * */
                obj.Type = Type.Structure.Types[typeName] as DP_ConcreteType;
                obj.Model = this as DP_IModel;
                obj.Initialize();

                Simulation.AttachListeners(obj);
            }
            return obj;
        }
        public DP_IObject Create(string typeName)
        {
            DP_IObject obj = DomainProAnalyst.Instance.ModelAssembly.CreateInstance("Simulation." + typeName) as DP_IObject;

            if (obj != null)
            {
                if (obj is DP_Component ||
                    obj is DP_Resource ||
                    obj is DP_Link ||
                    obj is DP_Dependency)
                {
                    // Add the new object to the object list
                    PropertyInfo propertyInfo = GetType().GetProperty(typeName + "List");
                    ((IList)propertyInfo.GetValue(this, null)).Add(obj);
                }

                /*
                obj.Type = Type.Root.Types.Find(
                    delegate(DP_ConcreteType c)
                    {
                        return (c.Name == typeName || c.Name == typeName);
                    });
                 * */
                obj.Type = Type.Structure.Types[typeName] as DP_ConcreteType;
                obj.Model = this as DP_IModel;
                obj.Initialize();

                Simulation.AttachListeners(obj);
            }
            return obj;
        }

        
    }
}
