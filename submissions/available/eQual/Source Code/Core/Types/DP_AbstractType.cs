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
using System.ComponentModel;

namespace DomainPro.Core.Types
{
    public abstract class DP_AbstractType : DP_Base
    {
        protected DP_AbstractStructure structure;

        [Browsable(false)]
        public DP_AbstractStructure Structure
        {
            get { return structure; }
            set { structure = value; }
        }

        protected DP_AbstractText text;

        [Browsable(false)]
        public DP_AbstractText Text
        {
            get { return text; }
            set { text = value; }
        }

        public DP_AbstractSemanticType FindTypeByFullName(string name)
        {
            if (name == null)
            {
                return null;
            }
            string[] words = name.Split('.');
            DP_AbstractType nextType = this;
            for (int i = 0; i < words.Length; i++)
            {
                if (i == 0 && words[i] == Name)
                {
                    continue;
                }
                if (i == words.Length - 1 && words[i] == "")
                {
                    continue;
                }
                if (!nextType.Structure.Types.Contains(words[i]))
                {
                    return null;
                }
                nextType = nextType.Structure.Types[words[i]];
            }

            return nextType as DP_AbstractSemanticType;
        }

        public DP_AbstractSemanticType FindTypeById(Guid id)
        {
            if (id == Id)
            {
                return this as DP_AbstractSemanticType;
            }
            if (Structure.Types.Contains(id))
            {
                return Structure.Types[id];
            }
            else
            {
                foreach (DP_AbstractSemanticType child in Structure.Types)
                {
                    DP_AbstractSemanticType match = child.FindTypeById(id);
                    if (match != null)
                    {
                        return match;
                    }
                }

                return null;
            }
        }

        public string GetFullNameById(Guid id)
        {
            if (id == Id)
            {
                return Name;
            }
            if (Structure.Types.Contains(id))
            {
                return Name + "." + Structure.Types[id].Name;
            }
            else
            {
                foreach (DP_AbstractSemanticType child in Structure.Types)
                {
                    string match = child.GetFullNameById(id);
                    if (match != null)
                    {
                        return Name + "." + match;
                    }
                }

                return null;
            }
        }
    }
}
