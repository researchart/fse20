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
using System.Xml.Serialization;
using DomainPro.Core.Application;

namespace DomainPro.Core.Types
{
    public abstract class DP_AbstractStructure : DP_Base
    {
        public override string Name
        {
            get { return null; }
            set { }
        }

        private DP_TypeCollection<DP_AbstractSemanticType> types = new DP_TypeCollection<DP_AbstractSemanticType>();

        public DP_TypeCollection<DP_AbstractSemanticType> Types
        {
            get { return types; }
            set { types = value; }
        }

        protected DP_AbstractSemanticType parent;

        [XmlIgnore]
        public DP_AbstractSemanticType Parent
        {
            get { return parent; }
            set { parent = value; }
        }

        public virtual void Initialize(DP_AbstractSemanticType parent)
        {
            Parent = parent;

            foreach (DP_AbstractSemanticType type in Types)
            {
                type.Initialize(this);
            }
        }

        public string MakeUniqueName(string name)
        {
            int i = 1;
            string tempName = name;
            while (Types.Contains(tempName))
            {
                tempName = name + i;
                i++;
            }
            return tempName;
        }
    }
}
