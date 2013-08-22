#!/bin/sh -

USER_AGENT='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0'

err() {
    printf "$@" 1>&2
}

die() {
    err "$@"
    exit 1
}

clean_up() {
    rm "$COOKIE_FILE" || die 'Cannot delete cookie file!'
}

clean_up_on_exit() {
    printf '\nExiting...\nCleaning up...'
    clean_up
    printf '\n'
}

load_config() {
    local where_am_i=''
    if [ -L "$0" ]; then
        where_am_i="$(readlink -f "$0")"
    else
        where_am_i="$0"
    fi
    source "$(dirname "$where_am_i")/config" || die 'Cannot load config file!'
}

get_cookie() {
    curl -s -c "$COOKIE_FILE" -A "$USER_AGENT" -d "username=${USERNAME}&password=${PASSWORD}" \
        'http://www.lightnovel.cn/member.php?mod=logging&action=login&loginsubmit=yes' | \
        iconv -f GB18030 -t UTF8 | grep -q -F "$USERNAME" || \
            die 'Cannot get cookie!'
}

do_daily_task() {
    curl -s -b "$COOKIE_FILE" -A "$USER_AGENT" -e 'http://www.lightnovel.cn/home.php?mod=task&do=view&id=98' \
        'http://www.lightnovel.cn/home.php?mod=task&do=apply&id=98' | \
        iconv -f GB18030 -t UTF8 | grep -q -F '任务已成功完成' || \
            die 'Failed to do daily task!'
}

main() {
    trap 'clean_up_on_exit' EXIT
    local COOKIE_FILE="$(mktemp "${TMPDIR-/tmp}/cookie-lightnovel.XXXXXXXXXX")"
    printf 'Loading config...\n'
    load_config
    printf 'Getting cookie...\n'
    get_cookie
    printf 'Doing daily task...\n'
    do_daily_task
    printf 'Done\n'
    printf "Finished: $(date)\n"
}

main "$@"
