#
# docker build ./ --build-arg USER_ID=`id -u` --build-arg GROUP_ID=`id -g` -t frontistr:5.0a
# cd [FrontISTR working directory]
# docker run -v `pwd`:/work -e NCPU=2 frontistr:5.0a
#
FROM centos:7
ARG USER_ID=1000
ARG GROUP_ID=1000

# /usr/lib64/openmpi/bin
RUN yum -y update \
 && yum -y install make \
 && yum -y install cmake \
 && yum -y install gcc gcc-c++ gcc-gfortran \
 && yum -y install openmpi \
 && yum -y install openmpi-devel \
 && yum -y install zlib-devel \
 && yum -y install git \
 && yum -y install wget \
 && yum -y install emacs \
 && yum -y install bison \
 && yum -y install flex \
 && yum -y install unzip \
 && yum -y install ruby

# OpenBLAS
# /usr/local/lib64
# /usr/local/include
RUN mkdir -p local \
 && cd local \
 && wget http://github.com/xianyi/OpenBLAS/archive/v0.2.20.tar.gz \
 && mv v0.2.20.tar.gz OpenBLAS-0.2.20.tar.gz \
 && tar xvfz OpenBLAS-0.2.20.tar.gz \
 && cd OpenBLAS-0.2.20 \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make \
 && make install
 
# scalapack
# /usr/local/lib
RUN mkdir -p local \
 && cd local \
 && wget http://www.netlib.org/scalapack/scalapack-2.0.2.tgz \
 && tar xvfz scalapack-2.0.2.tgz \
 && cd scalapack-2.0.2 \
 && export PATH=$PATH:/usr/lib64/openmpi/bin \
 && mkdir build \
 && cd build \
 && cmake -DBLAS_LIBRARIES=/usr/local/lib64/libopenblas.a -DLAPACK_LIBRARIES=/usr/local/lib64/libopenblas.a .. \
 && make \
 && make install

# metis
# /usr/local/lib
# /usr/local/include
RUN mkdir -p local \
 && cd local \
 && wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz \
 && tar xvfz metis-5.1.0.tar.gz \
 && cd metis-5.1.0 \
 && make config openmp=1 cc=gcc \
 && make && make install

# scotch
# /usr/local/lib
# /usr/local/include
RUN mkdir -p local \
 && cd local \
 && wget https://gforge.inria.fr/frs/download.php/file/34618/scotch_6.0.4.tar.gz \
 && tar xvfz scotch_6.0.4.tar.gz \
 && cd scotch_6.0.4/src \
 && cp Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc \
 && sed -i \
      -e "s|^CCS\s*= .*$|CCS = mpicc|" \
      -e "s|^CCD\s*= .*$|CCD = mpicc|" \
      Makefile.inc \
 && export PATH=$PATH:/usr/lib64/openmpi/bin \
 && make \
 && make install \
 && make ptesmumps \
 && make install \
 && cp -f esmumps/libptesmumps.a /usr/local/lib \
 && cp -f esmumps/esmumps.h /usr/local/include

# mumps
# /local/MUMPS_5.1.2/lib
# /local/MUMPS_5.1.2/include
RUN mkdir -p local \
 && cd local \
 && wget http://mumps.enseeiht.fr/MUMPS_5.1.2.tar.gz \
 && tar xvfz MUMPS_5.1.2.tar.gz \
 && export PATH=$PATH:/usr/lib64/openmpi/bin \
 && cd MUMPS_5.1.2 \
 && cp Make.inc/Makefile.inc.generic Makefile.inc \
 && sed -i \
      -e "s|^#SCOTCHDIR\s*= .*$|SCOTCHDIR = /usr/local|" \
      -e "s|^#ISCOTCH\s*= .*$|ISCOTCH = -I\$(SCOTCHDIR)/include|" \
      -e "s|^#LSCOTCH\s*= .*$|LSCOTCH = -L\$(SCOTCHDIR)/lib -lptesmumps -lptscotch -lptscotcherr -lscotch|" \
      -e "s|^#LMETISDIR = .*$|LMETISDIR = /usr/local/lib|" \
      -e "s|^#IMETIS    = .*$|IMETIS = -I/usr/local/include|" \
      -e "s|^#LMETIS    = -L\$(LMETISDIR) -lmetis$|LMETIS = -L\$(LMETISDIR) -lmetis|" \
      -e "s|^ORDERINGSF  = -Dpord$|ORDERINGSF = -Dpord -Dmetis -Dscotch|" \
      -e "s|^CC      = cc|CC      = mpicc|"  \
      -e "s|^FC      = f90|FC      = mpif90|"  \
      -e "s|^FL      = f90|FL      = mpifort|" \
      -e "s|^LAPACK = -llapack|LAPACK = -L/usr/local/lib64 -lopenblas|" \
      -e "s|^SCALAP  = -lscalapack -lblacs|SCALAP  = -L/usr/local/lib -lscalapack|" \
      -e "s|^LIBBLAS = -lblas|LIBBLAS = -L/usr/local/lib64 -lopenblas|" \
      -e "s|^OPTF    = -O|OPTF    = -O ${OMP}|" \
      -e "s|^OPTC    = -O -I\.|OPTC    = -O -I. ${OMP}|" \
      -e "s|^OPTL    = -O|OPTL    = -O ${OMP}|" \
      Makefile.inc \
 && make \
 && cp include/*.h /usr/local/include \
 && cp lib/*.a /usr/local/lib

# Trilinos
RUN mkdir -p local \
 && cd local \
 && wget https://github.com/trilinos/Trilinos/archive/trilinos-release-12-12-1.tar.gz \ 
 && tar xvfz trilinos-release-12-12-1.tar.gz \
 && export PATH=$PATH:/usr/lib64/openmpi/bin \
 && cd Trilinos-trilinos-release-12-12-1 \
 && mkdir build \
 && cd build \
 && cmake \
        -DCMAKE_C_COMPILER=mpicc \
        -DCMAKE_CXX_COMPILER=mpicxx \
        -DCMAKE_Fortran_COMPILER=mpifort \
        -DTPL_ENABLE_MPI=ON \
        -DTPL_ENABLE_LAPACK=ON \
        -DTPL_ENABLE_SCALAPACK=ON \
        -DTPL_ENABLE_METIS=ON \
        -DTPL_ENABLE_MUMPS=ON \
        -DTrilinos_ENABLE_ML=ON \
        -DTrilinos_ENABLE_Zoltan=ON \
        -DTrilinos_ENABLE_OpenMP=ON \
        -DTrilinos_ENABLE_Amesos=ON \
        -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
        -DBLAS_LIBRARY_DIRS="/usr/local/lib64" \
        -DLAPACK_LIBRARY_DIRS="/usr/local/lib64" \
        -DSCALAPACK_LIBRARY_DIRS="/usr/local/lib" \
        -DBLAS_LIBRARY_NAMES="openblas" \
        -DLAPACK_LIBRARY_NAMES="openblas" \
        -DSCALAPACK_LIBRARY_NAMES="scalapack" \
        .. \
 && make \
 && make install

RUN wget https://github.com/FrontISTR/FrontISTR/archive/v5.0a.tar.gz \
 && tar xvfz v5.0a.tar.gz \
 && cd FrontISTR-5.0a \
 && export PATH=$PATH:/usr/lib64/openmpi/bin \
 && export MUMPS_ROOT=/local/MUMPS_5.1.2 \
 && mkdir build \
 && cd build \
 && cmake -DWITH_TOOLS=1 -DWITH_MPI=1 -DWITH_METIS=1 -DWITH_MUMPS=1 \
       -DBLAS_LIBRARIES=/usr/local/lib64/libopenblas.a \
       -DLAPACK_LIBRARIES=/usr/local/lib64/libopenblas.a \
       -DMUMPS_LIBRARIES="/usr/local/lib/libptesmumps.a;/usr/local/lib/libptesmumps.a;/usr/local/lib/libptscotch.a;/usr/local/lib/libptscotcherr.a;/usr/local/lib/libscotch.a" \
       .. \
 && make

RUN echo '#!/bin/bash' > /FrontISTR-5.0a/run.sh \
 && echo 'if [ -z "${NCPU}" ] || [ ${NCPU} -le 1 ]; then' >> /FrontISTR-5.0a/run.sh \
 && echo '    /FrontISTR-5.0a/build/fistr1/fistr1' >> /FrontISTR-5.0a/run.sh \
 && echo 'else' >> /FrontISTR-5.0a/run.sh \
 && echo '    /FrontISTR-5.0a/build/hecmw1/tools/hecmw_part1' >> /FrontISTR-5.0a/run.sh \
 && echo '    mpirun -np ${NCPU} /FrontISTR-5.0a/build/fistr1/fistr1' >> /FrontISTR-5.0a/run.sh \
 && echo 'fi'  >> /FrontISTR-5.0a/run.sh \
 && chmod 755 /FrontISTR-5.0a/run.sh

RUN groupadd -g ${GROUP_ID} fistr
RUN useradd -u ${USER_ID} -g ${GROUP_ID} fistr
ENV PATH=$PATH:/usr/lib64/openmpi/bin
USER fistr
WORKDIR /work
CMD [ "/FrontISTR-5.0a/run.sh" ]
