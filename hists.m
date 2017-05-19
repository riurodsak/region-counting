function [histlength, histarea] = hists(lengths,areas,filename)
    % Histograms of given lengths and areas data
    histlength = figure('Name',strcat('Lengths ',filename),'Position',[100,100,320,200]);
    histogram(lengths);
    title('Length histogram');
    xlabel('Length (mm)');
    ylabel('Counts');
    xlim([0, 15]);
    
    histarea = figure('Name',strcat('Areas',filename),'Position',[100,100,320,200]);
    histogram(areas,10);
    title('Area histogram');
    xlabel('Area (mm^2)');
    ylabel('Number of regions');
end