
% this workflow will save MIP images in grayscale and rgb along X,Y and (depth) Z
% the imput 3D tiff stack 'your_3D_stack_name.tif' must have uniform x,y,z pixel size
% designed to work with .tif files generated with "fuse uncompressed tiff files" option in BigStitcher
% if more than 4Gb in size, .tiff metadata is corrupt
% to open such files in MATLAB "imread_big_to_8bit" function is used (adopted from Tristan Ursell)

strFilename = 'your_3D_stack_name.tif';
[stack_out, Nframes]= imread_big_to_8bit(strFilename);


% for MIP along Z dimention (number of frames)
[maxgray, maxind] = max(stack_out_5, [], 3);
m = size(threeDmatrix, 3);  % elements in colormap
c = hsv(m);

[sz_y, sz_x] = size(maxgray);
    MIP_R = uint8(zeros(sz_x, sz_y));
    MIP_G = uint8(zeros(sz_x, sz_y));
    MIP_B = uint8(zeros(sz_x, sz_y));

parfor rows = [1 : sz_y] 
    row = maxind(rows, :);
    temp_row_r = uint8(zeros(sz_x, 1));
    temp_row_g = uint8(zeros(sz_x, 1));
    temp_row_b = uint8(zeros(sz_x, 1));
    temp_row_gray = maxgray(rows, :);
    for pixel = [1 : sz_x]
        temp_row_r(pixel, 1) = temp_row_gray(1,pixel) * c(row(pixel),1);
        temp_row_g(pixel, 1) = temp_row_gray(1,pixel) * c(row(pixel),2);
        temp_row_b(pixel, 1) = temp_row_gray(1,pixel) * c(row(pixel),3);
    end
    MIP_R(:,rows) = temp_row_r;
    MIP_G(:,rows) = temp_row_g;
    MIP_B(:,rows) = temp_row_b;
end

%%
imwrite(maxgray, 'MIP_Z_gray.tif', 'Compression','none');
MIP = cat(3, MIP_R, MIP_G, MIP_B);  
imwrite(MIP, 'MIP_Z_rgb.tif', 'Compression','none');
%
tic
% for MIP along Y dimention    
    maxgray = max(stack_out_5, [], 2);
    maxgray = permute(maxgray, [1,3,2]);
    imwrite(maxgray, 'MIP_Y_gray.tif', 'Compression','none');
    
    MIP_R = bsxfun(@times, double(maxgray), c(:,1)');
    MIP_G = bsxfun(@times, double(maxgray), c(:,2)');
    MIP_B = bsxfun(@times, double(maxgray), c(:,3)');
    
    MIP = cat(3, uint8(MIP_R), uint8(MIP_G), uint8(MIP_B));
    imwrite(MIP, 'MIP_Y_rgb.tif', 'Compression','none');

% for MIP along X dimention
    maxgray = max(stack_out_5, [], 1);
    maxgray = permute(maxgray, [2,3,1]);
    imwrite(maxgray, 'MIP_X_gray.tif', 'Compression','none');
    
    MIP_R = bsxfun(@times, double(maxgray), c(:,1)');
    MIP_G = bsxfun(@times, double(maxgray), c(:,2)');
    MIP_B = bsxfun(@times, double(maxgray), c(:,3)');
    
    MIP = cat(3, uint8(MIP_R), uint8(MIP_G), uint8(MIP_B));
    imwrite(MIP, 'MIP_X_rgb.tif', 'Compression','none');
toc