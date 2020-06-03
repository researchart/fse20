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
using System.Drawing;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Core.Application;
using DomainPro.Core.Types;
using DomainPro.Designer.Controls;

namespace DomainPro.Designer.Types
{
    [XmlInclude(typeof (DP_Text))]
    public class DP_ModelType : DP_AbstractModelType
    {
        public override string Name
        {
            get { return name; }
            set
            {
                TreeRoot.Text = value;
                name = value;
            }
        }

        private TreeNode treeRoot = new TreeNode();

        [XmlIgnore]
        public TreeNode TreeRoot
        {
            get { return treeRoot; }
        }

        private DP_DiagramPanel diagramPanel;

        [XmlIgnore]
        public DP_DiagramPanel DiagramPanel
        {
            get { return diagramPanel; }
            set { diagramPanel = value; }
        }

        [XmlIgnore]
        public DP_Diagram Diagram
        {
            get { return (DP_Diagram) structure; }
            set { structure = value; }
        }

        private bool selected;

        [XmlIgnore,
         Browsable(false)]
        public bool Selected
        {
            get { return selected; }
            set
            {
                ((DP_Text) Text).Visible = value;
                selected = value;
            }
        }

        public DP_ModelType()
        {
            TreeRoot.Tag = this;

            DiagramPanel = new DP_DiagramPanel();
        }

        public DP_ModelType(string newName)
        {
            Name = newName;

            TreeRoot.Tag = this;

            DiagramPanel = new DP_DiagramPanel();
        }

        public override void Initialize()
        {
            TreeRoot.TreeView.BeginUpdate();
            base.Initialize();
            TreeRoot.TreeView.Sort();
            TreeRoot.TreeView.EndUpdate();

            ((DP_Text) Text).Initialize();

            Diagram.MakeMainDiagram();
        }

        public void ModelPaint(object sender, PaintEventArgs e)
        {
            foreach (DP_ConcreteType type in Diagram.Types)
            {
                type.TypePaint(sender, e);
            }
        }

        public DP_TypeCollection<DP_AbstractSemanticType> DuplicateTypes(
            DP_TypeCollection<DP_AbstractSemanticType> sources)
        {
            Dictionary<DP_ConcreteType, DP_ConcreteType> copyDict = new Dictionary<DP_ConcreteType, DP_ConcreteType>();
            Dictionary<DP_ConcreteType, DP_ConcreteType> reverseCopyDict =
                new Dictionary<DP_ConcreteType, DP_ConcreteType>();
            DP_TypeCollection<DP_ConcreteType> newTypes = new DP_TypeCollection<DP_ConcreteType>();

            foreach (DP_ConcreteType type in sources)
            {
                DP_ConcreteType newType = type.Duplicate();
                newTypes.Add(newType);
                copyDict.Add(type, newType);
                reverseCopyDict.Add(newType, type);
            }

            foreach (DP_ConcreteType newType in newTypes)
            {
                if (newType is DP_Line)
                {
                    if (((DP_Line) reverseCopyDict[newType]).Role1Attached != null)
                    {
                        foreach (KeyValuePair<DP_ConcreteType, DP_ConcreteType> typePair in copyDict)
                        {
                            DP_AbstractSemanticType attached =
                                typePair.Key.FindTypeById(((DP_Line) reverseCopyDict[newType]).Role1Attached.Id);
                            if (attached != null)
                            {
                                ((DP_Line) newType).Role1Attached =
                                    typePair.Value.FindTypeByFullName(typePair.Key.GetFullNameById(attached.Id)) as
                                        DP_ConcreteType;
                            }
                        }

                        if (((DP_Line) newType).Role1Attached == null)
                        {
                            Point attachedLoc =
                                ((DP_Line) reverseCopyDict[newType]).Role1Attached.Parent.TypePointToDiagramSpace(
                                    ((DP_Line) reverseCopyDict[newType]).Role1Attached.Location);
                            ((DP_Line) newType).LineProperties.Role1.Offset = new Point(
                                attachedLoc.X + ((DP_Line) newType).LineProperties.Role1.Offset.X + 20,
                                attachedLoc.Y + ((DP_Line) newType).LineProperties.Role1.Offset.Y + 20);
                        }

                        /*
                    DP_ConcreteType nextParent = ((DP_Line)reverseCopyDict[newType]).Role1Attached;
                    string fullName = "";
                    while (!copyDict.ContainsKey(nextParent))
                    {
                        fullName = nextParent.Name + "." + fullName;
                        nextParent = nextParent.Parent.Parent;
                    }

                    ((DP_Line)newType).Role1Attached = copyDict[nextParent].FindTypeByFullName(fullName) as DP_ConcreteType;
                         * */
                    }

                    if (((DP_Line) reverseCopyDict[newType]).Role2Attached != null)
                    {
                        foreach (KeyValuePair<DP_ConcreteType, DP_ConcreteType> typePair in copyDict)
                        {
                            DP_AbstractSemanticType attached =
                                typePair.Key.FindTypeById(((DP_Line) reverseCopyDict[newType]).Role2Attached.Id);
                            if (attached != null)
                            {
                                ((DP_Line) newType).Role2Attached =
                                    typePair.Value.FindTypeByFullName(typePair.Key.GetFullNameById(attached.Id)) as
                                        DP_ConcreteType;
                            }
                        }

                        if (((DP_Line) newType).Role2Attached == null)
                        {
                            Point attachedLoc =
                                ((DP_Line) reverseCopyDict[newType]).Role2Attached.Parent.TypePointToDiagramSpace(
                                    ((DP_Line) reverseCopyDict[newType]).Role2Attached.Location);
                            ((DP_Line) newType).LineProperties.Role2.Offset = new Point(
                                attachedLoc.X + ((DP_Line) newType).LineProperties.Role2.Offset.X + 20,
                                attachedLoc.Y + ((DP_Line) newType).LineProperties.Role2.Offset.Y + 20);
                        }
                    }
                }
            }

            return newTypes;
        }
    }
}