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
using System.Xml.Serialization;
using System.ComponentModel;
using System.Reflection;
using DomainPro.Core.Application;
using DomainPro.Core.Types;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Types
{
    [XmlInclude(typeof(DP_Text))]
    public class DP_ConcreteType : DP_AbstractSemanticType
    {
        [ReadOnly(true)]
        public override string Name
        {
            get { return name; }
            set { name = value; }
        }

        private Guid role1Id = Guid.Empty;

        [Browsable(false)]
        public Guid Role1Id
        {
            get { return role1Id; }
            set { role1Id = value; }
        }

        private Guid role2Id = Guid.Empty;

        [Browsable(false)]
        public Guid Role2Id
        {
            get { return role2Id; }
            set { role2Id = value; }
        }

        private DP_ConcreteType role1Attached;

        [Browsable(false)]
        public DP_ConcreteType Role1Attached
        {
            get
            {
                return role1Attached;
            }
            set
            {
                if (value != null)
                {
                    role1Attached = value;
                    Role1Id = role1Attached.Id;
                }
                else
                {
                    role1Attached = null;
                    Role1Id = Guid.Empty;
                }
            }
        }

        private DP_ConcreteType role2Attached;

        [Browsable(false)]
        public DP_ConcreteType Role2Attached
        {
            get { return role2Attached; }
            set
            {
                if (value != null)
                {
                    role2Attached = value;
                    Role2Id = role2Attached.Id;
                }
                else
                {
                    role2Attached = null;
                    Role2Id = Guid.Empty;
                }
            }
        }

        private Size size;

        public override Size Size
        {
            get { return size; }
            set { size = value; }
        }

        private Point location;

        public override Point Location
        {
            get { return location; }
            set { location = value; }
        }

        private DP_TypeCollection<DP_LinkType> links = new DP_TypeCollection<DP_LinkType>();

        [XmlIgnore,
        Browsable(false)]
        public DP_TypeCollection<DP_LinkType> Links
        {
            get { return links; }
        }

        private DP_TypeCollection<DP_DependencyType> dependencies = new DP_TypeCollection<DP_DependencyType>();

        [XmlIgnore,
        Browsable(false)]
        public DP_TypeCollection<DP_DependencyType> Dependencies
        {
            get { return dependencies; }
        }

        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            Parent = parentStructure;
            Structure.Initialize(this);
        }
        
        /*
        public DP_ConcreteType GetConcreteType(string typeName)
        {
            if (Structure.TypeNameDict.ContainsKey(typeName))
            {
                return Structure.TypeNameDict[typeName];
            }
            return null;
        }

        public DP_ComponentType GetComponentType(string compName)
        {
            if (Structure.TypeNameDict.ContainsKey(compName))
            {
                DP_ConcreteType comp = Structure.TypeNameDict[compName];
                if (comp.GetType().IsSubclassOf(typeof(DP_ComponentType)))
                {
                    return (DP_ComponentType)comp;
                }
            }
            return null;
        }

        public DP_FlowType GetFlowType(string flowName)
        {
            if (Structure.TypeNameDict.ContainsKey(flowName))
            {
                DP_ConcreteType flow = Structure.TypeNameDict[flowName];
                if (flow.GetType().IsSubclassOf(typeof(DP_FlowType)))
                {
                    return (DP_FlowType)flow;
                }
            }
            return null;
        }

        public DP_MethodType GetMethodType(string methodName)
        {
            if (Structure.TypeNameDict.ContainsKey(methodName))
            {
                DP_ConcreteType method = Structure.TypeNameDict[methodName];
                if (method.GetType().IsSubclassOf(typeof(DP_MethodType)))
                {
                    return (DP_MethodType)method;
                }
            }
            return null;
        }

        public DP_DataType GetDataType(string dataName)
        {
            if (Structure.TypeNameDict.ContainsKey(dataName))
            {
                DP_ConcreteType data = Structure.TypeNameDict[dataName];
                if (data.GetType().IsSubclassOf(typeof(DP_DataType)))
                {
                    return (DP_DataType)data;
                }
            }
            return null;
        }

        public DP_ResourceType GetResourceType(string rsrcName)
        {
            if (Structure.TypeNameDict.ContainsKey(rsrcName))
            {
                DP_ConcreteType rsrc = Structure.TypeNameDict[rsrcName];
                if (rsrc.GetType().IsSubclassOf(typeof(DP_ResourceType)))
                {
                    return (DP_ResourceType)rsrc;
                }
            }
            return null;
        }
        */
    }
}
