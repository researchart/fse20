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
    [DefaultPropertyAttribute("Name")]
    public class DP_Base
    {
        protected string name;

        [DisplayNameAttribute("Name"),
        CategoryAttribute("Common"),
        DescriptionAttribute("Sets the object's name (must be unique within the object's parent).")]
        public virtual string Name
        {
            get { return name; }
            set { name = value; }
        }

        private Guid id = Guid.NewGuid();

        [DisplayNameAttribute("ID"),
        CategoryAttribute("Common"),
        DescriptionAttribute("Indicates the object's ID (must be unique within the entire model)."),
        ReadOnlyAttribute(true)]
        public Guid Id
        {
            get { return id; }
            set { id = value; }
        }
    }
}
