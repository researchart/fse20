namespace DomainPro.Designer.Controls
{
    partial class DP_TreeWindow
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
            this.modelTreeView = new System.Windows.Forms.TreeView();
            this.SuspendLayout();
            // 
            // modelTreeView
            // 
            this.modelTreeView.LabelEdit = true;
            this.modelTreeView.Location = new System.Drawing.Point(13, 13);
            this.modelTreeView.Name = "modelTreeView";
            this.modelTreeView.Size = new System.Drawing.Size(257, 230);
            this.modelTreeView.TabIndex = 0;
            // 
            // DP_TreeWindow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(282, 255);
            this.Controls.Add(this.modelTreeView);
            this.Name = "DP_TreeWindow";
            this.ShowIcon = false;
            this.Text = "Model Tree";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TreeView modelTreeView;




    }
}