# Spam /retest-required
GREEN=$'\e[32m'
RESET=$'\e[0m'

PR_NUM=81
REPO=openshift/oauth-apiserver
while true; do
    clear

    RESPONSE=$(gh pr checks "$PR_NUM" --repo "$REPO")
    PENDING_NUM=$(printf '%s' "$RESPONSE" | rg pending | wc -l)
    FAILS_URL=$(printf '%s' "$RESPONSE" | rg fail | choose 3)

    printf "%sRepo:%s %s, %sPR%s: %d\n\t%sPending%s: %d\n" "$GREEN" "$RESET" "$REPO" "$GREEN" "$RESET" "$PR_NUM" "$GREEN" "$RESET" "$PENDING_NUM"
    if [ -n "$FAILS_URL" ]; then
        printf "%sFailed:%s\n" "$GREEN" "$RESET"
        for URL in $(printf '%s' "$FAILS_URL" | tr ' ' '\n'); do
            printf '\t%s-%s %s\n' "$GREEN" "$RESET" "$URL"
        done
    fi
    if [ "$PENDING_NUM" -le 1 ]; then
        if [ -n "$FAILS_URL" ]; then
            printf 'making comment to retest\n'
            gh pr comment "$PR_NUM" --body '/retest-required' --repo "$REPO"
            sleep 3600
        else
            printf 'success'
        fi
    fi
    sleep 600
done
