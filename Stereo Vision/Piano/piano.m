%---------------------------- Lab Assignment 2 --------------------------%

% Reading the left and right images %
left = imread('left_image.png');
right  = imread('right_image.png');


% Converting color to greyscale images %
leftI = mean(left, 3);
rightI = mean(right, 3);
[img_Height, img_Width] = size(leftI);
fprintf('Images converted to Greyscale...\n');

% Reducing the number of pixels 
newleftI = zeros((img_Height)/4,(img_Width)/4);
newrightI = zeros((img_Height)/4,(img_Width)/4);
i = 1; j = 1;p = 1; q = 1;

for j=1:(img_Width)/4
    for i=1:(img_Height)/4
    newleftI(i,j)= (leftI(p,q)+leftI(p+1,q)+leftI(p+2,q)+leftI(p+3,q)+leftI(p,q+1)+leftI(p+1,q+1)+leftI(p+2,q+1)+leftI(p+3,q+1)+leftI(p,q+2)+leftI(p+1,q+2)+leftI(p+2,q+2)+leftI(p+3,q+2)+leftI(p,q+3)+leftI(p+1,q+3)+leftI(p+2,q+3)+leftI(p+3,q+3))/16;
    newrightI(i,j)= (rightI(p,q)+rightI(p+1,q)+rightI(p+2,q)+rightI(p+3,q)+rightI(p,q+1)+rightI(p+1,q+1)+rightI(p+2,q+1)+rightI(p+3,q+1)+rightI(p,q+2)+rightI(p+1,q+2)+rightI(p+2,q+2)+rightI(p+3,q+2)+rightI(p,q+3)+rightI(p+1,q+3)+rightI(p+2,q+3)+rightI(p+3,q+3))/16;
    p = p+4; 
    end
    q = q+4;
    p = 1;
end
fprintf('Images scaled down...\n');
% Final disparity map %
DISP_FINAL = zeros(size(newleftI));
disparity_range = 50;
half_block = 1;
block_size = 2*half_block+1;
[img_Height, img_Width] = size(newleftI);

% Commence simple block matching %
fprintf('Commencing block matching\n');

for i = 1:img_Height
    % Min. Max. bounds for rows of blocks (and template)
    r_min = max(1,i-half_block);
    r_max = min(img_Height,i+half_block);
    
    for j = 1:img_Width
        % Min. Max. bounds for columns of blocks (and template)
        c_min = max(1,j-half_block);
        c_max = min(img_Width,j+half_block);
        
        % Declaring the search boundaries. Here we are performing the
        % search only to the right.
        d_min = 0;
        d_max = min(disparity_range,img_Width - c_max);
        
        %Extracting the template from right side image %
        template = newrightI(r_min:r_max, c_min:c_max);
        
        %Calculating the number of blocks to be compared in each iteration%
        block_num = d_max - d_min + 1;
        % Vector to store the difference between block and template %
        block_diff = zeros(block_num, 1);
    
    % Calculating the block differences %
    for p = d_min:d_max
        block = newleftI(r_min:r_max,c_min + p:c_max + p);
        block_index = p - d_min + 1;
        block_diff(block_index, 1) = sum(sum(abs(template - block)));
    end
    
    % Sorting out the indices of block_diff vector according to the increasing order of the SAD values % 
    [x, indices_sorted] = sort(block_diff);
    main_index = indices_sorted(1,1);
    disp = main_index + d_min - 1;
     
     if (main_index==1 || main_index == block_num)
         DISP_FINAL(i,j) = disp;
     else
         d1 = block_diff(main_index - 1);
         d2 = block_diff(main_index);
         d3 = block_diff(main_index + 1);
         DISP_FINAL(i, j) = disp - (0.5 * (d3 - d1) / (d1 - (2*d2) + d3));
     end
    end
    if (mod(i, 10) == 0)
		fprintf(' Finished processing row %d / %d \n', i, img_Height);
    end
end


figure(1);
imshow(DISP_FINAL,[]);
axis image;
colormap('jet');
colorbar;
title('Disparity map (Calculated)');

hold on

figure(2);
GT = parsePfm('disp1.pfm');
imshow(GT,[]);
axis image;
colormap('jet');
colorbar;
title('Disparity map (Ground Truth)');
