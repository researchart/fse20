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
using System.IO;
using System.Windows.Forms;
using System.Xml.Serialization;
using DomainPro.Core.Types;

namespace DomainPro.Designer.Types
{
    public class DP_Role
    {
        public event EventHandler EndChanged;

        public enum SnappedEdges
        {
            None = 0x0,
            Left = 0x1,
            Right = 0x2,
            Top = 0x4,
            Bottom = 0x8,
            Center = 0x16
        }

        public DP_Role()
        {
            Label.AutoSize = true;
            Label.BackColor = Color.Transparent;
        }

        private DP_ConcreteType attached;

        [XmlIgnore]
        public DP_ConcreteType Attached
        {
            get { return attached; }
            set
            {
                attached = value;
                Snap();
            }
        }

        public Point AttachedLocation
        {
            get
            {
                if (Attached != null)
                {
                    return Attached.Location;
                }
                else
                {
                    return new Point(0, 0);
                }
            }
        }

        public Point End
        {
            get
            {
                if (RoleProperties != null)
                {
                    return new Point(AttachedLocation.X + RoleProperties.Offset.X,
                        AttachedLocation.Y + RoleProperties.Offset.Y);
                }
                else
                {
                    return AttachedLocation;
                }
            }
        }

        public Point ScreenEnd
        {
            get
            {
                if (Attached != null && Attached.Parent != null)
                {
                    return Attached.Parent.TypePointToPanelSpace(End);
                }
                else
                {
                    if (DomainProDesigner.Instance.MainDiagram != null)
                    {
                        return DomainProDesigner.Instance.MainDiagram.DiagramPointToPanelSpace(End);
                    }
                    else
                    {
                        return End;
                    }
                }
            }
        }

        public Size Size
        {
            get
            {
                Size rectSize = new Size(DomainProDesigner.Instance.LineEndSize, DomainProDesigner.Instance.LineEndSize);
                if (Icon != null)
                {
                    rectSize = new Size(Math.Max(Icon.Width, rectSize.Width), Math.Max(Icon.Height, rectSize.Height));
                }
                return rectSize;
            }
        }

        private Bitmap icon;

        [XmlIgnore]
        public Bitmap Icon
        {
            get { return icon; }
            set { icon = value; }
        }

        private Label label = new Label();

        [XmlIgnore]
        public Label Label
        {
            get { return label; }
            set { label = value; }
        }

        private SnappedEdges snapped = SnappedEdges.None;

        public SnappedEdges Snapped
        {
            get { return snapped; }
            set { snapped = value; }
        }

        private DP_Line.DP_RoleProperties roleProperties;

        [XmlIgnore]
        public DP_Line.DP_RoleProperties RoleProperties
        {
            get { return roleProperties; }
            set
            {
                roleProperties = value;

                DisplayedNameChanged(roleProperties, new EventArgs());
                NameVisibleChanged(roleProperties, new EventArgs());
                FontChanged(roleProperties, new EventArgs());
                IconChanged(roleProperties, new EventArgs());
                roleProperties.DisplayedNameChanged += DisplayedNameChanged;
                roleProperties.NameVisibleChanged += NameVisibleChanged;
                roleProperties.FontChanged += FontChanged;
                roleProperties.IconChanged += IconChanged;
                roleProperties.OffsetChanged += OffsetChanged;
            }
        }

        private void Snap()
        {
            if (Attached != null)
            {
                Snapped = SnappedEdges.None;

                int rightDiff = Math.Abs(RoleProperties.Offset.X - Attached.Width);
                int bottomDiff = Math.Abs(RoleProperties.Offset.Y - Attached.Height);
                int centerDiff = (int) Math.Floor(Math.Sqrt(
                    Math.Pow(RoleProperties.Offset.X - Attached.Width/2, 2) +
                    Math.Pow(RoleProperties.Offset.Y - Attached.Height/2, 2)));

                if (centerDiff < RoleProperties.Offset.X &&
                    centerDiff < RoleProperties.Offset.Y &&
                    centerDiff < rightDiff &&
                    centerDiff < bottomDiff)
                {
                    if (centerDiff > DomainProDesigner.Instance.SnapSize*-1 &&
                        centerDiff < DomainProDesigner.Instance.SnapSize)
                    {
                        RoleProperties.Offset = new Point(Attached.Width/2, Attached.Height/2);
                        Snapped = SnappedEdges.Center;
                        return;
                    }
                }

                if (RoleProperties.Offset.X < rightDiff)
                {
                    if (RoleProperties.Offset.X > DomainProDesigner.Instance.SnapSize*-1 &&
                        RoleProperties.Offset.X < DomainProDesigner.Instance.SnapSize)
                    {
                        RoleProperties.Offset = new Point(0, RoleProperties.Offset.Y);
                        Snapped = Snapped | SnappedEdges.Left;
                    }
                }
                else
                {
                    if (RoleProperties.Offset.X > Attached.Width - DomainProDesigner.Instance.SnapSize &&
                        RoleProperties.Offset.X < Attached.Width + DomainProDesigner.Instance.SnapSize)
                    {
                        RoleProperties.Offset = new Point(Attached.Width, RoleProperties.Offset.Y);
                        Snapped = Snapped | SnappedEdges.Right;
                    }
                }

                if (RoleProperties.Offset.Y < bottomDiff)
                {
                    if (RoleProperties.Offset.Y > DomainProDesigner.Instance.SnapSize*-1 &&
                        RoleProperties.Offset.Y < DomainProDesigner.Instance.SnapSize)
                    {
                        RoleProperties.Offset = new Point(RoleProperties.Offset.X, 0);
                        Snapped = Snapped | SnappedEdges.Top;
                    }
                }
                else
                {
                    if (RoleProperties.Offset.Y > Attached.Height - DomainProDesigner.Instance.SnapSize &&
                        RoleProperties.Offset.Y < Attached.Height + DomainProDesigner.Instance.SnapSize)
                    {
                        RoleProperties.Offset = new Point(RoleProperties.Offset.X, Attached.Height);
                        Snapped = Snapped | SnappedEdges.Bottom;
                    }
                }
            }
        }

        private void OffsetChanged(object sender, EventArgs e)
        {
            Snap();
            if (EndChanged != null)
            {
                EndChanged(this, new EventArgs());
            }
        }

        private void DisplayedNameChanged(object sender, EventArgs e)
        {
            Label.Text = RoleProperties.DisplayedName;
        }

        private void NameVisibleChanged(object sender, EventArgs e)
        {
            Label.Visible = RoleProperties.NameVisible;
        }

        private void FontChanged(object sender, EventArgs e)
        {
            Label.Font = RoleProperties.Font;
        }

        private void IconChanged(object sender, EventArgs e)
        {
            Icon = null;

            if (RoleProperties.Icon != null)
            {
                string iconFile = RoleProperties.Icon;

                // Expand any environment variables in the icon file path
                iconFile = Environment.ExpandEnvironmentVariables(iconFile);

                // If the path is a relative path
                if (!Path.IsPathRooted(iconFile))
                {
                    iconFile = Path.Combine(Path.GetDirectoryName(DomainProDesigner.Instance.Language.File), iconFile);
                }

                if (File.Exists(iconFile))
                {
                    Icon = new Bitmap(iconFile);
                    Icon = new Bitmap(Icon);
                }

                // Make sure the stored value is a relative path
                if (Path.IsPathRooted(RoleProperties.Icon))
                {
                    RoleProperties.Icon = Path.Combine(
                        DomainProDesigner.Instance.RelativePath(
                            Path.GetDirectoryName(DomainProDesigner.Instance.Language.File),
                            Path.GetDirectoryName(RoleProperties.Icon)),
                        Path.GetFileName(RoleProperties.Icon));
                }
            }
        }
    }
}