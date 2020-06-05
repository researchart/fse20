package task;
import java.awt.Color;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class Task1 extends javax.swing.JFrame {

	// Add a ChangeListener that changes the labels text to the new value of the
	// slider and changes the font color to:
	// red : when lower than 50
	// black : when exactly 50
	// green : when higher than 50
	// Use a similar pattern to that in the example code.
	private void InitializeHandlers() {
		// --- Your code here
     
		// --- 
	}

	public Task1() {
		initComponents();
	}

	private void initComponents() {

		setSlider(new javax.swing.JSlider());
		jLabel1 = new javax.swing.JLabel();
		setOutputlabel(new javax.swing.JLabel());

		setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

		InitializeHandlers();

		jLabel1.setText("Value:");

		getOutputlabel().setText("50");

		javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
		getContentPane().setLayout(layout);
		layout.setHorizontalGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
				.addGroup(layout.createSequentialGroup()
						.addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
								.addGroup(layout.createSequentialGroup().addGap(40, 40, 40).addComponent(jLabel1)
										.addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
										.addComponent(getOutputlabel()))
						.addGroup(layout.createSequentialGroup().addGap(54, 54, 54).addComponent(getSlider(),
								javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE,
								javax.swing.GroupLayout.PREFERRED_SIZE)))
						.addContainerGap(60, Short.MAX_VALUE)));
		layout.setVerticalGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
				.addGroup(layout.createSequentialGroup().addContainerGap(27, Short.MAX_VALUE)
						.addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
								.addComponent(jLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 25,
										javax.swing.GroupLayout.PREFERRED_SIZE)
								.addComponent(getOutputlabel()))
						.addGap(18, 18, 18).addComponent(getSlider(), javax.swing.GroupLayout.PREFERRED_SIZE,
								javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)));

		pack();
	}

	public static void main(String args[]) {
		try {
			for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
				if ("Nimbus".equals(info.getName())) {
					javax.swing.UIManager.setLookAndFeel(info.getClassName());
					break;
				}
			}
		} catch (ClassNotFoundException ex) {
			java.util.logging.Logger.getLogger(Task1.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
		} catch (InstantiationException ex) {
			java.util.logging.Logger.getLogger(Task1.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
		} catch (IllegalAccessException ex) {
			java.util.logging.Logger.getLogger(Task1.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
		} catch (javax.swing.UnsupportedLookAndFeelException ex) {
			java.util.logging.Logger.getLogger(Task1.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
		}

		java.awt.EventQueue.invokeLater(new Runnable() {
			public void run() {
				new Task1().setVisible(true);
			}
		});
	}

	public javax.swing.JSlider getSlider() {
		return slider;
	}

	public void setSlider(javax.swing.JSlider slider) {
		this.slider = slider;
	}

	public javax.swing.JLabel getOutputlabel() {
		return outputlabel;
	}

	public void setOutputlabel(javax.swing.JLabel outputlabel) {
		this.outputlabel = outputlabel;
	}

	private javax.swing.JLabel jLabel1;
	private javax.swing.JLabel outputlabel;
	private javax.swing.JSlider slider;
}
