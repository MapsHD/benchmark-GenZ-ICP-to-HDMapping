docker run --rm -it -v $(pwd)/data:/data --name genzicp2hdmapping genzicp2hdmapping:latest bash -c 'rosbags-convert --src /data/ConSLAM/sequence1/*.bag --dst /data/ConSLAM/sequence1/converted' 
docker run --rm -it -v $(pwd)/data:/data --name genzicp2hdmapping genzicp2hdmapping:latest bash -c 'rosbags-convert --src /data/ConSLAM/sequence2/*.bag --dst /data/ConSLAM/sequence2/converted' 
docker run --rm -it -v $(pwd)/data:/data --name genzicp2hdmapping genzicp2hdmapping:latest bash -c 'rosbags-convert --src /data/ConSLAM/sequence3/*.bag --dst /data/ConSLAM/sequence3/converted' 
docker run --rm -it -v $(pwd)/data:/data --name genzicp2hdmapping genzicp2hdmapping:latest bash -c 'rosbags-convert --src /data/ConSLAM/sequence4/*.bag --dst /data/ConSLAM/sequence4/converted' 
docker run --rm -it -v $(pwd)/data:/data --name genzicp2hdmapping genzicp2hdmapping:latest bash -c 'rosbags-convert --src /data/ConSLAM/sequence5/*.bag --dst /data/ConSLAM/sequence5/converted' 

