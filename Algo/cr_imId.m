
%load image list
load('./data/shared/info/database.mat', 'database');

imgList = database.images;
imgPath=fullfile(pwd,'data','images','lfw')
numImg = numel(imgList);
%database.images={}
%database.imgIds=[];
nameInfo=[]
%{
for i=1:1:numImg,
	if exist(fullfile(imgPath,old.database.images{i}),'file')
		sprintf(fullfile(imgPath,old.database.images{i}))
		database.images{end+1}=old.database.images{i}
	end
end
%}
%database.imgIds=containers.Map(database.images,1:size(database.images,4))
%[pathstr,name,ext] = fileparts(database.imgIds.keys);
sortedImg = sort(database.imgIds);
L = length(sortedImg.keys());
keys=sortedImg.keys();
values =sortedImg.values();

[prev_key_name,~,~] = fileparts(keys{1});
nameInfo(1).names.person=prev_key_name;
count=1;
nameInfo(1).names.imgIds= sortedImg(keys{1});
fid=fopen('names.txt','w') 
for i = 2:L
	[key_name,~,~] = fileparts(keys{i});
	if strcmp(key_name, prev_key_name)
		%nameInfo(end).names.imgIds= [nameInfo(end).names.imgIds,sortedImg(keys{i})];
		nameInfo(count).names.imgIds= [nameInfo(count).names.imgIds,values{i}];
	else
		count=count+1;	
		nameInfo(count).names.person = [key_name];
		nameInfo(count).names.imgIds = [values{i}];
	
	end
	prev_key_name = key_name;

end

for i=1:length(nameInfo),
	fprintf(fid,'%s\n',nameInfo(i).names.person)
end

%nameInfo(end+1).names.person=i;
save('./data/shared/info/unrest_names.mat','nameInfo');
