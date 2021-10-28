function [log] = save_manifold_mesh(meshlabserverpath, vertn, facen, outputFile)
log = [];

%save the mesh
write_off(outputFile, vertn, facen);

% check if it is nonManifold and try to clean it with meshlabserver
[log, isNonManifold] = hasNonManifoldEdges(facen, vertn, log);
if isNonManifold
    % this means there are some edges which have more than 2 faces
    % so now use meshlabserver to clean it
    setenv('PATH', getenv('PATH'));
    setenv('LD_LIBRARY_PATH', '/usr/lib/qt5/bin'); % QTTOOLDIR output of $qtchooser -print-env
    cmd=sprintf('%s -i %s -o %s -s %s', meshlabserverpath, outputFile, outputFile, 'manifoldHoles.mlx'); %&> /dev/null

    [status,cmdout] = system(cmd,'-echo');
    if status~=0
        log = [log, sprintf(cmdout)];
    else
        [V,F] = read_mesh(outputFile);
        [log, isNonManifold] = hasNonManifoldEdges(F,V,log);
        if isNonManifold
            log = [log, sprintf(', applied meshlab script, still non-manifold, removing non-manifold output.')];
            %remove the mesh if it is still non-manifold
            fprintf('removing non-manifold output.')
            delete(outputFile);
        end
    end
end
end

function [log,isNonManifold] = hasNonManifoldEdges(facen, vertn, log)
% check for edge non-manifoldness
isNonManifold = true;
try
    TR = triangulation(facen,vertn);
catch err
    log = [log,sprintf(', %s',err.message)];
    return;
end
E = edges(TR);
ID = edgeAttachments(TR,E);
A = cellfun('size', ID, 2);
if sum(A-2)<=0
    isNonManifold = false;
end
genus = (size(vertn,1) - size(E,1) + size(facen,1) - 2)/2;
if genus~=0
    log = [log,sprintf(', genus %0.1f', genus)];
end
end

