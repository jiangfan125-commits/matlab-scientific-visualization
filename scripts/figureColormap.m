function cmap = figureColormap(name, n)
%FIGURECOLORMAP  Perceptually ordered continuous maps for MATLAB.
%
%   cmap = figureColormap('viridis')
%   cmap = figureColormap('cividis', 256)
%   colormap(figureColormap('viridis'))
%
%   Available: viridis, cividis, plasma, magma, parula (built-in), gray.
%
%   Why not the default: MATLAB's historical default `jet` is a rainbow map.
%   Rainbow maps create false boundaries where the colour wheel wraps, have no
%   inherent order, and lose detail for some colour-vision deficiencies. Use a
%   gentle, monotonic-lightness map for ordered magnitude.
%
%   Diverging data needs a meaningful centre and is NOT provided here. If
%   values depart from a real zero, build a diverging map explicitly and
%   state the centre:
%
%       c = [figureColormap('cividis',128); flipud(figureColormap('magma',128))];
%       % ...or use the built-in 'bluewhitered' pattern with a stated centre.
%
%   These curves are 11-anchor linear interpolations of the published maps,
%   which is accurate enough for display but not byte-identical to Matplotlib.
%   If exact values matter, export the reference map and compare.
%
%   See also figurePalette, figureStyle.

if nargin < 2 || isempty(n)
    n = 256;
end
if nargin < 1 || isempty(name)
    name = 'viridis';
end

key = lower(strtrim(char(name)));

switch key
    case 'parula'
        cmap = parula(n);
        return
    case 'gray'
        cmap = gray(n);
        return
    case 'viridis'
        a = [ 68   1  84;
              72  40 120;
              62  74 137;
              49 104 142;
              38 130 142;
              31 158 137;
              53 183 121;
             109 205  89;
             180 222  44;
             233 229  27;
             253 231  37];
    case 'cividis'
        a = [  0  32  76;
               0  42 102;
              40  60 110;
              69  80 119;
              95 101 124;
             120 123 129;
             147 146 129;
             176 170 124;
             208 195 114;
             241 221  97;
             255 233  69];
    case 'plasma'
        a = [ 13   8 135;
              76   4 162;
             125   3 168;
             168  34 150;
             203  70 121;
             229 107  93;
             248 148  65;
             253 191  41;
             240 234  22;
             249 252  11;
             240 249  33];
    case 'magma'
        a = [  0   0   4;
              28  16  68;
              79  18 123;
             129  37 129;
             181  54 122;
             229  80 100;
             251 135  97;
             254 194 135;
             252 253 191;
             254 255 246;
             252 253 191];
    otherwise
        error('figureColormap:unknown', ...
            ['Unknown map "%s". Use viridis, cividis, plasma, magma, ' ...
             'parula, or gray.'], key);
end

t   = linspace(0, 1, size(a, 1)).';
tt  = linspace(0, 1, n).';
cmap = [interp1(t, a(:,1), tt, 'linear'), ...
        interp1(t, a(:,2), tt, 'linear'), ...
        interp1(t, a(:,3), tt, 'linear')] / 255;
cmap = min(max(cmap, 0), 1);
end