% 2021/09/10 R Miyakawa
%
% Computes the drawn area in a GDS file
%
% Requires that GDS is flattened and does not contain references. 
%
% 

function [area, areaStruct, shapeCount, unit] = getStructureArea(gdtfname, structureName, areaStruct)


fid = fopen(gdtfname);

currentCell = ' ';
shapeCount = 0;
area = 0;

if (nargin < 3)
    areaStruct = struct();
end




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
%        fprintf('GDS unit: %g\n', unit);
    end
    
%     disp(tline)
    
    [cellMatch, ~] = regexp(tline, 'cell[^\'']+''([\w\s]+)''', 'tokens', 'match');
    if length(cellMatch)
        currentCell = cellMatch{1}{1};
        continue
    end
    
    if (nargin > 1 && ~strcmp(currentCell, structureName))
%         fprintf('skipping cell %s\n', currentCell);
        continue 
    end
    
    % Detect record type:
    [recordTypeBoundary, ~] = regexp(tline, '^b?{?\d\sxy', 'match');

    [recordTypeSRef, ~] = regexp(tline, '^s{''([\w\s]+)''', 'tokens', 'match');
    [recordTypeARef, ~] = regexp(tline, '^a{''([\w\s]+)''', 'tokens', 'match');


    if ~isempty(recordTypeBoundary)
        recordType = 'boundary';
    elseif ~isempty(recordTypeSRef)
        recordType = 'sref';
    elseif ~isempty(recordTypeARef)
        recordType = 'aref';
    else
        continue
    end
        
    switch recordType
        case 'boundary'
            [boundaryMatch, ~] = regexp(tline,...
                'xy\(([-\d\.\s]+)\)', 'tokens', 'match');
         
            if ~isempty(boundaryMatch)
                coordsCell = regexp(boundaryMatch{1}, '\s', 'split');
                coordsAr = cellfun(@eval, coordsCell{1});
                coords = reshape(coordsAr, 2, length(coordsAr)/2)';

                shapeCount = shapeCount + 1;

                % Compute area using shoelace method
                area = area + shoelaceArea(coords);
            end
        case 'sref'
            target = recordTypeSRef{1}{1};
            if isfield(areaStruct, target)
%                 fprintf('Looking up computed area for structure %s\n', target);
                area = area + areaStruct.(target)(1);
                shapeCount = shapeCount + areaStruct.(target)(2);
            else
%                 fprintf('Computing and storing area  structure %s\n', target);

                [structArea, areaStruct, structShapeCount] = getStructureArea(gdtfname, target, areaStruct);
                shapeCount = shapeCount + structShapeCount;
                areaStruct.(target) = [structArea, structShapeCount];
                area = area + structArea;
            end
            
        case 'aref'
            target = recordTypeARef{1}{1};
            if isfield(areaStruct, target)
%                 fprintf('Looking up computed area for structure %s\n', target);
                area = area + areaStruct.(target)(1);
                shapeCount = shapeCount + areaStruct.(target)(2);
            else
%                 fprintf('Computing and storing area  structure %s\n', target);

                [structArea, areaStruct, structShapeCount] = getStructureArea(gdtfname, target, areaStruct);
                shapeCount = shapeCount + structShapeCount;
                areaStruct.(target) = [structArea, structShapeCount];
                area = area + structArea;
            end
        
        otherwise
            error('Unrecognized record type')
    end
    
    
end

fclose(fid);

fprintf('Found %d shapes\n', shapeCount);
