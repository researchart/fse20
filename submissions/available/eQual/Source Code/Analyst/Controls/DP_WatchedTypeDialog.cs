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
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using DomainPro.Core.Types;

namespace DomainPro.Analyst.Controls
{
    public partial class DP_WatchedTypeDialog : Form
    {
        private DP_AbstractType autocompleteType;
        private AutoCompleteStringCollection suggestions = new AutoCompleteStringCollection();

        public string WatchedTypeText
        {
            get { return typeNameText.Text; }
        }

        public DP_WatchedTypeDialog()
        {
            InitializeComponent();

            typeNameText.AutoCompleteMode = AutoCompleteMode.Suggest;
            typeNameText.AutoCompleteSource = AutoCompleteSource.CustomSource;
            typeNameText.AutoCompleteCustomSource = suggestions;

            autocompleteType = DomainProAnalyst.Instance.SelectedSimulation.ModelType;
            foreach (DP_AbstractSemanticType type in autocompleteType.Structure.Types)
            {
                suggestions.Add(type.FullName);
            }

            typeNameText.TextChanged += TypeNameTextChanged;
            chooseTypeButton.Click += ChooseTypeButtonClick;
        }

        private void ChooseTypeButtonClick(object sender, EventArgs e)
        {
            DP_ModelTreeDialog modelTreeDialog = new DP_ModelTreeDialog();
            DialogResult typeSelected = modelTreeDialog.ShowDialog();
            if (typeSelected == DialogResult.OK)
            {
                if (modelTreeDialog.Selected != null)
                {
                    string typeName = modelTreeDialog.Selected.FullPath;
                    typeNameText.Text = typeName.Substring(typeName.IndexOf('.') + 1);
                }
            }
            modelTreeDialog.Dispose();
        }

        private void TypeNameTextChanged(object sender, EventArgs e)
        {
            int lastDot = typeNameText.Text.LastIndexOf('.');
            DP_AbstractType newAutocompleteType;

            if (lastDot != -1)
            {
                string autocompleteTypeName = typeNameText.Text.Substring(0, lastDot);
                newAutocompleteType = DomainProAnalyst.Instance.SelectedSimulation.ModelType.FindTypeByFullName(autocompleteTypeName);
            }
            else
            {
                newAutocompleteType = DomainProAnalyst.Instance.SelectedSimulation.ModelType;
                
            }

            if (newAutocompleteType != autocompleteType)
            {
                suggestions.Clear();
                if (newAutocompleteType != null)
                {
                    autocompleteType = newAutocompleteType;
                    foreach (DP_AbstractSemanticType type in autocompleteType.Structure.Types)
                    {
                        suggestions.Add(type.FullName);
                    }
                }
            }
        }
    }
}
