#!/bin/sh
#$-cwd
#$-N face_rec
#$-j y
#$ -o  /nfs/bigeye/asarya/face_recognition/FindME-DisasterManagement/Algo/logs/log.$JOB_ID.$TASK_ID.out
#$ -e  /nfs/bigeye/asarya/face_recognition/FindME-DisasterManagement/Algo/logs/log.$JOB_ID.$TASK_ID.err
#$-M asarya@cs.stonybrook.edu
#$-m ea
#$-t 1
#$-pe mpi 12
#$-l hostname=bigvision.cs.stonybrook.edu
export LD_LIBRARY_PATH=/opt/matlab_r2010b/bin/glnxa64:/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
export DISPLAY=localhost:11.0
echo "Starting job: $SGE_TASK_ID"
matlab -nodesktop -nosplash -singleCompThread < /nfs/bigeye/asarya/face_recognition/FindME-DisasterManagement/Algo/face_desc_src/main.m
echo "Ending job: $SGE_TASK_ID"




