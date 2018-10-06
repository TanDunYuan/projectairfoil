# projectairfoil
This project takes in a NACA 4 series airfoil, angle of attack, freestream velocity and number of panels on the airfoil as input.
The script then returns coefficient of lift, and plot the velocity vectors and streamlines around the airfoil using a panel code method. 
Note: if airfoil is too thin the mesh size of streamline should be smaller for better streamline pictures. 

airfoil.m is the main application using cdoublet and panelgen as functions in airfoil.m
