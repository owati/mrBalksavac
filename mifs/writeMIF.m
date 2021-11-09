function writeMIF
% Read an RGB image file and write the r, g and b values of the image into
% a .mif file. The .mif file is largely just a text file but it is formated
% in a specific way, with a specific set of data placed in the header rows
% (first few rows) and then the rgb values are in the rows that follow.

% First, we receive the file from the user
[fName, pName] = uigetfile('*.*');

% and then read it into a 3-D array where the first dimension is the set of
% red values, the 2nd for green and the third for blue
im = imread([pName,fName]);

% If you want to resize the image to a specific size, then uncomment the
% following command. Note that if the image is too large, you may not be
% able to use it in the FPGA - it may be too large for the memory available
% on the FPGA or on the board. First decide how much memory rows are
% available to you and then resize the image to a value less than that.
% Note that for this .mif file, you will need 3 x num_cols x num_rows of
% your image. So, for a 128 x 128 image, you will need 3 x 128 x 128 memory
% rows to store the image.
% im = imresize(im,[128,128]);

% Get the image size. We will use this size for a number of things
im_size = size(im);

% Create a blank .mif file and name it using the file name of the image
% selected and the size of the image. Note that Matlab writes the number of
% rows as the first variable in the im_size and the number of columns as
% the second variable but when referring to images, we refer to them by
% width (number of columns) by the height (number of rows). Hence, in the
% file name, we choose the number of columns first.
fid = fopen(['.\mif\',fName(1:(end-4)),'_',num2str(im_size(2)),'x',num2str(im_size(1)),'.mif'],'w');

% Each row of the mif file will start with the line number. We will use a
% variable named "count" to hold the present line number.
count = 0;

% This next command is not needed if you will be writing 8-bitsfor each of
% r, g and b. The command imread stores the r, g and b values as 8-bit
% uint8 values. If you want to use fewer bits to represent each of these,
% then you will need to divide the values in the variable im. For
% instance, if you will be using 4 bits for r, 4 bits for g and 4 bits for
% b, then you will need to divide the values stored in im by 16 in each
% case. We use the floor command so that 255/2 = 15, not 16 i.e. the
% maximum value we want is 15.
im4bit = floor(double(im)/16);

% Write the header lines in the .mif file
fprintf(fid,'WIDTH = 12;\n');
fprintf(fid,'DEPTH = %d;\n',im_size(1)*im_size(2));
fprintf(fid,'ADDRESS_RADIX = HEX;\n');
fprintf(fid,'DATA_RADIX = HEX;\n');
fprintf(fid,'CONTENT BEGIN\n\n');

% Write the image data into the mif file, one pixel at a time. The for
% loops below select a pixel in the ith row and jth column and then write
% the red, and then the green and then the blue value into the .mif file.
% The kk loop iterates fom 1 to 3. The data written is in hexadecimal form
% and hence the fprintf command is called with %x to specify that the data
% should be entered as a hexadecimal
% The data written is in the format:
% line_number  :  r_[or g_or b_value];
% e.g. 55  : b;
% Note that the header file of the .mif file specifies the format of the
% data stored in it. You can modify these if you want a different number of
% bits per row and a different radix for storing the values (and the line
% numbers).
for i=1:im_size(1)
    for j=1:im_size(2)
        fprintf(fid,'%x  : %x%x%x;\n',count, im4bit(i,j,1),im4bit(i,j,2),im4bit(i,j,3));
        count = count + 1;
    end
end
fprintf(fid,'END;\n'); % to indicate the end of the .mif file
fclose(fid);


%% Uncommend this section in order to see the red, green and blue components of the image supplied.
% % To get the red components alone, we make the green and blue components
% % zeros.
% im2 = im;
% im2(:,:,2) = zeros(im_size(1),im_size(2));
% im2(:,:,3) = zeros(im_size(1),im_size(2));
% % To get the green components alone, we make the red and blue components
% % zeros.
% im3 = im;
% im3(:,:,1) = zeros(im_size(1),im_size(2));
% im3(:,:,3) = zeros(im_size(1),im_size(2));
% % To get the blue components alone, we make the red and green components
% % zeros.
% im4 = im;
% im4(:,:,1) = zeros(im_size(1),im_size(2));
% im4(:,:,2) = zeros(im_size(1),im_size(2));
% subplot(2,2,1)
% imshow(uint8(im2))
% title('Red components of the image')
% subplot(2,2,2)
% imshow(uint8(im3))
% title('Green components of the image')
% subplot(2,2,3)
% imshow(uint8(im4))
% title('Blue components of the image')
