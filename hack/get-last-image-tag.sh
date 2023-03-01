REPOSITORY=${1:-"kostrows/oauth-apiserver"}
curl --silent "https://quay.io/api/v1/repository/${REPOSITORY}/tag/?limit=100&page=1&onlyActiveTags=true" \
    -H 'Accept: application/json, text/plain, */*' \
   | jq '.tags[0].name' | sed 's/"//g' \
   | xargs -I TAG printf 'quay.io/%s:%s' "$REPOSITORY" TAG
