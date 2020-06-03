namespace DomainPro.Core.Controls
{
    partial class DP_ProjectSettingsDialog
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
            this.projectNameLabel = new System.Windows.Forms.Label();
            this.projectNameTextBox = new System.Windows.Forms.TextBox();
            this.projectLocationLabel = new System.Windows.Forms.Label();
            this.folderTextBox = new System.Windows.Forms.TextBox();
            this.browseButton = new System.Windows.Forms.Button();
            this.modelLanguageLabel = new System.Windows.Forms.Label();
            this.languageNameTextBox = new System.Windows.Forms.TextBox();
            this.okButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // projectNameLabel
            // 
            this.projectNameLabel.AutoSize = true;
            this.projectNameLabel.Location = new System.Drawing.Point(13, 15);
            this.projectNameLabel.Name = "projectNameLabel";
            this.projectNameLabel.Size = new System.Drawing.Size(49, 17);
            this.projectNameLabel.TabIndex = 0;
            this.projectNameLabel.Text = "Name:";
            // 
            // projectNameTextBox
            // 
            this.projectNameTextBox.Location = new System.Drawing.Point(125, 12);
            this.projectNameTextBox.Name = "projectNameTextBox";
            this.projectNameTextBox.Size = new System.Drawing.Size(339, 22);
            this.projectNameTextBox.TabIndex = 1;
            // 
            // projectLocationLabel
            // 
            this.projectLocationLabel.AutoSize = true;
            this.projectLocationLabel.Location = new System.Drawing.Point(13, 86);
            this.projectLocationLabel.Name = "projectLocationLabel";
            this.projectLocationLabel.Size = new System.Drawing.Size(66, 17);
            this.projectLocationLabel.TabIndex = 2;
            this.projectLocationLabel.Text = "Location:";
            // 
            // folderTextBox
            // 
            this.folderTextBox.Location = new System.Drawing.Point(125, 83);
            this.folderTextBox.Name = "folderTextBox";
            this.folderTextBox.Size = new System.Drawing.Size(339, 22);
            this.folderTextBox.TabIndex = 3;
            // 
            // browseButton
            // 
            this.browseButton.Location = new System.Drawing.Point(483, 83);
            this.browseButton.Name = "browseButton";
            this.browseButton.Size = new System.Drawing.Size(110, 23);
            this.browseButton.TabIndex = 4;
            this.browseButton.Text = "Browse...";
            this.browseButton.UseVisualStyleBackColor = true;
            // 
            // modelLanguageLabel
            // 
            this.modelLanguageLabel.AutoSize = true;
            this.modelLanguageLabel.Location = new System.Drawing.Point(13, 49);
            this.modelLanguageLabel.Name = "modelLanguageLabel";
            this.modelLanguageLabel.Size = new System.Drawing.Size(76, 17);
            this.modelLanguageLabel.TabIndex = 5;
            this.modelLanguageLabel.Text = "Language:";
            // 
            // languageNameTextBox
            // 
            this.languageNameTextBox.Enabled = false;
            this.languageNameTextBox.Location = new System.Drawing.Point(125, 46);
            this.languageNameTextBox.Name = "languageNameTextBox";
            this.languageNameTextBox.Size = new System.Drawing.Size(339, 22);
            this.languageNameTextBox.TabIndex = 6;
            // 
            // okButton
            // 
            this.okButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.okButton.Location = new System.Drawing.Point(354, 128);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(110, 44);
            this.okButton.TabIndex = 7;
            this.okButton.Text = "OK";
            this.okButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(483, 128);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(110, 44);
            this.cancelButton.TabIndex = 8;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // DP_ProjectSettingsDialog
            // 
            this.AcceptButton = this.okButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(603, 184);
            this.ControlBox = false;
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.languageNameTextBox);
            this.Controls.Add(this.modelLanguageLabel);
            this.Controls.Add(this.browseButton);
            this.Controls.Add(this.folderTextBox);
            this.Controls.Add(this.projectLocationLabel);
            this.Controls.Add(this.projectNameTextBox);
            this.Controls.Add(this.projectNameLabel);
            this.Name = "DP_ProjectSettingsDialog";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Project Settings";
            this.TopMost = true;
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label projectNameLabel;
        private System.Windows.Forms.Label projectLocationLabel;
        private System.Windows.Forms.Label modelLanguageLabel;
        private System.Windows.Forms.TextBox folderTextBox;
        private System.Windows.Forms.TextBox languageNameTextBox;
        private System.Windows.Forms.TextBox projectNameTextBox;
        private System.Windows.Forms.Button browseButton;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.Button cancelButton;
    }
}