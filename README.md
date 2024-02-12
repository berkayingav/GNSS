# GNSS
In this project, RİNEX files taken from NASA's website were used primarily for visible satellite estimation. By entering the data of a specific location, hourly visible satellites were visualized on the skyplot chart using the functions in the Navigation ToolBox in MATLAB.Satellite positions and velocities were obtained using the gnssconstellation function. Then, azemuth, elevation angles and visibility, that is, visible satellites, were obtained with the help of the lookangles function. Then, pseudorange distance values were calculated with the pseudoranges function. After visualizing with the Skyplot graphic, a menu was created in the last part to display the visible satellites at the desired time. These operations are performed for GPS and GALILEO GNSS systems and options 1 and 2 are offered. For detailed explanation, the link to my own videos is below.

1-https://www.youtube.com/watch?v=ezNt8eUOfio&t=2s
2-https://www.youtube.com/watch?v=w7IWP-e38J8
3-https://www.youtube.com/watch?v=fs-fflIVocI

Secondly, the algorithm of the mathematical formulas of the user location estimation LSE (Least Square Estimation) process was provided and the receiver location estimation was achieved through pseudorange values and satellite positions.Using DOP formulas on the design matrix, VDOP, HDOP and PDOP values were calculated and collected in a matrix. Position estimation errors were calculated by subtracting the starting position and the calculated position from each other. Finally, the obtained data were visualized separately and the estimated location estimation process was achieved. For detailed explanation, the link to my own videos is below.

1-https://www.youtube.com/watch?v=s9SvpBhqfBU
2-https://www.youtube.com/watch?v=LrisrfdugXg
3-https://www.youtube.com/watch?v=Uk6ypKMCMXg




