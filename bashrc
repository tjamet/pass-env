#!/usr/bin/env bash


function pass-env-usage() {
    echo "Usage: penv [-v] COMMAND ARGS..."
    echo "Commands:"
    echo "      export ENV_VARIABLE ITEM     decrypts pass ITEM and store it to ENV_VARIABLE"
    echo "      export ENV_VARIABLE          retrieve ITEM from ENV_VARIABLE registered with set"
    echo "                                   and decrypts pass ITEM and store it to ENV_VARIABLE"
    echo "      export                       exports all ENV_VARIABLES registered with set to the local environment"
    echo "      unset                        unsets all pass ENV_VARIABLES from environment"
    return 1
}

function pass-env-unset-all() {
    [ $# -eq 0 ] || {
        pass-env-usage
        return
    }
    for key in $(sed 's/^PASS_ENV_LOOKUP_\(.*\)=.*$/\1/g' ${PREFIX}/.pass-env); do
        unset $key
    done
}

function pass-env-export() {
    [ $# -eq 2 ] || {
        pass-env-usage
        return
    }
    local passwd=$(pass show ${2})
    r=$?
    export ${1}=${passwd}
    return ${r}
}

function pass-env-export-key() {
    [ $# -eq 1 ] || {
        pass-env-usage
        return
    }
    PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    for line in $(cat ${PREFIX}/.pass-env); do
        key=$(echo $line | cut -d= -f1)
        item=$(echo $line | cut -d= -f2)
        if [ ${key} == "PASS_ENV_LOOKUP_${1}" ]; then
            pass-env-export ${1} ${item}
            return
        fi
    done
    echo -e "Cannot find encrypted environment variable ${1}" > /dev/stderr
    return 1
}

function pass-env-export-all() {
    [ $# -eq 0 ] || {
        pass-env-usage
        return
    }
    PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    for line in $(cat ${PREFIX}/.pass-env); do
        key=$(echo $line | cut -d= -f1)
        item=$(echo $line | cut -d= -f2)
        pass-env-export ${key:16} ${item}
    done
}

function penv() {
    PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    case $1 in
        export)
            case $# in
                1)
                    shift
                    pass-env-export-all $@
                    ;;
                2)
                    shift
                    pass-env-export-key $@
                    ;;
                3)
                    shift
                    pass-env-export $@
                    ;;
                *)
                    {
                        pass-env-usage
                        return
                    }
                    ;;
            esac
            ;;
        unset)
            shift
            pass-env-unset-all $@
            ;;
        *)
            {
                pass-env-usage
                return
            }
            ;;
    esac
}
