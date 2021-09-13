

%% Computing area from a GDS file:

gdsPath = 'test2.gds';
structureName = 'main';


[computedArea, unit] = computeDrawnGDSArea(gdsPath, structureName);

switch unit
    case 1e-06
        unitName = 'um';
    case 1e-09
        unitName = 'nm';
    otherwise
        unitName = 'unknown';
end

fprintf('GDS %s has drawn area of %0.4f %s^2\n', gdsPath, computedArea, unitName);
