# base-image for python on any machine using a template variable,
# see more about dockerfile templates here:http://docs.resin.io/pages/deployment/docker-templates
FROM resin/%%RESIN_MACHINE_NAME%%-python

RUN apt-get update && apt-get install build-essential cmake pkg-config \
		libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev && \
		apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev
		apt-get install libgtk-3-dev
		apt-get install libatlas-base-dev gfortran
		apt-get install python2.7-dev python3.5-dev

RUN wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.1.0.zip
RUN unzip opencv.zip
RUN wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.1.0.zip
RUN unzip opencv_contrib.zip
RUN cd ~/opencv-3.1.0/
RUN mdkir build
RUN cd build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.1.0/modules \
    -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
    -D BUILD_EXAMPLES=ON ..
RUN make -j4
RUN make clean
RUN make
RUN sudo make install
RUN sudo ldconfig

RUN pip install io
RUN pip install picamera
RUN pip install numpy
RUN pip install pushbullet.py
# Set our working directory
WORKDIR /usr/src/app2

# Copy requirements.txt first for better cache on later pushes
COPY ./requirements.txt /requirements.txt

# pip install python deps from requirements.txt on the resin.io build server
RUN pip install -r /requirements.txt

# This will copy all files in our root to the working	directory in the container
COPY . ./

# switch on systemd init system in container
ENV INITSYSTEM on

# setup-i2c.sh will run when container starts up on the device
#CMD ["bash", "setup-i2c.sh"]
