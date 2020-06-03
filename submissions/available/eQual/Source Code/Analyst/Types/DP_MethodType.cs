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
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Serialization;
using DomainPro.Core.Types;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Controls;

namespace DomainPro.Analyst.Types
{
    public class DP_MethodType : DP_ConcreteType
    {
        //[XmlIgnore]
        //public DP_TextProperty RsrcDependencyProp;

        private string resourceDependency;

        [DisplayName("Resource Dependency"),
        Category("Simulation"),
        DefaultValue(""),
        Description("Sets the resource on which the type depends.")]
        public string ResourceDependency
        {
            get { return resourceDependency; }
            set { resourceDependency = value; }
        }

        private string resourceRequest;

        [DisplayName("Resource Request"),
        Category("Simulation"),
        DefaultValue(""),
        Description("Sets the type of work requested of the resource.")]
        public string ResourceRequest
        {
            get { return resourceRequest; }
            set { resourceRequest = value; }
        }

        //[XmlIgnore]
        //public DP_TextProperty RsrcWorkProp;

        [XmlIgnore]
        public List<DP_FlowType> Flows
        {
            get { return flows; }
            set { flows = value; }
        }

        private List<DP_FlowType> flows = new List<DP_FlowType>();

        public DP_MethodType()
        {
            
        }

        public override void Initialize(DP_AbstractStructure parentStructure)
        {
            base.Initialize(parentStructure);

            /*
            RsrcDependencyProp = (DP_TextProperty)Properties.Find(
                 delegate(DP_Property p)
                 {
                     return p.Name == "Resource Dependency";
                 });
            RsrcDependencyProp.IsSemantic = true;

            RsrcWorkProp = (DP_TextProperty)Properties.Find(
                 delegate(DP_Property p)
                 {
                     return p.Name == "Required Work";
                 });
            RsrcWorkProp.IsSemantic = true;
            */
            
        }
    }
}
