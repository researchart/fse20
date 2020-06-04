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

namespace DomainPro.Core.Types
{
    [XmlRoot(ElementName="Type")]
    public abstract class DP_AbstractSemanticType : DP_AbstractType
    {
        private Type type;

        [DisplayName("Type"),
        Category("Common"),
        Description("Indicates the type of the object.")]
        public string TypeName
        {
            get
            {
                if (type == null)
                {
                    type = GetType();
                }
                return type.Name;
            }
        }

        private string fullName;

        [DisplayName("Full Name"),
        Category("Common"),
        Description("Indicates the fully qualified name of the object.")]
        public string FullName
        {
            get
            {
                if (fullName == null)
                {
                    if (Parent != null)
                    {
                        fullName = Name;
                        DP_AbstractSemanticType nextParent = Parent.Parent;
                        while (nextParent != null)
                        {
                            fullName = nextParent.Name + "." + fullName;
                            nextParent = nextParent.Parent.Parent;
                        }
                    }
                }
                return fullName;
            }
        }

        public enum DP_PresentationType { None, Shape, Line };

        private DP_PresentationType presentationType;

        [XmlIgnore,
        DisplayName("Presentation Metatype"),
        Category("Common"),
        DefaultValue(DP_PresentationType.None),
        Description("Indicates the way the object is displayed."),
        ReadOnly(true)]
        public DP_PresentationType PresentationType
        {
            get { return presentationType; }
            set { presentationType = value; }
        }

        public enum DP_SimulationType { None, Component, Data, Link, Method, Flow, Resource, Dependency };

        private DP_SimulationType simulationType;

        [XmlIgnore,
        DisplayName("Simulation Metatype"),
        Category("Common"),
        DefaultValue(DP_SimulationType.None),
        Description("Indicates the way the object behaves in simulation."),
        ReadOnly(true)]
        public DP_SimulationType SimulationType
        {
            get { return simulationType; }
            set { simulationType = value; }
        }

        protected DP_AbstractStructure parent;

        [XmlIgnore,
        Browsable(false)]
        public DP_AbstractStructure Parent
        {
            get { return parent; }
            set { parent = value; }
        }

        [DisplayName("Size"),
        Category("Instance"),
        Description("The size of the object in pixels.")]
        public abstract Size Size
        { get; set; }

        [DisplayName("Location"),
        Category("Instance"),
        Description("The pixel coordinates of the upper-left corner of the object relative to the upper-left corner of its parent object.")]
        public abstract Point Location
        { get; set; }

        public event EventHandler LocationChanged;

        public event EventHandler SizeChanged;

        protected void OnLocationChanged(EventArgs e)
        {
            if (LocationChanged != null)
            {
                LocationChanged(this, e);
            }
        }

        protected void OnSizeChanged(EventArgs e)
        {
            if (SizeChanged != null)
            {
                SizeChanged(this, e);
            }
        }

        public abstract void Initialize(DP_AbstractStructure parent);
    }
}
