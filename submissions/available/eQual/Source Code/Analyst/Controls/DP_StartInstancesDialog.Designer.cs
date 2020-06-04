namespace DomainPro.Analyst.Controls
{
    partial class DP_StartInstancesDialog
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
            this.instructionLabel = new System.Windows.Forms.Label();
            this.nextButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.backButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // instructionLabel
            // 
            this.instructionLabel.AutoSize = true;
            this.instructionLabel.Location = new System.Drawing.Point(13, 13);
            this.instructionLabel.Name = "instructionLabel";
            this.instructionLabel.Size = new System.Drawing.Size(0, 17);
            this.instructionLabel.TabIndex = 0;
            // 
            // nextButton
            // 
            this.nextButton.Location = new System.Drawing.Point(140, 399);
            this.nextButton.Name = "nextButton";
            this.nextButton.Size = new System.Drawing.Size(110, 44);
            this.nextButton.TabIndex = 2;
            this.nextButton.Text = "Next";
            this.nextButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(267, 399);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(110, 44);
            this.cancelButton.TabIndex = 3;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // backButton
            // 
            this.backButton.Enabled = false;
            this.backButton.Location = new System.Drawing.Point(13, 399);
            this.backButton.Name = "backButton";
            this.backButton.Size = new System.Drawing.Size(110, 44);
            this.backButton.TabIndex = 4;
            this.backButton.Text = "Back";
            this.backButton.UseVisualStyleBackColor = true;
            // 
            // DP_StartInstancesDialog
            // 
            this.AcceptButton = this.nextButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(389, 455);
            this.ControlBox = false;
            this.Controls.Add(this.backButton);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.nextButton);
            this.Controls.Add(this.instructionLabel);
            this.Name = "DP_StartInstancesDialog";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Set Start Instances";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label instructionLabel;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button nextButton;
        private System.Windows.Forms.Button backButton;
    }
}