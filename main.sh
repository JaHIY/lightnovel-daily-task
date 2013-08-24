#!/bin/sh -

USER_AGENT='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0'

die() {
    printf '%s\n' "$@" 1>&2
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
    curl -s -c "$COOKIE_FILE" -A "$USER_AGENT" -d "username=${1}&password=${2}" \
        'http://www.lightnovel.cn/member.php?mod=logging&action=login&loginsubmit=yes' | \
        iconv -f GB18030 -t UTF8 | grep -q -F "${1}，现在将转入登录前页面" || \
            die 'Cannot get cookie!'
}

do_daily_task() {
    curl -s -b "$COOKIE_FILE" -A "$USER_AGENT" -e 'http://www.lightnovel.cn/home.php?mod=task&do=view&id=98' \
        'http://www.lightnovel.cn/home.php?mod=task&do=apply&id=98' | \
        iconv -f GB18030 -t UTF8 > /dev/null || \
            die 'Failed to apply daily task!'
    curl -s -b "$COOKIE_FILE" -A "$USER_AGENT" -e 'http://www.lightnovel.cn/home.php?mod=task&do=view&id=98' \
        'http://www.lightnovel.cn/home.php?mod=task&do=draw&id=98' | \
        iconv -f GB18030 -t UTF8 | grep -q -F '恭喜您，任务已成功完成' || \
            die 'Failed to do daily task!'
}

main() {
    local username
    local password
    if [ $# -eq 2 ]; then
        username="$1"
        password="$2"
    elif [ $# -eq 0 ]; then
        printf 'Loading config...\n'
        load_config
        username="$USERNAME"
        password="$PASSWORD"
    else
        die "Usage: $(basename "${0}") [your_username] [your_password]"
    fi
    trap 'clean_up_on_exit' EXIT
    COOKIE_FILE="$(mktemp "${TMPDIR-/tmp}/cookie-lightnovel.XXXXXXXXXX")"
    printf 'Getting cookie...\n'
    get_cookie "$username" "$password"
    printf 'Doing daily task...\n'
    do_daily_task
    printf 'Done\n'
    printf "Finished: $(date)\n"
}

main "$@"
