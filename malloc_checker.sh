#!/bin/bash

MALLOC_LIMIT=1
LOOP=0
CC=clang
BIN=
LIB_NAME=malloc_wrapper.dylib
SCRIPT_NAME=$0
RETURN_VALUE=${SUCCESS}
RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"
SUCCESS=0
FAILURE=1

USAGE="\nusage:\t${SCRIPT_NAME} bin={value} limit={value} [loop={value}]\n"
HELP="option description:\n\tbin: binary you want to test\n\tlimit: the number of calls to malloc that can succeed before malloc returns NULL\n\tloop: [optional parameter] -> use if you want to loop from 0 to limit (default: false)"

if [ -z "$1" ]; then
	echo -e $USAGE >&2
	echo -e $HELP >&2
	exit $FAILURE
fi
for ARG in "$@";
do
	if [[ ${ARG} == "loop="* ]]; then
		LOOP=$(echo $ARG | cut -d '=' -f 2)
	elif [[ ${ARG} == "limit="* ]]; then
		MALLOC_LIMIT=$(echo $ARG | cut -d '=' -f 2)
	elif [[ ${ARG} == "bin="* ]]; then
		BIN=$(echo $ARG | cut -d '=' -f 2)
	elif [ "${ARG}" == "--help" ] || [ "${ARG}" == "-h" ]; then
		echo -e $USAGE >&2
		echo -e $HELP >&2
		exit $FAILURE
	else
		echo -e "${RED}Bad argument: ${ARG}${NC}\n${USAGE}" >&2
		exit $FAILURE
	fi
done

START=${MALLOC_LIMIT}

if [[ ${LOOP} == "true" ]] || [[ ${LOOP} == "1" ]]; then
	START=0
fi

for i in $(seq ${START} 1 ${MALLOC_LIMIT})
do
	echo ---- MALLOC_LIMIT = ${i} -----
	${CC} -dynamiclib -D MALLOC_LIMIT=${i} -o ${LIB_NAME} malloc_wrapper.c
	DYLD_INSERT_LIBRARIES=$(pwd)/${LIB_NAME} DYLD_FORCE_FLAT_NAMESPACE=1 ${BIN} 1>/dev/null
	if [ "$?" -gt "127" ]; then
		echo -e "${RED}KO${NC}"
		RETURN_VALUE=${FAILURE}
	else
		echo -e "${GREEN}OK${NC}"
	fi
	rm -f ${LIB_NAME}
done
exit ${RETURN_VALUE}
