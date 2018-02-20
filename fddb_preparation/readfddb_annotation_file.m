function data = readfddb_annotation_file(filename)

data = {};
fid = fopen(filename);

i=1;
while ~feof(fid)
  name = fgets(fid);  
  data{i}.name = name;
  num_data = str2num(fgets(fid));  
  data{i}.faces = zeros(num_data, 6);
  for j=1:num_data
    str = fgets(fid);      
    data{i}.faces(j,:) = sscanf(str, '%f %f %f %f %f %d\n');
  end
  i = i + 1;
end

fclose(fid);

