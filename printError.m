function printError(err)
fprintf("Error: %s\n", err.message);
for i = 1:numel(err.stack)
    fprintf("in %s line %d\n", err.stack(i).file, err.stack(i).line);
end
end
