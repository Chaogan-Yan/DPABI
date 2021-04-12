function filePathConf = EditConf(workingDir,flag)
% FORMAT filePathConf = EditConf(workingDir,command)
% Set .conf configuration file, parameters
% Input:
%   working_dir - working directory that generate scripts and Circos figure
%   command - string contains specific command character
%__________________________________________________________________________
% Written by DENG Zhao-Yu 210408 for DPARBI.
% Institute of Psychology, Chinese Academy of Sciences
% dengzy@psych.ac.cn
%__________________________________________________________________________
%%
% change working directory
cd(workingDir);

filePathConf = strcat(workingDir,'/CircosPlot.conf');
fid = fopen(filePathConf,'w');

fprintf(fid,'karyotype = CircosInput1_band.txt \n');
fprintf(fid,'dir   = . \n');
fprintf(fid,'file  = circos.svg \n');
fprintf(fid,'png   = no \n');
fprintf(fid,'svg   = yes \n');
fprintf(fid,'<ideogram> \n');
fprintf(fid,'<spacing> \n');
fprintf(fid,'default = 0.01r \n');
fprintf(fid,'</spacing> \n');
fprintf(fid,'radius    = 0.8r \n');
fprintf(fid,'thickness = 40p \n');
fprintf(fid,'fill      = yes \n');
% show external labels
if find(flag=='L')
else
    fprintf(fid,'show_label       = yes \n');
    fprintf(fid,'label_font       = bold \n');
    fprintf(fid,'label_with_tag	= yes \n');
    fprintf(fid,'label_radius     = 1r + 160p \n');
    fprintf(fid,'label_size       = 80 \n');
    fprintf(fid,'label_parallel   = yes \n');
end
% plot bands
fprintf(fid,'show_bands = yes \n');
fprintf(fid,'fill_bands = yes \n');
fprintf(fid,'band_stroke_thickness = 4 \n');
fprintf(fid,'band_stroke_color     = white \n');
fprintf(fid,'band_transparency = 4 \n');
fprintf(fid,'</ideogram> \n');
% show internal labels
if find(flag=='L')
else
    fprintf(fid,'<plots> \n');
    fprintf(fid,'<plot> \n');
    fprintf(fid,'type  = text \n');
    fprintf(fid,'color = black \n');
    fprintf(fid,'file  = CircosInput2_label.txt \n');
    fprintf(fid,'r0 = 1r+30p \n');
    fprintf(fid,'r1 = 1r+400p \n');
    fprintf(fid,'label_size = 40 \n');
    fprintf(fid,'label_font = bold \n');
    fprintf(fid,'label_parallel   = yes \n');
    fprintf(fid,'label_snuggle        = yes \n');
    fprintf(fid,'max_snuggle_distance = 1r \n');
    fprintf(fid,'snuggle_tolerance    = 0.25r \n');
    fprintf(fid,'snuggle_sampling     = 2 \n');
    fprintf(fid,'snuggle_refine       = yes \n');
    fprintf(fid,'</plot> \n');
    fprintf(fid,'</plots> \n');
end
% show ticks, hierarchical
if find(flag=='T')
else
    fprintf(fid,'show_ticks          = yes \n');
    fprintf(fid,'<ticks> \n');
    fprintf(fid,'radius               = dims(ideogram,radius_outer)+110p \n');
    fprintf(fid,'<tick> \n');
    fprintf(fid,'spacing        = 1u \n');
    fprintf(fid,'size           = 5p \n');
    fprintf(fid,'thickness      = 4p \n');
    fprintf(fid,'color          = black \n');
    fprintf(fid,'</tick> \n');
    fprintf(fid,'</ticks> \n');
end
% show relations of regioons
fprintf(fid,'<links> \n');
fprintf(fid,'<link> \n');
fprintf(fid,'file          = CircosInput3_link.txt \n');
fprintf(fid,'ribbon           = yes \n');
fprintf(fid,'flat             = yes \n');
fprintf(fid,'thickness        = 10 \n');
fprintf(fid,'radius           = 0.99r \n');
fprintf(fid,'bezier_radius    = 0r \n');
fprintf(fid,'crest            = 0.5 \n');
fprintf(fid,'bezier_radius_purity = 0.75 \n');
fprintf(fid,'</link> \n');
fprintf(fid,'</links> \n');
fprintf(fid,'<image> \n');
fprintf(fid,'<<include etc/image.conf>> \n');
fprintf(fid,'</image> \n');
fprintf(fid,'<<include etc/colors_fonts_patterns.conf>> \n');
fprintf(fid,'<<include etc/housekeeping.conf>> \n');



