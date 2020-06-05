Help file for using the GD option in Staliro:

1) Replace the inport block with a Repeating sequence block and replace the "Time values" with parameter "T" and the Output values with parameter "U" and specify them as
   model workspace parameters. (This allows for assigning values to these parameters in the linearization phase. See the model "steamcondense_RNN_22.slx" as an example.)
2) Pass the Simulink model name to the GD_parameters and use the "GDBlackbox" function as the input model to Staliro ( This function assign values to these parameters 
   progremmatically using the following lines of code:
       mdlWks = get_param('steamcondense_RNN_22','ModelWorkspace');
       assignin(mdlWks,'T',TU')
       assignin(mdlWks,'U',U')
3) In order to get system linearizations, inside your Simulink model, specify the linearization I/O using linear analysis point tool:
   -Create an Input perturbation port on the Input w.r.t which you want to test the system
   -If the specification is on a system output (staliro_options.spec_space is 'Y'), create an Output measurement port on that Output 
   O.w if the specification is defined on state space (staliro_options.spec_space is 'X') create an output which is an arbitrary function of all the
   states (states can affect this function directly or through other states.) and put the output measurement there. 
 3) Specify the GD_parameters (See help GD_parameters)
 
Output interpretation: 
    -The output should be treated as if varying times is allowed: results.run.bestSample consist of time samples and input values respectively.

Note that the SA optimizer returns after applying the Gradient Descent routine no matter if the problem is falsified or not, as creating new samples based on the input 
that optimal control approach has created needs further investigation.

Related functions in this directory: GdDoc, GDBlackbox, Apply_Opt_GD_default, GD_parameters, staliro_critical_info, optimal_descent