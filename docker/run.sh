#!/bin/bash

if [ -z "${NCPU}" ] || [ ${NCPU} -le 1 ]; then
    /FrontISTR-5.0a/build/fistr1/fistr1
else
    /FrontISTR-5.0a/build/hecmw1/tools/hecmw_part1
    mpirun -np ${NCPU} /FrontISTR-5.0a/build/fistr1/fistr1
fi
