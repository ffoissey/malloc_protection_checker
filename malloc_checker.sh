#!/bin/bash

SUCCESS=0
FAILURE=1
MALLOC_LIMIT=1
LOOP=0
CC=clang
BIN=
LIB_NAME=libmalloc_wrapper
SCRIPT_NAME=$0
RETURN_VALUE=${SUCCESS}
RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"

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


if [ -z "$BIN" ]; then
	echo "You need to specify 'bin' option" >&2
	echo -e $USAGE >&2
	echo -e $HELP >&2
	exit $FAILURE
fi

START=${MALLOC_LIMIT}
BIN_NAME=$(basename $(echo $BIN | cut -d ' ' -f 1))


if [[ ${LOOP} == "true" ]] || [[ ${LOOP} == "1" ]]; then
	START=0
fi

for i in $(seq ${START} 1 ${MALLOC_LIMIT})
do
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		echo ---- MALLOC_LIMIT = ${i} -----
		${CC} -ldl -shared -fPIC -D_GNU_SOURCE -D BIN_NAME="\"${BIN_NAME}\"" -D MALLOC_LIMIT=${i} -o ${LIB_NAME}.so malloc_wrapper.c
		LD_PRELOAD=$(pwd)/${LIB_NAME}.so ${BIN} 1>/dev/null
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		echo ---- MALLOC_LIMIT = ${i} -----
		${CC} -dynamiclib -D BIN_NAME="\"${BIN_NAME}\"" -D MALLOC_LIMIT=${i} -o ${LIB_NAME}.dylib malloc_wrapper.c
		DYLD_INSERT_LIBRARIES=$(pwd)/${LIB_NAME}.dylib DYLD_FORCE_FLAT_NAMESPACE=1 ${BIN} 1>/dev/null
	else
		echo -e "This program is not designed to run on this OS version: \"$OSTYPE\"" >&2
		exit ${FAILURE}
	fi
	if [ "$?" -gt "127" ]; then
		echo -e "${RED}KO${NC}"
		RETURN_VALUE=${FAILURE}
	else
		echo -e "${GREEN}OK${NC}"
	fi
	rm -f ${LIB_NAME}*
done
exit ${RETURN_VALUE}
