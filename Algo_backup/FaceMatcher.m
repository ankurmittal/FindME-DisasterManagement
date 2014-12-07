classdef FaceMatcher < handle

    properties
        src_dir;
        im
    end

    methods

        function fm = FaceMatcher()
            fm.src_dir = ...
                ['/nfs/bigeye/sdaptardar/' ... 
                'FindME-DisasterManagement/Algo/face_desc_src/'];
            addpath(genpath(fm.src_dir));
            run('startup');
        end

        function match(fm, img)

            fm.im = img;
            fprintf('%s\n', fm.im);
            fm.violaJones();
        end

        function violaJones(fm)

            fprintf('%s\n', fm.im);
            cd([fm.src_dir '/' 'violazones']);
%            ConvertHaarcasadeXMLOpenCV(...
%                [ fm.src_dir ...
%                'HaarCascades/haarcascade_frontalface_alt.xml']);
%
            ConvertHaarcasadeXMLOpenCV(...
                [ fm.src_dir '/' 'violazones' '/' ...
                'HaarCascades/haarcascade_frontalface_default.xml']);
            Options.Resize=true;
            ObjectDetection(fm.im, ...
                [  fm.src_dir '/' 'violazones' '/' ...
                'HaarCascades/haarcascade_frontalface_alt.mat'], ...
                Options);
        end

    end
end
