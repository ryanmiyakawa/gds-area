% 2021/09/10 R Miyakawa
%
% Parses GDS file and writes to GDT file

function gdtfname = parseGDStoGDT(fname)


if (nargin == 0)
    [p, d] = uigetfile();
    fname = fullfile(d, p);
end

[d, p, e] = fileparts(fname);

gdtfname = fullfile(d, [p '.gdt']);

% Write gds to file
fprintf('Writing GDT file: %s\n', gdtfname);
[~, out] = system(sprintf('./gds2gdt.Darwin %s %s', fname, gdtfname));


