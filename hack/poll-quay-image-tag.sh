PREVIOUS=
REPOSITORY="${1:-kostrows/oauth-apiserver}"

while true; do
    clear
    CURRENT=$(curl --silent "https://quay.io/api/v1/repository/${REPOSITORY}/tag/?limit=100&page=1&onlyActiveTags=true" \
        -H 'Accept: application/json, text/plain, */*' \
        | jq '.tags[0].name' | sed 's/"//g' \
        | xargs -I TAG printf 'quay.io/%s:%s' "$REPOSITORY" TAG)
    if [ "$PREVIOUS" != "$CURRENT" ]; then
        echo "New version: $CURRENT"
        echo "Previous version: $PREVIOUS"
        PREVIOUS=$CURRENT
    fi
    sleep 10
done
