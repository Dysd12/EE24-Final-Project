Numerical Simulation:
To first get an idea of the simulated data, plot the theoretical win probability by running part1.m.
Part1 runs by choosing values for B0 and B1 and plotting p(win) using the equation 1/(1+exp(-(b0+b1*gold)) for a range of gold values.

To run the simulation, run part2.m, which will plot the results and output the results of the statistical tests 
to the Command Window. The simulation runs by choosing 10000 random gold values following a normal distribtuion. 
Those gold values also represent individual games. Then the probability of winning
for each gold value is calculated using the same equation as above. For each game, a win is simulated using a random number 
between 0 and 1, and if the number is below the calculated probability for that game, the game counts as a win. 
The parameters B0 and B1 are estimated using the fitglm function in Matlab. A 95% confidence interval is then constructed, after which we 
check if the parameters are within that confidence interval. 
The Chi-Square test is run by accumulating all the bins with data in them and using the standard chi-square test formula. 

Inference:
To find the actual B0 and B1 values from the data, run part3.m which will plot the actual data and the fitted curve
over it. It will also print out the B0 and B1 values to the Command Window. As a bonus, the standard deviation for gold at
the various times were measured.
The inference part runs by first importing a .csv file and converting the data into a datatable. The columns of interest are 
manually recorded and their positions are stored in an array. Clean the data to make sure no cells are missing data.
Then use the fitglm function again to find the parameters B0 and B1. Then plot the equation with the discovered parameters. 
