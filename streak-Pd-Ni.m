#################################################################################
##
##  Program to obtain the radial expansion data from Streak images when exploding an exploding wire.
##
##      Usage: Just put in the same folder the streak files in "*.dat" format, this file and the file "display_rounded_matrix.m" 
##      and execute this file in an Octave console.
##      Based on previous programs (streak) made also by me.
##
#################################################################################








more off; %To make the lines display when they appear in the script, not at the end of it.

clear; %Cleaning memory. Just in case.

tic; %Time control for the script.

dist = 25; %µm per pixel in distance. Checked for this experiment. EACH EXPERIMENT MIGHT HAVE DIFFERENT VALUES.


files = glob("*.dat"); %All the streak files in an structure.


################
## General loop. Made for each streak file:
################
for i=1 : size(files)(1)%Number of files with Streaks in the folder.
    ####
    ## Which shot is and how much is the sweep time in µs?
    ####
    shot = char(files(i)) %Shot name. Displayed in order to see were it goes the script and if it stops, in which Streak..

    sweep = str2double(shot(end-7:end-6)) %µs of sweeping time in the streak images. Form the shot file name, that always follows the same standard of the sweep time at the end of the filename with 2 cyphers ("05", "10", etc.)
    %If this standard changes, the sweep line must follow the changes.
    
    ####
    ## Opening the picture and choosing illumination values and time constant in µs:
    ####

    disp("Opening streak image.");

    [file, msg] = fopen(shot, "r");
    if (file == -1) 
       error ("Unable to open file name: %s, %s",shot, msg); 
    endif; 
    
    disp("Processing it.");

    radius = []; %They must be empty every iteration.
    radios_pixel = [];

    #Charge the image as a matrix: (IT MUST BE ALREADY FORMATTED AS SUCH)
    Streak = dlmread(file);
    fclose(file);

    ti = sweep/rows(Streak); %Time constant in ¡¡¡¡¡µs!!!! 
    
    maximum_light =max(max(Streak(450:550))); %Maximum light in illumination zone (hopefully)
    
    ####
    ## In each row of the Streak, find two peaks based on light intensity:
    ####    
    for i=1:rows(Streak) %Time: Form 1 to 1024 pixels, equal to sweep time.
  
        vector = Streak(i,:); %Row i, all columns.

        maxim = max(vector); %Maximum light emission in the row.

        light = 0.85*maxim; % 85%Maximum of the light emission of this line. Peak border

        if maxim < 65535  %&& real_data > 1.25*light_fondo%Do the math just if is not a saturated row AND there is enough signal from the metal gas
            rad = find(vector>light); %Positions of the light borders
            radius = [radius;i,rad(1),rad(end)]; %Storing them as time - radius values in pixels.
        endif;

        radios_pixel = [radios_pixel; radius]; %To perform a visual inspection of the resultant radii;
    endfor;
    
    radius = [(radius(:,1)-radius(1,1)).*ti ,  abs(radius(:,2)-radius(:,3)).*0.5.*dist]; %Conversion to µs and milimeters and zero placement.



    ###
    # Radial data overimposed over the original image for checking purposes:
    ###

    hf = figure("visible","off"); %Figure to print.
    imagesc(Streak'); %Image to extract radiii from. It is trasposed to be as the extracted radial data.
    hold; %More things to show in the graph, so maintiang what is in there.
    plot(radios_pixel(:,1), radios_pixel(:,2), ".k",   radios_pixel(:,1), radios_pixel(:,3), ".r"); %Radial points in pixels
    title(horzcat(shot)); %Title: Shot name
    print(hf, horzcat(shot(1:end-4), "-radius.jpg")); %JPG format much faster than PDF in making a file



    ###
    # Saving file with radial expansion in time:
    ###
    %Radius points.
    disp("Saving files.");
    
    name = horzcat(shot(1:end-4), "_radio.txt"); %Adding the right sufix to the shot name.
    output = fopen(name,"w"); %Opening the file.
    fdisp(output,"t(µs)  r(µm)"); %first line of stored file.
    redond = [4 3]; %Saved precision 
    rad = [radius(:,1) radius(:,2)]; %Making the vectors columns to store
    display_rounded_matrix(rad, redond, output); 
    fclose(output); %Closing the file.

endfor;



###
# Total processing time
###

timing = toc;
disp("Script streak-Pd-Ni execution time:")
disp(timing)
disp(" seconds")

more on; %To make the lines display when they appear in the script, not at the end of it.

#That's...that's all, folks! 
