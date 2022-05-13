function filePathConf = EditConf(workingDir,CircosConf)
% FORMAT filePathConf = EditConf(workingDir,flag,offsetPixel)
% Set .conf configuration file, parameters
% Input:
%   working_dir - working directory that generate scripts and Circos figure
%   CircosConf.flag - string contains specific command character
%       'L' - show node labels
%       'N' - show network label
%       'P' - set labels perpendicular
%   CircosConf.offsetPixel - incase of adapting perpendicular label, scale inner content
%   CircosConf.
%__________________________________________________________________________
% Written by DENG Zhao-Yu 210408 for DPARBI. Update in 220412
% Institute of Psychology, Chinese Academy of Sciences
% dengzy@psych.ac.cn
%__________________________________________________________________________
%%

% offsetPixel = 200; % offset pixels to better organization of partions

flag = CircosConf.flag;
offsetPixel = CircosConf.offsetPixel;
textSize = CircosConf.textSize;

% change working directory
cd(workingDir);

filePathConf = strcat(workingDir,'/CircosPlot.conf');
fid = fopen(filePathConf,'w');

fprintf(fid,'karyotype = CircosInput1_network.txt \n');
% fprintf(fid,'dir   = . \n');
% fprintf(fid,'file  = circos.svg \n');
% fprintf(fid,'png   = no \n');
% fprintf(fid,'svg   = yes \n');
fprintf(fid,'<ideogram> \n');
fprintf(fid,'<spacing> \n');
fprintf(fid,'default = 0.01r \n');
fprintf(fid,'</spacing> \n');
fprintf(fid,'radius    = 0.92r \n'); % global radius(R) OUTTER
fprintf(fid,'thickness = 20p \n');
fprintf(fid,'fill      = yes \n');

% show external labels
if contains(flag,'N')
    fprintf(fid,'show_label       = yes \n');
    fprintf(fid,'label_font       = bold \n');
    fprintf(fid,'label_with_tag	= yes \n');
    fprintf(fid,'label_radius     = 1r+30p \n'); % network label radius(R)
    fprintf(fid,'label_size       = 80 \n');
    fprintf(fid,'label_parallel   = yes \n');
end

% % plot bands
% fprintf(fid,'show_bands = yes \n');
% fprintf(fid,'fill_bands = yes \n');
% fprintf(fid,'band_stroke_thickness = 4 \n');
% fprintf(fid,'band_stroke_color     = white \n');
% % fprintf(fid,'band_transparency = 0.7 \n');

fprintf(fid,'</ideogram> \n');

% show internal labels
if contains(flag,'L')
    fprintf(fid,'<plots> \n');
    fprintf(fid,'<plot> \n');
    fprintf(fid,'type  = text \n');
    fprintf(fid,'color = black \n');
    fprintf(fid,'file  = CircosInput3_label.txt \n');
    
    fprintf(fid,'r0 = 0.9r+30p-%up \n',offsetPixel); % band label radius(R) inner +20p
    fprintf(fid,'r1 = 0.9r+500p-%up \n',offsetPixel); % band label radius(R) outter 380p
    fprintf(fid,'label_size = %d \n', textSize);
    fprintf(fid,'label_font = light \n');
    if contains(flag,'P')
        fprintf(fid,'label_parallel   = yes \n');
    end
    fprintf(fid,'label_snuggle        = yes \n');
    fprintf(fid,'max_snuggle_distance = 1r \n');
    fprintf(fid,'snuggle_tolerance    = 0.25r \n');
    fprintf(fid,'snuggle_sampling     = 2 \n');
    fprintf(fid,'snuggle_refine       = yes \n');
    fprintf(fid,'</plot> \n');
    fprintf(fid,'</plots> \n');
end

% % show ticks, hierarchical
% if find(flag=='T')
% else
%     fprintf(fid,'show_ticks          = yes \n');
%     fprintf(fid,'<ticks> \n');
%     
%     fprintf(fid,'radius              = dims(ideogram,radius_outer)+%up \n',offsetPixel); % ticks radius(R)
%     fprintf(fid,'<tick> \n');
%     fprintf(fid,'spacing        = 1u \n');
%     fprintf(fid,'size           = 5p \n');
%     fprintf(fid,'thickness      = 4p \n');
%     fprintf(fid,'color          = black \n');
%     fprintf(fid,'</tick> \n');
%     fprintf(fid,'</ticks> \n');
% end

% show highlights(cortical regions)
fprintf(fid,'<highlights> \n');
fprintf(fid,'z      = 0 \n');
% fprintf(fid,'fill_color = green \n');
fprintf(fid,'<highlight> \n');
fprintf(fid,'file       = CircosInput2_region.txt \n');
fprintf(fid,'r0         = 0.85r-%up \n',offsetPixel);
fprintf(fid,'r1         = 0.9r-%up \n',offsetPixel);
fprintf(fid,'stroke_thickness = 6 \n');
fprintf(fid,'stroke_color     = white \n');
fprintf(fid,'</highlight> \n');
fprintf(fid,'</highlights> \n');
fprintf(fid,' \n');

% show relations of regioons
fprintf(fid,'<links> \n');
fprintf(fid,'<link> \n');
fprintf(fid,'file          = CircosInput4_link.txt \n');
fprintf(fid,'ribbon           = yes \n');
fprintf(fid,'flat             = yes \n');
fprintf(fid,'thickness        = 10 \n');

fprintf(fid,'radius           = 0.83r-%up \n',offsetPixel); % link radius(R) changed origine 0.99
fprintf(fid,'bezier_radius    = 0r \n');
fprintf(fid,'crest            = 0.5 \n');
fprintf(fid,'bezier_radius_purity = 0.75 \n');
% fprintf(fid,'bezier_transparency = 0.5 \n'); % useless
fprintf(fid,'</link> \n');
fprintf(fid,'</links> \n');
fprintf(fid,'<image> \n');
fprintf(fid,'<<include etc/image.conf>> \n');
fprintf(fid,'</image> \n');
fprintf(fid,'<<include etc/colors_fonts_patterns.conf>> \n');
fprintf(fid,'<<include etc/housekeeping.conf>> \n');
% fprintf(fid,'<colors> \n');
% fprintf(fid,'<<include cort_color.conf>> \n');
% fprintf(fid,'</colors> \n');



