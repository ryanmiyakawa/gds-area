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

function [area, unit] = computeDrawnGDSArea(fname, structureName)

gdtfname = parseGDStoGDT(fname);

[area, ~, shapeCount, unit] = getStructureArea(gdtfname, structureName);


fprintf('GDS %s has area %0.4f in %d shapes\n', fname, area, shapeCount);

