namespace DomainPro.Analyst.Controls
{
    partial class DP_ModelTreeDialog
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
            this.selectButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // selectButton
            // 
            this.selectButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.selectButton.Location = new System.Drawing.Point(466, 363);
            this.selectButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.selectButton.Name = "selectButton";
            this.selectButton.Size = new System.Drawing.Size(82, 36);
            this.selectButton.TabIndex = 7;
            this.selectButton.Text = "Select";
            this.selectButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(561, 363);
            this.cancelButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(82, 36);
            this.cancelButton.TabIndex = 8;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // DP_ModelTreeDialog
            // 
            this.AcceptButton = this.selectButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(654, 410);
            this.ControlBox = false;
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.selectButton);
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.Name = "DP_ModelTreeDialog";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Select Type";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button selectButton;
        private System.Windows.Forms.Button cancelButton;

    }
}