# region-counting
Matlab script for the analysis of regions contained in a image.

### Steps to follow
1. Start opening 'outlining.m'. This script processes a .png file and outputs a binary image with the region borders drawn in white. 
2. 'regionizator.m' gets that image and creates Region structs with information about their size, position and number of total pixels. The script outputs a superimposed colored image with the regions, another image only with the regions, and histograms of the length and area of these regions.


### To Do List
- Create a function in 'Region.m' to find the center of each Region. 
- Display the image with each Region marked with it's ID for easy indentification.
- Develop a more user-friendly GUI for the whole program.
