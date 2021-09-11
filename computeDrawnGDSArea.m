% 2021/09/10 R Miyakawa
%
% Computes the drawn area in a GDS file
%
% Requires that GDS is flattened and does not contain references. 
%
% TODO: 
%   - Filter by structure
%   - Recursively call to handle sref and aref structures
% 

function [area, unit] = computeDrawnGDSArea(fname)

bPatch = true;

if (nargin == 0)
    [p, d] = uigetfile();
    fname = fullfile(d, p);
end

[d, p, e] = fileparts(fname);

gdtfname = fullfile(d, [p '.gdt']);

% Write gds to file
fprintf('Writing GDT file: %s\n', gdtfname);
[~, out] = system(sprintf('./gds2gdt.Darwin %s %s', fname, gdtfname));



% Now parse gdt file:
fprintf('Parsing GDT...\n');

fid = fopen(gdtfname);

lineCount = 0;
braceCount = 0;
shapeCount = 0;
area = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    
    if tline(1) == '#'
        continue;
    end
    
    % Look for header:
    [headMatch, ~] = regexp(tline, 'lib[\s\w''\.]*(\d\.\d+)\s(\de-\d\d)', 'tokens', 'match');
    if (length(headMatch)) > 0
       dbunit = eval(headMatch{1}{1});
       gridunit = eval(headMatch{1}{2});
       
       unit = gridunit/dbunit;
       fprintf('GDS unit: %g\n', unit);
    end
    
    
    lineCount = lineCount + 1;
    
    % Count left and right braces:
    leftBraceCt = length(regexp(tline, '{', 'match'));
    rightBraceCt = length(regexp(tline, '}', 'match'));
    
    braceCount = braceCount + leftBraceCt - rightBraceCt;
    
    % boundaries match signature: xy( ** )
    
    [boundaryMatch, ~] = regexp(tline,...
        'xy\(([-\d\.\s]+)\)', 'tokens', 'match');

%          disp(tline)

         
    if length(boundaryMatch)
        coordsCell = regexp(boundaryMatch{1}, '\s', 'split');
        coordsAr = cellfun(@eval, coordsCell{1});
        coords = reshape(coordsAr, 2, length(coordsAr)/2)';
        
        shapeCount = shapeCount + 1;
        
        % Compute area using shoelace method
        area = area + shoelaceArea(coords);
        
        if bPatch
            patch(coords(:,1),coords(:,2), 'g');
        end
    end
    
    
end

fprintf('Found %d shapes\n', shapeCount);
