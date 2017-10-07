# get a token from CloudForms, keep the current if it's still valid.
get_token() {
    if [ -n "$tok" ]; then
        # verify it's still valid

        if [ $tok_expire_on -gt $(date +%s) ]; then
            return
        fi
    fi

    : ${username?"Username not set"}
    : ${password?"password not set"}
    : ${uri?"uri not set"}

    token_info=$(curl -s --user $username:$password \
                      -X GET -H "Accept: application/json" \
                      $uri/api/auth\
                     | jq -r '.auth_token + ";" + (.token_ttl|tostring)')

    tok=${token_info%;*}
    tok_ttl=${token_info#*;}

    if [ -z "${tok}" -o -z "${tok_ttl}" ]; then
        echo >&2 "issue with token"
        exit 1
    fi

    export tok
    export tok_expire_on=$(date --date="now + ${tok_ttl} seconds" +%s)
}

json_escape () {
    printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}
