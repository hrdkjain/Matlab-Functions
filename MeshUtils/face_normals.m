function [ f_normals ] = face_normals( v, f )

f_normals = cross(v(f(:,2),:) - v(f(:,1),:), v(f(:,3),:) - v(f(:,1),:));

f_normals = f_normals ./ sqrt(sum(f_normals.^2,2));
end

