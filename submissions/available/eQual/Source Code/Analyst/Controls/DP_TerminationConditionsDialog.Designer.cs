namespace DomainPro.Analyst.Controls
{
    partial class DP_TerminationConditionsDialog
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
            this.maxSimTimeLabel = new System.Windows.Forms.Label();
            this.maxRunTimeLabel = new System.Windows.Forms.Label();
            this.maxCyclesLabel = new System.Windows.Forms.Label();
            this.customConditionLabel = new System.Windows.Forms.Label();
            this.maxSimTimeText = new System.Windows.Forms.TextBox();
            this.maxRunTimeText = new System.Windows.Forms.TextBox();
            this.maxCyclesText = new System.Windows.Forms.TextBox();
            this.customConditionText = new System.Windows.Forms.RichTextBox();
            this.cancelButton = new System.Windows.Forms.Button();
            this.saveButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // maxSimTimeLabel
            // 
            this.maxSimTimeLabel.AutoSize = true;
            this.maxSimTimeLabel.Location = new System.Drawing.Point(12, 16);
            this.maxSimTimeLabel.Name = "maxSimTimeLabel";
            this.maxSimTimeLabel.Size = new System.Drawing.Size(268, 17);
            this.maxSimTimeLabel.TabIndex = 0;
            this.maxSimTimeLabel.Text = "Maximum Simulation Time (0 = unlimited):";
            // 
            // maxRunTimeLabel
            // 
            this.maxRunTimeLabel.AutoSize = true;
            this.maxRunTimeLabel.Location = new System.Drawing.Point(12, 46);
            this.maxRunTimeLabel.Name = "maxRunTimeLabel";
            this.maxRunTimeLabel.Size = new System.Drawing.Size(304, 17);
            this.maxRunTimeLabel.TabIndex = 1;
            this.maxRunTimeLabel.Text = "Maximum Running Time (00:00:00 = unlimited):";
            // 
            // maxCyclesLabel
            // 
            this.maxCyclesLabel.AutoSize = true;
            this.maxCyclesLabel.Location = new System.Drawing.Point(12, 76);
            this.maxCyclesLabel.Name = "maxCyclesLabel";
            this.maxCyclesLabel.Size = new System.Drawing.Size(209, 17);
            this.maxCyclesLabel.TabIndex = 2;
            this.maxCyclesLabel.Text = "Maximum Cycles (0 = unlimited):";
            // 
            // customConditionLabel
            // 
            this.customConditionLabel.AutoSize = true;
            this.customConditionLabel.Location = new System.Drawing.Point(12, 106);
            this.customConditionLabel.Name = "customConditionLabel";
            this.customConditionLabel.Size = new System.Drawing.Size(122, 17);
            this.customConditionLabel.TabIndex = 3;
            this.customConditionLabel.Text = "Custom Condition:";
            // 
            // maxSimTimeText
            // 
            this.maxSimTimeText.Location = new System.Drawing.Point(330, 13);
            this.maxSimTimeText.Name = "maxSimTimeText";
            this.maxSimTimeText.Size = new System.Drawing.Size(135, 22);
            this.maxSimTimeText.TabIndex = 4;
            this.maxSimTimeText.Text = "0";
            this.maxSimTimeText.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // maxRunTimeText
            // 
            this.maxRunTimeText.Location = new System.Drawing.Point(330, 43);
            this.maxRunTimeText.Name = "maxRunTimeText";
            this.maxRunTimeText.Size = new System.Drawing.Size(135, 22);
            this.maxRunTimeText.TabIndex = 5;
            this.maxRunTimeText.Text = "00:00:00";
            this.maxRunTimeText.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // maxCyclesText
            // 
            this.maxCyclesText.Location = new System.Drawing.Point(330, 73);
            this.maxCyclesText.Name = "maxCyclesText";
            this.maxCyclesText.Size = new System.Drawing.Size(135, 22);
            this.maxCyclesText.TabIndex = 6;
            this.maxCyclesText.Text = "0";
            this.maxCyclesText.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // customConditionText
            // 
            this.customConditionText.Location = new System.Drawing.Point(15, 136);
            this.customConditionText.Name = "customConditionText";
            this.customConditionText.Size = new System.Drawing.Size(450, 85);
            this.customConditionText.TabIndex = 7;
            this.customConditionText.Text = "";
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(355, 236);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(110, 44);
            this.cancelButton.TabIndex = 9;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // saveButton
            // 
            this.saveButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.saveButton.Location = new System.Drawing.Point(228, 236);
            this.saveButton.Name = "saveButton";
            this.saveButton.Size = new System.Drawing.Size(110, 44);
            this.saveButton.TabIndex = 8;
            this.saveButton.Text = "Save";
            this.saveButton.UseVisualStyleBackColor = true;
            // 
            // DP_TerminationConditionsDialog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(477, 292);
            this.ControlBox = false;
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.saveButton);
            this.Controls.Add(this.customConditionText);
            this.Controls.Add(this.maxCyclesText);
            this.Controls.Add(this.maxRunTimeText);
            this.Controls.Add(this.maxSimTimeText);
            this.Controls.Add(this.customConditionLabel);
            this.Controls.Add(this.maxCyclesLabel);
            this.Controls.Add(this.maxRunTimeLabel);
            this.Controls.Add(this.maxSimTimeLabel);
            this.Name = "DP_TerminationConditionsDialog";
            this.ShowIcon = false;
            this.Text = "Set Termination Conditions";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label maxSimTimeLabel;
        private System.Windows.Forms.Label maxRunTimeLabel;
        private System.Windows.Forms.Label maxCyclesLabel;
        private System.Windows.Forms.Label customConditionLabel;
        private System.Windows.Forms.TextBox maxSimTimeText;
        private System.Windows.Forms.TextBox maxRunTimeText;
        private System.Windows.Forms.TextBox maxCyclesText;
        private System.Windows.Forms.RichTextBox customConditionText;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button saveButton;
    }
}