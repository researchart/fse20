namespace DomainPro.Analyst.Controls
{
    partial class DP_PropertyOverridesDialog
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.doneButton = new System.Windows.Forms.Button();
            this.propertyGrid = new System.Windows.Forms.PropertyGrid();
            this.SuspendLayout();
            // 
            // doneButton
            // 
            this.doneButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.doneButton.Location = new System.Drawing.Point(594, 330);
            this.doneButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.doneButton.Name = "doneButton";
            this.doneButton.Size = new System.Drawing.Size(82, 36);
            this.doneButton.TabIndex = 3;
            this.doneButton.Text = "Done";
            this.doneButton.UseVisualStyleBackColor = true;
            // 
            // propertyGrid
            // 
            this.propertyGrid.Location = new System.Drawing.Point(406, 11);
            this.propertyGrid.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.propertyGrid.Name = "propertyGrid";
            this.propertyGrid.Size = new System.Drawing.Size(270, 292);
            this.propertyGrid.TabIndex = 9;
            // 
            // DP_PropertyOverridesDialog
            // 
            this.AcceptButton = this.doneButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(687, 497);
            this.ControlBox = false;
            this.Controls.Add(this.propertyGrid);
            this.Controls.Add(this.doneButton);
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.Name = "DP_PropertyOverridesDialog";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Set Property Overrides";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PropertyGrid propertyGrid;
        private System.Windows.Forms.Button doneButton;
    }
}