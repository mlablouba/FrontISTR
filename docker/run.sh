#!/bin/bash

if [ -z "${NCPU}" ] || [ ${NCPU} -le 1 ]; then
    fistr1
else
    hecmw_part1
    mpirun -np ${NCPU} fistr1
fi
