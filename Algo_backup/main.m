params=[];
data_loc='/nfs/bigeye/asarya/google_hack/FindME-DisasterManagement/Algo_backup/data/images/lfw/';
run('/home/asarya/software/VLFEATROOT/toolbox/vl_setup');
addpath(genpath('/nfs/bigeye/asarya/google_hack/FindME-DisasterManagement/Algo_backup/violazones/'));

features={};
%files=dir(data_loc)
files=getAllFiles(data_loc);
matlabpool open
for i=1:length(files)
	i
	im=imread(files{i});
	binSize = 8 ;
	magnif = 3 ;
	im=im(:,:,1);
%	im=run_face_matcher(im);
	Options=[]
	try,
		ConvertHaarcasadeXMLOpenCV('violazones/HaarCascades/haarcascade_frontalface_alt.xml'); 
% % Detect Faces 
 		Options.Resize=false; 
		[x,im]=ObjectDetection(im,'violazones/HaarCascades/haarcascade_frontalface_alt.mat',Options);	
	catch,
		pass	
%Is = vl_imsmooth(im, sqrt((binSize/magnif)^2 - .25)) ;
	[f, features{i}] = vl_dsift(im2single(im), 'size', binSize) ;
%	keyboard
end
save('./data/features.mat','features');
save('./data/files.mat',files);

