namespace DomainPro.Analyst.Controls
{
    partial class DP_WatchedTypeDialog
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
            this.addButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.typeNameLabel = new System.Windows.Forms.Label();
            this.typeNameText = new System.Windows.Forms.TextBox();
            this.chooseTypeButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // addButton
            // 
            this.addButton.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.addButton.Location = new System.Drawing.Point(407, 50);
            this.addButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.addButton.Name = "addButton";
            this.addButton.Size = new System.Drawing.Size(82, 36);
            this.addButton.TabIndex = 6;
            this.addButton.Text = "Add";
            this.addButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelButton.Location = new System.Drawing.Point(502, 50);
            this.cancelButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(82, 36);
            this.cancelButton.TabIndex = 7;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // typeNameLabel
            // 
            this.typeNameLabel.AutoSize = true;
            this.typeNameLabel.Location = new System.Drawing.Point(9, 13);
            this.typeNameLabel.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.typeNameLabel.Name = "typeNameLabel";
            this.typeNameLabel.Size = new System.Drawing.Size(65, 13);
            this.typeNameLabel.TabIndex = 8;
            this.typeNameLabel.Text = "Type Name:";
            // 
            // typeNameText
            // 
            this.typeNameText.Location = new System.Drawing.Point(78, 11);
            this.typeNameText.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.typeNameText.Name = "typeNameText";
            this.typeNameText.Size = new System.Drawing.Size(413, 20);
            this.typeNameText.TabIndex = 9;
            // 
            // chooseTypeButton
            // 
            this.chooseTypeButton.Location = new System.Drawing.Point(502, 11);
            this.chooseTypeButton.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.chooseTypeButton.Name = "chooseTypeButton";
            this.chooseTypeButton.Size = new System.Drawing.Size(82, 20);
            this.chooseTypeButton.TabIndex = 10;
            this.chooseTypeButton.Text = "Choose...";
            this.chooseTypeButton.UseVisualStyleBackColor = true;
            // 
            // DP_WatchedTypeDialog
            // 
            this.AcceptButton = this.addButton;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.cancelButton;
            this.ClientSize = new System.Drawing.Size(596, 105);
            this.ControlBox = false;
            this.Controls.Add(this.chooseTypeButton);
            this.Controls.Add(this.typeNameText);
            this.Controls.Add(this.typeNameLabel);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.addButton);
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.Name = "DP_WatchedTypeDialog";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.Text = "Add New Type to Watch List";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label typeNameLabel;
        private System.Windows.Forms.Button addButton;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button chooseTypeButton;
        private System.Windows.Forms.TextBox typeNameText;
    }
}