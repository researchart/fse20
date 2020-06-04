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
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Core.Types;
using DomainPro.Designer;
using DomainPro.Designer.Types;
using DomainPro.Designer.Controls;

namespace LanguageBuilder.MetaTypes
{
    public class DP_MetaReference : DP_Line
    {
        private string role = "";

        [DisplayName("Role"),
        Category("Type"),
        DefaultValue(""),
        Description("Sets the role that the referenced object can fulfill.")]
        public string Role
        {
            get { return role; }
            set { role = value; }
        }
        
        public new static bool ValidRoles(DP_ConcreteType newSource, DP_ConcreteType newDest)
        {
            if (newSource == null || CanBeRole1(newSource))
            {
                if (newDest == null || CanBeRole2(newDest))
                    return true;
            }
            if (newDest == null || CanBeRole1(newDest))
            {
                if (newSource == null || CanBeRole2(newSource))
                    return true;
            }

            return false;
        }

        private static bool CanBeRole1(DP_ConcreteType attached)
        {
            if (attached.GetType() == typeof(DP_MetaClass))
            {
                return true;
            }
            return false;
        }

        private static bool CanBeRole2(DP_ConcreteType attached)
        {
            if (attached.GetType() == typeof(DP_MetaClass))
            {
                return true;
            }
            return false;
        }

        protected override void SetParams()
        {
            LineProperties.Form = DP_LineForm.Line;
            LineProperties.LineWidth = 1;
            LineProperties.BorderStyle = DashStyle.Solid;
            LineProperties.BorderColor = Color.Empty;
            LineProperties.BorderWidth = 0;
            LineProperties.FillStyle = DashStyle.Solid;
            LineProperties.FillColor = Color.Black;
            LineProperties.Role1.DisplayedName = "source";
            LineProperties.Role1.NameVisible = false;
            LineProperties.Role1.Font = new Font("Segoe UI", (float)7.8, FontStyle.Bold);
            LineProperties.Role1.Icon = "";
            LineProperties.Role2.DisplayedName = "target";
            LineProperties.Role2.NameVisible = false;
            LineProperties.Role2.Font = new Font("Segoe UI", (float)7.8, FontStyle.Bold);
            LineProperties.Role2.Icon = "Graphics\\arrow.gif";

            Name = "NewReference";
            DisplayName = Name;
            ShowName = true;
            NameFont = new Font("Segoe UI", (float)7.8, FontStyle.Bold);

            TreeNode.ImageIndex = 8;
            TreeNode.SelectedImageIndex = 8;
        }

        public DP_MetaReference()
        {
        }

        public DP_MetaReference(DomainProDesigner.DP_ConnectionSpec newRole1, DomainProDesigner.DP_ConnectionSpec newRole2) :
            base(newRole1, newRole2)
        {
            Diagram = new DP_MetaReferenceDiagram();
            Text = new DP_Text();
        }

        public override void Initialize(DP_AbstractStructure parentDiagram)
        {
            base.Initialize(parentDiagram);
            Diagram.Initialize(this);
        }

        public override DP_ConcreteType Duplicate()
        {
            DP_MetaReference newType = new DP_MetaReference();
            newType.Diagram = new DP_MetaReferenceDiagram();
            newType.Text = new DP_Text();
            newType.Copy(this);
            return newType;
        }
    }
}
